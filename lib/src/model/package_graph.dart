// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/package_meta.dart' show PackageMeta;
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';

class PackageGraph {
  PackageGraph.UninitializedPackageGraph(this.config, this.driver, this.sdk,
      this.hasEmbedderSdk, this.rendererFactory)
      : packageMeta = config.topLevelPackageMeta,
        session = driver.currentSession {
    _packageWarningCounter = PackageWarningCounter(this);
    // Make sure the default package exists, even if it has no libraries.
    // This can happen for packages that only contain embedder SDKs.
    Package.fromPackageMeta(packageMeta, this);
  }

  /// Call during initialization to add a library to this [PackageGraph].
  ///
  /// Libraries added in this manner are assumed to be part of documented
  /// packages, even if includes or embedder.yaml files cause these to
  /// span packages.
  void addLibraryToGraph(ResolvedLibraryResult result) {
    assert(!allLibrariesAdded);
    var element = result.element;
    var packageMeta = PackageMeta.fromElement(element, config.sdkDir);
    var lib = Library.fromLibraryResult(
        result, this, Package.fromPackageMeta(packageMeta, this));
    packageMap[packageMeta.name].libraries.add(lib);
    allLibraries[element] = lib;
  }

  /// Call during initialization to add a library possibly containing
  /// special/non-documented elements to this [PackageGraph].  Must be called
  /// after any normal libraries.
  void addSpecialLibraryToGraph(ResolvedLibraryResult result) {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    findOrCreateLibraryFor(result);
  }

  /// Call after all libraries are added.
  Future<void> initializePackageGraph() async {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    // From here on in, we might find special objects.  Initialize the
    // specialClasses handler so when we find them, they get added.
    specialClasses = SpecialClasses();
    // Go through docs of every ModelElement in package to pre-build the macros
    // index.  Uses toList() in order to get all the precaching on the stack.
    var precacheFutures = precacheLocalDocs().toList();
    for (var f in precacheFutures) {
      await f;
    }
    _localDocumentationBuilt = true;

    // Scan all model elements to insure that interceptor and other special
    // objects are found.
    // After the allModelElements traversal to be sure that all packages
    // are picked up.
    documentedPackages.toList().forEach((package) {
      package.libraries.sort((a, b) => compareNatural(a.name, b.name));
      package.libraries.forEach((library) {
        library.allClasses.forEach(_addToImplementors);
        _extensions.addAll(library.extensions);
      });
    });
    _implementors.values.forEach((l) => l.sort());
    allImplementorsAdded = true;
    allExtensionsAdded = true;

    // We should have found all special classes by now.
    specialClasses.assertSpecials();
  }

  /// Generate a list of futures for any docs that actually require precaching.
  Iterable<Future> precacheLocalDocs() sync* {
    // Prevent reentrancy.
    var precachedElements = <ModelElement>{};

    Iterable<Future> precacheOneElement(ModelElement m) sync* {
      for (var d
          in m.documentationFrom.where((d) => d.documentationComment != null)) {
        if (needsPrecacheRegExp.hasMatch(d.documentationComment) &&
            !precachedElements.contains(d)) {
          precachedElements.add(d);
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
      // for.  Not the same as allCanonicalModelElements since we need to run
      // for any ModelElement that might not have a canonical ModelElement,
      // too.
      if (m.canonicalModelElement != null && !m.isCanonical) continue;
      yield* precacheOneElement(m);
    }
  }

  // Many ModelElements have the same ModelNode; don't build/cache this data more
  // than once for them.
  final Map<Element, ModelNode> _modelNodes = {};

  void populateModelNodeFor(
      Element element, Map<String, CompilationUnit> compilationUnitMap) {
    _modelNodes.putIfAbsent(
        element,
        () =>
            ModelNode(utils.getAstNode(element, compilationUnitMap), element));
  }

  ModelNode getModelNodeFor(Element element) => _modelNodes[element];

  SpecialClasses specialClasses;

  /// It is safe to cache values derived from the [_implementors] table if this
  /// is true.
  bool allImplementorsAdded = false;

  /// It is safe to cache values derived from the [_extensions] table if this
  /// is true.
  bool allExtensionsAdded = false;

  Map<String, List<Class>> get implementors {
    assert(allImplementorsAdded);
    return _implementors;
  }

  List<Extension> _documentedExtensions;
  Iterable<Extension> get documentedExtensions {
    _documentedExtensions ??=
        utils.filterNonDocumented(extensions).toList(growable: false);
    return _documentedExtensions;
  }

  Iterable<Extension> get extensions {
    assert(allExtensionsAdded);
    return _extensions;
  }

  Map<String, Set<ModelElement>> _findRefElementCache;
  Map<String, Set<ModelElement>> get findRefElementCache {
    if (_findRefElementCache == null) {
      assert(packageGraph.allLibrariesAdded);
      _findRefElementCache = {};
      for (final modelElement
          in utils.filterNonDocumented(packageGraph.allLocalModelElements)) {
        _findRefElementCache.putIfAbsent(
            modelElement.fullyQualifiedNameWithoutLibrary, () => {});
        _findRefElementCache.putIfAbsent(
            modelElement.fullyQualifiedName, () => {});
        _findRefElementCache[modelElement.fullyQualifiedName].add(modelElement);
        _findRefElementCache[modelElement.fullyQualifiedNameWithoutLibrary]
            .add(modelElement);
      }
    }
    return _findRefElementCache;
  }

  // All library objects related to this package; a superset of _libraries.
  final Map<LibraryElement, Library> allLibraries = {};

  /// Keep track of warnings
  PackageWarningCounter _packageWarningCounter;

  /// All ModelElements constructed for this package; a superset of [allModelElements].
  final Map<Tuple3<Element, Library, Container>, ModelElement>
      allConstructedModelElements = {};

  /// Anything that might be inheritable, place here for later lookup.
  final Map<Tuple2<Element, Library>, Set<ModelElement>>
      allInheritableElements = {};

  /// Map of Class.href to a list of classes implementing that class
  final Map<String, List<Class>> _implementors = {};

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

  Package _defaultPackage;

  Package get defaultPackage {
    _defaultPackage ??= Package.fromPackageMeta(packageMeta, this);
    return _defaultPackage;
  }

  final bool hasEmbedderSdk;

  bool get hasFooterVersion => !config.excludeFooterVersion;

  PackageGraph get packageGraph => this;

  /// Map of package name to Package.
  final Map<String, Package> packageMap = {};

  /// TODO(brianwilkerson) Replace the driver with the session.
  final AnalysisDriver driver;
  final AnalysisSession session;
  final DartSdk sdk;

  Map<Source, SdkLibrary> _sdkLibrarySources;

  Map<Source, SdkLibrary> get sdkLibrarySources {
    if (_sdkLibrarySources == null) {
      _sdkLibrarySources = {};
      for (var lib in sdk?.sdkLibraries) {
        _sdkLibrarySources[sdk.mapDartUri(lib.shortName)] = lib;
      }
    }
    return _sdkLibrarySources;
  }

  final Map<String, String> _macros = {};
  final Map<String, String> _htmlFragments = {};
  bool allLibrariesAdded = false;
  bool _localDocumentationBuilt = false;

  /// Returns true if there's at least one library documented in the package
  /// that has the same package path as the library for the given element.
  /// Usable as a cross-check for dartdoc's canonicalization to generate
  /// warnings for ModelElement.isPublicAndPackageDocumented.
  Set<String> _allRootDirs;

  bool packageDocumentedFor(ModelElement element) {
    _allRootDirs ??= {
      ...(publicLibraries.map((l) => l.packageMeta?.resolvedDir))
    };
    return (_allRootDirs.contains(element.library.packageMeta?.resolvedDir));
  }

  PackageWarningCounter get packageWarningCounter => _packageWarningCounter;

  final Set<Tuple3<Element, PackageWarning, String>> _warnAlreadySeen = {};

  void warnOnElement(Warnable warnable, PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    var newEntry = Tuple3(warnable?.element, kind, message);
    if (_warnAlreadySeen.contains(newEntry)) {
      return;
    }
    // Warnings can cause other warnings.  Queue them up via the stack but
    // don't allow warnings we're already working on to get in there.
    _warnAlreadySeen.add(newEntry);
    _warnOnElement(warnable, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
    _warnAlreadySeen.remove(newEntry);
  }

  void _warnOnElement(Warnable warnable, PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    if (warnable != null) {
      // This sort of warning is only applicable to top level elements.
      if (kind == PackageWarning.ambiguousReexport) {
        while (warnable.enclosingElement is! Library &&
            warnable.enclosingElement != null) {
          warnable = warnable.enclosingElement;
        }
      }
    } else {
      // If we don't have an element, we need a message to disambiguate.
      assert(message != null);
    }
    if (_packageWarningCounter.hasWarning(warnable, kind, message)) {
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
            'no canonical library found for ${warnableName}, not linking';
        break;
      case PackageWarning.ambiguousReexport:
        // Fix these warnings by adding the original library exporting the
        // symbol with --include, by using --auto-include-dependencies,
        // or by using --exclude to hide one of the libraries involved
        warningMessage =
            'ambiguous reexport of ${warnableName}, canonicalization candidates: ${message}';
        break;
      case PackageWarning.noLibraryLevelDocs:
        warningMessage =
            '${warnable.fullyQualifiedName} has no library level documentation comments';
        break;
      case PackageWarning.ambiguousDocReference:
        warningMessage = 'ambiguous doc reference ${message}';
        break;
      case PackageWarning.ignoredCanonicalFor:
        warningMessage =
            "library says it is {@canonicalFor ${message}} but ${message} can't be canonical there";
        break;
      case PackageWarning.packageOrderGivesMissingPackageName:
        warningMessage =
            "--package-order gives invalid package name: '${message}'";
        break;
      case PackageWarning.reexportedPrivateApiAcrossPackages:
        warningMessage =
            'private API of ${message} is reexported by libraries in other packages: ';
        break;
      case PackageWarning.notImplemented:
        warningMessage = message;
        break;
      case PackageWarning.unresolvedDocReference:
        warningMessage = 'unresolved doc reference [${message}]';
        referredFromPrefix = 'in documentation inherited from';
        break;
      case PackageWarning.unknownMacro:
        warningMessage = 'undefined macro [${message}]';
        break;
      case PackageWarning.unknownHtmlFragment:
        warningMessage = 'undefined HTML fragment identifier [${message}]';
        break;
      case PackageWarning.brokenLink:
        warningMessage = 'dartdoc generated a broken link to: ${message}';
        warnablePrefix = 'to element';
        referredFromPrefix = 'linked to from';
        break;
      case PackageWarning.orphanedFile:
        warningMessage = 'dartdoc generated a file orphan: ${message}';
        break;
      case PackageWarning.unknownFile:
        warningMessage =
            'dartdoc detected an unknown file in the doc tree: ${message}';
        break;
      case PackageWarning.missingFromSearchIndex:
        warningMessage =
            'dartdoc generated a file not in the search index: ${message}';
        break;
      case PackageWarning.typeAsHtml:
        // The message for this warning can contain many punctuation and other symbols,
        // so bracket with a triple quote for defense.
        warningMessage = 'generic type handled as HTML: """${message}"""';
        break;
      case PackageWarning.invalidParameter:
        warningMessage = 'invalid parameter to dartdoc directive: ${message}';
        break;
      case PackageWarning.toolError:
        warningMessage = 'tool execution failed: ${message}';
        break;
      case PackageWarning.deprecated:
        warningMessage = 'deprecated dartdoc usage: ${message}';
        break;
      case PackageWarning.unresolvedExport:
        warningMessage = 'unresolved export uri: ${message}';
        break;
      case PackageWarning.duplicateFile:
        warningMessage = 'failed to write file at: ${message}';
        warnablePrefix = 'for symbol';
        referredFromPrefix = 'conflicting with file already generated by';
        break;
      case PackageWarning.missingConstantConstructor:
        warningMessage = 'constant constructor missing: ${message}';
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
    String fullMessage;
    if (messageParts.length <= 2) {
      fullMessage = messageParts.join(', ');
    } else {
      fullMessage = messageParts.join('\n    ');
    }

    packageWarningCounter.addWarning(warnable, kind, message, fullMessage);
  }

  String _safeWarnableName(Locatable locatable) {
    if (locatable == null) {
      return '<unknown>';
    }

    return locatable.fullyQualifiedName.replaceFirst(':', '-');
  }

  List<Package> get packages => packageMap.values.toList();

  List<Package> _publicPackages;

  List<Package> get publicPackages {
    if (_publicPackages == null) {
      assert(allLibrariesAdded);
      // Help the user if they pass us a package that doesn't exist.
      for (var packageName in config.packageOrder) {
        if (!packages.map((p) => p.name).contains(packageName)) {
          warnOnElement(
              null, PackageWarning.packageOrderGivesMissingPackageName,
              message:
                  "${packageName}, packages: ${packages.map((p) => p.name).join(',')}");
        }
      }
      _publicPackages = packages.where((p) => p.isPublic).toList()..sort();
    }
    return _publicPackages;
  }

  /// Local packages are to be documented locally vs. remote or not at all.
  List<Package> get localPackages =>
      publicPackages.where((p) => p.isLocal).toList();

  /// Documented packages are documented somewhere (local or remote).
  Iterable<Package> get documentedPackages =>
      packages.where((p) => p.documentedWhere != DocumentLocation.missing);

  Map<LibraryElement, Set<Library>> _libraryElementReexportedBy = {};

  /// Prevent cycles from breaking our stack.
  Set<Tuple2<Library, LibraryElement>> _reexportsTagged = {};

  void _tagReexportsFor(
      final Library topLevelLibrary, final LibraryElement libraryElement,
      [ExportElement lastExportedElement]) {
    var key = Tuple2<Library, LibraryElement>(topLevelLibrary, libraryElement);
    if (_reexportsTagged.contains(key)) {
      return;
    }
    _reexportsTagged.add(key);
    if (libraryElement == null) {
      // The first call to _tagReexportFor should not have a null libraryElement.
      assert(lastExportedElement != null);
      warnOnElement(
          findButDoNotCreateLibraryFor(lastExportedElement.enclosingElement),
          PackageWarning.unresolvedExport,
          message: '"${lastExportedElement.uri}"',
          referredFrom: <Locatable>[topLevelLibrary]);
      return;
    }
    _libraryElementReexportedBy.putIfAbsent(libraryElement, () => {});
    _libraryElementReexportedBy[libraryElement].add(topLevelLibrary);
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
    var hrefMap = <String, Set<ModelElement>>{};
    // TODO(jcollins-g ): handle calculating hrefs causing new elements better
    //                    than toList().
    for (var modelElement in allConstructedModelElements.values.toList()) {
      // Technically speaking we should be able to use canonical model elements
      // only here, but since the warnings that depend on this debug
      // canonicalization problems, don't limit ourselves in case an href is
      // generated for something non-canonical.
      if (modelElement is Dynamic) continue;
      // TODO: see [Accessor.enclosingCombo]
      if (modelElement is Accessor) continue;
      if (modelElement.href == null) continue;
      hrefMap.putIfAbsent(modelElement.href, () => {});
      hrefMap[modelElement.href].add(modelElement);
    }
    for (var package in packageMap.values) {
      for (var library in package.libraries) {
        if (library.href == null) continue;
        hrefMap.putIfAbsent(library.href, () => {});
        hrefMap[library.href].add(library);
      }
    }
    return hrefMap;
  }

  void _addToImplementors(Class c) {
    assert(!allImplementorsAdded);
    _implementors.putIfAbsent(c.href, () => []);
    void _checkAndAddClass(Class key, Class implClass) {
      _implementors.putIfAbsent(key.href, () => []);
      List list = _implementors[key.href];

      if (!list.any((l) => l.element == c.element)) {
        list.add(implClass);
      }
    }

    if (c.mixins.isNotEmpty) {
      c.mixins.forEach((t) {
        _checkAndAddClass(t.element, c);
      });
    }
    if (c.supertype != null) {
      _checkAndAddClass(c.supertype.element, c);
    }
    if (c.interfaces.isNotEmpty) {
      c.interfaces.forEach((t) {
        _checkAndAddClass(t.element, c);
      });
    }
  }

  List<Library> get libraries =>
      packages.expand((p) => p.libraries).toList()..sort();

  List<Library> _publicLibraries;

  Iterable<Library> get publicLibraries {
    if (_publicLibraries == null) {
      assert(allLibrariesAdded);
      _publicLibraries = utils.filterNonPublic(libraries).toList();
    }
    return _publicLibraries;
  }

  List<Library> _localLibraries;

  Iterable<Library> get localLibraries {
    if (_localLibraries == null) {
      assert(allLibrariesAdded);
      _localLibraries = localPackages.expand((p) => p.libraries).toList()
        ..sort();
    }
    return _localLibraries;
  }

  List<Library> _localPublicLibraries;

  Iterable<Library> get localPublicLibraries {
    if (_localPublicLibraries == null) {
      assert(allLibrariesAdded);
      _localPublicLibraries = utils.filterNonPublic(localLibraries).toList();
    }
    return _localPublicLibraries;
  }

  Set<Class> _inheritThrough;

  /// Return the set of [Class]es objects should inherit through if they
  /// show up in the inheritance chain.  Do not call before interceptorElement is
  /// found.  Add classes here if they are similar to Interceptor in that they
  /// are to be ignored even when they are the implementors of [Inheritable]s,
  /// and the class these inherit from should instead claim implementation.
  Set<Class> get inheritThrough {
    if (_inheritThrough == null) {
      _inheritThrough = {};
      _inheritThrough.add(specialClasses[SpecialClass.interceptor]);
    }
    return _inheritThrough;
  }

  Set<Class> _invisibleAnnotations;

  /// Returns the set of [Class] objects that are similar to pragma
  /// in that we should never count them as documentable annotations.
  Set<Class> get invisibleAnnotations {
    if (_invisibleAnnotations == null) {
      _invisibleAnnotations = {};
      _invisibleAnnotations.add(specialClasses[SpecialClass.pragma]);
    }
    return _invisibleAnnotations;
  }

  @override
  String toString() => 'PackageGraph built from ${defaultPackage.name}';

  final Map<Element, Library> _canonicalLibraryFor = {};

  /// Tries to find a top level library that references this element.
  Library findCanonicalLibraryFor(Element e) {
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
        for (var modelElement in library.modelElementsMap[searchElement]) {
          if (modelElement.isCanonical) {
            _canonicalLibraryFor[e] = library;
            break;
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
  ModelElement findCanonicalModelElementFor(Element e,
      {Container preferredClass}) {
    assert(allLibrariesAdded);
    var lib = findCanonicalLibraryFor(e);
    if (preferredClass != null && preferredClass is Container) {
      Container canonicalClass =
          findCanonicalModelElementFor(preferredClass.element);
      if (canonicalClass != null) preferredClass = canonicalClass;
    }
    if (lib == null && preferredClass != null) {
      lib = findCanonicalLibraryFor(preferredClass.element);
    }
    ModelElement modelElement;
    // For elements defined in extensions, they are canonical.
    if (e?.enclosingElement is ExtensionElement) {
      lib ??= Library(e.enclosingElement.library, packageGraph);
      // (TODO:keertip) Find a better way to exclude members of extensions
      //  when libraries are specified using the "--include" flag
      if (lib?.isDocumented == true) {
        return ModelElement.from(e, lib, packageGraph);
      }
    }
    // TODO(jcollins-g): Special cases are pretty large here.  Refactor to split
    // out into helpers.
    // TODO(jcollins-g): The data structures should be changed to eliminate guesswork
    // with member elements.
    if (e is ClassMemberElement || e is PropertyAccessorElement) {
      e = e.declaration;
      var candidates = <ModelElement>{};
      var iKey = Tuple2<Element, Library>(e, lib);
      var key =
          Tuple4<Element, Library, Class, ModelElement>(e, lib, null, null);
      var keyWithClass = Tuple4<Element, Library, Class, ModelElement>(
          e, lib, preferredClass, null);
      if (allConstructedModelElements.containsKey(key)) {
        candidates.add(allConstructedModelElements[key]);
      }
      if (allConstructedModelElements.containsKey(keyWithClass)) {
        candidates.add(allConstructedModelElements[keyWithClass]);
      }
      if (candidates.isEmpty && allInheritableElements.containsKey(iKey)) {
        candidates
            .addAll(allInheritableElements[iKey].where((me) => me.isCanonical));
      }
      Class canonicalClass = findCanonicalModelElementFor(e.enclosingElement);
      if (canonicalClass != null) {
        candidates.addAll(canonicalClass.allCanonicalModelElements.where((m) {
          if (m.element == e) return true;
          return false;
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
      if (matches.length > 1 &&
          preferredClass != null &&
          preferredClass is Class) {
        // Search for matches inside our superchain.
        var superChain = preferredClass.superChain
            .map((et) => et.element)
            .cast<Class>()
            .toList();
        superChain.add(preferredClass);
        matches.removeWhere((me) =>
            !superChain.contains((me as EnclosedElement).enclosingElement));
        // Assumed all matches are EnclosedElement because we've been told about a
        // preferredClass.
        var enclosingElements = {
          ...matches
              .map((me) => (me as EnclosedElement).enclosingElement as Class)
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
        Accessor getter;
        Accessor setter;
        if (e is PropertyInducingElement) {
          if (e.getter != null) {
            getter = ModelElement.from(e.getter, lib, packageGraph);
          }
          if (e.setter != null) {
            setter = ModelElement.from(e.setter, lib, packageGraph);
          }
        }
        modelElement = ModelElement.from(e, lib, packageGraph,
            getter: getter, setter: setter);
      }
      assert(modelElement is! Inheritable);
      if (modelElement != null && !modelElement.isCanonical) {
        modelElement = null;
      }
    }
    // Prefer Fields.
    if (e is PropertyAccessorElement && modelElement is Accessor) {
      modelElement = (modelElement as Accessor).enclosingCombo;
    }
    return modelElement;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library findButDoNotCreateLibraryFor(Element e) {
    // This is just a cache to avoid creating lots of libraries over and over.
    if (allLibraries.containsKey(e.library)) {
      return allLibraries[e.library];
    }
    return null;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library findOrCreateLibraryFor(ResolvedLibraryResult result) {
    // This is just a cache to avoid creating lots of libraries over and over.
    if (allLibraries.containsKey(result.element.library)) {
      return allLibraries[result.element.library];
    }
    // can be null if e is for dynamic
    if (result.element.library == null) {
      return null;
    }
    var foundLibrary = Library.fromLibraryResult(
        result,
        this,
        Package.fromPackageMeta(
            PackageMeta.fromElement(result.element.library, config.sdkDir),
            packageGraph));
    allLibraries[result.element.library] = foundLibrary;
    return foundLibrary;
  }

  List<ModelElement> _allModelElements;

  Iterable<ModelElement> get allModelElements {
    assert(allLibrariesAdded);
    if (_allModelElements == null) {
      _allModelElements = [];
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
              _allModelElements.addAll(library.allModelElements);
              completedLibraries.add(library);
            });
            librariesToDo.addAll(p.allLibraries);
          }
          completedPackages.add(p);
        });
        packagesToDo.addAll(packages);
      }
    }
    return _allModelElements;
  }

  List<ModelElement> _allLocalModelElements;

  Iterable<ModelElement> get allLocalModelElements {
    assert(allLibrariesAdded);
    if (_allLocalModelElements == null) {
      _allLocalModelElements = [];
      localLibraries.forEach((library) {
        _allLocalModelElements.addAll(library.allModelElements);
      });
    }
    return _allLocalModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;

  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allLocalModelElements.where((e) => e.isCanonical).toList());
  }

  String getMacro(String name) {
    assert(_localDocumentationBuilt);
    return _macros[name];
  }

  void addMacro(String name, String content) {
    assert(!_localDocumentationBuilt);
    _macros[name] = content;
  }

  String getHtmlFragment(String name) {
    assert(_localDocumentationBuilt);
    return _htmlFragments[name];
  }

  void addHtmlFragment(String name, String content) {
    assert(!_localDocumentationBuilt);
    _htmlFragments[name] = content;
  }
}
