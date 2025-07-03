// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

abstract class Typedef extends ModelElement
    with TypeParameters, Categorization {
  @override
  final TypeAliasElement2 element;

  Typedef(this.element, super.library, super.packageGraph);

  DartType get aliasedType => element.aliasedType;

  late final ElementType modelType = getTypeFor(element.aliasedType, library);

  @override
  Library get enclosingElement => library;

  @override
  String get nameWithGenerics => '$name${super.genericParameters}';

  @override
  String get genericParameters => _renderTypeParameters();

  @override
  String get linkedGenericParameters => _renderTypeParameters(isLinked: true);

  @override
  // Prevent a collision with the library file.
  String get fileName => name == 'index' ? '$name-typedef.html' : '$name.html';

  @override
  String get aboveSidebarPath => canonicalLibraryOrThrow.sidebarPath;

  @override
  String? get belowSidebarPath => null;

  /// Helper for mustache templates, which can't do casting themselves
  /// without this.
  FunctionTypedef get asCallable => this as FunctionTypedef;

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    return '${package.baseHref}$filePath';
  }

  // Food for mustache.
  bool get isInherited => false;

  @override
  Kind get kind => Kind.typedef;

  @override
  List<TypeParameter> get typeParameters => element.typeParameters2
      .map((f) => getModelFor(f, library) as TypeParameter)
      .toList(growable: false);

  @override
  Iterable<CommentReferable> get referenceParents => [library];

  late final Map<String, CommentReferable> _referenceChildren = {
    ...typeParameters.explicitOnCollisionWith(this),
  };

  @override
  Map<String, CommentReferable> get referenceChildren => _referenceChildren;

  /// Render the the generic type parameters of this typedef.
  String _renderTypeParameters({bool isLinked = false}) {
    if (typeParameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('&lt;<wbr><span class="type-parameter">');
    buffer.writeAll(
        typeParameters.map((t) => [
              ...t.annotations.map((a) => a.linkedNameWithParameters),
              isLinked ? t.linkedName : t.name,
            ].join(' ')),
        '</span>, <span class="type-parameter">');
    buffer.write('</span>&gt;');

    return buffer.toString();
  }
}

/// A typedef referring to a non-function typedef that is nevertheless not
/// referring to a defined class.  An example is a typedef alias for `void` or
/// for `Function` itself.
class GeneralizedTypedef extends Typedef {
  GeneralizedTypedef(super.element, super.library, super.packageGraph) {
    assert(!isCallable);
  }
}

/// A typedef referring to a non-function, defined type.
class ClassTypedef extends Typedef {
  ClassTypedef(super.element, super.library, super.packageGraph) {
    assert(!isCallable);
    // TODO(kallentu): Make sure typedef testing is covered for each interface
    // element.
  }

  @override
  DefinedElementType get modelType => super.modelType as DefinedElementType;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    ...modelType.modelElement.referenceChildren,
    ...super.referenceChildren,
  };
}

/// A typedef referring to a function type.
class FunctionTypedef extends Typedef {
  FunctionTypedef(super.element, super.library, super.packageGraph) {
    assert(
        isCallable,
        'Expected callable but: ${element.runtimeType} is FunctionTypedElement '
        '|| (${element.runtimeType} is TypeAliasElement && '
        '${element.aliasedType.runtimeType} is FunctionType) is not true for '
        '"${element.name3}" in "${element.library2}"');
  }

  @override
  Callable get modelType => super.modelType as Callable;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    ...parameters.explicitOnCollisionWith(this),
    ...super.referenceChildren,
  };
}
