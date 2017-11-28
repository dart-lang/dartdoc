// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/config.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/sdk.dart';
import 'package:path/path.dart' as p;

Directory sdkDir;
PackageMeta sdkPackageMeta;
Package testPackage;
Package testPackageGinormous;
Package testPackageSmall;
Package testPackageSdk;

final Directory testPackageBadDir = new Directory('testing/test_package_bad');
final Directory testPackageDir = new Directory('testing/test_package');
final Directory testPackageWithEmbedderYaml =
    new Directory('testing/test_package_embedder_yaml');
final Directory testPackageWithNoReadme =
    new Directory('testing/test_package_small');

void delete(Directory dir) {
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}

void init() {
  sdkDir = getSdkDir();
  sdkPackageMeta = new PackageMeta.fromSdk(sdkDir);
  setConfig();

  testPackage = bootBasicPackage(
      'testing/test_package', ['css', 'code_in_comments', 'excluded'], false);
  testPackageGinormous = bootBasicPackage(
      'testing/test_package', ['css', 'code_in_commnets', 'excluded'], true);

  testPackageSmall = bootBasicPackage('testing/test_package_small', [], false);
  testPackageSdk = bootSdkPackage();
}

Package bootSdkPackage() {
  Directory dir = new Directory(p.current);
  return new PackageBuilder(
          dir, [], [], sdkDir, sdkPackageMeta, [], [], true, false)
      .buildPackage();
}

Package bootBasicPackage(
    String dirPath, List<String> excludes, bool withAutoIncludedDependencies) {
  Directory dir = new Directory(dirPath);
  return new PackageBuilder(
          dir,
          excludes,
          [],
          sdkDir,
          new PackageMeta.fromDir(new Directory(dirPath)),
          [],
          [],
          true,
          withAutoIncludedDependencies)
      .buildPackage();
}
/*
@deprecated
class AnalyzerHelper {
  AnalysisContext context;

  AnalyzerHelper() {
    List<UriResolver> resolvers = [
      new DartUriResolver(sdkDir),
      new ResourceUriResolver(PhysicalResourceProvider.INSTANCE)
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
    // Ensure that the analysis engine performs all remaining work.
    AnalysisResult result = context.performAnalysisTask();
    while (result.hasMoreWork) {
      result = context.performAnalysisTask();
    }
    return source;
  }

  LibraryElement resolve(Source librarySource) =>
      context.computeLibraryElement(librarySource);
}
*/
