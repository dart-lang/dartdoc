// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.css_test;

import 'package:http/http.dart' as http;
import 'package:unittest/unittest.dart';

import '../lib/src/css.dart';

void main() {
  group('check bootstrap', () {
    CSS css = new CSS();

    test('css stylesheet url exists', () {
      var url = css.cssHeader;
      http.get(url).then((response) {
        expect(response.statusCode, 200);
      });
    });

    test('theme stylesheet url exists', () {
      var url = css.theme;
      http.get(url).then((response) {
        expect(response.statusCode, 200);
      });
    });

  });
}
