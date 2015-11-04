library dartdoc.templates;

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show Directory, File, stdout;

import 'package:mustache4dart/mustache4dart.dart';

import 'resource_loader.dart' as loader;

typedef String TemplateRenderer(context,
    {bool assumeNullNonExistingProperty, bool errorOnMissingProperty});

// TODO: if we can ever enumerate the contents of a package, we
// won't need this.
const _partials = const <String>[
  'callable',
  'callable_multiline',
  'constant',
  'footer',
  'head',
  'property',
  'styles_and_scripts',
  'readable_writable',
  'documentation',
  'name_summary',
  'sidebar_for_class',
  'source_code',
  'sidebar_for_library',
  'has_more_docs',
  'accessor_getter',
  'accessor_setter'
];

Future<Map<String, String>> _loadPartials(
    String headerPath, String footerPath) async {
  var partials = <String, String>{};

  Future<String> _loadPartial(String templatePath) async {
    String template = await _getTemplateFile(templatePath);
    // TODO: revisit, not sure this is the right place for this logic
    if (templatePath.contains('_footer') && footerPath != null) {
      String footerValue = await new File(footerPath).readAsString();
      template =
          template.replaceAll('<!-- Footer Placeholder -->', footerValue);
    }
    if (templatePath.contains('_head') && headerPath != null) {
      String headerValue = await new File(headerPath).readAsString();
      template =
          template.replaceAll('<!-- Header Placeholder -->', headerValue);
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
      {String headerPath, String footerPath}) async {
    var partials = await _loadPartials(headerPath, footerPath);

    String _partial(String name) {
      String partial = partials[name];
      if (partial == null || partial.isEmpty) {
        throw new StateError('Did not find partial "$name"');
      }
      return partial;
    }

    Future<TemplateRenderer> _loadTemplate(String templatePath) async {
      String templateContents = await _getTemplateFile(templatePath);
      return compile(templateContents, partial: _partial) as TemplateRenderer;
    }

    var indexTemplate = await _loadTemplate('index.html');
    var libraryTemplate = await _loadTemplate('library.html');
    var classTemplate = await _loadTemplate('class.html');
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
      this.functionTemplate,
      this.methodTemplate,
      this.constructorTemplate,
      this.propertyTemplate,
      this.constantTemplate,
      this.topLevelConstantTemplate,
      this.topLevelPropertyTemplate,
      this.typeDefTemplate);
}
