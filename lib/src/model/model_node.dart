// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/comment_references/model_comment_reference.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;

/// Stripped down information derived from [AstNode] containing only information
/// needed for Dartdoc.  Drops link to the [AstNode] after construction.
class ModelNode {
  final List<ModelCommentReference> commentRefs;
  final Element element;
  final ResourceProvider resourceProvider;
  final int _sourceEnd;
  final int _sourceOffset;

  factory ModelNode(
      AstNode? sourceNode, Element element, ResourceProvider resourceProvider) {
    var commentRefs = _commentRefsFor(sourceNode, resourceProvider);
    // Get a node higher up the syntax tree that includes the semicolon.
    // In this case, it is either a [FieldDeclaration] or
    // [TopLevelVariableDeclaration]. (#2401)
    if (sourceNode == null) {
      return ModelNode._(element, resourceProvider, commentRefs,
          sourceEnd: -1, sourceOffset: -1);
    } else {
      if (sourceNode is VariableDeclaration) {
        sourceNode = sourceNode.parent!.parent!;
        assert(sourceNode is FieldDeclaration ||
            sourceNode is TopLevelVariableDeclaration);
      }
      return ModelNode._(element, resourceProvider, commentRefs,
          sourceEnd: sourceNode.end, sourceOffset: sourceNode.offset);
    }
  }

  ModelNode._(this.element, this.resourceProvider, this.commentRefs,
      {required int sourceEnd, required int sourceOffset})
      : _sourceEnd = sourceEnd,
        _sourceOffset = sourceOffset;

  static List<ModelCommentReference> _commentRefsFor(
      AstNode? node, ResourceProvider resourceProvider) {
    if (node is AnnotatedNode) {
      var nodeDocumentationComment = node.documentationComment;
      if (nodeDocumentationComment != null) {
        return [
          for (var m in nodeDocumentationComment.references)
            ModelCommentReference(m, resourceProvider),
        ];
      }
    }
    return const [];
  }

  late final String sourceCode = () {
    if (_sourceEnd < 0 || _sourceOffset < 0) {
      return '';
    }

    var contents = model_utils.getFileContentsFor(element, resourceProvider)!;
    // Find the start of the line, so that we can line up all of the indents.
    var i = _sourceOffset;
    while (i > 0) {
      i -= 1;
      if (contents[i] == '\n' || contents[i] == '\r') {
        i += 1;
        break;
      }
    }

    // Trim the common indent from the source snippet.
    var source = contents.substring(i, _sourceEnd);

    source = model_utils.stripIndentFromSource(source);
    source = model_utils.stripDartdocCommentsFromSource(source);

    return source.trim();
  }();
}
