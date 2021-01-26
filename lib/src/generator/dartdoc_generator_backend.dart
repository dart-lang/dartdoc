// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/generator_utils.dart' as generator_util;
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/generator/templates.renderers.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path show Context;

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

  @override
  final String customHeaderContent;

  @override
  final String customFooterContent;

  @override
  final String customInnerFooterText;

  DartdocGeneratorBackendOptions.fromContext(
      DartdocGeneratorOptionContext context)
      : relCanonicalPrefix = context.relCanonicalPrefix,
        toolVersion = dartdocVersion,
        favicon = context.favicon,
        prettyIndexJson = context.prettyIndexJson,
        useBaseHref = context.useBaseHref,
        customHeaderContent = context.header,
        customFooterContent = context.footer,
        customInnerFooterText = context.footerText;

  DartdocGeneratorBackendOptions._defaults()
      : relCanonicalPrefix = null,
        toolVersion = null,
        favicon = null,
        prettyIndexJson = false,
        useBaseHref = false,
        customHeaderContent = '',
        customFooterContent = '',
        customInnerFooterText = '';
}

class SidebarGenerator<T extends TemplateData> {
  final Template template;
  final RenderFunction<T> renderFunction;
  final Map<Documentable, String> _renderCache = {};

  SidebarGenerator(this.template, this.renderFunction);

  // Retrieve the render for a specific key, or generate it using the given
  // template data if you need.
  String getRenderFor(Documentable key, T templateData) {
    return _renderCache[key] ??= renderFunction(templateData, template);
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
  final path.Context _pathContext;

  DartdocGeneratorBackend(
      DartdocGeneratorBackendOptions options, this.templates, this._pathContext)
      : options = options ?? DartdocGeneratorBackendOptions._defaults(),
        sidebarForLibrary = SidebarGenerator(
            templates.sidebarLibraryTemplate, renderSidebarForLibrary),
        sidebarForContainer = SidebarGenerator(
            templates.sidebarContainerTemplate, renderSidebarForContainer);

  /// Helper method to bind template data and emit the content to the writer.
  void write(
      FileWriter writer, String filename, TemplateData data, String content) {
    if (!options.useBaseHref) {
      content = content.replaceAll(htmlBasePlaceholder, data.htmlBase);
    }
    writer.write(filename, content,
        element: data.self is Warnable ? data.self : null);
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
    TemplateData data = PackageTemplateData(options, graph, package);
    var content = renderIndex(data, templates.indexTemplate);
    write(writer, package.filePath, data, content);
  }

  @override
  void generateCategory(
      FileWriter writer, PackageGraph packageGraph, Category category) {
    TemplateData data = CategoryTemplateData(options, packageGraph, category);
    var content = renderCategory(data, templates.categoryTemplate);
    write(writer, category.filePath, data, content);
  }

  @override
  void generateLibrary(
      FileWriter writer, PackageGraph packageGraph, Library lib) {
    TemplateData data = LibraryTemplateData(
        options, packageGraph, lib, sidebarForLibrary.getRenderFor);
    var content = renderLibrary(data, templates.libraryTemplate);
    write(writer, lib.filePath, data, content);
  }

  @override
  void generateClass(
      FileWriter writer, PackageGraph packageGraph, Library lib, Class clazz) {
    TemplateData data = ClassTemplateData(options, packageGraph, lib, clazz,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = renderClass(data, templates.classTemplate);
    write(writer, clazz.filePath, data, content);
  }

  @override
  void generateExtension(FileWriter writer, PackageGraph packageGraph,
      Library lib, Extension extension) {
    TemplateData data = ExtensionTemplateData(
        options,
        packageGraph,
        lib,
        extension,
        sidebarForLibrary.getRenderFor,
        sidebarForContainer.getRenderFor);
    var content = renderExtension(data, templates.extensionTemplate);
    write(writer, extension.filePath, data, content);
  }

  @override
  void generateMixin(
      FileWriter writer, PackageGraph packageGraph, Library lib, Mixin mixin) {
    TemplateData data = MixinTemplateData(options, packageGraph, lib, mixin,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = renderMixin(data, templates.mixinTemplate);
    write(writer, mixin.filePath, data, content);
  }

  @override
  void generateConstructor(FileWriter writer, PackageGraph packageGraph,
      Library lib, Class clazz, Constructor constructor) {
    TemplateData data = ConstructorTemplateData(options, packageGraph, lib,
        clazz, constructor, sidebarForContainer.getRenderFor);
    var content = renderConstructor(data, templates.constructorTemplate);
    write(writer, constructor.filePath, data, content);
  }

  @override
  void generateEnum(
      FileWriter writer, PackageGraph packageGraph, Library lib, Enum eNum) {
    TemplateData data = EnumTemplateData(options, packageGraph, lib, eNum,
        sidebarForLibrary.getRenderFor, sidebarForContainer.getRenderFor);
    var content = renderEnum(data, templates.enumTemplate);
    write(writer, eNum.filePath, data, content);
  }

  @override
  void generateFunction(FileWriter writer, PackageGraph packageGraph,
      Library lib, ModelFunction function) {
    TemplateData data = FunctionTemplateData(
        options, packageGraph, lib, function, sidebarForLibrary.getRenderFor);
    var content = renderFunction(data, templates.functionTemplate);
    write(writer, function.filePath, data, content);
  }

  @override
  void generateMethod(FileWriter writer, PackageGraph packageGraph, Library lib,
      Container clazz, Method method) {
    TemplateData data = MethodTemplateData(options, packageGraph, lib, clazz,
        method, sidebarForContainer.getRenderFor);
    var content = renderMethod(data, templates.methodTemplate);
    write(writer, method.filePath, data, content);
  }

  @override
  void generateConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, Container clazz, Field property) =>
      generateProperty(writer, packageGraph, lib, clazz, property);

  @override
  void generateProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, Container clazz, Field property) {
    TemplateData data = PropertyTemplateData(options, packageGraph, lib, clazz,
        property, sidebarForContainer.getRenderFor);
    var content = renderProperty(data, templates.propertyTemplate);
    write(writer, property.filePath, data, content);
  }

  @override
  void generateTopLevelProperty(FileWriter writer, PackageGraph packageGraph,
      Library lib, TopLevelVariable property) {
    TemplateData data = TopLevelPropertyTemplateData(
        options, packageGraph, lib, property, sidebarForLibrary.getRenderFor);
    var content =
        renderTopLevelProperty(data, templates.topLevelPropertyTemplate);
    write(writer, property.filePath, data, content);
  }

  @override
  void generateTopLevelConstant(FileWriter writer, PackageGraph packageGraph,
          Library lib, TopLevelVariable property) =>
      generateTopLevelProperty(writer, packageGraph, lib, property);

  @override
  void generateTypeDef(FileWriter writer, PackageGraph packageGraph,
      Library lib, Typedef typeDef) {
    TemplateData data = TypedefTemplateData(
        options, packageGraph, lib, typeDef, sidebarForLibrary.getRenderFor);
    var content = renderTypedef(data, templates.typeDefTemplate);
    write(writer, typeDef.filePath, data, content);
  }

  @override
  Future<void> generateAdditionalFiles(
      FileWriter writer, PackageGraph graph) async {}
}
