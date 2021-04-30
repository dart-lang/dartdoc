// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/model_utils.dart';

/// A stripped down analyzer AST [CommentReference] containing only that
/// information needed for Dartdoc.  Drops link to the [CommentReference]
/// and [ResourceProvider] after construction.
class ModelCommentReference {
  final String codeRef;
  final Element staticElement;

  ModelCommentReference(CommentReference ref, ResourceProvider resourceProvider)
      : codeRef = _referenceText(ref, resourceProvider),
        staticElement = ref.identifier.staticElement;

  /// "Unparse" the code reference into the raw text associated with the
  /// [CommentReference].
  static String _referenceText(
      CommentReference ref, ResourceProvider resourceProvider) {
    var contents = getFileContentsFor(
        (ref.root as CompilationUnit).declaredElement, resourceProvider);
    return contents.substring(ref.offset, ref.end);
  }
}
