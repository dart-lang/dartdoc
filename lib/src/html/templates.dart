// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.templates;

import 'dart:async' show Future;
import 'dart:io' show File;
import 'package:dartdoc/src/html/resource_loader.dart' as loader;
import 'package:mustache4dart/mustache4dart.dart';

const _partials = const <String>[
  'callable',
  'callable_multiline',
  'constant',
  'footer',
  'head',
  'library',
  'packages',
  'property',
  'features',
  'documentation',
  'name_summary',
  'sidebar_for_class',
  'sidebar_for_enum',
  'source_code',
  'sidebar_for_library',
  'accessor_getter',
  'accessor_setter',
];

Future<Map<String, String>> _loadPartials(List<String> headerPaths,
    List<String> footerPaths, List<String> footerTextPaths) async {
  final String headerPlaceholder = '<!-- header placeholder -->';
  final String footerPlaceholder = '<!-- footer placeholder -->';
  final String footerTextPlaceholder = '<!-- footer-text placeholder -->';

  headerPaths ??= [];
  footerPaths ??= [];
  footerTextPaths ??= [];

  var partials = <String, String>{};

  Future<String> _loadPartial(String templatePath) async {
    String template = await _getTemplateFile(templatePath);

    if (templatePath.contains('_head')) {
      String headerValue = headerPaths
          .map((path) => new File(path).readAsStringSync())
          .join('\n');
      template = template.replaceAll(headerPlaceholder, headerValue);
    }

    if (templatePath.contains('_footer')) {
      String footerValue = footerPaths
          .map((path) => new File(path).readAsStringSync())
          .join('\n');
      template = template.replaceAll(footerPlaceholder, footerValue);

      String footerTextValue = footerTextPaths
          .map((path) => new File(path).readAsStringSync())
          .join('\n');
      template = template.replaceAll(footerTextPlaceholder, footerTextValue);
    }

    return template;
  }

  for (String partial in _partials) {
    partials[partial] = await _loadPartial('_$partial.html');
  }

  return partials;
}

Future<String> _getTemplateFile(String templateFileName) =>
    loader.loadAsString('package:dartdoc/templates/$templateFileName');

class Templates {
  final TemplateRenderer classTemplate;
  final TemplateRenderer enumTemplate;
  final TemplateRenderer constantTemplate;
  final TemplateRenderer constructorTemplate;
  final TemplateRenderer functionTemplate;
  final TemplateRenderer indexTemplate;
  final TemplateRenderer libraryTemplate;
  final TemplateRenderer methodTemplate;
  final TemplateRenderer propertyTemplate;
  final TemplateRenderer topLevelConstantTemplate;
  final TemplateRenderer topLevelPropertyTemplate;
  final TemplateRenderer typeDefTemplate;

  static Future<Templates> create(
      {List<String> headerPaths,
      List<String> footerPaths,
      List<String> footerTextPaths}) async {
    var partials =
        await _loadPartials(headerPaths, footerPaths, footerTextPaths);

    String _partial(String name) {
      String partial = partials[name];
      if (partial == null || partial.isEmpty) {
        throw new StateError('Did not find partial "$name"');
      }
      return partial;
    }

    Future<TemplateRenderer> _loadTemplate(String templatePath) async {
      String templateContents = await _getTemplateFile(templatePath);
      return compile(templateContents, partial: _partial);
    }

    var indexTemplate = await _loadTemplate('index.html');
    var libraryTemplate = await _loadTemplate('library.html');
    var classTemplate = await _loadTemplate('class.html');
    var enumTemplate = await _loadTemplate('enum.html');
    var functionTemplate = await _loadTemplate('function.html');
    var methodTemplate = await _loadTemplate('method.html');
    var constructorTemplate = await _loadTemplate('constructor.html');
    var propertyTemplate = await _loadTemplate('property.html');
    var constantTemplate = await _loadTemplate('constant.html');
    var topLevelConstantTemplate =
        await _loadTemplate('top_level_constant.html');
    var topLevelPropertyTemplate =
        await _loadTemplate('top_level_property.html');
    var typeDefTemplate = await _loadTemplate('typedef.html');

    return new Templates._(
        indexTemplate,
        libraryTemplate,
        classTemplate,
        enumTemplate,
        functionTemplate,
        methodTemplate,
        constructorTemplate,
        propertyTemplate,
        constantTemplate,
        topLevelConstantTemplate,
        topLevelPropertyTemplate,
        typeDefTemplate);
  }

  Templates._(
      this.indexTemplate,
      this.libraryTemplate,
      this.classTemplate,
      this.enumTemplate,
      this.functionTemplate,
      this.methodTemplate,
      this.constructorTemplate,
      this.propertyTemplate,
      this.constantTemplate,
      this.topLevelConstantTemplate,
      this.topLevelPropertyTemplate,
      this.typeDefTemplate);
}
