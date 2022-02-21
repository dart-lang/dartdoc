// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  test('libraries in SDK package have appropriate data', () async {
    var packageMetaProvider = utils.testPackageMetaProvider;
    var sdkFolder = packageMetaProvider.defaultSdkDir;
    var packageConfigProvider =
        utils.getTestPackageConfigProvider(sdkFolder.path);

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

    var dartAsyncLib = sdkPackage.libraries.named('dart:async');
    expect(dartAsyncLib.name, 'dart:async');
    expect(dartAsyncLib.dirName, 'dart-async');
    expect(dartAsyncLib.href,
        '${htmlBasePlaceholder}dart-async/dart-async-library.html');
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});
}
