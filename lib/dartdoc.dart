// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
library dartdoc;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/error.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'generator.dart';
import 'resource_loader.dart' as loader;
import 'src/html_generator.dart';
import 'src/io_utils.dart';
import 'src/model.dart';
import 'src/model_utils.dart';
import 'src/package_meta.dart';

export 'src/model.dart';
export 'src/package_meta.dart';

const String name = 'dartdoc';
// Update when pubspec version changes.
const String version = '0.1.0+5';

final String defaultOutDir = 'doc${Platform.pathSeparator}api';

/// Initialize and setup the generators.
List<Generator> initGenerators(
    String url, String headerFilePath, String footerFilePath) {
  return [
    new HtmlGenerator(url, header: headerFilePath, footer: footerFilePath)
  ];
}

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc {
  final Directory rootDir;
  final List<String> excludes;
  final Directory sdkDir;
  final List<Generator> generators;
  final Directory outputDir;
  final Directory packageRootDir;
  final PackageMeta packageMeta;
  final Map<String, String> urlMappings;

  final Set<LibraryElement> libraries = new Set();

  Stopwatch _stopwatch;

  DartDoc(this.rootDir, this.excludes, this.sdkDir, this.generators,
      this.outputDir, this.packageRootDir, this.packageMeta, this.urlMappings);

  /// Generate DartDoc documentation.
  ///
  /// [DartDocResults] is returned if dartdoc succeeds. [DartDocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// anaysis error in the code. Any other exception can be throw if there is an
  /// unexpected failure.
  Future<DartDocResults> generateDocs() async {
    _stopwatch = new Stopwatch()..start();

    if (packageRootDir != null) loader.packageRootPath = packageRootDir.path;

    var files =
        packageMeta.isSdk ? [] : findFilesToDocumentInPackage(rootDir.path);

    List<LibraryElement> libs = [];
    libs.addAll(_parseLibraries(files));
    // remove excluded libraries
    excludes.forEach(
        (pattern) => libs.removeWhere((l) => l.name.startsWith(pattern)));
    libs.removeWhere((library) => excludes.contains(library.name));
    libraries.addAll(libs);

    Package package = new Package(libraries, packageMeta);

    // Create the out directory.
    if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

    for (var generator in generators) {
      await generator.generate(package, outputDir);
    }

    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print(
        "Documented ${libraries.length} librar${libraries.length == 1 ? 'y' : 'ies'} "
        "in ${seconds.toStringAsFixed(1)} seconds.");

    return new DartDocResults(packageMeta, package, outputDir);
  }

  List<LibraryElement> _parseLibraries(List<String> files) {
    DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(sdkDir.path));
    List<UriResolver> resolvers = [
      new DartUriResolver(sdk),
      new FileUriResolver()
    ];
    if (urlMappings != null) resolvers.insert(
        0, new CustomUriResolver(urlMappings));
    JavaFile packagesDir = packageRootDir == null
        ? new JavaFile.relative(new JavaFile(rootDir.path), 'packages')
        : new JavaFile(packageRootDir.path);
    if (packagesDir.exists()) {
      resolvers.add(new PackageUriResolver([packagesDir]));
    }
    SourceFactory sourceFactory =
        new SourceFactory(/*contentCache,*/ resolvers);

    var options = new AnalysisOptionsImpl()..cacheSize = 512;

    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = sourceFactory;

    if (packageMeta.isSdk) {
      libraries.addAll(getSdkLibrariesToDocument(sdk, context));
    }

    List<Source> sources = [];

    files.forEach((String filePath) {
      String name = filePath;
      if (name.startsWith(Directory.current.path)) {
        name = name.substring(Directory.current.path.length);
        if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
      }
      print('parsing ${name}...');
      Source source = new FileBasedSource.con1(new JavaFile(filePath));
      sources.add(source);
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        libraries.add(library);
      }
    });

    // Ensure that the analysis engine performs all remaining work.
    AnalysisResult result = context.performAnalysisTask();
    while (result.hasMoreWork) {
      result = context.performAnalysisTask();
    }

    List<AnalysisErrorInfo> errorInfos = [];

    for (Source source in sources) {
      context.computeErrors(source);
      errorInfos.add(context.getErrors(source));
    }

    List<_Error> errors = errorInfos.expand((AnalysisErrorInfo info) {
      return info.errors.map(
          (error) => new _Error(error, info.lineInfo, packageMeta.dir.path));
    }).where((_Error error) => error.isError).toList()..sort();

    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print(
        "Parsed ${libraries.length} " "file${libraries.length == 1 ? '' : 's'} in "
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

/// The results of a [DartDoc.generateDocs] call.
class DartDocResults {
  final PackageMeta packageMeta;
  final Package package;
  final Directory outDir;

  DartDocResults(this.packageMeta, this.package, this.outDir);
}

/// This class is returned if dartdoc fails in an expected way (for instance, if
/// there is an analysis error in the library).
class DartDocFailure {
  final String message;

  DartDocFailure(this.message);

  String toString() => message;
}

class _Error implements Comparable {
  final AnalysisError error;
  final LineInfo lineInfo;
  final String projectPath;

  _Error(this.error, this.lineInfo, this.projectPath);

  int get severity => error.errorCode.errorSeverity.ordinal;
  bool get isError => error.errorCode.errorSeverity == ErrorSeverity.ERROR;
  String get severityName => error.errorCode.errorSeverity.displayName;
  String get description => '${error.message} at ${location}, line ${line}.';
  int get line => lineInfo.getLocation(error.offset).lineNumber;

  String get location {
    String path = error.source.fullName;
    if (path.startsWith(projectPath)) {
      path = path.substring(projectPath.length + 1);
    }
    return path;
  }

  int compareTo(_Error other) {
    if (severity == other.severity) {
      int cmp = error.source.fullName.compareTo(other.error.source.fullName);
      return cmp == 0 ? line - other.line : cmp;
    } else {
      return other.severity - severity;
    }
  }

  String toString() => '[${severityName}] ${description}';
}
