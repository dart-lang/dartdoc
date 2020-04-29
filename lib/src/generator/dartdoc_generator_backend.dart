// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/generator_utils.dart' as generator_util;
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

/// Configuration options for the Dartdoc's default backend.
class DartdocGeneratorBackendOptions implements TemplateOptions {
  @override
  final String relCanonicalPrefix;
  @override
  final String toolVersion;

  final String favicon;

  final bool prettyIndexJson;

  @override
  final bool useBaseHref;

  DartdocGeneratorBackendOptions.fromContext(
      DartdocGeneratorOptionContext context)
      : relCanonicalPrefix = context.relCanonicalPrefix,
        toolVersion = dartdocVersion,
        favicon = context.favicon,
        prettyIndexJson = context.prettyIndexJson,
        useBaseHref = context.useBaseHref;

  DartdocGeneratorBackendOptions(
      {this.relCanonicalPrefix,
      this.toolVersion,
      this.favicon,
      this.prettyIndexJson = false,
      this.useBaseHref = false});
}

/// Base GeneratorBackend for Dartdoc's supported formats.
abstract class DartdocGeneratorBackend implements GeneratorBackend {
  final DartdocGeneratorBackendOptions options;
  final Templates templates;

  DartdocGeneratorBackend(
      DartdocGeneratorBackendOptions options, this.templates)
      : options = (options ?? DartdocGeneratorBackendOptions());

  /// Helper method to bind template data and emit the content to the writer.
  void render(FileWriter writer, String filename, Template template,
      TemplateData data) {
    var content = template.renderString(data);
    if (!options.useBaseHref) {
      content = content.replaceAll(HTMLBASE_PLACEHOLDER, data.htmlBase);
    }
    writer.write(filename, content,
        element: data.self is Warnable ? data.self : null);
  }

  @override
  void generateCategoryJson(
      FileWriter writer, List<Categorization> categories) {
    var json = generator_util.generateCategoryJson(
        categories, options.prettyIndexJson);
    if (!options.useBaseHref) {
      json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    }
    writer.write(path.join('categories.json'), '${json}\n');
  }

  @override
  void generateSearchIndex(FileWriter writer, List<Indexable> indexedElements) {
    var json = generator_util.generateSearchIndexJson(
        indexedElements, options.prettyIndexJson);
    if (!options.useBaseHref) {
      json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    }
    writer.write(path.join('index.json'), '${json}\n');
  }

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    TemplateData data = PackageTemplateData(options, graph, package);
    render(writer, package.filePath, templates.indexTemplate, data);
  }

  @override
  void generateCategory(
      FileWriter writer, PackageGraph packageGraph, Category category) {
    TemplateData data = CategoryTemplateData(options, packageGraph, category);
    render(writer, category.filePath, templates.categoryTemplate, data);
  }

  @override
  void generateLibrary(
      FileWriter writer, PackageGraph packageGraph, Library lib) {
    TemplateData data = LibraryTemplateData(options, packageGraph, lib);
    render(writer, lib.filePath, templates.libraryTemplate, data);
  }

  @override
  void generateClass(
      FileWriter writer, PackageGraph packageGraph, Library lib, Class clazz) {
    TemplateData data = ClassTemplateData(options, packageGraph, lib, clazz);
    render(writer, clazz.filePath, templates.classTemplate, data);
  }

  @override
  void generateExtension(FileWriter writer, PackageGraph packageGraph,
      Library lib, Extension extension) {
    TemplateData data =
        ExtensionTemplateData(options, packageGraph, lib, extension);
    render(writer, extension.filePath, templates.extensionTemplate, data);
  }

  @override
  void generateMixin(
      FileWriter writer, PackageGraph packageGraph, Library lib, Mixin mixin) {
    TemplateData data = MixinTemplateData(options, packageGraph, lib, mixin);
    render(writer, mixin.filePath, templates.mixinTemplate, data);
  }

  @override
  void generateConstructor(FileWriter writer, PackageGraph packageGraph,
      Library lib, Class clazz, Constructor constructor) {
    TemplateData data =
        ConstructorTemplateData(options, packageGraph, lib, clazz, constructor);

    render(writer, constructor.filePath, templates.constructorTemplate, data);
  }

  @override
  void generateEnum(
      FileWriter writer, PackageGraph packageGraph, Library lib, Enum eNum) {
    TemplateData data = EnumTemplateData(options, packageGraph, lib, eNum);

    render(writer, eNum.filePath, templates.enumTemplate, data);
  }

  @override
  void generateFunction(FileWriter writer, PackageGraph packageGraph,
      Library lib, ModelFunction function) {
    TemplateData data =
        FunctionTemplateData(options, packageGraph, lib, function);

    render(writer, function.filePath, templates.functionTemplate, data);
  }

  @override
  void generateMethod(FileWriter writer, PackageGraph packageGraph, Library lib,
      Container clazz, Method method) {
    TemplateData data =
        MethodTemplateData(options, packageGraph, lib, clazz, method);

    render(writer, method.filePath, templates.methodTemplate, data);
  }

  @override
  void generateConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, Container clazz, Field property) =>
      generateProperty(writer, packageGraph, lib, clazz, property);

  @override
  void generateProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, Container clazz, Field property) {
    TemplateData data =
        PropertyTemplateData(options, packageGraph, lib, clazz, property);

    render(writer, property.filePath, templates.propertyTemplate, data);
  }

  @override
  void generateTopLevelProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, TopLevelVariable property) {
    TemplateData data =
        TopLevelPropertyTemplateData(options, packageGraph, lib, property);

    render(writer, property.filePath, templates.topLevelPropertyTemplate, data);
  }

  @override
  void generateTopLevelConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, TopLevelVariable property) =>
      generateTopLevelProperty(writer, packageGraph, lib, property);

  @override
  void generateTypeDef(FileWriter writer, PackageGraph packageGraph,
      Library lib, Typedef typeDef) {
    TemplateData data =
        TypedefTemplateData(options, packageGraph, lib, typeDef);

    render(writer, typeDef.filePath, templates.typeDefTemplate, data);
  }

  @override
  void generateAdditionalFiles(FileWriter writer, PackageGraph graph) {}
}
