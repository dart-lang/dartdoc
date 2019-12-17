// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';

/// A [ModelElement] for a [FunctionElement] that isn't part of a type definition.
class ModelFunction extends ModelFunctionTyped with Categorization {
  ModelFunction(
      FunctionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  bool get isStatic {
    return _func.isStatic;
  }

  @override
  String get name => element.name ?? '';

  @override
  FunctionElement get _func => (element as FunctionElement);
}

/// A [ModelElement] for a [FunctionTypedElement] that is part of an
/// explicit typedef.
class ModelFunctionTypedef extends ModelFunctionTyped {
  ModelFunctionTypedef(
      FunctionTypedElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  String get name => element.enclosingElement.name;
}

class ModelFunctionTyped extends ModelElement
    with TypeParameters
    implements EnclosedElement {
  @override
  List<TypeParameter> typeParameters = [];

  ModelFunctionTyped(
      FunctionTypedElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null) {
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = _func.typeParameters.map((f) {
      return ModelElement.from(f, library, packageGraph) as TypeParameter;
    }).toList();
  }

  @override
  ModelElement get enclosingElement => library;

  @override
  String get filePath => '${library.dirName}/$fileName';

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  @override
  String get kind => 'function';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  // Food for mustache. TODO(jcollins-g): what about enclosing elements?
  bool get isInherited => false;

  @override
  DefinedElementType get modelType => super.modelType;

  FunctionTypedElement get _func => (element as FunctionTypedElement);
}
