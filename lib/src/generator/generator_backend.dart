// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_utils.dart' as generator_util;
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/version.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p show Context;

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

  final List<String> packageOrder;

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
        resourcesDir = context.resourcesDir,
        packageOrder = context.packageOrder;
}

/// Outputs generated documentation.
abstract class GeneratorBackend {
  final DartdocGeneratorBackendOptions options;
  final Templates templates;

  final FileWriter writer;
  final ResourceProvider resourceProvider;
  final p.Context _pathContext;

  GeneratorBackend(
      this.options, this.templates, this.writer, this.resourceProvider)
      : _pathContext = resourceProvider.pathContext;

  /// Binds template data and emits the content to the [writer].
  void write(
    FileWriter writer,
    String filename,
    TemplateData data,
    String content, {
    bool isSidebar = false,
  }) {
    if (!options.useBaseHref) {
      content = content.replaceAll(
        htmlBasePlaceholder,
        // URLs in sidebars are tweaked in the front-end; other URLs use
        // `htmlBase`.
        isSidebar ? '' : data.htmlBase,
      );
    }
    var element = data.self;
    writer.write(filename, content,
        element: element is Warnable ? element : null);
  }

  /// Emits JSON describing the [categories] defined by the package.
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

  /// Emits a JSON catalog of [indexedElements] for use with a search index.
  void generateSearchIndex(List<Indexable> indexedElements) {
    var json = generator_util.generateSearchIndexJson(
      indexedElements,
      packageOrder: options.packageOrder,
      pretty: options.prettyIndexJson,
    );
    if (!options.useBaseHref) {
      json = json.replaceAll(htmlBasePlaceholder, '');
    }
    writer.write(_pathContext.join('index.json'), '$json\n');
  }

  /// Emits documentation content for the [category].
  void generateCategory(PackageGraph packageGraph, Category category) {
    var data = CategoryTemplateData(options, packageGraph, category);
    var content = templates.renderCategory(data);
    write(writer, category.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenCategoryFileCount');
  }

  /// Emits documentation content for the [clazz].
  void generateClass(PackageGraph packageGraph, Library library, Class clazz) {
    var data = ClassTemplateData(options, packageGraph, library, clazz);
    var content = templates.renderClass(data);
    write(writer, clazz.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenClassFileCount');
  }

  /// Emits documentation content for the [constructor].
  void generateConstructor(PackageGraph packageGraph, Library library,
      Constructable constructable, Constructor constructor) {
    var data = ConstructorTemplateData(
        options, packageGraph, library, constructable, constructor);
    var content = templates.renderConstructor(data);
    write(writer, constructor.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenConstructorFileCount');
  }

  /// Emits documentation content for the [eNum].
  void generateEnum(PackageGraph packageGraph, Library library, Enum eNum) {
    var data = EnumTemplateData(options, packageGraph, library, eNum);
    var content = templates.renderEnum(data);
    write(writer, eNum.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenEnumFileCount');
  }

  /// Emits documentation content for the [extension].
  void generateExtension(
      PackageGraph packageGraph, Library library, Extension extension) {
    var data = ExtensionTemplateData(options, packageGraph, library, extension);
    var content = templates.renderExtension(data);
    write(writer, extension.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenExtensionFileCount');
  }

  /// Emits documentation content for the [extensionType].
  void generateExtensionType(
      PackageGraph packageGraph, Library library, ExtensionType extensionType) {
    var data = ExtensionTypeTemplateData(
        options, packageGraph, library, extensionType);
    var content = templates.renderExtensionType(data);
    write(writer, extensionType.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenExtensionTypeFileCount');
  }

  /// Emits documentation content for the [function].
  void generateFunction(
      PackageGraph packageGraph, Library library, ModelFunction function) {
    var data = FunctionTemplateData(options, packageGraph, library, function);
    var content = templates.renderFunction(data);
    write(writer, function.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenFunctionFileCount');
  }

  /// Emits documentation content for the [library].
  void generateLibrary(PackageGraph packageGraph, Library library) {
    var data = LibraryTemplateData(options, packageGraph, library);
    var content = templates.renderLibrary(data);
    write(writer, library.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenLibraryFileCount');
  }

  /// Emits documentation content for the [method].
  void generateMethod(PackageGraph packageGraph, Library library,
      Container clazz, Method method) {
    var data =
        MethodTemplateData(options, packageGraph, library, clazz, method);
    var content = templates.renderMethod(data);
    write(writer, method.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenMethodFileCount');
  }

  /// Emits documentation content for the [mixin].
  void generateMixin(PackageGraph packageGraph, Library library, Mixin mixin) {
    var data = MixinTemplateData(options, packageGraph, library, mixin);
    var content = templates.renderMixin(data);
    write(writer, mixin.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenMixinFileCount');
  }

  /// Emits documentation content for the [package].
  void generatePackage(PackageGraph packageGraph, Package package) {
    var data = PackageTemplateData(options, packageGraph, package);
    var content = templates.renderIndex(data);
    write(writer, package.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenPackageFileCount');
  }

  /// Emits documentation content for the [field].
  void generateProperty(PackageGraph packageGraph, Library library,
      Container clazz, Field field) {
    var data =
        PropertyTemplateData(options, packageGraph, library, clazz, field);
    var content = templates.renderProperty(data);
    write(writer, field.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenPropertyFileCount');
  }

  /// Emits documentation content for the [property].
  void generateTopLevelProperty(
      PackageGraph packageGraph, Library library, TopLevelVariable property) {
    var data =
        TopLevelPropertyTemplateData(options, packageGraph, library, property);
    var content = templates.renderTopLevelProperty(data);
    write(writer, property.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenTopLevelPropertyFileCount');
  }

  /// Emits documentation content for the [typedef].
  void generateTypeDef(
      PackageGraph packageGraph, Library library, Typedef typedef) {
    var data = TypedefTemplateData(options, packageGraph, library, typedef);
    var content = templates.renderTypedef(data);
    write(writer, typedef.filePath, data, content);
    runtimeStats.incrementAccumulator('writtenTypedefFileCount');
  }

  /// Emits files not specific to a Dart language element (like a favicon, etc).
  Future<void> generateAdditionalFiles();
}
