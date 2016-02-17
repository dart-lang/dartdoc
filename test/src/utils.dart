// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as p;

AnalyzerHelper analyzerHelper;
DartSdk sdkDir;
Package testPackage;
final Directory testPackageBadDir = new Directory('test_package_bad');

final Directory testPackageDir = new Directory('test_package');
Package testPackageSmall;
final Directory testPackageWithEmbedderYaml =
    new Directory('test_package_embedder_yaml');
final Directory testPackageWithNoReadme = new Directory('test_package_small');

void delete(Directory dir) {
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}

void init() {
  sdkDir = new DirectoryBasedDartSdk(new JavaFile(cli_util.getSdkDir().path));

  analyzerHelper = new AnalyzerHelper();
  var pathsForTestLib = [
    'lib/example.dart',
    'lib/two_exports.dart',
    'lib/fake.dart',
    'lib/anonymous_library.dart',
    'lib/another_anonymous_lib.dart',
    'lib/is_deprecated.dart'
  ];

  testPackage = _bootPackage(pathsForTestLib, 'test_package');

  testPackageSmall = _bootPackage(['lib/main.dart'], 'test_package_small');
}

Package _bootPackage(Iterable<String> libPaths, String dirPath) {
  String fullDirPath = p.join(Directory.current.path, dirPath);
  Iterable<LibraryElement> libElements = libPaths.map((libFile) {
    Source source = analyzerHelper.addSource(p.join(fullDirPath, libFile));
    return analyzerHelper.resolve(source);
  });

  return new Package(
      libElements, new PackageMeta.fromDir(new Directory(dirPath)));
}

class AnalyzerHelper {
  AnalysisContext context;

  AnalyzerHelper() {
    List<UriResolver> resolvers = [
      new DartUriResolver(sdkDir),
      new FileUriResolver()
    ];

    SourceFactory sourceFactory = new SourceFactory(resolvers);
    AnalysisEngine.instance.processRequiredPlugins();
    context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;
  }

  Source addSource(String filePath) {
    Source source = new FileBasedSource(new JavaFile(filePath));
    ChangeSet changeSet = new ChangeSet();
    changeSet.addedSource(source);
    context.applyChanges(changeSet);
    return source;
  }

  LibraryElement resolve(Source librarySource) =>
      context.computeLibraryElement(librarySource);
}
