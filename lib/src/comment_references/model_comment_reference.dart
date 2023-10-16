// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/comment_references/parser.dart';

abstract class ModelCommentReference {
  String get codeRef;
  bool get hasCallableHint;
  List<String> get referenceBy;
  Element? get staticElement;

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
  final String codeRef;

  @override
  bool get hasCallableHint =>
      parsed.isNotEmpty &&
      ((parsed.length > 1 && parsed.last.text == 'new') ||
          parsed.last is CallableHintEndNode);

  @override
  List<String> get referenceBy => parsed
      .whereType<IdentifierNode>()
      .map<String>((i) => i.text)
      .toList(growable: false);

  @override
  final Element? staticElement;

  _ModelCommentReferenceImpl(
      CommentReference ref, ResourceProvider resourceProvider)
      : codeRef = _referenceText(ref, resourceProvider),
        staticElement = ref.expression.element;

  _ModelCommentReferenceImpl.synthetic(this.codeRef, this.staticElement);

  /// "Unparse" the code reference into the raw text associated with the
  /// [CommentReference].
  static String _referenceText(
      CommentReference ref, ResourceProvider resourceProvider) {
    var token = (ref.parent as Comment)
        .tokens
        .firstWhere((t) => t.offset <= ref.offset && t.end >= ref.end);
    // This is a little sketchy, but works since comments happen to be a token
    // that is fully preserved in its string representation.
    // TODO(jcollins-g): replace unparsing in general with lower level changes.
    return token
        .toString()
        .substring(ref.offset - token.offset, ref.end - token.offset);
  }

  late final List<CommentReferenceNode> parsed =
      CommentReferenceParser(codeRef).parse();
}

extension on CommentReferableExpression {
  Element? get element {
    var self = this;
    return switch (self) {
      PrefixedIdentifier() => self.staticElement,
      PropertyAccess() => self.propertyName.staticElement,
      SimpleIdentifier() => self.staticElement,
      _ => null
    };
  }
}
