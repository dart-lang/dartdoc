// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Creates a [Generator] with an [MarkdownGeneratorBackend] backend.
///
/// [forceRuntimeTemplates] should only be given [true] during tests.
Future<Generator> initMarkdownGenerator(DartdocGeneratorOptionContext context,
    {bool forceRuntimeTemplates = false}) async {
  var templates = await Templates.fromContext(context);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend =
      MarkdownGeneratorBackend(options, templates, context.resourceProvider);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for markdown output.
class MarkdownGeneratorBackend extends DartdocGeneratorBackend {
  MarkdownGeneratorBackend(DartdocGeneratorBackendOptions options,
      Templates templates, ResourceProvider resourceProvider)
      : super(options, templates, resourceProvider);

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    super.generatePackage(writer, graph, package);
    // We have to construct the data again. This only happens once per package.
    TemplateData data = PackageTemplateData(options, graph, package);
    var content = templates.renderError(data);
    write(writer, '__404error.md', data, content);
  }
}
