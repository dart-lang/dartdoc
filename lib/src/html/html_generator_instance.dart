// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Future, StreamController;
import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File;

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

  // Protect against bugs in canonicalization by tracking what files we
  // write.
  final Set<String> writtenFiles = new Set<String>();

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
      var bytes = new File(faviconPath).readAsBytesSync();
      // Allow overwrite of favicon.
      String filename = path.join(out.path, 'static-assets', 'favicon.png');
      writtenFiles.remove(filename);
      _writeFile(path.join(out.path, 'static-assets', 'favicon.png'), bytes);
    }
  }

  void _generateSearchIndex() {
    var encoder =
        prettyIndexJson ? new JsonEncoder.withIndent(' ') : new JsonEncoder();

    final List<Map> indexItems =
        documentedElements.where((e) => e.isCanonical).map((ModelElement e) {
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
    _writeFile(path.join(out.path, 'index.json'), '${json}\n');
  }

  void _generateDocs() {
    if (package == null) return;

    generatePackage();

    for (var lib in filterNonDocumented(package.libraries)) {
      // if (lib.name != 'extract_messages') continue;
      generateLibrary(package, lib);

      for (var clazz in filterNonDocumented(lib.allClasses)) {
        generateClass(package, lib, clazz);

        for (var constructor in filterNonDocumented(clazz.constructors)) {
          if (!constructor.isCanonical) continue;
          generateConstructor(package, lib, clazz, constructor);
        }

        for (var constant in filterNonDocumented(clazz.constants)) {
          if (!constant.isCanonical) continue;
          generateConstant(package, lib, clazz, constant);
        }

        for (var property in filterNonDocumented(clazz.staticProperties)) {
          if (!property.isCanonical) continue;
          generateProperty(package, lib, clazz, property);
        }

        for (var property in filterNonDocumented(clazz.propertiesForPages)) {
          if (!property.isCanonical) continue;
          generateProperty(package, lib, clazz, property);
        }

        for (var method in filterNonDocumented(clazz.methodsForPages)) {
          if (!method.isCanonical) continue;
          generateMethod(package, lib, clazz, method);
        }

        for (var operator in filterNonDocumented(clazz.operatorsForPages)) {
          if (!operator.isCanonical) continue;
          generateMethod(package, lib, clazz, operator);
        }

        for (var method in filterNonDocumented(clazz.staticMethods)) {
          if (!method.isCanonical) continue;
          generateMethod(package, lib, clazz, method);
        }
      }

      for (var eNum in filterNonDocumented(lib.enums)) {
        generateEnum(package, lib, eNum);
        for (var property in filterNonDocumented(eNum.propertiesForPages)) {
          generateProperty(package, lib, eNum, property);
        }
        for (var operator in filterNonDocumented(eNum.operatorsForPages)) {
          generateMethod(package, lib, eNum, operator);
        }
        for (var method in filterNonDocumented(eNum.methodsForPages)) {
          generateMethod(package, lib, eNum, method);
        }
      }

      for (var constant in filterNonDocumented(lib.constants)) {
        generateTopLevelConstant(package, lib, constant);
      }

      for (var property in filterNonDocumented(lib.properties)) {
        generateTopLevelProperty(package, lib, property);
      }

      for (var function in filterNonDocumented(lib.functions)) {
        generateFunction(package, lib, function);
      }

      for (var typeDef in filterNonDocumented(lib.typedefs)) {
        generateTypeDef(package, lib, typeDef);
      }
    }
  }

  void generatePackage() {
    TemplateData data = new PackageTemplateData(this, package, useCategories);
    logInfo('documenting ${package.name}');

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    logInfo(
        'Generating docs for library ${lib.name} from ${lib.element.source.uri}...');
    if (!lib.isAnonymous && !lib.hasDocumentation) {
      package.warnOnElement(lib, PackageWarning.noLibraryLevelDocs);
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

  void generateEnum(Package package, Library lib, Enum eNum) {
    TemplateData data = new EnumTemplateData(this, package, lib, eNum);

    _build(path.joinAll(eNum.href.split('/')), _templates.enumTemplate, data);
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
      _writeFile(path.join(out.path, 'static-assets', destFileName),
          await loader.loadAsBytes(resourcePath));
    }
  }

  void _build(String filename, TemplateRenderer template, TemplateData data) {
    String fullName = path.join(out.path, filename);

    String content = template(data,
        assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

    _writeFile(fullName, content);
    if (data.self is ModelElement) {
      documentedElements.add(data.self);
    }
  }

  /// [content] must be either [String] or [List<int>].
  void _writeFile(String filename, Object content) {
    // If you see this assert, we're probably being called to build non-canonical
    // docs somehow.  Check data.self.isCanonical and callers for bugs.
    assert(!writtenFiles.contains(filename));

    File file = new File(filename);
    Directory parent = file.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }

    if (content is String) {
      file.writeAsStringSync(content);
    } else if (content is List<int>) {
      file.writeAsBytesSync(content);
    } else {
      throw new ArgumentError.value(
          content, 'content', '`content` must be `String` or `List<int>`.');
    }
    _onFileCreated.add(file);
    writtenFiles.add(filename);
  }
}
