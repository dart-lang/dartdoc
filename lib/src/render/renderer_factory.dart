// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/render/attribute_renderer.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:dartdoc/src/render/language_feature_renderer.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/render/template_renderer.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

abstract class RendererFactory {
  const RendererFactory();

  LayoutRenderer get templateRenderer;

  CategoryRenderer get categoryRenderer;

  DocumentationRenderer get documentationRenderer;

  AttributeRenderer get attributeRenderer;

  LanguageFeatureRenderer get languageFeatureRenderer;

  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer;

  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer;

  ElementTypeRenderer<RecordElementType> get recordElementTypeRenderer;

  ElementTypeRenderer<AliasedElementType> get aliasedElementTypeRenderer;

  ElementTypeRenderer<AliasedUndefinedElementType>
      get aliasedUndefinedElementTypeRenderer;

  ElementTypeRenderer<CallableElementType> get callableElementTypeRenderer;

  EnumFieldRenderer get enumFieldRenderer;

  ModelElementRenderer get modelElementRenderer;

  ParameterRenderer get parameterRenderer;

  ParameterRenderer get parameterRendererDetailed;

  SourceCodeRenderer get sourceCodeRenderer;

  TypeParametersRenderer get typeParametersRenderer;

  TypedefRenderer get typedefRenderer;
}

class HtmlRenderFactory extends RendererFactory {
  const HtmlRenderFactory();

  @override
  LayoutRenderer get templateRenderer => const HtmlLayoutRenderer();

  @override
  CategoryRenderer get categoryRenderer => const CategoryRendererHtml();

  @override
  DocumentationRenderer get documentationRenderer =>
      const DocumentationRendererHtml();

  @override
  ElementTypeRenderer<CallableElementType> get callableElementTypeRenderer =>
      const CallableElementTypeRendererHtml();

  @override
  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer =>
          const FunctionTypeElementTypeRendererHtml();

  @override
  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer =>
          const ParameterizedElementTypeRendererHtml();

  @override
  ElementTypeRenderer<RecordElementType> get recordElementTypeRenderer =>
      const RecordElementTypeRendererHtml();

  @override
  ElementTypeRenderer<AliasedElementType> get aliasedElementTypeRenderer =>
      const AliasedElementTypeRendererHtml();

  @override
  EnumFieldRenderer get enumFieldRenderer => const EnumFieldRendererHtml();

  @override
  ModelElementRenderer get modelElementRenderer =>
      const ModelElementRendererHtml();

  @override
  ParameterRenderer get parameterRenderer => const ParameterRendererHtml();

  @override
  ParameterRenderer get parameterRendererDetailed =>
      const ParameterRendererHtmlList();

  @override
  TypeParametersRenderer get typeParametersRenderer =>
      const TypeParametersRendererHtml();

  @override
  TypedefRenderer get typedefRenderer => const TypedefRendererHtml();

  @override
  LanguageFeatureRenderer get languageFeatureRenderer =>
      const LanguageFeatureRendererHtml();

  @override
  SourceCodeRenderer get sourceCodeRenderer => const SourceCodeRendererHtml();

  @override
  AttributeRenderer get attributeRenderer => const AttributeRendererHtml();

  @override
  ElementTypeRenderer<AliasedUndefinedElementType>
      get aliasedUndefinedElementTypeRenderer =>
          const AliasedUndefinedElementTypeRendererHtml();
}
