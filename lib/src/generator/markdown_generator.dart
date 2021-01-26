// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/generator/templates.renderers.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:path/path.dart' as path show Context;

Future<Generator> initMarkdownGenerator(
    DartdocGeneratorOptionContext context) async {
  var templates = await Templates.fromContext(context);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend = MarkdownGeneratorBackend(
      options, templates, context.resourceProvider.pathContext);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for markdown output.
class MarkdownGeneratorBackend extends DartdocGeneratorBackend {
  MarkdownGeneratorBackend(DartdocGeneratorBackendOptions options,
      Templates templates, path.Context pathContext)
      : super(options, templates, pathContext);

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    super.generatePackage(writer, graph, package);
    // We have to construct the data again. This only happens once per package.
    TemplateData data = PackageTemplateData(options, graph, package);
    var content = renderError(data, templates.errorTemplate);
    write(writer, '__404error.md', data, content);
  }
}
