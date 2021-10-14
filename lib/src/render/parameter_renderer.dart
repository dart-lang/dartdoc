// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/parameter.dart';

/// Render HTML in an extended vertical format using <ol> tag.
class ParameterRendererHtmlList extends ParameterRendererHtml {
  const ParameterRendererHtmlList();

  @override
  String listItem(String item) => '<li>$item</li>\n';
  @override
  // TODO(jcollins-g): consider comma separated lists and more advanced css.
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

class ParameterRendererMd extends ParameterRenderer {
  const ParameterRendererMd();

  @override
  String annotation(String annotation) => annotation;

  @override
  String covariant(String covariant) => covariant;

  @override
  String defaultValue(String defaultValue) => defaultValue;

  @override
  String listItem(String item) => item;

  @override
  String orderedList(String listItems) => listItems;

  @override
  String parameter(String parameter, String id) => parameter;

  @override
  String parameterName(String parameterName) => parameterName;

  @override
  String required(String required) => required;

  @override
  String typeName(String typeName) => typeName;
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
      {bool showMetadata = true, bool showNames = true}) {
    var positionalParams =
        parameters.where((Parameter p) => p.isRequiredPositional).toList();
    var optionalPositionalParams =
        parameters.where((Parameter p) => p.isOptionalPositional).toList();
    var namedParams = parameters.where((Parameter p) => p.isNamed).toList();

    var output = StringBuffer();
    if (positionalParams.isNotEmpty) {
      _renderLinkedParameterSublist(positionalParams, output,
          trailingComma:
              optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty,
          showMetadata: showMetadata,
          showNames: showNames);
    }
    if (optionalPositionalParams.isNotEmpty) {
      _renderLinkedParameterSublist(optionalPositionalParams, output,
          trailingComma: namedParams.isNotEmpty,
          openBracket: '[',
          closeBracket: ']',
          showMetadata: showMetadata,
          showNames: showNames);
    }
    if (namedParams.isNotEmpty) {
      _renderLinkedParameterSublist(namedParams, output,
          trailingComma: false,
          openBracket: '{',
          closeBracket: '}',
          showMetadata: showMetadata,
          showNames: showNames);
    }
    return orderedList(output.toString());
  }

  void _renderLinkedParameterSublist(
      List<Parameter> parameters, StringBuffer output,
      {required bool trailingComma,
      String openBracket = '',
      String closeBracket = '',
      bool showMetadata = true,
      bool showNames = true}) {
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
      var renderedParam = _renderParam(p,
          prefix: prefix,
          suffix: suffix,
          showMetadata: showMetadata,
          showNames: showNames);
      output.write(listItem(parameter(renderedParam, p.htmlId)));
    }
  }

  String _renderParam(
    Parameter param, {
    required String prefix,
    required String suffix,
    bool showMetadata = true,
    bool showNames = true,
  }) {
    var buf = StringBuffer();
    buf.write(prefix);
    var paramModelType = param.modelType;

    if (showMetadata && param.hasAnnotations) {
      for (var a in param.annotations) {
        buf.write(annotation(a.linkedNameWithParameters));
        buf.write(' ');
      }
    }
    if (param.isRequiredNamed) {
      buf.write(required('required') + ' ');
    }
    if (param.isCovariant) {
      buf.write(covariant('covariant') + ' ');
    }
    if (paramModelType is Callable) {
      String returnTypeName;
      if (paramModelType.isTypedef) {
        returnTypeName = paramModelType.linkedName;
      } else {
        returnTypeName = paramModelType.returnType.linkedName;
      }
      buf.write(typeName(returnTypeName));
      if (showNames) {
        buf.write(' ${parameterName(param.name)}');
      } else {
        buf.write(' ${parameterName(paramModelType.name)}');
      }
      if (!paramModelType.isTypedef && paramModelType is DefinedElementType) {
        buf.write('(');
        buf.write(renderLinkedParams(
            (paramModelType as DefinedElementType).modelElement.parameters,
            showMetadata: showMetadata,
            showNames: showNames));
        buf.write(')');
        buf.write(paramModelType.nullabilitySuffix);
      }
      if (!paramModelType.isTypedef) {
        buf.write('(');
        buf.write(renderLinkedParams(paramModelType.parameters,
            showMetadata: showMetadata, showNames: showNames));
        buf.write(')');
        buf.write(paramModelType.nullabilitySuffix);
      }
    } else if (param.modelType != null) {
      var linkedTypeName = paramModelType.linkedName;
      if (linkedTypeName.isNotEmpty) {
        buf.write(typeName(linkedTypeName));
        if (showNames && param.name.isNotEmpty) {
          buf.write(' ');
        }
      }
      if (showNames && param.name.isNotEmpty) {
        buf.write(parameterName(param.name));
      }
    }

    if (param.hasDefaultValue) {
      buf.write(' = ');
      buf.write(defaultValue(param.defaultValue!));
    }

    buf.write(suffix);
    return buf.toString();
  }
}
