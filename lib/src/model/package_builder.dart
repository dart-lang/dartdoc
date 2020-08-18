// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/src/dart/analysis/driver_based_analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart' as file_system;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart'
    show PackageMeta, pubPackageMetaProvider;
import 'package:dartdoc/src/quiver.dart' as quiver;
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:package_config/discovery.dart' as package_config;
import 'package:path/path.dart' as path;

/// Everything you need to instantiate a PackageGraph object for documenting.
abstract class PackageBuilder {
  // Builds package graph to be used by documentation generator.
  Future<PackageGraph> buildPackageGraph();
}

/// A package builder that understands pub package format.
class PubPackageBuilder implements PackageBuilder {
  final DartdocOptionContext config;
  final Set<String> _knownFiles = {};

  PubPackageBuilder(this.config);

  @override
  Future<PackageGraph> buildPackageGraph() async {
    if (!config.sdkDocs) {
      if (config.topLevelPackageMeta.needsPubGet &&
          config.topLevelPackageMeta.requiresFlutter &&
          config.flutterRoot == null) {
        throw DartdocOptionError(
            'Top level package requires Flutter but FLUTTER_ROOT environment variable not set');
      }
      if (config.topLevelPackageMeta.needsPubGet) {
        config.topLevelPackageMeta.runPubGet(config.flutterRoot);
      }
    }

    var rendererFactory = RendererFactory.forFormat(config.format);

    var newGraph = PackageGraph.UninitializedPackageGraph(
      config,
      sdk,
      hasEmbedderSdkFiles,
      rendererFactory,
      pubPackageMetaProvider,
    );
    await getLibraries(newGraph);
    await newGraph.initializePackageGraph();
    return newGraph;
  }

  FolderBasedDartSdk _sdk;

  FolderBasedDartSdk get sdk {
    _sdk ??= FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
        PhysicalResourceProvider.INSTANCE.getFolder(config.sdkDir));
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
    var map = <String, List<file_system.Folder>>{};
    var info = package_config.findPackagesFromFile(dir.toUri());

    for (var name in info.packages) {
      var uri = info.asMap()[name];
      var packagePath = path.normalize(path.fromUri(uri));
      var resource = PhysicalResourceProvider.INSTANCE.getResource(packagePath);
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

  AnalysisContextCollection _contextCollection;

  AnalysisContextCollection get contextCollection {
    _contextCollection ??= AnalysisContextCollection(
      includedPaths: [config.inputDir],
    );
    return _contextCollection;
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

    if (name.startsWith(directoryCurrentPath)) {
      name = name.substring(directoryCurrentPath.length);
      if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
    }
    var javaFile = JavaFile(filePath).getAbsoluteFile();
    Source source = FileBasedSource(javaFile);

    var analysisContext = contextCollection.contextFor(config.inputDir);
    var driver = (analysisContext as DriverBasedAnalysisContext).driver;

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
//      if (!restoredUri.startsWith('dart:')) {
//        restoredUri =
//            driver.sourceFactory.restoreUri(library.element.source).toString();
//      }
      return DartDocResolvedLibrary(library, restoredUri);
    }
    return null;
  }

//  Source _internalResolveUri(
//      List<UriResolver> resolvers, Source containingSource, Uri containedUri) {
//    print('  [resolvers: $resolvers]');
//    if (!containedUri.isAbsolute) {
////      if (containingSource == null) {
//      throw StateError(
//          'Cannot resolve a relative URI without a containing source:'
//          ' $containedUri');
////      }
////      containedUri =
////          utils.resolveRelativeUri(containingSource.uri, containedUri);
//    }
//
//    var actualUri = containedUri;
//
//    for (var resolver in resolvers) {
//      var result = resolver.resolveAbsolute(containedUri, actualUri);
//      print('    [resolver: $resolver][result: $result]');
//      if (result != null) {
//        return result;
//      }
//    }
//    return null;
//  }

  Set<PackageMeta> _packageMetasForFiles(Iterable<String> files) {
    var metas = <PackageMeta>{};
    for (var filename in files) {
      metas.add(pubPackageMetaProvider.fromFilename(filename));
    }
    return metas;
  }

  void _addKnownFiles(LibraryElement element) {
    if (element != null) {
      var path = element.source.fullName;
      if (_knownFiles.add(path)) {
        for (var import in element.imports) {
          _addKnownFiles(import.importedLibrary);
        }
        for (var export in element.exports) {
          _addKnownFiles(export.exportedLibrary);
        }
        for (var part in element.parts) {
          _knownFiles.add(part.source.fullName);
        }
      }
    }
  }

  /// Parse libraries with the analyzer and invoke a callback with the
  /// result.
  ///
  /// Uses the [libraries] parameter to prevent calling
  /// the callback more than once with the same [LibraryElement].
  /// Adds [LibraryElement]s found to that parameter.
  Future<void> _parseLibraries(
      void Function(DartDocResolvedLibrary) libraryAdder,
      Set<LibraryElement> libraries,
      Set<String> files,
      [bool Function(LibraryElement) isLibraryIncluded]) async {
    isLibraryIncluded ??= (_) => true;
    var lastPass = <PackageMeta>{};
    Set<PackageMeta> current;
    do {
      lastPass = _packageMetasForFiles(files);

      // Be careful here not to accidentally stack up multiple
      // DartDocResolvedLibrarys, as those eat our heap.
      for (var f in files) {
        logProgress(f);
        var r = await processLibrary(f);
        if (r != null) {
          _addKnownFiles(r.element);
          if (!libraries.contains(r.element) && isLibraryIncluded(r.element)) {
            logDebug('parsing ${f}...');
            libraryAdder(r);
            libraries.add(r.element);
          }
        }
      }

      files.addAll(_knownFiles);
      files.addAll(_includeExternalsFrom(_knownFiles));

      current = _packageMetasForFiles(files);

      // To get canonicalization correct for non-locally documented packages
      // (so we can generate the right hyperlinks), it's vital that we
      // add all libraries in dependent packages.  So if the analyzer
      // discovers some files in a package we haven't seen yet, add files
      // for that package.
      for (var meta in current.difference(lastPass)) {
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
    var sep = path.separator;

    var packageDirs = {basePackageDir};

    if (autoIncludeDependencies) {
      var info = package_config
          .findPackagesFromFile(
              Uri.file(path.join(basePackageDir, 'pubspec.yaml')))
          .asMap();
      for (var packageName in info.keys) {
        if (!filterExcludes || !config.exclude.contains(packageName)) {
          packageDirs.add(path.dirname(info[packageName].toFilePath()));
        }
      }
    }

    for (var packageDir in packageDirs) {
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

            if (contents.startsWith('part of ') ||
                contents.contains('\npart of ')) {
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
    for (var file in files) {
      var fileContext = DartdocOptionContext.fromContext(config, File(file));
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
    return Set.from(files.map<String>((s) => File(s).absolute.path));
  }

  Iterable<String> getEmbedderSdkFiles() sync* {
    if (embedderSdk != null &&
        embedderSdk.urlMappings.isNotEmpty &&
        !config.topLevelPackageMeta.isSdk) {
      for (var dartUri in embedderSdk.urlMappings.keys) {
        var source = embedderSdk.mapDartUri(dartUri);
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
    var files = getFiles()..addAll(getEmbedderSdkFiles());
    var specialFiles = specialLibraryFiles(findSpecialsSdk).toSet();

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

/// Contains the [ResolvedLibraryResult] and any additional information about
/// the library.
class DartDocResolvedLibrary {
  final ResolvedLibraryResult result;
  final String restoredUri;

  DartDocResolvedLibrary(this.result, this.restoredUri);

  LibraryElement get element => result.element;
  LibraryElement get library => result.element.library;
}
