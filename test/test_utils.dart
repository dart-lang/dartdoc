// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'package:dartdoc/src/model.dart';
import 'dart:io';

import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:path/path.dart' as p;
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:dartdoc/src/package_meta.dart';

DartSdk sdkDir;
AnalyzerHelper analyzerHelper;
Package testPackage;
Package testPackageSmall;

init() {
  sdkDir = new DirectoryBasedDartSdk(new JavaFile(cli_util.getSdkDir().path));

  analyzerHelper = new AnalyzerHelper();
  var pathsForTestLib = [
    'lib/example.dart',
    'lib/two_exports.dart',
    'lib/fake.dart',
    'lib/anonymous_library.dart',
    'lib/another_anonymous_lib.dart'
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
