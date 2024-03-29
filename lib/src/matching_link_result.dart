// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/comment_referable.dart';

class MatchingLinkResult {
  final CommentReferable? commentReferable;

  MatchingLinkResult(this.commentReferable);

  @override
  bool operator ==(Object other) =>
      other is MatchingLinkResult && commentReferable == other.commentReferable;

  @override
  int get hashCode => commentReferable.hashCode;

  @override
  String toString() {
    return 'element: [${commentReferable?.fullyQualifiedName}]';
  }
}
