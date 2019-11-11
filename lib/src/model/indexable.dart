// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// Something able to be indexed.
abstract class Indexable implements Nameable {
  String get href;

  String get kind;

  int get overriddenDepth => 0;
}
