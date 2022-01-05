// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart' hide CommentReference;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk, SdkLibrary;
// ignore: implementation_imports
import 'package:analyzer/src/generated/source.dart' show Source;
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
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';

class PackageGraph with CommentReferable, Nameable, ModelBuilder {
  PackageGraph.uninitialized(
    this.config,
    this.sdk,
    this.hasEmbedderSdk,
    this.rendererFactory,
    this.packageMetaProvider,
  ) : packageMeta = config.topLevelPackageMeta {
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

  /// Call during initialization to add a library to this [PackageGraph].
  ///
  /// Libraries added in this manner are assumed to be part of documented
  /// packages, even if includes or embedder.yaml files cause these to
  /// span packages.
  void addLibraryToGraph(DartDocResolvedLibrary resolvedLibrary) {
    assert(!allLibrariesAdded);
    var libraryElement = resolvedLibrary.element;
    var packageMeta =
        packageMetaProvider.fromElement(libraryElement, config.sdkDir);
    if (packageMeta == null) {
      throw DartdocFailure(packageMetaProvider.getMessageForMissingPackageMeta(
          libraryElement, config));
    }
    var lib = Library.fromLibraryResult(
        resolvedLibrary, this, Package.fromPackageMeta(packageMeta, this));
    packageMap[packageMeta.name]!.libraries.add(lib);
    allLibraries[libraryElement.source.fullName] = lib;
  }

  /// Call during initialization to add a library possibly containing
  /// special/non-documented elements to this [PackageGraph].  Must be called
  /// after any normal libraries.
  void addSpecialLibraryToGraph(DartDocResolvedLibrary resolvedLibrary) {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    findOrCreateLibraryFor(resolvedLibrary);
  }

  /// Call after all libraries are added.
  Future<void> initializePackageGraph() async {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    // From here on in, we might find special objects.  Initialize the
    // specialClasses handler so when we find them, they get added.
    specialClasses = SpecialClasses();
    // Go through docs of every ModelElement in package to pre-build the macros
    // index.
    await Future.wait(precacheLocalDocs());
    _localDocumentationBuilt = true;

    // Scan all model elements to insure that interceptor and other special
    // objects are found.
    // Emit warnings for any local package that has no libraries.
    // After the allModelElements traversal to be sure that all packages
    // are picked up.
    for (var package in documentedPackages) {
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
  Iterable<Future<void>> precacheLocalDocs() sync* {
    // Prevent reentrancy.
    var precachedElements = <ModelElement>{};

    Iterable<Future<void>> precacheOneElement(ModelElement m) sync* {
      for (var d
          in m.documentationFrom.where((d) => d.hasDocumentationComment)) {
        if (d.needsPrecache && !precachedElements.contains(d)) {
          precachedElements.add(d as ModelElement);
          yield d.precacheLocalDocs();
          logProgress(d.name);
          // TopLevelVariables get their documentation from getters and setters,
          // so should be precached if either has a template.
          if (m is TopLevelVariable && !precachedElements.contains(m)) {
            precachedElements.add(m);
            yield m.precacheLocalDocs();
            logProgress(d.name);
          }
        }
      }
    }

    for (var m in allModelElements) {
      // Skip if there is a canonicalModelElement somewhere else we can run this
      // for and we won't need a one line document that is precached.
      // Not the same as allCanonicalModelElements since we need to run
      // for any ModelElement that might not have a canonical ModelElement,
      // too.
      if (m.canonicalModelElement !=
                  null // A canonical element exists somewhere
              &&
              !m.isCanonical // This element is not canonical
              &&
              !m.enclosingElement!
                  .isCanonical // The enclosingElement won't need a oneLineDoc from this
          ) {
        continue;
      }
      yield* precacheOneElement(m);
    }
    // Now wait for any of the tasks still running to complete.
    yield config.tools.runner.wait();
  }

  // Many ModelElements have the same ModelNode; don't build/cache this data more
  // than once for them.
  final Map<Element, ModelNode> _modelNodes = {};

  void populateModelNodeFor(
      Element element, Map<String, CompilationUnit> compilationUnitMap) {
    _modelNodes.putIfAbsent(
        element,
        () => ModelNode(utils.getAstNode(element, compilationUnitMap), element,
            resourceProvider));
  }

  ModelNode? getModelNodeFor(Element? element) => _modelNodes[element!];

  late SpecialClasses specialClasses;

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

  late final Iterable<Extension> documentedExtensions =
      utils.filterNonDocumented(extensions).toList(growable: false);

  Iterable<Extension> get extensions {
    assert(allExtensionsAdded);
    return _extensions;
  }

  // All library objects related to this package; a superset of _libraries.
  // Keyed by [LibraryElement.Source.fullName] to resolve multiple URIs
  // referring to the same location to the same [Library].  This isn't how
  // Dart works internally, but Dartdoc pretends to avoid documenting or
  // duplicating data structures for the same "library" on disk based
  // on how it is referenced.  We can't use [Source] as a key since because
  // of differences in the [TimestampedData] timestamps.
  final allLibraries = <String, Library>{};

  /// All ModelElements constructed for this package; a superset of [allModelElements].
  final HashMap<Tuple3<Element, Library, Container?>, ModelElement?>
      allConstructedModelElements =
      HashMap<Tuple3<Element, Library, Container?>, ModelElement?>();

  /// Anything that might be inheritable, place here for later lookup.
  final allInheritableElements =
      HashMap<Tuple2<Element, Library>, Set<ModelElement>>();

  /// A mapping of the list of classes which implement each class.
  final _implementors =
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
  final Map<String, Package> packageMap = {};

  ResourceProvider get resourceProvider => config.resourceProvider;

  final DartSdk sdk;

  late final Map<Source?, SdkLibrary> sdkLibrarySources = {
    for (var lib in sdk.sdkLibraries) sdk.mapDartUri(lib.shortName): lib
  };

  final Map<String, String> _macros = {};
  final Map<String, String> _htmlFragments = {};
  bool allLibrariesAdded = false;
  bool _localDocumentationBuilt = false;

  /// Keep track of warnings.
  late final PackageWarningCounter packageWarningCounter =
      PackageWarningCounter(this);

  final Set<Tuple3<Element?, PackageWarning, String?>> _warnAlreadySeen = {};

  void warnOnElement(Warnable? warnable, PackageWarning kind,
      {String? message,
      Iterable<Locatable>? referredFrom,
      Iterable<String>? extendedDebug}) {
    var newEntry = Tuple3(warnable?.element, kind, message);
    if (_warnAlreadySeen.contains(newEntry)) {
      return;
    }
    // Warnings can cause other warnings.  Queue them up via the stack but
    // don't allow warnings we're already working on to get in there.
    _warnAlreadySeen.add(newEntry);
    _warnOnElement(warnable, kind,
        message: message ?? '',
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
    _warnAlreadySeen.remove(newEntry);
  }

  void _warnOnElement(Warnable? warnable, PackageWarning kind,
      {required String message,
      Iterable<Locatable>? referredFrom,
      Iterable<String>? extendedDebug}) {
    if (warnable != null) {
      // This sort of warning is only applicable to top level elements.
      if (kind == PackageWarning.ambiguousReexport) {
        var enclosingElement = warnable.enclosingElement;
        while (enclosingElement != null && enclosingElement is! Library) {
          warnable = enclosingElement;
          enclosingElement = warnable.enclosingElement;
        }
      }
    } else {
      // If we don't have an element, we need a message to disambiguate.
      assert(message.isNotEmpty);
    }
    if (packageWarningCounter.hasWarning(warnable, kind, message)) {
      return;
    }
    // Some kinds of warnings it is OK to drop if we're not documenting them.
    // TODO(jcollins-g): drop this and use new flag system instead.
    if (warnable != null &&
        skipWarningIfNotDocumentedFor.contains(kind) &&
        !warnable.isDocumented) {
      return;
    }
    // Elements that are part of the Dart SDK can have colons in their FQNs.
    // This confuses IntelliJ and makes it so it can't link to the location
    // of the error in the console window, so separate out the library from
    // the path.
    // TODO(jcollins-g): What about messages that may include colons?  Substituting
    //                   them out doesn't work as well there since it might confuse
    //                   the user, yet we still want IntelliJ to link properly.
    final warnableName = _safeWarnableName(warnable);

    var warnablePrefix = 'from';
    var referredFromPrefix = 'referred to by';
    String warningMessage;
    switch (kind) {
      case PackageWarning.noCanonicalFound:
        // Fix these warnings by adding libraries with --include, or by using
        // --auto-include-dependencies.
        // TODO(jcollins-g): pipeline references through linkedName for error
        //                   messages and warn for non-public canonicalization
        //                   errors.
        warningMessage =
            'no canonical library found for $warnableName, not linking';
        break;
      case PackageWarning.ambiguousReexport:
        // Fix these warnings by adding the original library exporting the
        // symbol with --include, by using --auto-include-dependencies,
        // or by using --exclude to hide one of the libraries involved
        warningMessage =
            'ambiguous reexport of $warnableName, canonicalization candidates: $message';
        break;
      case PackageWarning.noDefiningLibraryFound:
        warningMessage =
            'could not find the defining library for $warnableName; the '
            'library may be imported or exported with a non-standard URI';
        break;
      case PackageWarning.noLibraryLevelDocs:
        warningMessage =
            '${warnable!.fullyQualifiedName} has no library level documentation comments';
        break;
      case PackageWarning.noDocumentableLibrariesInPackage:
        warningMessage =
            '${warnable!.fullyQualifiedName} has no documentable libraries';
        break;
      case PackageWarning.ambiguousDocReference:
        warningMessage = 'ambiguous doc reference $message';
        break;
      case PackageWarning.ignoredCanonicalFor:
        warningMessage =
            "library says it is {@canonicalFor $message} but $message can't be canonical there";
        break;
      case PackageWarning.packageOrderGivesMissingPackageName:
        warningMessage =
            "--package-order gives invalid package name: '$message'";
        break;
      case PackageWarning.reexportedPrivateApiAcrossPackages:
        warningMessage =
            'private API of $message is reexported by libraries in other packages: ';
        break;
      case PackageWarning.notImplemented:
        warningMessage = message;
        break;
      case PackageWarning.unresolvedDocReference:
        warningMessage = 'unresolved doc reference [$message]';
        referredFromPrefix = 'in documentation inherited from';
        break;
      case PackageWarning.unknownDirective:
        warningMessage = 'undefined directive: $message';
        break;
      case PackageWarning.unknownMacro:
        warningMessage = 'undefined macro [$message]';
        break;
      case PackageWarning.unknownHtmlFragment:
        warningMessage = 'undefined HTML fragment identifier [$message]';
        break;
      case PackageWarning.brokenLink:
        warningMessage = 'dartdoc generated a broken link to: $message';
        warnablePrefix = 'to element';
        referredFromPrefix = 'linked to from';
        break;
      case PackageWarning.orphanedFile:
        warningMessage = 'dartdoc generated a file orphan: $message';
        break;
      case PackageWarning.unknownFile:
        warningMessage =
            'dartdoc detected an unknown file in the doc tree: $message';
        break;
      case PackageWarning.missingFromSearchIndex:
        warningMessage =
            'dartdoc generated a file not in the search index: $message';
        break;
      case PackageWarning.typeAsHtml:
        // The message for this warning can contain many punctuation and other symbols,
        // so bracket with a triple quote for defense.
        warningMessage = 'generic type handled as HTML: """$message"""';
        break;
      case PackageWarning.invalidParameter:
        warningMessage = 'invalid parameter to dartdoc directive: $message';
        break;
      case PackageWarning.toolError:
        warningMessage = 'tool execution failed: $message';
        break;
      case PackageWarning.deprecated:
        warningMessage = 'deprecated dartdoc usage: $message';
        break;
      case PackageWarning.unresolvedExport:
        warningMessage = 'unresolved export uri: $message';
        break;
      case PackageWarning.duplicateFile:
        warningMessage = 'failed to write file at: $message';
        warnablePrefix = 'for symbol';
        referredFromPrefix = 'conflicting with file already generated by';
        break;
      case PackageWarning.missingConstantConstructor:
        warningMessage = 'constant constructor missing: $message';
        break;
      case PackageWarning.missingExampleFile:
        warningMessage = 'example file not found: $message';
        break;
      case PackageWarning.missingCodeBlockLanguage:
        warningMessage = 'missing code block language: $message';
        break;
    }

    var messageParts = <String>[warningMessage];
    if (warnable != null) {
      messageParts.add('$warnablePrefix $warnableName: ${warnable.location}');
    }
    if (referredFrom != null) {
      for (var referral in referredFrom) {
        if (referral != warnable) {
          var referredFromStrings = _safeWarnableName(referral);
          messageParts.add(
              '$referredFromPrefix $referredFromStrings: ${referral.location}');
        }
      }
    }
    if (config.verboseWarnings && extendedDebug != null) {
      messageParts.addAll(extendedDebug.map((s) => '    $s'));
    }
    var fullMessage = messageParts.join('\n    ');

    packageWarningCounter.addWarning(warnable, kind, message, fullMessage);
  }

  String _safeWarnableName(Locatable? locatable) {
    if (locatable == null) {
      return '<unknown>';
    }

    return locatable.fullyQualifiedName.replaceFirst(':', '-');
  }

  List<Package> get packages => packageMap.values.toList();

  late final List<Package> publicPackages = () {
    assert(allLibrariesAdded);
    // Help the user if they pass us a package that doesn't exist.
    for (var packageName in config.packageOrder) {
      if (!packages.map((p) => p.name).contains(packageName)) {
        warnOnElement(null, PackageWarning.packageOrderGivesMissingPackageName,
            message:
                "$packageName, packages: ${packages.map((p) => p.name).join(',')}");
      }
    }
    return packages.where((p) => p.isPublic).toList()..sort();
  }();

  /// Local packages are to be documented locally vs. remote or not at all.
  List<Package> get localPackages =>
      publicPackages.where((p) => p.isLocal).toList();

  /// Documented packages are documented somewhere (local or remote).
  Iterable<Package> get documentedPackages =>
      packages.where((p) => p.documentedWhere != DocumentLocation.missing);

  Map<LibraryElement, Set<Library>> _libraryElementReexportedBy = {};

  /// Prevent cycles from breaking our stack.
  Set<Tuple2<Library, LibraryElement?>> _reexportsTagged = {};

  void _tagReexportsFor(
      final Library topLevelLibrary, final LibraryElement? libraryElement,
      [ExportElement? lastExportedElement]) {
    var key = Tuple2<Library, LibraryElement?>(topLevelLibrary, libraryElement);
    if (_reexportsTagged.contains(key)) {
      return;
    }
    _reexportsTagged.add(key);
    if (libraryElement == null) {
      // The first call to _tagReexportFor should not have a null libraryElement.
      assert(lastExportedElement != null);
      warnOnElement(
          findButDoNotCreateLibraryFor(lastExportedElement!.enclosingElement!),
          PackageWarning.unresolvedExport,
          message: '"${lastExportedElement.uri}"',
          referredFrom: <Locatable>[topLevelLibrary]);
      return;
    }
    _libraryElementReexportedBy
        .putIfAbsent(libraryElement, () => {})
        .add(topLevelLibrary);
    for (var exportedElement in libraryElement.exports) {
      _tagReexportsFor(
          topLevelLibrary, exportedElement.exportedLibrary, exportedElement);
    }
  }

  int _lastSizeOfAllLibraries = 0;

  Map<LibraryElement, Set<Library>> get libraryElementReexportedBy {
    // Table must be reset if we're still in the middle of adding libraries.
    if (allLibraries.keys.length != _lastSizeOfAllLibraries) {
      _lastSizeOfAllLibraries = allLibraries.keys.length;
      _libraryElementReexportedBy = <LibraryElement, Set<Library>>{};
      _reexportsTagged = {};
      for (var library in publicLibraries) {
        _tagReexportsFor(library, library.element);
      }
    }
    return _libraryElementReexportedBy;
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
      if (modelElement == null) continue;
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

  Iterable<Library> get libraries =>
      packages.expand((p) => p.libraries).toList()..sort();

  late final Iterable<Library> publicLibraries = () {
    assert(allLibrariesAdded);
    return utils.filterNonPublic(libraries).toList();
  }();

  late final Iterable<Library> localLibraries = () {
    assert(allLibrariesAdded);
    return localPackages.expand((p) => p.libraries).toList()..sort();
  }();

  late final Iterable<Library> localPublicLibraries = () {
    assert(allLibrariesAdded);
    return utils.filterNonPublic(localLibraries).toList();
  }();

  /// Return the set of [Class]es objects should inherit through if they
  /// show up in the inheritance chain.  Do not call before interceptorElement is
  /// found.  Add classes here if they are similar to Interceptor in that they
  /// are to be ignored even when they are the implementors of [Inheritable]s,
  /// and the class these inherit from should instead claim implementation.
  late final Set<Class> inheritThrough = () {
    var interceptorSpecialClass = specialClasses[SpecialClass.interceptor];
    if (interceptorSpecialClass == null) {
      return const <Class>{};
    }

    return {interceptorSpecialClass};
  }();

  /// The set of [Class] objects that are similar to pragma
  /// in that we should never count them as documentable annotations.
  late final Set<Class> invisibleAnnotations = () {
    var pragmaSpecialClass = specialClasses[SpecialClass.pragma];
    if (pragmaSpecialClass == null) {
      return const <Class>{};
    }
    return {pragmaSpecialClass};
  }();

  bool isAnnotationVisible(Class clazz) =>
      !invisibleAnnotations.contains(clazz);

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

  final Map<Element?, Library?> _canonicalLibraryFor = {};

  /// Tries to find a top level library that references this element.
  Library? findCanonicalLibraryFor(Element? e) {
    assert(allLibrariesAdded);
    var searchElement = e;
    if (e is PropertyAccessorElement) {
      searchElement = e.variable;
    }
    if (e is GenericFunctionTypeElement) {
      searchElement = e.enclosingElement;
    }

    if (_canonicalLibraryFor.containsKey(e)) {
      return _canonicalLibraryFor[e];
    }
    _canonicalLibraryFor[e] = null;
    for (var library in publicLibraries) {
      if (library.modelElementsMap.containsKey(searchElement)) {
        for (var modelElement in library.modelElementsMap[searchElement!]!) {
          if (modelElement.isCanonical) {
            return _canonicalLibraryFor[e] = library;
          }
        }
      }
    }
    return _canonicalLibraryFor[e];
  }

  /// Tries to find a canonical ModelElement for this element.  If we know
  /// this element is related to a particular class, pass preferredClass to
  /// disambiguate.
  ///
  /// This doesn't know anything about [PackageGraph.inheritThrough] and probably
  /// shouldn't, so using it with [Inheritable]s without special casing is
  /// not advised.
  ModelElement? findCanonicalModelElementFor(Element? e,
      {Container? preferredClass}) {
    assert(allLibrariesAdded);
    var lib = findCanonicalLibraryFor(e);
    if (preferredClass != null) {
      Container? canonicalClass =
          findCanonicalModelElementFor(preferredClass.element) as Container?;
      if (canonicalClass != null) preferredClass = canonicalClass;
    }
    if (lib == null && preferredClass != null) {
      lib = findCanonicalLibraryFor(preferredClass.element);
    }
    // For elements defined in extensions, they are canonical.
    var enclosingElement = e?.enclosingElement;
    if (enclosingElement is ExtensionElement) {
      lib ??= modelBuilder.fromElement(enclosingElement.library) as Library?;
      // (TODO:keertip) Find a better way to exclude members of extensions
      //  when libraries are specified using the "--include" flag
      if (lib?.isDocumented == true) {
        return modelBuilder.from(e!, lib!);
      }
    }
    ModelElement? modelElement;
    // TODO(jcollins-g): Special cases are pretty large here.  Refactor to split
    // out into helpers.
    // TODO(jcollins-g): The data structures should be changed to eliminate guesswork
    // with member elements.
    var declaration = e?.declaration;
    if (declaration != null &&
        (e is ClassMemberElement || e is PropertyAccessorElement)) {
      e = declaration;
      var candidates = <ModelElement>{};
      var iKey = Tuple2<Element, Library?>(e, lib);
      var key =
          Tuple4<Element, Library?, Class?, ModelElement?>(e, lib, null, null);
      var keyWithClass = Tuple4<Element, Library?, Class?, ModelElement?>(
          e, lib, preferredClass as Class?, null);
      var constructedWithKey = allConstructedModelElements[key];
      if (constructedWithKey != null) {
        candidates.add(constructedWithKey);
      }
      var constructedWithKeyWithClass =
          allConstructedModelElements[keyWithClass];
      if (constructedWithKeyWithClass != null) {
        candidates.add(constructedWithKeyWithClass);
      }
      if (candidates.isEmpty && allInheritableElements.containsKey(iKey)) {
        candidates.addAll(
            allInheritableElements[iKey as Tuple2<Element, Library>]!
                .where((me) => me.isCanonical));
      }
      Class? canonicalClass =
          findCanonicalModelElementFor(e.enclosingElement) as Class?;
      if (canonicalClass != null) {
        candidates.addAll(canonicalClass.allCanonicalModelElements.where((m) {
          return m.element == e;
        }));
      }
      var matches = <ModelElement>{...candidates.where((me) => me.isCanonical)};

      // It's possible to find accessors but no combos.  Be sure that if we
      // have Accessors, we find their combos too.
      if (matches.any((me) => me is Accessor)) {
        var combos =
            matches.whereType<Accessor>().map((a) => a.enclosingCombo).toList();
        matches.addAll(combos);
        assert(combos.every((c) => c.isCanonical));
      }

      // This is for situations where multiple classes may actually be canonical
      // for an inherited element whose defining Class is not canonical.
      if (matches.length > 1 && preferredClass != null) {
        // Search for matches inside our superchain.
        var superChain = preferredClass.superChain
            .map((et) => et.modelElement)
            .cast<Class>()
            .toList();
        superChain.add(preferredClass);
        matches.removeWhere((me) =>
            !superChain.contains((me as EnclosedElement).enclosingElement));
        // Assumed all matches are EnclosedElement because we've been told about a
        // preferredClass.
        var enclosingElements = {
          ...matches
              .map((me) => (me as EnclosedElement).enclosingElement as Class?)
        };
        for (var c in superChain.reversed) {
          if (enclosingElements.contains(c)) {
            matches.removeWhere(
                (me) => (me as EnclosedElement).enclosingElement != c);
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
        modelElement = matches.first;
      }
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
          modelElement = modelBuilder.from(e!, lib);
        }
      }
      assert(modelElement is! Inheritable);
      if (modelElement != null && !modelElement.isCanonical) {
        modelElement = null;
      }
    }
    // Prefer Fields.
    if (e is PropertyAccessorElement && modelElement is Accessor) {
      modelElement = modelElement.enclosingCombo;
    }
    return modelElement;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library? findButDoNotCreateLibraryFor(Element e) {
    // This is just a cache to avoid creating lots of libraries over and over.
    return allLibraries[e.library?.source.fullName];
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library findOrCreateLibraryFor(DartDocResolvedLibrary resolvedLibrary) {
    final libraryElement = resolvedLibrary.library;
    var foundLibrary = findButDoNotCreateLibraryFor(libraryElement);
    if (foundLibrary != null) return foundLibrary;

    foundLibrary = Library.fromLibraryResult(
        resolvedLibrary,
        this,
        Package.fromPackageMeta(
            packageMetaProvider.fromElement(libraryElement, config.sdkDir)!,
            packageGraph));
    allLibraries[libraryElement.source.fullName] = foundLibrary;
    return foundLibrary;
  }

  late final Iterable<ModelElement> allModelElements = () {
    assert(allLibrariesAdded);
    var allElements = <ModelElement>[];
    var packagesToDo = packages.toSet();
    var completedPackages = <Package>{};
    while (packagesToDo.length > completedPackages.length) {
      packagesToDo.difference(completedPackages).forEach((Package p) {
        var librariesToDo = p.allLibraries.toSet();
        var completedLibraries = <Library>{};
        while (librariesToDo.length > completedLibraries.length) {
          librariesToDo
              .difference(completedLibraries)
              .forEach((Library library) {
            allElements.addAll(library.allModelElements);
            completedLibraries.add(library);
          });
          librariesToDo.addAll(p.allLibraries);
        }
        completedPackages.add(p);
      });
      packagesToDo.addAll(packages);
    }

    return allElements;
  }();

  late final Iterable<ModelElement> allLocalModelElements = [
    for (var library in localLibraries) ...library.allModelElements
  ];

  late final Iterable<ModelElement> allCanonicalModelElements =
      allLocalModelElements.where((e) => e.isCanonical).toList();

  /// Glob lookups can be expensive.  Cache per filename.
  final _configSetsNodocFor = HashMap<String, bool>();

  /// Given an element's location, look up the nodoc configuration data and
  /// determine whether to unconditionally treat the element as "nodoc".
  bool configSetsNodocFor(String fullName) {
    var noDocForName = _configSetsNodocFor[fullName];
    if (noDocForName == null) {
      var file = resourceProvider.getFile(fullName);
      // Direct lookup instead of generating a custom context will save some
      // cycles.  We can't use the element's [DartdocOptionContext] because that
      // might not be where the element was defined, which is what's important
      // for nodoc's semantics.  Looking up the defining element just to pull
      // a context is again, slow.
      List<String> globs = config.optionSet['nodoc'].valueAt(file.parent2);
      noDocForName = utils.matchGlobs(globs, fullName);
      _configSetsNodocFor[fullName] = noDocForName;
    }
    return noDocForName;
  }

  String? getMacro(String? name) {
    assert(_localDocumentationBuilt);
    if (name == null) {
      return null;
    }
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
    var sortedPackages = packages.toList()..sort(byName);
    var sortedDocumentedPackages = documentedPackages.toList()..sort(byName);
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
              ...l.publicClasses,
              ...l.publicEnums,
              ...l.publicMixins
            ])
        .generateEntries());

    return children;
  }();

  @override
  Iterable<CommentReferable> get referenceParents => [];
}
