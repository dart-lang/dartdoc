// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.new_html_generator;

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart' as html;
import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as path;

import 'io_utils.dart';
import 'model.dart';
import '../generator.dart';

class NewHtmlGenerator extends Generator {
  static const String indexTemplatePath = 'templates/new/index.html';
  static const String libraryTemplatePath = 'templates/new/library.html';
  static const String footerTemplatePath = 'templates/new/_footer.html';

  final String _url;
  final List<String> _htmlFiles = [];

  Package get package => _package;
  Package _package;

  Directory get out => _out;
  Directory _out;

  final String generatedOn;

  static final String indexTemplate = _loadTemplate(indexTemplatePath);
  static final String libraryTemplate = _loadTemplate(libraryTemplatePath);
  static final String footerTemplate = _loadTemplate(footerTemplatePath);

  static final Map partials = {
    'footer': footerTemplate
  };

  NewHtmlGenerator(this._url) :
    generatedOn = new DateFormat('MMMM dd yyyy').format(new DateTime.now());

  void generate(Package package, Directory out) {
    _package = package;
    _out = new Directory(path.join(out.path, 'new'));
    if (!_out.existsSync()) _out.createSync();
    generatePackage();
    _copyResources();
    package.libraries.forEach((lib) => generateLibrary(package, lib));
    // if (_url != null) {
    //   generateSiteMap();
    // }
  }

  void generatePackage() {
    var data = {};
    // TODO should we add _this_ to the context and avoid putting stuff
    // in the map?
    data.addAll({
      'package': package,
      'generatedOn': generatedOn,
      'markdown': (String s) => renderMarkdown(s, data)
    });

    _writeFile('index.html', indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    var data = {};
    // TODO should we add _this_ to the context and avoid putting stuff
    // in the map?
    data.addAll({
        'package': package,
        'library': lib,
        'generatedOn': generatedOn,
        'markdown': (String s) => renderMarkdown(s, data)
    });

    _writeFile(lib.name+'.html', libraryTemplate, data);
  }

  void _copyResources() {
    var script = new File(Platform.script.toFilePath());
    ['styles.css', 'prettify.css', 'prettify.js'].forEach((f) {
      new File(path.join(script.parent.parent.path, 'templates', 'new', f))
        .copySync(path.join(out.path, f));
    });
  }

  File _createOutputFile(String filename) {
    File f = joinFile(new Directory(out.path), [filename]);
    _htmlFiles.add(filename);
    print('generating ${f.path}');
    return f;
  }

  void _writeFile(String filename, String template, Map data) {
    File f = _createOutputFile(filename);
    String content = render(template, data, partial: _partials);
    f.writeAsStringSync(content);
  }

  static String _loadTemplate(String templatePath) {
    File script = new File(Platform.script.toFilePath());
    File tmplFile = new File(path.join(script.parent.parent.path, templatePath));
    return tmplFile.readAsStringSync();
  }

  static String _partials(String name) {
    String partial = partials[name];
    if (partial == null) {
      throw "Could not find partial '$name'";
    }
    return partial;
  }
}

// TODO: parse the custom dartdoc formatting brackets
/// Converts a markdown formatted string into HTML,
/// and removes any script tags. Returns the HTML as a string.
String renderMarkdown(String markdown, Map data) {
  String html = markdownToHtml(render(markdown.trim(), data));
  html.Document doc = parse(html);
  doc.querySelectorAll('script').forEach((s) => s.remove());
  return doc.body.innerHtml;
}