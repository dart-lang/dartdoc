// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/type_parameter.dart';

abstract class TypeParametersRenderer {
  String renderGenericParameters(List<TypeParameter> typeParameters);
  String renderLinkedGenericParameters(List<TypeParameter> typeParameters);
}

class TypeParametersRendererHtml extends TypeParametersRenderer {
  @override
  String renderGenericParameters(List<TypeParameter> typeParameters) {
    var joined = typeParameters
        .map((t) => t.name)
        .join('</span>, <span class="type-parameter">');
    return '&lt;<wbr><span class="type-parameter">${joined}</span>&gt;';
  }

  @override
  String renderLinkedGenericParameters(List<TypeParameter> typeParameters) {
    var joined = typeParameters
        .map((t) => t.linkedName)
        .join('</span>, <span class="type-parameter">');
    return '<span class="signature">&lt;<wbr><span class="type-parameter">${joined}</span>&gt;</span>';
  }
}
