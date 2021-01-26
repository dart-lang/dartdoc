// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart' as resources;
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/generator/templates.renderers.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:path/path.dart' as path show Context;

Future<Generator> initHtmlGenerator(
    DartdocGeneratorOptionContext context) async {
  var templates = await Templates.fromContext(context);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend = HtmlGeneratorBackend(
      options, templates, context.resourceProvider.pathContext);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for html output.
class HtmlGeneratorBackend extends DartdocGeneratorBackend {
  HtmlGeneratorBackend(DartdocGeneratorBackendOptions options,
      Templates templates, path.Context pathContext)
      : super(options, templates, pathContext);

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    super.generatePackage(writer, graph, package);
    // We have to construct the data again. This only happens once per package.
    TemplateData data = PackageTemplateData(options, graph, package);
    var content = renderError(data, templates.errorTemplate);
    write(writer, '__404error.html', data, content);
  }

  @override
  Future<void> generateAdditionalFiles(
      FileWriter writer, PackageGraph graph) async {
    await _copyResources(writer);
    if (options.favicon != null) {
      // Allow overwrite of favicon.
      var bytes =
          graph.resourceProvider.getFile(options.favicon).readAsBytesSync();
      writer.write(
          graph.resourceProvider.pathContext
              .join('static-assets', 'favicon.png'),
          bytes,
          allowOverwrite: true);
    }
  }

  Future<void> _copyResources(FileWriter writer) async {
    for (var resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(_dartdocResourcePrefix)) {
        throw StateError('Resource paths must start with '
            '$_dartdocResourcePrefix, encountered $resourcePath');
      }
      var destFileName = resourcePath.substring(_dartdocResourcePrefix.length);
      var destFilePath = writer.resourceProvider.pathContext
          .join('static-assets', destFileName);
      writer.write(destFilePath,
          await writer.resourceProvider.loadResourceAsBytes(resourcePath));
    }
  }

  static const _dartdocResourcePrefix = 'package:dartdoc/resources/';
}
