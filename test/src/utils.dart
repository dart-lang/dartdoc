// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/config.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/sdk.dart';
import 'package:path/path.dart' as pathLib;

Directory sdkDir;
PackageMeta sdkPackageMeta;
PackageGraph testPackageGraph;
PackageGraph testPackageGraphGinormous;
PackageGraph testPackageGraphSmall;
PackageGraph testPackageGraphSdk;

final Directory testPackageBadDir = new Directory('testing/test_package_bad');
final Directory testPackageDir = new Directory('testing/test_package');
final Directory testPackageWithEmbedderYaml =
    new Directory('testing/test_package_embedder_yaml');
final Directory testPackageWithNoReadme =
    new Directory('testing/test_package_small');

void delete(Directory dir) {
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}

init() async {
  sdkDir = getSdkDir();
  sdkPackageMeta = new PackageMeta.fromDir(sdkDir);
  setConfig();

  testPackageGraph = await bootBasicPackage(
      'testing/test_package', ['css', 'code_in_comments', 'excluded'], false);
  testPackageGraphGinormous = await bootBasicPackage(
      'testing/test_package', ['css', 'code_in_commnets', 'excluded'], true);

  testPackageGraphSmall =
      await bootBasicPackage('testing/test_package_small', [], false);
  testPackageGraphSdk = await bootSdkPackage();
}

Future<PackageGraph> bootSdkPackage() {
  Directory dir = new Directory(pathLib.current);
  return new PackageBuilder(
          dir, [], [], sdkDir, sdkPackageMeta, [], [], true, false)
      .buildPackageGraph();
}

Future<PackageGraph> bootBasicPackage(
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
      .buildPackageGraph();
}
