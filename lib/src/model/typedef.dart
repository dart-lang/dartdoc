// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

class Typedef extends ModelElement
    with TypeParameters, Categorization
    implements EnclosedElement {
  Typedef(FunctionTypeAliasElement element, Library library,
      PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  @override
  ModelElement get enclosingElement => library;

  @override
  String get nameWithGenerics => '$name${super.genericParameters}';

  @override
  String get genericParameters => _renderer.renderGenericParameters(this);

  List<TypeParameterElement> get genericTypeParameters {
    if (element is FunctionTypeAliasElement) {
      return (element as FunctionTypeAliasElement).function.typeParameters;
    }
    return Iterable<TypeParameterElement>.empty();
  }

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

  // Food for mustache.
  bool get isInherited => false;

  @override
  String get kind => 'typedef';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  @override
  // TODO(jcollins-g): change to FunctionTypeElementType after analyzer 0.41
  // ignore: unnecessary_overrides
  ElementType get modelType => super.modelType;

  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  @override
  List<TypeParameter> get typeParameters => _typedef.typeParameters.map((f) {
        return ModelElement.from(f, library, packageGraph) as TypeParameter;
      }).toList();

  TypedefRenderer get _renderer => packageGraph.rendererFactory.typedefRenderer;
}
