// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';

class TypeParameter extends ModelElement {
  TypeParameter(
      TypeParameterElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  ModelElement get enclosingElement => (element.enclosingElement != null)
      ? modelBuilder.from(element.enclosingElement, library)
      : null;

  @override
  String get filePath =>
      '${enclosingElement.library.dirName}/${enclosingElement.name}/$name';

  @override

  /// [TypeParameter]s don't have documentation pages.
  String get href => null;

  @override
  String get kind => 'type parameter';

  ElementType _boundType;

  ElementType get boundType {
    if (_boundType == null) {
      var bound = element.bound;
      if (bound != null) {
        _boundType = modelBuilder.typeFrom(bound, library);
      }
    }
    return _boundType;
  }

  @override
  bool get hasParameters => false;

  String _name;

  @override
  String get name {
    _name ??= element.bound != null
        ? '${element.name} extends ${boundType.nameWithGenerics}'
        : element.name;
    return _name;
  }

  String _linkedName;

  @override
  String get linkedName {
    _linkedName ??= element.bound != null
        ? '${element.name} extends ${boundType.linkedName}'
        : element.name;
    return _linkedName;
  }

  Map<String, CommentReferable> _referenceChildren;

  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      if (boundType != null) {
        _referenceChildren[boundType.name] = boundType;
      }
    }
    return _referenceChildren;
  }

  @override
  Iterable<CommentReferable> get referenceParents => [enclosingElement];
  @override
  TypeParameterElement get element => super.element;

  @override
  String get referenceName => element.name;
}

mixin TypeParameters implements ModelElement {
  String get nameWithGenerics => '$name$genericParameters';

  String get nameWithLinkedGenerics => '$name$linkedGenericParameters';

  bool get hasGenericParameters => typeParameters.isNotEmpty;

  String get genericParameters =>
      _typeParametersRenderer.renderGenericParameters(this);

  String get linkedGenericParameters =>
      _typeParametersRenderer.renderLinkedGenericParameters(this);

  List<TypeParameter> get typeParameters;

  TypeParametersRenderer get _typeParametersRenderer =>
      packageGraph.rendererFactory.typeParametersRenderer;
}
