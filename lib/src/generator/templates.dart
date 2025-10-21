// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Renderer annotations direct the Mustachio code generators to generate render
// functions. These are generated into:
//
// * templates.aot_renderers_for_html.dart
//
// See tool/mustachio/README.md for details.

@Renderer(#renderCategory, Context<CategoryTemplateData>(), 'category',
    visibleTypes: _visibleTypes)
@Renderer(#renderCategoryRedirect, Context<CategoryTemplateData>(),
    'category_redirect',
    visibleTypes: _visibleTypes)
@Renderer(#renderClass, Context<ClassTemplateData>(), 'class')
@Renderer(#renderConstructor, Context<ConstructorTemplateData>(), 'constructor')
@Renderer(#renderEnum, Context<EnumTemplateData>(), 'enum')
@Renderer(#renderError, Context<PackageTemplateData>(), '404error')
@Renderer(#renderExtension, Context<ExtensionTemplateData>(), 'extension')
@Renderer(#renderExtensionType, Context<ExtensionTypeTemplateData>(),
    'extension_type')
@Renderer(#renderFunction, Context<FunctionTemplateData>(), 'function')
@Renderer(#renderIndex, Context<PackageTemplateData>(), 'index')
@Renderer(#renderLibrary, Context<LibraryTemplateData>(), 'library')
@Renderer(
    #renderLibraryRedirect, Context<LibraryTemplateData>(), 'library_redirect')
@Renderer(#renderMethod, Context<MethodTemplateData>(), 'method')
@Renderer(#renderMixin, Context<MixinTemplateData>(), 'mixin')
@Renderer(#renderProperty, Context<PropertyTemplateData>(), 'property')
@Renderer(#renderSearchPage, Context<PackageTemplateData>(), 'search')
@Renderer(
    #renderSidebarForContainer,
    Context<TemplateDataWithContainer<Documentable>>(),
    '_sidebar_for_container')
@Renderer(#renderSidebarForLibrary,
    Context<TemplateDataWithLibrary<Documentable>>(), '_sidebar_for_library')
@Renderer(#renderTopLevelProperty, Context<TopLevelPropertyTemplateData>(),
    'top_level_property')
@Renderer(#renderTypedef, Context<TypedefTemplateData>(), 'typedef')
library;

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.aot_renderers_for_html.dart'
    as aot_renderers_for_html;
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/tag.dart';
import 'package:dartdoc/src/mustachio/annotations.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';

/// The set of types which are visible to the Mustachio renderers.
///
/// These are the types whose fields are referenced in templates. The set
/// only needs to be specified on one `@Renderer` annotation; above, they are
/// only referenced in the first.
const _visibleTypes = {
  Annotation,
  Callable,
  Category,
  Class,
  Constructor,
  DefinedElementType,
  Documentable,
  ElementType,
  Enum,
  Extension,
  ExtensionType,
  ExternalItem,
  FunctionTypeElementType,
  InheritingContainer,
  Tag,
  Library,
  LibraryContainer,
  Method,
  ModelElement,
  Package,
  // For getters like `isNotEmpty`; perhaps a smell, but currently in use.
  String,
  TopLevelVariable,
  TypeParameter,
};

/// The collection of [Template] objects.
abstract class Templates {
  String renderCategory(CategoryTemplateData context);
  String renderCategoryRedirect(CategoryTemplateData context);
  String renderClass<T extends Class>(ClassTemplateData context);
  String renderConstructor(ConstructorTemplateData context);
  String renderEnum(EnumTemplateData context);
  String renderError(PackageTemplateData context);
  String renderExtension(ExtensionTemplateData context);
  String renderExtensionType(ExtensionTypeTemplateData context);
  String renderFunction(FunctionTemplateData context);
  String renderIndex(PackageTemplateData context);
  String renderLibrary(LibraryTemplateData context);
  String renderLibraryRedirect(LibraryTemplateData context);
  String renderMethod(MethodTemplateData context);
  String renderMixin(MixinTemplateData context);
  String renderProperty(PropertyTemplateData context);
  String renderSearchPage(PackageTemplateData context);
  String renderSidebarForContainer(
      TemplateDataWithContainer<Documentable> context);
  String renderSidebarForLibrary(TemplateDataWithLibrary<Documentable> context);
  String renderTopLevelProperty(TopLevelPropertyTemplateData context);
  String renderTypedef(TypedefTemplateData context);
}

/// The [Templates] implementation which uses the render functions generated
/// from the default Dartdoc HTML templates.
class HtmlAotTemplates implements Templates {
  @override
  String renderCategory(CategoryTemplateData context) =>
      aot_renderers_for_html.renderCategory(context);

  @override
  String renderCategoryRedirect(CategoryTemplateData context) =>
      aot_renderers_for_html.renderCategoryRedirect(context);

  @override
  String renderClass<T extends Class>(ClassTemplateData context) =>
      aot_renderers_for_html.renderClass(context);

  @override
  String renderConstructor(ConstructorTemplateData context) =>
      aot_renderers_for_html.renderConstructor(context);

  @override
  String renderEnum(EnumTemplateData context) =>
      aot_renderers_for_html.renderEnum(context);

  @override
  String renderError(PackageTemplateData context) =>
      aot_renderers_for_html.renderError(context);

  @override
  String renderExtension(ExtensionTemplateData context) =>
      aot_renderers_for_html.renderExtension(context);

  @override
  String renderExtensionType(ExtensionTypeTemplateData context) =>
      aot_renderers_for_html.renderExtensionType(context);

  @override
  String renderFunction(FunctionTemplateData context) =>
      aot_renderers_for_html.renderFunction(context);

  @override
  String renderIndex(PackageTemplateData context) =>
      aot_renderers_for_html.renderIndex(context);

  @override
  String renderLibrary(LibraryTemplateData context) =>
      aot_renderers_for_html.renderLibrary(context);

  @override
  String renderLibraryRedirect(LibraryTemplateData context) =>
      aot_renderers_for_html.renderLibraryRedirect(context);

  @override
  String renderMethod(MethodTemplateData context) =>
      aot_renderers_for_html.renderMethod(context);

  @override
  String renderMixin(MixinTemplateData context) =>
      aot_renderers_for_html.renderMixin(context);

  @override
  String renderProperty(PropertyTemplateData context) =>
      aot_renderers_for_html.renderProperty(context);

  @override
  String renderSearchPage(PackageTemplateData context) =>
      aot_renderers_for_html.renderSearchPage(context);

  @override
  String renderSidebarForContainer(
          TemplateDataWithContainer<Documentable> context) =>
      aot_renderers_for_html.renderSidebarForContainer(context);

  @override
  String renderSidebarForLibrary(
          TemplateDataWithLibrary<Documentable> context) =>
      aot_renderers_for_html.renderSidebarForLibrary(context);

  @override
  String renderTopLevelProperty(TopLevelPropertyTemplateData context) =>
      aot_renderers_for_html.renderTopLevelProperty(context);

  @override
  String renderTypedef(TypedefTemplateData context) =>
      aot_renderers_for_html.renderTypedef(context);
}
