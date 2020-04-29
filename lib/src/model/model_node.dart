// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;

/// A stripped down [CommentReference] containing only that information needed
/// for Dartdoc.  Drops link to the [CommentReference] after construction.
class ModelCommentReference {
  final String name;
  final Element staticElement;

  ModelCommentReference(CommentReference ref)
      : name = ref.identifier.name,
        staticElement = ref.identifier.staticElement;
}

/// Stripped down information derived from [AstNode] containing only information
/// needed for Dartdoc.  Drops link to the [AstNode] after construction.
class ModelNode {
  final List<ModelCommentReference> commentRefs;
  final Element element;

  final int _sourceOffset;
  final int _sourceEnd;

  ModelNode(AstNode sourceNode, this.element)
      : _sourceOffset = sourceNode?.offset,
        _sourceEnd = sourceNode?.end,
        commentRefs = _commentRefsFor(sourceNode);

  static List<ModelCommentReference> _commentRefsFor(AstNode node) {
    if (node is AnnotatedNode &&
        node?.documentationComment?.references != null) {
      return node.documentationComment.references
          .map((c) => ModelCommentReference(c))
          .toList(growable: false);
    }
    return null;
  }

  String _sourceCode;

  String get sourceCode {
    if (_sourceCode == null) {
      if (_sourceOffset != null) {
        var contents = model_utils.getFileContentsFor(element);
        // Find the start of the line, so that we can line up all the indents.
        var i = _sourceOffset;
        while (i > 0) {
          i -= 1;
          if (contents[i] == '\n' || contents[i] == '\r') {
            i += 1;
            break;
          }
        }

        // Trim the common indent from the source snippet.
        var start = _sourceOffset - (_sourceOffset - i);
        var source = contents.substring(start, _sourceEnd);

        source = const HtmlEscape().convert(source);
        source = model_utils.stripIndentFromSource(source);
        source = model_utils.stripDartdocCommentsFromSource(source);

        _sourceCode = source.trim();
      } else {
        _sourceCode = '';
      }
    }
    return _sourceCode;
  }
}
