// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.templates;

import 'dart:async' show Future;
import 'dart:io' show File, Directory;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/html/resource_loader.dart' as loader;
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

const _partials = <String>[
  'callable',
  'callable_multiline',
  'categorization',
  'class',
  'constant',
  'extension',
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
  'sidebar_for_class',
  'sidebar_for_category',
  'sidebar_for_container',
  'sidebar_for_enum',
  'sidebar_for_extension',
  'source_code',
  'source_link',
  'sidebar_for_library',
  'accessor_getter',
  'accessor_setter',
];

const _requiredTemplates = <String>[
  '404error.html',
  'category.html',
  'class.html',
  'constant.html',
  'constructor.html',
  'enum.html',
  'extension.html',
  'function.html',
  'index.html',
  'library.html',
  'method.html',
  'mixin.html',
  'property.html',
  'top_level_constant.html',
  'top_level_property.html',
  'typedef.html',
];

const String _headerPlaceholder = '{{! header placeholder }}';
const String _footerPlaceholder = '{{! footer placeholder }}';
const String _footerTextPlaceholder = '{{! footer-text placeholder }}';

Future<Map<String, String>> _loadPartials(
    _TemplatesLoader templatesLoader,
    List<String> headerPaths,
    List<String> footerPaths,
    List<String> footerTextPaths) async {
  headerPaths ??= [];
  footerPaths ??= [];
  footerTextPaths ??= [];

  var partials = await templatesLoader.loadPartials();

  void replacePlaceholder(String key, String placeholder, List<String> paths) {
    var template = partials[key];
    if (template != null && paths != null && paths.isNotEmpty) {
      String replacement =
          paths.map((p) => File(p).readAsStringSync()).join('\n');
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
  Future<Map<String, String>> loadPartials();
  Future<String> loadTemplate(String name);
}

class _DefaultTemplatesLoader extends _TemplatesLoader {
  @override
  Future<Map<String, String>> loadPartials() async {
    var partials = <String, String>{};
    for (String partial in _partials) {
      var uri = 'package:dartdoc/templates/_$partial.html';
      partials[partial] = await loader.loadAsString(uri);
    }
    return partials;
  }

  @override
  Future<String> loadTemplate(String name) =>
      loader.loadAsString('package:dartdoc/templates/$name');
}

class _DirectoryTemplatesLoader extends _TemplatesLoader {
  final Directory _directory;

  _DirectoryTemplatesLoader(this._directory);

  @override
  Future<Map<String, String>> loadPartials() async {
    var partials = <String, String>{};

    for (File file in _directory.listSync().whereType<File>()) {
      var basename = path.basename(file.path);
      if (basename.startsWith('_') && basename.endsWith('.html')) {
        var content = file.readAsString();
        var partialName = basename.substring(1, basename.lastIndexOf('.'));
        partials[partialName] = await content;
      }
    }
    return partials;
  }

  @override
  Future<String> loadTemplate(String name) {
    var file = File(path.join(_directory.path, name));
    return file.readAsString();
  }
}

class Templates {
  final Template categoryTemplate;
  final Template classTemplate;
  final Template extensionTemplate;
  final Template enumTemplate;
  final Template constantTemplate;
  final Template constructorTemplate;
  final Template errorTemplate;
  final Template functionTemplate;
  final Template indexTemplate;
  final Template libraryTemplate;
  final Template methodTemplate;
  final Template mixinTemplate;
  final Template propertyTemplate;
  final Template topLevelConstantTemplate;
  final Template topLevelPropertyTemplate;
  final Template typeDefTemplate;

  static Future<Templates> fromContext(GeneratorContext context) {
    String templatesDir = context.templatesDir;
    if (templatesDir != null) {
      return fromDirectory(Directory(templatesDir),
          headerPaths: context.header,
          footerPaths: context.footer,
          footerTextPaths: context.footerTextPaths);
    } else {
      return createDefault(
          headerPaths: context.header,
          footerPaths: context.footer,
          footerTextPaths: context.footerTextPaths);
    }
  }

  static Future<Templates> createDefault(
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
    return _create(_DefaultTemplatesLoader(),
        headerPaths: headerPaths,
        footerPaths: footerPaths,
        footerTextPaths: footerTextPaths);
  }

  static Future<Templates> fromDirectory(Directory dir,
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
    await _checkRequiredTemplatesExist(dir);
    return _create(_DirectoryTemplatesLoader(dir),
        headerPaths: headerPaths,
        footerPaths: footerPaths,
        footerTextPaths: footerTextPaths);
  }

  static void _checkRequiredTemplatesExist(Directory dir) {
    for (var name in _requiredTemplates) {
      var file = File(path.join(dir.path, name));
      if (!file.existsSync()) {
        throw DartdocFailure('Missing required template file: "$name"');
      }
    }
  }

  static Future<Templates> _create(_TemplatesLoader templatesLoader,
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
    var partials = await _loadPartials(
        templatesLoader, headerPaths, footerPaths, footerTextPaths);

    Template _partial(String name) {
      String partial = partials[name];
      if (partial == null || partial.isEmpty) {
        throw StateError('Did not find partial "$name"');
      }
      return Template(partial);
    }

    Future<Template> _loadTemplate(String templatePath) async {
      String templateContents =
          await templatesLoader.loadTemplate(templatePath);
      return Template(templateContents, partialResolver: _partial);
    }

    var indexTemplate = await _loadTemplate('index.html');
    var libraryTemplate = await _loadTemplate('library.html');
    var categoryTemplate = await _loadTemplate('category.html');
    var classTemplate = await _loadTemplate('class.html');
    var extensionTemplate = await _loadTemplate('extension.html');
    var enumTemplate = await _loadTemplate('enum.html');
    var functionTemplate = await _loadTemplate('function.html');
    var methodTemplate = await _loadTemplate('method.html');
    var constructorTemplate = await _loadTemplate('constructor.html');
    var errorTemplate = await _loadTemplate('404error.html');
    var propertyTemplate = await _loadTemplate('property.html');
    var constantTemplate = await _loadTemplate('constant.html');
    var topLevelConstantTemplate =
        await _loadTemplate('top_level_constant.html');
    var topLevelPropertyTemplate =
        await _loadTemplate('top_level_property.html');
    var typeDefTemplate = await _loadTemplate('typedef.html');
    var mixinTemplate = await _loadTemplate('mixin.html');

    return Templates._(
        indexTemplate,
        categoryTemplate,
        libraryTemplate,
        classTemplate,
        extensionTemplate,
        enumTemplate,
        functionTemplate,
        methodTemplate,
        constructorTemplate,
        errorTemplate,
        propertyTemplate,
        constantTemplate,
        topLevelConstantTemplate,
        topLevelPropertyTemplate,
        typeDefTemplate,
        mixinTemplate);
  }

  Templates._(
      this.indexTemplate,
      this.categoryTemplate,
      this.libraryTemplate,
      this.classTemplate,
      this.extensionTemplate,
      this.enumTemplate,
      this.functionTemplate,
      this.methodTemplate,
      this.constructorTemplate,
      this.errorTemplate,
      this.propertyTemplate,
      this.constantTemplate,
      this.topLevelConstantTemplate,
      this.topLevelPropertyTemplate,
      this.typeDefTemplate,
      this.mixinTemplate);
}
