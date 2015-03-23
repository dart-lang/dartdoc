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
import '../generator.dart';

class HtmlGenerator extends Generator {
  final String _url;
  final List<String> _htmlFiles = [];

  Package get package => _package;
  Package _package;

  Directory get out => _out;
  Directory _out;

  final String generatedOn;

  // TODO: fix this to be a single map, just like _partialTemplates
  static final Function indexTemplate = _loadTemplate('templates/index.html');
  static final Function libraryTemplate =
      _loadTemplate('templates/library.html');
  static final Function classTemplate = _loadTemplate('templates/class.html');
  static final Function functionTemplate =
      _loadTemplate('templates/function.html');
  static final Function methodTemplate =
      _loadTemplate('templates/method.html');
  static final Function constructorTemplate =
      _loadTemplate('templates/constructor.html');

  static final Map<String, String> _partialTemplates = {};

  static String _partial(String name) {
    return _partialTemplates.putIfAbsent(name, () => _loadTemplate('templates/_$name.html', true));
  }

  HtmlGenerator(this._url)
      : generatedOn = new DateFormat('MMMM dd yyyy').format(new DateTime.now());

  void generate(Package package, Directory out) {
    _package = package;
    _out = out;
    if (!_out.existsSync()) _out.createSync();
    generatePackage();
    _copyResources();
    package.libraries.forEach((lib) {
      generateLibrary(package, lib);

      lib.getClasses().forEach((Class clazz) {
        generateClass(package, lib, clazz);

        clazz.constructors.forEach((constructor) {
          generateConstructor(package, lib, clazz, constructor);
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
      'oneLiner': oneLiner
    };

    _writeFile('index.html', indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    // TODO should we add _this_ to the context and avoid putting stuff
    // in the map?
    Map data = {
      'package': package,
      'library': lib,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner
    };

    _writeFile(path.join(lib.fileName, 'index.html'), libraryTemplate, data);
  }

  void generateClass(Package package, Library lib, Class clazz) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'class': clazz
    };

    _writeFile(path.joinAll(clazz.href.split('/')), classTemplate, data);
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

    _writeFile(path.joinAll(constructor.href.split('/')), constructorTemplate, data);
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

    _writeFile(path.joinAll(eNum.href.split('/')), classTemplate, data);
  }

  void generateFunction(Package package, Library lib, ModelFunction function) {
    Map data = {
      'package': package,
      'generatedOn': generatedOn,
      'markdown': renderMarkdown,
      'oneLiner': oneLiner,
      'library': lib,
      'function': function
    };

    _writeFile(path.joinAll(function.href.split('/')), functionTemplate, data);
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
      'method': method
    };

    _writeFile(path.joinAll(method.href.split('/')), methodTemplate, data);
  }

  void _copyResources() {
    File script = new File(Platform.script.toFilePath());
    ['styles.css', 'prettify.css', 'material-design-typography.css', 'prettify.js'].forEach((f) {
      new File(path.join(script.parent.parent.path, 'templates', f))
          .copySync(path.join(out.path, f));
    });
  }

  File _createOutputFile(String filename) {
    File f = new File(path.join(out.path, filename));
    if (!f.existsSync()) f.createSync(recursive: true);
    _htmlFiles.add(filename);
    print('generating ${f.path}');
    return f;
  }

  void _writeFile(String filename, template, Map data) {
    File f = _createOutputFile(filename);
    String content = template(data, assumeNullNonExistingProperty: false, errorOnMissingProperty: true);
    f.writeAsStringSync(content);
  }

  static dynamic _loadTemplate(String templatePath, [bool partial = false]) {
    File script = new File(Platform.script.toFilePath());
    File tmplFile =
        new File(path.join(script.parent.parent.path, templatePath));
    String contents = tmplFile.readAsStringSync();
    return partial ? contents : compile(contents, partial: _partial);
  }

}

// TODO: parse the custom dartdoc formatting brackets
/// Converts a markdown formatted string into HTML,
/// and removes any script tags. Returns the HTML as a string.
String renderMarkdown(String markdown, {nestedContext}) {
  String mustached = render(markdown.trim(), nestedContext,
      assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

  // reflector.
  String html = md.markdownToHtml(mustached);
  html = resolveDocReferences(html, nestedContext);
  Document doc = parse(html);
  doc.querySelectorAll('script').forEach((s) => s.remove());
  return doc.body.innerHtml;
}

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

  String render(List<md.Node> nodes) {
    buffer = new StringBuffer();

    for (final node in nodes) node.accept(this);

    return buffer.toString();
  }

  void visitText(md.Text text) {
    buffer.write(text.text);
  }

  bool visitElementBefore(md.Element element) {
    // do nothing
    return true;
  }

  void visitElementAfter(md.Element element) {
    // Hackish. Separate block-level elements with newlines.
    if (!buffer.isEmpty && _BLOCK_TAGS.firstMatch(element.tag) != null) {
      buffer.write('\n\n');
    }
  }
}
