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
import 'package:analyzer/src/dart/ast/utilities.dart' show NodeLocator2;
// ignore: implementation_imports
import 'package:analyzer/src/dart/sdk/sdk.dart'
    show EmbedderSdk, FolderBasedDartSdk;
// ignore: implementation_imports
import 'package:analyzer/src/generated/engine.dart' show AnalysisOptionsImpl;
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk;
import 'package:collection/collection.dart' show IterableExtension;
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
          ..hint = false
          ..lint = false,
  );

  /// Returns an Iterable with the SDK files we should parse.
  Iterable<String> _getSdkFilesToDocument() sync* {
    for (var sdkLib in sdk.sdkLibraries) {
      var source = sdk.mapDartUri(sdkLib.shortName)!;
      yield source.fullName;
    }
  }

  /// Parse a single library at [filePath] using the current analysis driver.
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
      // (so we can generate the right hyperlinks), it's vital that we
      // add all libraries in dependent packages.  So if the analyzer
      // discovers some files in a package we haven't seen yet, add files
      // for that package.
      for (var meta in current.difference(lastPass)) {
        if (meta.isSdk) {
          if (!_skipUnreachableSdkLibraries) {
            files.addAll(_getSdkFilesToDocument());
          }
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
      {required bool autoIncludeDependencies,
      bool filterExcludes = true}) async* {
    var packageDirs = {basePackageDir};

    if (autoIncludeDependencies) {
      var info = (await packageConfigProvider
          .findPackageConfig(resourceProvider.getFolder(basePackageDir)))!;
      for (var package in info.packages) {
        if (!filterExcludes || !config.exclude.contains(package.name)) {
          packageDirs.add(_pathContext.dirname(
              _pathContext.fromUri(info[package.name]!.packageUriRoot)));
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
      for (var lib
          in _listDir(packageDir, recursive: true, listDir: _packageDirList)) {
        if (lib.endsWith('.dart') &&
            (packageDirContainsPackages ||
                !lib.contains(packagesWithSeparators))) {
          // Only include libraries within the lib dir that are not in
          // 'lib/src'.
          if (_pathContext.isWithin(packageLibDir, lib) &&
              !_pathContext.isWithin(packageLibSrcDir, lib)) {
            // Only add the file if it does not contain 'part of'.
            // TODO(srawlins): I worry that the cure is worse than the disease:
            // A very small percentage of files should be part files (citation
            // missing), but we pay a price here of reading all files into
            // memory, scanning them for a substring, and then dropping the
            // contents.
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
      Iterable<Resource> Function(Folder dir)? listDir}) {
    listDir ??= (Folder dir) => dir.getChildren();

    return _doList(dir, const <String>{}, recursive, listDir);
  }

  Iterable<String> _doList(String dir, Set<String> listedDirectories,
      bool recurse, Iterable<Resource> Function(Folder dir) listDir) sync* {
    // Avoid recursive symlinks.
    var resolvedPath =
        resourceProvider.getFolder(dir).resolveSymbolicLinksSync().path;
    if (!listedDirectories.contains(resolvedPath)) {
      listedDirectories = {
        ...listedDirectories,
        resolvedPath,
      };

      for (var resource in listDir(resourceProvider.getFolder(dir))) {
        // Skip hidden files and directories
        if (_pathContext.basename(resource.path).startsWith('.')) {
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
      yield* fileContext.includeExternal;
    }
  }

  Future<Set<String>> _getFiles() async {
    var files = config.topLevelPackageMeta.isSdk
        ? _getSdkFilesToDocument()
        : await findFilesToDocumentInPackage(config.inputDir,
                autoIncludeDependencies: config.autoIncludeDependencies)
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
    DartSdk findSpecialsSdk;
    var embedderSdk = this.embedderSdk;
    if (embedderSdk != null && embedderSdk.urlMappings.isNotEmpty) {
      findSpecialsSdk = embedderSdk;
    } else {
      findSpecialsSdk = sdk;
    }
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

  /// If [dir] contains both a `lib` directory and a `pubspec.yaml` file treat
  /// it like a package and only return the `lib` dir.
  ///
  /// This ensures that packages don't have non-`lib` content documented.
  static Iterable<Resource> _packageDirList(Folder dir) sync* {
    var resources = dir.getChildren();
    var pathContext = dir.provider.pathContext;

    var pubspec = resources.firstWhereOrNull(
        (e) => e is File && pathContext.basename(e.path) == 'pubspec.yaml');

    var libDir = resources.firstWhereOrNull(
        (e) => e is Folder && pathContext.basename(e.path) == 'lib');

    if (pubspec != null && libDir != null) {
      yield libDir;
    } else {
      yield* resources;
    }
  }
}

/// Contains the [ResolvedLibraryResult] and any additional information about
/// the library.
class DartDocResolvedLibrary {
  final LibraryElement element;
  final Map<String, CompilationUnit> _units;

  DartDocResolvedLibrary(ResolvedLibraryResult result)
      : element = result.element,
        _units = {
          for (var unit in result.units) unit.path: unit.unit,
        };

  /// Returns the [AstNode] for a given [Element].
  ///
  /// Uses a precomputed map of `element.source.fullName` to [CompilationUnit]
  /// to avoid linear traversal in
  /// [ResolvedLibraryElementImpl.getElementDeclaration].
  AstNode? getAstNode(Element element) {
    var fullName = element.source?.fullName;
    if (fullName != null && !element.isSynthetic && element.nameOffset != -1) {
      var unit = _units[fullName];
      if (unit != null) {
        var locator = NodeLocator2(element.nameOffset);
        var node = locator.searchWithin(unit);
        if (node is SimpleIdentifier) {
          // TODO(scheglov) Remove this branch after the breaking change for
          // the analyzer, when we start returning the declaring node, not
          // the name, which will be just a `Token`.
          return node.parent;
        } else {
          return node;
        }
      }
    }
    return null;
  }
}
