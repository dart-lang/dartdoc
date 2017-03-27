// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
library dartdoc;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart' as fileSystem;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/embedder.dart' show EmbedderUriResolver;
import 'package:analyzer/source/package_map_resolver.dart';
import 'package:analyzer/source/sdk_ext.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:package_config/discovery.dart' as package_config;
import 'package:path/path.dart' as path;

import 'src/config.dart';
import 'src/generator.dart';
import 'src/html/html_generator.dart';
import 'src/io_utils.dart';
import 'src/model.dart';
import 'src/model_utils.dart';
import 'src/package_meta.dart';

export 'src/element_type.dart';
export 'src/generator.dart';
export 'src/model.dart';
export 'src/package_meta.dart';

const String name = 'dartdoc';
// Update when pubspec version changes.
const String version = '0.9.13';

final String defaultOutDir = path.join('doc', 'api');

/// Initialize and setup the generators.
Future<List<Generator>> initGenerators(String url, List<String> headerFilePaths,
    List<String> footerFilePaths, String relCanonicalPrefix,
    {String faviconPath, bool useCategories: false}) async {
  return [
    await HtmlGenerator.create(
        url: url,
        headers: headerFilePaths,
        footers: footerFilePaths,
        relCanonicalPrefix: relCanonicalPrefix,
        toolVersion: version,
        faviconPath: faviconPath,
        useCategories: useCategories)
  ];
}

/// Configure the dartdoc generation process
void initializeConfig(
    {Directory inputDir,
    String sdkVersion,
    bool showWarnings: false,
    bool addCrossdart: false,
    String examplePathPrefix,
    bool includeSource: true,
    bool autoIncludeDependencies: false}) {
  setConfig(
      inputDir: inputDir,
      sdkVersion: sdkVersion,
      showWarnings: showWarnings,
      addCrossdart: addCrossdart,
      examplePathPrefix: examplePathPrefix,
      includeSource: includeSource,
      autoIncludeDependencies: autoIncludeDependencies);
}

Map<String, List<fileSystem.Folder>> _calculatePackageMap(
    fileSystem.Folder dir) {
  Map<String, List<fileSystem.Folder>> map = new Map();
  var info = package_config.findPackagesFromFile(dir.toUri());

  for (String name in info.packages) {
    Uri uri = info.asMap()[name];
    fileSystem.Resource resource =
        PhysicalResourceProvider.INSTANCE.getResource(uri.toFilePath());
    if (resource is fileSystem.Folder) {
      map[name] = [resource];
    }
  }

  return map;
}

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc {
  final Directory rootDir;
  final Directory sdkDir;
  final List<Generator> generators;
  final Directory outputDir;
  final PackageMeta packageMeta;
  final List<String> includes;
  final List<String> includeExternals;
  final List<String> excludes;

  Stopwatch _stopwatch;

  DartDoc(this.rootDir, this.excludes, this.sdkDir, this.generators,
      this.outputDir, this.packageMeta, this.includes,
      {this.includeExternals: const []});

  /// Generate DartDoc documentation.
  ///
  /// [DartDocResults] is returned if dartdoc succeeds. [DartDocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// anaysis error in the code. Any other exception can be throw if there is an
  /// unexpected failure.
  Future<DartDocResults> generateDocs() async {
    _stopwatch = new Stopwatch()..start();

    List<String> files = packageMeta.isSdk
        ? const []
        : findFilesToDocumentInPackage(rootDir.path).toList();

    List<LibraryElement> libraries = _parseLibraries(files, includeExternals);

    if (includes != null && includes.isNotEmpty) {
      Iterable knownLibraryNames = libraries.map((l) => l.name);
      Set notFound =
          new Set.from(includes).difference(new Set.from(knownLibraryNames));
      if (notFound.isNotEmpty) {
        throw 'Did not find: [${notFound.join(', ')}] in '
            'known libraries: [${knownLibraryNames.join(', ')}]';
      }
      libraries.removeWhere((lib) => !includes.contains(lib.name));
    } else {
      // remove excluded libraries
      excludes.forEach((pattern) {
        libraries.removeWhere((lib) {
          return lib.name.startsWith(pattern) || lib.name == pattern;
        });
      });
    }

    if (includes.isNotEmpty || excludes.isNotEmpty) {
      print('generating docs for libraries ${libraries.join(', ')}\n');
    }

    Package package = new Package(libraries, packageMeta);

    if (config != null && config.autoIncludeDependencies) {
      final newLibraryElements =
          _buildLibrariesWithAutoincludedDependencies(package);
      Library.clearLibraryMap();
      package = new Package(newLibraryElements, packageMeta);
    }

    // Go through docs of every model element in package to prebuild the macros index
    package.allModelElements.forEach((m) => m.documentation);

    // Create the out directory.
    if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

    for (var generator in generators) {
      await generator.generate(package, outputDir);
    }

    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print(
        "\nDocumented ${libraries.length} librar${libraries.length == 1 ? 'y' : 'ies'} "
        "in ${seconds.toStringAsFixed(1)} seconds.");

    if (libraries.isEmpty) {
      print(
          "\ndartdoc could not find any libraries to document. Run `pub get` and try again.");
    }

    return new DartDocResults(packageMeta, package, outputDir);
  }

  List<LibraryElement> _parseLibraries(
      List<String> files, List<String> includeExternals) {
    List<LibraryElement> libraries = [];
    DartSdk sdk = new FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
        PhysicalResourceProvider.INSTANCE.getFolder(sdkDir.path));
    List<UriResolver> resolvers = [];

    fileSystem.Folder cwd =
        PhysicalResourceProvider.INSTANCE.getResource(rootDir.path);
    Map<String, List<fileSystem.Folder>> packageMap = _calculatePackageMap(cwd);
    EmbedderUriResolver embedderUriResolver;
    if (packageMap != null) {
      resolvers.add(new SdkExtUriResolver(packageMap));
      resolvers.add(new PackageMapUriResolver(
          PhysicalResourceProvider.INSTANCE, packageMap));

      var embedderYamls = new EmbedderYamlLocator(packageMap).embedderYamls;
      embedderUriResolver = new EmbedderUriResolver(embedderYamls);
      if (embedderUriResolver.length == 0) {
        // The embedder uri resolver has no mappings. Use the default Dart SDK
        // uri resolver.
        resolvers.add(new DartUriResolver(sdk));
      } else {
        // The embedder uri resolver has mappings, use it instead of the default
        // Dart SDK uri resolver.
        resolvers.add(embedderUriResolver);
      }
    } else {
      resolvers.add(new DartUriResolver(sdk));
    }
    resolvers.add(
        new fileSystem.ResourceUriResolver(PhysicalResourceProvider.INSTANCE));

    SourceFactory sourceFactory = new SourceFactory(resolvers);

    var options = new AnalysisOptionsImpl();
    options.enableGenericMethods = true;

    AnalysisEngine.instance.processRequiredPlugins();

    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = sourceFactory;

    if (packageMeta.isSdk) {
      libraries
          .addAll(new Set()..addAll(getSdkLibrariesToDocument(sdk, context)));
    }

    List<Source> sources = [];

    void processLibrary(String filePath) {
      String name = filePath;
      if (name.startsWith(Directory.current.path)) {
        name = name.substring(Directory.current.path.length);
        if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
      }
      print('parsing ${name}...');
      JavaFile javaFile = new JavaFile(filePath).getAbsoluteFile();
      Source source = new FileBasedSource(javaFile);
      Uri uri = context.sourceFactory.restoreUri(source);
      if (uri != null) {
        source = new FileBasedSource(javaFile, uri);
      }
      sources.add(source);
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        libraries.add(library);
      }
    }

    files.forEach(processLibrary);

    if ((embedderUriResolver != null) && (embedderUriResolver.length > 0)) {
      embedderUriResolver.dartSdk.uris.forEach((String dartUri) {
        Source source = embedderUriResolver.dartSdk.mapDartUri(dartUri);
        processLibrary(source.fullName);
      });
    }

    // Ensure that the analysis engine performs all remaining work.
    AnalysisResult result = context.performAnalysisTask();
    while (result.hasMoreWork) {
      result = context.performAnalysisTask();
    }

    // Use the includeExternals.
    for (Source source in context.librarySources) {
      LibraryElement library = context.computeLibraryElement(source);
      String libraryName = Library.getLibraryName(library);
      var fullPath = source.fullName;
      if (includeExternals.any((string) => fullPath.endsWith(string))) {
        if (libraries.map(Library.getLibraryName).contains(libraryName)) {
          continue;
        }
        libraries.add(library);
      }
    }

    List<AnalysisErrorInfo> errorInfos = [];

    for (Source source in sources) {
      context.computeErrors(source);
      errorInfos.add(context.getErrors(source));
    }

    List<_Error> errors = errorInfos
        .expand((AnalysisErrorInfo info) {
          return info.errors.map((error) =>
              new _Error(error, info.lineInfo, packageMeta.dir.path));
        })
        .where((_Error error) => error.isError)
        .toList()
          ..sort();

    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print("Parsed ${libraries.length} "
        "file${libraries.length == 1 ? '' : 's'} in "
        "${seconds.toStringAsFixed(1)} seconds.\n");

    if (errors.isNotEmpty) {
      errors.forEach(print);
      int len = errors.length;
      throw new DartDocFailure(
          "encountered ${len} analysis error${len == 1 ? '' : 's'}");
    }

    return libraries.toList();
  }
}

/// This class is returned if dartdoc fails in an expected way (for instance, if
/// there is an analysis error in the library).
class DartDocFailure {
  final String message;

  DartDocFailure(this.message);

  @override
  String toString() => message;
}

/// The results of a [DartDoc.generateDocs] call.
class DartDocResults {
  final PackageMeta packageMeta;
  final Package package;
  final Directory outDir;

  DartDocResults(this.packageMeta, this.package, this.outDir);
}

class _Error implements Comparable<_Error> {
  final AnalysisError error;
  final LineInfo lineInfo;
  final String projectPath;

  _Error(this.error, this.lineInfo, this.projectPath);

  String get description => '${error.message} at ${location}, line ${line}.';
  bool get isError => error.errorCode.errorSeverity == ErrorSeverity.ERROR;
  int get line => lineInfo.getLocation(error.offset).lineNumber;
  String get location {
    String path = error.source.fullName;
    if (path.startsWith(projectPath)) {
      path = path.substring(projectPath.length + 1);
    }
    return path;
  }

  int get severity => error.errorCode.errorSeverity.ordinal;

  String get severityName => error.errorCode.errorSeverity.displayName;

  @override
  int compareTo(_Error other) {
    if (severity == other.severity) {
      int cmp = error.source.fullName.compareTo(other.error.source.fullName);
      return cmp == 0 ? line - other.line : cmp;
    } else {
      return other.severity - severity;
    }
  }

  @override
  String toString() => '[${severityName}] ${description}';
}

Iterable<LibraryElement> _buildLibrariesWithAutoincludedDependencies(
    Package package) {
  final List<LibraryElement> newLibraryElements = []
    ..addAll(package.libraries.map((l) => l.element as LibraryElement));

  package.allModelElements.forEach((modelElement) {
    modelElement.usedElements.forEach((used) {
      if (used != null && used.modelType != null) {
        final ModelElement modelTypeElement = used.modelType.element;
        final library = package.findLibraryFor(modelTypeElement.element);
        if (library == null && modelTypeElement.library != null) {
          if (!newLibraryElements.contains(modelTypeElement.library.element) &&
              !modelTypeElement.library.name.startsWith("dart:")) {
            newLibraryElements.add(modelTypeElement.library.element);
          }
        }
      }
    });
  });

  return newLibraryElements;
}
