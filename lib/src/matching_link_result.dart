// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/nameable.dart';

class MatchingLinkResult {
  final Nameable? nameable;

  MatchingLinkResult(this.nameable);

  @override
  bool operator ==(Object other) =>
      other is MatchingLinkResult && nameable == other.nameable;

  @override
  int get hashCode => nameable.hashCode;

  @override
  String toString() {
    return 'element: [${nameable?.fullyQualifiedName}]';
  }
}
