// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/element_type.dart';

/// Render HTML in an extended vertical format using <ol> tag.
class ParameterRendererHtmlList extends ParameterRendererHtml {
  ParameterRendererHtmlList({bool showMetadata = true, bool showNames = true})
      : super(showMetadata: showMetadata, showNames: showNames);
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
  final bool showMetadata;
  @override
  final bool showNames;
  ParameterRendererHtml({this.showMetadata = true, this.showNames = true});

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

abstract class ParameterRenderer {
  bool get showMetadata;
  bool get showNames;

  String listItem(String item);
  String orderedList(String listItems);
  String annotation(String annotation);
  String covariant(String covariant);
  String defaultValue(String defaultValue);
  String parameter(String parameter, String id);
  String parameterName(String parameterName);
  String typeName(String typeName);
  String required(String required);

  String _linkedParameterSublist(List<Parameter> parameters, bool trailingComma,
      {String thisOpenBracket = '', String thisCloseBracket = ''}) {
    StringBuffer builder = StringBuffer();
    parameters.forEach((p) {
      String prefix = '';
      String suffix = '';
      if (identical(p, parameters.first)) {
        prefix = thisOpenBracket;
      }
      if (identical(p, parameters.last)) {
        suffix += thisCloseBracket;
        if (trailingComma) suffix += ', ';
      } else {
        suffix += ', ';
      }
      builder.write(
          listItem(parameter(prefix + renderParam(p) + suffix, p.htmlId)));
    });
    return builder.toString();
  }

  String renderLinkedParams(List<Parameter> parameters) {
    List<Parameter> positionalParams =
        parameters.where((Parameter p) => p.isRequiredPositional).toList();
    List<Parameter> optionalPositionalParams =
        parameters.where((Parameter p) => p.isOptionalPositional).toList();
    List<Parameter> namedParams =
        parameters.where((Parameter p) => p.isNamed).toList();

    String positional = '', optional = '', named = '';
    if (positionalParams.isNotEmpty) {
      positional = _linkedParameterSublist(positionalParams,
          optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty);
    }
    if (optionalPositionalParams.isNotEmpty) {
      optional = _linkedParameterSublist(
          optionalPositionalParams, namedParams.isNotEmpty,
          thisOpenBracket: '[', thisCloseBracket: ']');
    }
    if (namedParams.isNotEmpty) {
      named = _linkedParameterSublist(namedParams, false,
          thisOpenBracket: '{', thisCloseBracket: '}');
    }
    return (orderedList(positional + optional + named));
  }

  String renderParam(Parameter param) {
    StringBuffer buf = StringBuffer();
    ElementType paramModelType = param.modelType;

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
          paramModelType is CallableAnonymousElementType ||
          paramModelType.type is FunctionType) {
        buf.write(' ${parameterName(paramModelType.name)}');
      }
      if (!paramModelType.isTypedef && paramModelType is DefinedElementType) {
        buf.write('(');
        buf.write(renderLinkedParams(paramModelType.element.parameters));
        buf.write(')');
      }
      if (!paramModelType.isTypedef && paramModelType.type is FunctionType) {
        buf.write('(');
        buf.write(renderLinkedParams(
            (paramModelType as UndefinedElementType).parameters));
        buf.write(')');
      }
    } else if (param.modelType != null) {
      String linkedTypeName = paramModelType.linkedName;
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
