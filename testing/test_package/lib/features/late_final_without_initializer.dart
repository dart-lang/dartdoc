// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

late final String initializeMe;

class C {
  late final a;
  late final b = 0;
  late final cField;
  late final double dField;

  C(double param) {
    cField = param * 3.14;
    dField = param * 8.854 * pow(10, -12);
  }
}

