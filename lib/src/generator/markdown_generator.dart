// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';

Future<Generator> initMarkdownGenerator(
    DartdocGeneratorOptionContext context) async {
  var templates = await Templates.fromContext(context);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend = MarkdownGeneratorBackend(options, templates);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for markdown output.
class MarkdownGeneratorBackend extends DartdocGeneratorBackend {
  MarkdownGeneratorBackend(
      DartdocGeneratorBackendOptions options, Templates templates)
      : super(options, templates);

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    super.generatePackage(writer, graph, package);
    // We have to construct the data again. This only happens once per package.
    TemplateData data = PackageTemplateData(options, graph, package);
    render(writer, '__404error.md', templates.errorTemplate, data);
  }
}
