// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';

import 'src/utils.dart';

void main() {
  group('dartdoc', () {
    Directory tempDir;

    setUp(() {
      tempDir = new Directory(path.join(Directory.systemTemp.path, 'temp'));
    });

    tearDown(() {
      delete(tempDir);
    });

    test('generateDocs', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc =
          new DartDoc(testPackageDir, [], getSdkDir(), [], tempDir, meta);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.package, isNotNull);

      Package p = results.package;
      expect(p.name, 'test_package');
      expect(p.hasDocumentation, true);
      expect(p.libraries.length, 3);
    });
  });
}
