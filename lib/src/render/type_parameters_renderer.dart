// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/type_parameter.dart';

abstract class TypeParametersRenderer {
  const TypeParametersRenderer();

  String renderGenericParameters(TypeParameters typeParameters);

  String renderLinkedGenericParameters(TypeParameters typeParameters);
}

class TypeParametersRendererHtml implements TypeParametersRenderer {
  const TypeParametersRendererHtml();

  @override
  String renderGenericParameters(TypeParameters typeParameters) {
    if (typeParameters.typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters.typeParameters
        .map((t) => [
              ...t.annotations.map((a) => a.linkedNameWithParameters),
              t.name
            ].join(' '))
        .join('</span>, <span class="type-parameter">');
    return '&lt;<wbr><span class="type-parameter">$joined</span>&gt;';
  }

  @override
  String renderLinkedGenericParameters(TypeParameters typeParameters) {
    if (typeParameters.typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters.typeParameters
        .map((t) => [
              ...t.annotations.map((a) => a.linkedNameWithParameters),
              t.linkedName
            ].join(' '))
        .join('</span>, <span class="type-parameter">');
    return '<span class="signature">&lt;<wbr><span class="type-parameter">$joined</span>&gt;</span>';
  }
}

class TypeParametersRendererMd implements TypeParametersRenderer {
  const TypeParametersRendererMd();

  @override
  String renderGenericParameters(TypeParameters typeParameters) => _compose(
      typeParameters.typeParameters,
      (t) => [...t.annotations.map((a) => a.linkedNameWithParameters), t.name]
          .join(' '));

  @override
  String renderLinkedGenericParameters(TypeParameters typeParameters) =>
      _compose(
          typeParameters.typeParameters,
          (t) => [
                ...t.annotations.map((a) => a.linkedNameWithParameters),
                t.linkedName
              ].join(' '));

  String _compose(List<TypeParameter> typeParameters,
      String Function(TypeParameter) mapfn) {
    if (typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters.map(mapfn).join(', ');
    return '&lt;$joined>';
  }
}
