// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_backend.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:meta/meta.dart';

/// Creates a [Generator] with a [MarkdownGeneratorBackend] backend.
///
/// [forceRuntimeTemplates] should only be given [true] during tests.
Future<Generator> initMarkdownGenerator(
  DartdocGeneratorOptionContext context, {
  required FileWriter writer,
  @visibleForTesting bool forceRuntimeTemplates = false,
}) async {
  var templates = await Templates.fromContext(context);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend = MarkdownGeneratorBackend(
      options, templates, writer, context.resourceProvider);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for Markdown output.
class MarkdownGeneratorBackend extends GeneratorBackendBase {
  MarkdownGeneratorBackend(
      super.options, super.templates, super.writer, super.resourceProvider);

  @override
  void generatePackage(PackageGraph packageGraph, Package package) {
    super.generatePackage(packageGraph, package);
    // We have to construct the data again. This only happens once per package.
    var data = PackageTemplateData(options, packageGraph, package);
    var content = templates.renderError(data);
    write(writer, '__404error.md', data, content);
    var searchContent = templates.renderError(data);
    write(writer, 'search.md', data, searchContent);
  }
}
