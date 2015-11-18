// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show Directory, File, stdout;
import 'dart:convert' show JSON;
import 'dart:typed_data' show Uint8List;

import 'package:path/path.dart' as path;

import '../model.dart';
import 'resources.g.dart' as resources;
import 'resource_loader.dart' as loader;
import 'templates.dart';
import 'template_data.dart';

class HtmlGeneratorInstance implements HtmlOptions {
  final String url;
  final Templates _templates;
  final Package package;
  final Directory out;
  final List<ModelElement> documentedElements = <ModelElement>[];
  final StreamController<File> _onFileCreated;
  final String relCanonicalPrefix;
  final String toolVersion;

  HtmlGeneratorInstance(this.toolVersion, this.url, this._templates,
      this.package, this.out, this._onFileCreated, this.relCanonicalPrefix);

  Future generate() async {
    if (!out.existsSync()) out.createSync();

    if (package != null) {
      _generateDocs();
      _generateSearchIndex();
      // TODO: generate sitemap
    }

    await _copyResources();
  }

  void _generateSearchIndex() {
    File jsonFile = _createOutputFile(out, 'index.json');
    String json = JSON.encode(documentedElements.map((ModelElement e) {
      // TODO: find a better string for type
      Map data = {
        'name': e.name,
        'qualifiedName': e.name,
        'href': e.href,
        'type': e.kind
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
    }).toList());
    jsonFile.writeAsStringSync(json);
  }

  void _generateDocs() {
    if (package == null) return;

    generatePackage();

    for (var lib in package.libraries) {
      generateLibrary(package, lib);

      for (var clazz in lib.allClasses) {
        generateClass(package, lib, clazz);

        for (var constructor in clazz.constructors) {
          generateConstructor(package, lib, clazz, constructor);
        }

        for (var constant in clazz.constants) {
          generateConstant(package, lib, clazz, constant);
        }

        for (var property in clazz.staticProperties) {
          generateProperty(package, lib, clazz, property);
        }

        for (var property in clazz.propertiesForPages) {
          generateProperty(package, lib, clazz, property);
        }

        for (var method in clazz.methodsForPages) {
          generateMethod(package, lib, clazz, method);
        }

        for (var operator in clazz.operatorsForPages) {
          generateMethod(package, lib, clazz, operator);
        }

        for (var method in clazz.staticMethods) {
          generateMethod(package, lib, clazz, method);
        }
      }

      for (var eNum in lib.enums) {
        generateEnum(package, lib, eNum);
      }

      for (var constant in lib.constants) {
        generateTopLevelConstant(package, lib, constant);
      }

      for (var property in lib.properties) {
        generateTopLevelProperty(package, lib, property);
      }

      for (var function in lib.functions) {
        generateFunction(package, lib, function);
      }

      for (var typeDef in lib.typedefs) {
        generateTypeDef(package, lib, typeDef);
      }
    }
  }

  void generatePackage() {
    stdout.write('documenting ${package.name}');

    TemplateData data = new PackageTemplateData(this, package);

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    stdout
        .write('\ngenerating docs for library ${lib.name} from ${lib.path}...');

    if (!lib.isAnonymous && !lib.hasDocumentation) {
      stdout.write("\n  warning: '${lib.name}' has no library level "
          "documentation comments");
    }

    TemplateData data = new LibraryTemplateData(this, package, lib);

    _build(path.join(lib.dirName, '${lib.fileName}'),
        _templates.libraryTemplate, data);
  }

  void generateClass(Package package, Library lib, Class clazz) {
    TemplateData data = new ClassTemplateData(this, package, lib, clazz);

    _build(path.joinAll(clazz.href.split('/')), _templates.classTemplate, data);
  }

  void generateConstructor(
      Package package, Library lib, Class clazz, Constructor constructor) {
    TemplateData data =
        new ConstructorTemplateData(this, package, lib, clazz, constructor);

    _build(path.joinAll(constructor.href.split('/')),
        _templates.constructorTemplate, data);
  }

  void generateEnum(Package package, Library lib, Class eNum) {
    TemplateData data = new EnumTemplateData(this, package, lib, eNum);

    _build(path.joinAll(eNum.href.split('/')), _templates.classTemplate, data);
  }

  void generateFunction(Package package, Library lib, ModelFunction function) {
    TemplateData data = new FunctionTemplateData(this, package, lib, function);

    _build(path.joinAll(function.href.split('/')), _templates.functionTemplate,
        data);
  }

  void generateMethod(
      Package package, Library lib, Class clazz, Method method) {
    TemplateData data =
        new MethodTemplateData(this, package, lib, clazz, method);

    _build(
        path.joinAll(method.href.split('/')), _templates.methodTemplate, data);
  }

  void generateConstant(
      Package package, Library lib, Class clazz, Field property) {
    TemplateData data =
        new ConstantTemplateData(this, package, lib, clazz, property);

    _build(path.joinAll(property.href.split('/')), _templates.constantTemplate,
        data);
  }

  void generateProperty(
      Package package, Library lib, Class clazz, Field property) {
    TemplateData data =
        new PropertyTemplateData(this, package, lib, clazz, property);

    _build(path.joinAll(property.href.split('/')), _templates.propertyTemplate,
        data);
  }

  void generateTopLevelProperty(
      Package package, Library lib, TopLevelVariable property) {
    TemplateData data =
        new TopLevelPropertyTemplateData(this, package, lib, property);

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
      Package package, Library lib, TopLevelVariable property) {
    TemplateData data =
        new TopLevelConstTemplateData(this, package, lib, property);

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelConstantTemplate, data);
  }

  void generateTypeDef(Package package, Library lib, Typedef typeDef) {
    TemplateData data = new TypedefTemplateData(this, package, lib, typeDef);

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
      File destFile =
          new File(path.join(out.path, 'static-assets', destFileName))
            ..createSync(recursive: true);
      Uint8List resourceBytes = await loader.loadAsBytes(resourcePath);
      destFile.writeAsBytesSync(resourceBytes);
    }
  }

  void _build(String filename, TemplateRenderer template, TemplateData data) {
    String content = template(data,
        assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

    _writeFile(filename, content);
    if (data.self is ModelElement) documentedElements.add(data.self);
  }

  void _writeFile(String filename, String content) {
    File f = _createOutputFile(out, filename);
    f.writeAsStringSync(content);
    _onFileCreated.add(f);
  }
}

File _createOutputFile(Directory destination, String filename) {
  File f = new File(path.join(destination.path, filename));
  if (!f.existsSync()) f.createSync(recursive: true);
  return f;
}
