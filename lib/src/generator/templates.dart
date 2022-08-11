// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Renderer annotations direct the Mustachio code generators to generate render
// functions. These are generated into:
//
// * templates.aot_renderers_for_html.dart
// * templates.aot_renderers_for_markdown.dart
// * templates.runtime_renderers.dart
//
// See tool/mustachio/README.md for details.

@Renderer(#renderCategory, Context<CategoryTemplateData>(), 'category',
    visibleTypes: _visibleTypes)
@Renderer(#renderClass, Context<ClassTemplateData>(), 'class')
@Renderer(#renderConstructor, Context<ConstructorTemplateData>(), 'constructor')
@Renderer(#renderEnum, Context<EnumTemplateData>(), 'enum')
@Renderer(#renderError, Context<PackageTemplateData>(), '404error')
@Renderer(#renderExtension, Context<ExtensionTemplateData>(), 'extension')
@Renderer(#renderFunction, Context<FunctionTemplateData>(), 'function')
@Renderer(#renderIndex, Context<PackageTemplateData>(), 'index')
@Renderer(#renderLibrary, Context<LibraryTemplateData>(), 'library')
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
library dartdoc.templates;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.aot_renderers_for_html.dart'
    as aot_renderers_for_html;
import 'package:dartdoc/src/generator/templates.aot_renderers_for_md.dart'
    as aot_renderers_for_md;
import 'package:dartdoc/src/generator/templates.runtime_renderers.dart'
    as runtime_renderers;
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/model/model.dart';
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
  FeatureSet,
  FunctionTypeElementType,
  InheritingContainer,
  LanguageFeature,
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
  String renderClass<T extends Class>(ClassTemplateData context);
  String renderConstructor(ConstructorTemplateData context);
  String renderEnum(EnumTemplateData context);
  String renderError(PackageTemplateData context);
  String renderExtension(ExtensionTemplateData context);
  String renderFunction(FunctionTemplateData context);
  String renderIndex(PackageTemplateData context);
  String renderLibrary(LibraryTemplateData context);
  String renderMethod(MethodTemplateData context);
  String renderMixin(MixinTemplateData context);
  String renderProperty(PropertyTemplateData context);
  String renderSearchPage(PackageTemplateData context);
  String renderSidebarForContainer(
      TemplateDataWithContainer<Documentable> context);
  String renderSidebarForLibrary(TemplateDataWithLibrary<Documentable> context);
  String renderTopLevelProperty(TopLevelPropertyTemplateData context);
  String renderTypedef(TypedefTemplateData context);

  /// Creates a [Templates] instance either from the default set of templates,
  /// or a custom set if the 'templatesDir' Dartdoc option is used.
  ///
  /// [forceRuntimeTemplates] should only be given [true] during tests.
  static Future<Templates> fromContext(DartdocGeneratorOptionContext context,
      {bool forceRuntimeTemplates = false}) async {
    var templatesDir = context.templatesDir;
    var format = context.format;

    if (templatesDir != null) {
      return RuntimeTemplates._create(
          context.resourceProvider.getFolder(templatesDir), format,
          resourceProvider: context.resourceProvider);
    } else if (forceRuntimeTemplates) {
      var directory = await context.resourceProvider
          .getResourceFolder('package:dartdoc/templates/$format');
      return RuntimeTemplates._create(directory, format,
          resourceProvider: context.resourceProvider);
    } else if (format == 'html') {
      return HtmlAotTemplates();
    } else if (format == 'md') {
      return MarkdownAotTemplates();
    } else {
      throw ArgumentError.value(format, 'format');
    }
  }
}

/// The [Templates] implementation which uses the render functions generated
/// from the default Dartdoc HTML templates.
class HtmlAotTemplates implements Templates {
  @override
  String renderCategory(CategoryTemplateData context) =>
      aot_renderers_for_html.renderCategory(context);

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
  String renderFunction(FunctionTemplateData context) =>
      aot_renderers_for_html.renderFunction(context);

  @override
  String renderIndex(PackageTemplateData context) =>
      aot_renderers_for_html.renderIndex(context);

  @override
  String renderLibrary(LibraryTemplateData context) =>
      aot_renderers_for_html.renderLibrary(context);

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

/// The [Templates] implementation which uses the render functions generated
/// from the default Dartdoc Markdown templates.
class MarkdownAotTemplates implements Templates {
  @override
  String renderCategory(CategoryTemplateData context) =>
      aot_renderers_for_md.renderCategory(context);

  @override
  String renderClass<T extends Class>(ClassTemplateData context) =>
      aot_renderers_for_md.renderClass(context);

  @override
  String renderConstructor(ConstructorTemplateData context) =>
      aot_renderers_for_md.renderConstructor(context);

  @override
  String renderEnum(EnumTemplateData context) =>
      aot_renderers_for_md.renderEnum(context);

  @override
  String renderError(PackageTemplateData context) =>
      aot_renderers_for_md.renderError();

  @override
  String renderExtension(ExtensionTemplateData context) =>
      aot_renderers_for_md.renderExtension(context);

  @override
  String renderFunction(FunctionTemplateData context) =>
      aot_renderers_for_md.renderFunction(context);

  @override
  String renderIndex(PackageTemplateData context) =>
      aot_renderers_for_md.renderIndex(context);

  @override
  String renderLibrary(LibraryTemplateData context) =>
      aot_renderers_for_md.renderLibrary(context);

  @override
  String renderMethod(MethodTemplateData context) =>
      aot_renderers_for_md.renderMethod(context);

  @override
  String renderMixin(MixinTemplateData context) =>
      aot_renderers_for_md.renderMixin(context);

  @override
  String renderProperty(PropertyTemplateData context) =>
      aot_renderers_for_md.renderProperty(context);

  @override
  String renderSearchPage(PackageTemplateData context) =>
      aot_renderers_for_md.renderSearchPage(context);

  @override
  String renderSidebarForContainer(
          TemplateDataWithContainer<Documentable> context) =>
      aot_renderers_for_md.renderSidebarForContainer();

  @override
  String renderSidebarForLibrary(
          TemplateDataWithLibrary<Documentable> context) =>
      aot_renderers_for_md.renderSidebarForLibrary();

  @override
  String renderTopLevelProperty(TopLevelPropertyTemplateData context) =>
      aot_renderers_for_md.renderTopLevelProperty(context);

  @override
  String renderTypedef(TypedefTemplateData context) =>
      aot_renderers_for_md.renderTypedef(context);
}

/// The collection of [Template] objects parsed at runtime.
class RuntimeTemplates implements Templates {
  @override
  String renderCategory(CategoryTemplateData context) =>
      runtime_renderers.renderCategory(context, _categoryTemplate);

  @override
  String renderClass<T extends Class>(ClassTemplateData context) =>
      runtime_renderers.renderClass(context, _classTemplate);

  @override
  String renderConstructor(ConstructorTemplateData context) =>
      runtime_renderers.renderConstructor(context, _constructorTemplate);

  @override
  String renderEnum(EnumTemplateData context) =>
      runtime_renderers.renderEnum(context, _enumTemplate);

  @override
  String renderError(PackageTemplateData context) =>
      runtime_renderers.renderError(context, _errorTemplate);

  @override
  String renderExtension(ExtensionTemplateData context) =>
      runtime_renderers.renderExtension(context, _extensionTemplate);

  @override
  String renderFunction(FunctionTemplateData context) =>
      runtime_renderers.renderFunction(context, _functionTemplate);

  @override
  String renderIndex(PackageTemplateData context) =>
      runtime_renderers.renderIndex(context, _indexTemplate);

  @override
  String renderLibrary(LibraryTemplateData context) =>
      runtime_renderers.renderLibrary(context, _libraryTemplate);

  @override
  String renderMethod(MethodTemplateData context) =>
      runtime_renderers.renderMethod(context, _methodTemplate);

  @override
  String renderMixin(MixinTemplateData context) =>
      runtime_renderers.renderMixin(context, _mixinTemplate);

  @override
  String renderProperty(PropertyTemplateData context) =>
      runtime_renderers.renderProperty(context, _propertyTemplate);

  @override
  String renderSearchPage(PackageTemplateData context) =>
      runtime_renderers.renderSearchPage(context, _searchPageTemplate);

  @override
  String renderSidebarForContainer(
          TemplateDataWithContainer<Documentable> context) =>
      runtime_renderers.renderSidebarForContainer(
          context, _sidebarContainerTemplate);

  @override
  String renderSidebarForLibrary(
          TemplateDataWithLibrary<Documentable> context) =>
      runtime_renderers.renderSidebarForLibrary(
          context, _sidebarLibraryTemplate);

  @override
  String renderTopLevelProperty(TopLevelPropertyTemplateData context) =>
      runtime_renderers.renderTopLevelProperty(
          context, _topLevelPropertyTemplate);

  @override
  String renderTypedef(TypedefTemplateData context) =>
      runtime_renderers.renderTypedef(context, _typedefTemplate);

  final Template _categoryTemplate;
  final Template _classTemplate;
  final Template _constructorTemplate;
  final Template _enumTemplate;
  final Template _errorTemplate;
  final Template _extensionTemplate;
  final Template _functionTemplate;
  final Template _indexTemplate;
  final Template _libraryTemplate;
  final Template _methodTemplate;
  final Template _mixinTemplate;
  final Template _propertyTemplate;
  final Template _searchPageTemplate;
  final Template _sidebarContainerTemplate;
  final Template _sidebarLibraryTemplate;
  final Template _topLevelPropertyTemplate;
  final Template _typedefTemplate;

  /// Creates a [Templates] from a custom set of template files, found in [dir].
  static Future<Templates> _create(Folder dir, String format,
      {required ResourceProvider resourceProvider}) async {
    Future<Template> loadTemplate(String templatePath) {
      var templateFile = dir.getChildAssumingFile('$templatePath.$format');
      if (!templateFile.exists) {
        throw DartdocFailure(
            'Missing required template file: $templatePath.$format');
      }
      return Template.parse(templateFile,
          partialResolver: (String partialName) async =>
              dir.getChildAssumingFile('_$partialName.$format'));
    }

    var indexTemplate = await loadTemplate('index');
    var libraryTemplate = await loadTemplate('library');
    var searchPageTemplate = await loadTemplate('search');
    var sidebarContainerTemplate = await loadTemplate('_sidebar_for_container');
    var sidebarLibraryTemplate = await loadTemplate('_sidebar_for_library');
    var categoryTemplate = await loadTemplate('category');
    var classTemplate = await loadTemplate('class');
    var constructorTemplate = await loadTemplate('constructor');
    var enumTemplate = await loadTemplate('enum');
    var errorTemplate = await loadTemplate('404error');
    var extensionTemplate = await loadTemplate('extension');
    var functionTemplate = await loadTemplate('function');
    var methodTemplate = await loadTemplate('method');
    var mixinTemplate = await loadTemplate('mixin');
    var propertyTemplate = await loadTemplate('property');
    var topLevelPropertyTemplate = await loadTemplate('top_level_property');
    var typeDefTemplate = await loadTemplate('typedef');

    return RuntimeTemplates._(
      categoryTemplate,
      libraryTemplate,
      classTemplate,
      constructorTemplate,
      enumTemplate,
      errorTemplate,
      extensionTemplate,
      functionTemplate,
      indexTemplate,
      methodTemplate,
      mixinTemplate,
      propertyTemplate,
      searchPageTemplate,
      sidebarContainerTemplate,
      sidebarLibraryTemplate,
      topLevelPropertyTemplate,
      typeDefTemplate,
    );
  }

  RuntimeTemplates._(
    this._categoryTemplate,
    this._libraryTemplate,
    this._classTemplate,
    this._constructorTemplate,
    this._enumTemplate,
    this._errorTemplate,
    this._extensionTemplate,
    this._functionTemplate,
    this._indexTemplate,
    this._methodTemplate,
    this._mixinTemplate,
    this._propertyTemplate,
    this._searchPageTemplate,
    this._sidebarContainerTemplate,
    this._sidebarLibraryTemplate,
    this._topLevelPropertyTemplate,
    this._typedefTemplate,
  );
}
