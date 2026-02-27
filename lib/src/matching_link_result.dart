// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/referable.dart';

class MatchingLinkResult {
  final Referable? referable;

  MatchingLinkResult(this.referable);

  @override
  bool operator ==(Object other) =>
      other is MatchingLinkResult && referable == other.referable;

  @override
  int get hashCode => referable.hashCode;

  @override
  String toString() {
    return 'element: [${referable?.fullyQualifiedName}]';
  }
}
