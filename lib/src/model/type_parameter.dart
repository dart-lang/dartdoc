// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';

class TypeParameter extends ModelElement with HasNoPage {
  @override
  final TypeParameterElement element;

  TypeParameter(this.element, super.library, super.packageGraph);

  @override
  ModelElement get enclosingElement =>
      modelBuilder.from(element.enclosingElement!, library);

  /// [TypeParameter]s don't have documentation pages, and don't link to the
  /// element on which they are declared.
  // TODO(srawlins): But shouldn't they link to the element on which they are
  // declared?
  @override
  String? get href => null;

  @override
  String get kind => 'type parameter';

  ElementType? get boundType {
    var bound = element.bound;
    return bound == null ? null : modelBuilder.typeFrom(bound, library);
  }

  @override
  bool get hasParameters => false;

  @override
  late final String name = element.bound != null
      ? '${element.name} extends ${boundType!.nameWithGenerics}'
      : element.name;

  String? _linkedName;

  @override
  String get linkedName {
    _linkedName ??= element.bound != null
        ? '${element.name} extends ${boundType!.linkedName}'
        : element.name;
    return _linkedName!;
  }

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    var boundType = this.boundType;
    if (boundType == null) return const <String, CommentReferable>{};
    return {boundType.name: boundType};
  }();

  @override
  Iterable<CommentReferable> get referenceParents => [enclosingElement];

  @override
  String get referenceName => element.name;
}

/// A mixin for [ModelElement]s which have type parameters.
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
