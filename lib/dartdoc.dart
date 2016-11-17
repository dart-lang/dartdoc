// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
library dartdoc;

import 'dart:async';
import 'dart:io' show Directory, Platform;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
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
const String version = '0.9.7+6';

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
    bool addCrossdart: false,
    bool includeSource: true}) {
  setConfig(
      inputDir: inputDir,
      sdkVersion: sdkVersion,
      addCrossdart: addCrossdart,
      includeSource: includeSource);
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
    ResourceProvider resourceProvider = PhysicalResourceProvider.INSTANCE;
    ContextBuilder builder = new ContextBuilder(
        resourceProvider,
        new DartSdkManager(sdkDir.path, false, (options) {
          DartSdk sdk = new FolderBasedDartSdk(
              PhysicalResourceProvider.INSTANCE,
              PhysicalResourceProvider.INSTANCE.getFolder(sdkDir.path));
          sdk.context.analysisOptions = options;
          return sdk;
        }),
        null);
    AnalysisOptions options = builder.getAnalysisOptions(null, rootDir.path);
    SourceFactory sourceFactory =
        builder.createSourceFactory(rootDir.path, options);
    DartSdk sdk = sourceFactory.dartSdk;

    AnalysisEngine.instance.processRequiredPlugins();

    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = sourceFactory;

    if (packageMeta.isSdk) {
      libraries
          .addAll(new Set()..addAll(getSdkLibrariesToDocument(sdk, context)));
    }

    List<Source> sources = [];

    void processSource(Source source) {
      sources.add(source);
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        libraries.add(library);
      }
    }

    void processLibrary(String filePath) {
      String name = filePath;
      if (name.startsWith(Directory.current.path)) {
        name = name.substring(Directory.current.path.length);
        if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
      }
      print('parsing ${name}...');
      File file = resourceProvider.getFile(filePath);
      Source source = file.createSource();
      Uri uri = context.sourceFactory.restoreUri(source);
      if (uri != null) {
        source = file.createSource(uri);
      }
      processSource(source);
    }

    files.forEach(processLibrary);

    if (sdk is EmbedderSdk) {
      sdk.uris.forEach((String dartUri) {
        Source source = sdk.mapDartUri(dartUri);
        processSource(source);
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
      if (includeExternals.contains(libraryName)) {
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
        .toList()..sort();

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
