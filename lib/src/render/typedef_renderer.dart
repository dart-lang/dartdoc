// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/typedef.dart';

abstract class TypedefRenderer {
  String renderGenericParameters(Typedef typedef);
}

class TypedefRendererHtml extends TypedefRenderer {
  @override
  String renderGenericParameters(Typedef typedef) {
    if (typedef.genericTypeParameters.isEmpty) {
      return '';
    }
    var joined = typedef.genericTypeParameters
        .map((t) => t.name)
        .join('</span>, <span class="type-parameter">');
    return '&lt;<wbr><span class="type-parameter">${joined}</span>&gt;';
  }
}

class TypedefRendererMd extends TypedefRenderer {
  @override
  String renderGenericParameters(Typedef typedef) {
    if (typedef.genericTypeParameters.isEmpty) {
      return '';
    }
    var joined = typedef.genericTypeParameters.map((t) => t.name).join(', ');
    return '<{$joined}>';
  }
}
