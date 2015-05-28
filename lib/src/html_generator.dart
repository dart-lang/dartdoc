// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:io';

import 'dart:async' show Future;
import 'dart:profiler';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show Document;
import 'package:markdown/markdown.dart' as md;
import 'package:mustache4dart/mustache4dart.dart';
import 'package:mustache4dart/mustache_context.dart';
import 'package:path/path.dart' as path;

import 'html_utils.dart';
import 'model.dart';
import 'package_meta.dart';
import '../generator.dart';
import '../resources.g.dart' show RESOURCE_NAMES;
import '../resource_loader.dart' as loader;

typedef String TemplateRenderer(context,
    {bool assumeNullNonExistingProperty, bool errorOnMissingProperty});

final UserTag _HTML_GENERATE = new UserTag('HTML GENERATE');

class Templates {
  TemplateRenderer indexTemplate;
  TemplateRenderer libraryTemplate;
  TemplateRenderer classTemplate;
  TemplateRenderer functionTemplate;
  TemplateRenderer methodTemplate;
  TemplateRenderer constructorTemplate;
  TemplateRenderer propertyTemplate;
  TemplateRenderer constantTemplate;
  TemplateRenderer topLevelConstantTemplate;
  TemplateRenderer topLevelPropertyTemplate;
  TemplateRenderer typeDefTemplate;

  final Map<String, String> _partialTemplates = <String, String>{};

  final String _footer;
  final String _header;

  Templates(this._header, this._footer);

  Future init() async {
    if (_partialTemplates.isNotEmpty) return;

    indexTemplate = await _loadTemplate('index.html');
    libraryTemplate = await _loadTemplate('library.html');
    classTemplate = await _loadTemplate('class.html');
    functionTemplate = await _loadTemplate('function.html');
    methodTemplate = await _loadTemplate('method.html');
    constructorTemplate = await _loadTemplate('constructor.html');
    propertyTemplate = await _loadTemplate('property.html');
    constantTemplate = await _loadTemplate('constant.html');
    topLevelConstantTemplate = await _loadTemplate('top_level_constant.html');
    topLevelPropertyTemplate = await _loadTemplate('top_level_property.html');
    typeDefTemplate = await _loadTemplate('typedef.html');

    var partials = [
      'callable',
      'callable_multiline',
      'constant',
      'footer',
      'head',
      'property',
      'styles_and_scripts',
      'readable_writable',
      'documentation',
      'name_summary'
    ];

    for (var partial in partials) {
      _partialTemplates[partial] = await _loadPartial('_$partial.html');
    }
  }

  String _partial(String name) => _partialTemplates[name];

  Future<TemplateRenderer> _loadTemplate(String templatePath) async {
    var templateContents = await _getTemplateFile(templatePath);
    return compile(templateContents, partial: _partial) as TemplateRenderer;
  }

  Future<String> _getTemplateFile(String templatePath) {
    return loader.loadAsString('package:dartdoc/templates/$templatePath');
  }

  Future<String> _loadPartial(String templatePath) async {
    String template = await _getTemplateFile(templatePath);
    // TODO: revisit, not sure this is the right place for this logic
    if (templatePath.contains('_footer') && _footer != null) {
      var footerValue = await new File(_footer).readAsString();
      template =
          template.replaceAll('<!-- Footer Placeholder -->', footerValue);
    }
    if (templatePath.contains('_head') && _header != null) {
      var headerValue = await new File(_header).readAsString();
      template =
          template.replaceAll('<!-- Header Placeholder -->', headerValue);
    }
    return template;
  }
}

class HtmlGenerator extends Generator {
  final String url;
  final Templates _templates;

  HtmlGenerator(this.url, {String header, String footer})
      : _templates = new Templates(header, footer);

  Future generate(Package package, Directory out) {
    return new HtmlGeneratorInstance(url, _templates, package, out).generate();
  }
}

class HtmlGeneratorInstance {
  final String _url;
  final Templates _templates;

  final Package package;
  final Directory out;

  final List<String> _htmlFiles = [];

  HtmlGeneratorInstance(this._url, this._templates, this.package, this.out);

  Future generate() async {
    var previousTag = _HTML_GENERATE.makeCurrent();
    await _templates.init();
    if (!out.existsSync()) out.createSync();
    generatePackage();

    package.libraries.forEach((Library lib) {
      generateLibrary(package, lib);

      lib.allClasses.forEach((Class clazz) {
        generateClass(package, lib, clazz);

        clazz.constructors.forEach((constructor) {
          generateConstructor(package, lib, clazz, constructor);
        });

        clazz.constants.forEach((constant) {
          generateConstant(package, lib, clazz, constant);
        });

        clazz.staticProperties.forEach((property) {
          generateProperty(package, lib, clazz, property);
        });

        clazz.instanceProperties.forEach((property) {
          generateProperty(package, lib, clazz, property);
        });

        clazz.instanceMethods.forEach((method) {
          generateMethod(package, lib, clazz, method);
        });

        clazz.operators.forEach((operator) {
          generateMethod(package, lib, clazz, operator);
        });

        clazz.staticMethods.forEach((method) {
          generateMethod(package, lib, clazz, method);
        });
      });

      lib.enums.forEach((eNum) {
        generateEnum(package, lib, eNum);
      });

      lib.constants.forEach((constant) {
        generateTopLevelConstant(package, lib, constant);
      });

      lib.properties.forEach((property) {
        generateTopLevelProperty(package, lib, property);
      });

      lib.functions.forEach((function) {
        generateFunction(package, lib, function);
      });

      lib.typedefs.forEach((typeDef) {
        generateTypeDef(package, lib, typeDef);
      });
    });
    if (_url != null) {
      //generateSiteMap();
    }

    await _copyResources();

    previousTag.makeCurrent();
  }

  void generatePackage() {
    // TODO: Should we add _this_ to the context and avoid putting stuff in the
    // map?
    Map data = {
      'package': package,
      'oneLiner': oneLiner,
      'documentation': package.documentation,
      'title': '${package.name} - Dart API docs',
      'layoutTitle': _layoutTitle(package.name, package.isSdk ? '' : 'package'),
      'metaDescription':
          '${package.name} API docs, for the Dart programming language.',
      'navLinks': [package],
      'htmlBase': '.'
    };

    if (package.hasDocumentation) {
      FileContents readme = package.documentationFile;
      data['markdown'] = readme.isMarkdown ? renderMarkdown : renderPlainText;
    }

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    // TODO should we add _this_ to the context and avoid putting stuff
    // in the map?
    Map data = {
      'package': package,
      'library': lib,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': lib.documentation,
      'title': '${lib.name} library - Dart API',
      'htmlBase': '..',
      'metaDescription':
          '${lib.name} library API docs, for the Dart programming language.',
      'navLinks': [package, lib],
      'layoutTitle': _layoutTitle(lib.name, 'library')
    };

    _build(path.join(lib.nameForFile, 'index.html'), _templates.libraryTemplate,
        data);
  }

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    Library dc = package.libraries.firstWhere((it) => it.name == "dart:core",
        orElse: () => null);

    if (dc == null) {
      return _objectType = null;
    }

    return _objectType = dc.getClassByName("Object");
  }

  Class _objectType;

  void generateClass(Package package, Library lib, Class clazz) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': clazz.documentation,
      'library': lib,
      'class': clazz,
      'linkedObjectType': objectType == null ? 'Object' : objectType.linkedName,
      'title': '${clazz.name} ${clazz.kind} - ${lib.name} library - Dart API',
      'metaDescription':
          'API docs for the ${clazz.name} ${clazz.kind} from the ${lib.name} library, for the Dart programming language.',
      'layoutTitle': _layoutTitle(clazz.nameWithGenerics, clazz.kind),
      'navLinks': [package, lib, clazz],
      'htmlBase': '..'
    };

    _build(path.joinAll(clazz.href.split('/')), _templates.classTemplate, data);
  }

  void generateConstructor(
      Package package, Library lib, Class clazz, Constructor constructor) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': constructor.documentation,
      'library': lib,
      'class': clazz,
      'constructor': constructor,
      'layoutTitle': _layoutTitle(constructor.name, 'constructor'),
      'navLinks': [package, lib, clazz, constructor],
      'htmlBase': '../..'
    };

    _build(path.joinAll(constructor.href.split('/')),
        _templates.constructorTemplate, data);
  }

  void generateEnum(Package package, Library lib, Class eNum) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': eNum,
      'library': lib,
      'class': eNum,
      'layoutTitle': _layoutTitle(eNum.name, 'enum'),
      'navLinks': [package, lib, eNum],
      'htmlBase': '..'
    };

    _build(path.joinAll(eNum.href.split('/')), _templates.classTemplate, data);
  }

  void generateFunction(Package package, Library lib, ModelFunction function) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': function.documentation,
      'library': lib,
      'function': function,
      'title': '${function.name} function - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(function.name, 'function'),
      'metaDescription':
          'API docs for the ${function.name} function from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib, function],
      'htmlBase': '..'
    };

    _build(path.joinAll(function.href.split('/')), _templates.functionTemplate,
        data);
  }

  void generateMethod(
      Package package, Library lib, Class clazz, Method method) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': method.documentation,
      'library': lib,
      'class': clazz,
      'method': method,
      'title':
          '${method.name} method - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(method.name, 'method'),
      'metaDescription':
          'API docs for the ${method.name} method from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz, method],
      'htmlBase': '../..'
    };

    _build(
        path.joinAll(method.href.split('/')), _templates.methodTemplate, data);
  }

  void generateConstant(
      Package package, Library lib, Class clazz, Field property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': property.documentation,
      'library': lib,
      'class': clazz,
      'property': property,
      'title':
          '${property.name} constant - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(property.name, 'constant'),
      'metaDescription':
          'API docs for the ${property.name} constant from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz, property],
      'htmlBase': '../..'
    };

    _build(path.joinAll(property.href.split('/')), _templates.constantTemplate,
        data);
  }

  void generateProperty(
      Package package, Library lib, Class clazz, Field property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': property.documentation,
      'library': lib,
      'class': clazz,
      'property': property,
      'title':
          '${property.name} property - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(property.name, 'property'),
      'metaDescription':
          'API docs for the ${property.name} property from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz, property],
      'htmlBase': '../..'
    };

    _build(path.joinAll(property.href.split('/')), _templates.propertyTemplate,
        data);
  }

  void generateTopLevelProperty(
      Package package, Library lib, TopLevelVariable property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'documentation': property.documentation,
      'library': lib,
      'property': property,
      'title': '${property.name} property - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(property.name, 'property'),
      'metaDescription':
          'API docs for the ${property.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib, property],
      'htmlBase': '..'
    };

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
      Package package, Library lib, TopLevelVariable property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': property.documentation,
      'oneLiner': oneLiner,
      'library': lib,
      'property': property,
      'title': '${property.name} property - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(property.name, 'constant'),
      'metaDescription':
          'API docs for the ${property.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib, property],
      'htmlBase': '..'
    };

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelConstantTemplate, data);
  }

  void generateTypeDef(Package package, Library lib, Typedef typeDef) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': typeDef.documentation,
      'oneLiner': oneLiner,
      'library': lib,
      'typeDef': typeDef,
      'title': '${typeDef.name} typedef - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(typeDef.name, 'typedef'),
      'metaDescription':
          'API docs for the ${typeDef.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib, typeDef],
      'htmlBase': '..'
    };

    _build(path.joinAll(typeDef.href.split('/')), _templates.typeDefTemplate,
        data);
  }

  // TODO: change this to use resource_loader
  Future _copyResources() async {
    final prefix = 'package:dartdoc/resources/';
    for (var resourcePath in RESOURCE_NAMES) {
      if (!resourcePath.startsWith(prefix)) {
        throw new StateError(
            'Resource paths must start with $prefix, encountered $resourcePath');
      }
      var destFileName = resourcePath.substring(prefix.length);
      var destFile = new File(path.join(out.path, 'const', destFileName))
        ..createSync(recursive: true);
      var resourceBytes = await loader.loadAsBytes(resourcePath);
      destFile.writeAsBytesSync(resourceBytes);
    }
  }

  File _createOutputFile(String filename) {
    File f = new File(path.join(out.path, filename));
    if (!f.existsSync()) f.createSync(recursive: true);
    _htmlFiles.add(filename);
    print('generating ${f.path}');
    return f;
  }

  void _build(String filename, TemplateRenderer template, Map data) {
    String content = template(data,
        assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

    _writeFile(filename, content);
  }

  void _writeFile(String filename, String content) {
    File f = _createOutputFile(filename);
    f.writeAsStringSync(content);
  }
}

String _layoutTitle(String name, String kind) =>
    kind.isEmpty ? name : '$name <span class="kind">$kind</span>';

/// Converts a markdown formatted string into HTML, and removes any script tags.
/// Returns the HTML as a string.
String renderMarkdown(String markdown, {nestedContext}) {
  if (markdown == null) return '';

  String mustached = render(markdown.trim(), nestedContext,
      assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

  // reflector.
  String html = md.markdownToHtml(mustached, inlineSyntaxes: MARKDOWN_SYNTAXES);
  html = resolveDocReferences(html, nestedContext);
  Document doc = parse(html);
  doc.querySelectorAll('script').forEach((s) => s.remove());
  doc.querySelectorAll('pre > code').forEach((e) {
    e.classes.addAll(['prettyprint', 'lang-dart']);
  });
  return doc.body.innerHtml;
}

/// Convert the given plain text into HTML.
String renderPlainText(String text) {
  if (text == null) return '';

  return "<code class='fixed'>${text.trim()}</code>";
}

const List<String> _oneLinerSkipTags = const ["code", "pre"];

String oneLiner(String text, {MustacheToString nestedContext}) {
  String mustached = render(text.trim(), nestedContext,
          assumeNullNonExistingProperty: false, errorOnMissingProperty: true)
      .trim();
  if (mustached == null || mustached.trim().isEmpty) return '';
  // Parse with Markdown, but only care about the first block or paragraph.
  var lines = mustached.replaceAll('\r\n', '\n').split('\n');
  var document = new md.Document(inlineSyntaxes: MARKDOWN_SYNTAXES);
  document.parseRefLinks(lines);
  var blocks = document.parseLines(lines);

  while (blocks.isNotEmpty &&
      ((blocks.first is md.Element &&
              _oneLinerSkipTags.contains(blocks.first.tag)) ||
          blocks.first.isEmpty)) {
    blocks.removeAt(0);
  }

  if (blocks.isEmpty) {
    return '';
  }

  var firstPara = new PlainTextRenderer().render([blocks.first]);
  if (firstPara.length > 200) {
    firstPara = firstPara.substring(0, 200) + '...';
  }

  return resolveDocReferences(firstPara, nestedContext).trim();
}

ModelElement _getElement(MustacheToString nestedContext) {
  ModelElement _getFromContext(dynamic context) {
    var obj = context.ctxReflector.m;
    if (obj != null) {
      var reflectee = obj.reflectee;
      if (reflectee is ModelElement) {
        return reflectee;
      } else if (reflectee is Map) {
        var objE = reflectee['method'];
        if (objE == null) objE = reflectee['class'];
        if (objE == null) objE = reflectee['function'];
        if (objE == null) objE = reflectee['library'];
        return objE;
      }
    }
    return null;
  }

  if (nestedContext == null) {
    return null;
  }

  var parent = nestedContext.parent;
  var obj = _getFromContext(parent);
  if (obj != null) return obj;
  parent = parent.parent;
  if (parent != null) {
    obj = _getFromContext(parent);
  }
  return obj;
}

String resolveDocReferences(String text, MustacheToString nestedContext) {
  var element = _getElement(nestedContext);
  if (element != null) {
    return element.resolveReferences(docs: text);
  }
  return text;
}

class PlainTextRenderer implements md.NodeVisitor {
  static final _BLOCK_TAGS =
      new RegExp('blockquote|h1|h2|h3|h4|h5|h6|hr|p|pre');

  StringBuffer _buffer;

  String render(List<md.Node> nodes) {
    _buffer = new StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }

    return _buffer.toString();
  }

  @override
  void visitText(md.Text text) {
    _buffer.write(text.text);
  }

  @override
  bool visitElementBefore(md.Element element) {
    // do nothing
    return true;
  }

  @override
  void visitElementAfter(md.Element element) {
    // Hackish. Separate block-level elements with newlines.
    if (!_buffer.isEmpty && _BLOCK_TAGS.firstMatch(element.tag) != null) {
      _buffer.write('\n\n');
    }
  }
}

final List<md.InlineSyntax> MARKDOWN_SYNTAXES = [new InlineCodeSyntax()];

class InlineCodeSyntax extends md.InlineSyntax {
  InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = new md.Element.text('code', htmlEscape(match[1]));
    var c = element.attributes.putIfAbsent("class", () => "");
    c = (c.isEmpty ? "" : " ") + "prettyprint";
    element.attributes["class"] = c;
    parser.addNode(element);
    return true;
  }
}
