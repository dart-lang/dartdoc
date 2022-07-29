// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// An element which has no page documenting itself.
mixin HasNoPage on ModelElement {
  @override
  String get filePath =>
      throw UnimplementedError('This element has no generated page');

  // TODO(srawlins): Add sidebar information here, when sidebars become dynamic.
}
