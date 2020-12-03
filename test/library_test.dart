// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  Folder sdkFolder;

  PackageMetaProvider packageMetaProvider;
  FakePackageConfigProvider packageConfigProvider;

  setUp(() async {
    packageMetaProvider = utils.testPackageMetaProvider;
    sdkFolder = packageMetaProvider.defaultSdkDir;
    packageConfigProvider = utils.getTestPackageConfigProvider(sdkFolder.path);
  });

  test('libraries in SDK package have appropriate data', () async {
    var packageGraph = await utils.bootBasicPackage(
        sdkFolder.path, packageMetaProvider, packageConfigProvider,
        additionalArguments: [
          '--input',
          packageMetaProvider.defaultSdkDir.path,
        ]);

    var localPackages = packageGraph.localPackages;
    expect(localPackages, hasLength(1));
    var sdkPackage = localPackages.single;
    expect(sdkPackage.name, equals('Dart'));

    var dartAsyncLib =
        sdkPackage.libraries.firstWhere((l) => l.name == 'dart:async');
    expect(dartAsyncLib.name, 'dart:async');
    expect(dartAsyncLib.dirName, 'dart-async');
    expect(dartAsyncLib.href,
        '${HTMLBASE_PLACEHOLDER}dart-async/dart-async-library.html');
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});
}
