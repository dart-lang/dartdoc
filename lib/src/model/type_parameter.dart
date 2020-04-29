// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';

class TypeParameter extends ModelElement {
  TypeParameter(
      TypeParameterElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  @override
  ModelElement get enclosingElement => (element.enclosingElement != null)
      ? ModelElement.from(element.enclosingElement, library, packageGraph)
      : null;

  @override
  String get filePath =>
      '${enclosingElement.library.dirName}/${enclosingElement.name}/$name';

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
  String get kind => 'type parameter';

  ElementType _boundType;

  ElementType get boundType {
    if (_boundType == null) {
      var bound = _typeParameter.bound;
      if (bound != null) {
        _boundType = ElementType.from(bound, library, packageGraph);
      }
    }
    return _boundType;
  }

  String _name;

  @override
  String get name {
    _name ??= _typeParameter.bound != null
        ? '${_typeParameter.name} extends ${boundType.nameWithGenerics}'
        : _typeParameter.name;
    return _name;
  }

  String _linkedName;

  @override
  String get linkedName {
    _linkedName ??= _typeParameter.bound != null
        ? '${_typeParameter.name} extends ${boundType.linkedName}'
        : _typeParameter.name;
    return _linkedName;
  }

  TypeParameterElement get _typeParameter => element as TypeParameterElement;
}

abstract class TypeParameters implements ModelElement {
  String get nameWithGenerics => '$name$genericParameters';

  String get nameWithLinkedGenerics => '$name$linkedGenericParameters';

  bool get hasGenericParameters => typeParameters.isNotEmpty;

  String get genericParameters =>
      _typeParametersRenderer.renderGenericParameters(this);

  String get linkedGenericParameters =>
      _typeParametersRenderer.renderLinkedGenericParameters(this);

  @override
  DefinedElementType get modelType;

  List<TypeParameter> get typeParameters;

  TypeParametersRenderer get _typeParametersRenderer =>
      packageGraph.rendererFactory.typeParametersRenderer;
}
