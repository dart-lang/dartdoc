// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
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
  final ResourceProvider resourceProvider;

  final AstNode _sourceNode;

  ModelNode(AstNode sourceNode, this.element, this.resourceProvider)
      : _sourceNode = sourceNode,
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
      if (_sourceNode?.offset != null) {
        var enclosingSourceNode = _sourceNode;

        /// Get a node higher up the syntax tree that includes the semicolon.
        /// In this case, it is either a [FieldDeclaration] or
        /// [TopLevelVariableDeclaration]. (#2401)
        if (_sourceNode is VariableDeclaration) {
          enclosingSourceNode = _sourceNode.parent.parent;
          assert(enclosingSourceNode is FieldDeclaration ||
              enclosingSourceNode is TopLevelVariableDeclaration);
        }

        var sourceEnd = enclosingSourceNode.end;
        var sourceOffset = enclosingSourceNode.offset;

        var contents =
            model_utils.getFileContentsFor(element, resourceProvider);
        // Find the start of the line, so that we can line up all the indents.
        var i = sourceOffset;
        while (i > 0) {
          i -= 1;
          if (contents[i] == '\n' || contents[i] == '\r') {
            i += 1;
            break;
          }
        }

        // Trim the common indent from the source snippet.
        var start = sourceOffset - (sourceOffset - i);
        var source = contents.substring(start, sourceEnd);

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
