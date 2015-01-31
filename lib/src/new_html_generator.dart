// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.new_html_generator;

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as path;

import 'io_utils.dart';
import 'model.dart';
import '../generator.dart';

class NewHtmlGenerator extends Generator {
  static final String indexTemplate = 'templates/new/index.html';

  final String _url;
  final List<String> _htmlFiles = [];

  Package get package => _package;
  Package _package;

  Directory get out => _out;
  Directory _out;

  NewHtmlGenerator(this._url);

  void generate(Package package, Directory out) {
    _package = package;
    _out = new Directory(path.join(out.path, 'new'));
    if (!_out.existsSync()) _out.createSync();
    generatePackage();
    copyResources();
    //package.libraries.forEach((lib) => generateLibrary(lib));
    // if (_url != null) {
    //   generateSiteMap();
    // }
  }

  void generatePackage() {
    var date = new DateFormat('MMMM dd yyyy').format(new DateTime.now());
    var data = {};
    data.addAll({
      'package': package,
      'generatedOn': date,
      'markdown': (s) => markdownToHtml(render(s, data))
    });
    var fileName = 'index.html';

    File f = joinFile(new Directory(out.path), [fileName]);
    _htmlFiles.add(fileName);
    print('generating ${f.path}');

    var script = new File(Platform.script.toFilePath());
    File tmplFile = new File(path.join(script.parent.parent.path, indexTemplate));
    var tmpl = tmplFile.readAsStringSync();
    var content = render(tmpl, data);
    f.writeAsStringSync(content);
  }

  void copyResources() {
    var script = new File(Platform.script.toFilePath());
    ['styles.css', 'prettify.css', 'prettify.js'].forEach((f) {
      new File(path.join(script.parent.parent.path, 'templates', 'new', f))
        .copySync(path.join(out.path, f));
    });
  }
}
