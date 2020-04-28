// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';

abstract class ElementTypeRenderer<T extends ElementType> {
  String renderLinkedName(T elementType);

  String renderNameWithGenerics(T elementType) => '';
}

// Html implementations

class FunctionTypeElementTypeRendererHtml
    extends ElementTypeRenderer<FunctionTypeElementType> {
  @override
  String renderLinkedName(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write('${elementType.returnType.linkedName} ');
    buf.write('${elementType.nameWithGenerics}');
    buf.write('<span class="signature">(');
    buf.write(
        ParameterRendererHtml().renderLinkedParams(elementType.parameters));
    buf.write(')</span>');
    return buf.toString();
  }

  @override
  String renderNameWithGenerics(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.name);
    if (elementType.typeFormals.isNotEmpty) {
      if (!elementType.typeFormals.every((t) => t.name == 'dynamic')) {
        buf.write('&lt;<wbr><span class="type-parameter">');
        buf.writeAll(elementType.typeFormals.map((t) => t.name),
            '</span>, <span class="type-parameter">');
        buf.write('</span>&gt;');
      }
    }
    return buf.toString();
  }
}

class ParameterizedElementTypeRendererHtml
    extends ElementTypeRenderer<ParameterizedElementType> {
  @override
  String renderLinkedName(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.element.linkedName);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('<span class="signature">');
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.typeArguments.map((t) => t.linkedName),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
      buf.write('</span>');
    }
    return buf.toString();
  }

  @override
  String renderNameWithGenerics(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.element.name);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.typeArguments.map((t) => t.nameWithGenerics),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
    }
    return buf.toString();
  }
}

class CallableElementTypeRendererHtml
    extends ElementTypeRenderer<CallableElementType> {
  @override
  String renderLinkedName(CallableElementType elementType) {
    if (elementType.name != null && elementType.name.isNotEmpty) {
      return elementType.superLinkedName;
    }

    var buf = StringBuffer();
    buf.write(elementType.nameWithGenerics);
    buf.write('(');
    buf.write(ParameterRendererHtml()
        .renderLinkedParams(elementType.element.parameters, showNames: false)
        .trim());
    buf.write(') → ');
    buf.write(elementType.returnType.linkedName);
    return buf.toString();
  }
}

// Markdown implementations

class FunctionTypeElementTypeRendererMd
    extends ElementTypeRenderer<FunctionTypeElementType> {
  @override
  String renderLinkedName(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write('${elementType.returnType.linkedName} ');
    buf.write('${elementType.nameWithGenerics}');
    buf.write('(');
    buf.write(ParameterRendererMd().renderLinkedParams(elementType.parameters));
    buf.write(')');
    return buf.toString();
  }

  @override
  String renderNameWithGenerics(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.name);
    if (elementType.typeFormals.isNotEmpty) {
      if (!elementType.typeFormals.every((t) => t.name == 'dynamic')) {
        buf.write('<');
        buf.writeAll(elementType.typeFormals.map((t) => t.name), ', ');
        buf.write('>');
      }
    }
    return buf.toString();
  }
}

class ParameterizedElementTypeRendererMd
    extends ElementTypeRenderer<ParameterizedElementType> {
  @override
  String renderLinkedName(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.element.linkedName);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('<');
      buf.writeAll(elementType.typeArguments.map((t) => t.linkedName), ', ');
      buf.write('>');
    }
    return buf.toString();
  }

  @override
  String renderNameWithGenerics(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.element.name);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('<');
      buf.writeAll(
          elementType.typeArguments.map((t) => t.nameWithGenerics), ', ');
      buf.write('>');
    }
    return buf.toString();
  }
}

class CallableElementTypeRendererMd
    extends ElementTypeRenderer<CallableElementType> {
  @override
  String renderLinkedName(CallableElementType elementType) {
    if (elementType.name != null && elementType.name.isNotEmpty) {
      return elementType.superLinkedName;
    }

    var buf = StringBuffer();
    buf.write(elementType.nameWithGenerics);
    buf.write('(');
    buf.write(ParameterRendererMd()
        .renderLinkedParams(elementType.element.parameters, showNames: false)
        .trim());
    buf.write(') → ');
    buf.write(elementType.returnType.linkedName);
    return buf.toString();
  }
}
