// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_utils.dart' as generator_util;
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/version.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p show Context;

@Deprecated('Refer to GeneratorBackendBase directly')
typedef DartdocGeneratorBackend = GeneratorBackendBase;

/// Configuration options for Dartdoc's default backend.
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

  /// Retrieves the render for a specific [key], or generates it using the given
  /// [templateData] if needed.
  String getRenderFor(Documentable key, T templateData) {
    return _renderCache[key] ??= renderFunction(templateData);
  }
}

/// An interface for classes which are responsible for outputing the generated
/// documentation.
abstract class GeneratorBackend {
  FileWriter get writer;

  /// Emits JSON describing the [categories] defined by the package.
  void generateCategoryJson(List<Categorization> categories);

  /// Emits a JSON catalog of [indexedElements] for use with a search index.
  void generateSearchIndex(List<Indexable> indexedElements);

  /// Emits documentation content for the [package].
  void generatePackage(PackageGraph graph, Package package);

  /// Emits documentation content for the [category].
  void generateCategory(PackageGraph graph, Category category);

  /// Emits documentation content for the [library].
  void generateLibrary(PackageGraph graph, Library library);

  /// Emits documentation content for the [clazz].
  void generateClass(PackageGraph graph, Library library, Class clazz);

  /// Emits documentation content for the [eNum].
  void generateEnum(PackageGraph graph, Library library, Enum eNum);

  /// Emits documentation content for the [mixin].
  void generateMixin(PackageGraph graph, Library library, Mixin mixin);

  /// Emits documentation content for the [constructor].
  void generateConstructor(PackageGraph graph, Library library,
      Constructable constructable, Constructor constructor);

  /// Emits documentation content for the [field].
  void generateConstant(
      PackageGraph graph, Library library, Container clazz, Field field);

  /// Emits documentation content for the [field].
  void generateProperty(
      PackageGraph graph, Library library, Container clazz, Field field);

  /// Emits documentation content for the [method].
  void generateMethod(
      PackageGraph graph, Library library, Container clazz, Method method);

  /// Emits documentation content for the [extension].
  void generateExtension(
      PackageGraph graph, Library library, Extension extension);

  /// Emits documentation content for the [function].
  void generateFunction(
      PackageGraph graph, Library library, ModelFunction function);

  /// Emits documentation content for the [constant].
  void generateTopLevelConstant(
      PackageGraph graph, Library library, TopLevelVariable constant);

  /// Emits documentation content for the [property].
  void generateTopLevelProperty(
      PackageGraph graph, Library library, TopLevelVariable property);

  /// Emits documentation content for the [typedef].
  void generateTypeDef(PackageGraph graph, Library library, Typedef typedef);

  /// Emits files not specific to a Dart language element (like a favicon, etc).
  Future<void> generateAdditionalFiles();
}

/// Base [GeneratorBackend] for Dartdoc's supported formats.
abstract class GeneratorBackendBase implements GeneratorBackend {
  final DartdocGeneratorBackendOptions options;
  final Templates templates;
  final SidebarGenerator<TemplateDataWithLibrary<Documentable>>
      _sidebarForLibrary;
  final SidebarGenerator<TemplateDataWithContainer<Documentable>>
      _sidebarForContainer;

  @override
  final FileWriter writer;
  final ResourceProvider resourceProvider;
  final p.Context _pathContext;

  GeneratorBackendBase(
      this.options, this.templates, this.writer, this.resourceProvider)
      : _sidebarForLibrary =
            SidebarGenerator(templates.renderSidebarForLibrary),
        _sidebarForContainer =
            SidebarGenerator(templates.renderSidebarForContainer),
        _pathContext = resourceProvider.pathContext;

  /// Binds template data and emits the content to the [writer].
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
  void generateCategoryJson(List<Categorization> categories) {
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
  void generateSearchIndex(List<Indexable> indexedElements) {
    var json = generator_util.generateSearchIndexJson(
        indexedElements, options.prettyIndexJson);
    if (!options.useBaseHref) {
      json = json.replaceAll(htmlBasePlaceholder, '');
    }
    writer.write(_pathContext.join('index.json'), '$json\n');
  }

  @override
  void generateCategory(PackageGraph packageGraph, Category category) {
    var data = CategoryTemplateData(options, packageGraph, category);
    var content = templates.renderCategory(data);
    write(writer, category.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenCategoryFileCount');
  }

  @override
  void generateClass(PackageGraph packageGraph, Library lib, Class clazz) {
    var data = ClassTemplateData(options, packageGraph, lib, clazz,
        _sidebarForLibrary.getRenderFor, _sidebarForContainer.getRenderFor);
    var content = templates.renderClass(data);
    write(writer, clazz.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenClassFileCount');
  }

  @override
  void generateConstant(PackageGraph packageGraph, Library lib, Container clazz,
          Field property) =>
      generateProperty(packageGraph, lib, clazz, property);

  @override
  void generateConstructor(PackageGraph packageGraph, Library lib,
      Constructable constructable, Constructor constructor) {
    var data = ConstructorTemplateData(options, packageGraph, lib,
        constructable, constructor, _sidebarForContainer.getRenderFor);
    var content = templates.renderConstructor(data);
    write(writer, constructor.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenConstructorFileCount');
  }

  @override
  void generateEnum(PackageGraph packageGraph, Library lib, Enum eNum) {
    var data = EnumTemplateData(options, packageGraph, lib, eNum,
        _sidebarForLibrary.getRenderFor, _sidebarForContainer.getRenderFor);
    var content = templates.renderEnum(data);
    write(writer, eNum.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenEnumFileCount');
  }

  @override
  void generateExtension(
      PackageGraph packageGraph, Library lib, Extension extension) {
    var data = ExtensionTemplateData(options, packageGraph, lib, extension,
        _sidebarForLibrary.getRenderFor, _sidebarForContainer.getRenderFor);
    var content = templates.renderExtension(data);
    write(writer, extension.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenExtensionFileCount');
  }

  @override
  void generateFunction(
      PackageGraph packageGraph, Library lib, ModelFunction function) {
    var data = FunctionTemplateData(
        options, packageGraph, lib, function, _sidebarForLibrary.getRenderFor);
    var content = templates.renderFunction(data);
    write(writer, function.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenFunctionFileCount');
  }

  @override
  void generateLibrary(PackageGraph packageGraph, Library lib) {
    var data = LibraryTemplateData(
        options, packageGraph, lib, _sidebarForLibrary.getRenderFor);
    var content = templates.renderLibrary(data);
    write(writer, lib.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenLibraryFileCount');
  }

  @override
  void generateMethod(
      PackageGraph packageGraph, Library lib, Container clazz, Method method) {
    var data = MethodTemplateData(options, packageGraph, lib, clazz, method,
        _sidebarForContainer.getRenderFor);
    var content = templates.renderMethod(data);
    write(writer, method.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenMethodFileCount');
  }

  @override
  void generateMixin(PackageGraph packageGraph, Library lib, Mixin mixin) {
    var data = MixinTemplateData(options, packageGraph, lib, mixin,
        _sidebarForLibrary.getRenderFor, _sidebarForContainer.getRenderFor);
    var content = templates.renderMixin(data);
    write(writer, mixin.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenMixinFileCount');
  }

  @override
  void generatePackage(PackageGraph graph, Package package) {
    var data = PackageTemplateData(options, graph, package);
    var content = templates.renderIndex(data);
    write(writer, package.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenPackageFileCount');
  }

  @override
  void generateProperty(
      PackageGraph packageGraph, Library lib, Container clazz, Field property) {
    var data = PropertyTemplateData(options, packageGraph, lib, clazz, property,
        _sidebarForContainer.getRenderFor);
    var content = templates.renderProperty(data);
    write(writer, property.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenPropertyFileCount');
  }

  @override
  void generateTopLevelConstant(
          PackageGraph packageGraph, Library lib, TopLevelVariable property) =>
      generateTopLevelProperty(packageGraph, lib, property);

  @override
  void generateTopLevelProperty(
      PackageGraph packageGraph, Library lib, TopLevelVariable property) {
    var data = TopLevelPropertyTemplateData(
        options, packageGraph, lib, property, _sidebarForLibrary.getRenderFor);
    var content = templates.renderTopLevelProperty(data);
    write(writer, property.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenTopLevelPropertyFileCount');
  }

  @override
  void generateTypeDef(
      PackageGraph packageGraph, Library lib, Typedef typeDef) {
    var data = TypedefTemplateData(
        options, packageGraph, lib, typeDef, _sidebarForLibrary.getRenderFor);
    var content = templates.renderTypedef(data);
    write(writer, typeDef.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenTypedefFileCount');
  }

  @override
  Future<void> generateAdditionalFiles() async {}
}
