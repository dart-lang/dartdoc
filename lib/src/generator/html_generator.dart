// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart' as resources;
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Creates a [Generator] with an [HtmlGeneratorBackend] backend.
///
/// [forceRuntimeTemplates] should only be given [true] during tests.
Future<Generator> initHtmlGenerator(DartdocGeneratorOptionContext context,
    {bool forceRuntimeTemplates = false}) async {
  var templates = await Templates.fromContext(context,
      forceRuntimeTemplates: forceRuntimeTemplates);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend =
      HtmlGeneratorBackend(options, templates, context.resourceProvider);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for html output.
class HtmlGeneratorBackend extends DartdocGeneratorBackend {
  HtmlGeneratorBackend(DartdocGeneratorBackendOptions options,
      Templates templates, ResourceProvider resourceProvider)
      : super(options, templates, resourceProvider);

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    super.generatePackage(writer, graph, package);
    // We have to construct the data again. This only happens once per package.
    var data = PackageTemplateData(options, graph, package);
    var content = templates.renderError(data);
    write(writer, '__404error.html', data, content);
  }

  @override
  Future<void> generateAdditionalFiles(FileWriter writer) async {
    await _copyResources(writer);
    var favicon = options.favicon;
    if (favicon != null) {
      // Allow overwrite of favicon.
      var bytes = resourceProvider.getFile(favicon).readAsBytesSync();
      writer.writeBytes(
        resourceProvider.pathContext.join('static-assets', 'favicon.png'),
        bytes,
        allowOverwrite: true,
      );
    }
  }

  Future<void> _copyResources(FileWriter writer) async {
    for (var resourcePath in resources.resourceNames) {
      if (!resourcePath.startsWith(_dartdocResourcePrefix)) {
        throw StateError('Resource paths must start with '
            '$_dartdocResourcePrefix, encountered $resourcePath');
      }
      var destFileName = resourcePath.substring(_dartdocResourcePrefix.length);
      var destFilePath =
          resourceProvider.pathContext.join('static-assets', destFileName);
      writer.writeBytes(destFilePath,
          await resourceProvider.loadResourceAsBytes(resourcePath));
    }
  }

  static const _dartdocResourcePrefix = 'package:dartdoc/resources/';
}
