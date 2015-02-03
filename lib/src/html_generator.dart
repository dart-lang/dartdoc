// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:mustache4dart/mustache4dart.dart';

import 'css.dart';
import 'html_printer.dart';
import 'html_utils.dart';
import 'model_utils.dart'; // temp. this class is getting deleted anyway
import 'io_utils.dart';
import 'model.dart';
import '../generator.dart';

/// Generates the HTML files
class HtmlGenerator extends Generator {
  // The sitemap template file
  static final String siteMapTemplate = '/templates/sitemap.xml';
  static final String indexTemplate = '/templates/index.html';
  static final String bootstrapOverrides = '''
body {
  margin: 8px;
}''';

  static const String _bootstrapCss =
      'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css';
  static const String _bootstrapTheme =
      'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css';

  HtmlPrinter _html = new HtmlPrinter();
  final CSS _css = new CSS();
  //HtmlGeneratorHelper _helper;
  final List<String> _htmlFiles = [];
  final String _url;

  Package get package => _package;
  Package _package;

  Directory get out => _out;
  Directory _out;

  HtmlGenerator(this._url) {}

  void generate(Package package, Directory out) {
    this._package = package;
    this._out = out;
    _helper = new HtmlGeneratorHelper(package);
    generatePackage();
    package.libraries.forEach((lib) => generateLibrary(lib));
    if (_url != null) {
      generateSiteMap();
    }
  }

  void generatePackage() {
    var date = new DateFormat('MMMM dd yyyy').format(new DateTime.now());
    var data = {
      'css': _bootstrapCss,
      'theme': _bootstrapTheme,
      'sdkVersion': package.sdkVersion.trim(),
      'date': date,
      'packageName': package.name,
      'packageDesc': package.description,
      'packageVersion': package.version,
      'libraries': package.libraries.map((lib) {
        return {
          'name': lib.name,
          'filename': getFileNameFor(lib.name),
          'descr': getDocOneLiner(lib)
        };
      })
    };
    var fileName = 'index.html';

    File f = new File(path.join(out.path, fileName));
    _htmlFiles.add(fileName);
    print('generating ${f.path}');

    var script = new File(Platform.script.toFilePath());
    File tmplFile = new File('${script.parent.parent.path}$indexTemplate');
    var tmpl = tmplFile.readAsStringSync();
    var content = render(tmpl, data);
    f.writeAsStringSync(content);
  }

  void generateLibrary(Library library) {
    var fileName = getFileNameFor(library.name);
    File f = new File(path.join(out.path, fileName));
    print('generating ${f.path}');
    _htmlFiles.add(fileName);
    _html = new HtmlPrinter();
    _html.start(
        title: 'Library ${library.name}',
        cssRef: _css.cssHeader,
        theme: _css.theme,
        inlineStyle: bootstrapOverrides);

    _html.generateHeader();

    _html.startTag('div', attributes: "class='container'", newLine: false);
    _html.writeln();
    _html.startTag('div', attributes: "class='row'", newLine: false);
    _html.writeln();

    // left nav
    _html.startTag('div', attributes: "class='col-md-3'");
    _html.startTag('ul', attributes: 'class="nav nav-pills nav-stacked"');
    _html.startTag('li', attributes: 'class="active"', newLine: false);
    _html.write(
        '<a href="${getFileNameFor(library.name)}">' '<i class="chevron-nav icon-white icon-chevron-right"></i> ' '${library.name}</a>');
    _html.endTag(); // li
    _html.endTag(); // ul.nav
    _html.endTag(); // div.col-md-3

    // main content
    _html.startTag('div', attributes: "class='col-md-9'");

    _html.tag('h1', contents: library.name);

    if (!library.exported.isEmpty) {
      _html.startTag('p');
      _html.write('exports ');
      for (int i = 0; i < library.exported.length; i++) {
        if (i > 0) {
          _html.write(', ');
        }

        Library lib = library.exported[i];
        if (package.libraries.contains(lib)) {
          _html.write('<a href="${getFileNameFor(lib.name)}">${lib.name}</a>');
        } else {
          _html.write(lib.name);
        }
      }
      _html.endTag();
    }

    _html.writeln('<hr>');

    _html.startTag('dl', attributes: "class=dl-horizontal");

    List<Variable> variables = library.getVariables();
    List<Accessor> accessors = library.getAccessors();
    List<ModelFunction> functions = library.getFunctions();
    List<Typedef> typedefs = library.getTypedefs();
    List<Class> types = library.getTypes();

    createToc(variables);
    createToc(accessors);
    createToc(functions);
    createToc(typedefs);
    createToc(types);

    _html.endTag(); // dl

    printComments(library);

    generateElements(variables);
    generateElements(accessors);
    generateElements(functions);
    generateElements(typedefs);

    types.forEach(generateClass);

    _html.writeln('<hr>');

    _html.endTag(); // div.col-md-9

    _html.endTag(); // div.row

    _html.endTag(); // div.container

    _html.generateFooter();

    _html.end();
    // write the file contents
    f.writeAsStringSync(_html.toString());
  }

  void createToc(List<ModelElement> elements) {
    if (!elements.isEmpty) {
      _html.tag('dt', contents: elements[0].typeName);
      _html.startTag('dd');
      for (ModelElement e in elements) {
        _html.writeln(
            '${createIconFor(e)}${e.createLinkedSummary(_helper)}<br>');
      }
      _html.endTag();
    }
  }

  void generateClass(Class cls) {
    _html.write(createAnchor(cls));
    _html.writeln('<hr>');
    _html.startTag('h4');
    generateAnnotations(cls.getAnnotations());
    _html.write(createIconFor(cls));
    if (cls.isAbstract) {
      _html.write('Abstract class ${cls.name}');
    } else {
      _html.write('Class ${cls.name}');
    }
    if (cls.hasSupertype) {
      _html.write(' extends ${_helper.createLinkedTypeName(cls.supertype)}');
    }
    if (!cls.mixins.isEmpty) {
      _html.write(' with');
      for (int i = 0; i < cls.mixins.length; i++) {
        if (i == 0) {
          _html.write(' ');
        } else {
          _html.write(', ');
        }
        _html.write(_helper.createLinkedTypeName(cls.mixins[i]));
      }
    }

    if (!cls.interfaces.isEmpty) {
      _html.write(' implements');
      for (int i = 0; i < cls.interfaces.length; i++) {
        if (i == 0) {
          _html.write(' ');
        } else {
          _html.write(', ');
        }
        _html.write(_helper.createLinkedTypeName(cls.interfaces[i]));
      }
    }

    _html.endTag();

    _html.startTag('dl', attributes: 'class=dl-horizontal');
    createToc(cls.getStaticFields());
    createToc(cls.getInstanceFields());
    createToc(cls.getAccessors());
    createToc(cls.getCtors());
    createToc(cls.getMethods());
    _html.endTag();

    printComments(cls);

    generateElements(cls.getStaticFields(), false);
    generateElements(cls.getInstanceFields(), false);
    generateElements(cls.getAccessors(), false);
    generateElements(cls.getCtors(), false);
    generateElements(cls.getMethods(), false);
  }

  void printComments(ModelElement e, [bool indent = true]) {
    String comments = e.documentation;
    if (comments != null) {
      if (indent) {
        _html.startTag('div', attributes: "class=indent");
      }
      _html.tag('p', contents: cleanupDocs(e, comments));
      if (indent) {
        _html.endTag();
      }
    } else {
      if (indent) {
        _html.tag('div', attributes: "class=indent");
      }
    }
  }

  void generateElements(List<ModelElement> elements, [bool header = true]) {
    if (!elements.isEmpty) {
      _html.tag('h4', contents: elements[0].typeName);
      if (header) {
        _html.startTag('div', attributes: "class=indent");
      }
      elements.forEach(generateElement);
      if (header) {
        _html.endTag();
      }
    }
  }

  void generateElement(ModelElement f) {
    _html.startTag('b', newLine: false);
    _html.write('${createAnchor(f)}');
    generateAnnotations(f.getAnnotations());
    _html.write(createIconFor(f));
    if (f is Method) {
      _html.write(generateOverrideIcon(f));
    }
    _html.write(f.createLinkedDescription(_helper));
    _html.endTag();
    printComments(f);
  }

  void generateAnnotations(List<String> annotations) {
    if (!annotations.isEmpty) {
      _html.write('<i class="icon-info-sign icon-hidden"></i> ');
      for (String a in annotations) {
        // TODO: I don't believe we get back the right elements for const
        // ctor annotations
        _html.writeln('@${a} ');
      }
      _html.writeln('<br>');
    }
  }

  String generateOverrideIcon(Method method) {
    ModelElement o = method.getOverriddenElement();
    if (o == null) {
      return '';
    } else if (!package.isDocumented(o)) {
      return "<i title='Overrides ${getNameFor(o)}' " "class='icon-circle-arrow-up icon-disabled'></i> ";
    } else {
      return "<a href='${_helper.createHrefFor(o)}'>" "<i title='Overrides ${getNameFor(o)}' " "class='icon-circle-arrow-up'></i></a> ";
    }
  }

  String getNameFor(ModelElement e) {
    Class c = e.getEnclosingElement();
    // TODO: upscale this! handle ctors
    String ext = (e.isExecutable) ? '()' : '';
    return '${c.name}.${htmlEscape(e.name)}${ext}';
  }

  String createAnchor(ModelElement e) {
    Class c = e.getEnclosingElement();

    if (c != null) {
      return '<a id=${c.name}.${escapeBrackets(e.name)}></a>';
    } else {
      return '<a id=${e.name}></a>';
    }
  }

  String createIconFor(ModelElement e) {
    // TODO: This icons need to be upgraded to bootstrap 3.0 - something like:
    // <span class="glyphicon glyphicon-search"></span>

    if (e.isPropertyAccessor) {
      Accessor a = (e as Accessor);
      if (a.isGetter) {
        return '<i class=icon-circle-arrow-right></i> ';
      } else {
        return '<i class=icon-circle-arrow-left></i> ';
      }
    } else if (e is Class) {
      return '<i class=icon-leaf></i> ';
    } else if (e is Function) {
      return '<i class=icon-cog></i> ';
    } else if (e.isPropertyInducer) {
      return '<i class=icon-minus-sign></i> ';
    } else if (e is Constructor) {
      return '<i class=icon-plus-sign></i> ';
    } else if (e.isExecutable) {
      return '<i class=icon-ok-sign></i> ';
    } else {
      return '';
    }
  }

  String getDocOneLiner(ModelElement e) {
    var doc = stripComments(e.documentation);
    if (doc == null || doc == '') return null;
    var endOfFirstSentence = doc.indexOf('.');
    if (endOfFirstSentence >= 0) {
      return doc.substring(0, endOfFirstSentence + 1);
    } else {
      return doc;
    }
  }

  String cleanupDocs(ModelElement e, String docs) {
    if (docs == null) {
      return '';
    }
    docs = htmlEscape(docs);
    docs = stripComments(docs);
    StringBuffer buf = new StringBuffer();

    bool inCode = false;
    bool inList = false;
    for (String line in docs.split('\n')) {
      if (inList && !line.startsWith("* ")) {
        inList = false;
        buf.write('</ul>');
      }
      if (inCode && !(line.startsWith('    ') || line.trim().isEmpty)) {
        inCode = false;
        buf.write('</pre>');
      } else if (line.startsWith('    ') && !inCode) {
        inCode = true;
        buf.write('<pre>');
      } else if (line.trim().startsWith('* ') && !inList) {
        inList = true;
        buf.write('<ul>');
      }
      if (inCode) {
        if (line.startsWith('    ')) {
          buf.write('${line.substring(4)}\n');
        } else {
          buf.write('${line}\n');
        }
      } else if (inList) {
        buf.write('<li>${_cleanupMarkdown(e, line.trim().substring(2))}</li>');
      } else if (line.trim().length == 0) {
        buf.write('</p>\n<p>');
      } else {
        buf.write('${_cleanupMarkdown(e, line)} ');
      }
    }
    if (inCode) {
      buf.write('</pre>');
    }
    return buf.toString().replaceAll('\n\n</pre>', '\n</pre>').trim();
  }

  String _cleanupMarkdown(ModelElement e, String line) {
    line = ltrim(line);
    if (line.startsWith("##")) {
      line = line.substring(2);
      if (line.endsWith("##")) {
        line = line.substring(0, line.length - 2);
      }
      line = "<h5>$line</h5>";
    } else {
      line = replaceAll(line, ['[:', ':]'], htmlEntity: 'code');
      line = replaceAll(line, ['`', '`'], htmlEntity: 'code');
      line = replaceAll(line, ['*', '*'], htmlEntity: 'i');
      line = replaceAll(line, ['__', '__'], htmlEntity: 'b');
      line = replaceAll(line, ['[', ']'], replaceFunction: (String ref) {
        return _resolveCodeReference(e, ref);
      });
    }
    return line;
  }

  String _resolveCodeReference(ModelElement e, String reference) {
    ModelElement element = e.getChild(reference);

    if (element != null && !element.isLocalElement) {
      return _helper.createLinkedName(element, true);
    } else {
      //return "<a>$reference</a>";
      return "<code>$reference</code>";
    }
  }

  void generateSiteMap() {
    print('generating sitemap.xml');
    File f = new File(path.join(out.path, 'sitemap.xml'));
    var script = new File(Platform.script.toFilePath());
    File tmplFile = new File('${script.parent.parent.path}$siteMapTemplate');
    var tmpl = tmplFile.readAsStringSync();
    // TODO: adjust urls
    List names = _htmlFiles.map((f) => {'name': '$f'}).toList();
    var content = render(tmpl, {'url': _url, 'links': names});
    f.writeAsStringSync(content);
  }
}

//class HtmlGeneratorHelper extends Helper {
//  final Package _package;
//
//  HtmlGeneratorHelper(this._package);
//
//  String createLinkedName(ModelElement e, [bool appendParens = false]) {
//    if (e == null) {
//      return '';
//    }
//    if (!_package.isDocumented(e)) {
//      return htmlEscape(e.name);
//    }
//    if (e.name.startsWith('_')) {
//      return htmlEscape(e.name);
//    }
//    Class c = e.getEnclosingElement();
//    if (c != null && c.name.startsWith('_')) {
//      return '${c.name}.${htmlEscape(e.name)}';
//    }
//    if (c != null && e is Constructor) {
//      String name;
//      if (e.name.isEmpty) {
//        name = c.name;
//      } else {
//        name = '${c.name}.${htmlEscape(e.name)}';
//      }
//      if (appendParens) {
//        return "<a href=${createHrefFor(e)}>${name}()</a>";
//      } else {
//        return "<a href=${createHrefFor(e)}>${name}</a>";
//      }
//    } else {
//      String append = '';
//
//      if (appendParens && (e is Method || e is ModelFunction)) {
//        append = '()';
//      }
//      return "<a href=${createHrefFor(e)}>${htmlEscape(e.name)}$append</a>";
//    }
//  }
//
//  String createHrefFor(ModelElement e) {
//    if (!_package.isDocumented(e)) {
//      return '';
//    }
//    Class c = e.getEnclosingElement();
//    if (c != null) {
//      return '${getFileNameFor(e.library.name)}#${c.name}.${escapeBrackets(e.name)}';
//    } else {
//      return '${getFileNameFor(e.library.name)}#${e.name}';
//    }
//  }
//
//  String printParams(List<Parameter> params) {
//    StringBuffer buf = new StringBuffer();
//
//    for (Parameter p in params) {
//      if (buf.length > 0) {
//        buf.write(', ');
//      }
//      if (p.type != null && p.type.name != null) {
//        String typeName = createLinkedTypeName(p.type);
//        if (typeName.isNotEmpty) buf.write('${typeName} ');
//      }
//      buf.write(p.name);
//    }
//    return buf.toString();
//  }
//
//  String createLinkedTypeName(ElementType type) {
//    StringBuffer buf = new StringBuffer();
//
//    if (type.isParameterType) {
//      buf.write(type.element.name);
//    } else {
//      buf.write(createLinkedName(type.element));
//    }
//
//    if (type.isParameterizedType) {
//      if (!type.typeArguments.isEmpty) {
//        buf.write('&lt;');
//        for (int i = 0; i < type.typeArguments.length; i++) {
//          if (i > 0) {
//            buf.write(', ');
//          }
//          ElementType t = type.typeArguments[i];
//          buf.write(createLinkedTypeName(t));
//        }
//        buf.write('&gt;');
//      }
//    }
//    return buf.toString();
//  }
//
//  String createLinkedReturnTypeName(ElementType type) {
//    if (type.returnElement == null) {
//      if (type.returnTypeName != null) {
//        return type.returnTypeName;
//      } else {
//        return '';
//      }
//    } else {
//      return createLinkedTypeName(type.returnType);
//    }
//  }
//}
