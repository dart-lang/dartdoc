// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/typedef.dart';

/// A renderer for a [Typedef].
abstract class TypedefRenderer {
  const TypedefRenderer();

  /// Render the the generic type parameters of the specified [typedef].
  String renderGenericParameters(Typedef typedef);
}

/// A HTML renderer for a [Typedef].
class TypedefRendererHtml extends TypedefRenderer {
  const TypedefRendererHtml();

  @override
  String renderGenericParameters(Typedef typedef) {
    final genericTypeParameters = typedef.genericTypeParameters;
    if (genericTypeParameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('&lt;<wbr><span class="type-parameter">');
    buffer.writeAll(genericTypeParameters.map((t) => t.name),
        '</span>, <span class="type-parameter">');
    buffer.write('</span>&gt;');

    return buffer.toString();
  }
}

/// A markdown renderer for a [Typedef].
class TypedefRendererMd extends TypedefRenderer {
  const TypedefRendererMd();

  @override
  String renderGenericParameters(Typedef typedef) {
    final genericTypeParameters = typedef.genericTypeParameters;
    if (genericTypeParameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('&lt;{');
    buffer.writeAll(genericTypeParameters.map((t) => t.name), ', ');
    buffer.write('}>');

    return buffer.toString();
  }
}
