// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
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
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;

/// Everything you need to instantiate a PackageGraph object for documenting.
abstract class PackageBuilder {
  // Builds package graph to be used by documentation generator.
  Future<PackageGraph> buildPackageGraph();
}

/// A package builder that understands pub package format.
class PubPackageBuilder implements PackageBuilder {
  final DartdocOptionContext config;
  final Set<String> _knownFiles = {};
  final PackageMetaProvider packageMetaProvider;
  final PackageConfigProvider packageConfigProvider;

  PubPackageBuilder(
    this.config,
    this.packageMetaProvider,
    this.packageConfigProvider, {
    @visibleForTesting bool skipUnreachableSdkLibraries = false,
  }) : _skipUnreachableSdkLibraries = skipUnreachableSdkLibraries;

  @override
  Future<PackageGraph> buildPackageGraph() async {
    if (!config.sdkDocs) {
      if (config.topLevelPackageMeta.requiresFlutter &&
          config.flutterRoot == null) {
        // TODO(devoncarew): We may no longer need to emit this error.
        throw DartdocOptionError(
            'Top level package requires Flutter but FLUTTER_ROOT environment variable not set');
      }
    }

    var rendererFactory = RendererFactory.forFormat(config.format);

    runtimeStats.startPerfTask('_calculatePackageMap');
    await _calculatePackageMap();
    runtimeStats.endPerfTask();

    runtimeStats.startPerfTask('getLibraries');
    var newGraph = PackageGraph.uninitialized(
      config,
      sdk,
      hasEmbedderSdkFiles,
      rendererFactory,
      packageMetaProvider,
    );
    await getLibraries(newGraph);
    runtimeStats.endPerfTask();

    runtimeStats.startPerfTask('initializePackageGraph');
    await newGraph.initializePackageGraph();
    runtimeStats.endPerfTask();

    runtimeStats.startPerfTask('initializeCategories');
    newGraph.initializeCategories();
    runtimeStats.endPerfTask();

    return newGraph;
  }

  late final DartSdk sdk = packageMetaProvider.defaultSdk ??
      FolderBasedDartSdk(
          resourceProvider, resourceProvider.getFolder(config.sdkDir));

  EmbedderSdk? _embedderSdk;

  EmbedderSdk? get embedderSdk {
    if (_embedderSdk == null && !config.topLevelPackageMeta.isSdk) {
      _embedderSdk = EmbedderSdk(
          resourceProvider, EmbedderYamlLocator(_packageMap).embedderYamls);
    }
    return _embedderSdk;
  }

  ResourceProvider get resourceProvider => packageMetaProvider.resourceProvider;

  p.Context get pathContext => resourceProvider.pathContext;

  /// Do not call more than once for a given PackageBuilder.
  Future<void> _calculatePackageMap() async {
    _packageMap = <String, List<Folder>>{};
    var cwd = resourceProvider.getResource(config.inputDir) as Folder;
    var info = await packageConfigProvider
        .findPackageConfig(resourceProvider.getFolder(cwd.path));
    if (info == null) return;

    for (var package in info.packages) {
      var packagePath =
          pathContext.normalize(pathContext.fromUri(package.packageUriRoot));
      var resource = resourceProvider.getResource(packagePath);
      if (resource is Folder) {
        _packageMap[package.name] = [resource];
      }
    }
  }

  late final Map<String, List<Folder>> _packageMap;

  late final AnalysisContextCollection _contextCollection =
      AnalysisContextCollectionImpl(
    includedPaths: [config.inputDir],
    // TODO(jcollins-g): should we pass excluded directories here instead of
    // handling it ourselves?
    resourceProvider: resourceProvider,
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

  /// The SDK files we should parse.
  List<String> get _sdkFilesToDocument => [
        for (var sdkLib in sdk.sdkLibraries)
          sdk.mapDartUri(sdkLib.shortName)!.fullName,
      ];

  /// Parses a single library at [filePath] using the current analysis driver.
  /// If [filePath] is not a library, returns null.
  Future<DartDocResolvedLibrary?> processLibrary(String filePath) async {
    logDebug('Resolving $filePath...');

    var analysisContext = _contextCollection.contextFor(config.inputDir);
    // Allow dart source files with inappropriate suffixes (#1897).
    final library =
        await analysisContext.currentSession.getResolvedLibrary(filePath);
    if (library is ResolvedLibraryResult) {
      return DartDocResolvedLibrary(library);
    }
    return null;
  }

  Set<PackageMeta> _packageMetasForFiles(Iterable<String> files) => {
        for (var filename in files) packageMetaProvider.fromFilename(filename)!,
      };

  /// Adds [element]'s path and all of its part files' paths to [_knownFiles],
  /// and recursively adds the paths of all imported and exported libraries.
  void _addKnownFiles(LibraryElement? element) {
    if (element != null) {
      var path = element.source.fullName;
      if (_knownFiles.add(path)) {
        for (var import in element.libraryImports) {
          _addKnownFiles(import.importedLibrary);
        }
        for (var export in element.libraryExports) {
          _addKnownFiles(export.exportedLibrary);
        }
        for (var part in element.parts
            .map((e) => e.uri)
            .whereType<DirectiveUriWithUnit>()) {
          _knownFiles.add(part.source.fullName);
        }
      }
    }
  }

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

  /// Parses libraries with the analyzer and invokes [addLibrary] with each
  /// result.
  ///
  /// Uses [processedLibraries] to prevent calling the callback more than once
  /// with the same [LibraryElement]. Adds each [LibraryElement] found to
  /// [processedLibraries].
  Future<void> _parseLibraries(
    void Function(DartDocResolvedLibrary) addLibrary,
    Set<LibraryElement> processedLibraries,
    Set<String> files, {
    bool Function(LibraryElement)? isLibraryIncluded,
  }) async {
    files = {...files};
    isLibraryIncluded ??= (_) => true;
    var lastPass = <PackageMeta>{};
    var current = <PackageMeta>{};
    var processedFiles = <String>{};
    do {
      lastPass = current;

      // Be careful here; not to accidentally stack up multiple
      // [DartDocResolvedLibrary]s, as those eat our heap.
      var libraryFiles = files.difference(_knownParts);
      for (var file in libraryFiles) {
        if (processedFiles.contains(file)) {
          continue;
        }
        processedFiles.add(file);
        logProgress(file);
        var resolvedLibrary = await processLibrary(file);
        if (resolvedLibrary == null) {
          _knownParts.add(file);
          continue;
        }
        _addKnownFiles(resolvedLibrary.element);
        if (!processedLibraries.contains(resolvedLibrary.element) &&
            isLibraryIncluded(resolvedLibrary.element)) {
          addLibrary(resolvedLibrary);
          processedLibraries.add(resolvedLibrary.element);
        }
      }

      files.addAll(_knownFiles);
      files.addAll(_includeExternalsFrom(_knownFiles));

      current = _packageMetasForFiles(files.difference(_knownParts));
      // To get canonicalization correct for non-locally documented packages
      // (so we can generate the right hyperlinks), it's vital that we add all
      // libraries in dependent packages.  So if the analyzer discovers some
      // files in a package we haven't seen yet, add files for that package.
      for (var meta in current.difference(lastPass)) {
        if (meta.isSdk) {
          if (!_skipUnreachableSdkLibraries) {
            files.addAll(_sdkFilesToDocument);
          }
        } else {
          files.addAll(await _findFilesToDocumentInPackage(meta.dir.path,
                  includeDependencies: false, filterExcludes: false)
              .toList());
        }
      }
    } while (!lastPass.containsAll(current));
  }

  /// Returns all top level library files in the 'lib/' directory of the given
  /// package root directory.
  ///
  /// If [includeDependencies], then all top level library files in the 'lib/'
  /// directory of every package in [basePackageDir]'s package config are also
  /// included.
  Stream<String> _findFilesToDocumentInPackage(String basePackageDir,
      {required bool includeDependencies, bool filterExcludes = true}) async* {
    var packageDirs = {basePackageDir};

    if (includeDependencies) {
      var packageConfig = (await packageConfigProvider
          .findPackageConfig(resourceProvider.getFolder(basePackageDir)))!;
      for (var package in packageConfig.packages) {
        if (!filterExcludes || !config.exclude.contains(package.name)) {
          packageDirs.add(_pathContext.dirname(_pathContext
              .fromUri(packageConfig[package.name]!.packageUriRoot)));
        }
      }
    }

    var sep = _pathContext.separator;
    var packagesWithSeparators = '${sep}packages$sep';
    for (var packageDir in packageDirs) {
      var packageLibDir = _pathContext.join(packageDir, 'lib');
      var packageLibSrcDir = _pathContext.join(packageLibDir, 'src');
      var packageDirContainsPackages =
          packageDir.contains(packagesWithSeparators);
      // To avoid analyzing package files twice, only files with paths not
      // containing '/packages/' will be added. The only exception is if the
      // file to analyze already has a '/packages/' in its path.
      for (var filePath in _listDir(packageDir, const {})) {
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

        yield filePath;
      }
    }
  }

  /// Lists the files in [directory].
  ///
  /// Excludes files and directories beginning with `.`.
  ///
  /// The returned paths are guaranteed to begin with [directory].
  Iterable<String> _listDir(
      String directory, Set<String> listedDirectories) sync* {
    // Avoid recursive symlinks.
    var resolvedPath =
        resourceProvider.getFolder(directory).resolveSymbolicLinksSync().path;
    if (listedDirectories.contains(resolvedPath)) {
      return;
    }

    listedDirectories = {
      ...listedDirectories,
      resolvedPath,
    };

    for (var resource
        in _packageDirList(resourceProvider.getFolder(directory))) {
      // Skip hidden files and directories.
      if (_pathContext.basename(resource.path).startsWith('.')) {
        continue;
      }

      if (resource is File) {
        yield resource.path;
        continue;
      }
      if (resource is Folder) {
        yield* _listDir(resource.path, listedDirectories);
      }
    }
  }

  /// Calculates 'includeExternal' based on a list of files.
  ///
  /// Assumes each file might be part of a [DartdocOptionContext], and loads
  /// those objects to find any [DartdocOptionContext.includeExternal]
  /// configurations therein.
  List<String> _includeExternalsFrom(Iterable<String> files) => [
        for (var file in files)
          ...DartdocOptionContext.fromContext(
            config,
            config.resourceProvider.getFile(file),
            config.resourceProvider,
          ).includeExternal,
      ];

  Future<Set<String>> _getFiles() async {
    var files = config.topLevelPackageMeta.isSdk
        ? _sdkFilesToDocument
        : await _findFilesToDocumentInPackage(config.inputDir,
                includeDependencies: config.autoIncludeDependencies)
            .toList();
    files = [...files, ..._includeExternalsFrom(files)];
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
            .getFile(embedderSdk!.mapDartUri(dartUri)!.fullName)
            .path),
    ];
  }

  bool get hasEmbedderSdkFiles => _embedderSdkUris.isNotEmpty;

  Iterable<String> get _embedderSdkUris {
    if (config.topLevelPackageMeta.isSdk) return const [];

    return embedderSdk?.urlMappings.keys ?? const [];
  }

  Future<void> getLibraries(PackageGraph uninitializedPackageGraph) async {
    var embedderSdk = this.embedderSdk;
    var findSpecialsSdk = switch (embedderSdk) {
      EmbedderSdk(:var urlMappings) when urlMappings.isNotEmpty => embedderSdk,
      _ => sdk,
    };
    var files = await _getFiles();
    var specialFiles = specialLibraryFiles(findSpecialsSdk);

    var foundLibraries = <LibraryElement>{};
    await _parseLibraries(
      uninitializedPackageGraph.addLibraryToGraph,
      foundLibraries,
      files,
      isLibraryIncluded: (LibraryElement libraryElement) =>
          config.include.isEmpty ||
          config.include.contains(libraryElement.name),
    );
    if (config.include.isNotEmpty) {
      var knownLibraryNames = foundLibraries.map((l) => l.name);
      var notFound = config.include
          .difference(Set.of(knownLibraryNames))
          .difference(config.exclude);
      if (notFound.isNotEmpty) {
        throw StateError('Did not find: [${notFound.join(', ')}] in '
            'known libraries: [${knownLibraryNames.join(', ')}]');
      }
    }
    // Include directive does not apply to special libraries.
    await _parseLibraries(uninitializedPackageGraph.addSpecialLibraryToGraph,
        foundLibraries, specialFiles.difference(files));
  }

  p.Context get _pathContext => resourceProvider.pathContext;

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
