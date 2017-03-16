// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future, StreamController;
import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File, stdout;
import 'dart:typed_data' show Uint8List;

import 'package:collection/collection.dart' show compareNatural;
import 'package:path/path.dart' as path;

import '../model.dart';
import 'html_generator.dart' show HtmlGeneratorOptions;
import 'resource_loader.dart' as loader;
import 'resources.g.dart' as resources;
import 'template_data.dart';
import 'templates.dart';

class HtmlGeneratorInstance implements HtmlOptions {
  final HtmlGeneratorOptions _options;

  String get url => _options.url;
  final Templates _templates;
  final Package package;
  final Directory out;
  final List<ModelElement> documentedElements = <ModelElement>[];
  final StreamController<File> _onFileCreated;
  @override
  String get relCanonicalPrefix => _options.relCanonicalPrefix;
  @override
  String get toolVersion => _options.toolVersion;
  String get faviconPath => _options.faviconPath;
  bool get useCategories => _options.useCategories;
  bool get prettyIndexJson => _options.prettyIndexJson;
  // Protect against generating the same data over and over for a package.
  final Set<String> _writtenFiles = new Set();

  HtmlGeneratorInstance(this._options, this._templates, this.package, this.out,
      this._onFileCreated);

  Future generate() async {
    if (!out.existsSync()) out.createSync();

    if (package != null) {
      _generateDocs();
      _generateSearchIndex();
    }

    await _copyResources();
    if (faviconPath != null) {
      File file = new File(path.join(out.path, 'static-assets', 'favicon.png'));
      file.writeAsBytesSync(new File(faviconPath).readAsBytesSync());
    }
  }

  void _generateSearchIndex() {
    var encoder =
        prettyIndexJson ? new JsonEncoder.withIndent(' ') : new JsonEncoder();

    File jsonFile = _createOutputFile(path.join(out.path, 'index.json'));
    String json = encoder.convert(documentedElements.where((e) => e.isCanonical).map((ModelElement e) {
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
    }).toList()
          ..sort((a, b) {
            var aQualified = a['qualifiedName'] as String;
            var bQualified = b['qualifiedName'] as String;
            return compareNatural(aQualified, bQualified);
          }));
    jsonFile.writeAsStringSync('${json}\n');
  }

  void _generateDocs() {
    if (package == null) return;

    generatePackage();

    for (var lib in package.libraries) {
      generateLibrary(package, lib);

      for (var clazz in lib.allClasses) {
        // TODO(jcollins-g): consider refactor so that only the canonical
        // ModelElements show up in these lists
        if (!clazz.isCanonical) continue;
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
        if (!eNum.isCanonical) continue;
        generateEnum(package, lib, eNum);
      }

      for (var constant in lib.constants) {
        if (!constant.isCanonical) continue;
        generateTopLevelConstant(package, lib, constant);
      }

      for (var property in lib.properties) {
        if (!property.isCanonical) continue;
        generateTopLevelProperty(package, lib, property);
      }

      for (var function in lib.functions) {
        if (!function.isCanonical) continue;
        generateFunction(package, lib, function);
      }

      for (var typeDef in lib.typedefs) {
        if (!typeDef.isCanonical) continue;
        generateTypeDef(package, lib, typeDef);
      }
    }
  }

  void generatePackage() {
    stdout.write('documenting ${package.name}');

    TemplateData data = new PackageTemplateData(this, package, useCategories);

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    stdout
        .write('\ngenerating docs for library ${lib.name} from ${lib.path}...');

    if (!lib.isAnonymous && !lib.hasDocumentation) {
      stdout.write("\n  warning: '${lib.name}' has no library level "
          "documentation comments");
    }

    TemplateData data =
        new LibraryTemplateData(this, package, lib, useCategories);

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
    String fullName = path.join(out.path, filename);
    // If you see this assert, we're probably being called to build non-canonical
    // docs somehow.  Check data.self.isCanonical to find out.
    assert(!_writtenFiles.contains(fullName));
    if (!_writtenFiles.contains(fullName)) {
      String content = template(data,
          assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

      _writeFile(fullName, content);
      _writtenFiles.add(fullName);
      if (data.self is ModelElement) documentedElements.add(data.self);
    }
  }

  void _writeFile(String filename, String content) {
    File file = _createOutputFile(filename);
    file.writeAsStringSync(content);
    _onFileCreated.add(file);
  }
}

File _createOutputFile(String filename) {
  File file = new File(filename);
  Directory parent = file.parent;
  if (!parent.existsSync()) parent.createSync(recursive: true);
  return file;
}
