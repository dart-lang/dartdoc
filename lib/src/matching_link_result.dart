// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class MatchingLinkResult {
  final CommentReferable? commentReferable;
  final bool warn;

  MatchingLinkResult(this.commentReferable, {this.warn = true});

  @override
  bool operator ==(Object other) {
    return other is MatchingLinkResult &&
        commentReferable == other.commentReferable &&
        warn == other.warn;
  }

  @override
  int get hashCode => Object.hash(commentReferable, warn);

  @override
  String toString() {
    return 'element: [${commentReferable is Constructor ? 'new ' : ''}${commentReferable?.fullyQualifiedName}] warn: $warn';
  }
}
