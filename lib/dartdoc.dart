// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc;

import 'dart:io';

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'src/generator.dart';
import 'src/io_utils.dart';
import 'src/model.dart';
import 'src/model_utils.dart';

const String DEFAULT_OUTPUT_DIRECTORY = 'docs';

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc {

  List<String> _excludes;
  Directory _rootDir;
  String _url;
  Directory out;
  Set<LibraryElement> libraries = new Set();
  HtmlGenerator generator;

  DartDoc(this._rootDir, this._excludes, this._url);

  /// Generate the documentation
  void generateDocs() {
    Stopwatch stopwatch = new Stopwatch();
    stopwatch.start();
    var files = findFilesToDocumentInPackage(_rootDir.path);
    List<LibraryElement> libs = [];
    libs.addAll(parseLibraries(files));
    // remove excluded libraries
    _excludes.forEach(
        (pattern) => libs.removeWhere((l) => l.name.startsWith(pattern)));
    libs.removeWhere(
        (LibraryElement library) => _excludes.contains(library.name));
    libs.sort(elementCompare);
    libraries.addAll(libs);

    // create the out directory
    out = new Directory(DEFAULT_OUTPUT_DIRECTORY);
    if (!out.existsSync()) {
      out.createSync(recursive: true);
    }

    generator = new HtmlGenerator(new Package(libraries, _rootDir.path), out, _url);
    // generate the docs
    generator.generate();

    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    print('');
    print("Documented ${libraries.length} " "librar${libraries.length == 1 ? 'y' : 'ies'} in " "${seconds.toStringAsFixed(1)} seconds.");
  }

  List<LibraryElement> parseLibraries(List<String> files) {
    DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(_getSdkDir().path));

    ContentCache contentCache = new ContentCache();
    List<UriResolver> resolvers = [new DartUriResolver(sdk), new FileUriResolver()];
    JavaFile packagesDir = new JavaFile.relative(new JavaFile(_rootDir.path), 'packages');
    if (packagesDir.exists()) {
      resolvers.add(new PackageUriResolver([packagesDir]));
    }
    SourceFactory sourceFactory = new SourceFactory(/*contentCache,*/ resolvers);
    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;

    files.forEach((String filePath) {
      print('parsing ${filePath}...');
      Source source = new FileBasedSource.con1(new JavaFile(filePath));
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        CompilationUnit unit = context.resolveCompilationUnit(source, library);
        libraries.add(library);
        libraries.addAll(library.exportedLibraries);
      }
    });
    return libraries.toList();
  }

  Directory _getSdkDir() {
    // Look for --dart-sdk on the command line.
    // TODO:
    List<String> args = []; //new Options().arguments;
    if (args.contains('--dart-sdk')) {
      return new Directory(args[args.indexOf('dart-sdk') + 1]);
    }
    // Look in env['DART_SDK'].
    if (Platform.environment['DART_SDK'] != null) {
      return new Directory(Platform.environment['DART_SDK']);
    }
    // Look relative to the dart executable.
    return new File(Platform.executable).parent.parent;
  }

}
