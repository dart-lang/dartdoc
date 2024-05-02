// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//

import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartdoc/src/comment_references/parser.dart';

/// A stripped down analyzer AST [CommentReference] containing only that
/// information needed for Dartdoc.
class ModelCommentReference {
  final String _codeRef;

  bool get hasCallableHint =>
      _parsed.isNotEmpty &&
      ((_parsed.length > 1 && _parsed.last.text == 'new') ||
          _parsed.last is CallableHintEndNode);

  List<String> get referenceBy => _parsed
      .whereType<IdentifierNode>()
      .map<String>((i) => i.text)
      .toList(growable: false);

  /// Constructs a [ModelCommentReference] given a raw string.
  ModelCommentReference(this._codeRef);

  late final List<CommentReferenceNode> _parsed =
      CommentReferenceParser(_codeRef).parse();
}
