// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:convert' show JsonEncoder;
import 'dart:io' show File;

import 'package:collection/collection.dart' show compareNatural;
import 'package:dartdoc/src/html/html_generator.dart' show HtmlGeneratorOptions;
import 'package:dartdoc/src/html/template_render_helper.dart';
import 'package:dartdoc/src/html/resource_loader.dart' as loader;
import 'package:dartdoc/src/html/resources.g.dart' as resources;
import 'package:dartdoc/src/html/template_data.dart';
import 'package:dartdoc/src/html/templates.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

typedef FileWriter = void Function(String path, Object content,
    {bool allowOverwrite, Warnable element});

class HtmlGeneratorInstance {
  final HtmlGeneratorOptions _options;
  final Templates _templates;
  final PackageGraph _packageGraph;
  final List<Indexable> _indexedElements = <Indexable>[];
  final FileWriter _writer;
  final HtmlRenderHelper _templateHelper = HtmlRenderHelper();

  HtmlGeneratorInstance(
      this._options, this._templates, this._packageGraph, this._writer);

  Future generate() async {
    if (_packageGraph != null) {
      _generateDocs();
      _generateSearchIndex();
      _generateCategoryJson();
    }

    await _copyResources();
    if (_options.faviconPath != null) {
      var bytes = File(_options.faviconPath).readAsBytesSync();
      // Allow overwrite of favicon.
      _writer(path.join('static-assets', 'favicon.png'), bytes,
          allowOverwrite: true);
    }
  }

  void _generateCategoryJson() {
    var encoder = JsonEncoder.withIndent('  ');
    final List<Map> indexItems = _categorizationItems.map((Categorization e) {
      Map data = {
        'name': e.name,
        'qualifiedName': e.fullyQualifiedName,
        'href': e.href,
        'type': e.kind,
      };

      if (e.hasCategoryNames) data['categories'] = e.categoryNames;
      if (e.hasSubCategoryNames) data['subcategories'] = e.subCategoryNames;
      if (e.hasImage) data['image'] = e.image;
      if (e.hasSamples) data['samples'] = e.samples;
      return data;
    }).toList();

    indexItems.sort((a, b) {
      var value = compareNatural(a['qualifiedName'], b['qualifiedName']);
      if (value == 0) {
        value = compareNatural(a['type'], b['type']);
      }
      return value;
    });

    String json = encoder.convert(indexItems);
    json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    _writer(path.join('categories.json'), '${json}\n');
  }

  List<Categorization> _categorizationItems;

  void _generateSearchIndex() {
    var encoder =
        _options.prettyIndexJson ? JsonEncoder.withIndent(' ') : JsonEncoder();
    _categorizationItems = [];

    final List<Map> indexItems = _indexedElements.map((Indexable e) {
      if (e is Categorization && e.hasCategorization) {
        _categorizationItems.add(e);
      }
      Map data = {
        'name': e.name,
        'qualifiedName': e.fullyQualifiedName,
        'href': e.href,
        'type': e.kind,
        'overriddenDepth': e.overriddenDepth,
      };
      if (e is EnclosedElement) {
        EnclosedElement ee = e as EnclosedElement;
        data['enclosedBy'] = {
          'name': ee.enclosingElement.name,
          'type': ee.enclosingElement.kind
        };

        data['qualifiedName'] = e.fullyQualifiedName;
      }
      return data;
    }).toList();

    indexItems.sort((a, b) {
      var value = compareNatural(a['qualifiedName'], b['qualifiedName']);
      if (value == 0) {
        value = compareNatural(a['type'], b['type']);
      }
      return value;
    });

    String json = encoder.convert(indexItems);
    json = json.replaceAll(HTMLBASE_PLACEHOLDER, '');
    _writer(path.join('index.json'), '${json}\n');
  }

  void _generateDocs() {
    if (_packageGraph == null) return;

    generatePackage(_packageGraph, _packageGraph.defaultPackage);

    for (var package in _packageGraph.localPackages) {
      for (var category in filterNonDocumented(package.categories)) {
        generateCategory(_packageGraph, category);
      }

      for (var lib in filterNonDocumented(package.libraries)) {
        generateLibrary(_packageGraph, lib);

        for (var clazz in filterNonDocumented(lib.allClasses)) {
          generateClass(_packageGraph, lib, clazz);

          for (var constructor in filterNonDocumented(clazz.constructors)) {
            if (!constructor.isCanonical) continue;
            generateConstructor(_packageGraph, lib, clazz, constructor);
          }

          for (var constant in filterNonDocumented(clazz.constants)) {
            if (!constant.isCanonical) continue;
            generateConstant(_packageGraph, lib, clazz, constant);
          }

          for (var property in filterNonDocumented(clazz.staticProperties)) {
            if (!property.isCanonical) continue;
            generateProperty(_packageGraph, lib, clazz, property);
          }

          for (var property in filterNonDocumented(clazz.allInstanceFields)) {
            if (!property.isCanonical) continue;
            generateProperty(_packageGraph, lib, clazz, property);
          }

          for (var method in filterNonDocumented(clazz.allInstanceMethods)) {
            if (!method.isCanonical) continue;
            generateMethod(_packageGraph, lib, clazz, method);
          }

          for (var operator in filterNonDocumented(clazz.allOperators)) {
            if (!operator.isCanonical) continue;
            generateMethod(_packageGraph, lib, clazz, operator);
          }

          for (var method in filterNonDocumented(clazz.staticMethods)) {
            if (!method.isCanonical) continue;
            generateMethod(_packageGraph, lib, clazz, method);
          }
        }

        for (var extension in filterNonDocumented(lib.extensions)) {
          generateExtension(_packageGraph, lib, extension);

          for (var constant in filterNonDocumented(extension.constants)) {
            generateConstant(_packageGraph, lib, extension, constant);
          }

          for (var property
              in filterNonDocumented(extension.staticProperties)) {
            generateProperty(_packageGraph, lib, extension, property);
          }

          for (var method
              in filterNonDocumented(extension.allPublicInstanceMethods)) {
            generateMethod(_packageGraph, lib, extension, method);
          }

          for (var method in filterNonDocumented(extension.staticMethods)) {
            generateMethod(_packageGraph, lib, extension, method);
          }

          for (var operator in filterNonDocumented(extension.allOperators)) {
            generateMethod(_packageGraph, lib, extension, operator);
          }

          for (var property
              in filterNonDocumented(extension.allInstanceFields)) {
            generateProperty(_packageGraph, lib, extension, property);
          }
        }

        for (var mixin in filterNonDocumented(lib.mixins)) {
          generateMixins(_packageGraph, lib, mixin);
          for (var constructor in filterNonDocumented(mixin.constructors)) {
            if (!constructor.isCanonical) continue;
            generateConstructor(_packageGraph, lib, mixin, constructor);
          }

          for (var constant in filterNonDocumented(mixin.constants)) {
            if (!constant.isCanonical) continue;
            generateConstant(_packageGraph, lib, mixin, constant);
          }

          for (var property in filterNonDocumented(mixin.staticProperties)) {
            if (!property.isCanonical) continue;
            generateProperty(_packageGraph, lib, mixin, property);
          }

          for (var property in filterNonDocumented(mixin.allInstanceFields)) {
            if (!property.isCanonical) continue;
            generateProperty(_packageGraph, lib, mixin, property);
          }

          for (var method in filterNonDocumented(mixin.allInstanceMethods)) {
            if (!method.isCanonical) continue;
            generateMethod(_packageGraph, lib, mixin, method);
          }

          for (var operator in filterNonDocumented(mixin.allOperators)) {
            if (!operator.isCanonical) continue;
            generateMethod(_packageGraph, lib, mixin, operator);
          }

          for (var method in filterNonDocumented(mixin.staticMethods)) {
            if (!method.isCanonical) continue;
            generateMethod(_packageGraph, lib, mixin, method);
          }
        }

        for (var eNum in filterNonDocumented(lib.enums)) {
          generateEnum(_packageGraph, lib, eNum);
          for (var property in filterNonDocumented(eNum.allInstanceFields)) {
            generateProperty(_packageGraph, lib, eNum, property);
          }
          for (var operator in filterNonDocumented(eNum.allOperators)) {
            generateMethod(_packageGraph, lib, eNum, operator);
          }
          for (var method in filterNonDocumented(eNum.allInstanceMethods)) {
            generateMethod(_packageGraph, lib, eNum, method);
          }
        }

        for (var constant in filterNonDocumented(lib.constants)) {
          generateTopLevelConstant(_packageGraph, lib, constant);
        }

        for (var property in filterNonDocumented(lib.properties)) {
          generateTopLevelProperty(_packageGraph, lib, property);
        }

        for (var function in filterNonDocumented(lib.functions)) {
          generateFunction(_packageGraph, lib, function);
        }

        for (var typeDef in filterNonDocumented(lib.typedefs)) {
          generateTypeDef(_packageGraph, lib, typeDef);
        }
      }
    }
  }

  void generatePackage(PackageGraph packageGraph, Package package) {
    TemplateData data =
        PackageTemplateData(_options, packageGraph, _templateHelper, package);
    logInfo('documenting ${package.name}');

    _build(package.filePath, _templates.indexTemplate, data);
    _build('__404error.html', _templates.errorTemplate, data);
  }

  void generateCategory(PackageGraph packageGraph, Category category) {
    logInfo(
        'Generating docs for category ${category.name} from ${category.package.fullyQualifiedName}...');
    TemplateData data =
        CategoryTemplateData(_options, packageGraph, _templateHelper, category);

    _build(category.filePath, _templates.categoryTemplate, data);
  }

  void generateLibrary(PackageGraph packageGraph, Library lib) {
    logInfo(
        'Generating docs for library ${lib.name} from ${lib.element.source.uri}...');
    if (!lib.isAnonymous && !lib.hasDocumentation) {
      packageGraph.warnOnElement(lib, PackageWarning.noLibraryLevelDocs);
    }
    TemplateData data =
        LibraryTemplateData(_options, packageGraph, _templateHelper, lib);

    _build(lib.filePath, _templates.libraryTemplate, data);
  }

  void generateClass(PackageGraph packageGraph, Library lib, Class clazz) {
    TemplateData data =
        ClassTemplateData(_options, packageGraph, _templateHelper, lib, clazz);
    _build(clazz.filePath, _templates.classTemplate, data);
  }

  void generateExtension(
      PackageGraph packageGraph, Library lib, Extension extension) {
    TemplateData data = ExtensionTemplateData(
        _options, packageGraph, _templateHelper, lib, extension);
    _build(extension.filePath, _templates.extensionTemplate, data);
  }

  void generateMixins(PackageGraph packageGraph, Library lib, Mixin mixin) {
    TemplateData data =
        MixinTemplateData(_options, packageGraph, _templateHelper, lib, mixin);
    _build(mixin.filePath, _templates.mixinTemplate, data);
  }

  void generateConstructor(PackageGraph packageGraph, Library lib, Class clazz,
      Constructor constructor) {
    TemplateData data = ConstructorTemplateData(
        _options, packageGraph, _templateHelper, lib, clazz, constructor);

    _build(constructor.filePath, _templates.constructorTemplate, data);
  }

  void generateEnum(PackageGraph packageGraph, Library lib, Enum eNum) {
    TemplateData data =
        EnumTemplateData(_options, packageGraph, _templateHelper, lib, eNum);

    _build(eNum.filePath, _templates.enumTemplate, data);
  }

  void generateFunction(
      PackageGraph packageGraph, Library lib, ModelFunction function) {
    TemplateData data = FunctionTemplateData(
        _options, packageGraph, _templateHelper, lib, function);

    _build(function.filePath, _templates.functionTemplate, data);
  }

  void generateMethod(
      PackageGraph packageGraph, Library lib, Container clazz, Method method) {
    TemplateData data = MethodTemplateData(
        _options, packageGraph, _templateHelper, lib, clazz, method);

    _build(method.filePath, _templates.methodTemplate, data);
  }

  void generateConstant(
      PackageGraph packageGraph, Library lib, Container clazz, Field property) {
    TemplateData data = ConstantTemplateData(
        _options, packageGraph, _templateHelper, lib, clazz, property);

    _build(property.filePath, _templates.constantTemplate, data);
  }

  void generateProperty(
      PackageGraph packageGraph, Library lib, Container clazz, Field property) {
    TemplateData data = PropertyTemplateData(
        _options, packageGraph, _templateHelper, lib, clazz, property);

    _build(property.filePath, _templates.propertyTemplate, data);
  }

  void generateTopLevelProperty(
      PackageGraph packageGraph, Library lib, TopLevelVariable property) {
    TemplateData data = TopLevelPropertyTemplateData(
        _options, packageGraph, _templateHelper, lib, property);

    _build(property.filePath, _templates.topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
      PackageGraph packageGraph, Library lib, TopLevelVariable property) {
    TemplateData data = TopLevelConstTemplateData(
        _options, packageGraph, _templateHelper, lib, property);

    _build(property.filePath, _templates.topLevelConstantTemplate, data);
  }

  void generateTypeDef(
      PackageGraph packageGraph, Library lib, Typedef typeDef) {
    TemplateData data = TypedefTemplateData(
        _options, packageGraph, _templateHelper, lib, typeDef);

    _build(typeDef.filePath, _templates.typeDefTemplate, data);
  }

  // TODO: change this to use resource_loader
  Future _copyResources() async {
    final prefix = 'package:dartdoc/resources/';
    for (String resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(prefix)) {
        throw StateError('Resource paths must start with $prefix, '
            'encountered $resourcePath');
      }
      String destFileName = resourcePath.substring(prefix.length);
      _writer(path.join('static-assets', destFileName),
          await loader.loadAsBytes(resourcePath));
    }
  }

  void _build(String filename, Template template, TemplateData data) {
    // Replaces '/' separators with proper separators for the platform.
    String outFile = path.joinAll(filename.split('/'));
    String content = template.renderString(data);

    content = content.replaceAll(HTMLBASE_PLACEHOLDER, data.htmlBase);
    _writer(outFile, content,
        element: data.self is Warnable ? data.self : null);
    if (data.self is Indexable) _indexedElements.add(data.self as Indexable);
  }
}
