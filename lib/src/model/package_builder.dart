// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/context/packages.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/file_state.dart';
import 'package:analyzer/src/dart/analysis/performance_logger.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:analyzer/src/source/package_map_resolver.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart' hide Package;
import 'package:dartdoc/src/quiver.dart' as quiver;
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart'
    show PackageMeta, PackageMetaProvider;
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:meta/meta.dart';
// TODO(jcollins-g): do not directly import path, use ResourceProvider instead
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

/// Everything you need to instantiate a PackageGraph object for documenting.
abstract class PackageBuilder {
  // Builds package graph to be used by documentation generator.
  Future<PackageGraph> buildPackageGraph();
}

/// A package builder that understands pub package format.
class PubPackageBuilder implements PackageBuilder {
  final DartdocOptionContext config;
  final PackageMetaProvider packageMetaProvider;
  final PackageConfigProvider packageConfigProvider;

  PubPackageBuilder(
      this.config, this.packageMetaProvider, this.packageConfigProvider);

  @override
  Future<PackageGraph> buildPackageGraph() async {
    if (!config.sdkDocs) {
      if (config.topLevelPackageMeta.requiresFlutter &&
          config.flutterRoot == null) {
        throw DartdocOptionError(
            'Top level package requires Flutter but FLUTTER_ROOT environment variable not set');
      }
      if (config.topLevelPackageMeta.needsPubGet) {
        config.topLevelPackageMeta.runPubGet(config.flutterRoot);
      }
    }

    var rendererFactory = RendererFactory.forFormat(config.format);

    await _calculatePackageMap();

    var newGraph = PackageGraph.UninitializedPackageGraph(
      config,
      sdk,
      hasEmbedderSdkFiles,
      rendererFactory,
      packageMetaProvider,
    );
    await getLibraries(newGraph);
    await newGraph.initializePackageGraph();
    return newGraph;
  }

  /*late final*/ DartSdk _sdk;

  DartSdk get sdk {
    _sdk ??= packageMetaProvider.defaultSdk ??
        FolderBasedDartSdk(
            resourceProvider, resourceProvider.getFolder(config.sdkDir));

    return _sdk;
  }

  EmbedderSdk _embedderSdk;

  EmbedderSdk get embedderSdk {
    if (_embedderSdk == null && !config.topLevelPackageMeta.isSdk) {
      _embedderSdk = EmbedderSdk(
          resourceProvider, EmbedderYamlLocator(_packageMap).embedderYamls);
    }
    return _embedderSdk;
  }

  ResourceProvider get resourceProvider => packageMetaProvider.resourceProvider;

  /* late final */ Packages packages;

  Future<void> _calculatePackageMap() async {
    assert(_packageMap == null);
    _packageMap = <String, List<Folder>>{};
    Folder cwd = resourceProvider.getResource(config.inputDir);
    var info = await packageConfigProvider
        .findPackageConfig(resourceProvider.getFolder(cwd.path));
    if (info == null) return;

    var rpc = resourceProvider.pathContext;
    // This complicated expression transforms a list of [package_config.Package]
    // into [analyzer.Packages].  It's a bit confusing because [info.packages]
    // is actually the list of [package_config.Package] objects, rather than
    // the [Packages] object we need.
    packages = Packages(Map.fromEntries(info.packages.map((p) => MapEntry<
            String, Package>(
        p.name,
        Package(
            name: p.name,
            rootFolder:
                resourceProvider.getFolder(rpc.normalize(rpc.fromUri(p.root))),
            languageVersion: p.languageVersion != null
                ? Version(p.languageVersion.major, p.languageVersion.minor, 0)
                : null,
            libFolder: resourceProvider.getFolder(
              rpc.normalize(rpc.fromUri(p.packageUriRoot)),
            ))))));

    for (var package in info.packages) {
      var packagePath = rpc.normalize(rpc.fromUri(package.packageUriRoot));
      var resource = resourceProvider.getResource(packagePath);
      if (resource is Folder) {
        _packageMap[package.name] = [resource];
      }
    }
  }

  /*late final*/ Map<String, List<Folder>> _packageMap;

  DartUriResolver _embedderResolver;

  DartUriResolver get embedderResolver {
    _embedderResolver ??= DartUriResolver(embedderSdk);
    return _embedderResolver;
  }

  SourceFactory get sourceFactory {
    final UriResolver packageResolver =
        PackageMapUriResolver(resourceProvider, _packageMap);
    UriResolver sdkResolver;
    if (embedderSdk == null || embedderSdk.urlMappings.isEmpty) {
      // The embedder uri resolver has no mappings. Use the default Dart SDK
      // uri resolver.
      sdkResolver = DartUriResolver(sdk);
    } else {
      // The embedder uri resolver has mappings, use it instead of the default
      // Dart SDK uri resolver.
      sdkResolver = embedderResolver;
    }

    /// [AnalysisDriver] seems to require package resolvers that
    /// never resolve to embedded SDK files, and the resolvers list must still
    /// contain a DartUriResolver.  This hack won't be necessary once analyzer
    /// has a clean public API.
    var resolvers = [
      PackageWithoutSdkResolver(packageResolver, sdkResolver),
      sdkResolver,
      ResourceUriResolver(resourceProvider),
    ];

    assert(
        resolvers.any((UriResolver resolver) => resolver is DartUriResolver));
    return SourceFactory(resolvers);
  }

  AnalysisDriver _driver;
  AnalysisDriver get driver {
    if (_driver == null) {
      var log = PerformanceLog(null);
      var scheduler = AnalysisDriverScheduler(log);
      var options = AnalysisOptionsImpl()
        ..hint = false
        // TODO(jcollins-g): pass in an ExperimentStatus instead?
        ..contextFeatures = FeatureSet.fromEnableFlags(config.enableExperiment);
      // TODO(jcollins-g): make use of AnalysisContextCollection()
      // TODO(jcollins-g): make use of DartProject isApi()
      _driver = AnalysisDriver(scheduler, log, resourceProvider,
          MemoryByteStore(), FileContentOverlay(), null, sourceFactory, options,
          packages: packages);
      driver.results.listen((_) => logProgress(''));
      driver.exceptions.listen((_) {});
      scheduler.start();
    }
    return _driver;
  }

  /// Return an Iterable with the sdk files we should parse.
  /// Filter can be String or RegExp (technically, anything valid for
  /// [String.contains])
  Iterable<String> getSdkFilesToDocument() sync* {
    for (var sdkLib in sdk.sdkLibraries) {
      var source = sdk.mapDartUri(sdkLib.shortName);
      yield source.fullName;
    }
  }

  /// Parse a single library at [filePath] using the current analysis driver.
  /// If [filePath] is not a library, returns null.
  Future<DartDocResolvedLibrary> processLibrary(String filePath) async {
    var name = filePath;
    var directoryCurrentPath = resourceProvider.pathContext.current;

    if (name.startsWith(directoryCurrentPath)) {
      name = name.substring(directoryCurrentPath.length);
      if (name.startsWith(resourceProvider.pathContext.separator)) {
        name = name.substring(1);
      }
    }
    var javaFile = JavaFile(filePath).getAbsoluteFile();
    Source source = FileBasedSource(javaFile);

    // TODO(jcollins-g): remove the manual reversal using embedderSdk when we
    // upgrade to analyzer-0.30 (where DartUriResolver implements
    // restoreAbsolute)
    var uri = embedderSdk?.fromFileUri(source.uri)?.uri;
    if (uri != null) {
      source = FileBasedSource(javaFile, uri);
    } else {
      uri = driver.sourceFactory.restoreUri(source);
      if (uri != null) {
        source = FileBasedSource(javaFile, uri);
      }
    }
    var sourceKind = await driver.getSourceKind(filePath);
    // Allow dart source files with inappropriate suffixes (#1897).  Those
    // do not show up as SourceKind.LIBRARY.
    if (sourceKind != SourceKind.PART) {
      // Loading libraryElements from part files works, but is painfully slow
      // and creates many duplicates.
      final library =
          await driver.currentSession.getResolvedLibrary(source.fullName);
      final libraryElement = library.element;
      var restoredUri = libraryElement.source.uri.toString();
      if (!restoredUri.startsWith('dart:')) {
        restoredUri =
            driver.sourceFactory.restoreUri(library.element.source).toString();
      }
      return DartDocResolvedLibrary(library, restoredUri);
    }
    return null;
  }

  Set<PackageMeta> _packageMetasForFiles(Iterable<String> files) => {
        for (var filename in files) packageMetaProvider.fromFilename(filename),
      };

  /// Parses libraries with the analyzer and invokes [libraryAdder] with each
  /// result.
  ///
  /// Uses [libraries] to prevent calling the callback more than once with the
  /// same [LibraryElement]. Adds each [LibraryElement] found to [libraries].
  Future<void> _parseLibraries(
      void Function(DartDocResolvedLibrary) libraryAdder,
      Set<LibraryElement> libraries,
      Set<String> files,
      [bool Function(LibraryElement) isLibraryIncluded]) async {
    isLibraryIncluded ??= (_) => true;
    var lastPass = <PackageMeta>{};
    Set<PackageMeta> current;
    var knownParts = <String>{};
    do {
      lastPass = _packageMetasForFiles(files);

      // Be careful here not to accidentally stack up multiple
      // [DartDocResolvedLibrary]s, as those eat our heap.
      for (var f in files.difference(knownParts)) {
        logProgress(f);
        var r = await processLibrary(f);
        if (r == null) {
          knownParts.add(f);
          continue;
        }
        if (!libraries.contains(r.element) && isLibraryIncluded(r.element)) {
          logDebug('parsing ${f}...');
          libraryAdder(r);
          libraries.add(r.element);
        }
      }

      // Be sure to give the analyzer enough time to find all the files.
      await driver.discoverAvailableFiles();
      files.addAll(driver.knownFiles);
      files.addAll(_includeExternalsFrom(driver.knownFiles));
      current = _packageMetasForFiles(files.difference(knownParts));
      // To get canonicalization correct for non-locally documented packages
      // (so we can generate the right hyperlinks), it's vital that we
      // add all libraries in dependent packages.  So if the analyzer
      // discovers some files in a package we haven't seen yet, add files
      // for that package.
      for (var meta in current.difference(lastPass)) {
        if (meta.isSdk) {
          files.addAll(getSdkFilesToDocument());
        } else {
          files.addAll(await findFilesToDocumentInPackage(meta.dir.path,
                  autoIncludeDependencies: false, filterExcludes: false)
              .toList());
        }
      }
    } while (!lastPass.containsAll(current));
  }

  /// Given a package name, explore the directory and pull out all top level
  /// library files in the "lib" directory to document.
  Stream<String> findFilesToDocumentInPackage(String basePackageDir,
      {@required bool autoIncludeDependencies,
      bool filterExcludes = true}) async* {
    var packageDirs = {basePackageDir};

    if (autoIncludeDependencies) {
      var info = await packageConfigProvider
          .findPackageConfig(resourceProvider.getFolder(basePackageDir));
      for (var package in info.packages) {
        if (!filterExcludes || !config.exclude.contains(package.name)) {
          packageDirs.add(
              path.dirname(path.fromUri(info[package.name].packageUriRoot)));
        }
      }
    }

    var sep = path.separator;
    for (var packageDir in packageDirs) {
      var packageLibDir = path.join(packageDir, 'lib');
      var packageLibSrcDir = path.join(packageLibDir, 'src');
      // To avoid analyzing package files twice, only files with paths not
      // containing '/packages' will be added. The only exception is if the file
      // to analyze already has a '/package' in its path.
      for (var lib
          in _listDir(packageDir, recursive: true, listDir: _packageDirList)) {
        if (lib.endsWith('.dart') &&
            (!lib.contains('${sep}packages${sep}') ||
                packageDir.contains('${sep}packages${sep}'))) {
          // Only include libraries within the lib dir that are not in 'lib/src'.
          if (path.isWithin(packageLibDir, lib) &&
              !path.isWithin(packageLibSrcDir, lib)) {
            // Only add the file if it does not contain 'part of'.
            var contents = resourceProvider.getFile(lib).readAsStringSync();

            if (contents.startsWith('part of ') ||
                contents.contains('\npart of ')) {
              // NOOP: it's a part file.
            } else {
              yield lib;
            }
          }
        }
      }
    }
  }

  /// Lists the contents of [dir].
  ///
  /// If [recursive] is `true`, lists subdirectory contents (defaults to `false`).
  ///
  /// Excludes files and directories beginning with `.`
  ///
  /// The returned paths are guaranteed to begin with [dir].
  Iterable<String> _listDir(String dir,
      {bool recursive = false,
      Iterable<Resource> Function(Folder dir) listDir}) {
    listDir ??= (Folder dir) => dir.getChildren();

    return _doList(dir, <String>{}, recursive, listDir);
  }

  Iterable<String> _doList(String dir, Set<String> listedDirectories,
      bool recurse, Iterable<Resource> Function(Folder dir) listDir) sync* {
    // Avoid recursive symlinks.
    var resolvedPath =
        resourceProvider.getFolder(dir).resolveSymbolicLinksSync().path;
    if (!listedDirectories.contains(resolvedPath)) {
      listedDirectories = Set<String>.from(listedDirectories);
      listedDirectories.add(resolvedPath);

      for (var resource in listDir(resourceProvider.getFolder(dir))) {
        // Skip hidden files and directories
        if (path.basename(resource.path).startsWith('.')) {
          continue;
        }

        yield resource.path;
        if (resource is Folder && recurse) {
          yield* _doList(resource.path, listedDirectories, recurse, listDir);
        }
      }
    }
  }

  /// Calculate includeExternals based on a list of files.  Assumes each
  /// file might be part of a [DartdocOptionContext], and loads those
  /// objects to find any [DartdocOptionContext.includeExternal] configurations
  /// therein.
  Iterable<String> _includeExternalsFrom(Iterable<String> files) sync* {
    for (var file in files) {
      var fileContext = DartdocOptionContext.fromContext(config,
          config.resourceProvider.getFile(file), config.resourceProvider);
      if (fileContext.includeExternal != null) {
        yield* fileContext.includeExternal;
      }
    }
  }

  Future<Set<String>> _getFiles() async {
    Iterable<String> files;
    if (config.topLevelPackageMeta.isSdk) {
      files = getSdkFilesToDocument();
    } else {
      files = await findFilesToDocumentInPackage(config.inputDir,
              autoIncludeDependencies: config.autoIncludeDependencies)
          .toList();
    }
    files = quiver.concat([files, _includeExternalsFrom(files)]);
    return {
      ...files.map((s) => resourceProvider.pathContext
          .absolute(resourceProvider.getFile(s).path)),
      ...getEmbedderSdkFiles(),
    };
  }

  Iterable<String> getEmbedderSdkFiles() {
    return [
      for (var dartUri in _embedderSdkUris)
        resourceProvider.pathContext.absolute(resourceProvider
            .getFile(embedderSdk.mapDartUri(dartUri).fullName)
            .path),
    ];
  }

  bool get hasEmbedderSdkFiles => _embedderSdkUris.isNotEmpty;

  Iterable<String> get _embedderSdkUris {
    if (config.topLevelPackageMeta.isSdk) return [];

    return embedderSdk?.urlMappings?.keys ?? [];
  }

  Future<void> getLibraries(PackageGraph uninitializedPackageGraph) async {
    var findSpecialsSdk = sdk;
    if (embedderSdk != null && embedderSdk.urlMappings.isNotEmpty) {
      findSpecialsSdk = embedderSdk;
    }
    var files = await _getFiles();
    var specialFiles = specialLibraryFiles(findSpecialsSdk);

    /// Returns true if this library element should be included according
    /// to the configuration.
    bool isLibraryIncluded(LibraryElement libraryElement) {
      if (config.include.isNotEmpty &&
          !config.include.contains(libraryElement.name)) {
        return false;
      }
      return true;
    }

    var foundLibraries = <LibraryElement>{};
    await _parseLibraries(uninitializedPackageGraph.addLibraryToGraph,
        foundLibraries, files, isLibraryIncluded);
    if (config.include.isNotEmpty) {
      var knownLibraryNames = foundLibraries.map((l) => l.name);
      var notFound = Set<String>.from(config.include)
          .difference(Set.from(knownLibraryNames))
          .difference(Set.from(config.exclude));
      if (notFound.isNotEmpty) {
        throw 'Did not find: [${notFound.join(', ')}] in '
            'known libraries: [${knownLibraryNames.join(', ')}]';
      }
    }
    // Include directive does not apply to special libraries.
    await _parseLibraries(uninitializedPackageGraph.addSpecialLibraryToGraph,
        foundLibraries, specialFiles.difference(files));
  }

  /// If [dir] contains both a `lib` directory and a `pubspec.yaml` file treat
  /// it like a package and only return the `lib` dir.
  ///
  /// This ensures that packages don't have non-`lib` content documented.
  static Iterable<Resource> _packageDirList(Folder dir) sync* {
    var resources = dir.getChildren();

    var pubspec = resources.firstWhere(
        (e) => e is File && path.basename(e.path) == 'pubspec.yaml',
        orElse: () => null);

    var libDir = resources.firstWhere(
        (e) => e is Folder && path.basename(e.path) == 'lib',
        orElse: () => null);

    if (pubspec != null && libDir != null) {
      yield libDir;
    } else {
      yield* resources;
    }
  }
}

/// This class resolves package URIs, but only if a given SdkResolver doesn't
/// resolve them.
///
/// TODO(jcollins-g): remove this hackery when a clean public API to analyzer
/// exists, and port dartdoc to it.
class PackageWithoutSdkResolver extends UriResolver {
  final UriResolver _packageResolver;
  final UriResolver _sdkResolver;

  PackageWithoutSdkResolver(this._packageResolver, this._sdkResolver);

  @override
  Source resolveAbsolute(Uri uri, [Uri actualUri]) {
    if (_sdkResolver.resolveAbsolute(uri, actualUri) == null) {
      return _packageResolver.resolveAbsolute(uri, actualUri);
    }
    return null;
  }

  @override
  Uri restoreAbsolute(Source source) {
    Uri resolved;
    try {
      resolved = _sdkResolver.restoreAbsolute(source);
    } on ArgumentError {
      // SDK resolvers really don't like being thrown package paths.
    }
    if (resolved == null) {
      return _packageResolver.restoreAbsolute(source);
    }
    return null;
  }
}

/// Contains the [ResolvedLibraryResult] and any additional information about
/// the library coming from [AnalysisDriver].
///
/// Prefer to populate this class with more information rather than passing
/// [AnalysisDriver] or [AnalysisSession] down to [PackageGraph]. The graph
/// object is reachable by many DartDoc model objects and there's no guarantee
/// that there's a valid [AnalysisDriver] in every environment dartdoc runs.
class DartDocResolvedLibrary {
  final ResolvedLibraryResult result;
  final String restoredUri;

  DartDocResolvedLibrary(this.result, this.restoredUri);

  LibraryElement get element => result.element;
  LibraryElement get library => result.element.library;
}
