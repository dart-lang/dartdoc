// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future;
import 'dart:io' show Directory, File, stdout;
import 'dart:convert' show JSON;
import 'dart:typed_data' show Uint8List;

import 'package:mustache4dart/mustache4dart.dart';
import 'package:path/path.dart' as path;

import 'model.dart';
import 'package_meta.dart';
import 'resources.g.dart' as resources;
import '../generator.dart';
import '../markdown_processor.dart';
import '../resource_loader.dart' as loader;
import 'io_utils.dart' show createOutputFile;

String dartdocVersion = 'unknown';

typedef String Renderer(String input);

typedef String TemplateRenderer(context,
    {bool assumeNullNonExistingProperty, bool errorOnMissingProperty});

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

class Templates {
  TemplateRenderer indexTemplate;
  TemplateRenderer libraryTemplate;
  TemplateRenderer classTemplate;
  TemplateRenderer functionTemplate;
  TemplateRenderer methodTemplate;
  TemplateRenderer constructorTemplate;
  TemplateRenderer propertyTemplate;
  TemplateRenderer constantTemplate;
  TemplateRenderer topLevelConstantTemplate;
  TemplateRenderer topLevelPropertyTemplate;
  TemplateRenderer typeDefTemplate;

  final Map<String, String> _partialTemplates = <String, String>{};

  final String _footer;
  final String _header;

  Templates(this._header, this._footer);

  Future init() async {
    if (_partialTemplates.isNotEmpty) return;

    indexTemplate = await _loadTemplate('index.html');
    libraryTemplate = await _loadTemplate('library.html');
    classTemplate = await _loadTemplate('class.html');
    functionTemplate = await _loadTemplate('function.html');
    methodTemplate = await _loadTemplate('method.html');
    constructorTemplate = await _loadTemplate('constructor.html');
    propertyTemplate = await _loadTemplate('property.html');
    constantTemplate = await _loadTemplate('constant.html');
    topLevelConstantTemplate = await _loadTemplate('top_level_constant.html');
    topLevelPropertyTemplate = await _loadTemplate('top_level_property.html');
    typeDefTemplate = await _loadTemplate('typedef.html');

    // TODO: if we can ever enumerate the contents of a package, we
    // won't need this.
    List<String> partials = [
      'callable',
      'callable_multiline',
      'constant',
      'footer',
      'head',
      'property',
      'styles_and_scripts',
      'readable_writable',
      'documentation',
      'name_summary',
      'sidebar_for_class',
      'source_code',
      'sidebar_for_library',
      'has_more_docs',
      'accessor_getter',
      'accessor_setter'
    ];

    for (String partial in partials) {
      _partialTemplates[partial] = await _loadPartial('_$partial.html');
    }
  }

  String _partial(String name) {
    String partial = _partialTemplates[name];
    if (partial == null || partial.isEmpty) {
      throw new StateError('Did not find partial "$name"');
    }
    return partial;
  }

  Future<TemplateRenderer> _loadTemplate(String templatePath) async {
    String templateContents = await _getTemplateFile(templatePath);
    return compile(templateContents, partial: _partial) as TemplateRenderer;
  }

  Future<String> _getTemplateFile(String templatePath) {
    return loader.loadAsString('package:dartdoc/templates/$templatePath');
  }

  Future<String> _loadPartial(String templatePath) async {
    String template = await _getTemplateFile(templatePath);
    // TODO: revisit, not sure this is the right place for this logic
    if (templatePath.contains('_footer') && _footer != null) {
      String footerValue = await new File(_footer).readAsString();
      template =
          template.replaceAll('<!-- Footer Placeholder -->', footerValue);
    }
    if (templatePath.contains('_head') && _header != null) {
      String headerValue = await new File(_header).readAsString();
      template =
          template.replaceAll('<!-- Header Placeholder -->', headerValue);
    }
    return template;
  }
}

class HtmlGenerator extends Generator {
  /// Optional URL for where the docs will be hosted.
  final String url;
  final Templates _templates;

  /// [url] can be null.
  // TODO: make url an optional parameter
  HtmlGenerator(this.url, {String header, String footer})
      : _templates = new Templates(header, footer) {}

  Future generate(Package package, Directory out,
      {ProgressCallback onProgress}) {
    return new HtmlGeneratorInstance(url, _templates, package, out,
        onProgress: onProgress).generate();
  }
}

class HtmlGeneratorInstance {
  final String url;
  final Templates _templates;

  final Package package;
  final Directory out;

  final ProgressCallback onProgress;

  final List<ModelElement> documentedElements = [];

  HtmlGeneratorInstance(this.url, this._templates, this.package, this.out,
      {this.onProgress});

  Future generate() async {
    await _templates.init();
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
      Map data = {'name': e.name, 'href': e.href, 'type': e.kind};
      if (e is EnclosedElement) {
        EnclosedElement ee = e as EnclosedElement;
        data['enclosedBy'] = {
          'name': ee.enclosingElement.name,
          'type': ee.enclosingElement.kind
        };
      }
      return data;
    }).toList());
    jsonFile.writeAsStringSync(json);
  }

  void _generateDocs() {
    if (package == null) return;

    generatePackage();

    package.libraries.forEach((Library lib) {
      generateLibrary(package, lib);

      lib.allClasses.forEach((Class clazz) {
        generateClass(package, lib, clazz);

        clazz.constructors.forEach((constructor) {
          generateConstructor(package, lib, clazz, constructor);
        });

        clazz.constants.forEach((constant) {
          generateConstant(package, lib, clazz, constant);
        });

        clazz.staticProperties.forEach((property) {
          generateProperty(package, lib, clazz, property);
        });

        clazz.propertiesForPages.forEach((property) {
          generateProperty(package, lib, clazz, property);
        });

        clazz.methodsForPages.forEach((method) {
          generateMethod(package, lib, clazz, method);
        });

        clazz.operatorsForPages.forEach((operator) {
          generateMethod(package, lib, clazz, operator);
        });

        clazz.staticMethods.forEach((method) {
          generateMethod(package, lib, clazz, method);
        });
      });

      lib.enums.forEach((eNum) {
        generateEnum(package, lib, eNum);
      });

      lib.constants.forEach((constant) {
        generateTopLevelConstant(package, lib, constant);
      });

      lib.properties.forEach((property) {
        generateTopLevelProperty(package, lib, property);
      });

      lib.functions.forEach((function) {
        generateFunction(package, lib, function);
      });

      lib.typedefs.forEach((typeDef) {
        generateTypeDef(package, lib, typeDef);
      });
    });
  }

  void generatePackage() {
    Renderer markdown = renderMarkdown;

    if (package.hasDocumentationFile) {
      FileContents readme = package.documentationFile;
      markdown = readme.isMarkdown ? renderMarkdown : renderPlainText;
    }

    stdout.write('documenting ${package.name}');

    TemplateData data = new PackageTemplateData(package, markdown: markdown);

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    stdout
        .write('\ngenerating docs for library ${lib.name} from ${lib.path}...');

    if (!lib.isAnonymous && !lib.hasDocumentation) {
      print("\n  warning: library '${lib.name}' has no documentation");
    }

    TemplateData data = new LibraryTemplateData(package, lib);

    _build(path.join(lib.dirName, '${lib.fileName}'),
        _templates.libraryTemplate, data);
  }

  void generateClass(Package package, Library lib, Class clazz) {
    TemplateData data = new ClassTemplateData(package, lib, clazz);

    _build(path.joinAll(clazz.href.split('/')), _templates.classTemplate, data);
  }

  void generateConstructor(
      Package package, Library lib, Class clazz, Constructor constructor) {
    TemplateData data =
        new ConstructorTemplateData(package, lib, clazz, constructor);

    _build(path.joinAll(constructor.href.split('/')),
        _templates.constructorTemplate, data);
  }

  void generateEnum(Package package, Library lib, Class eNum) {
    TemplateData data = new EnumTemplateData(package, lib, eNum);

    _build(path.joinAll(eNum.href.split('/')), _templates.classTemplate, data);
  }

  void generateFunction(Package package, Library lib, ModelFunction function) {
    TemplateData data = new FunctionTemplateData(package, lib, function);

    _build(path.joinAll(function.href.split('/')), _templates.functionTemplate,
        data);
  }

  void generateMethod(
      Package package, Library lib, Class clazz, Method method) {
    TemplateData data = new MethodTemplateData(package, lib, clazz, method);

    _build(
        path.joinAll(method.href.split('/')), _templates.methodTemplate, data);
  }

  void generateConstant(
      Package package, Library lib, Class clazz, Field property) {
    TemplateData data = new ConstantTemplateData(package, lib, clazz, property);

    _build(path.joinAll(property.href.split('/')), _templates.constantTemplate,
        data);
  }

  void generateProperty(
      Package package, Library lib, Class clazz, Field property) {
    TemplateData data = new PropertyTemplateData(package, lib, clazz, property);

    _build(path.joinAll(property.href.split('/')), _templates.propertyTemplate,
        data);
  }

  void generateTopLevelProperty(
      Package package, Library lib, TopLevelVariable property) {
    TemplateData data =
        new TopLevelPropertyTemplateData(package, lib, property);

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
      Package package, Library lib, TopLevelVariable property) {
    TemplateData data = new TopLevelConstTemplateData(package, lib, property);

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelConstantTemplate, data);
  }

  void generateTypeDef(Package package, Library lib, Typedef typeDef) {
    TemplateData data = new TypedefTemplateData(package, lib, typeDef);

    _build(path.joinAll(typeDef.href.split('/')), _templates.typeDefTemplate,
        data);
  }

  // TODO: change this to use resource_loader
  Future _copyResources() async {
    final prefix = 'package:dartdoc/resources/';
    for (String resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(prefix)) {
        throw new StateError(
            'Resource paths must start with $prefix, encountered $resourcePath');
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
    if (onProgress != null) onProgress(f);
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
  Package _package;
  Function _markdown = renderMarkdown;

  TemplateData(this._package, {Renderer markdown}) : _markdown = markdown;

  Package get package => _package;
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

  String _layoutTitle(String name, String kind, bool isDeprecated) {
    if (kind.isEmpty) kind =
        '&nbsp;'; // Ugly. fixes https://github.com/dart-lang/dartdoc/issues/695
    String str = '<div class="kind">$kind</div>';
    if (!isDeprecated) return '${str} ${name}';
    return '${str} <span class="deprecated">$name</span>';
  }

  List<Subnav> _gatherSubnavForInvokable(ModelElement element) {
    if (element is SourceCodeMixin &&
        (element as SourceCodeMixin).hasSourceCode) {
      return [new Subnav('Source', '${element.href}#source')];
    } else {
      return [];
    }
  }
}

class PackageTemplateData extends TemplateData {
  PackageTemplateData(Package package, {Renderer markdown})
      : super(package, markdown: markdown);

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
  Library _library;

  LibraryTemplateData(Package package, this._library) : super(package);

  String get title => '${_library.name} library - Dart API';
  Library get library => _library;
  String get documentation => _library.documentation;
  String get htmlBase => '..';
  String get metaDescription =>
      '${_library.name} library API docs, for the Dart programming language.';
  List get navLinks => [package];
  List<Subnav> get subnavItems {
    List<Subnav> navs = [];

    if (_library.hasConstants) navs
        .add(new Subnav('Constants', '${_library.href}#constants'));
    if (_library.hasTypedefs) navs
        .add(new Subnav('Typedefs', '${_library.href}#typedefs'));
    if (_library.hasProperties) navs
        .add(new Subnav('Properties', '${_library.href}#properties'));
    if (_library.hasFunctions) navs
        .add(new Subnav('Functions', '${_library.href}#functions'));
    if (_library.hasEnums) navs
        .add(new Subnav('Enums', '${_library.href}#enums'));
    if (_library.hasClasses) navs
        .add(new Subnav('Classes', '${_library.href}#classes'));
    if (_library.hasExceptions) navs
        .add(new Subnav('Exceptions', '${_library.href}#exceptions'));

    return navs;
  }

  String get layoutTitle =>
      _layoutTitle(_library.name, 'library', _library.isDeprecated);
  Library get self => _library;
}

class ClassTemplateData extends TemplateData {
  Class _clazz;
  Library _library;
  Class _objectType;

  ClassTemplateData(Package package, this._library, this._clazz)
      : super(package);

  Class get self => _clazz;
  Library get library => _library;
  Class get clazz => _clazz;
  String get linkedObjectType =>
      objectType == null ? 'Object' : objectType.linkedName;
  String get title =>
      '${clazz.name} ${clazz.kind} - ${_library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${clazz.name} ${clazz.kind} from the ${_library.name} library, for the Dart programming language.';
  String get layoutTitle =>
      _layoutTitle(clazz.nameWithGenerics, clazz.kind, clazz.isDeprecated);
  List get navLinks => [package, _library];
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
  Library _library;
  Class _class;
  Constructor _constructor;

  ConstructorTemplateData(
      Package package, this._library, this._class, this._constructor)
      : super(package);

  Constructor get self => _constructor;
  Library get library => _library;
  Class get clazz => _class;
  Constructor get constructor => _constructor;
  String get layoutTitle =>
      _layoutTitle(constructor.name, 'constructor', constructor.isDeprecated);
  List get navLinks => [package, _library, clazz];
  List<Subnav> get subnavItems => _gatherSubnavForInvokable(constructor);
  String get htmlBase => '../..';
  String get title =>
      '${constructor.name} constructor - ${clazz.name} class - ${_library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${constructor.name} constructor from the ${clazz} class from the ${_library.name} library, for the Dart programming language.';
}

class EnumTemplateData extends TemplateData {
  Library _library;
  Enum _enum;

  EnumTemplateData(Package package, this._library, this._enum) : super(package);

  Library get library => _library;
  Enum get clazz => _enum;
  Enum get self => _enum;
  String get layoutTitle =>
      _layoutTitle(_enum.name, 'enum', _enum.isDeprecated);
  String get title => '${self.name} enum - ${_library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${_enum.name} enum from the ${_library.name} library, for the Dart programming language.';
  List get navLinks => [package, _library];
  String get htmlBase => '..';
  List<Subnav> get subnavItems {
    return [
      new Subnav('Constants', '${_enum.href}#constants'),
      new Subnav('Properties', '${_enum.href}#properties')
    ];
  }
}

class FunctionTemplateData extends TemplateData {
  ModelFunction _function;
  Library _library;

  FunctionTemplateData(Package package, this._library, this._function)
      : super(package);

  ModelFunction get self => _function;
  ModelFunction get function => _function;
  Library get library => _library;
  String get title =>
      '${function.name} function - ${_library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(function.name, 'function', function.isDeprecated);
  String get metaDescription =>
      'API docs for the ${function.name} function from the ${_library.name} library, for the Dart programming language.';
  List get navLinks => [package, _library];
  List<Subnav> get subnavItems => _gatherSubnavForInvokable(function);
  String get htmlBase => '..';
}

class MethodTemplateData extends TemplateData {
  Library _library;
  Method _method;
  Class _class;

  MethodTemplateData(Package package, this._library, this._class, this._method)
      : super(package);

  Library get library => _library;
  Class get clazz => _class;
  Method get self => _method;
  Method get method => _method;
  String get title =>
      '${method.name} method - ${clazz.name} class - ${_library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(method.name, 'method', method.isDeprecated);
  String get metaDescription =>
      'API docs for the ${method.name} method from the ${clazz.name} class, for the Dart programming language.';
  List get navLinks => [package, _library, clazz];
  List<Subnav> get subnavItems => _gatherSubnavForInvokable(method);
  String get htmlBase => '../..';
}

class PropertyTemplateData extends TemplateData {
  Library _library;
  Class _class;
  Field _property;

  PropertyTemplateData(
      Package package, this._library, this._class, this._property)
      : super(package);

  Library get library => _library;
  Class get clazz => _class;
  Field get self => _property;
  Field get property => _property;

  String get title =>
      '${property.name} $type - ${clazz.name} class - ${_library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(property.name, type, property.isDeprecated);
  String get metaDescription =>
      'API docs for the ${property.name} $type from the ${clazz.name} class, for the Dart programming language.';
  List get navLinks => [package, _library, clazz];
  List get subnavItems => [];
  String get htmlBase => '../..';

  String get type => 'property';
}

class ConstantTemplateData extends PropertyTemplateData {
  ConstantTemplateData(
      Package package, Library library, Class clazz, Field property)
      : super(package, library, clazz, property);

  String get type => 'constant';
}

class TypedefTemplateData extends TemplateData {
  Library _library;
  Typedef _typeDef;

  TypedefTemplateData(Package package, this._library, this._typeDef)
      : super(package);

  Library get library => _library;
  Typedef get self => _typeDef;
  Typedef get typeDef => _typeDef;

  String get title =>
      '${typeDef.name} typedef - ${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(typeDef.name, 'typedef', typeDef.isDeprecated);
  String get metaDescription =>
      'API docs for the ${typeDef.name} property from the ${library.name} library, for the Dart programming language.';
  List get navLinks => [package, library];
  String get htmlBase => '..';
  List get subnavItems => [];
}

class TopLevelPropertyTemplateData extends TemplateData {
  Library _library;
  TopLevelVariable _property;

  TopLevelPropertyTemplateData(Package package, this._library, this._property)
      : super(package);

  Library get library => _library;
  TopLevelVariable get self => _property;
  TopLevelVariable get property => _property;

  String get title =>
      '${property.name} $_type - ${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(property.name, _type, property.isDeprecated);
  String get metaDescription =>
      'API docs for the ${property.name} $_type from the ${library.name} library, for the Dart programming language.';
  List get navLinks => [package, library];
  String get htmlBase => '..';
  List get subnavItems => [];

  String get _type => 'property';
}

class TopLevelConstTemplateData extends TopLevelPropertyTemplateData {
  TopLevelConstTemplateData(
      Package package, Library library, TopLevelVariable property)
      : super(package, library, property);

  String get _type => 'constant';
}
