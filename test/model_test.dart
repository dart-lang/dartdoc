// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'package:dartdoc/src/model.dart';
import 'package:unittest/unittest.dart';

tests() {
  group('Class', () {

    test('has correct type name', () {
      var c = new Class(null, null);
      expect(c.typeName, equals('Classes'));
    });
  });
}
