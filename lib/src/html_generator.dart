// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:io';

import 'package:mustache4dart/mustache4dart.dart';

import 'css.dart';
import 'html_printer.dart';
import 'html_utils.dart';
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

  static final String bootstrapCss = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css';
  static final String bootstrapTheme ='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css';

  HtmlPrinter html = new HtmlPrinter();
  CSS css = new CSS();
  HtmlGeneratorHelper helper;
  List<String> htmlFiles = [];
  String url;

  HtmlGenerator(this.url) {

  }

  void generate(Package package, Directory out) {
    this.package = package;
    this.out = out;
    helper = new HtmlGeneratorHelper(package);
    generatePackage();
    package.libraries.forEach((lib) => generateLibrary(lib));
    if (url != null) {
      generateSiteMap();
    }
  }

  void generatePackage() {
    var data = {
      'css' : bootstrapCss,
      'theme' : bootstrapTheme,
      'packageName': package.name,
      'packageDesc': package.description,
      'packageVersion': package.version,
      'libraries': package.libraries.map((lib) {
          return {'name': lib.name,
                  'filename': _getFileNameFor(lib),
                  'descr': getDocOneLiner(lib)};
      })
    };
    var fileName = 'index.html';

    File f = joinFile(new Directory(out.path), [fileName]);
    htmlFiles.add(fileName);
    print('generating ${f.path}');

    var script = new File(Platform.script.toFilePath());
    File tmplFile = new File('${script.parent.parent.path}$indexTemplate');
    var tmpl = tmplFile.readAsStringSync();
    var content = render(tmpl, data);
    f.writeAsStringSync(content);
  }

  void generateLibrary(Library library) {
    var fileName = _getFileNameFor(library);
    File f = joinFile(new Directory(out.path), [fileName]);
    print('generating ${f.path}');
    htmlFiles.add(fileName);
    html = new HtmlPrinter();
    html.start(
        title: 'Library ${library.name}',
        cssRef: css.cssHeader,
        theme: css.theme,
        inlineStyle: bootstrapOverrides);

    html.generateHeader();

    html.startTag('div', attributes: "class='container'", newLine: false);
    html.writeln();
    html.startTag('div', attributes: "class='row'", newLine: false);
    html.writeln();

    // left nav
    html.startTag('div', attributes: "class='col-md-3'");
    html.startTag('ul', attributes: 'class="nav nav-pills nav-stacked"');
    html.startTag('li', attributes: 'class="active"', newLine: false);
    html.write(
        '<a href="${_getFileNameFor(library)}">' '<i class="chevron-nav icon-white icon-chevron-right"></i> ' '${library.name}</a>');
    html.endTag(); // li
    html.endTag(); // ul.nav
    html.endTag(); // div.col-md-3

    // main content
    html.startTag('div', attributes: "class='col-md-9'");

    html.tag('h1', contents: library.name);

    if (!library.exported.isEmpty) {
      html.startTag('p');
      html.write('exports ');
      for (int i = 0; i < library.exported.length; i++) {
        if (i > 0) {
          html.write(', ');
        }

        Library lib = library.exported[i];
        if (package.libraries.contains(lib)) {
          html.write('<a href="${_getFileNameFor(lib)}">${lib.name}</a>');
        } else {
          html.write(lib.name);
        }
      }
      html.endTag();
    }

    html.writeln('<hr>');

    html.startTag('dl', attributes: "class=dl-horizontal");

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

    html.endTag(); // dl

    printComments(library);

    generateElements(variables);
    generateElements(accessors);
    generateElements(functions);
    generateElements(typedefs);

    types.forEach(generateClass);

    html.writeln('<hr>');

    html.endTag(); // div.col-md-9

    html.endTag(); // div.row

    html.endTag(); // div.container

    html.generateFooter();

    html.end();

    // write the file contents
    f.writeAsStringSync(html.toString());
  }

  void createToc(List<ModelElement> elements) {
    if (!elements.isEmpty) {
      html.tag('dt', contents: elements[0].typeName);
      html.startTag('dd');
      for (ModelElement e in elements) {
        html.writeln('${createIconFor(e)}${e.createLinkedSummary(helper)}<br>');
      }
      html.endTag();
    }
  }

  void generateClass(Class cls) {
    html.write(createAnchor(cls));
    html.writeln('<hr>');
    html.startTag('h4');
    generateAnnotations(cls.getAnnotations());
    html.write(createIconFor(cls));
    if (cls.isAbstract) {
      html.write('Abstract class ${cls.name}');
    } else {
      html.write('Class ${cls.name}');
    }
    if (cls.hasSupertype) {
      html.write(' extends ${helper.createLinkedTypeName(cls.supertype)}');
    }
    if (!cls.mixins.isEmpty) {
      html.write(' with');
      for (int i = 0; i < cls.mixins.length; i++) {
        if (i == 0) {
          html.write(' ');
        } else {
          html.write(', ');
        }
        html.write(helper.createLinkedTypeName(cls.mixins[i]));
      }
    }

    if (!cls.interfaces.isEmpty) {
      html.write(' implements');
      for (int i = 0; i < cls.interfaces.length; i++) {
        if (i == 0) {
          html.write(' ');
        } else {
          html.write(', ');
        }
        html.write(helper.createLinkedTypeName(cls.interfaces[i]));
      }
    }

    html.endTag();

    html.startTag('dl', attributes: 'class=dl-horizontal');
    createToc(cls.getStaticFields());
    createToc(cls.getInstanceFields());
    createToc(cls.getAccessors());
    createToc(cls.getCtors());
    createToc(cls.getMethods());
    html.endTag();

    printComments(cls);

    generateElements(cls.getStaticFields(), false);
    generateElements(cls.getInstanceFields(), false);
    generateElements(cls.getAccessors(), false);
    generateElements(cls.getCtors(), false);
    generateElements(cls.getMethods(), false);
  }

  void printComments(ModelElement e, [bool indent = true]) {
    String comments = e.getDocumentation();
    if (comments != null) {
      if (indent) {
        html.startTag('div', attributes: "class=indent");
      }
      html.tag('p', contents: cleanupDocs(e, comments));
      if (indent) {
        html.endTag();
      }
    } else {
      if (indent) {
        html.tag('div', attributes: "class=indent");
      }
    }
  }

  void generateElements(List<ModelElement> elements, [bool header = true]) {
    if (!elements.isEmpty) {
      html.tag('h4', contents: elements[0].typeName);
      if (header) {
        html.startTag('div', attributes: "class=indent");
      }
      elements.forEach(generateElement);
      if (header) {
        html.endTag();
      }
    }
  }

  void generateElement(ModelElement f) {
    html.startTag('b', newLine: false);
    html.write('${createAnchor(f)}');
    generateAnnotations(f.getAnnotations());
    html.write(createIconFor(f));
    if (f is Method) {
      html.write(generateOverrideIcon(f));
    }
    html.write(f.createLinkedDescription(helper));
    html.endTag();
    printComments(f);
  }

  void generateAnnotations(List<String> annotations) {
    if (!annotations.isEmpty) {
      html.write('<i class="icon-info-sign icon-hidden"></i> ');
      for (String a in annotations) {
        // TODO: I don't believe we get back the right elements for const
        // ctor annotations
        html.writeln('@${a} ');
      }
      html.writeln('<br>');
    }
  }

  String generateOverrideIcon(Method method) {
    ModelElement o = method.getOverriddenElement();
    if (o == null) {
      return '';
    } else if (!package.isDocumented(o)) {
      return "<i title='Overrides ${getNameFor(o)}' " "class='icon-circle-arrow-up icon-disabled'></i> ";
    } else {
      return "<a href='${helper.createHrefFor(o)}'>" "<i title='Overrides ${getNameFor(o)}' " "class='icon-circle-arrow-up'></i></a> ";
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
    var doc = stripComments(e.getDocumentation());
    if (doc == null || doc == '') return null;
    var endOfFirstSentence = doc.indexOf('.');
    if (endOfFirstSentence >= 0) {
      return doc.substring(0, endOfFirstSentence+1);
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
      return helper.createLinkedName(element, true);
    } else {
      //return "<a>$reference</a>";
      return "<code>$reference</code>";
    }
  }

  void generateSiteMap() {
    print('generating sitemap.xml');
    File f = joinFile(new Directory(out.path), ['sitemap.xml']);
    var script = new File(Platform.script.toFilePath());
    File tmplFile = new File('${script.parent.parent.path}$siteMapTemplate');
    var tmpl = tmplFile.readAsStringSync();
    // TODO: adjust urls
    List names = htmlFiles.map((f) => {'name': '$f'}).toList();
    var content = render(tmpl, {'url': url, 'links': names});
    f.writeAsStringSync(content);
  }
}

String _getFileNameFor(Library library) {
  return '${library.name.replaceAll('.', '_').replaceAll(':', '_')}.html';
}

class HtmlGeneratorHelper extends Helper {
  Package package;

  HtmlGeneratorHelper(this.package);

  String createLinkedName(ModelElement e, [bool appendParens = false]) {
    if (e == null) {
      return '';
    }
    if (!package.isDocumented(e)) {
      return htmlEscape(e.name);
    }
    if (e.name.startsWith('_')) {
      return htmlEscape(e.name);
    }
    Class c = e.getEnclosingElement();
    if (c != null && c.name.startsWith('_')) {
      return '${c.name}.${htmlEscape(e.name)}';
    }
    if (c != null && e is Constructor) {
      String name;
      if (e.name.isEmpty) {
        name = c.name;
      } else {
        name = '${c.name}.${htmlEscape(e.name)}';
      }
      if (appendParens) {
        return "<a href=${createHrefFor(e)}>${name}()</a>";
      } else {
        return "<a href=${createHrefFor(e)}>${name}</a>";
      }
    } else {
      String append = '';

      if (appendParens && (e is Method || e is ModelFunction)) {
        append = '()';
      }
      return "<a href=${createHrefFor(e)}>${htmlEscape(e.name)}$append</a>";
    }
  }

  String createHrefFor(ModelElement e) {
    if (!package.isDocumented(e)) {
      return '';
    }
    Class c = e.getEnclosingElement();
    if (c != null) {
      return '${_getFileNameFor(e.library)}#${c.name}.${escapeBrackets(e.name)}';
    } else {
      return '${_getFileNameFor(e.library)}#${e.name}';
    }
  }

  String printParams(List<Parameter> params) {
    StringBuffer buf = new StringBuffer();

    for (Parameter p in params) {
      if (buf.length > 0) {
        buf.write(', ');
      }
      if (p.type != null && p.type.name != null) {
        String typeName = createLinkedTypeName(p.type);
        if (typeName.isNotEmpty) buf.write('${typeName} ');
      }
      buf.write(p.name);
    }
    return buf.toString();
  }

  String createLinkedTypeName(ElementType type) {
    StringBuffer buf = new StringBuffer();

    if (type.isParameterType) {
      buf.write(type.element.name);
    } else {
      buf.write(createLinkedName(type.element));
    }

    if (type.isParameterizedType) {
      if (!type.typeArguments.isEmpty) {
        buf.write('&lt;');
        for (int i = 0; i < type.typeArguments.length; i++) {
          if (i > 0) {
            buf.write(', ');
          }
          ElementType t = type.typeArguments[i];
          buf.write(createLinkedTypeName(t));
        }
        buf.write('&gt;');
      }
    }
    return buf.toString();
  }

  String createLinkedReturnTypeName(ElementType type) {
    if (type.returnElement == null) {
      if (type.returnTypeName != null) {
        return type.returnTypeName;
      } else {
        return '';
      }
    } else {
      return createLinkedTypeName(type.returnType);
    }
  }
}
