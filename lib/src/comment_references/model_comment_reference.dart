// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/comment_references/parser.dart';

abstract class ModelCommentReference {
  /// Does the structure of the reference itself imply a possible unnamed
  /// constructor?
  bool get allowUnnamedConstructor;
  bool get allowUnnamedConstructorParameter;
  String get codeRef;
  bool get hasConstructorHint;
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
  void _initAllowCache() {
    final referencePieces =
        parsed.whereType<IdentifierNode>().toList(growable: false);
    _allowUnnamedConstructor = false;
    _allowUnnamedConstructorParameter = false;
    if (referencePieces.length >= 2) {
      for (var i = 0; i <= referencePieces.length - 2; i++) {
        if (referencePieces[i].text == referencePieces[i + 1].text) {
          if (i + 2 == referencePieces.length) {
            // This looks like an old-style reference to an unnamed
            // constructor, e.g. [lib_name.C.C].
            _allowUnnamedConstructor = true;
          } else {
            // This could be a reference to a parameter or type parameter of
            // an unnamed/new-declared constructor.
            _allowUnnamedConstructorParameter = true;
          }
        }
      }
      // e.g. [C.new], which may be the unnamed constructor.
      if (referencePieces.isNotEmpty && referencePieces.last.text == 'new') {
        _allowUnnamedConstructor = true;
      }
    }
  }

  bool? _allowUnnamedConstructor;
  @override
  bool get allowUnnamedConstructor {
    if (_allowUnnamedConstructor == null) {
      _initAllowCache();
    }
    return _allowUnnamedConstructor!;
  }

  bool? _allowUnnamedConstructorParameter;
  @override
  bool get allowUnnamedConstructorParameter {
    if (_allowUnnamedConstructorParameter == null) {
      _initAllowCache();
    }
    return _allowUnnamedConstructorParameter!;
  }

  @override
  final String codeRef;

  @override
  bool get hasCallableHint =>
      parsed.isNotEmpty &&
      (parsed.first is ConstructorHintStartNode ||
          parsed.last is CallableHintEndNode);

  @override
  bool get hasConstructorHint =>
      parsed.isNotEmpty && parsed.first is ConstructorHintStartNode;

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
    if (self is PrefixedIdentifier) {
      return self.staticElement;
    } else if (self is PropertyAccess) {
      return self.propertyName.staticElement;
    } else if (self is SimpleIdentifier) {
      return self.staticElement;
    } else {
      return null;
    }
  }
}
