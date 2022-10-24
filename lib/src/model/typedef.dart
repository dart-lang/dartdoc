// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

abstract class Typedef extends ModelElement
    with TypeParameters, Categorization
    implements EnclosedElement {
  @override
  final TypeAliasElement element;

  Typedef(this.element, super.library, super.packageGraph);

  DartType get aliasedType => element.aliasedType;

  late final ElementType modelType =
      modelBuilder.typeFrom(element.aliasedType, library);

  @override
  Library get enclosingElement => library;

  @override
  String get nameWithGenerics => '$name${super.genericParameters}';

  @override
  String get genericParameters => _renderer.renderGenericParameters(this);

  @override
  String get linkedGenericParameters =>
      _renderer.renderLinkedGenericParameters(this);

  @override
  String get filePath => '${library.dirName}/$fileName';

  /// Helper for mustache templates, which can't do casting themselves
  /// without this.
  FunctionTypedef get asCallable => this as FunctionTypedef;

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  // Food for mustache.
  bool get isInherited => false;

  @override
  String get kind => 'typedef';

  @override
  List<TypeParameter> get typeParameters => element.typeParameters
      .map((f) => modelBuilder.from(f, library) as TypeParameter)
      .toList(growable: false);

  TypedefRenderer get _renderer => packageGraph.rendererFactory.typedefRenderer;

  @override
  Iterable<CommentReferable> get referenceParents => [definingLibrary];

  late final Map<String, CommentReferable> _referenceChildren = {
    ...typeParameters.explicitOnCollisionWith(this),
  };

  @override
  Map<String, CommentReferable> get referenceChildren => _referenceChildren;
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
    assert(modelType.modelElement is Class);
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
        '"${element.name}" in "${element.library}"');
  }

  @override
  Callable get modelType => super.modelType as Callable;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    ...parameters.explicitOnCollisionWith(this),
    ...super.referenceChildren,
  };
}
