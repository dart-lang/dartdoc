// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(srawlins): Add Renderer annotations for more types as the mustachio
// implementation matures.
@Renderer(#renderIndex, Context<PackageTemplateData>())
library dartdoc.templates;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/mustachio/annotations.dart';
import 'package:meta/meta.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

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
];

const String _headerPlaceholder = '{{! header placeholder }}';
const String _footerPlaceholder = '{{! footer placeholder }}';
const String _footerTextPlaceholder = '{{! footer-text placeholder }}';

Future<Map<String, String>> _loadPartials(
    _TemplatesLoader templatesLoader,
    List<String> headerPaths,
    List<String> footerPaths,
    List<String> footerTextPaths) async {
  var partials = await templatesLoader.loadPartials();

  void replacePlaceholder(String key, String placeholder, List<String> paths) {
    var template = partials[key];
    if (template != null && paths != null && paths.isNotEmpty) {
      var replacement = paths
          .map((p) =>
              templatesLoader.loader.provider.getFile(p).readAsStringSync())
          .join('\n');
      template = template.replaceAll(placeholder, replacement);
      partials[key] = template;
    }
  }

  replacePlaceholder('head', _headerPlaceholder, headerPaths);
  replacePlaceholder('footer', _footerPlaceholder, footerPaths);
  replacePlaceholder('footer', _footerTextPlaceholder, footerTextPaths);

  return partials;
}

abstract class _TemplatesLoader {
  ResourceLoader get loader;

  Future<Map<String, String>> loadPartials();

  Future<String> loadTemplate(String name);
}

/// Loads default templates included in the Dartdoc program.
class _DefaultTemplatesLoader extends _TemplatesLoader {
  final String _format;
  final List<String> _partials;

  @override
  final ResourceLoader loader;

  factory _DefaultTemplatesLoader.create(String format, ResourceLoader loader) {
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
    return _DefaultTemplatesLoader(format, partials, loader);
  }

  _DefaultTemplatesLoader(this._format, this._partials, this.loader);

  @override
  Future<Map<String, String>> loadPartials() async {
    var templates = <String, String>{};
    for (var name in _partials) {
      var uri = 'package:dartdoc/templates/$_format/_$name.$_format';
      templates[name] = await loader.loadAsString(uri);
    }
    return templates;
  }

  @override
  Future<String> loadTemplate(String name) =>
      loader.loadAsString('package:dartdoc/templates/$_format/$name.$_format');
}

/// Loads templates from a specified Directory.
class _DirectoryTemplatesLoader extends _TemplatesLoader {
  final Folder _directory;
  final String _format;

  @override
  final ResourceLoader loader;

  _DirectoryTemplatesLoader(this._directory, this._format, this.loader);

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
  Future<String> loadTemplate(String name) async {
    var file = _directory.getChildAssumingFile('$name.$_format');
    if (!file.exists) {
      throw DartdocFailure('Missing required template file: $name.$_format');
    }
    return file.readAsStringSync();
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
    var footerTextPaths = context.footerText;
    var resourceLoader = ResourceLoader(context.resourceProvider);

    if (templatesDir != null) {
      return _fromDirectory(
          context.resourceProvider.getFolder(templatesDir), format,
          loader: resourceLoader,
          headerPaths: context.header,
          footerPaths: context.footer,
          footerTextPaths: footerTextPaths);
    } else {
      return createDefault(format,
          loader: resourceLoader,
          headerPaths: context.header,
          footerPaths: context.footer,
          footerTextPaths: footerTextPaths);
    }
  }

  @visibleForTesting
  static Future<Templates> createDefault(String format,
      {@required ResourceLoader loader,
      List<String> headerPaths = const <String>[],
      List<String> footerPaths = const <String>[],
      List<String> footerTextPaths = const <String>[]}) async {
    return _create(_DefaultTemplatesLoader.create(format, loader),
        headerPaths: headerPaths,
        footerPaths: footerPaths,
        footerTextPaths: footerTextPaths);
  }

  static Future<Templates> _fromDirectory(Folder dir, String format,
      {@required ResourceLoader loader,
      @required List<String> headerPaths,
      @required List<String> footerPaths,
      @required List<String> footerTextPaths}) async {
    return _create(_DirectoryTemplatesLoader(dir, format, loader),
        headerPaths: headerPaths,
        footerPaths: footerPaths,
        footerTextPaths: footerTextPaths);
  }

  static Future<Templates> _create(_TemplatesLoader templatesLoader,
      {@required List<String> headerPaths,
      @required List<String> footerPaths,
      @required List<String> footerTextPaths}) async {
    var partials = await _loadPartials(
        templatesLoader, headerPaths, footerPaths, footerTextPaths);

    Template _partial(String name) {
      var partial = partials[name];
      if (partial == null || partial.isEmpty) {
        throw StateError('Did not find partial "$name"');
      }
      return Template(partial);
    }

    Future<Template> _loadTemplate(String templatePath) async {
      var templateContents = await templatesLoader.loadTemplate(templatePath);
      return Template(templateContents, partialResolver: _partial);
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
