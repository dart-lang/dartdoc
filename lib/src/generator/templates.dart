// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.templates;

import 'dart:async' show Future;
import 'dart:io' show File, Directory;
import 'dart:isolate';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/resource_loader.dart' as loader;
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
  headerPaths ??= [];
  footerPaths ??= [];
  footerTextPaths ??= [];

  var partials = await templatesLoader.loadPartials();

  void replacePlaceholder(String key, String placeholder, List<String> paths) {
    var template = partials[key];
    if (template != null && paths != null && paths.isNotEmpty) {
      var replacement = paths.map((p) => File(p).readAsStringSync()).join('\n');
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

/// Loads default templates included in the Dartdoc program.
class _DefaultTemplatesLoader extends _TemplatesLoader {
  final String _format;
  final List<String> _partials;

  factory _DefaultTemplatesLoader.create(String format) {
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
    return _DefaultTemplatesLoader(format, partials);
  }

  _DefaultTemplatesLoader(this._format, this._partials);

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
  final Directory _directory;
  final String _format;

  _DirectoryTemplatesLoader(this._directory, this._format);

  @override
  Future<Map<String, String>> loadPartials() async {
    var partials = <String, String>{};

    for (var file in _directory.listSync().whereType<File>()) {
      var basename = path.basename(file.path);
      if (basename.startsWith('_') && basename.endsWith('.$_format')) {
        var content = file.readAsString();
        var partialName = basename.substring(1, basename.lastIndexOf('.'));
        partials[partialName] = await content;
      }
    }
    return partials;
  }

  @override
  Future<String> loadTemplate(String name) {
    var file = File(path.join(_directory.path, '$name.$_format'));
    if (!file.existsSync()) {
      throw DartdocFailure('Missing required template file: $name.$_format');
    }
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

  static Future<Templates> fromContext(
      DartdocGeneratorOptionContext context) async {
    var templatesDir = context.templatesDir;
    var format = context.format;
    var footerTextPaths = context.footerText;
    if (context.addSdkFooter) {
      var sdkFooter = await Isolate.resolvePackageUri(
          Uri.parse('package:dartdoc/resources/sdk_footer_text.$format'));
      footerTextPaths.add(path.canonicalize(sdkFooter.toFilePath()));
    }

    if (templatesDir != null) {
      return fromDirectory(Directory(templatesDir), format,
          headerPaths: context.header,
          footerPaths: context.footer,
          footerTextPaths: footerTextPaths);
    } else {
      return createDefault(format,
          headerPaths: context.header,
          footerPaths: context.footer,
          footerTextPaths: footerTextPaths);
    }
  }

  static Future<Templates> createDefault(String format,
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
    return _create(_DefaultTemplatesLoader.create(format),
        headerPaths: headerPaths,
        footerPaths: footerPaths,
        footerTextPaths: footerTextPaths);
  }

  static Future<Templates> fromDirectory(Directory dir, String format,
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
    return _create(_DirectoryTemplatesLoader(dir, format),
        headerPaths: headerPaths,
        footerPaths: footerPaths,
        footerTextPaths: footerTextPaths);
  }

  static Future<Templates> _create(_TemplatesLoader templatesLoader,
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
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
    var categoryTemplate = await _loadTemplate('category');
    var classTemplate = await _loadTemplate('class');
    var extensionTemplate = await _loadTemplate('extension');
    var enumTemplate = await _loadTemplate('enum');
    var functionTemplate = await _loadTemplate('function');
    var methodTemplate = await _loadTemplate('method');
    var constructorTemplate = await _loadTemplate('constructor');
    var errorTemplate = await _loadTemplate('404error');
    var propertyTemplate = await _loadTemplate('property');
    var constantTemplate = await _loadTemplate('constant');
    var topLevelConstantTemplate = await _loadTemplate('top_level_constant');
    var topLevelPropertyTemplate = await _loadTemplate('top_level_property');
    var typeDefTemplate = await _loadTemplate('typedef');
    var mixinTemplate = await _loadTemplate('mixin');

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
