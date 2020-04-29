// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future;
import 'dart:io' show File;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart' as resources;
import 'package:dartdoc/src/generator/resource_loader.dart' as resource_loader;
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:path/path.dart' as path;

Future<Generator> initHtmlGenerator(
    DartdocGeneratorOptionContext context) async {
  var templates = await Templates.fromContext(context);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend = HtmlGeneratorBackend(options, templates);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for html output.
class HtmlGeneratorBackend extends DartdocGeneratorBackend {
  HtmlGeneratorBackend(
      DartdocGeneratorBackendOptions options, Templates templates)
      : super(options, templates);

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    super.generatePackage(writer, graph, package);
    // We have to construct the data again. This only happens once per package.
    TemplateData data = PackageTemplateData(options, graph, package);
    render(writer, '__404error.html', templates.errorTemplate, data);
  }

  @override
  void generateAdditionalFiles(FileWriter writer, PackageGraph graph) async {
    await _copyResources(writer);
    if (options.favicon != null) {
      // Allow overwrite of favicon.
      var bytes = File(options.favicon).readAsBytesSync();
      writer.write(path.join('static-assets', 'favicon.png'), bytes,
          allowOverwrite: true);
    }
  }

  Future _copyResources(FileWriter writer) async {
    final prefix = 'package:dartdoc/resources/';
    for (var resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(prefix)) {
        throw StateError('Resource paths must start with $prefix, '
            'encountered $resourcePath');
      }
      var destFileName = resourcePath.substring(prefix.length);
      writer.write(path.join('static-assets', destFileName),
          await resource_loader.loadAsBytes(resourcePath));
    }
  }
}
