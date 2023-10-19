// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//

import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartdoc/src/comment_references/parser.dart';

/// A stripped down analyzer AST [CommentReference] containing only that
/// information needed for Dartdoc.
class ModelCommentReference {
  final String codeRef;

  bool get hasCallableHint =>
      parsed.isNotEmpty &&
      ((parsed.length > 1 && parsed.last.text == 'new') ||
          parsed.last is CallableHintEndNode);

  List<String> get referenceBy => parsed
      .whereType<IdentifierNode>()
      .map<String>((i) => i.text)
      .toList(growable: false);

  /// Constructs a [ModelCommentReference] given a raw string.
  ModelCommentReference(this.codeRef);

  late final List<CommentReferenceNode> parsed =
      CommentReferenceParser(codeRef).parse();
}
