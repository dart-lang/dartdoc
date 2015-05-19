// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'generator.dart';
import 'src/html_generator.dart';
import 'src/io_utils.dart';
import 'src/model.dart';
import 'src/model_utils.dart';
import 'src/package_meta.dart';

const String NAME = 'dartdoc';
// Update when pubspec version changes.
const String VERSION = '0.0.1+10';

const String defaultOutDir = 'doc/api';

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
  final PackageMeta packageMeta;

  final Set<LibraryElement> libraries = new Set();

  Stopwatch _stopwatch;

  DartDoc(this.rootDir, this.excludes, this.sdkDir, this.generators,
      this.outputDir, this.packageMeta);

  /// Generate the documentation.
  Future<DartDocResults> generateDocs() async {
    _stopwatch = new Stopwatch()..start();

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
    JavaFile packagesDir =
        new JavaFile.relative(new JavaFile(rootDir.path), 'packages');
    if (packagesDir.exists()) {
      resolvers.add(new PackageUriResolver([packagesDir]));
    }
    SourceFactory sourceFactory =
        new SourceFactory(/*contentCache,*/ resolvers);

    var options = new AnalysisOptionsImpl()
      ..analyzeFunctionBodies = false
      ..cacheSize = 512;

    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = sourceFactory;

    if (packageMeta.isSdk) {
      libraries.addAll(getSdkLibrariesToDocument(sdk, context));
    }
    files.forEach((String filePath) {
      String name = filePath;
      if (name.startsWith(Directory.current.path)) {
        name = name.substring(Directory.current.path.length);
        if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
      }
      print('parsing ${name}...');
      Source source = new FileBasedSource.con1(new JavaFile(filePath));
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        libraries.add(library);
      }
    });
    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print(
        "Parsed ${libraries.length} " "file${libraries.length == 1 ? '' : 's'} in "
        "${seconds.toStringAsFixed(1)} seconds.\n");
    return libraries.toList();
  }
}

class DartDocResults {
  final PackageMeta packageMeta;
  final Package package;
  final Directory outDir;

  DartDocResults(this.packageMeta, this.package, this.outDir);
}
