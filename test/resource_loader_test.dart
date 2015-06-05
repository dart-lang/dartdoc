// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.resource_loader_test;

import 'dart:io';

import 'package:path/path.dart';
import 'package:dartdoc/resource_loader.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('Resource Loader', () {
    test('load from packages', () {
      loadAsString('package:dartdoc/templates/index.html')
          .then((string) => expect(string, isNotNull));
    });

    test('package root setting', () {
      var root = Directory.current;
      packageRootPath = root.path;
      expect(packageRootPath, equals(root.path));
    });

    test('load from packages with package root setting', () {
      var root = Directory.current;
      packageRootPath = join(root.path, 'packages');
      loadAsString('package:dartdoc/templates/index.html').then((string) {
        expect(string, isNotNull);
      });
    });
  });
}
