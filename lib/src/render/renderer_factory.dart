// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/template_renderer.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

abstract class RendererFactory {
  TemplateRenderer get templateRenderer;

  CategoryRenderer get categoryRenderer;

  DocumentationRenderer get documentationRenderer;

  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer;

  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer;

  ElementTypeRenderer<CallableElementType> get callableElementTypeRenderer;

  EnumFieldRenderer get enumFieldRenderer;

  ModelElementRenderer get modelElementRenderer;

  ParameterRenderer get parameterRenderer;

  ParameterRenderer get parameterRendererDetailed;

  TypeParametersRenderer get typeParametersRenderer;

  TypedefRenderer get typedefRenderer;
}

class HtmlRenderFactory extends RendererFactory {
  @override
  TemplateRenderer get templateRenderer => HtmlTemplateRenderer();

  @override
  CategoryRenderer get categoryRenderer => CategoryRendererHtml();

  @override
  DocumentationRenderer get documentationRenderer =>
      DocumentationRendererHtml();

  @override
  ElementTypeRenderer<CallableElementType> get callableElementTypeRenderer =>
      CallableElementTypeRendererHtml();

  @override
  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer =>
          FunctionTypeElementTypeRendererHtml();

  @override
  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer =>
          ParameterizedElementTypeRendererHtml();

  @override
  EnumFieldRenderer get enumFieldRenderer => EnumFieldRendererHtml();

  @override
  ModelElementRenderer get modelElementRenderer => ModelElementRendererHtml();

  @override
  ParameterRenderer get parameterRenderer => ParameterRendererHtml();

  @override
  ParameterRenderer get parameterRendererDetailed =>
      ParameterRendererHtmlList();

  @override
  TypeParametersRenderer get typeParametersRenderer =>
      TypeParametersRendererHtml();

  @override
  TypedefRenderer get typedefRenderer => TypedefRendererHtml();
}
