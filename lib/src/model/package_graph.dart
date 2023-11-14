// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/inheritance_manager3.dart'
    show InheritanceManager3;
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk, SdkLibrary;
// ignore: implementation_imports
import 'package:analyzer/src/generated/source.dart' show Source;
// ignore: implementation_imports
import 'package:analyzer/src/generated/timestamped_data.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/package_meta.dart'
    show PackageMeta, PackageMetaProvider;
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/tool_definition.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';

class PackageGraph with CommentReferable, Nameable, ModelBuilder {
  PackageGraph.uninitialized(
    this.config,
    DartSdk sdk,
    this.hasEmbedderSdk,
    this.rendererFactory,
    this.packageMetaProvider,
  )   : packageMeta = config.topLevelPackageMeta,
        sdkLibrarySources = {
          for (var lib in sdk.sdkLibraries) sdk.mapDartUri(lib.shortName): lib
        } {
    // Make sure the default package exists, even if it has no libraries.
    // This can happen for packages that only contain embedder SDKs.
    Package.fromPackageMeta(packageMeta, this);
  }

  final InheritanceManager3 inheritanceManager = InheritanceManager3();

  final Map<Source?, SdkLibrary> sdkLibrarySources;

  void dispose() {
    // Clear out any cached tool snapshots and temporary directories.
    // TODO(jcollins-g): Consider ownership change for these objects
    // so they are tied to PackageGraph instead of being global.
    SnapshotCache.instanceFor(config.resourceProvider).dispose();
    ToolTempFileTracker.instanceFor(config.resourceProvider).dispose();
  }

  @override
  String get name => '';

  @override
  String get displayName => throw UnimplementedError();

  @override
  String get breadcrumbName => throw UnimplementedError();

  /// Adds [resolvedLibrary] to the package graph, adding it to [allLibraries],
  /// and to the [Package] which is created from the [PackageMeta] for the
  /// library.
  ///
  /// Call during initialization to add a library to this [PackageGraph].
  ///
  /// Libraries added in this manner are assumed to be part of documented
  /// packages, even if 'includes' or 'embedder.yaml' files cause these to
  /// span packages.
  void addLibraryToGraph(DartDocResolvedLibrary resolvedLibrary) {
    assert(!allLibrariesAdded);
    var libraryElement = resolvedLibrary.element;
    var packageMeta =
        packageMetaProvider.fromElement(libraryElement, config.sdkDir);
    if (packageMeta == null) {
      var libraryPath = libraryElement.librarySource.fullName;
      var dartOrFlutter = config.flutterRoot == null ? 'dart' : 'flutter';
      throw DartdocFailure(
          "Unknown package for library: '$libraryPath'.  Consider "
          '`$dartOrFlutter pub get` and/or '
          '`$dartOrFlutter pub global deactivate dartdoc` followed by '
          '`$dartOrFlutter pub global activate dartdoc` to fix. Also, be sure '
          'that `$dartOrFlutter analyze` completes without errors.');
    }
    var package = Package.fromPackageMeta(packageMeta, this);
    var lib = Library.fromLibraryResult(resolvedLibrary, this, package);
    package.libraries.add(lib);
    allLibraries[libraryElement.source.fullName] = lib;
  }

  /// Adds [resolvedLibrary] as a special library to the package graph, which
  /// adds the library to [allLibraries], but does not add it to any [Package]'s
  /// list of libraries.
  ///
  /// Call during initialization to add a library possibly containing
  /// special/non-documented elements to this [PackageGraph].  Must be called
  /// after any normal libraries.
  void addSpecialLibraryToGraph(DartDocResolvedLibrary resolvedLibrary) {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    final libraryElement = resolvedLibrary.element.library;
    allLibraries.putIfAbsent(
      libraryElement.source.fullName,
      () => Library.fromLibraryResult(
        resolvedLibrary,
        this,
        Package.fromPackageMeta(
            packageMetaProvider.fromElement(libraryElement, config.sdkDir)!,
            packageGraph),
      ),
    );
  }

  /// Call after all libraries are added.
  Future<void> initializePackageGraph() async {
    assert(!_localDocumentationBuilt);
    allLibrariesAdded = true;
    // Go through docs of every ModelElement in package to pre-build the macros
    // index.
    await Future.wait(_precacheLocalDocs());
    _localDocumentationBuilt = true;

    // Scan all model elements to insure that interceptor and other special
    // objects are found.
    // Emit warnings for any local package that has no libraries.
    // This must be done after the [allModelElements] traversal to be sure that
    // all packages are picked up.
    for (var package in _documentedPackages) {
      for (var library in package.libraries) {
        _addToImplementors(library.allClasses);
        _addToImplementors(library.mixins);
        _extensions.addAll(library.extensions);
      }
      if (package.isLocal && !package.hasPublicLibraries) {
        package.warn(PackageWarning.noDocumentableLibrariesInPackage);
      }
    }
    allImplementorsAdded = true;
    allExtensionsAdded = true;

    // We should have found all special classes by now.
    specialClasses.assertSpecials();
  }

  /// Generate a list of futures for any docs that actually require precaching.
  Iterable<Future<void>> _precacheLocalDocs() {
    // Prevent reentrancy.
    var precachedElements = <ModelElement>{};
    var futures = <Future<void>>[];

    logInfo('Linking elements...');
    // This is awkward, but initializing this late final field is a sizeable
    // chunk of work. Several seconds for a small package.
    var allModelElements = _gatherModelElements();
    logInfo('Precaching local docs for ${allModelElements.length} elements...');
    progressBarStart(allModelElements.length);
    for (var element in allModelElements) {
      progressBarTick();
      // Only precache elements which are canonical, have a canonical element
      // somewhere, or have a canonical enclosing element. Not the same as
      // `allCanonicalModelElements` since we need to run for any [ModelElement]
      // that might not _have_ a canonical [ModelElement], too.
      if (element.isCanonical ||
          element.canonicalModelElement == null ||
          element.enclosingElement!.isCanonical) {
        for (var d in element.documentationFrom
            .where((d) => d.hasDocumentationComment)) {
          if (d.needsPrecache && !precachedElements.contains(d)) {
            precachedElements.add(d as ModelElement);
            futures.add(d.precacheLocalDocs());
            // [TopLevelVariable]s get their documentation from getters and
            // setters, so should be precached if either has a template.
            if (element is TopLevelVariable &&
                !precachedElements.contains(element)) {
              precachedElements.add(element);
              futures.add(element.precacheLocalDocs());
            }
          }
        }
      }
    }
    progressBarComplete();
    // Now wait for any of the tasks still running to complete.
    futures.add(config.tools.runner.wait());
    return futures;
  }

  /// Initializes the category mappings in all [packages].
  void initializeCategories() {
    for (var package in packages) {
      package.initializeCategories();
    }
  }

  // Many ModelElements have the same ModelNode; don't build/cache this data
  // more than once for them.
  final Map<Element, ModelNode> _modelNodes = {};

  /// The collection of "special" classes for which we need some special access.
  final specialClasses = SpecialClasses();

  /// Populate's [_modelNodes] with elements in [resolvedLibrary].
  ///
  /// This is done as [Library] model objects are created, while we are holding
  /// onto [resolvedLibrary] objects.
  // TODO(srawlins): I suspect we populate this mapping with way too many
  // objects, too eagerly. They are only needed when writing the source code of
  // an element to HTML, and maybe for resolving doc comments. We should find a
  // way to get this data only when needed. But it's not immediately obvious to
  // me how, because the data is on AST nodes, not the element model.
  void gatherModelNodes(DartDocResolvedLibrary resolvedLibrary) {
    for (var unit in resolvedLibrary.units) {
      for (var declaration in unit.declarations) {
        _populateModelNodeFor(declaration);
        switch (declaration) {
          case ClassDeclaration():
            for (var member in declaration.members) {
              _populateModelNodeFor(member);
            }
          case EnumDeclaration():
            if (declaration.declaredElement?.isPublic ?? false) {
              for (var member in declaration.members) {
                _populateModelNodeFor(member);
              }
            }
          case MixinDeclaration():
            for (var member in declaration.members) {
              _populateModelNodeFor(member);
            }
          case ExtensionDeclaration():
            if (declaration.declaredElement?.isPublic ?? false) {
              for (var member in declaration.members) {
                _populateModelNodeFor(member);
              }
            }
          case ExtensionTypeDeclaration():
            if (declaration.declaredElement?.isPublic ?? false) {
              for (var member in declaration.members) {
                _populateModelNodeFor(member);
              }
            }
        }
      }
    }
  }

  void _populateModelNodeFor(Declaration declaration) {
    if (declaration is FieldDeclaration) {
      var fields = declaration.fields.variables;
      for (var field in fields) {
        var element = field.declaredElement!;
        _modelNodes.putIfAbsent(
            element, () => ModelNode(field, element, resourceProvider));
      }
      return;
    }
    if (declaration is TopLevelVariableDeclaration) {
      var fields = declaration.variables.variables;
      for (var field in fields) {
        var element = field.declaredElement!;
        _modelNodes.putIfAbsent(
            element, () => ModelNode(field, element, resourceProvider));
      }
      return;
    }
    var element = declaration.declaredElement!;
    _modelNodes.putIfAbsent(
        element, () => ModelNode(declaration, element, resourceProvider));
  }

  ModelNode? getModelNodeFor(Element element) => _modelNodes[element];

  /// It is safe to cache values derived from the [_implementors] table if this
  /// is true.
  bool allImplementorsAdded = false;

  /// It is safe to cache values derived from the [_extensions] table if this
  /// is true.
  bool allExtensionsAdded = false;

  Map<InheritingContainer, List<InheritingContainer>> get implementors {
    assert(allImplementorsAdded);
    return _implementors;
  }

  Iterable<Extension> get documentedExtensions =>
      utils.filterNonDocumented(extensions).toList(growable: false);

  Iterable<Extension> get extensions {
    assert(allExtensionsAdded);
    return _extensions;
  }

  /// All library objects related to this package; a superset of [libraries].
  ///
  /// Keyed by `LibraryElement.Source.fullName` to resolve different URIs, which
  /// refer to the same location, to the same [Library].  This isn't how Dart
  /// works internally, but Dartdoc pretends to avoid documenting or duplicating
  /// data structures for the same "library" on disk based on how it is
  /// referenced.  We can't use [Source] as a key due to differences in the
  /// [TimestampedData] timestamps.
  ///
  /// This mapping must be complete before [initializePackageGraph] is called.
  @visibleForTesting
  final Map<String, Library> allLibraries = {};

  /// All [ModelElement]s constructed for this package; a superset of
  /// the elements gathered in [_gatherModelElements].
  final Map<(Element element, Library library, Container? enclosingElement),
      ModelElement> allConstructedModelElements = {};

  /// Anything that might be inheritable, place here for later lookup.
  final Map<(Element, Library), Set<ModelElement>> allInheritableElements = {};

  /// A mapping of the list of classes which implement each class.
  final Map<InheritingContainer, List<InheritingContainer>> _implementors =
      LinkedHashMap<InheritingContainer, List<InheritingContainer>>(
          equals: (InheritingContainer a, InheritingContainer b) =>
              a.definingContainer == b.definingContainer,
          hashCode: (InheritingContainer clazz) =>
              clazz.definingContainer.hashCode);

  /// A list of extensions that exist in the package graph.
  final List<Extension> _extensions = [];

  /// PackageMeta for the default package.
  final PackageMeta packageMeta;

  /// Name of the default package.
  String get defaultPackageName => packageMeta.name;

  /// Dartdoc's configuration flags.
  final DartdocOptionContext config;

  /// Factory for renderers
  final RendererFactory rendererFactory;

  /// PackageMeta Provider for building [PackageMeta]s.
  final PackageMetaProvider packageMetaProvider;

  late final Package defaultPackage =
      Package.fromPackageMeta(packageMeta, this);

  final bool hasEmbedderSdk;

  bool get hasFooterVersion => !config.excludeFooterVersion;

  @override
  PackageGraph get packageGraph => this;

  /// Map of package name to Package.
  ///
  /// This mapping must be complete before [initializePackageGraph] is called.
  final Map<String, Package> packageMap = {};

  ResourceProvider get resourceProvider => config.resourceProvider;

  final Map<String, String> _macros = {};
  final Map<String, String> _htmlFragments = {};
  bool allLibrariesAdded = false;

  /// Whether the local documentation has been built, which is only complete
  /// after all of the work in [_precacheLocalDocs] is done.
  bool _localDocumentationBuilt = false;

  /// Keep track of warnings.
  late final PackageWarningCounter packageWarningCounter =
      PackageWarningCounter(this);

  final Set<(Element? element, PackageWarning packageWarning, String? message)>
      _warnAlreadySeen = {};

  void warnOnElement(Warnable? warnable, PackageWarning kind,
      {String? message,
      Iterable<Locatable> referredFrom = const [],
      Iterable<String> extendedDebug = const []}) {
    var newEntry = (warnable?.element, kind, message);
    if (_warnAlreadySeen.contains(newEntry)) {
      return;
    }
    // Warnings can cause other warnings.  Queue them up via the stack but don't
    // allow warnings we're already working on to get in there.
    _warnAlreadySeen.add(newEntry);
    _warnOnElement(warnable, kind,
        message: message ?? '',
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
    _warnAlreadySeen.remove(newEntry);
  }

  void _warnOnElement(Warnable? warnable, PackageWarning kind,
      {required String message,
      Iterable<Locatable> referredFrom = const [],
      Iterable<String> extendedDebug = const []}) {
    if (warnable is ModelElement && kind == PackageWarning.ambiguousReexport) {
      // This sort of warning is only applicable to top level elements.
      var enclosingElement = warnable.enclosingElement;
      while (enclosingElement != null && enclosingElement is! Library) {
        warnable = enclosingElement;
        enclosingElement = warnable.enclosingElement;
      }
    }

    // If we don't have an element, we need a message to disambiguate.
    assert(warnable != null || message.isNotEmpty);

    if (packageWarningCounter.hasWarning(warnable, kind, message)) {
      return;
    }
    // Some kinds of warnings are OK to drop if we're not documenting them.
    // TODO(jcollins-g): drop this and use new flag system instead.
    if (warnable != null &&
        skipWarningIfNotDocumentedFor.contains(kind) &&
        !warnable.isDocumented) {
      return;
    }
    // Elements that are part of the Dart SDK can have colons in their FQNs.
    // This confuses IntelliJ and makes it so it can't link to the location of
    // the error in the console window, so separate out the library from the
    // path.
    // TODO(jcollins-g): What about messages that may include colons?
    // Substituting them out doesn't work as well there since it might confuse
    // the user, yet we still want IntelliJ to link properly.
    final warnableName = warnable.safeWarnableName;

    var warningMessage = switch (kind) {
      PackageWarning.ambiguousReexport =>
        kind.messageFor([warnableName, message]),
      PackageWarning.noCanonicalFound => kind.messageFor([warnableName]),
      PackageWarning.noLibraryLevelDocs ||
      PackageWarning.noDocumentableLibrariesInPackage =>
        kind.messageFor([warnable!.fullyQualifiedName]),
      PackageWarning.ambiguousDocReference ||
      PackageWarning.ignoredCanonicalFor ||
      PackageWarning.packageOrderGivesMissingPackageName ||
      PackageWarning.reexportedPrivateApiAcrossPackages ||
      PackageWarning.unresolvedDocReference ||
      PackageWarning.unknownMacro ||
      PackageWarning.unknownHtmlFragment ||
      PackageWarning.brokenLink ||
      PackageWarning.duplicateFile ||
      PackageWarning.orphanedFile ||
      PackageWarning.unknownFile ||
      PackageWarning.missingFromSearchIndex ||
      PackageWarning.typeAsHtml ||
      PackageWarning.invalidParameter ||
      PackageWarning.toolError ||
      PackageWarning.deprecated ||
      PackageWarning.unresolvedExport ||
      PackageWarning.missingConstantConstructor ||
      PackageWarning.missingExampleFile ||
      PackageWarning.missingCodeBlockLanguage =>
        kind.messageFor([message])
    };

    var fullMessage = [
      warningMessage,
      if (warnable != null) kind.messageForWarnable(warnable),
      for (var referral in referredFrom)
        if (referral != warnable) kind.messageForReferral(referral),
      if (config.verboseWarnings) ...extendedDebug.map((s) => '    $s')
    ].join('\n    ');

    packageWarningCounter.addWarning(warnable, kind, message, fullMessage);
  }

  Iterable<Package> get packages => packageMap.values;

  late final List<Package> publicPackages = () {
    assert(allLibrariesAdded);
    // Help the user if they pass us a package that doesn't exist.
    var packageNames = packages.map((p) => p.name).toSet();
    for (var packageName in config.packageOrder) {
      if (!packageNames.contains(packageName)) {
        warnOnElement(null, PackageWarning.packageOrderGivesMissingPackageName,
            message: "$packageName, packages: ${packageNames.join(',')}");
      }
    }
    return packages.where((p) => p.isPublic).toList(growable: false)..sort();
  }();

  /// Local packages are to be documented locally vs. remote or not at all.
  List<Package> get localPackages =>
      publicPackages.where((p) => p.isLocal).toList(growable: false);

  /// Documented packages are documented somewhere (local or remote).
  Iterable<Package> get _documentedPackages =>
      packages.where((p) => p.documentedWhere != DocumentLocation.missing);

  /// A mapping of all the [Library]s that export a given [LibraryElement].
  Map<LibraryElement, Set<Library>> _libraryExports = {};

  /// Prevent cycles from breaking our stack.
  Set<(Library, LibraryElement?)> _reexportsTagged = {};

  void _tagReexportsFor(
      final Library topLevelLibrary, final LibraryElement? libraryElement,
      [LibraryExportElement? lastExportedElement]) {
    var key = (topLevelLibrary, libraryElement);
    if (_reexportsTagged.contains(key)) {
      return;
    }
    _reexportsTagged.add(key);
    if (libraryElement == null) {
      lastExportedElement!;
      final lastExportedElementUri = lastExportedElement.uri;
      final uri = lastExportedElementUri is DirectiveUriWithRelativeUriString
          ? lastExportedElementUri.relativeUriString
          : null;
      warnOnElement(
          findButDoNotCreateLibraryFor(lastExportedElement.enclosingElement!),
          PackageWarning.unresolvedExport,
          message: '"$uri"',
          referredFrom: <Locatable>[topLevelLibrary]);
      return;
    }
    _libraryExports.putIfAbsent(libraryElement, () => {}).add(topLevelLibrary);
    for (var exportedElement in libraryElement.libraryExports) {
      _tagReexportsFor(
          topLevelLibrary, exportedElement.exportedLibrary, exportedElement);
    }
  }

  int _lastSizeOfAllLibraries = 0;

  Map<LibraryElement, Set<Library>> get libraryExports {
    // Table must be reset if we're still in the middle of adding libraries.
    if (allLibraries.keys.length != _lastSizeOfAllLibraries) {
      _lastSizeOfAllLibraries = allLibraries.keys.length;
      _libraryExports = {};
      _reexportsTagged = {};
      for (var library in publicLibraries) {
        _tagReexportsFor(library, library.element);
      }
    }
    return _libraryExports;
  }

  /// A lookup index for hrefs to allow warnings to indicate where a broken
  /// link or orphaned file may have come from.  Not cached because
  /// [ModelElement]s can be created at any time and we're basing this
  /// on more than just [allLocalModelElements] to make the error messages
  /// comprehensive.
  Map<String, Set<ModelElement>> get allHrefs {
    final hrefMap = <String, Set<ModelElement>>{};
    // TODO(jcollins-g ): handle calculating hrefs causing new elements better
    //                    than toList().
    for (final modelElement in allConstructedModelElements.values.toList()) {
      // Technically speaking we should be able to use canonical model elements
      // only here, but since the warnings that depend on this debug
      // canonicalization problems, don't limit ourselves in case an href is
      // generated for something non-canonical.
      if (modelElement is Dynamic) continue;
      // TODO: see [Accessor.enclosingCombo]
      if (modelElement is Accessor) continue;
      final href = modelElement.href;
      if (href == null) continue;

      hrefMap.putIfAbsent(href, () => {}).add(modelElement);
    }

    for (final library in allLibraries.values) {
      final href = library.href;
      if (href == null) continue;
      hrefMap.putIfAbsent(href, () => {}).add(library);
    }
    return hrefMap;
  }

  void _addToImplementors(Iterable<InheritingContainer> containers) {
    assert(!allImplementorsAdded);

    // Private containers may not be included in documentation, but may still be
    // necessary links in the implementation chain. They are added here as they
    // are found, then processed after [containers].
    var privates = <InheritingContainer>[];

    void checkAndAddContainer(
        InheritingContainer implemented, InheritingContainer implementor) {
      if (!implemented.isPublic) {
        privates.add(implemented);
      }
      implemented = implemented.canonicalModelElement as InheritingContainer? ??
          implemented;
      var list = _implementors.putIfAbsent(implemented, () => []);
      // TODO(srawlins): This would be more efficient if we created a
      // SplayTreeSet keyed off of `.element`.
      if (!list.any((l) => l.element == implementor.element)) {
        list.add(implementor);
      }
    }

    void addImplementor(InheritingContainer clazz) {
      var supertype = clazz.supertype;
      if (supertype != null) {
        checkAndAddContainer(
            supertype.modelElement as InheritingContainer, clazz);
      }
      if (clazz is Class) {
        for (var type in clazz.mixedInTypes) {
          checkAndAddContainer(type.modelElement as InheritingContainer, clazz);
        }
        for (var type in clazz.interfaces) {
          checkAndAddContainer(type.modelElement as InheritingContainer, clazz);
        }
      }
      for (var type in clazz.publicInterfaces) {
        checkAndAddContainer(type.modelElement as InheritingContainer, clazz);
      }
    }

    containers.forEach(addImplementor);

    // [privates] may grow while processing; use a for loop, rather than a
    // for-each loop, to avoid concurrent modification errors.
    for (var i = 0; i < privates.length; i++) {
      addImplementor(privates[i]);
    }
  }

  @visibleForTesting
  late final Iterable<Library> libraries =
      packages.expand((p) => p.libraries).toList(growable: false)..sort();

  int get libraryCount => libraries.length;

  late final Set<Library> publicLibraries = () {
    assert(allLibrariesAdded);
    return utils.filterNonPublic(libraries).toSet();
  }();

  late final List<Library> _localLibraries = () {
    assert(allLibrariesAdded);
    return localPackages.expand((p) => p.libraries).toList(growable: false)
      ..sort();
  }();

  late final Set<Library> localPublicLibraries = () {
    assert(allLibrariesAdded);
    return utils.filterNonPublic(_localLibraries).toSet();
  }();

  /// The String name representing the `Object` type.
  late final String dartCoreObject = libraries
          .firstWhereOrNull((library) => library.name == 'dart:core')
          ?.allClasses
          .firstWhereOrNull((c) => c.name == 'Object')
          ?.linkedName ??
      'Object';

  /// The set of [Class]es which should _not_ be presented as implementors.
  ///
  /// Add classes here if they are similar to Interceptor in that they are to be
  /// ignored even when they are the implementors of [Inheritable]s, and the
  /// class these inherit from should instead claim implementation.
  late final Set<Class> inheritThrough = () {
    var interceptorSpecialClass = specialClasses[SpecialClass.interceptor];
    if (interceptorSpecialClass == null) {
      return const <Class>{};
    }

    return {interceptorSpecialClass};
  }();

  /// The set of [Class] objects that are similar to 'pragma' in that we should
  /// never count them as documentable annotations.
  late final Set<Class> _invisibleAnnotations = () {
    var pragmaSpecialClass = specialClasses[SpecialClass.pragma];
    if (pragmaSpecialClass == null) {
      return const <Class>{};
    }
    return {pragmaSpecialClass};
  }();

  bool isAnnotationVisible(Class class_) =>
      !_invisibleAnnotations.contains(class_);

  @override
  String toString() {
    const divider = '=========================================================';
    final buffer = StringBuffer('PackageGraph built from ');
    buffer.writeln(defaultPackageName);
    buffer.writeln(divider);
    buffer.writeln();
    for (final name in packageMap.keys) {
      final package = packageMap[name]!;
      buffer.write('Package $name documented at ${package.documentedWhere} '
          'with libraries: ');
      buffer.writeAll(package.allLibraries);
      buffer.writeln();
    }
    buffer.writeln(divider);
    return buffer.toString();
  }

  final Map<Element, Library?> _canonicalLibraryFor = {};

  /// Tries to find a top level library that references this element.
  Library? _findCanonicalLibraryFor(Element e) {
    assert(allLibrariesAdded);
    if (_canonicalLibraryFor.containsKey(e)) {
      return _canonicalLibraryFor[e];
    }
    _canonicalLibraryFor[e] = null;

    var searchElement = switch (e) {
      PropertyAccessorElement() => e.variable,
      GenericFunctionTypeElement() => e.enclosingElement,
      _ => e,
    };
    if (searchElement == null) return null;
    for (var library in publicLibraries) {
      var modelElements = library.modelElementsMap[searchElement];
      if (modelElements != null) {
        if (modelElements.any((element) => element.isCanonical)) {
          return _canonicalLibraryFor[e] = library;
        }
      }
    }
    return _canonicalLibraryFor[e];
  }

  /// Tries to find a canonical [ModelElement] for this [e].  If we know this
  /// element is related to a particular class, pass a [preferredClass] to
  /// disambiguate.
  ///
  /// This doesn't know anything about [PackageGraph.inheritThrough] and
  /// probably shouldn't, so using it with [Inheritable]s without special casing
  /// is not advised.
  ModelElement? findCanonicalModelElementFor(Element? e,
      {Container? preferredClass}) {
    assert(allLibrariesAdded);
    if (e == null) return null;
    if (preferredClass != null) {
      var canonicalClass =
          findCanonicalModelElementFor(preferredClass.element) as Container?;
      if (canonicalClass != null) preferredClass = canonicalClass;
    }
    var lib = _findCanonicalLibraryFor(e);
    if (lib == null && preferredClass != null) {
      lib = _findCanonicalLibraryFor(preferredClass.element);
    }
    // For elements defined in extensions, they are canonical.
    var enclosingElement = e.enclosingElement;
    if (enclosingElement is ExtensionElement) {
      lib ??= modelBuilder.fromElement(enclosingElement.library) as Library?;
      // TODO(keertip): Find a better way to exclude members of extensions
      // when libraries are specified using the "--include" flag.
      if (lib != null && lib.isDocumented) {
        return modelBuilder.from(e, lib);
      }
    }
    // TODO(jcollins-g): The data structures should be changed to eliminate
    // guesswork with member elements.
    var declaration = e.declaration;
    ModelElement? modelElement;
    if (declaration != null &&
        (e is ClassMemberElement || e is PropertyAccessorElement)) {
      e = declaration;
      modelElement = _findCanonicalModelElementForAmbiguous(e, lib,
          preferredClass: preferredClass as InheritingContainer?);
    } else {
      if (lib != null) {
        if (e is PropertyInducingElement) {
          var getter =
              e.getter != null ? modelBuilder.from(e.getter!, lib) : null;
          var setter =
              e.setter != null ? modelBuilder.from(e.setter!, lib) : null;
          modelElement = modelBuilder.fromPropertyInducingElement(e, lib,
              getter: getter as Accessor?, setter: setter as Accessor?);
        } else {
          modelElement = modelBuilder.from(e, lib);
        }
      }
      assert(modelElement is! Inheritable);
      if (modelElement != null && !modelElement.isCanonical) {
        modelElement = null;
      }
    }
    // Prefer fields and top-level variables.
    if (e is PropertyAccessorElement && modelElement is Accessor) {
      modelElement = modelElement.enclosingCombo;
    }
    return modelElement;
  }

  ModelElement? _findCanonicalModelElementForAmbiguous(Element e, Library? lib,
      {InheritingContainer? preferredClass}) {
    var candidates = <ModelElement>{};
    if (lib != null) {
      var constructedWithKey = allConstructedModelElements[(e, lib, null)];
      if (constructedWithKey != null) {
        candidates.add(constructedWithKey);
      }
      var constructedWithKeyWithClass =
          allConstructedModelElements[(e, lib, preferredClass)];
      if (constructedWithKeyWithClass != null) {
        candidates.add(constructedWithKeyWithClass);
      }
      if (candidates.isEmpty) {
        candidates = {
          ...?allInheritableElements[(e, lib)]?.where((me) => me.isCanonical),
        };
      }
    }

    var canonicalClass = findCanonicalModelElementFor(e.enclosingElement);
    if (canonicalClass is InheritingContainer) {
      candidates.addAll(canonicalClass.allCanonicalModelElements
          .where((m) => m.element == e));
    }

    var matches = {...candidates.where((me) => me.isCanonical)};

    // It's possible to find [Accessor]s but no combos.  Be sure that if we
    // have accessors, we find their combos too.
    if (matches.any((me) => me is Accessor)) {
      var combos = matches
          .whereType<Accessor>()
          .map((a) => a.enclosingCombo)
          .toList(growable: false);
      matches.addAll(combos);
      assert(combos.every((c) => c.isCanonical));
    }

    // This is for situations where multiple classes may actually be canonical
    // for an inherited element whose defining Class is not canonical.
    if (matches.length > 1 && preferredClass != null) {
      // Search for matches inside our superchain.
      var superChain = [
        ...preferredClass.superChain.map((e) => e.modelElement),
        preferredClass,
      ];

      matches.removeWhere((me) => !superChain.contains(me.enclosingElement));
      // Assumed all matches are EnclosedElement because we've been told about a
      // preferredClass.
      var enclosingElements = {...matches.map((me) => me.enclosingElement)};
      for (var c in superChain.reversed) {
        if (enclosingElements.contains(c)) {
          matches.removeWhere((me) => me.enclosingElement != c);
        }
        if (matches.length <= 1) break;
      }
    }

    // Prefer a GetterSetterCombo to Accessors.
    if (matches.any((me) => me is GetterSetterCombo)) {
      matches.removeWhere((me) => me is Accessor);
    }

    assert(matches.length <= 1);
    if (matches.isNotEmpty) {
      return matches.first;
    }
    return null;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library? findButDoNotCreateLibraryFor(Element e) {
    // This is just a cache to avoid creating lots of libraries over and over.
    return allLibraries[e.library?.source.fullName];
  }

  /// Gathers all of the model elements found in all of the libraries of all
  /// of the packages.
  Iterable<ModelElement> _gatherModelElements() {
    assert(allLibrariesAdded);
    var allElements = <ModelElement>[];
    var completedPackages = <Package>{};
    var libraryCount = packages.fold(
        0, (previous, package) => previous + package.allLibraries.length);
    progressBarStart(libraryCount);
    for (var package in packages) {
      if (completedPackages.contains(package)) {
        continue;
      }
      var completedLibraries = <Library>{};
      for (var library in package.allLibraries) {
        progressBarTick();
        if (completedLibraries.contains(library)) {
          continue;
        }
        allElements.addAll(library.allModelElements);
        completedLibraries.add(library);
      }
      completedPackages.add(package);
    }
    progressBarComplete();

    return allElements;
  }

  late final Iterable<ModelElement> allLocalModelElements = [
    for (var library in _localLibraries) ...library.allModelElements
  ];

  /// Glob lookups can be expensive.  Cache per filename.
  final _configSetsNodocFor = HashMap<String, bool>();

  /// Given an element's location, look up the nodoc configuration data and
  /// determine whether to unconditionally treat the element as "nodoc".
  bool configSetsNodocFor(String fullName) {
    return _configSetsNodocFor.putIfAbsent(fullName, () {
      var file = resourceProvider.getFile(fullName);
      // Direct lookup instead of generating a custom context will save some
      // cycles.  We can't use the element's [DartdocOptionContext] because that
      // might not be where the element was defined, which is what's important
      // for nodoc's semantics.  Looking up the defining element just to pull
      // a context is again, slow.
      var globs = (config.optionSet['nodoc'].valueAt(file.parent) as List)
          .cast<String>();
      return utils.matchGlobs(globs, fullName);
    });
  }

  /// Returns a macro by [name], or `null` if no macro is found.
  String? getMacro(String name) {
    assert(_localDocumentationBuilt);
    return _macros[name];
  }

  void addMacro(String name, String content) {
    // TODO(srawlins): We have to add HTML fragments after documentation is
    // built, in order to include fragments which come from macros which
    // were generated by a tool. I think the macro/HTML-injection system needs
    // to be overhauled to allow for this type of looping.
    //assert(!_localDocumentationBuilt);
    _macros[name] = content;
  }

  String? getHtmlFragment(String? name) {
    assert(_localDocumentationBuilt);
    if (name == null) {
      return null;
    }
    return _htmlFragments[name];
  }

  void addHtmlFragment(String name, String content) {
    // TODO(srawlins): We have to add HTML fragments after documentation is
    // built, in order to include fragments which come from macros which
    // were generated by a tool. I think the macro/HTML-injection system needs
    // to be overhauled to allow for this type of looping.
    //assert(!_localDocumentationBuilt);
    _htmlFragments[name] = content;
  }

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    var children = <String, CommentReferable>{};
    // We have to use a stable order or otherwise references depending
    // on ambiguous resolution (see below) will change where they
    // resolve based on internal implementation details.
    var sortedPackages = packages.toList(growable: false)..sort(byName);
    var sortedDocumentedPackages = _documentedPackages.toList(growable: false)
      ..sort(byName);
    // Packages are the top priority.
    children.addEntries(sortedPackages.generateEntries());

    // Libraries are next.
    // TODO(jcollins-g): Warn about directly referencing libraries out of
    // scope?  Doing this is always going to be ambiguous and potentially
    // confusing.
    children.addEntriesIfAbsent(sortedDocumentedPackages
        .expand((p) => p.publicLibrariesSorted)
        .generateEntries());

    // TODO(jcollins-g): Warn about directly referencing top level items
    // out of scope?  Doing this will be even more ambiguous and
    // potentially confusing than doing so with libraries.
    children.addEntriesIfAbsent(sortedDocumentedPackages
        .expand((p) => p.publicLibrariesSorted)
        .expand((l) => [
              ...l.publicConstants,
              ...l.publicFunctions,
              ...l.publicProperties,
              ...l.publicTypedefs,
              ...l.publicExtensions,
              ...l.publicExtensionTypes,
              ...l.publicClasses,
              ...l.publicEnums,
              ...l.publicMixins
            ])
        .generateEntries());

    return children;
  }();

  @override
  Iterable<CommentReferable> get referenceParents => const [];
}
