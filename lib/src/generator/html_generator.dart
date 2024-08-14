// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_backend.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart' as resources;
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:meta/meta.dart';

/// Creates a [Generator] with an [HtmlGeneratorBackend] backend.
///
/// [forceRuntimeTemplates] should only be given [true] during tests.
Future<Generator> initHtmlGenerator(
  DartdocGeneratorOptionContext context, {
  required FileWriter writer,
  @visibleForTesting bool forceRuntimeTemplates = false,
}) async {
  var templates = await Templates.fromContext(context,
      forceRuntimeTemplates: forceRuntimeTemplates);
  var options = DartdocGeneratorBackendOptions.fromContext(context);
  var backend = HtmlGeneratorBackend(
      options, templates, writer, context.resourceProvider);
  return GeneratorFrontEnd(backend);
}

/// Generator backend for HTML output.
class HtmlGeneratorBackend extends GeneratorBackend {
  HtmlGeneratorBackend(
      super.options, super.templates, super.writer, super.resourceProvider);

  @override
  void generateClass(PackageGraph packageGraph, Library library, Class class_) {
    super.generateClass(packageGraph, library, class_);
    var data = ClassTemplateData(options, packageGraph, library, class_);
    var sidebarContent = templates.renderSidebarForContainer(data);
    write(writer, class_.sidebarPath, data, sidebarContent, isSidebar: true);
    runtimeStats.incrementAccumulator('writtenSidebarFileCount');
  }

  @override
  void generateEnum(PackageGraph packageGraph, Library library, Enum enum_) {
    super.generateEnum(packageGraph, library, enum_);
    var data = EnumTemplateData(options, packageGraph, library, enum_);
    var sidebarContent = templates.renderSidebarForContainer(data);
    write(writer, enum_.sidebarPath, data, sidebarContent, isSidebar: true);
    runtimeStats.incrementAccumulator('writtenSidebarFileCount');
  }

  @override
  void generateExtension(
      PackageGraph packageGraph, Library library, Extension extension) {
    super.generateExtension(packageGraph, library, extension);
    var data = ExtensionTemplateData(options, packageGraph, library, extension);
    var sidebarContent = templates.renderSidebarForContainer(data);
    write(writer, extension.sidebarPath, data, sidebarContent, isSidebar: true);
    runtimeStats.incrementAccumulator('writtenSidebarFileCount');
  }

  @override
  void generateExtensionType(
      PackageGraph packageGraph, Library library, ExtensionType extensionType) {
    super.generateExtensionType(packageGraph, library, extensionType);
    var data = ExtensionTypeTemplateData(
        options, packageGraph, library, extensionType);
    var sidebarContent = templates.renderSidebarForContainer(data);
    write(writer, extensionType.sidebarPath, data, sidebarContent,
        isSidebar: true);
    runtimeStats.incrementAccumulator('writtenSidebarFileCount');
  }

  @override
  void generateLibrary(PackageGraph packageGraph, Library library) {
    super.generateLibrary(packageGraph, library);
    var data = LibraryTemplateData(options, packageGraph, library);
    var sidebarContent = templates.renderSidebarForLibrary(data);
    write(writer, library.sidebarPath, data, sidebarContent, isSidebar: true);
    runtimeStats.incrementAccumulator('writtenSidebarFileCount');
  }

  @override
  void generateMixin(PackageGraph packageGraph, Library library, Mixin mixin) {
    super.generateMixin(packageGraph, library, mixin);
    var data = MixinTemplateData(options, packageGraph, library, mixin);
    var sidebarContent = templates.renderSidebarForContainer(data);
    write(writer, mixin.sidebarPath, data, sidebarContent, isSidebar: true);
    runtimeStats.incrementAccumulator('writtenSidebarFileCount');
  }

  @override
  void generatePackage(PackageGraph packageGraph, Package package) {
    super.generatePackage(packageGraph, package);
    // We have to construct the data again. This only happens once per package.
    var data = PackageTemplateData(options, packageGraph, package);
    var dataForSearch =
        PackageTemplateDataForSearch(options, packageGraph, package);
    var content = templates.renderError(data);
    write(writer, '__404error.html', data, content);
    var searchContent = templates.renderSearchPage(dataForSearch);
    write(writer, 'search.html', data, searchContent);
  }

  @override
  Future<void> generateAdditionalFiles() async {
    await _copyResources(writer);
    var favicon = options.favicon;
    if (favicon != null) {
      // Allow overwrite of favicon.
      var bytes = resourceProvider.getFile(favicon).readAsBytesSync();
      writer.writeBytes(
        _pathJoin('static-assets', 'favicon.png'),
        bytes,
        allowOverwrite: true,
      );
    }
  }

  Future<void> _copyResources(FileWriter writer) async {
    var resourcesDir = options.resourcesDir ??
        (await resourceProvider.getResourceFolder(_dartdocResourcePrefix)).path;
    for (var resourceFileName in resources.resourceNames) {
      var destinationPath = _pathJoin('static-assets', resourceFileName);
      var sourcePath = _pathJoin(resourcesDir, resourceFileName);
      writer.writeBytes(
        destinationPath,
        resourceProvider.getFile(sourcePath).readAsBytesSync(),
      );
    }
  }

  String _pathJoin(String a, String b) =>
      resourceProvider.pathContext.join(a, b);

  static const _dartdocResourcePrefix = 'package:dartdoc/resources';
}
