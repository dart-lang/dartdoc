// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/type_parameter.dart';

abstract class TypeParametersRenderer {
  String renderGenericParameters(TypeParameters typeParameters);

  String renderLinkedGenericParameters(TypeParameters typeParameters);
}

class TypeParametersRendererHtml extends TypeParametersRenderer {
  @override
  String renderGenericParameters(TypeParameters typeParameters) {
    if (typeParameters.typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters.typeParameters
        .map((t) => t.name)
        .join('</span>, <span class="type-parameter">');
    return '&lt;<wbr><span class="type-parameter">${joined}</span>&gt;';
  }

  @override
  String renderLinkedGenericParameters(TypeParameters typeParameters) {
    if (typeParameters.typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters.typeParameters
        .map((t) => t.linkedName)
        .join('</span>, <span class="type-parameter">');
    return '<span class="signature">&lt;<wbr><span class="type-parameter">${joined}</span>&gt;</span>';
  }
}

class TypeParametersRendererMd extends TypeParametersRenderer {
  @override
  String renderGenericParameters(TypeParameters typeParameters) =>
      _compose(typeParameters.typeParameters, (t) => t.name);

  @override
  String renderLinkedGenericParameters(TypeParameters typeParameters) =>
      _compose(typeParameters.typeParameters, (t) => t.linkedName);

  String _compose(List<TypeParameter> typeParameters,
      String Function(TypeParameter) mapfn) {
    if (typeParameters.isEmpty) {
      return '';
    }
    var joined = typeParameters.map(mapfn).join(', ');
    return '&lt;${joined}>';
  }
}
