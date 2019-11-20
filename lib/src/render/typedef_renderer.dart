// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';

abstract class TypedefRenderer {
  String renderGenericParameters(List<TypeParameterElement> typeParameters);
}

class TypedefRendererHtml extends TypedefRenderer {
  @override
  String renderGenericParameters(List<TypeParameterElement> typeParameters) {
    var joined = typeParameters
        .map((t) => t.name)
        .join('</span>, <span class="type-parameter">');
    return '&lt;<wbr><span class="type-parameter">${joined}</span>&gt;';
  }
}
