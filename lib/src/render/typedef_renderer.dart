// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/type_parameter.dart';
import 'package:dartdoc/src/model/typedef.dart';

/// A renderer for a [Typedef].
abstract class TypedefRenderer {
  const TypedefRenderer();

  /// Render the the generic type parameters of the specified [typedef].
  String renderGenericParameters(Typedef typedef);

  /// Render the the generic type parameters of the specified [typedef].
  String renderLinkedGenericParameters(Typedef typedef);
}

/// An HTML renderer for a [Typedef].
class TypedefRendererHtml extends TypedefRenderer {
  const TypedefRendererHtml();

  String _renderTypeParameters(Iterable<TypeParameter> typeParameters,
      String Function(TypeParameter t) getName) {
    if (typeParameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('&lt;<wbr><span class="type-parameter">');
    buffer.writeAll(
        typeParameters.map((t) => [
              ...t.annotations.map((a) => a.linkedNameWithParameters),
              getName(t)
            ].join(' ')),
        '</span>, <span class="type-parameter">');
    buffer.write('</span>&gt;');

    return buffer.toString();
  }

  @override
  String renderGenericParameters(Typedef typedef) =>
      _renderTypeParameters(typedef.typeParameters, (t) => t.name);

  @override
  String renderLinkedGenericParameters(Typedef typedef) =>
      _renderTypeParameters(typedef.typeParameters, (t) => t.linkedName);
}

/// A markdown renderer for a [Typedef].
class TypedefRendererMd extends TypedefRenderer {
  const TypedefRendererMd();

  String _renderTypeParameters(Iterable<TypeParameter> typeParameters,
      String Function(TypeParameter t) getName) {
    if (typeParameters.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('&lt;{');
    buffer.writeAll(
        typeParameters.map((t) => [
              ...t.annotations.map((a) => a.linkedNameWithParameters),
              getName(t)
            ].join(' ')),
        ', ');
    buffer.write('}>');

    return buffer.toString();
  }

  @override
  String renderGenericParameters(Typedef typedef) =>
      _renderTypeParameters(typedef.typeParameters, (t) => t.name);

  @override
  String renderLinkedGenericParameters(Typedef typedef) =>
      _renderTypeParameters(typedef.typeParameters, (t) => t.linkedName);
}
