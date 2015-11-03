// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show Directory, File, stdout;
import 'dart:convert' show JSON;
import 'dart:typed_data' show Uint8List;

import 'package:path/path.dart' as path;

import '../generator.dart';
import '../markdown_processor.dart';
import '../resource_loader.dart' as loader;
import 'io_utils.dart' show createOutputFile;
import 'model.dart';
import 'package_meta.dart';
import 'resources.g.dart' as resources;
import 'templates.dart';

String dartdocVersion = 'unknown';

typedef String Renderer(String input);

// Generation order for libraries:
//   constants
//   typedefs
//   properties
//   functions
//   enums
//   classes
//   exceptions
//
// Generation order for classes:
//   constants
//   static properties
//   static methods
//   properties
//   constructors
//   operators
//   methods

class HtmlGenerator extends Generator {
  final StreamController<File> _onFileCreated =
      new StreamController(sync: true);

  /// Optional URL for where the docs will be hosted.
  final String url;
  final String relCanonicalPrefix;
  final Templates _templates;

  static Future<HtmlGenerator> create(String url,
      {String header, String footer, String relCanonicalPrefix}) async {
    var templates =
        await Templates.create(headerPath: header, footerPath: footer);

    return new HtmlGenerator._(url, relCanonicalPrefix, templates);
  }

  /// [url] can be null.
  // TODO: make url an optional parameter
  HtmlGenerator._(this.url, this.relCanonicalPrefix, this._templates);

  Future generate(Package package, Directory out) {
    return new _HtmlGeneratorInstance(
            url, _templates, package, out, _onFileCreated, relCanonicalPrefix)
        .generate();
  }

  Stream<File> get onFileCreated => _onFileCreated.stream;
}

abstract class HtmlOptions {
  String get relCanonicalPrefix;
}

class _HtmlGeneratorInstance implements HtmlOptions {
  final String url;
  final Templates _templates;
  final Package package;
  final Directory out;
  final List<ModelElement> documentedElements = [];
  final StreamController<File> _onFileCreated;
  final String relCanonicalPrefix;

  _HtmlGeneratorInstance(this.url, this._templates, this.package, this.out,
      this._onFileCreated, this.relCanonicalPrefix);

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
    File jsonFile = createOutputFile(out, 'index.json');
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
    Renderer markdown = renderMarkdown;

    if (package.hasDocumentationFile) {
      FileContents readme = package.documentationFile;
      markdown = readme.isMarkdown ? renderMarkdown : renderPlainText;
    }

    stdout.write('documenting ${package.name}');

    TemplateData data =
        new PackageTemplateData(this, package, markdown: markdown);

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
    File f = createOutputFile(out, filename);
    f.writeAsStringSync(content);
    _onFileCreated.add(f);
  }
}

class Subnav {
  final String name;
  final String href;

  Subnav(this.name, this.href);

  String toString() => name;
}

/// Converts a markdown formatted string into HTML, and removes any script tags.
/// Returns the HTML as a string.
String renderMarkdown(String markdown) => renderMarkdownToHtml(markdown);

/// Convert the given plain text into HTML.
String renderPlainText(String text) {
  if (text == null) return '';

  return "<code class='fixed'>${text.trim()}</code>";
}

abstract class TemplateData {
  final Package package;
  Function _markdown = renderMarkdown;
  final HtmlOptions htmlOptions;

  TemplateData(this.htmlOptions, this.package, {Renderer markdown})
      : _markdown = markdown;

  String get documentation => self.documentation;
  String get oneLineDoc => self.oneLineDoc;
  String get title;
  String get layoutTitle;
  String get metaDescription;
  List get navLinks;
  List<Subnav> get subnavItems;
  String get htmlBase;
  dynamic get self;
  String get version => dartdocVersion;
  Function get markdown => _markdown;
  String get relCanonicalPrefix => htmlOptions.relCanonicalPrefix;

  String _layoutTitle(String name, String kind, bool isDeprecated) {
    if (kind.isEmpty) kind =
        '&nbsp;'; // Ugly. fixes https://github.com/dart-lang/dartdoc/issues/695
    String str = '<span class="kind">$kind</span>';
    if (!isDeprecated) return '${str} ${name}';
    return '${str} <span class="deprecated">$name</span>';
  }

  List<Subnav> _gatherSubnavForInvokable(ModelElement element) {
    if (element is SourceCodeMixin &&
        (element as SourceCodeMixin).hasSourceCode) {
      return [new Subnav('Source', '${element.href}#source')];
    } else {
      return const [];
    }
  }
}

class PackageTemplateData extends TemplateData {
  PackageTemplateData(HtmlOptions htmlOptions, Package package,
      {Renderer markdown})
      : super(htmlOptions, package, markdown: markdown);

  List get navLinks => [];
  String get title => '${package.name} - Dart API docs';
  Package get self => package;
  String get layoutTitle =>
      _layoutTitle(package.name, package.isSdk ? '' : 'package', false);
  String get metaDescription =>
      '${package.name} API docs, for the Dart programming language.';
  List<Subnav> get subnavItems =>
      [new Subnav('Libraries', '${package.href}#libraries')];
  String get htmlBase => '.';
}

class LibraryTemplateData extends TemplateData {
  final Library library;

  LibraryTemplateData(HtmlOptions htmlOptions, Package package, this.library)
      : super(htmlOptions, package);

  String get title => '${library.name} library - Dart API';
  String get documentation => library.documentation;
  String get htmlBase => '..';
  String get metaDescription =>
      '${library.name} library API docs, for the Dart programming language.';
  List get navLinks => [package];
  List<Subnav> get subnavItems {
    List<Subnav> navs = [];

    if (library.hasConstants) navs
        .add(new Subnav('Constants', '${library.href}#constants'));
    if (library.hasTypedefs) navs
        .add(new Subnav('Typedefs', '${library.href}#typedefs'));
    if (library.hasProperties) navs
        .add(new Subnav('Properties', '${library.href}#properties'));
    if (library.hasFunctions) navs
        .add(new Subnav('Functions', '${library.href}#functions'));
    if (library.hasEnums) navs
        .add(new Subnav('Enums', '${library.href}#enums'));
    if (library.hasClasses) navs
        .add(new Subnav('Classes', '${library.href}#classes'));
    if (library.hasExceptions) navs
        .add(new Subnav('Exceptions', '${library.href}#exceptions'));

    return navs;
  }

  String get layoutTitle =>
      _layoutTitle(library.name, 'library', library.isDeprecated);
  Library get self => library;
}

class ClassTemplateData extends TemplateData {
  final Class clazz;
  final Library library;
  Class _objectType;

  ClassTemplateData(
      HtmlOptions htmlOptions, Package package, this.library, this.clazz)
      : super(htmlOptions, package);

  Class get self => clazz;
  String get linkedObjectType =>
      objectType == null ? 'Object' : objectType.linkedName;
  String get title =>
      '${clazz.name} ${clazz.kind} - ${library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${clazz.name} ${clazz.kind} from the '
      '${library.name} library, for the Dart programming language.';

  String get layoutTitle =>
      _layoutTitle(clazz.nameWithGenerics, clazz.fullkind, clazz.isDeprecated);
  List get navLinks => [package, library];
  String get htmlBase => '..';
  List<Subnav> get subnavItems {
    List<Subnav> navs = [];

    if (clazz.hasConstants) navs
        .add(new Subnav('Constants', '${clazz.href}#constants'));
    if (clazz.hasStaticProperties) navs.add(
        new Subnav('Static Properties', '${clazz.href}#static-properties'));
    if (clazz.hasStaticMethods) navs
        .add(new Subnav('Static Methods', '${clazz.href}#static-methods'));
    if (clazz.hasInstanceProperties) navs
        .add(new Subnav('Properties', '${clazz.href}#instance-properties'));
    if (clazz.hasConstructors) navs
        .add(new Subnav('Constructors', '${clazz.href}#constructors'));
    if (clazz.hasOperators) navs
        .add(new Subnav('Operators', '${clazz.href}#operators'));
    if (clazz.hasInstanceMethods) navs
        .add(new Subnav('Methods', '${clazz.href}#instance-methods'));

    return navs;
  }

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    Library dc = package.libraries
        .firstWhere((it) => it.name == "dart:core", orElse: () => null);

    if (dc == null) {
      return _objectType = null;
    }

    return _objectType = dc.getClassByName("Object");
  }
}

class ConstructorTemplateData extends TemplateData {
  final Library library;
  final Class clazz;
  final Constructor constructor;

  ConstructorTemplateData(HtmlOptions htmlOptions, Package package,
      this.library, this.clazz, this.constructor)
      : super(htmlOptions, package);

  Constructor get self => constructor;
  String get layoutTitle => _layoutTitle(
      constructor.name, constructor.fullKind, constructor.isDeprecated);
  List get navLinks => [package, library, clazz];
  List<Subnav> get subnavItems => _gatherSubnavForInvokable(constructor);
  String get htmlBase => '../..';
  String get title => '${constructor.name} constructor - ${clazz.name} class - '
      '${library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${constructor.name} constructor from the '
      '${clazz} class from the ${library.name} library, '
      'for the Dart programming language.';
}

class EnumTemplateData extends TemplateData {
  EnumTemplateData(
      HtmlOptions htmlOptions, Package package, this.library, this.clazz)
      : super(htmlOptions, package);

  final Library library;
  final Enum clazz;
  Enum get self => clazz;
  String get layoutTitle =>
      _layoutTitle(clazz.name, 'enum', clazz.isDeprecated);
  String get title => '${self.name} enum - ${library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${clazz.name} enum from the ${library.name} library, '
      'for the Dart programming language.';
  List get navLinks => [package, library];
  String get htmlBase => '..';
  List<Subnav> get subnavItems {
    return [
      new Subnav('Constants', '${clazz.href}#constants'),
      new Subnav('Properties', '${clazz.href}#properties')
    ];
  }
}

class FunctionTemplateData extends TemplateData {
  final ModelFunction function;
  final Library library;

  FunctionTemplateData(
      HtmlOptions htmlOptions, Package package, this.library, this.function)
      : super(htmlOptions, package);

  ModelFunction get self => function;
  String get title =>
      '${function.name} function - ${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(function.name, 'function', function.isDeprecated);
  String get metaDescription =>
      'API docs for the ${function.name} function from the '
      '${library.name} library, for the Dart programming language.';
  List get navLinks => [package, library];
  List<Subnav> get subnavItems => _gatherSubnavForInvokable(function);
  String get htmlBase => '..';
}

class MethodTemplateData extends TemplateData {
  final Library library;
  final Method method;
  final Class clazz;

  MethodTemplateData(HtmlOptions htmlOptions, Package package, this.library,
      this.clazz, this.method)
      : super(htmlOptions, package);

  Method get self => method;
  String get title => '${method.name} method - ${clazz.name} class - '
      '${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(method.name, 'method', method.isDeprecated);
  String get metaDescription =>
      'API docs for the ${method.name} method from the ${clazz.name} class, '
      'for the Dart programming language.';
  List get navLinks => [package, library, clazz];
  List<Subnav> get subnavItems => _gatherSubnavForInvokable(method);
  String get htmlBase => '../..';
}

class PropertyTemplateData extends TemplateData {
  final Library library;
  final Class clazz;
  final Field property;

  PropertyTemplateData(HtmlOptions htmlOptions, Package package, this.library,
      this.clazz, this.property)
      : super(htmlOptions, package);

  Field get self => property;

  String get title => '${property.name} $type - ${clazz.name} class - '
      '${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(property.name, type, property.isDeprecated);
  String get metaDescription =>
      'API docs for the ${property.name} $type from the ${clazz.name} class, '
      'for the Dart programming language.';
  List get navLinks => [package, library, clazz];
  List get subnavItems => [];
  String get htmlBase => '../..';

  String get type => 'property';
}

class ConstantTemplateData extends PropertyTemplateData {
  ConstantTemplateData(HtmlOptions htmlOptions, Package package,
      Library library, Class clazz, Field property)
      : super(htmlOptions, package, library, clazz, property);

  String get type => 'constant';
}

class TypedefTemplateData extends TemplateData {
  final Library library;
  final Typedef typeDef;

  TypedefTemplateData(
      HtmlOptions htmlOptions, Package package, this.library, this.typeDef)
      : super(htmlOptions, package);

  Typedef get self => typeDef;

  String get title =>
      '${typeDef.name} typedef - ${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(typeDef.name, 'typedef', typeDef.isDeprecated);
  String get metaDescription =>
      'API docs for the ${typeDef.name} property from the '
      '${library.name} library, for the Dart programming language.';
  List get navLinks => [package, library];
  String get htmlBase => '..';
  List get subnavItems => [];
}

class TopLevelPropertyTemplateData extends TemplateData {
  final Library library;
  final TopLevelVariable property;

  TopLevelPropertyTemplateData(
      HtmlOptions htmlOptions, Package package, this.library, this.property)
      : super(htmlOptions, package);

  TopLevelVariable get self => property;

  String get title =>
      '${property.name} $_type - ${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(property.name, _type, property.isDeprecated);
  String get metaDescription =>
      'API docs for the ${property.name} $_type from the '
      '${library.name} library, for the Dart programming language.';
  List get navLinks => [package, library];
  String get htmlBase => '..';
  List get subnavItems => [];

  String get _type => 'property';
}

class TopLevelConstTemplateData extends TopLevelPropertyTemplateData {
  TopLevelConstTemplateData(HtmlOptions htmlOptions, Package package,
      Library library, TopLevelVariable property)
      : super(htmlOptions, package, library, property);

  String get _type => 'constant';
}
