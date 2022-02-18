// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/generator_utils.dart' as generator_util;
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/version.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p show Context;

/// Configuration options for the Dartdoc's default backend.
class DartdocGeneratorBackendOptions implements TemplateOptions {
  @override
  final String? relCanonicalPrefix;

  @override
  final String toolVersion;

  final String? favicon;

  final bool prettyIndexJson;

  @override
  final bool useBaseHref;

  @override
  final String customHeaderContent;

  @override
  final String customFooterContent;

  @override
  final String customInnerFooterText;

  final String? resourcesDir;

  DartdocGeneratorBackendOptions.fromContext(
      DartdocGeneratorOptionContext context)
      : relCanonicalPrefix = context.relCanonicalPrefix,
        toolVersion = packageVersion,
        favicon = context.favicon,
        prettyIndexJson = context.prettyIndexJson,
        useBaseHref = context.useBaseHref,
        customHeaderContent = context.header,
        customFooterContent = context.footer,
        customInnerFooterText = context.footerText,
        resourcesDir = context.resourcesDir;
}

class SidebarGenerator<T extends TemplateData> {
  final String Function(T context) renderFunction;
  final Map<Documentable, String> _renderCache = {};

  SidebarGenerator(this.renderFunction);

  // Retrieve the render for a specific key, or generate it using the given
  // template data if you need.
  String getRenderFor(Documentable key, T templateData) {
    return _renderCache[key] ??= renderFunction(templateData);
  }
}

/// Base GeneratorBackend for Dartdoc's supported formats.
abstract class DartdocGeneratorBackend implements GeneratorBackend {
  final DartdocGeneratorBackendOptions options;
  final Templates templates;
  final SidebarGenerator<TemplateDataWithLibrary<Documentable>>
      sidebarForLibrary;
  final SidebarGenerator<TemplateDataWithContainer<Documentable>>
      sidebarForContainer;
  final ResourceProvider resourceProvider;
  final p.Context _pathContext;

  DartdocGeneratorBackend(this.options, this.templates, this.resourceProvider)
      : sidebarForLibrary = SidebarGenerator(templates.renderSidebarForLibrary),
        sidebarForContainer =
            SidebarGenerator(templates.renderSidebarForContainer),
        _pathContext = resourceProvider.pathContext;

  /// Helper method to bind template data and emit the content to the writer.
  void write(
      FileWriter writer, String filename, TemplateData data, String content) {
    if (!options.useBaseHref) {
      content = content.replaceAll(htmlBasePlaceholder, data.htmlBase);
    }
    var element = data.self;
    writer.write(filename, content,
        element: element is Warnable ? element : null);
  }

  @override
  void generateCategoryJson(
      FileWriter writer, List<Categorization> categories) {
    var json = '[]';
    if (categories.isNotEmpty) {
      json = generator_util.generateCategoryJson(
          categories, options.prettyIndexJson);
      if (!options.useBaseHref) {
        json = json.replaceAll(htmlBasePlaceholder, '');
      }
    }

    writer.write(_pathContext.join('categories.json'), '$json\n');
  }

  @override
  void generateSearchIndex(FileWriter writer, List<Indexable> indexedElements) {
    var json = generator_util.generateSearchIndexJson(
        indexedElements, options.prettyIndexJson);
    if (!options.useBaseHref) {
      json = json.replaceAll(htmlBasePlaceholder, '');
    }
    writer.write(_pathContext.join('index.json'), '$json\n');
  }

  @override
  void generatePackage(FileWriter writer, PackageGraph graph, Package package) {
    var data = PackageTemplateData(options, graph, package);
    var content = templates.renderIndex(data);
    write(writer, package.filePath, data, content);
  }

  @override
  void generateCategory(
      FileWriter writer, PackageGraph packageGraph, Category category) {
    var data = CategoryTemplateData(options, packageGraph, category);
    var content = templates.renderCategory(data);
    write(writer, category.filePath, data, content);
  }

  @override
  void generateLibrary(
      FileWriter writer, PackageGraph packageGraph, Library lib) {
    var data = LibraryTemplateData(
        options, packageGraph, lib, sidebarForLibrary.getRenderFor);
    var content = templates.renderLibrary(data);
    write(writer, lib.filePath, data, content);
  }

  @override
  void generateClass(
      FileWriter writer, PackageGraph packageGraph, Library lib, Class clazz) {
    var data = ClassTemplateData(options, packageGraph, lib, clazz,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = templates.renderClass(data);
    write(writer, clazz.filePath, data, content);
  }

  @override
  void generateExtension(FileWriter writer, PackageGraph packageGraph,
      Library lib, Extension extension) {
    var data = ExtensionTemplateData(options, packageGraph, lib, extension,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = templates.renderExtension(data);
    write(writer, extension.filePath, data, content);
  }

  @override
  void generateMixin(
      FileWriter writer, PackageGraph packageGraph, Library lib, Mixin mixin) {
    var data = MixinTemplateData(options, packageGraph, lib, mixin,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = templates.renderMixin(data);
    write(writer, mixin.filePath, data, content);
  }

  @override
  void generateConstructor(FileWriter writer, PackageGraph packageGraph,
      Library lib, Class clazz, Constructor constructor) {
    var data = ConstructorTemplateData(options, packageGraph, lib, clazz,
        constructor, sidebarForContainer.getRenderFor);
    var content = templates.renderConstructor(data);
    write(writer, constructor.filePath, data, content);
  }

  @override
  void generateEnum(
      FileWriter writer, PackageGraph packageGraph, Library lib, Enum eNum) {
    var data = EnumTemplateData(options, packageGraph, lib, eNum,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = templates.renderEnum(data);
    write(writer, eNum.filePath, data, content);
  }

  @override
  void generateFunction(FileWriter writer, PackageGraph packageGraph,
      Library lib, ModelFunction function) {
    var data = FunctionTemplateData(
        options, packageGraph, lib, function, sidebarForLibrary.getRenderFor);
    var content = templates.renderFunction(data);
    write(writer, function.filePath, data, content);
  }

  @override
  void generateMethod(FileWriter writer, PackageGraph packageGraph, Library lib,
      Container clazz, Method method) {
    var data = MethodTemplateData(options, packageGraph, lib, clazz, method,
        sidebarForContainer.getRenderFor);
    var content = templates.renderMethod(data);
    write(writer, method.filePath, data, content);
  }

  @override
  void generateConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, Container clazz, Field property) =>
      generateProperty(writer, packageGraph, lib, clazz, property);

  @override
  void generateProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, Container clazz, Field property) {
    var data = PropertyTemplateData(options, packageGraph, lib, clazz, property,
        sidebarForContainer.getRenderFor);
    var content = templates.renderProperty(data);
    write(writer, property.filePath, data, content);
  }

  @override
  void generateTopLevelProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, TopLevelVariable property) {
    var data = TopLevelPropertyTemplateData(
        options, packageGraph, lib, property, sidebarForLibrary.getRenderFor);
    var content = templates.renderTopLevelProperty(data);
    write(writer, property.filePath, data, content);
  }

  @override
  void generateTopLevelConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, TopLevelVariable property) =>
      generateTopLevelProperty(writer, packageGraph, lib, property);

  @override
  void generateTypeDef(FileWriter writer, PackageGraph packageGraph,
      Library lib, Typedef typeDef) {
    var data = TypedefTemplateData(
        options, packageGraph, lib, typeDef, sidebarForLibrary.getRenderFor);
    var content = templates.renderTypedef(data);
    write(writer, typeDef.filePath, data, content);
  }

  @override
  Future<void> generateAdditionalFiles(FileWriter writer) async {}
}
