// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/context/builder.dart' show EmbedderYamlLocator;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollectionImpl;
// ignore: implementation_imports
import 'package:analyzer/src/dart/sdk/sdk.dart'
    show EmbedderSdk, FolderBasedDartSdk;
// ignore: implementation_imports
import 'package:analyzer/src/generated/engine.dart' show AnalysisOptionsImpl;
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk;
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart' hide Package;
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart'
    show PackageMeta, PackageMetaProvider;
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;

/// Everything you need to instantiate a PackageGraph object for documenting.
abstract class PackageBuilder {
  // Builds package graph to be used by documentation generator.
  Future<PackageGraph> buildPackageGraph();

  /// The `include-external` option is deprecated, so we track whether it was
  /// used, to report it.
  bool get includeExternalsWasSpecified;
}

/// A package builder that understands pub package format.
class PubPackageBuilder implements PackageBuilder {
  final DartdocOptionContext _config;
  final PackageMetaProvider _packageMetaProvider;
  final PackageConfigProvider _packageConfigProvider;

  final AnalysisContextCollectionImpl _contextCollection;
  final AnalysisContext _analysisContext;

  factory PubPackageBuilder(
    DartdocOptionContext config,
    PackageMetaProvider packageMetaProvider,
    PackageConfigProvider packageConfigProvider, {
    @visibleForTesting bool skipUnreachableSdkLibraries = false,
  }) {
    var contextCollection = AnalysisContextCollectionImpl(
      includedPaths: [config.inputDir],
      // TODO(jcollins-g): should we pass excluded directories here instead
      // of handling it ourselves?
      resourceProvider: packageMetaProvider.resourceProvider,
      sdkPath: config.sdkDir,
      updateAnalysisOptions2: ({
        required AnalysisOptionsImpl analysisOptions,
        required ContextRoot contextRoot,
        required DartSdk sdk,
      }) =>
          analysisOptions
            ..warning = false
            ..lint = false,
    );
    return PubPackageBuilder._(
      config,
      packageMetaProvider,
      packageConfigProvider,
      contextCollection,
      analysisContext: contextCollection.contextFor(config.inputDir),
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
  }

  PubPackageBuilder._(
    this._config,
    this._packageMetaProvider,
    this._packageConfigProvider,
    this._contextCollection, {
    required AnalysisContext analysisContext,
    required bool skipUnreachableSdkLibraries,
  })  : _analysisContext = analysisContext,
        _skipUnreachableSdkLibraries = skipUnreachableSdkLibraries;

  @override
  Future<PackageGraph> buildPackageGraph() async {
    runtimeStats.resetAccumulators([
      'elementTypeInstantiation',
      'modelElementCacheInsertion',
    ]);

    runtimeStats.startPerfTask('_calculatePackageMap');
    await _calculatePackageMap();
    runtimeStats.endPerfTask();

    runtimeStats.startPerfTask('getLibraries');
    var newGraph = PackageGraph.uninitialized(
      _config,
      _sdk,
      _embedderSdkUris.isNotEmpty,
      _packageMetaProvider,
      _analysisContext,
    );
    await _getLibraries(newGraph);
    runtimeStats.endPerfTask();

    logDebug('${DateTime.now()}: Initializing package graph...');
    runtimeStats.startPerfTask('initializePackageGraph');
    try {
      await newGraph.initializePackageGraph();
    } finally {
      await _dispose();
    }
    runtimeStats.endPerfTask();

    runtimeStats.startPerfTask('initializeCategories');
    newGraph.initializeCategories();
    runtimeStats.endPerfTask();

    return newGraph;
  }

  Future<void> _dispose() async {
    // Shutdown macro support.
    await _contextCollection.dispose();
  }

  late final DartSdk _sdk = _packageMetaProvider.defaultSdk ??
      FolderBasedDartSdk(
          _resourceProvider, _resourceProvider.getFolder(_config.sdkDir));

  EmbedderSdk? __embedderSdk;

  EmbedderSdk? get _embedderSdk {
    if (__embedderSdk == null && !_config.topLevelPackageMeta.isSdk) {
      __embedderSdk = EmbedderSdk(
          _resourceProvider, EmbedderYamlLocator(_packageMap).embedderYamls);
    }
    return __embedderSdk;
  }

  ResourceProvider get _resourceProvider =>
      _packageMetaProvider.resourceProvider;

  p.Context get _pathContext => _resourceProvider.pathContext;

  /// Do not call more than once for a given PackageBuilder.
  Future<void> _calculatePackageMap() async {
    _packageMap = <String, List<Folder>>{};
    var cwd = _resourceProvider.getResource(_config.inputDir) as Folder;
    var info = await _packageConfigProvider
        .findPackageConfig(_resourceProvider.getFolder(cwd.path));
    if (info == null) return;

    for (var package in info.packages) {
      var packagePath =
          _pathContext.normalize(_pathContext.fromUri(package.packageUriRoot));
      var resource = _resourceProvider.getResource(packagePath);
      if (resource is Folder) {
        _packageMap[package.name] = [resource];
      }
    }
  }

  late final Map<String, List<Folder>> _packageMap;

  List<String> get _sdkFilesToDocument => [
        for (var sdkLib in _sdk.sdkLibraries)
          // TODO(srawlins): This bit is temporary, here in order to unblock some
          // unfortunate CI in the Dart SDK which is not designed well for when
          // SDK libraries are _removed_.
          if (!sdkLib.shortName.contains('macros'))
            _sdk.mapDartUri(sdkLib.shortName)!.fullName,
      ];

  /// Resolves a single library at [filePath] using the current analysis driver.
  ///
  /// If [filePath] is not a library, returns null.
  Future<DartDocResolvedLibrary?> _resolveLibrary(String filePath) async {
    logDebug('Resolving $filePath...');

    // Allow dart source files with inappropriate suffixes (#1897).
    final library =
        await _analysisContext.currentSession.getResolvedLibrary(filePath);
    if (library is ResolvedLibraryResult) {
      return DartDocResolvedLibrary(library);
    }
    return null;
  }

  Set<PackageMeta> _packageMetasForFiles(Iterable<String> files) => {
        for (var filename in files)
          _packageMetaProvider.fromFilename(filename)!,
      };

  /// Whether to skip unreachable libraries when gathering all of the libraries
  /// for the package graph.
  ///
  /// **TESTING ONLY**
  ///
  /// When generating dartdoc for any package, this flag should be `false`. This
  /// is used in tests to dramatically speed up unit tests.
  final bool _skipUnreachableSdkLibraries;

  /// A set containing known part file paths.
  ///
  /// This set is used to prevent resolving set files more than once.
  final _knownParts = <String>{};

  /// Discovers and resolves libraries, invoking [addLibrary] with each result.
  ///
  /// Uses [processedLibraries] to prevent calling [addLibrary] more than once
  /// with the same [LibraryElement]. Adds each [LibraryElement] found to
  /// [processedLibraries].
  Future<void> _discoverLibraries(PackageGraph uninitializedPackageGraph,
      Set<LibraryElement> processedLibraries, Set<String> files) async {
    files = {...files};
    // Discover Dart libraries in a loop. In each iteration of the loop, we take
    // a set of files (starting with the ones passed into the function), resolve
    // them, add them to the package graph via `addLibrary`, and then discover
    // which additional files need to be processed in the next loop. This
    // discovery depends on various options (TODO: which?). The basic idea is
    // to take a file we've just processed, and add all of the files which that
    // file references (via imports, augmentation imports, exports, and parts),
    // and add them to the set of files to be processed.
    //
    // This loop may execute a few times. We know to stop looping when we have
    // added zero new files to process. This is tracked with `filesInLastPass`
    // and `filesInCurrentPass`.
    var filesInLastPass = <String>{};
    var filesInCurrentPass = <String>{};
    var processedFiles = <String>{};
    // When the loop discovers new files in a new package, it does extra work to
    // find all documentable files in that package, for the universal reference
    // scope. This variable tracks which packages we've seen so far.
    var knownPackages = <PackageMeta>{};
    progressBarStart(files.length);

    // The set of files that are discovered while iterating in the below
    // do-while loop, which are then added to `files`, as they are found.
    var newFiles = <String>{};
    do {
      filesInLastPass = filesInCurrentPass;
      progressBarUpdateTickCount(files.length);

      // Be careful here, not to accidentally stack up multiple
      // [DartDocResolvedLibrary]s, as those eat our heap.
      var libraryFiles = files.difference(_knownParts);

      for (var file in libraryFiles) {
        if (processedFiles.contains(file)) {
          continue;
        }
        processedFiles.add(file);
        progressBarTick();

        var resolvedLibrary = await _resolveLibrary(file);
        if (resolvedLibrary == null) {
          // `file` did not resolve to a _library_; could be a part, an
          // augmentation, or some other invalid result.
          _knownParts.add(file);
          continue;
        }
        newFiles.addFilesReferencedBy(resolvedLibrary.element);
        for (var unit in resolvedLibrary.units) {
          newFiles.addFilesReferencedBy(unit.declaredElement);
        }
        if (processedLibraries.contains(resolvedLibrary.element)) {
          continue;
        }
        uninitializedPackageGraph.addLibraryToGraph(resolvedLibrary);
        processedLibraries.add(resolvedLibrary.element);
      }
      files.addAll(newFiles);
      var externals = _includedExternalsFrom(newFiles);
      if (externals.isNotEmpty) {
        includeExternalsWasSpecified = true;
      }
      files.addAll(externals);

      var packages = _packageMetasForFiles(files.difference(_knownParts));
      filesInCurrentPass = {...files.difference(_knownParts)};

      // To get canonicalization correct for non-locally documented packages
      // (so we can generate the right hyperlinks), it's vital that we add all
      // libraries in dependent packages. So if the analyzer discovers some
      // files in a package we haven't seen yet, add files for that package.
      for (var packageMeta in packages.difference(knownPackages)) {
        if (packageMeta.isSdk) {
          if (!_skipUnreachableSdkLibraries) {
            files.addAll(_sdkFilesToDocument);
          }
        } else {
          files.addAll(_findFilesToDocumentInPackage({packageMeta.dir.path}));
        }
      }
      knownPackages.addAll(packages);
    } while (!filesInLastPass.containsAll(filesInCurrentPass));
    progressBarComplete();
  }

  /// Returns all top level library files in the 'lib/' directory of the given
  /// package root directory.
  List<String> _findFilesToDocumentInPackage(Set<String> packageRoots) {
    var sep = _pathContext.separator;
    var packagesWithSeparators = '${sep}packages$sep';
    var filesToDocument = <String>[];
    for (var packageRoot in packageRoots) {
      var packageLibDir = _pathContext.join(packageRoot, 'lib');
      var packageLibSrcDir = _pathContext.join(packageLibDir, 'src');
      var packageDirContainsPackages =
          packageRoot.contains(packagesWithSeparators);
      // To avoid analyzing package files twice, only files with paths not
      // containing '/packages/' will be added. The only exception is if the
      // file to analyze already has a '/packages/' in its path.
      for (var filePath in _listDir(packageRoot, const {})) {
        if (!filePath.endsWith('.dart')) continue;
        if (!packageDirContainsPackages &&
            filePath.contains(packagesWithSeparators)) {
          // The package's directory path does not contain '/packages/' and this
          // file's path _does_, so it should not be included.
          continue;
        }

        // Only include libraries within the lib dir that are not in 'lib/src'.
        if (!_pathContext.isWithin(packageLibDir, filePath) ||
            _pathContext.isWithin(packageLibSrcDir, filePath)) {
          continue;
        }

        filesToDocument.add(filePath);
      }
    }
    return filesToDocument;
  }

  /// Lists the files in [directory].
  ///
  /// Excludes files and directories beginning with `.`.
  ///
  /// The returned paths are guaranteed to begin with [directory].
  List<String> _listDir(String directory, Set<String> listedDirectories) {
    // Avoid recursive symlinks.
    var resolvedPath =
        _resourceProvider.getFolder(directory).resolveSymbolicLinksSync().path;
    if (listedDirectories.contains(resolvedPath)) {
      return const [];
    }

    listedDirectories = {
      ...listedDirectories,
      resolvedPath,
    };

    var dirs = <String>[];

    for (var resource
        in _packageDirList(_resourceProvider.getFolder(directory))) {
      // Skip hidden files and directories.
      if (_pathContext.basename(resource.path).startsWith('.')) {
        continue;
      }

      if (resource is File) {
        dirs.add(resource.path);
        continue;
      }
      if (resource is Folder) {
        dirs.addAll(_listDir(resource.path, listedDirectories));
      }
    }

    return dirs;
  }

  /// Calculates 'includeExternal' based on a list of files.
  ///
  /// Assumes each file might be part of a [DartdocOptionContext], and loads
  /// those objects to find any [DartdocOptionContext.includeExternal]
  /// configurations therein.
  List<String> _includedExternalsFrom(Iterable<String> files) => [
        for (var file in files)
          ...DartdocOptionContext.fromContext(
            _config,
            _config.resourceProvider.getFile(file),
            _config.resourceProvider,
          ).includeExternal,
      ];

  /// Returns the set of files that may contain elements that need to be
  /// documented.
  ///
  /// This takes into account the 'auto-include-dependencies' option, the
  /// 'exclude' option, and the 'include-external' option.
  Future<Set<String>> _getFilesToDocument() async {
    if (_config.topLevelPackageMeta.isSdk) {
      return _sdkFilesToDocument
          .map((s) => _pathContext.absolute(_resourceProvider.getFile(s).path))
          .toSet();
    } else {
      var packagesToDocument = await _findPackagesToDocument(
        _config.inputDir,
      );
      var files = _findFilesToDocumentInPackage(packagesToDocument).toList();
      var externals = _includedExternalsFrom(files);
      if (externals.isNotEmpty) {
        includeExternalsWasSpecified = true;
        files = [...files, ...externals];
      }
      return {
        ...files.map(
            (s) => _pathContext.absolute(_resourceProvider.getFile(s).path)),
        ..._embedderSdkFiles,
      };
    }
  }

  /// Returns a set of package roots that are to be documented.
  ///
  /// If `_config.autoIncludeDependencies` is `true`, then every package in
  /// [basePackageRoot]'s package config is included.
  Future<Set<String>> _findPackagesToDocument(String basePackageRoot) async {
    if (!_config.autoIncludeDependencies) {
      return {basePackageRoot};
    }

    var packageConfig = (await _packageConfigProvider
        .findPackageConfig(_resourceProvider.getFolder(basePackageRoot)))!;
    return {
      basePackageRoot,
      for (var package in packageConfig.packages)
        if (!_config.exclude.contains(package.name))
          _pathContext.dirname(_pathContext
              .fromUri(packageConfig[package.name]!.packageUriRoot)),
    };
  }

  @override
  bool includeExternalsWasSpecified = false;

  Iterable<String> get _embedderSdkFiles => [
        for (var dartUri in _embedderSdkUris)
          _pathContext.absolute(_resourceProvider
              .getFile(_embedderSdk!.mapDartUri(dartUri)!.fullName)
              .path),
      ];

  Iterable<String> get _embedderSdkUris {
    if (_config.topLevelPackageMeta.isSdk) return const [];

    return _embedderSdk?.urlMappings.keys ?? const [];
  }

  /// Adds all libraries with documentable elements to
  /// [uninitializedPackageGraph].
  Future<void> _getLibraries(PackageGraph uninitializedPackageGraph) async {
    var files = await _getFilesToDocument();

    logInfo('Discovering libraries...');
    var foundLibraries = <LibraryElement>{};
    await _discoverLibraries(
      uninitializedPackageGraph,
      foundLibraries,
      files,
    );
    _checkForMissingIncludedFiles(foundLibraries);
    uninitializedPackageGraph.allLibrariesAdded = true;
  }

  /// Throws an exception if any configured-to-be-included files were not found
  /// while gathering libraries.
  void _checkForMissingIncludedFiles(Set<LibraryElement> foundLibraries) {
    if (_config.include.isNotEmpty) {
      var knownLibraryNames = foundLibraries.map((l) => l.name);
      var notFound = _config.include
          .difference(Set.of(knownLibraryNames))
          .difference(_config.exclude);
      if (notFound.isNotEmpty) {
        throw StateError('Did not find: [${notFound.join(', ')}] in '
            'known libraries: [${knownLibraryNames.join(', ')}]');
      }
    }
  }

  /// Returns the children of [directory], or returns only the 'lib/'
  /// directory in [directory] if [directory] is determined to be a package
  /// root.
  ///
  /// This ensures that packages don't have non-`lib` content documented.
  static List<Resource> _packageDirList(Folder directory) {
    var resources = directory.getChildren();
    var pubspec = directory.getChild('pubspec.yaml');
    var libDirectory = directory.getChild('lib');

    return [
      if (pubspec is File && libDirectory is Folder)
        libDirectory
      else
        ...resources
    ];
  }
}

/// Contains the [ResolvedLibraryResult] and any additional information about
/// the library.
class DartDocResolvedLibrary {
  final LibraryElement element;
  final List<CompilationUnit> units;

  DartDocResolvedLibrary(ResolvedLibraryResult result)
      : element = result.element,
        units = result.units.map((unit) => unit.unit).toList();
}

extension on Set<String> {
  /// Adds [element]'s path and all of its part files' paths to `this`, and
  /// recursively adds the paths of all imported and exported libraries.
  ///
  /// [element] must be a [LibraryElement] or [CompilationUnitElement].
  void addFilesReferencedBy(Element? element) {
    if (element == null) return;

    var path = element.source?.fullName;
    if (path == null) return;

    if (add(path)) {
      var libraryImports = switch (element) {
        LibraryElement() => element.definingCompilationUnit.libraryImports,
        CompilationUnitElement(:var libraryImports) => libraryImports,
        _ => const <LibraryImportElement>[],
      };
      for (var import in libraryImports) {
        addFilesReferencedBy(import.importedLibrary);
      }

      var libraryExports = switch (element) {
        LibraryElement() => element.definingCompilationUnit.libraryExports,
        CompilationUnitElement(:var libraryExports) => libraryExports,
        _ => const <LibraryExportElement>[],
      };
      for (var export in libraryExports) {
        addFilesReferencedBy(export.exportedLibrary);
      }
      if (element is LibraryElement) {
        for (var unit in element.units) {
          addFilesReferencedBy(unit);
        }
      }
    }
  }
}
