// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:dartdoc/src/render/language_feature_renderer.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/render/type_parameters_renderer.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';

// TODO(kallentu): Inline and remove all the renderers in this renderer factory.
// Then remove the factory itself.
class HtmlRenderFactory {
  const HtmlRenderFactory();

  DocumentationRenderer get documentationRenderer =>
      const DocumentationRendererHtml();

  ElementTypeRenderer<CallableElementType> get callableElementTypeRenderer =>
      const CallableElementTypeRendererHtml();

  ElementTypeRenderer<FunctionTypeElementType>
      get functionTypeElementTypeRenderer =>
          const FunctionTypeElementTypeRendererHtml();

  ElementTypeRenderer<ParameterizedElementType>
      get parameterizedElementTypeRenderer =>
          const ParameterizedElementTypeRendererHtml();

  ElementTypeRenderer<RecordElementType> get recordElementTypeRenderer =>
      const RecordElementTypeRendererHtml();

  ElementTypeRenderer<AliasedElementType> get aliasedElementTypeRenderer =>
      const AliasedElementTypeRendererHtml();

  EnumFieldRenderer get enumFieldRenderer => const EnumFieldRendererHtml();

  ModelElementRenderer get modelElementRenderer =>
      const ModelElementRendererHtml();

  ParameterRenderer get parameterRenderer => const ParameterRendererHtml();

  ParameterRenderer get parameterRendererDetailed =>
      const ParameterRendererHtmlList();

  TypeParametersRenderer get typeParametersRenderer =>
      const TypeParametersRendererHtml();

  TypedefRenderer get typedefRenderer => const TypedefRendererHtml();

  LanguageFeatureRenderer get languageFeatureRenderer =>
      const LanguageFeatureRendererHtml();

  SourceCodeRenderer get sourceCodeRenderer => const SourceCodeRendererHtml();

  ElementTypeRenderer<AliasedUndefinedElementType>
      get aliasedUndefinedElementTypeRenderer =>
          const AliasedUndefinedElementTypeRendererHtml();
}
