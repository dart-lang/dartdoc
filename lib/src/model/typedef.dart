// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

class Typedef extends ModelElement
    with TypeParameters, Categorization
    implements EnclosedElement {
  Typedef(TypeAliasElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  DartType get aliasedType => element.aliasedType;

  @override
  TypeAliasElement get element => super.element;

  ElementType _modelType;
  ElementType get modelType => _modelType ??=
      ElementType.from(element.aliasedType, library, packageGraph);

  @override
  ModelElement get enclosingElement => library;

  @override
  String get nameWithGenerics => '$name${super.genericParameters}';

  @override
  String get genericParameters => _renderer.renderGenericParameters(this);

  List<TypeParameterElement> get genericTypeParameters =>
      element.typeParameters;

  @override
  String get filePath => '${library.dirName}/$fileName';

  FunctionTypedef get asCallable => this as FunctionTypedef;

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

  @override
  List<TypeParameter> get typeParameters => element.typeParameters.map((f) {
        return ModelElement.from(f, library, packageGraph) as TypeParameter;
      }).toList();

  TypedefRenderer get _renderer => packageGraph.rendererFactory.typedefRenderer;
}

/// A typedef referring to a function type.
class FunctionTypedef extends Typedef {
  FunctionTypedef(
      TypeAliasElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  FunctionType get aliasedType => super.aliasedType;

  @override
  List<TypeParameterElement> get genericTypeParameters {
    var aliasedTypeElement = aliasedType.aliasElement;
    if (aliasedTypeElement is FunctionTypedElement) {
      return aliasedTypeElement.typeParameters;
    }
    if (aliasedType.typeFormals.isNotEmpty == true) {
      return aliasedType.typeFormals;
    }
    return super.genericTypeParameters;
  }

  @override
  CallableElementTypeMixin get modelType => super.modelType;
}
