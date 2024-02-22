// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/parameter.dart';

/// Render HTML in an extended vertical format using an `<ol>` tag.
class ParameterRendererHtmlList extends ParameterRendererHtml {
  const ParameterRendererHtmlList();

  @override
  String listItem(String item) => '<li>$item</li>\n';
  @override
  // TODO(jcollins-g): consider comma separated lists and more advanced CSS.
  String orderedList(String listItems) =>
      '<ol class="parameter-list">$listItems</ol>\n';
}

/// Render HTML suitable for a single, wrapped line.
class ParameterRendererHtml extends ParameterRenderer {
  const ParameterRendererHtml();

  @override
  String listItem(String item) => item;
  @override
  String orderedList(String listItems) => listItems;
  @override
  String annotation(String annotation) => '<span>$annotation</span>';
  @override
  String covariant(String covariant) => '<span>$covariant</span>';
  @override
  String defaultValue(String defaultValue) {
    var escaped =
        const HtmlEscape(HtmlEscapeMode.unknown).convert(defaultValue);
    return '<span class="default-value">$escaped</span>';
  }

  @override
  String parameter(String parameter, String id) =>
      '<span class="parameter" id="$id">$parameter</span>';
  @override
  String parameterName(String parameterName) =>
      '<span class="parameter-name">$parameterName</span>';
  @override
  String typeName(String typeName) =>
      '<span class="type-annotation">$typeName</span>';
  @override
  String required(String required) => '<span>$required</span>';
}

abstract class ParameterRenderer {
  const ParameterRenderer();

  String listItem(String item);
  String orderedList(String listItems);
  String annotation(String annotation);
  String covariant(String covariant);
  String defaultValue(String defaultValue);
  String parameter(String parameter, String id);
  String parameterName(String parameterName);
  String typeName(String typeName);
  String required(String required);

  String renderLinkedParams(List<Parameter> parameters,
      {bool showMetadata = true}) {
    var positionalParams = parameters
        .where((Parameter p) => p.isRequiredPositional)
        .toList(growable: false);
    var optionalPositionalParams = parameters
        .where((Parameter p) => p.isOptionalPositional)
        .toList(growable: false);
    var namedParams =
        parameters.where((Parameter p) => p.isNamed).toList(growable: false);

    var buffer = StringBuffer();
    if (positionalParams.isNotEmpty) {
      _renderLinkedParameterSublist(
        positionalParams,
        buffer,
        trailingComma:
            optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty,
        showMetadata: showMetadata,
      );
    }
    if (optionalPositionalParams.isNotEmpty) {
      _renderLinkedParameterSublist(
        optionalPositionalParams,
        buffer,
        trailingComma: namedParams.isNotEmpty,
        openBracket: '[',
        closeBracket: ']',
        showMetadata: showMetadata,
      );
    }
    if (namedParams.isNotEmpty) {
      _renderLinkedParameterSublist(
        namedParams,
        buffer,
        trailingComma: false,
        openBracket: '{',
        closeBracket: '}',
        showMetadata: showMetadata,
      );
    }
    return orderedList(buffer.toString());
  }

  void _renderLinkedParameterSublist(
    List<Parameter> parameters,
    StringBuffer buffer, {
    required bool trailingComma,
    String openBracket = '',
    String closeBracket = '',
    bool showMetadata = true,
  }) {
    for (var p in parameters) {
      var prefix = '';
      var suffix = '';
      if (identical(p, parameters.first)) {
        prefix = openBracket;
      }
      if (identical(p, parameters.last)) {
        suffix += closeBracket;
        if (trailingComma) suffix += ', ';
      } else {
        suffix += ', ';
      }
      final renderedParameter = _renderParameter(
        p,
        prefix: prefix,
        suffix: suffix,
        showMetadata: showMetadata,
      );
      buffer.write(listItem(parameter(renderedParameter, p.htmlId)));
    }
  }

  String _renderParameter(
    Parameter param, {
    required String prefix,
    required String suffix,
    bool showMetadata = true,
  }) {
    final buffer = StringBuffer(prefix);
    final modelType = param.modelType;

    if (showMetadata && param.hasAnnotations) {
      for (final a in param.annotations) {
        buffer.write('${annotation(a.linkedNameWithParameters)} ');
      }
    }
    if (param.isRequiredNamed) {
      buffer.write('${required('required')} ');
    }
    if (param.isCovariant) {
      buffer.write('${covariant('covariant')} ');
    }
    if (modelType is Callable) {
      final returnTypeName = modelType.isTypedef
          ? modelType.linkedName
          : modelType.returnType.linkedName;
      buffer.write(typeName(returnTypeName));
      buffer.write(' ${parameterName(param.name)}');

      // Writes out the generic type parameters for a function type.
      // TODO(kallentu): Pull this type parameter generation into a helper for
      // other renderers that also do this same work.
      if (modelType is FunctionTypeElementType) {
        if (modelType.typeFormals.isNotEmpty) {
          if (!modelType.typeFormals.every((t) => t.name == 'dynamic')) {
            buffer
              ..write('&lt;<wbr><span class="type-parameter">')
              ..writeAll(modelType.typeFormals.map((t) => t.name),
                  '</span>, <span class="type-parameter">')
              ..write('</span>&gt;');
          }
        }
      }

      if (!modelType.isTypedef && modelType is DefinedElementType) {
        buffer.write('(');
        buffer.write(renderLinkedParams(
          (modelType as DefinedElementType).modelElement.parameters,
          showMetadata: showMetadata,
        ));
        buffer.write(')');
        buffer.write(modelType.nullabilitySuffix);
      }
      if (!modelType.isTypedef) {
        buffer.write('(');
        buffer.write(renderLinkedParams(
          modelType.parameters,
          showMetadata: showMetadata,
        ));
        buffer.write(')');
        buffer.write(modelType.nullabilitySuffix);
      }
    } else {
      final linkedTypeName = modelType.linkedName;
      if (linkedTypeName.isNotEmpty) {
        buffer.write(typeName(linkedTypeName));
        if (param.name.isNotEmpty) {
          buffer.write(' ');
        }
      }
      if (param.name.isNotEmpty) {
        buffer.write(parameterName(param.name));
      }
    }

    if (param.hasDefaultValue) {
      buffer.write(' = ');
      buffer.write(defaultValue(param.defaultValue!));
    }

    buffer.write(suffix);
    return buffer.toString();
  }
}
