// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/context/builder.dart' show locateEmbedderYamlFor;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollectionImpl;
// ignore: implementation_imports
import 'package:analyzer/src/dart/sdk/sdk.dart'
    show EmbedderSdk, languageVersionFromSdkVersion, FolderBasedDartSdk;
// ignore: implementation_imports
import 'package:analyzer/src/generated/engine.dart' show AnalysisOptionsImpl;
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk;
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart' hide Package;
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart'
    show PackageMeta, PackageMetaProvider;
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;
import 'package:yaml/yaml.dart';

/// Everything you need to instantiate a PackageGraph object for documenting.
abstract class PackageBuilder {
  // Builds package graph to be used by documentation generator.
  Future<PackageGraph> buildPackageGraph();
}

/// A package builder that understands pub package format.
class PubPackageBuilder implements PackageBuilder {
  final DartdocOptionContext _config;
  final PackageMetaProvider _packageMetaProvider;

  final AnalysisContextCollectionImpl _contextCollection;
  final AnalysisContext _analysisContext;

  final DartSdk _sdk;

  final List<String> _embedderSdkFiles;

  factory PubPackageBuilder(
    DartdocOptionContext config,
    PackageMetaProvider packageMetaProvider, {
    @visibleForTesting bool skipUnreachableSdkLibraries = false,
  }) {
    var contextCollection = AnalysisContextCollectionImpl(
      includedPaths: [config.inputDir],
      // TODO(jcollins-g): should we pass excluded directories here instead
      // of handling it ourselves?
      resourceProvider: packageMetaProvider.resourceProvider,
      sdkPath: config.sdkDir,
      updateAnalysisOptions4: ({
        required AnalysisOptionsImpl analysisOptions,
      }) =>
          analysisOptions
            ..warning = false
            ..lint = false,
      withFineDependencies: true,
    );
    var resourceProvider = packageMetaProvider.resourceProvider;
    var sdk = packageMetaProvider.defaultSdk ??
        FolderBasedDartSdk(
            resourceProvider, resourceProvider.getFolder(config.sdkDir));
    var embedderSdkFiles = _findEmbedderSdkFiles(config, resourceProvider);

    return PubPackageBuilder._(
      config,
      packageMetaProvider,
      contextCollection,
      sdk: sdk,
      embedderSdkFiles: embedderSdkFiles,
      analysisContext: contextCollection.contextFor(config.inputDir),
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
  }

  PubPackageBuilder._(
    this._config,
    this._packageMetaProvider,
    this._contextCollection, {
    required DartSdk sdk,
    required List<String> embedderSdkFiles,
    required AnalysisContext analysisContext,
    required bool skipUnreachableSdkLibraries,
  })  : _sdk = sdk,
        _embedderSdkFiles = embedderSdkFiles,
        _analysisContext = analysisContext,
        _skipUnreachableSdkLibraries = skipUnreachableSdkLibraries;

  static List<String> _findEmbedderSdkFiles(
      DartdocOptionContext config, ResourceProvider resourceProvider) {
    if (config.topLevelPackageMeta.isSdk) return const [];

    var cwd = resourceProvider.getResource(config.inputDir) as Folder;
    var info = findPackageConfig(resourceProvider.getFolder(cwd.path));
    if (info == null) return const [];

    var skyEngine =
        info.packages.firstWhereOrNull((p) => p.name == 'sky_engine');
    if (skyEngine == null) return const [];

    var packagePath = resourceProvider.pathContext.normalize(
        resourceProvider.pathContext.fromUri(skyEngine.packageUriRoot));
    var skyEngineLibFolder =
        resourceProvider.getResource(packagePath) as Folder;
    var embedderYaml = locateEmbedderYamlFor(skyEngineLibFolder);
    var embedderSdk = EmbedderSdk.new2(
        resourceProvider, skyEngineLibFolder, embedderYaml,
        languageVersion: languageVersionFromSdkVersion(io.Platform.version));

    return [
      for (var dartUri in embedderSdk.urlMappings.keys)
        resourceProvider.pathContext.absolute(resourceProvider
            .getFile(embedderSdk.mapDartUri(dartUri)!.fullName)
            .path),
    ];
  }

  @override
  Future<PackageGraph> buildPackageGraph() async {
    runtimeStats.resetAccumulators([
      'elementTypeInstantiation',
      'modelElementCacheInsertion',
    ]);

    runtimeStats.startPerfTask('getLibraries');
    var newGraph = PackageGraph.uninitialized(
      _config,
      _sdk,
      _embedderSdkFiles.isNotEmpty,
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
    await _contextCollection.dispose();
  }

  ResourceProvider get _resourceProvider =>
      _packageMetaProvider.resourceProvider;

  p.Context get _pathContext => _resourceProvider.pathContext;

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

  /// Names of packages discovered as workspace members during
  /// [_findWorkspacePackages]. Populated when `workspaceDocs` is enabled.
  ///
  /// Used to mark workspace member packages as "local" in the [PackageGraph].
  final Set<String> _workspacePackageNames = {};

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
          newFiles.addFilesReferencedByFragment(unit.declaredFragment);
        }
        if (processedLibraries.contains(resolvedLibrary.element)) {
          continue;
        }
        uninitializedPackageGraph.addLibraryToGraph(resolvedLibrary);
        processedLibraries.add(resolvedLibrary.element);
      }
      files.addAll(newFiles);

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

  /// Returns the set of files that may contain elements that need to be
  /// documented.
  ///
  /// This takes into account the 'auto-include-dependencies' option, and the
  /// 'exclude' option.
  Future<Set<String>> _getFilesToDocument() async {
    if (_config.topLevelPackageMeta.isSdk) {
      return _sdkFilesToDocument
          .map((s) => _pathContext.absolute(_resourceProvider.getFile(s).path))
          .toSet();
    } else {
      var packagesToDocument = await _findPackagesToDocument(
        _config.inputDir,
      );
      var files = _findFilesToDocumentInPackage(packagesToDocument);
      return {
        ...files.map(
            (s) => _pathContext.absolute(_resourceProvider.getFile(s).path)),
        ..._embedderSdkFiles,
      };
    }
  }

  /// Returns a set of package roots that are to be documented.
  ///
  /// If `_config.workspaceDocs` is `true`, reads the root pubspec.yaml's
  /// `workspace:` key, resolves each entry (including glob patterns) to
  /// package directories, and returns those package roots.
  ///
  /// If `_config.includePackages` is non-empty, filters the package config
  /// to only those package names and returns their roots.
  ///
  /// If `_config.autoIncludeDependencies` is `true`, then every package in
  /// [basePackageRoot]'s package config is included.
  Future<Set<String>> _findPackagesToDocument(String basePackageRoot) async {
    if (_config.workspaceDocs) {
      return _findWorkspacePackages(basePackageRoot);
    }

    if (_config.includePackages.isNotEmpty) {
      return _findIncludedPackages(basePackageRoot);
    }

    if (!_config.autoIncludeDependencies) {
      return {basePackageRoot};
    }

    var packageConfig =
        findPackageConfig(_resourceProvider.getFolder(basePackageRoot))!;
    return {
      basePackageRoot,
      for (var package in packageConfig.packages)
        if (!_config.exclude.contains(package.name))
          _pathContext.dirname(_pathContext
              .fromUri(packageConfig[package.name]!.packageUriRoot)),
    };
  }

  /// Reads the `workspace:` key from the root pubspec.yaml and resolves
  /// each entry (supporting glob patterns) to package directories.
  ///
  /// Returns the set of package root paths for all workspace members.
  Set<String> _findWorkspacePackages(String basePackageRoot) {
    var pubspecFile = _resourceProvider
        .getFile(_pathContext.join(basePackageRoot, 'pubspec.yaml'));
    if (!pubspecFile.exists) {
      logWarning('workspaceDocs enabled but no pubspec.yaml found at '
          '$basePackageRoot');
      return {basePackageRoot};
    }

    var pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
    if (pubspecYaml is! YamlMap) {
      logWarning('workspaceDocs enabled but pubspec.yaml is not a valid '
          'YAML map at $basePackageRoot');
      return {basePackageRoot};
    }

    var workspaceEntries = pubspecYaml['workspace'];
    if (workspaceEntries is! YamlList) {
      logWarning("workspaceDocs enabled but no 'workspace:' key found in "
          'pubspec.yaml at $basePackageRoot');
      return {basePackageRoot};
    }

    var packageRoots = <String>{basePackageRoot};

    for (var entry in workspaceEntries) {
      var pattern = entry.toString();
      var resolvedDirs = _resolveWorkspaceEntry(basePackageRoot, pattern);

      for (var dir in resolvedDirs) {
        var dirPubspec = _resourceProvider
            .getFile(_pathContext.join(dir, 'pubspec.yaml'));
        if (!dirPubspec.exists) {
          logDebug('Workspace entry "$pattern" resolved to "$dir" but no '
              'pubspec.yaml found, skipping.');
          continue;
        }

        var dirName = _readPackageName(dirPubspec);
        if (dirName == null) {
          logDebug('Workspace entry "$pattern" resolved to "$dir" but '
              "pubspec.yaml has no 'name' field, skipping.");
          continue;
        }

        if (_config.isPackageExcluded(dirName)) {
          logDebug('Workspace package "$dirName" excluded by '
              'excludePackages option.');
          continue;
        }

        _workspacePackageNames.add(dirName);
        packageRoots.add(_pathContext.canonicalize(dir));
      }
    }

    return packageRoots;
  }

  /// Resolves a single workspace entry pattern to a list of directory paths.
  ///
  /// If [pattern] contains glob characters (`*`, `?`, `[`, `{`), it is
  /// treated as a glob and matched against the filesystem. Otherwise, it is
  /// treated as a literal relative path.
  List<String> _resolveWorkspaceEntry(String baseRoot, String pattern) {
    var isGlob = pattern.contains('*') ||
        pattern.contains('?') ||
        pattern.contains('[') ||
        pattern.contains('{');

    if (!isGlob) {
      var resolved = _pathContext.normalize(
          _pathContext.join(baseRoot, pattern));
      var folder = _resourceProvider.getFolder(resolved);
      if (folder.exists) {
        return [resolved];
      }
      logDebug('Workspace entry "$pattern" resolved to non-existent '
          'directory "$resolved".');
      return [];
    }

    // Handle glob patterns by expanding the parent directory and matching.
    var glob = Glob(pattern, recursive: false);
    var results = <String>[];
    var baseFolder = _resourceProvider.getFolder(baseRoot);

    // Walk directories matching the glob from the base root.
    _matchGlob(baseFolder, glob, baseRoot, results);
    return results;
  }

  /// Recursively matches [glob] against directories starting from [folder].
  void _matchGlob(
      Folder folder, Glob glob, String baseRoot, List<String> results) {
    for (var child in folder.getChildren()) {
      if (child is Folder) {
        var relativePath = _pathContext.relative(child.path, from: baseRoot);
        if (glob.matches(relativePath)) {
          results.add(child.path);
        }
        // Continue searching subdirectories for patterns like 'packages/adapters/*'
        _matchGlob(child, glob, baseRoot, results);
      }
    }
  }

  /// Reads the `name` field from a pubspec.yaml [file].
  String? _readPackageName(File file) {
    try {
      var yaml = loadYaml(file.readAsStringSync());
      if (yaml is YamlMap) {
        return yaml['name'] as String?;
      }
    } catch (_) {
      // Ignore malformed YAML files.
    }
    return null;
  }

  /// Returns package roots for packages whose names are in
  /// `_config.includePackages`.
  Set<String> _findIncludedPackages(String basePackageRoot) {
    var packageConfig =
        findPackageConfig(_resourceProvider.getFolder(basePackageRoot))!;
    var includeSet = _config.includePackages.toSet();

    var packageRoots = <String>{basePackageRoot};
    for (var package in packageConfig.packages) {
      if (includeSet.contains(package.name) &&
          !_config.isPackageExcluded(package.name)) {
        packageRoots.add(_pathContext.dirname(
            _pathContext.fromUri(packageConfig[package.name]!.packageUriRoot)));
      }
    }

    return packageRoots;
  }

  /// Adds all libraries with documentable elements to
  /// [uninitializedPackageGraph].
  Future<void> _getLibraries(PackageGraph uninitializedPackageGraph) async {
    var files = await _getFilesToDocument();

    // Propagate discovered workspace package names and includePackages
    // to the PackageGraph so Package.isLocal can use them.
    uninitializedPackageGraph.workspacePackageNames
        .addAll(_workspacePackageNames);
    uninitializedPackageGraph.workspacePackageNames
        .addAll(_config.includePackages);

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
  /// [element] must be a [LibraryElement].
  void addFilesReferencedBy(LibraryElement? element) {
    if (element == null) return;

    for (var fragment in element.fragments) {
      addFilesReferencedByFragment(fragment);
    }
  }

  void addFilesReferencedByFragment(LibraryFragment? fragment) {
    if (fragment == null) return;

    var path = fragment.source.fullName;

    if (add(path)) {
      var libraryImports = fragment.libraryImports;
      for (var import in libraryImports) {
        addFilesReferencedBy(import.importedLibrary);
      }
      var libraryExports = fragment.libraryExports;
      for (var export in libraryExports) {
        addFilesReferencedBy(export.exportedLibrary);
      }
    }
  }
}
