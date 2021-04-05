// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Annotations only appear on other pages, so there is no template data here.
@Renderer(#renderAnnotation, Context<Annotation>())
@Renderer(#renderCategory, Context<CategoryTemplateData>(),
    visibleTypes: _visibleTypes)
@Renderer(#renderClass, Context<ClassTemplateData>())
@Renderer(#renderConstructor, Context<ConstructorTemplateData>())
@Renderer(#renderEnum, Context<EnumTemplateData>())
@Renderer(#renderError, Context<PackageTemplateData>())
@Renderer(#renderExtension, Context<ExtensionTemplateData>())
@Renderer(#renderFunction, Context<FunctionTemplateData>())
@Renderer(#renderIndex, Context<PackageTemplateData>())
@Renderer(#renderLibrary, Context<LibraryTemplateData>())
@Renderer(#renderMethod, Context<MethodTemplateData>())
@Renderer(#renderMixin, Context<MixinTemplateData>())
@Renderer(#renderProperty, Context<PropertyTemplateData>())
@Renderer(#renderSidebarForContainer,
    Context<TemplateDataWithContainer<Documentable>>())
@Renderer(
    #renderSidebarForLibrary, Context<TemplateDataWithLibrary<Documentable>>())
@Renderer(#renderTopLevelProperty, Context<TopLevelPropertyTemplateData>())
@Renderer(#renderTypedef, Context<TypedefTemplateData>())
library dartdoc.templates;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/mustachio/annotations.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path show Context;

const _visibleTypes = {
  Annotation,
  CallableElementTypeMixin,
  Category,
  Class,
  Constructor,
  DefinedElementType,
  Documentable,
  Enum,
  Extension,
  FeatureSet,
  LanguageFeature,
  Library,
  Method,
  ModelElement,
  Package,
  // For getters like `isNotEmpty`; perhaps a smell, but currently in use.
  String,
  TopLevelVariable,
  TypeParameter,
};

// resource_loader and the Resource API doesn't support viewing resources like
// a directory listing, so we have to explicitly list the partials.
const _partials_html = <String>[
  'callable',
  'callable_multiline',
  'categorization',
  'class',
  'constant',
  'extension',
  'feature_set',
  'footer',
  'head',
  'library',
  'mixin',
  'packages',
  'property',
  'features',
  'documentation',
  'name_summary',
  'search_sidebar',
  'sidebar_for_category',
  'sidebar_for_container',
  'source_code',
  'source_link',
  'sidebar_for_library',
  'type',
  'type_multiline',
  'typedef',
  'typedef_multiline',
  'accessor_getter',
  'accessor_setter',
];

const _partials_md = <String>[
  'accessor_getter',
  'accessor_setter',
  'callable',
  'callable_multiline',
  'categorization',
  'class',
  'constant',
  'documentation',
  'extension',
  'features',
  'feature_set',
  'footer',
  'head',
  'library',
  'mixin',
  'name_summary',
  'property',
  'source_code',
  'source_link',
  'type',
  'type_multiline',
  'typedef',
  'typedef_multiline',
];

abstract class _TemplatesLoader {
  ResourceProvider get resourceProvider;

  Future<Map<String, String>> loadPartials();

  Future<Template> loadTemplate(String name);
}

/// Loads default templates included in the Dartdoc program.
class _DefaultTemplatesLoader extends _TemplatesLoader {
  final String _format;
  final List<String> _partials;

  @override
  final ResourceProvider resourceProvider;

  factory _DefaultTemplatesLoader.create(
      String format, ResourceProvider resourceProvider) {
    List<String> partials;
    switch (format) {
      case 'html':
        partials = _partials_html;
        break;
      case 'md':
        partials = _partials_md;
        break;
      default:
        partials = [];
    }
    return _DefaultTemplatesLoader(format, partials, resourceProvider);
  }

  _DefaultTemplatesLoader(this._format, this._partials, this.resourceProvider);

  @override
  Future<Map<String, String>> loadPartials() async {
    var templates = <String, String>{};
    for (var name in _partials) {
      var uri = 'package:dartdoc/templates/$_format/_$name.$_format';
      templates[name] = await resourceProvider.loadResourceAsString(uri);
    }
    return templates;
  }

  @override
  Future<Template> loadTemplate(String name) async {
    var templateFile = await resourceProvider
        .getResourceFile('package:dartdoc/templates/$_format/$name.$_format');
    return Template.parse(templateFile,
        partialResolver: (String partialName) =>
            resourceProvider.getResourceFile(
                'package:dartdoc/templates/$_format/_$partialName.$_format'));
  }
}

/// Loads templates from a specified Directory.
class _DirectoryTemplatesLoader extends _TemplatesLoader {
  final Folder _directory;
  final String _format;

  @override
  final ResourceProvider resourceProvider;

  _DirectoryTemplatesLoader(
      this._directory, this._format, this.resourceProvider);

  path.Context get pathContext => _directory.provider.pathContext;

  @override
  Future<Map<String, String>> loadPartials() async {
    var partials = <String, String>{};

    for (var file in _directory.getChildren().whereType<File>()) {
      var basename = pathContext.basename(file.path);
      if (basename.startsWith('_') && basename.endsWith('.$_format')) {
        var content = file.readAsStringSync();
        var partialName = basename.substring(1, basename.lastIndexOf('.'));
        partials[partialName] = content;
      }
    }
    return partials;
  }

  @override
  Future<Template> loadTemplate(String name) async {
    var templateFile = _directory.getChildAssumingFile('$name.$_format');
    if (!templateFile.exists) {
      throw DartdocFailure('Missing required template file: $name.$_format');
    }
    return Template.parse(templateFile,
        partialResolver: (String partialName) async =>
            _directory.getChildAssumingFile('_$partialName.$_format'));
  }
}

class Templates {
  final Template categoryTemplate;
  final Template classTemplate;
  final Template extensionTemplate;
  final Template enumTemplate;
  final Template constructorTemplate;
  final Template errorTemplate;
  final Template functionTemplate;
  final Template indexTemplate;
  final Template libraryTemplate;
  final Template methodTemplate;
  final Template mixinTemplate;
  final Template propertyTemplate;
  final Template sidebarContainerTemplate;
  final Template sidebarLibraryTemplate;
  final Template topLevelPropertyTemplate;
  final Template typeDefTemplate;

  static Future<Templates> fromContext(
      DartdocGeneratorOptionContext context) async {
    var templatesDir = context.templatesDir;
    var format = context.format;

    if (templatesDir != null) {
      return _fromDirectory(
          context.resourceProvider.getFolder(templatesDir), format,
          resourceProvider: context.resourceProvider);
    } else {
      return createDefault(format, resourceProvider: context.resourceProvider);
    }
  }

  @visibleForTesting
  static Future<Templates> createDefault(String format,
      {@required ResourceProvider resourceProvider}) async {
    return _create(_DefaultTemplatesLoader.create(format, resourceProvider));
  }

  static Future<Templates> _fromDirectory(Folder dir, String format,
      {@required ResourceProvider resourceProvider}) async {
    return _create(_DirectoryTemplatesLoader(dir, format, resourceProvider));
  }

  static Future<Templates> _create(_TemplatesLoader templatesLoader) async {
    Future<Template> _loadTemplate(String templatePath) async {
      return templatesLoader.loadTemplate(templatePath);
    }

    var indexTemplate = await _loadTemplate('index');
    var libraryTemplate = await _loadTemplate('library');
    var sidebarContainerTemplate =
        await _loadTemplate('_sidebar_for_container');
    var sidebarLibraryTemplate = await _loadTemplate('_sidebar_for_library');
    var categoryTemplate = await _loadTemplate('category');
    var classTemplate = await _loadTemplate('class');
    var extensionTemplate = await _loadTemplate('extension');
    var enumTemplate = await _loadTemplate('enum');
    var functionTemplate = await _loadTemplate('function');
    var methodTemplate = await _loadTemplate('method');
    var constructorTemplate = await _loadTemplate('constructor');
    var errorTemplate = await _loadTemplate('404error');
    var propertyTemplate = await _loadTemplate('property');
    var topLevelPropertyTemplate = await _loadTemplate('top_level_property');
    var typeDefTemplate = await _loadTemplate('typedef');
    var mixinTemplate = await _loadTemplate('mixin');

    return Templates._(
        indexTemplate,
        categoryTemplate,
        libraryTemplate,
        sidebarContainerTemplate,
        sidebarLibraryTemplate,
        classTemplate,
        extensionTemplate,
        enumTemplate,
        functionTemplate,
        methodTemplate,
        constructorTemplate,
        errorTemplate,
        propertyTemplate,
        topLevelPropertyTemplate,
        typeDefTemplate,
        mixinTemplate);
  }

  Templates._(
      this.indexTemplate,
      this.categoryTemplate,
      this.libraryTemplate,
      this.sidebarContainerTemplate,
      this.sidebarLibraryTemplate,
      this.classTemplate,
      this.extensionTemplate,
      this.enumTemplate,
      this.functionTemplate,
      this.methodTemplate,
      this.constructorTemplate,
      this.errorTemplate,
      this.propertyTemplate,
      this.topLevelPropertyTemplate,
      this.typeDefTemplate,
      this.mixinTemplate);
}
