// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:mustache4dart/mustache_context.dart';
import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart' show Document;
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;

import 'model.dart';
import 'html_utils.dart';
import '../generator.dart';
import 'io_utils.dart';

typedef String TemplateRenderer(context, {
  bool assumeNullNonExistingProperty,
  bool errorOnMissingProperty
});

class HtmlGenerator extends Generator {
  final String _url;
  final List<String> _htmlFiles = [];

  Package get package => _package;
  Package _package;

  Directory get out => _out;
  Directory _out;

  final String generatedOn;

  static final TemplateRenderer indexTemplate = _loadTemplate('templates/index.html');
  static final TemplateRenderer libraryTemplate =
      _loadTemplate('templates/library.html');
  static final TemplateRenderer classTemplate = _loadTemplate('templates/class.html');
  static final TemplateRenderer functionTemplate =
      _loadTemplate('templates/function.html');
  static final TemplateRenderer methodTemplate =
      _loadTemplate('templates/method.html');
  static final TemplateRenderer constructorTemplate =
      _loadTemplate('templates/constructor.html');
  static final TemplateRenderer propertyTemplate =
      _loadTemplate('templates/property.html');
  static final TemplateRenderer constantTemplate =
      _loadTemplate('templates/constant.html');
  static final TemplateRenderer topLevelConstantTemplate =
    _loadTemplate('templates/top_level_constant.html');
  static final TemplateRenderer topLevelPropertyTemplate =
      _loadTemplate('templates/top_level_property.html');

  static final Map<String, String> _partialTemplates = {};

  static String _partial(String name) {
    return _partialTemplates.putIfAbsent(name, () => _loadPartial('templates/_$name.html'));
  }

  HtmlGenerator(this._url)
      : generatedOn = new DateFormat('MMMM dd yyyy').format(new DateTime.now());

  void generate(Package package, Directory out) {
    _package = package;
    _out = out;
    if (!_out.existsSync()) _out.createSync();
    generatePackage();
    _copyResources();
    package.libraries.forEach((Library lib) {
      generateLibrary(package, lib);

      lib.getClasses().forEach((Class clazz) {
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

      lib.getEnums().forEach((eNum) {
        generateEnum(package, lib, eNum);
      });

      lib.getConstants().forEach((constant) {
        generateTopLevelConstant(package, lib, constant);
      });

      lib.getProperties().forEach((property) {
        generateTopLevelProperty(package, lib, property);
      });

      lib.getFunctions().forEach((function) {
        generateFunction(package, lib, function);
      });
    });
    // if (_url != null) {
    //   generateSiteMap();
    // }
  }

  void generatePackage() {
    // TODO should we add _this_ to the context and avoid putting stuff
    // in the map?
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'title': '${package.name} - Dart API docs',
      'layoutTitle': '${package.name} package',
      'metaDescription': '${package.name} API docs, for the Dart programming language.',
      'navLinks': [package],
      'htmlBase': '.'
    };

    _build('index.html', indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    // TODO should we add _this_ to the context and avoid putting stuff
    // in the map?
    Map data = {
      'package': package,
      'library': lib,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'title': '${lib.name} library - Dart API',
      'htmlBase': '..',
      'metaDescription': '${lib.name} library API docs, for the Dart programming language.',
      'navLinks': [package],
      'layoutTitle': '${lib.name} library'
    };

    _build(path.join(lib.fileName, 'index.html'), libraryTemplate, data);
  }

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    Library dc = package.libraries.firstWhere((it) => it.name == "dart:core", orElse: () => null);

    if (dc == null) {
      return _objectType = null;
    }

    return _objectType = dc.getClassByName("Object");
  }

  Class _objectType;

  void generateClass(Package package, Library lib, Class clazz) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'class': clazz,
      'linkedObjectType': objectType == null ? 'Object' : objectType.linkedName,
      'title': '${clazz.name} ${clazz.kind} - ${lib.name} library - Dart API',
      'metaDescription': 'API docs for the ${clazz.name} ${clazz.kind} from the ${lib.name} library, for the Dart programming language.',
      'layoutTitle': '${clazz.nameWithGenerics} ${clazz.kind}',
      'navLinks': [package, lib],
      'htmlBase': '..'
    };

    _build(path.joinAll(clazz.href.split('/')), classTemplate, data);
  }

  void generateConstructor(Package package, Library lib, Class clazz,
                           Constructor constructor) {
    Map data = {
        'package': package,
        'generatedOn': generatedOn,
        'markdown': renderMarkdown,
        'oneLiner': oneLiner,
        'library': lib,
        'class': clazz,
        'constructor': constructor
    };

    _build(path.joinAll(constructor.href.split('/')), constructorTemplate, data);
  }

  void generateEnum(Package package, Library lib, Class eNum) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'class': eNum
    };

    _build(path.joinAll(eNum.href.split('/')), classTemplate, data);
  }

  void generateFunction(Package package, Library lib, ModelFunction function) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'function': function,
      'title': '${function.name} function - ${lib.name} library - Dart API',
      'layoutTitle': '${function.name} function',
      'metaDescription': 'API docs for the ${function.name} function from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'htmlBase': '..'
    };

    _build(path.joinAll(function.href.split('/')), functionTemplate, data);
  }

  void generateMethod(
      Package package, Library lib, Class clazz, Method method) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'class': clazz,
      'method': method,
      'title': '${method.name} method - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': '${method.name} method',
      'metaDescription': 'API docs for the ${method.name} method from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz],
      'htmlBase': '../..'
    };

    _build(path.joinAll(method.href.split('/')), methodTemplate, data);
  }

  void generateConstant(
    Package package, Library lib, Class clazz, Field property) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'class': clazz,
      'property': property,
      'title': '${property.name} constant - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': '${property.name} constant',
      'metaDescription': 'API docs for the ${property.name} constant from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz],
      'htmlBase': '../..'
    };

    _build(path.joinAll(property.href.split('/')), constantTemplate, data);
  }

  void generateProperty(
    Package package, Library lib, Class clazz, Field property) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'class': clazz,
      'property': property,
      'title': '${property.name} property - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': '${property.name} property',
      'metaDescription': 'API docs for the ${property.name} property from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz],
      'htmlBase': '../..'
    };

    _build(path.joinAll(property.href.split('/')), propertyTemplate, data);
  }

  void generateTopLevelProperty(
    Package package, Library lib, TopLevelVariable property) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'property': property,
      'title': '${property.name} property - ${lib.name} library - Dart API',
      'layoutTitle': '${property.name} property',
      'metaDescription': 'API docs for the ${property.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'htmlBase': '../..'
    };

    _build(path.joinAll(property.href.split('/')), topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
    Package package, Library lib, TopLevelVariable property) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'property': property,
      'title': '${property.name} property - ${lib.name} library - Dart API',
      'layoutTitle': '${property.name} property',
      'metaDescription': 'API docs for the ${property.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'htmlBase': '../..'
    };

    _build(path.joinAll(property.href.split('/')), topLevelConstantTemplate, data);
  }

  void _copyResources() {
    File script = new File(Platform.script.toFilePath());
    var sourcePath = path.join(script.parent.parent.path, 'resources');
    if (!new Directory(sourcePath).existsSync()) {
      throw new StateError('resources/ directory not found');
    }
    for (var fileName in listDir(sourcePath, recursive: true)) {
      var destFileName = fileName.substring(sourcePath.length+1);
      if (FileSystemEntity.isDirectorySync(fileName)) {
        new Directory(path.join(out.path, destFileName)).createSync(recursive: true);
      } else {
        var destPath = path.join(out.path, destFileName);
        new File(fileName).copySync(destPath);
      }
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
    String content = template(
        data,
        assumeNullNonExistingProperty: false,
        errorOnMissingProperty: true
    );

    _writeFile(filename, content);
  }

  void _writeFile(String filename, String content) {
    File f = _createOutputFile(filename);
    f.writeAsStringSync(content);
  }

  static TemplateRenderer _loadTemplate(String templatePath) {
    return compile(_getTemplateFile(templatePath), partial: _partial);
  }

  static String _getTemplateFile(String templatePath) {
    File script = new File(Platform.script.toFilePath());
    File tmplFile =
      new File(path.join(script.parent.parent.path, templatePath));
    return tmplFile.readAsStringSync();
  }

  static String _loadPartial(String templatePath) {
    return _getTemplateFile(templatePath);
  }
}

/// Converts a markdown formatted string into HTML,
/// and removes any script tags. Returns the HTML as a string.
String renderMarkdown(String markdown, {nestedContext}) {
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

const List<String> _oneLinerSkipTags = const ["code", "pre"];

String oneLiner(String text, {nestedContext}) {
  String mustached = render(text.trim(), nestedContext,
          assumeNullNonExistingProperty: false, errorOnMissingProperty: true)
      .trim();
  if (mustached == null || mustached.trim().isEmpty) return '';
  // Parse with Markdown, but only care about the first block or paragraph.
  var lines = mustached.replaceAll('\r\n', '\n').split('\n');
  var document = new md.Document();
  document.parseRefLinks(lines);
  var blocks = document.parseLines(lines);

  while (blocks.isNotEmpty && (blocks.first is md.Element && _oneLinerSkipTags.contains(blocks.first.tag))) {
    blocks.removeAt(0);
  }

  if (blocks.isEmpty) {
    return '';
  }

  var firstPara = new PlainTextRenderer().render([blocks.first]);
  if (firstPara.length > 200) {
    firstPara = firstPara.substring(0, 200) + '...';
  }

  return resolveDocReferences(firstPara, nestedContext);
}

String resolveDocReferences(String text, MustacheContext nestedContext) {
  ModelElement _getElement() {
    var obj = (nestedContext as MustacheToString).parent;
    obj = obj.ctxReflector.m;
    if (obj != null) {
      var reflectee = obj.reflectee;
      if (reflectee is ModelElement) {
        return reflectee;
      } else {
        var objE = reflectee['method'];
        if (objE == null) objE = reflectee['class'];
        if (objE == null) objE = reflectee['function'];
        if (objE == null) objE = reflectee['library'];
        return objE;
      }
    }
    return null;
  }

  var resolvedText;
  var element = _getElement();
  if (element != null) {
    resolvedText = element.resolveReferences(text);
    return resolvedText;
  }
  return text;
}

class PlainTextRenderer implements md.NodeVisitor {
  static final _BLOCK_TAGS =
      new RegExp('blockquote|h1|h2|h3|h4|h5|h6|hr|p|pre');

  StringBuffer buffer;

  @override
  String render(List<md.Node> nodes) {
    buffer = new StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }

    return buffer.toString();
  }

  @override
  void visitText(md.Text text) {
    buffer.write(text.text);
  }

  @override
  bool visitElementBefore(md.Element element) {
    // do nothing
    return true;
  }

  @override
  void visitElementAfter(md.Element element) {
    // Hackish. Separate block-level elements with newlines.
    if (!buffer.isEmpty && _BLOCK_TAGS.firstMatch(element.tag) != null) {
      buffer.write('\n\n');
    }
  }
}

final List<md.InlineSyntax> MARKDOWN_SYNTAXES = [
  new InlineCodeSyntax()
];

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
