// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:convert' show JsonEncoder;
import 'dart:io' show File;

import 'package:collection/collection.dart' show compareNatural;
import 'package:dartdoc/src/model_utils.dart';
import 'package:path/path.dart' as path;

import '../logging.dart';
import '../model.dart';
import '../warnings.dart';
import 'html_generator.dart' show HtmlGeneratorOptions;
import 'resource_loader.dart' as loader;
import 'resources.g.dart' as resources;
import 'template_data.dart';
import 'templates.dart';

typedef void FileWriter(String path, Object content, {bool allowOverwrite});

class HtmlGeneratorInstance {
  final HtmlGeneratorOptions _options;
  final Templates _templates;
  final PackageGraph _packageGraph;
  final List<ModelElement> _documentedElements = <ModelElement>[];
  final FileWriter _writer;

  HtmlGeneratorInstance(
      this._options, this._templates, this._packageGraph, this._writer);

  Future generate() async {
    if (_packageGraph != null) {
      _generateDocs();
      _generateSearchIndex();
    }

    await _copyResources();
    if (_options.faviconPath != null) {
      var bytes = new File(_options.faviconPath).readAsBytesSync();
      // Allow overwrite of favicon.
      _writer(path.join('static-assets', 'favicon.png'), bytes,
          allowOverwrite: true);
    }
  }

  void _generateSearchIndex() {
    var encoder = _options.prettyIndexJson
        ? new JsonEncoder.withIndent(' ')
        : new JsonEncoder();

    final List<Map> indexItems =
        _documentedElements.where((e) => e.isCanonical).map((ModelElement e) {
      Map data = {
        'name': e.name,
        'qualifiedName': e.name,
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
    _writer(path.join('index.json'), '${json}\n');
  }

  void _generateDocs() {
    if (_packageGraph == null) return;

    generatePackage();

    for (var lib in filterNonDocumented(_packageGraph.libraries)) {
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

        for (var property in filterNonDocumented(clazz.propertiesForPages)) {
          if (!property.isCanonical) continue;
          generateProperty(_packageGraph, lib, clazz, property);
        }

        for (var method in filterNonDocumented(clazz.methodsForPages)) {
          if (!method.isCanonical) continue;
          generateMethod(_packageGraph, lib, clazz, method);
        }

        for (var operator in filterNonDocumented(clazz.operatorsForPages)) {
          if (!operator.isCanonical) continue;
          generateMethod(_packageGraph, lib, clazz, operator);
        }

        for (var method in filterNonDocumented(clazz.staticMethods)) {
          if (!method.isCanonical) continue;
          generateMethod(_packageGraph, lib, clazz, method);
        }
      }

      for (var eNum in filterNonDocumented(lib.enums)) {
        generateEnum(_packageGraph, lib, eNum);
        for (var property in filterNonDocumented(eNum.propertiesForPages)) {
          generateProperty(_packageGraph, lib, eNum, property);
        }
        for (var operator in filterNonDocumented(eNum.operatorsForPages)) {
          generateMethod(_packageGraph, lib, eNum, operator);
        }
        for (var method in filterNonDocumented(eNum.methodsForPages)) {
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

  void generatePackage() {
    TemplateData data = new PackageTemplateData(_options, _packageGraph);
    logInfo('documenting ${_packageGraph.name}');

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(PackageGraph packageGraph, Library lib) {
    logInfo(
        'Generating docs for library ${lib.name} from ${lib.element.source.uri}...');
    if (!lib.isAnonymous && !lib.hasDocumentation) {
      packageGraph.warnOnElement(lib, PackageWarning.noLibraryLevelDocs);
    }
    TemplateData data = new LibraryTemplateData(_options, packageGraph, lib);

    _build(path.join(lib.dirName, '${lib.fileName}'),
        _templates.libraryTemplate, data);
  }

  void generateClass(PackageGraph packageGraph, Library lib, Class clazz) {
    TemplateData data =
        new ClassTemplateData(_options, packageGraph, lib, clazz);
    _build(path.joinAll(clazz.href.split('/')), _templates.classTemplate, data);
  }

  void generateConstructor(PackageGraph packageGraph, Library lib, Class clazz,
      Constructor constructor) {
    TemplateData data = new ConstructorTemplateData(
        _options, packageGraph, lib, clazz, constructor);

    _build(path.joinAll(constructor.href.split('/')),
        _templates.constructorTemplate, data);
  }

  void generateEnum(PackageGraph packageGraph, Library lib, Enum eNum) {
    TemplateData data = new EnumTemplateData(_options, packageGraph, lib, eNum);

    _build(path.joinAll(eNum.href.split('/')), _templates.enumTemplate, data);
  }

  void generateFunction(
      PackageGraph packageGraph, Library lib, ModelFunction function) {
    TemplateData data =
        new FunctionTemplateData(_options, packageGraph, lib, function);

    _build(path.joinAll(function.href.split('/')), _templates.functionTemplate,
        data);
  }

  void generateMethod(
      PackageGraph packageGraph, Library lib, Class clazz, Method method) {
    TemplateData data =
        new MethodTemplateData(_options, packageGraph, lib, clazz, method);

    _build(
        path.joinAll(method.href.split('/')), _templates.methodTemplate, data);
  }

  void generateConstant(
      PackageGraph packageGraph, Library lib, Class clazz, Field property) {
    TemplateData data =
        new ConstantTemplateData(_options, packageGraph, lib, clazz, property);

    _build(path.joinAll(property.href.split('/')), _templates.constantTemplate,
        data);
  }

  void generateProperty(
      PackageGraph packageGraph, Library lib, Class clazz, Field property) {
    TemplateData data =
        new PropertyTemplateData(_options, packageGraph, lib, clazz, property);

    _build(path.joinAll(property.href.split('/')), _templates.propertyTemplate,
        data);
  }

  void generateTopLevelProperty(
      PackageGraph packageGraph, Library lib, TopLevelVariable property) {
    TemplateData data =
        new TopLevelPropertyTemplateData(_options, packageGraph, lib, property);

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
      PackageGraph packageGraph, Library lib, TopLevelVariable property) {
    TemplateData data =
        new TopLevelConstTemplateData(_options, packageGraph, lib, property);

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelConstantTemplate, data);
  }

  void generateTypeDef(
      PackageGraph packageGraph, Library lib, Typedef typeDef) {
    TemplateData data =
        new TypedefTemplateData(_options, packageGraph, lib, typeDef);

    _build(path.joinAll(typeDef.href.split('/')), _templates.typeDefTemplate,
        data);
  }

  // TODO: change this to use resource_loader
  Future _copyResources() async {
    final prefix = 'package:dartdoc/resources/';
    for (String resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(prefix)) {
        throw new StateError('Resource paths must start with $prefix, '
            'encountered $resourcePath');
      }
      String destFileName = resourcePath.substring(prefix.length);
      _writer(path.join('static-assets', destFileName),
          await loader.loadAsBytes(resourcePath));
    }
  }

  void _build(String filename, TemplateRenderer template, TemplateData data) {
    String content = template(data,
        assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

    _writer(filename, content);
    if (data.self is ModelElement) _documentedElements.add(data.self);
  }
}
