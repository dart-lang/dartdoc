// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart' as file_system;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/context/builder.dart';
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
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart' show PackageMeta;
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:package_config/discovery.dart' as package_config;
import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart' as quiver;

/// Everything you need to instantiate a PackageGraph object for documenting.
class PackageBuilder {
  final DartdocOptionContext config;

  PackageBuilder(this.config);

  Future<PackageGraph> buildPackageGraph() async {
    if (config.topLevelPackageMeta.needsPubGet) {
      config.topLevelPackageMeta.runPubGet();
    }
    // TODO(jdkoren): change factory for other formats based on config options
    RendererFactory rendererFactory = HtmlRenderFactory();

    PackageGraph newGraph = PackageGraph.UninitializedPackageGraph(
        config,
        driver,
        await driver.currentSession.typeSystem,
        sdk,
        hasEmbedderSdkFiles,
        rendererFactory);
    await getLibraries(newGraph);
    await newGraph.initializePackageGraph();
    return newGraph;
  }

  DartSdk _sdk;

  DartSdk get sdk {
    if (_sdk == null) {
      _sdk = FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
          PhysicalResourceProvider.INSTANCE.getFolder(config.sdkDir));
    }
    return _sdk;
  }

  EmbedderSdk _embedderSdk;

  EmbedderSdk get embedderSdk {
    if (_embedderSdk == null && !config.topLevelPackageMeta.isSdk) {
      _embedderSdk = EmbedderSdk(PhysicalResourceProvider.INSTANCE,
          EmbedderYamlLocator(packageMap).embedderYamls);
    }
    return _embedderSdk;
  }

  static Map<String, List<file_system.Folder>> _calculatePackageMap(
      file_system.Folder dir) {
    Map<String, List<file_system.Folder>> map = Map();
    var info = package_config.findPackagesFromFile(dir.toUri());

    for (String name in info.packages) {
      Uri uri = info.asMap()[name];
      String packagePath = path.normalize(path.fromUri(uri));
      file_system.Resource resource =
          PhysicalResourceProvider.INSTANCE.getResource(packagePath);
      if (resource is file_system.Folder) {
        map[name] = [resource];
      }
    }

    return map;
  }

  Map<String, List<file_system.Folder>> _packageMap;

  Map<String, List<file_system.Folder>> get packageMap {
    if (_packageMap == null) {
      file_system.Folder cwd =
          PhysicalResourceProvider.INSTANCE.getResource(config.inputDir);
      _packageMap = _calculatePackageMap(cwd);
    }
    return _packageMap;
  }

  DartUriResolver _embedderResolver;

  DartUriResolver get embedderResolver {
    if (_embedderResolver == null) {
      _embedderResolver = DartUriResolver(embedderSdk);
    }
    return _embedderResolver;
  }

  SourceFactory get sourceFactory {
    List<UriResolver> resolvers = [];
    final UriResolver packageResolver =
        PackageMapUriResolver(PhysicalResourceProvider.INSTANCE, packageMap);
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
    resolvers.add(PackageWithoutSdkResolver(packageResolver, sdkResolver));
    resolvers.add(sdkResolver);
    resolvers.add(
        file_system.ResourceUriResolver(PhysicalResourceProvider.INSTANCE));

    assert(
        resolvers.any((UriResolver resolver) => resolver is DartUriResolver));
    SourceFactory sourceFactory = SourceFactory(resolvers);
    return sourceFactory;
  }

  AnalysisDriver _driver;

  AnalysisDriver get driver {
    if (_driver == null) {
      PerformanceLog log = PerformanceLog(null);
      AnalysisDriverScheduler scheduler = AnalysisDriverScheduler(log);
      AnalysisOptionsImpl options = AnalysisOptionsImpl();

      // TODO(jcollins-g): pass in an ExperimentStatus instead?
      options.enabledExperiments = config.enableExperiment;

      // TODO(jcollins-g): Make use of currently not existing API for managing
      //                   many AnalysisDrivers
      // TODO(jcollins-g): make use of DartProject isApi()
      _driver = AnalysisDriver(
          scheduler,
          log,
          PhysicalResourceProvider.INSTANCE,
          MemoryByteStore(),
          FileContentOverlay(),
          null,
          sourceFactory,
          options);
      driver.results.listen((_) {});
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
      Source source = sdk.mapDartUri(sdkLib.shortName);
      yield source.fullName;
    }
  }

  /// Parse a single library at [filePath] using the current analysis driver.
  /// If [filePath] is not a library, returns null.
  Future<ResolvedLibraryResult> processLibrary(String filePath) async {
    String name = filePath;

    if (name.startsWith(directoryCurrentPath)) {
      name = name.substring(directoryCurrentPath.length);
      if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
    }
    JavaFile javaFile = JavaFile(filePath).getAbsoluteFile();
    Source source = FileBasedSource(javaFile);

    // TODO(jcollins-g): remove the manual reversal using embedderSdk when we
    // upgrade to analyzer-0.30 (where DartUriResolver implements
    // restoreAbsolute)
    Uri uri = embedderSdk?.fromFileUri(source.uri)?.uri;
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
      return await driver.currentSession.getResolvedLibrary(source.fullName);
    }
    return null;
  }

  Set<PackageMeta> _packageMetasForFiles(Iterable<String> files) {
    Set<PackageMeta> metas = Set();
    for (String filename in files) {
      metas.add(PackageMeta.fromFilename(filename));
    }
    return metas;
  }

  /// Parse libraries with the analyzer and invoke a callback with the
  /// result.
  ///
  /// Uses the [libraries] parameter to prevent calling
  /// the callback more than once with the same [LibraryElement].
  /// Adds [LibraryElement]s found to that parameter.
  Future<void> _parseLibraries(
      void Function(ResolvedLibraryResult) libraryAdder,
      Set<LibraryElement> libraries,
      Set<String> files,
      [bool Function(LibraryElement) isLibraryIncluded]) async {
    isLibraryIncluded ??= (_) => true;
    Set<PackageMeta> lastPass = Set();
    Set<PackageMeta> current;
    do {
      lastPass = _packageMetasForFiles(files);

      // Be careful here not to accidentally stack up multiple
      // ResolvedLibraryResults, as those eat our heap.
      for (String f in files) {
        ResolvedLibraryResult r = await processLibrary(f);
        if (r != null &&
            !libraries.contains(r.element) &&
            isLibraryIncluded(r.element)) {
          logInfo('parsing ${f}...');
          libraryAdder(r);
          libraries.add(r.element);
        }
      }

      // Be sure to give the analyzer enough time to find all the files.
      await driver.discoverAvailableFiles();
      files.addAll(driver.knownFiles);
      files.addAll(_includeExternalsFrom(driver.knownFiles));
      current = _packageMetasForFiles(files);
      // To get canonicalization correct for non-locally documented packages
      // (so we can generate the right hyperlinks), it's vital that we
      // add all libraries in dependent packages.  So if the analyzer
      // discovers some files in a package we haven't seen yet, add files
      // for that package.
      for (PackageMeta meta in current.difference(lastPass)) {
        if (meta.isSdk) {
          files.addAll(getSdkFilesToDocument());
        } else {
          files.addAll(
              findFilesToDocumentInPackage(meta.dir.path, false, false));
        }
      }
    } while (!lastPass.containsAll(current));
  }

  /// Given a package name, explore the directory and pull out all top level
  /// library files in the "lib" directory to document.
  Iterable<String> findFilesToDocumentInPackage(
      String basePackageDir, bool autoIncludeDependencies,
      [bool filterExcludes = true]) sync* {
    final String sep = path.separator;

    Set<String> packageDirs = Set()..add(basePackageDir);

    if (autoIncludeDependencies) {
      Map<String, Uri> info = package_config
          .findPackagesFromFile(
              Uri.file(path.join(basePackageDir, 'pubspec.yaml')))
          .asMap();
      for (String packageName in info.keys) {
        if (!filterExcludes || !config.exclude.contains(packageName)) {
          packageDirs.add(path.dirname(info[packageName].toFilePath()));
        }
      }
    }

    for (String packageDir in packageDirs) {
      var packageLibDir = path.join(packageDir, 'lib');
      var packageLibSrcDir = path.join(packageLibDir, 'src');
      // To avoid analyzing package files twice, only files with paths not
      // containing '/packages' will be added. The only exception is if the file
      // to analyze already has a '/package' in its path.
      for (var lib
          in listDir(packageDir, recursive: true, listDir: _packageDirList)) {
        if (lib.endsWith('.dart') &&
            (!lib.contains('${sep}packages${sep}') ||
                packageDir.contains('${sep}packages${sep}'))) {
          // Only include libraries within the lib dir that are not in lib/src
          if (path.isWithin(packageLibDir, lib) &&
              !path.isWithin(packageLibSrcDir, lib)) {
            // Only add the file if it does not contain 'part of'
            var contents = File(lib).readAsStringSync();

            if (contents.contains(newLinePartOfRegexp) ||
                contents.startsWith(partOfRegexp)) {
              // NOOP: it's a part file
            } else {
              yield lib;
            }
          }
        }
      }
    }
  }

  /// Calculate includeExternals based on a list of files.  Assumes each
  /// file might be part of a [DartdocOptionContext], and loads those
  /// objects to find any [DartdocOptionContext.includeExternal] configurations
  /// therein.
  Iterable<String> _includeExternalsFrom(Iterable<String> files) sync* {
    for (String file in files) {
      DartdocOptionContext fileContext =
          DartdocOptionContext.fromContext(config, File(file));
      if (fileContext.includeExternal != null) {
        yield* fileContext.includeExternal;
      }
    }
  }

  Set<String> getFiles() {
    Iterable<String> files;
    if (config.topLevelPackageMeta.isSdk) {
      files = getSdkFilesToDocument();
    } else {
      files = findFilesToDocumentInPackage(
          config.inputDir, config.autoIncludeDependencies);
    }
    files = quiver.concat([files, _includeExternalsFrom(files)]);
    return Set.from(files.map((s) => File(s).absolute.path));
  }

  Iterable<String> getEmbedderSdkFiles() sync* {
    if (embedderSdk != null &&
        embedderSdk.urlMappings.isNotEmpty &&
        !config.topLevelPackageMeta.isSdk) {
      for (String dartUri in embedderSdk.urlMappings.keys) {
        Source source = embedderSdk.mapDartUri(dartUri);
        yield (File(source.fullName)).absolute.path;
      }
    }
  }

  bool get hasEmbedderSdkFiles =>
      embedderSdk != null && getEmbedderSdkFiles().isNotEmpty;

  Future<void> getLibraries(PackageGraph uninitializedPackageGraph) async {
    DartSdk findSpecialsSdk = sdk;
    if (embedderSdk != null && embedderSdk.urlMappings.isNotEmpty) {
      findSpecialsSdk = embedderSdk;
    }
    Set<String> files = getFiles()..addAll(getEmbedderSdkFiles());
    Set<String> specialFiles = specialLibraryFiles(findSpecialsSdk).toSet();

    /// Returns true if this library element should be included according
    /// to the configuration.
    bool isLibraryIncluded(LibraryElement libraryElement) {
      if (config.include.isNotEmpty &&
          !config.include.contains(libraryElement.name)) {
        return false;
      }
      return true;
    }

    Set<LibraryElement> foundLibraries = Set();
    await _parseLibraries(uninitializedPackageGraph.addLibraryToGraph,
        foundLibraries, files, isLibraryIncluded);
    if (config.include.isNotEmpty) {
      Iterable knownLibraryNames = foundLibraries.map((l) => l.name);
      Set notFound = Set.from(config.include)
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
  static Iterable<FileSystemEntity> _packageDirList(Directory dir) sync* {
    var entities = dir.listSync();

    var pubspec = entities.firstWhere(
        (e) => e is File && path.basename(e.path) == 'pubspec.yaml',
        orElse: () => null);

    var libDir = entities.firstWhere(
        (e) => e is Directory && path.basename(e.path) == 'lib',
        orElse: () => null);

    if (pubspec != null && libDir != null) {
      yield libDir;
    } else {
      yield* entities;
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
    } catch (ArgumentError) {
      // SDK resolvers really don't like being thrown package paths.
    }
    if (resolved == null) {
      return _packageResolver.restoreAbsolute(source);
    }
    return null;
  }
}
