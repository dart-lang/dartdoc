// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

class TypeParameter extends ModelElement with HasNoPage {
  @override
  final TypeParameterElement2 element;

  TypeParameter(this.element, super.library, super.packageGraph);

  @override
  ModelElement get enclosingElement =>
      getModelFor(element.enclosingElement2!, library);

  /// [TypeParameter]s don't have documentation pages, and don't link to the
  /// element on which they are declared.
  // TODO(srawlins): But shouldn't they link to the element on which they are
  // declared?
  @override
  String? get href => null;

  @override
  Kind get kind => Kind.typeParameter;

  ElementType? get boundType {
    var bound = element.bound;
    return bound == null ? null : getTypeFor(bound, library);
  }

  @override
  bool get hasParameters => false;

  @override
  String get name => element.bound != null
      ? '${element.name3} extends ${boundType!.nameWithGenerics}'
      : element.name3!;

  @override
  String get linkedName => element.bound != null
      ? '${element.name3} extends ${boundType!.linkedName}'
      : element.name3!;

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    var boundType = this.boundType;
    if (boundType == null) return const <String, CommentReferable>{};
    return {boundType.name: boundType};
  }();

  @override
  Iterable<CommentReferable> get referenceParents => [enclosingElement];

  @override
  String get referenceName => element.name3!;
}

/// A mixin for [ModelElement]s which have type parameters.
mixin TypeParameters implements ModelElement {
  String get nameWithGenerics => '$name$genericParameters';

  String get nameWithLinkedGenerics => '$name$linkedGenericParameters';

  bool get hasGenericParameters => typeParameters.isNotEmpty;

  String get genericParameters => _renderTypeParameters();

  String get linkedGenericParameters => _renderTypeParameters(isLinked: true);

  List<TypeParameter> get typeParameters;

  String _renderTypeParameters({bool isLinked = false}) {
    if (typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters
        .map((t) => [
              ...t.annotations.map((a) => a.linkedNameWithParameters),
              isLinked ? t.linkedName : t.name
            ].join(' '))
        .join('</span>, <span class="type-parameter">');
    var typeParametersString =
        '&lt;<wbr><span class="type-parameter">$joined</span>&gt;';
    if (isLinked) {
      typeParametersString =
          '<span class="signature">$typeParametersString</span>';
    }
    return typeParametersString;
  }
}
