// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';

abstract class ElementTypeRenderer<T extends ElementType> {
  const ElementTypeRenderer();

  String renderLinkedName(T elementType);

  String renderNameWithGenerics(T elementType) => '';

  String wrapNullabilityParens(T elementType, String inner) =>
      elementType.nullabilitySuffix.isEmpty
          ? inner
          : '($inner${elementType.nullabilitySuffix})';
  String wrapNullability(T elementType, String inner) =>
      '$inner${elementType.nullabilitySuffix}';
}

// Html implementations

class FunctionTypeElementTypeRendererHtml
    extends ElementTypeRenderer<FunctionTypeElementType> {
  const FunctionTypeElementTypeRendererHtml();

  @override
  String renderLinkedName(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write('${elementType.returnType.linkedName} ');
    buf.write('${elementType.nameWithGenerics}');
    buf.write('<span class="signature">(');
    buf.write(
        ParameterRendererHtml().renderLinkedParams(elementType.parameters));
    buf.write(')</span>');
    return wrapNullabilityParens(elementType, buf.toString());
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
    return wrapNullability(elementType, buf.toString());
  }
}

class ParameterizedElementTypeRendererHtml
    extends ElementTypeRenderer<ParameterizedElementType> {
  const ParameterizedElementTypeRendererHtml();

  @override
  String renderLinkedName(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.modelElement.linkedName);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('<span class="signature">');
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.typeArguments.map((t) => t.linkedName),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
      buf.write('</span>');
    }
    return wrapNullability(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.modelElement.name);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.typeArguments.map((t) => t.nameWithGenerics),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
    }
    return wrapNullability(elementType, buf.toString());
  }
}

class AliasedFunctionTypeElementTypeRendererHtml
    extends ElementTypeRenderer<AliasedFunctionTypeElementType> {
  const AliasedFunctionTypeElementTypeRendererHtml();

  @override
  String renderLinkedName(AliasedFunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.linkedName);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('<span class="signature">');
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.aliasArguments.map((t) => t.linkedName),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
      buf.write('</span>');
    }
    return wrapNullability(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(AliasedFunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.name);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.aliasArguments.map((t) => t.nameWithGenerics),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
    }
    return wrapNullability(elementType, buf.toString());
  }
}

class AliasedElementTypeRendererHtml
    extends ElementTypeRenderer<AliasedElementType> {
  const AliasedElementTypeRendererHtml();

  @override
  String renderLinkedName(AliasedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.linkedName);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('<span class="signature">');
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.aliasArguments.map((t) => t.linkedName),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
      buf.write('</span>');
    }
    return wrapNullability(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(AliasedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.name);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;<wbr><span class="type-parameter">');
      buf.writeAll(elementType.aliasArguments.map((t) => t.nameWithGenerics),
          '</span>, <span class="type-parameter">');
      buf.write('</span>&gt;');
    }
    return wrapNullability(elementType, buf.toString());
  }
}

class CallableElementTypeRendererHtml
    extends ElementTypeRenderer<CallableElementType> {
  const CallableElementTypeRendererHtml();

  @override
  String renderLinkedName(CallableElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.nameWithGenerics);
    buf.write('(');
    buf.write(ParameterRendererHtml()
        .renderLinkedParams(elementType.modelElement.parameters,
            showNames: false)
        .trim());
    buf.write(') → ');
    buf.write(elementType.returnType.linkedName);
    return wrapNullabilityParens(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(CallableElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.name);
    if (elementType.typeArguments != null) {
      if (elementType.typeArguments.isNotEmpty &&
          !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
        buf.write('&lt;');
        buf.writeAll(
            elementType.typeArguments.map((t) => t.nameWithGenerics), ', ');
        buf.write('>');
      }
    }
    return wrapNullability(elementType, buf.toString());
  }
}

// Markdown implementations

class FunctionTypeElementTypeRendererMd
    extends ElementTypeRenderer<FunctionTypeElementType> {
  const FunctionTypeElementTypeRendererMd();

  @override
  String renderLinkedName(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write('${elementType.returnType.linkedName} ');
    buf.write('${elementType.nameWithGenerics}');
    buf.write('(');
    buf.write(ParameterRendererMd().renderLinkedParams(elementType.parameters));
    buf.write(')');
    return wrapNullabilityParens(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(FunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.name);
    if (elementType.typeFormals.isNotEmpty) {
      if (!elementType.typeFormals.every((t) => t.name == 'dynamic')) {
        buf.write('&lt;');
        buf.writeAll(elementType.typeFormals.map((t) => t.name), ', ');
        buf.write('>');
      }
    }
    return wrapNullabilityParens(elementType, buf.toString());
  }
}

class ParameterizedElementTypeRendererMd
    extends ElementTypeRenderer<ParameterizedElementType> {
  const ParameterizedElementTypeRendererMd();

  @override
  String renderLinkedName(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.modelElement.linkedName);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;');
      buf.writeAll(elementType.typeArguments.map((t) => t.linkedName), ', ');
      buf.write('>');
    }
    return wrapNullability(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(ParameterizedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.modelElement.name);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;');
      buf.writeAll(
          elementType.typeArguments.map((t) => t.nameWithGenerics), ', ');
      buf.write('>');
    }
    return wrapNullability(elementType, buf.toString());
  }
}

class AliasedElementTypeRendererMd
    extends ElementTypeRenderer<AliasedElementType> {
  const AliasedElementTypeRendererMd();

  @override
  String renderLinkedName(AliasedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.linkedName);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;');
      buf.writeAll(elementType.aliasArguments.map((t) => t.linkedName), ', ');
      buf.write('>');
    }
    return wrapNullability(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(AliasedElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.name);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;');
      buf.writeAll(
          elementType.aliasArguments.map((t) => t.nameWithGenerics), ', ');
      buf.write('>');
    }
    return wrapNullability(elementType, buf.toString());
  }
}

class AliasedFunctionTypeElementTypeRendererMd
    extends ElementTypeRenderer<AliasedFunctionTypeElementType> {
  const AliasedFunctionTypeElementTypeRendererMd();

  @override
  String renderLinkedName(AliasedFunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.linkedName);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;');
      buf.writeAll(elementType.aliasArguments.map((t) => t.linkedName), ', ');
      buf.write('>');
    }
    return wrapNullability(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(AliasedFunctionTypeElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.aliasElement.name);
    if (elementType.aliasArguments.isNotEmpty &&
        !elementType.aliasArguments.every((t) => t.name == 'dynamic')) {
      buf.write('&lt;');
      buf.writeAll(
          elementType.aliasArguments.map((t) => t.nameWithGenerics), ', ');
      buf.write('>');
    }
    return wrapNullability(elementType, buf.toString());
  }
}

class CallableElementTypeRendererMd
    extends ElementTypeRenderer<CallableElementType> {
  const CallableElementTypeRendererMd();

  @override
  String renderLinkedName(CallableElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.nameWithGenerics);
    buf.write('(');
    buf.write(ParameterRendererMd()
        .renderLinkedParams(elementType.parameters, showNames: false)
        .trim());
    buf.write(') → ');
    buf.write(elementType.returnType.linkedName);
    return wrapNullabilityParens(elementType, buf.toString());
  }

  @override
  String renderNameWithGenerics(CallableElementType elementType) {
    var buf = StringBuffer();
    buf.write(elementType.name);
    if (elementType.typeArguments != null) {
      if (elementType.typeArguments.isNotEmpty &&
          !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
        buf.write('&lt;');
        buf.writeAll(
            elementType.typeArguments.map((t) => t.nameWithGenerics), ', ');
        buf.write('>');
      }
    }
    return wrapNullability(elementType, buf.toString());
  }
}
