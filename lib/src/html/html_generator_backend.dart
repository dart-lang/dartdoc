// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator_frontend.dart';
import 'package:dartdoc/src/generator_utils.dart' as generator_util;
import 'package:dartdoc/src/html/resource_loader.dart' as loader;
import 'package:dartdoc/src/html/resources.g.dart' as resources;
import 'package:dartdoc/src/html/template_data.dart';
import 'package:dartdoc/src/html/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

class HtmlBackendOptions implements HtmlOptions {
  @override
  final String relCanonicalPrefix;
  @override
  final String toolVersion;

  final String favicon;

  @override
  final bool useBaseHref;

  HtmlBackendOptions({this.relCanonicalPrefix, this.toolVersion, this.favicon, this.useBaseHref});
}

class HtmlGeneratorBackend implements GeneratorBackend {
  final HtmlBackendOptions _options;
  final Templates _templates;

  static Future<HtmlGeneratorBackend> fromContext(
      GeneratorContext context) async {
    Templates templates = await Templates.fromContext(context);
    HtmlOptions options = HtmlBackendOptions(
      relCanonicalPrefix: context.relCanonicalPrefix,
      toolVersion: dartdocVersion,
      favicon: context.favicon,
    );
    return HtmlGeneratorBackend(options, templates);
  }

  HtmlGeneratorBackend(HtmlBackendOptions options, this._templates)
      : this._options = (options ?? HtmlBackendOptions());

  /// Helper method to bind template data and emit the content to the writer.
  void _render(FileWriter writer, String filename, Template template,
      TemplateData data) {
    String content = template.renderString(data);
    if (!_options.useBaseHref) {
      content = content.replaceAll(HTMLBASE_PLACEHOLDER, data.htmlBase);
    }
    writer.write(filename, content);
  }

  @override
  void generateCategoryJson(
      FileWriter writer, List<Categorization> categories) {
    String json = generator_util.generateCategoryJson(categories);
    if (!_options.useBaseHref) {
      json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    }
    writer.write(path.join('categories.json'), '${json}\n');
  }

  @override
  void generateSearchIndex(FileWriter writer, List<Indexable> indexedElements) {
    // TODO pretty-index-json from generator options
    String json =
        generator_util.generateSearchIndexJson(indexedElements, false);
    if (!_options.useBaseHref) {
      json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    }
    writer.write(path.join('index.json'), '${json}\n');
  }

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    TemplateData data = PackageTemplateData(_options, graph, package);
    _render(writer, package.filePath, _templates.indexTemplate, data);
    _render(writer, '__404error.html', _templates.errorTemplate, data);
  }

  @override
  void generateCategory(
      FileWriter writer, PackageGraph packageGraph, Category category) {
    TemplateData data = CategoryTemplateData(_options, packageGraph, category);
    _render(writer, category.filePath, _templates.categoryTemplate, data);
  }

  @override
  void generateLibrary(
      FileWriter writer, PackageGraph packageGraph, Library lib) {
    TemplateData data = LibraryTemplateData(_options, packageGraph, lib);
    _render(writer, lib.filePath, _templates.libraryTemplate, data);
  }

  @override
  void generateClass(
      FileWriter writer, PackageGraph packageGraph, Library lib, Class clazz) {
    TemplateData data = ClassTemplateData(_options, packageGraph, lib, clazz);
    _render(writer, clazz.filePath, _templates.classTemplate, data);
  }

  @override
  void generateExtension(FileWriter writer, PackageGraph packageGraph,
      Library lib, Extension extension) {
    TemplateData data =
        ExtensionTemplateData(_options, packageGraph, lib, extension);
    _render(writer, extension.filePath, _templates.extensionTemplate, data);
  }

  @override
  void generateMixin(
      FileWriter writer, PackageGraph packageGraph, Library lib, Mixin mixin) {
    TemplateData data = MixinTemplateData(_options, packageGraph, lib, mixin);
    _render(writer, mixin.filePath, _templates.mixinTemplate, data);
  }

  @override
  void generateConstructor(FileWriter writer, PackageGraph packageGraph,
      Library lib, Class clazz, Constructor constructor) {
    TemplateData data = ConstructorTemplateData(
        _options, packageGraph, lib, clazz, constructor);

    _render(writer, constructor.filePath, _templates.constructorTemplate, data);
  }

  @override
  void generateEnum(
      FileWriter writer, PackageGraph packageGraph, Library lib, Enum eNum) {
    TemplateData data = EnumTemplateData(_options, packageGraph, lib, eNum);

    _render(writer, eNum.filePath, _templates.enumTemplate, data);
  }

  @override
  void generateFunction(FileWriter writer, PackageGraph packageGraph,
      Library lib, ModelFunction function) {
    TemplateData data =
        FunctionTemplateData(_options, packageGraph, lib, function);

    _render(writer, function.filePath, _templates.functionTemplate, data);
  }

  @override
  void generateMethod(FileWriter writer, PackageGraph packageGraph, Library lib,
      Container clazz, Method method) {
    TemplateData data =
        MethodTemplateData(_options, packageGraph, lib, clazz, method);

    _render(writer, method.filePath, _templates.methodTemplate, data);
  }

  @override
  void generateConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, Container clazz, Field property) =>
      generateProperty(writer, packageGraph, lib, clazz, property);

  @override
  void generateProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, Container clazz, Field property) {
    TemplateData data =
        PropertyTemplateData(_options, packageGraph, lib, clazz, property);

    _render(writer, property.filePath, _templates.propertyTemplate, data);
  }

  @override
  void generateTopLevelProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, TopLevelVariable property) {
    TemplateData data =
        TopLevelPropertyTemplateData(_options, packageGraph, lib, property);

    _render(
        writer, property.filePath, _templates.topLevelPropertyTemplate, data);
  }

  @override
  void generateTopLevelConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, TopLevelVariable property) =>
      generateTopLevelProperty(writer, packageGraph, lib, property);

  @override
  void generateTypeDef(FileWriter writer, PackageGraph packageGraph,
      Library lib, Typedef typeDef) {
    TemplateData data =
        TypedefTemplateData(_options, packageGraph, lib, typeDef);

    _render(writer, typeDef.filePath, _templates.typeDefTemplate, data);
  }

  @override
  void generateAdditionalFiles(FileWriter writer, PackageGraph graph) async {
    if (_options.favicon != null) {
      var bytes = File(_options.favicon).readAsBytesSync();
      // Allow overwrite of favicon.
      writer.write(path.join('static-assets', 'favicon.png'), bytes, allowOverwrite: true);
    }
    await _copyResources(writer);
  }

  // TODO: change this to use resource_loader
  Future _copyResources(FileWriter writer) async {
    final prefix = 'package:dartdoc/resources/';
    for (String resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(prefix)) {
        throw StateError('Resource paths must start with $prefix, '
            'encountered $resourcePath');
      }
      String destFileName = resourcePath.substring(prefix.length);
      writer.write(path.join('static-assets', destFileName),
          await loader.loadAsBytes(resourcePath));
    }
  }
}
