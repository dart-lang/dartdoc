// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.resource_loader_test;

import 'package:dartdoc/src/html/resource_loader.dart' as loader;
import 'package:test/test.dart';

void main() {
  group('Resource Loader', () {
    test('load from packages', () async {
      var contents =
          await loader.loadAsString('package:dartdoc/templates/index.html');
      expect(contents, isNotNull);
    });
  });
}
