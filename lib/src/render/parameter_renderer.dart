// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/parameter.dart';

/// Render HTML in an extended vertical format using <ol> tag.
class ParameterRendererHtmlList extends ParameterRendererHtml {
  @override
  String listItem(String listItem) => '<li>$listItem</li>\n';
  @override
  // TODO(jcollins-g): consider comma separated lists and more advanced css.
  String orderedList(String listItems) =>
      '<ol class="parameter-list">$listItems</ol>\n';
}

/// Render HTML suitable for a single, wrapped line.
class ParameterRendererHtml extends ParameterRenderer {
  @override
  String listItem(String listItem) => '${listItem}<wbr>';
  @override
  String orderedList(String listItems) => listItems;
  @override
  String annotation(String annotation) => '<span>$annotation</span>';
  @override
  String covariant(String covariant) => '<span>$covariant</span>';
  @override
  String defaultValue(String defaultValue) =>
      '<span class="default-value">$defaultValue</span>';
  @override
  String parameter(String parameter, String htmlId) =>
      '<span class="parameter" id="${htmlId}">$parameter</span>';
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
      {showMetadata = true, showNames = true}) {
    var positionalParams =
        parameters.where((Parameter p) => p.isRequiredPositional).toList();
    var optionalPositionalParams =
        parameters.where((Parameter p) => p.isOptionalPositional).toList();
    var namedParams = parameters.where((Parameter p) => p.isNamed).toList();

    var positional = '', optional = '', named = '';
    if (positionalParams.isNotEmpty) {
      positional = _linkedParameterSublist(positionalParams,
          optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty,
          showMetadata: showMetadata, showNames: showNames);
    }
    if (optionalPositionalParams.isNotEmpty) {
      optional = _linkedParameterSublist(
          optionalPositionalParams, namedParams.isNotEmpty,
          openBracket: '[',
          closeBracket: ']',
          showMetadata: showMetadata,
          showNames: showNames);
    }
    if (namedParams.isNotEmpty) {
      named = _linkedParameterSublist(namedParams, false,
          openBracket: '{',
          closeBracket: '}',
          showMetadata: showMetadata,
          showNames: showNames);
    }
    return (orderedList(positional + optional + named));
  }

  String _linkedParameterSublist(List<Parameter> parameters, bool trailingComma,
      {String openBracket = '',
      String closeBracket = '',
      showMetadata = true,
      showNames = true}) {
    var builder = StringBuffer();
    parameters.forEach((p) {
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
      var renderedParam =
          _renderParam(p, showMetadata: showMetadata, showNames: showNames);
      builder.write(
          listItem(parameter(prefix + renderedParam + suffix, p.htmlId)));
    });
    return builder.toString();
  }

  String _renderParam(Parameter param,
      {showMetadata = true, showNames = true}) {
    var buf = StringBuffer();
    var paramModelType = param.modelType;

    if (showMetadata && param.hasAnnotations) {
      buf.write(param.annotations.map(annotation).join(' ') + ' ');
    }
    if (param.isRequiredNamed) {
      buf.write(required('required') + ' ');
    }
    if (param.isCovariant) {
      buf.write(covariant('covariant') + ' ');
    }
    if (paramModelType is CallableElementTypeMixin ||
        paramModelType.type is FunctionType) {
      String returnTypeName;
      if (paramModelType.isTypedef) {
        returnTypeName = paramModelType.linkedName;
      } else {
        returnTypeName = paramModelType.createLinkedReturnTypeName();
      }
      buf.write(typeName(returnTypeName));
      if (showNames) {
        buf.write(' ${parameterName(param.name)}');
      } else if (paramModelType.isTypedef ||
          paramModelType.type is FunctionType) {
        buf.write(' ${parameterName(paramModelType.name)}');
      }
      if (!paramModelType.isTypedef && paramModelType is DefinedElementType) {
        buf.write('(');
        buf.write(renderLinkedParams(paramModelType.element.parameters,
            showMetadata: showMetadata, showNames: showNames));
        buf.write(')');
      }
      if (!paramModelType.isTypedef && paramModelType.type is FunctionType) {
        buf.write('(');
        buf.write(renderLinkedParams(
            (paramModelType as UndefinedElementType).parameters,
            showMetadata: showMetadata,
            showNames: showNames));
        buf.write(')');
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
      if (param.isNamed) {
        buf.write(': ');
      } else {
        buf.write(' = ');
      }
      buf.write(defaultValue(param.defaultValue));
    }
    return buf.toString();
  }
}
