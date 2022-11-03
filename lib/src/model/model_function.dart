// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

/// A [ModelElement] for a [FunctionElement] that isn't part of a type definition.
class ModelFunction extends ModelFunctionTyped with Categorization {
  ModelFunction(
      FunctionElement super.element, super.library, super.packageGraph);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  FunctionElement get element => super.element as FunctionElement;

  @override
  bool get isAsynchronous => element.isAsynchronous;
}

/// A [ModelElement] for a [FunctionTypedElement] that is part of an
/// explicit typedef.
class ModelFunctionTypedef extends ModelFunctionTyped {
  ModelFunctionTypedef(super.element, super.library, super.packageGraph);

  @override
  String get name => element.enclosingElement!.name!;
}

class ModelFunctionTyped extends ModelElement
    with TypeParameters
    implements EnclosedElement {
  @override
  final FunctionTypedElement element;

  @override
  late final List<TypeParameter> typeParameters = [
    for (var p in element.typeParameters)
      modelBuilder.from(p, library) as TypeParameter,
  ];

  ModelFunctionTyped(this.element, super.library, super.packageGraph);

  @override
  ModelElement get enclosingElement => library;

  @override
  String get filePath => '${library.dirName}/$fileName';

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  @override
  String get kind => 'function';

  // Food for mustache. TODO(jcollins-g): what about enclosing elements?
  bool get isInherited => false;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    ...parameters.explicitOnCollisionWith(this),
    ...typeParameters.explicitOnCollisionWith(this),
  };

  @override
  Iterable<CommentReferable> get referenceParents => [definingLibrary];

  late final Callable modelType =
      modelBuilder.typeFrom(element.type, library) as Callable;
}
