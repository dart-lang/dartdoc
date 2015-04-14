// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc;

import 'dart:io';
import 'dart:async';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'package:path/path.dart' as path;

import 'generator.dart';
import 'src/html_generator.dart';
import 'src/io_utils.dart';
import 'src/model.dart';
import 'src/model_utils.dart';

const String NAME = 'dartdoc';

// Update when pubspec version changes
const String VERSION = '0.0.1+1';

/// Initialize and setup the generators
List<Generator> initGenerators(String url, String footer) {
  return [new HtmlGenerator(url, footer)];
}

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc {
  final List<String> _excludes;
  final Directory _rootDir;
  final Directory _sdkDir;
  Directory outputDir;
  Directory inputDir;
  final bool sdkDocs;
  final Set<LibraryElement> libraries = new Set();
  final List<Generator> _generators;
  final String sdkReadmePath;

  Stopwatch stopwatch;

  DartDoc(this._rootDir, this._excludes, this._sdkDir, this._generators,
      this.outputDir, {this.inputDir, this.sdkDocs: false, this.sdkReadmePath});

  /// Generate the documentation
  Future generateDocs() async {
    stopwatch = new Stopwatch();
    stopwatch.start();

    if (inputDir == null) inputDir = _rootDir;
    var files = sdkDocs ? [] : findFilesToDocumentInPackage(inputDir.path);
    List<LibraryElement> libs = [];
    libs.addAll(_parseLibraries(files));
    // remove excluded libraries
    _excludes.forEach(
        (pattern) => libs.removeWhere((l) => l.name.startsWith(pattern)));
    libs
      ..removeWhere(
          (LibraryElement library) => _excludes.contains(library.name));
    libraries.addAll(libs);

    // create the out directory
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    Package package = new Package(
        libraries, _rootDir.path, _getSdkVersion(), sdkDocs, sdkReadmePath);

    for (var generator in _generators) {
      await generator.generate(package, outputDir);
    }

    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    print('');
    print(
        "Documented ${libraries.length} " "librar${libraries.length == 1 ? 'y' : 'ies'} in " "${seconds.toStringAsFixed(1)} seconds.");
  }

  List<LibraryElement> _parseLibraries(List<String> files) {
    DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(_sdkDir.path));
    List<UriResolver> resolvers = [
      new DartUriResolver(sdk),
      new FileUriResolver()
    ];
    JavaFile packagesDir =
        new JavaFile.relative(new JavaFile(_rootDir.path), 'packages');
    if (packagesDir.exists()) {
      resolvers.add(new PackageUriResolver([packagesDir]));
    }
    SourceFactory sourceFactory =
        new SourceFactory(/*contentCache,*/ resolvers);
    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;

    if (sdkDocs) {
      libraries.addAll(getSdkLibrariesToDocument(sdk, context));
    }
    files.forEach((String filePath) {
      print('parsing ${filePath}...');
      Source source = new FileBasedSource.con1(new JavaFile(filePath));
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        libraries.add(library);
        //    libraries.addAll(library.exportedLibraries);
      }
    });
    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    print(
        "\nParsed ${libraries.length} " "librar${libraries.length == 1 ? 'y' : 'ies'} in " "${seconds.toStringAsFixed(1)} seconds.\n");
    return libraries.toList();
  }

  String _getSdkVersion() {
    File versionFile = new File(path.join(_sdkDir.path, 'version'));
    return versionFile.readAsStringSync();
  }
}
