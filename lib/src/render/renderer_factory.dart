// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:dartdoc/src/render/feature_renderer.dart';
import 'package:dartdoc/src/render/language_feature_renderer.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/render/template_renderer.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

abstract class RendererFactory {
  const RendererFactory();

  /// Retrieves the appropriate [RendererFactory] according to the
  /// specified [format]. Currently supports `html` or `md` otherwise
  /// throws an [ArgumentError].
  factory RendererFactory.forFormat(String format) {
    switch (format) {
      case 'html':
        return const HtmlRenderFactory();
      case 'md':
        return const MdRenderFactory();
      default:
        throw ArgumentError('Unsupported renderer format: $format');
    }
  }

  TemplateRenderer get templateRenderer;

  CategoryRenderer get categoryRenderer;

  DocumentationRenderer get documentationRenderer;

  FeatureRenderer get featureRenderer;

  LanguageFeatureRenderer get languageFeatureRenderer;

  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer;

  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer;

  ElementTypeRenderer<AliasedElementType> get aliasedElementTypeRenderer;

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
  TemplateRenderer get templateRenderer => HtmlTemplateRenderer();

  @override
  CategoryRenderer get categoryRenderer => const CategoryRendererHtml();

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
  ElementTypeRenderer<AliasedElementType> get aliasedElementTypeRenderer =>
      AliasedElementTypeRendererHtml();

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
  TypedefRenderer get typedefRenderer => const TypedefRendererHtml();

  @override
  LanguageFeatureRenderer get languageFeatureRenderer =>
      const LanguageFeatureRendererHtml();

  @override
  SourceCodeRenderer get sourceCodeRenderer => SourceCodeRendererHtml();

  @override
  FeatureRenderer get featureRenderer => FeatureRendererHtml();
}

class MdRenderFactory extends RendererFactory {
  const MdRenderFactory();

  @override
  TemplateRenderer get templateRenderer => MdTemplateRenderer();

  @override
  CategoryRenderer get categoryRenderer => const CategoryRendererMd();

  // We render documentation as HTML for now.
  // TODO(jdkoren): explore using documentation directly in the output file.
  @override
  DocumentationRenderer get documentationRenderer =>
      DocumentationRendererHtml();

  @override
  ElementTypeRenderer<CallableElementType> get callableElementTypeRenderer =>
      CallableElementTypeRendererMd();

  @override
  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer =>
          FunctionTypeElementTypeRendererMd();

  @override
  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer =>
          ParameterizedElementTypeRendererMd();

  @override
  ElementTypeRenderer<AliasedElementType> get aliasedElementTypeRenderer =>
      AliasedElementTypeRendererMd();

  @override
  EnumFieldRenderer get enumFieldRenderer => EnumFieldRendererMd();

  @override
  ModelElementRenderer get modelElementRenderer => ModelElementRendererMd();

  @override
  ParameterRenderer get parameterRenderer => ParameterRendererMd();

  @override
  ParameterRenderer get parameterRendererDetailed => parameterRenderer;

  @override
  TypeParametersRenderer get typeParametersRenderer =>
      TypeParametersRendererMd();

  @override
  TypedefRenderer get typedefRenderer => const TypedefRendererMd();

  @override
  LanguageFeatureRenderer get languageFeatureRenderer =>
      const LanguageFeatureRendererMd();

  @override
  SourceCodeRenderer get sourceCodeRenderer => SourceCodeRendererNoop();

  @override
  FeatureRenderer get featureRenderer => FeatureRendererMd();
}
