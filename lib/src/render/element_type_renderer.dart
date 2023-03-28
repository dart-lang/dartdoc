// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/record_type_field_renderer.dart';

abstract class ElementTypeRenderer<T extends ElementType> {
  const ElementTypeRenderer();

  String renderLinkedName(T elementType);

  String renderNameWithGenerics(T elementType) => '';

  String wrapNullabilityParens(T elementType, String inner) =>
      elementType.nullabilitySuffix.isEmpty
          ? inner
          : '($inner${elementType.nullabilitySuffix})';

  @Deprecated('Append nullability suffix to StringBuilder')
  String wrapNullability(T elementType, String inner) =>
      '$inner${elementType.nullabilitySuffix}';
}

// HTML implementations.

abstract class ElementTypeRendererHtml<T extends ElementType>
    extends ElementTypeRenderer<T> {
  const ElementTypeRendererHtml();

  String _renderLinkedName(
      T elementType, String name, Iterable<ElementType> typeArguments) {
    var buffer = StringBuffer()..write(name);
    if (typeArguments.isNotEmpty &&
        !typeArguments.every((t) => t.name == 'dynamic')) {
      buffer
        ..write('<span class="signature">')
        ..write('&lt;<wbr><span class="type-parameter">')
        ..writeAll(typeArguments.map((t) => t.linkedName),
            '</span>, <span class="type-parameter">')
        ..write('</span>&gt;')
        ..write('</span>');
    }
    buffer.write(elementType.nullabilitySuffix);
    return buffer.toString();
  }

  String _renderNameWithGenerics(
      T elementType, String name, Iterable<ElementType> typeArguments) {
    var buffer = StringBuffer()..write(name);
    if (typeArguments.isNotEmpty &&
        !typeArguments.every((t) => t.name == 'dynamic')) {
      buffer
        ..write('&lt;<wbr><span class="type-parameter">')
        ..writeAll(typeArguments.map((t) => t.nameWithGenerics),
            '</span>, <span class="type-parameter">')
        ..write('</span>&gt;');
    }
    buffer.write(elementType.nullabilitySuffix);
    return buffer.toString();
  }
}

class FunctionTypeElementTypeRendererHtml
    extends ElementTypeRenderer<FunctionTypeElementType> {
  const FunctionTypeElementTypeRendererHtml();

  @override
  String renderLinkedName(FunctionTypeElementType elementType) {
    var buffer = StringBuffer()
      ..write(elementType.returnType.linkedName)
      ..write(' ')
      ..write(elementType.nameWithGenerics)
      ..write('<span class="signature">(')
      ..write(const ParameterRendererHtml()
          .renderLinkedParams(elementType.parameters))
      ..write(')</span>');
    return wrapNullabilityParens(elementType, buffer.toString());
  }

  @override
  String renderNameWithGenerics(FunctionTypeElementType elementType) {
    var buffer = StringBuffer()..write(elementType.name);
    if (elementType.typeFormals.isNotEmpty) {
      if (!elementType.typeFormals.every((t) => t.name == 'dynamic')) {
        buffer
          ..write('&lt;<wbr><span class="type-parameter">')
          ..writeAll(elementType.typeFormals.map((t) => t.name),
              '</span>, <span class="type-parameter">')
          ..write('</span>&gt;');
      }
    }
    return buffer.toString();
  }
}

class ParameterizedElementTypeRendererHtml
    extends ElementTypeRendererHtml<ParameterizedElementType> {
  const ParameterizedElementTypeRendererHtml();

  @override
  String renderLinkedName(ParameterizedElementType elementType) =>
      _renderLinkedName(
        elementType,
        elementType.modelElement.linkedName,
        elementType.typeArguments,
      );

  @override
  String renderNameWithGenerics(ParameterizedElementType elementType) =>
      _renderNameWithGenerics(
        elementType,
        elementType.modelElement.name,
        elementType.typeArguments,
      );
}

class RecordElementTypeRendererHtml
    extends ElementTypeRendererHtml<RecordElementType> {
  const RecordElementTypeRendererHtml();

  @override
  String renderLinkedName(RecordElementType elementType) {
    var buffer = StringBuffer()
      ..write('(')
      ..write(const RecordTypeFieldListHtmlRenderer()
          .renderLinkedFields(elementType)
          .trim())
      ..write(')');
    return wrapNullabilityParens(elementType, buffer.toString());
  }

  @override
  String renderNameWithGenerics(RecordElementType elementType) {
    return '${elementType.name}${elementType.nullabilitySuffix}';
  }
}

class AliasedUndefinedElementTypeRendererHtml
    extends ElementTypeRendererHtml<AliasedUndefinedElementType> {
  const AliasedUndefinedElementTypeRendererHtml();

  @override
  String renderLinkedName(AliasedUndefinedElementType elementType) =>
      _renderLinkedName(
        elementType,
        elementType.aliasElement.linkedName,
        elementType.aliasArguments,
      );

  @override
  String renderNameWithGenerics(AliasedUndefinedElementType elementType) =>
      _renderNameWithGenerics(
        elementType,
        elementType.aliasElement.name,
        elementType.aliasArguments,
      );
}

class AliasedElementTypeRendererHtml
    extends ElementTypeRendererHtml<AliasedElementType> {
  const AliasedElementTypeRendererHtml();

  @override
  String renderLinkedName(AliasedElementType elementType) => _renderLinkedName(
        elementType,
        elementType.aliasElement.linkedName,
        elementType.aliasArguments,
      );

  @override
  String renderNameWithGenerics(AliasedElementType elementType) =>
      _renderNameWithGenerics(
        elementType,
        elementType.aliasElement.name,
        elementType.aliasArguments,
      );
}

class CallableElementTypeRendererHtml
    extends ElementTypeRenderer<CallableElementType> {
  const CallableElementTypeRendererHtml();

  @override
  String renderLinkedName(CallableElementType elementType) {
    var buffer = StringBuffer()
      ..write(elementType.nameWithGenerics)
      ..write('(')
      ..write(const ParameterRendererHtml()
          .renderLinkedParams(elementType.modelElement.parameters,
              showNames: false)
          .trim())
      ..write(') → ')
      ..write(elementType.returnType.linkedName);
    return wrapNullabilityParens(elementType, buffer.toString());
  }

  @override
  String renderNameWithGenerics(CallableElementType elementType) {
    var buffer = StringBuffer()..write(elementType.name);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buffer
        ..write('&lt;')
        ..writeAll(
            elementType.typeArguments.map((t) => t.nameWithGenerics), ', ')
        ..write('>');
    }
    buffer.write(elementType.nullabilitySuffix);
    return buffer.toString();
  }
}

// Markdown implementations.

abstract class ElementTypeRendererMd<T extends ElementType>
    extends ElementTypeRenderer<T> {
  const ElementTypeRendererMd();

  String _renderLinkedName(
      T elementType, String name, Iterable<ElementType> typeArguments) {
    var buffer = StringBuffer()..write(name);
    if (typeArguments.isNotEmpty &&
        !typeArguments.every((t) => t.name == 'dynamic')) {
      buffer
        ..write('&lt;')
        ..writeAll(typeArguments.map((t) => t.linkedName), ', ')
        ..write('>');
    }
    buffer.write(elementType.nullabilitySuffix);
    return buffer.toString();
  }

  String _renderNameWithGenerics(
      T elementType, String name, Iterable<ElementType> typeArguments) {
    var buffer = StringBuffer()..write(name);
    if (typeArguments.isNotEmpty &&
        !typeArguments.every((t) => t.name == 'dynamic')) {
      buffer
        ..write('&lt;')
        ..writeAll(typeArguments.map((t) => t.nameWithGenerics), ', ')
        ..write('>');
    }
    buffer.write(elementType.nullabilitySuffix);
    return buffer.toString();
  }
}

class FunctionTypeElementTypeRendererMd
    extends ElementTypeRenderer<FunctionTypeElementType> {
  const FunctionTypeElementTypeRendererMd();

  @override
  String renderLinkedName(FunctionTypeElementType elementType) {
    var parameterRenderer = const ParameterRendererMd();
    return wrapNullabilityParens(
        elementType,
        '${elementType.returnType.linkedName} '
        '${elementType.nameWithGenerics}'
        '('
        '${parameterRenderer.renderLinkedParams(elementType.parameters)}'
        ')');
  }

  @override
  String renderNameWithGenerics(FunctionTypeElementType elementType) {
    var buffer = StringBuffer()..write(elementType.name);
    if (elementType.typeFormals.isNotEmpty) {
      if (!elementType.typeFormals.every((t) => t.name == 'dynamic')) {
        buffer
          ..write('&lt;')
          ..writeAll(elementType.typeFormals.map((t) => t.name), ', ')
          ..write('>');
      }
    }
    return buffer.toString();
  }
}

class ParameterizedElementTypeRendererMd
    extends ElementTypeRendererMd<ParameterizedElementType> {
  const ParameterizedElementTypeRendererMd();

  @override
  String renderLinkedName(ParameterizedElementType elementType) =>
      _renderLinkedName(
        elementType,
        elementType.modelElement.linkedName,
        elementType.typeArguments,
      );

  @override
  String renderNameWithGenerics(ParameterizedElementType elementType) =>
      _renderNameWithGenerics(
        elementType,
        elementType.modelElement.name,
        elementType.typeArguments,
      );
}

class RecordElementTypeRendererMd
    extends ElementTypeRendererMd<RecordElementType> {
  const RecordElementTypeRendererMd();

  @override
  String renderLinkedName(RecordElementType elementType) {
    var buffer = StringBuffer()
      ..write('(')
      ..write(
          const RecordTypeFieldListMdRenderer().renderLinkedFields(elementType))
      ..write(')');
    return wrapNullabilityParens(elementType, buffer.toString());
  }

  @override
  String renderNameWithGenerics(RecordElementType elementType) {
    return '${elementType.name}${elementType.nullabilitySuffix}';
  }
}

class AliasedElementTypeRendererMd
    extends ElementTypeRendererMd<AliasedElementType> {
  const AliasedElementTypeRendererMd();

  @override
  String renderLinkedName(AliasedElementType elementType) => _renderLinkedName(
        elementType,
        elementType.aliasElement.linkedName,
        elementType.aliasArguments,
      );

  @override
  String renderNameWithGenerics(AliasedElementType elementType) =>
      _renderNameWithGenerics(
        elementType,
        elementType.aliasElement.name,
        elementType.aliasArguments,
      );
}

class AliasedUndefinedElementTypeRendererMd
    extends ElementTypeRendererMd<AliasedUndefinedElementType> {
  const AliasedUndefinedElementTypeRendererMd();

  @override
  String renderLinkedName(AliasedUndefinedElementType elementType) =>
      _renderLinkedName(
        elementType,
        elementType.aliasElement.linkedName,
        elementType.aliasArguments,
      );

  @override
  String renderNameWithGenerics(AliasedUndefinedElementType elementType) =>
      _renderNameWithGenerics(
        elementType,
        elementType.aliasElement.name,
        elementType.aliasArguments,
      );
}

class CallableElementTypeRendererMd
    extends ElementTypeRendererMd<CallableElementType> {
  const CallableElementTypeRendererMd();

  @override
  String renderLinkedName(CallableElementType elementType) {
    var buffer = StringBuffer()
      ..write(elementType.nameWithGenerics)
      ..write('(')
      ..write(const ParameterRendererMd()
          .renderLinkedParams(elementType.parameters, showNames: false)
          .trim())
      ..write(') → ')
      ..write(elementType.returnType.linkedName);
    return wrapNullabilityParens(elementType, buffer.toString());
  }

  @override
  String renderNameWithGenerics(CallableElementType elementType) {
    var buffer = StringBuffer()..write(elementType.name);
    if (elementType.typeArguments.isNotEmpty &&
        !elementType.typeArguments.every((t) => t.name == 'dynamic')) {
      buffer
        ..write('&lt;')
        ..writeAll(
            elementType.typeArguments.map((t) => t.nameWithGenerics), ', ')
        ..write('>');
    }
    buffer.write(elementType.nullabilitySuffix);
    return buffer.toString();
  }
}
