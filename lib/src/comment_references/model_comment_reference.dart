// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:dartdoc/src/model_utils.dart';

abstract class ModelCommentReference {
  /// Does the structure of the reference itself imply a possible default
  /// constructor?
  // TODO(jcollins-g): rewrite/discard this once default constructor tear-off
  // design process is complete.
  bool get allowDefaultConstructor;
  String get codeRef;
  bool get hasConstructorHint;
  List<String> get referenceBy;
  Element get staticElement;

  /// Construct a [ModelCommentReference] using the analyzer AST.
  factory ModelCommentReference(
          CommentReference ref, ResourceProvider resourceProvider) =>
      _ModelCommentReferenceImpl(ref, resourceProvider);

  /// Construct a [ModelCommentReference] given a raw string.
  factory ModelCommentReference.synthetic(String codeRef) =>
      _ModelCommentReferenceImpl.synthetic(codeRef, null);
}

/// A stripped down analyzer AST [CommentReference] containing only that
/// information needed for Dartdoc.  Drops link to the [CommentReference]
/// and [ResourceProvider] after construction.
class _ModelCommentReferenceImpl implements ModelCommentReference {
  @override
  bool get allowDefaultConstructor {
    if (parsed.length >= 2) {
      return parsed[parsed.length - 2] == parsed[parsed.length - 1];
    }
    return false;
  }

  @override
  final String codeRef;

  @override
  bool get hasConstructorHint =>
      parsed.isNotEmpty &&
      (parsed.first is ConstructorHintStartNode ||
          parsed.last is ConstructorHintEndNode);

  @override
  List<String> get referenceBy => parsed
      .whereType<IdentifierNode>()
      .map<String>((i) => i.text)
      .toList(growable: false);

  @override
  final Element staticElement;

  _ModelCommentReferenceImpl(
      CommentReference ref, ResourceProvider resourceProvider)
      : codeRef = _referenceText(ref, resourceProvider),
        staticElement = ref.identifier.staticElement;

  _ModelCommentReferenceImpl.synthetic(this.codeRef, this.staticElement);

  /// "Unparse" the code reference into the raw text associated with the
  /// [CommentReference].
  static String _referenceText(
      CommentReference ref, ResourceProvider resourceProvider) {
    var contents = getFileContentsFor(
        (ref.root as CompilationUnit).declaredElement, resourceProvider);
    return contents.substring(ref.offset, ref.end);
  }

  List<CommentReferenceNode> _parsed;
  List<CommentReferenceNode> get parsed =>
      _parsed ??= CommentReferenceParser(codeRef).parse();
}
