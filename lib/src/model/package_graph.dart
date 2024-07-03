// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/source/source.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/inheritance_manager3.dart'
    show InheritanceManager3;
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk, SdkLibrary;
// ignore: implementation_imports
import 'package:analyzer/src/generated/timestamped_data.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/package_meta.dart'
    show PackageMeta, PackageMetaProvider;
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/tool_definition.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';

class PackageGraph with CommentReferable, Nameable {
  /// Dartdoc's configuration flags.
  final DartdocOptionContext config;

  final bool hasEmbedderSdk;

  /// [PackageMeta] provider for building [PackageMeta]s.
  final PackageMetaProvider packageMetaProvider;

  final InheritanceManager3 inheritanceManager = InheritanceManager3();

  final AnalysisContext analysisContext;

  /// PackageMeta for the default package.
  final PackageMeta packageMeta;

  final Map<Source?, SdkLibrary> sdkLibrarySources;

  PackageGraph.uninitialized(
    this.config,
    DartSdk sdk,
    this.hasEmbedderSdk,
    this.packageMetaProvider,
    this.analysisContext,
  )   : packageMeta = config.topLevelPackageMeta,
        sdkLibrarySources = {
          for (var lib in sdk.sdkLibraries) sdk.mapDartUri(lib.shortName): lib
        } {
    // Make sure the default package exists, even if it has no libraries.
    // This can happen for packages that only contain embedder SDKs.
    Package.fromPackageMeta(packageMeta, this);
  }

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

  /// Adds [resolvedLibrary] to the package graph, adding it to [_allLibraries],
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
    _allLibraries[libraryElement.source.fullName] = lib;
  }

  /// Adds [resolvedLibrary] as a special library to the package graph, which
  /// adds the library to [_allLibraries], but does not add it to any [Package]'s
  /// list of libraries.
  ///
  /// Call during initialization to add a library possibly containing
  /// special/non-documented elements to this [PackageGraph].  Must be called
  /// after any normal libraries.
  void addSpecialLibraryToGraph(DartDocResolvedLibrary resolvedLibrary) {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    final libraryElement = resolvedLibrary.element.library;
    _allLibraries.putIfAbsent(
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
        _addToImplementers(library.classesAndExceptions);
        _addToImplementers(library.mixins);
        _addToImplementers(library.extensionTypes);
        _extensions.addAll(library.extensions);
      }
      if (package.isLocal && !package.hasPublicLibraries) {
        package.warn(PackageWarning.noDocumentableLibrariesInPackage);
      }
    }
    allImplementersAdded = true;
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
      for (var directive in unit.directives.whereType<LibraryDirective>()) {
        // There should be only one library directive. If there are more, there
        // is no harm in grabbing ModelNode for each.
        var commentData = directive.documentationComment?.data;
        _modelNodes.putIfAbsent(
            resolvedLibrary.element,
            () => ModelNode(
                  directive,
                  resolvedLibrary.element,
                  analysisContext,
                  commentData: commentData,
                ));
      }

      for (var declaration in unit.declarations) {
        _populateModelNodeFor(declaration);
        switch (declaration) {
          case ClassDeclaration():
            for (var member in declaration.members) {
              _populateModelNodeFor(member);
            }
          case EnumDeclaration():
            if (declaration.declaredElement?.isPublic ?? false) {
              for (var constant in declaration.constants) {
                _populateModelNodeFor(constant);
              }
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
    var commentData = declaration.documentationComment?.data;

    void addModelNode(Declaration declaration) {
      var element = declaration.declaredElement;
      if (element == null) {
        throw StateError("Expected '$declaration' to declare an element");
      }
      _modelNodes.putIfAbsent(
        element,
        () => ModelNode(
          declaration,
          element,
          analysisContext,
          commentData: commentData,
        ),
      );
    }

    if (declaration is FieldDeclaration) {
      var fields = declaration.fields.variables;
      for (var field in fields) {
        addModelNode(field);
      }
      return;
    }
    if (declaration is TopLevelVariableDeclaration) {
      var fields = declaration.variables.variables;
      for (var field in fields) {
        addModelNode(field);
      }
      return;
    }
    addModelNode(declaration);
  }

  ModelNode? getModelNodeFor(Element element) => _modelNodes[element];

  /// It is safe to cache values derived from the [_implementers] table if this
  /// is true.
  bool allImplementersAdded = false;

  /// It is safe to cache values derived from the [_extensions] table if this
  /// is true.
  bool allExtensionsAdded = false;

  Map<InheritingContainer, List<InheritingContainer>> get implementers {
    assert(allImplementersAdded);
    return _implementers;
  }

  Iterable<Extension> get extensions {
    assert(allExtensionsAdded);
    return _extensions;
  }

  /// All library objects related to this package graph; a superset of
  /// [libraries].
  ///
  /// Keyed by `LibraryElement.source.fullName` to resolve different URIs
  /// referring to the same location, to the same [Library].  This isn't how Dart
  /// works internally, but Dartdoc pretends to avoid documenting or duplicating
  /// data structures for the same "library" on disk based on how it is
  /// referenced.  We can't use [Source] as a key due to differences in the
  /// [TimestampedData] timestamps.
  ///
  /// This mapping must be complete before [initializePackageGraph] is called.
  final Map<String, Library> _allLibraries = {};

  /// All [ModelElement]s constructed for this package; a superset of
  /// the elements gathered in [_gatherModelElements].
  final Map<ConstructedModelElementsKey, ModelElement>
      allConstructedModelElements = {};

  /// Anything that might be inheritable, place here for later lookup.
  final Map<InheritableElementsKey, Set<ModelElement>> allInheritableElements =
      {};

  /// A mapping of the list of classes, enums, mixins, and extension types which
  /// "implement" each class, mixin, and extension type.
  ///
  /// For the purposes of the "Implementers" section in the output, this
  /// includes elements that "implement" or "extend" another element.
  final Map<InheritingContainer, List<InheritingContainer>> _implementers =
      LinkedHashMap<InheritingContainer, List<InheritingContainer>>(
          equals: (InheritingContainer a, InheritingContainer b) =>
              a.definingContainer == b.definingContainer,
          hashCode: (InheritingContainer clazz) =>
              clazz.definingContainer.hashCode);

  /// A list of extensions that exist in the package graph.
  final List<Extension> _extensions = [];

  /// Name of the default package.
  String get defaultPackageName => packageMeta.name;

  late final Package defaultPackage =
      Package.fromPackageMeta(packageMeta, this);

  bool get hasFooterVersion => !config.excludeFooterVersion;

  @override
  PackageGraph get packageGraph => this;

  /// Map of package name to [Package].
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

  /// A mapping from a [LibraryElement] to all of the [Library]s that export it.
  Map<LibraryElement, Set<Library>> _libraryExports = {};

  /// Marks [publicLibrary] as a library that exports [libraryElement] and all
  /// libraries that [libraryElement] transitively exports.
  ///
  /// [alreadyTagged] is used internall to prevent visiting in cycles.
  void _tagExportsFor(
    final Library publicLibrary,
    final LibraryElement libraryElement, {
    Set<(Library, LibraryElement)>? alreadyTagged,
  }) {
    alreadyTagged ??= {};
    var key = (publicLibrary, libraryElement);
    if (alreadyTagged.contains(key)) {
      return;
    }
    alreadyTagged.add(key);
    // Mark that `publicLibrary` exports `libraryElement`.
    _libraryExports.putIfAbsent(libraryElement, () => {}).add(publicLibrary);
    for (var exportedElement in libraryElement.libraryExports) {
      var exportedLibrary = exportedElement.exportedLibrary;
      if (exportedLibrary != null) {
        // Follow the exports down; as `publicLibrary` exports `libraryElement`,
        // it also exports each `exportedLibrary`.
        _tagExportsFor(publicLibrary, exportedLibrary,
            alreadyTagged: alreadyTagged);
      }
    }
  }

  int _lastSizeOfAllLibraries = 0;

  /// A mapping from a [LibraryElement] to all of the [Library]s that export it,
  /// which is created if it is not yet populated.
  Map<LibraryElement, Set<Library>> get libraryExports {
    // Table must be reset if we're still in the middle of adding libraries.
    if (_allLibraries.keys.length != _lastSizeOfAllLibraries) {
      _lastSizeOfAllLibraries = _allLibraries.keys.length;
      _libraryExports = {};
      for (var library in publicLibraries) {
        _tagExportsFor(library, library.element);
      }
    }
    return _libraryExports;
  }

  /// A lookup index for hrefs to allow warnings to indicate where a broken
  /// link or orphaned file may have come from.
  ///
  /// This is not cached because [ModelElement]s can be created at any time.
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

    for (final library in _allLibraries.values) {
      final href = library.href;
      if (href == null) continue;
      hrefMap.putIfAbsent(href, () => {}).add(library);
    }
    return hrefMap;
  }

  void _addToImplementers(Iterable<InheritingContainer> containers) {
    assert(!allImplementersAdded);

    // Private containers may not be included in documentation, but may still be
    // necessary links in the implementation chain. They are added here as they
    // are found, then processed after [containers].
    var privates = <InheritingContainer>[];

    void checkAndAddContainer(
        InheritingContainer implemented, InheritingContainer implementer) {
      if (!implemented.isPublic) {
        privates.add(implemented);
      }
      implemented = implemented.canonicalModelElement as InheritingContainer? ??
          implemented;
      var list = _implementers.putIfAbsent(implemented, () => []);
      // TODO(srawlins): This would be more efficient if we created a
      // SplayTreeSet keyed off of `.element`.
      if (!list.any((l) => l.element == implementer.element)) {
        list.add(implementer);
      }
    }

    void addImplementer(InheritingContainer container) {
      var supertype = container.supertype;
      if (supertype != null) {
        checkAndAddContainer(
            supertype.modelElement as InheritingContainer, container);
      }
      if (container is Class) {
        for (var element in container.mixedInElements) {
          checkAndAddContainer(element, container);
        }
        for (var element in container.interfaceElements) {
          checkAndAddContainer(element, container);
        }
      } else if (container is ExtensionType) {
        for (var element in container.interfaceElements) {
          checkAndAddContainer(element, container);
        }
      }
      for (var element in container.publicInterfaceElements) {
        checkAndAddContainer(element, container);
      }
    }

    containers.forEach(addImplementer);

    // [privates] may grow while processing; use a for loop, rather than a
    // for-each loop, to avoid concurrent modification errors.
    for (var i = 0; i < privates.length; i++) {
      addImplementer(privates[i]);
    }
  }

  @visibleForTesting

  /// The set of all libraries (public and implementation) found across all
  /// [packages].
  late final List<Library> libraries =
      packages.expand((p) => p.libraries).toList(growable: false)..sort();

  int get libraryCount => libraries.length;

  /// The set of public libraries found across all [packages].
  late final Set<Library> publicLibraries = () {
    assert(allLibrariesAdded);
    return libraries.wherePublic.toSet();
  }();

  late final List<Library> _localLibraries = () {
    assert(allLibrariesAdded);
    return localPackages.expand((p) => p.libraries).toList(growable: false)
      ..sort();
  }();

  late final Set<Library> localPublicLibraries = () {
    assert(allLibrariesAdded);
    return _localLibraries.wherePublic.toSet();
  }();

  /// The String name representing the `Object` type.
  late final String dartCoreObject = libraries
          .firstWhereOrNull((library) => library.name == 'dart:core')
          ?.classes
          .firstWhereOrNull((c) => c.name == 'Object')
          ?.linkedName ??
      'Object';

  /// The set of [Class]es which should _not_ be presented as implementers.
  ///
  /// Add classes here if they are similar to Interceptor in that they are to be
  /// ignored even when they are the implementers of [Inheritable]s, and the
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

  /// Tries to find a canonical [ModelElement] for this [modelElement].  If we
  /// know this element is related to a particular class, pass a
  /// [preferredClass] to disambiguate.
  ///
  /// This doesn't know anything about [PackageGraph.inheritThrough] and
  /// probably shouldn't, so using it with [Inheritable]s without special casing
  /// is not advised.
  ///
  /// This can return `null` in a few ways: if [modelElement] is `null`, or if
  /// it has no canonical library, or if a possible canonical model element has
  /// a `false` value for `isCanonical`.
  ModelElement? findCanonicalModelElementFor(ModelElement? modelElement,
      {Container? preferredClass}) {
    assert(allLibrariesAdded);
    if (modelElement == null) return null;
    var element = modelElement.element;
    if (preferredClass != null) {
      var canonicalClass =
          findCanonicalModelElementFor(preferredClass) as Container?;
      if (canonicalClass != null) preferredClass = canonicalClass;
    }
    var lib = modelElement.canonicalLibrary;
    if (lib == null && preferredClass != null) {
      lib = preferredClass.canonicalLibrary;
    }
    // For elements defined in extensions, they are canonical.
    var enclosingElement = element.enclosingElement;
    if (enclosingElement is ExtensionElement) {
      lib ??= getModelForElement(enclosingElement.library) as Library?;
      // TODO(keertip): Find a better way to exclude members of extensions
      // when libraries are specified using the "--include" flag.
      if (lib != null && lib.isDocumented) {
        return getModelFor(element, lib);
      }
    }
    // TODO(jcollins-g): The data structures should be changed to eliminate
    // guesswork with member elements.
    var declaration = element.declaration;
    ModelElement? canonicalModelElement;
    if (declaration != null &&
        (element is ClassMemberElement || element is PropertyAccessorElement)) {
      modelElement = getModelForElement(declaration);
      element = modelElement.element;
      canonicalModelElement = _findCanonicalModelElementForAmbiguous(
          modelElement, lib,
          preferredClass: preferredClass as InheritingContainer?);
    } else {
      if (lib != null) {
        if (element case PropertyInducingElement(:var getter, :var setter)) {
          var getterElement =
              getter == null ? null : getModelFor(getter, lib) as Accessor;
          var setterElement =
              setter == null ? null : getModelFor(setter, lib) as Accessor;
          canonicalModelElement = getModelForPropertyInducingElement(
              element, lib,
              getter: getterElement, setter: setterElement);
        } else {
          canonicalModelElement = getModelFor(element, lib);
        }
      }
      assert(canonicalModelElement is! Inheritable);
      if (canonicalModelElement != null && !canonicalModelElement.isCanonical) {
        canonicalModelElement = null;
      }
    }
    // Prefer fields and top-level variables.
    if (element is PropertyAccessorElement &&
        canonicalModelElement is Accessor) {
      canonicalModelElement = canonicalModelElement.enclosingCombo;
    }
    return canonicalModelElement;
  }

  ModelElement? _findCanonicalModelElementForAmbiguous(
      ModelElement modelElement, Library? lib,
      {InheritingContainer? preferredClass}) {
    var element = modelElement.element;
    var candidates = <ModelElement>{};
    if (lib != null) {
      var constructedWithKey = allConstructedModelElements[
          ConstructedModelElementsKey(element, lib, null)];
      if (constructedWithKey != null) {
        candidates.add(constructedWithKey);
      }
      var constructedWithKeyWithClass = allConstructedModelElements[
          ConstructedModelElementsKey(element, lib, preferredClass)];
      if (constructedWithKeyWithClass != null) {
        candidates.add(constructedWithKeyWithClass);
      }
      if (candidates.isEmpty) {
        candidates = {
          ...?allInheritableElements[InheritableElementsKey(element, lib)]
              ?.where((me) => me.isCanonical),
        };
      }
    }

    var canonicalClass =
        findCanonicalModelElementFor(modelElement.enclosingElement);
    if (canonicalClass is InheritingContainer) {
      candidates.addAll(canonicalClass.allCanonicalModelElements
          .where((m) => m.element == element));
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
    return _allLibraries[e.library?.source.fullName];
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

  /// Cache of 'nodoc' configurations.
  ///
  /// Glob lookups can be expensive, so cache per filename.
  final _configSetsNodocFor = HashMap<String, bool>();

  /// Given an element's [fullName], look up the nodoc configuration data and
  /// determine whether to unconditionally treat the element as "nodoc", an
  /// attribute indicating that documentation should not be included in
  /// dartdoc's generated output.
  ///
  /// This configuration setting is deprecated.
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
      if (globs.isNotEmpty) {
        packageGraph.defaultPackage.warn(
          PackageWarning.deprecated,
          message:
              "The '--nodoc' option is deprecated, and will soon be removed.",
        );
      }
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
    // We have to use a stable order or otherwise references depending on
    // ambiguous resolution (see below) will change where they resolve based on
    // internal implementation details.
    var sortedPackages = packages.toList(growable: false)..sort(byName);
    var sortedDocumentedPackages = _documentedPackages.toList(growable: false)
      ..sort(byName);
    return {
      // TODO(jcollins-g): Warn about directly referencing top level items out
      // of scope?  Doing this will be even more ambiguous and potentially
      // confusing than doing so with libraries.
      ...sortedDocumentedPackages
          .expand((p) => p.publicLibrariesSorted)
          .expand((l) => [
                ...l.constants.wherePublic,
                ...l.functions.wherePublic,
                ...l.properties.wherePublic,
                ...l.typedefs.wherePublic,
                ...l.extensions.wherePublic,
                ...l.extensionTypes.wherePublic,
                ...l.classes.wherePublic,
                ...l.enums.wherePublic,
                ...l.mixins.wherePublic,
              ])
          .asMapByName,

      // Libraries are next.
      // TODO(jcollins-g): Warn about directly referencing libraries out of
      // scope?  Doing this is always going to be ambiguous and potentially
      // confusing.
      ...sortedDocumentedPackages
          .expand((p) => p.publicLibrariesSorted)
          .asMapByName,

      // Packages are the top priority.
      ...sortedPackages.asMapByName,
    };
  }();

  @override
  Iterable<CommentReferable> get referenceParents => const [];
}

class ConstructedModelElementsKey {
  final Element element;
  final Library library;
  final Container? enclosingElement;

  ConstructedModelElementsKey(
      this.element, this.library, this.enclosingElement);

  @override
  late final int hashCode = Object.hash(element, library, enclosingElement);

  @override
  bool operator ==(Object other) {
    if (other is! ConstructedModelElementsKey) return false;
    return other.element == element &&
        other.library == library &&
        other.enclosingElement == enclosingElement;
  }
}

class InheritableElementsKey {
  final Element element;
  final Library library;

  InheritableElementsKey(this.element, this.library);
}

extension on Comment {
  /// A mapping of all comment references to their various data.
  CommentData get data {
    var docImportsData = <CommentDocImportData>[];
    for (var docImport in docImports) {
      docImportsData.add(
        CommentDocImportData(
            offset: docImport.offset, end: docImport.import.end),
      );
    }

    var referencesData = <String, CommentReferenceData>{};
    for (var reference in references) {
      var commentReferable = reference.expression;
      String name;
      Element? staticElement;
      if (commentReferable case PropertyAccessImpl(:var propertyName)) {
        var target = commentReferable.target;
        if (target is! PrefixedIdentifierImpl) continue;
        name = '${target.name}.${propertyName.name}';
        staticElement = propertyName.staticElement;
      } else if (commentReferable case PrefixedIdentifier(:var identifier)) {
        name = commentReferable.name;
        staticElement = identifier.staticElement;
      } else if (commentReferable case SimpleIdentifier()) {
        name = commentReferable.name;
        staticElement = commentReferable.staticElement;
      } else {
        continue;
      }

      if (staticElement != null && !referencesData.containsKey(name)) {
        referencesData[name] = CommentReferenceData(
          staticElement,
          name,
          commentReferable.offset,
          commentReferable.length,
        );
      }
    }
    return CommentData(
        offset: offset, docImports: docImportsData, references: referencesData);
  }
}
