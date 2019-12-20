// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

class HtmlGeneratorBackend implements GeneratorBackend {
  final HtmlOptions _options;
  final Templates _templates;

  HtmlGeneratorBackend(this._options, this._templates);

  void _write(FileWriter writer, String filename, Template template,
      TemplateData data) {
    String content = template.renderString(data);
    content = content.replaceAll(HTMLBASE_PLACEHOLDER, data.htmlBase);
    writer.write(filename, content);
  }

  @override
  void generateCategoryJson(
      FileWriter writer, List<Categorization> categories) {
    String json = generator_util.generateCategoryJson(categories);
    json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    writer.write(path.join('categories.json'), '${json}\n');
  }

  @override
  void generateSearchIndex(FileWriter writer, List<Indexable> indexedElements) {
    // TODO pretty-index-json from generator options
    String json =
        generator_util.generateSearchIndexJson(indexedElements, false);
    json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    writer.write(path.join('categories.json'), '${json}\n');
  }

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    TemplateData data = PackageTemplateData(_options, graph, package);
    _write(writer, package.filePath, _templates.indexTemplate, data);
    _write(writer, '__404error.html', _templates.errorTemplate, data);
  }

  @override
  void generateCategory(
      FileWriter writer, PackageGraph packageGraph, Category category) {
    TemplateData data = CategoryTemplateData(_options, packageGraph, category);
    _write(writer, category.filePath, _templates.categoryTemplate, data);
  }

  @override
  void generateLibrary(
      FileWriter writer, PackageGraph packageGraph, Library lib) {
    TemplateData data = LibraryTemplateData(_options, packageGraph, lib);
    _write(writer, lib.filePath, _templates.libraryTemplate, data);
  }

  @override
  void generateClass(
      FileWriter writer, PackageGraph packageGraph, Library lib, Class clazz) {
    TemplateData data = ClassTemplateData(_options, packageGraph, lib, clazz);
    _write(writer, clazz.filePath, _templates.classTemplate, data);
  }

  @override
  void generateExtension(FileWriter writer, PackageGraph packageGraph,
      Library lib, Extension extension) {
    TemplateData data =
        ExtensionTemplateData(_options, packageGraph, lib, extension);
    _write(writer, extension.filePath, _templates.extensionTemplate, data);
  }

  @override
  void generateMixin(
      FileWriter writer, PackageGraph packageGraph, Library lib, Mixin mixin) {
    TemplateData data = MixinTemplateData(_options, packageGraph, lib, mixin);
    _write(writer, mixin.filePath, _templates.mixinTemplate, data);
  }

  @override
  void generateConstructor(FileWriter writer, PackageGraph packageGraph,
      Library lib, Class clazz, Constructor constructor) {
    TemplateData data = ConstructorTemplateData(
        _options, packageGraph, lib, clazz, constructor);

    _write(writer, constructor.filePath, _templates.constructorTemplate, data);
  }

  @override
  void generateEnum(
      FileWriter writer, PackageGraph packageGraph, Library lib, Enum eNum) {
    TemplateData data = EnumTemplateData(_options, packageGraph, lib, eNum);

    _write(writer, eNum.filePath, _templates.enumTemplate, data);
  }

  @override
  void generateFunction(FileWriter writer, PackageGraph packageGraph,
      Library lib, ModelFunction function) {
    TemplateData data =
        FunctionTemplateData(_options, packageGraph, lib, function);

    _write(writer, function.filePath, _templates.functionTemplate, data);
  }

  @override
  void generateMethod(FileWriter writer, PackageGraph packageGraph, Library lib,
      Container clazz, Method method) {
    TemplateData data =
        MethodTemplateData(_options, packageGraph, lib, clazz, method);

    _write(writer, method.filePath, _templates.methodTemplate, data);
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

    _write(writer, property.filePath, _templates.propertyTemplate, data);
  }

  @override
  void generateTopLevelProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, TopLevelVariable property) {
    TemplateData data =
        TopLevelPropertyTemplateData(_options, packageGraph, lib, property);

    _write(
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

    _write(writer, typeDef.filePath, _templates.typeDefTemplate, data);
  }

  @override
  void generateAdditionalFiles(FileWriter writer, PackageGraph graph) async {
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
