// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future;
import 'dart:io';

import 'package:mustache4dart/mustache4dart.dart';
import 'package:path/path.dart' as path;

import 'model.dart';
import 'package_meta.dart';
import 'resources.g.dart' as resources;
import '../generator.dart';
import '../markdown_processor.dart';
import '../resource_loader.dart' as loader;

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

    var partials = [
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
      'name_link'
    ];

    for (var partial in partials) {
      _partialTemplates[partial] = await _loadPartial('_$partial.html');
    }
  }

  String _partial(String name) => _partialTemplates[name];

  Future<TemplateRenderer> _loadTemplate(String templatePath) async {
    var templateContents = await _getTemplateFile(templatePath);
    return compile(templateContents, partial: _partial) as TemplateRenderer;
  }

  Future<String> _getTemplateFile(String templatePath) {
    return loader.loadAsString('package:dartdoc/templates/$templatePath');
  }

  Future<String> _loadPartial(String templatePath) async {
    String template = await _getTemplateFile(templatePath);
    // TODO: revisit, not sure this is the right place for this logic
    if (templatePath.contains('_footer') && _footer != null) {
      var footerValue = await new File(_footer).readAsString();
      template =
          template.replaceAll('<!-- Footer Placeholder -->', footerValue);
    }
    if (templatePath.contains('_head') && _header != null) {
      var headerValue = await new File(_header).readAsString();
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
      : _templates = new Templates(header, footer);

  Future generate(Package package, Directory out) {
    return new HtmlGeneratorInstance(url, _templates, package, out).generate();
  }
}

class HtmlGeneratorInstance {
  final String url;
  final Templates _templates;

  final Package package;
  final Directory out;

  final List<String> _htmlFiles = [];

  HtmlGeneratorInstance(this.url, this._templates, this.package, this.out);

  Future generate() async {
    await _templates.init();
    if (!out.existsSync()) out.createSync();

    if (package != null) {
      _generateDocs();
    }

    //if (url != null) generateSiteMap();

    await _copyResources();
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

        clazz.instanceProperties.forEach((property) {
          generateProperty(package, lib, clazz, property);
        });

        clazz.instanceMethods.forEach((method) {
          generateMethod(package, lib, clazz, method);
        });

        clazz.operators.forEach((operator) {
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
    // TODO: Should we add _this_ to the context and avoid putting stuff in the
    // map?
    var data = new PackageTemplateData(package);

    if (package.hasDocumentationFile) {
      FileContents readme = package.documentationFile;
      data['markdown'] = readme.isMarkdown ? renderMarkdown : renderPlainText;
    }

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    print('generating docs for library ${lib.name} from ${lib.path}...');

    if (!lib.hasDocumentation) {
      print("  warning: library '${lib.name}' has no documentation");
    }

    var data = new LibraryTemplateData(package, lib);

    _build(path.join(lib.dirName, '${lib.fileName}'),
        _templates.libraryTemplate, data);
  }

  void generateClass(Package package, Library lib, Class clazz) {
    var data = new ClassTemplateData(package, lib, clazz);

    _build(path.joinAll(clazz.href.split('/')), _templates.classTemplate, data);
  }

  void generateConstructor(
      Package package, Library lib, Class clazz, Constructor constructor) {
    var data = new ConstructorTemplateData(package, lib, clazz, constructor);

    _build(path.joinAll(constructor.href.split('/')),
        _templates.constructorTemplate, data);
  }

  void generateEnum(Package package, Library lib, Class eNum) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': eNum.documentation,
      'oneLineDoc': eNum.oneLineDoc,
      'library': lib,
      'class': eNum,
      'layoutTitle': _layoutTitle(eNum.name, 'enum', eNum.isDeprecated),
      'navLinks': [package, lib],
      'htmlBase': '..',
      'self': eNum
    };

    _build(path.joinAll(eNum.href.split('/')), _templates.classTemplate, data);
  }

  void generateFunction(Package package, Library lib, ModelFunction function) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': function.documentation,
      'oneLineDoc': function.oneLineDoc,
      'library': lib,
      'function': function,
      'title': '${function.name} function - ${lib.name} library - Dart API',
      'layoutTitle':
          _layoutTitle(function.name, 'function', function.isDeprecated),
      'metaDescription':
          'API docs for the ${function.name} function from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'subnavItems': _gatherSubnavForInvokable(function),
      'htmlBase': '..',
      'self': function
    };

    _build(path.joinAll(function.href.split('/')), _templates.functionTemplate,
        data);
  }

  void generateMethod(
      Package package, Library lib, Class clazz, Method method) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': method.documentation,
      'oneLineDoc': method.oneLineDoc,
      'library': lib,
      'class': clazz,
      'method': method,
      'title':
          '${method.name} method - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle': _layoutTitle(method.name, 'method', method.isDeprecated),
      'metaDescription':
          'API docs for the ${method.name} method from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz],
      'subnavItems': _gatherSubnavForInvokable(method),
      'htmlBase': '../..',
      'self': method
    };

    _build(
        path.joinAll(method.href.split('/')), _templates.methodTemplate, data);
  }

  void generateConstant(
      Package package, Library lib, Class clazz, Field property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': property.documentation,
      'oneLineDoc': property.oneLineDoc,
      'library': lib,
      'class': clazz,
      'property': property,
      'title':
          '${property.name} constant - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle':
          _layoutTitle(property.name, 'constant', property.isDeprecated),
      'metaDescription':
          'API docs for the ${property.name} constant from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz],
      'htmlBase': '../..',
      'self': property
    };

    _build(path.joinAll(property.href.split('/')), _templates.constantTemplate,
        data);
  }

  void generateProperty(
      Package package, Library lib, Class clazz, Field property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': property.documentation,
      'oneLineDoc': property.oneLineDoc,
      'library': lib,
      'class': clazz,
      'property': property,
      'title':
          '${property.name} property - ${clazz.name} class - ${lib.name} library - Dart API',
      'layoutTitle':
          _layoutTitle(property.name, 'property', property.isDeprecated),
      'metaDescription':
          'API docs for the ${property.name} property from the ${clazz.name} class, for the Dart programming language.',
      'navLinks': [package, lib, clazz],
      'htmlBase': '../..',
      'self': property
    };

    _build(path.joinAll(property.href.split('/')), _templates.propertyTemplate,
        data);
  }

  void generateTopLevelProperty(
      Package package, Library lib, TopLevelVariable property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': property.documentation,
      'oneLineDoc': property.oneLineDoc,
      'library': lib,
      'property': property,
      'title': '${property.name} property - ${lib.name} library - Dart API',
      'layoutTitle':
          _layoutTitle(property.name, 'property', property.isDeprecated),
      'metaDescription':
          'API docs for the ${property.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'htmlBase': '..',
      'self': property
    };

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelPropertyTemplate, data);
  }

  void generateTopLevelConstant(
      Package package, Library lib, TopLevelVariable property) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': property.documentation,
      'oneLineDoc': property.oneLineDoc,
      'library': lib,
      'property': property,
      'title': '${property.name} property - ${lib.name} library - Dart API',
      'layoutTitle':
          _layoutTitle(property.name, 'constant', property.isDeprecated),
      'metaDescription':
          'API docs for the ${property.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'htmlBase': '..',
      'self': property
    };

    _build(path.joinAll(property.href.split('/')),
        _templates.topLevelConstantTemplate, data);
  }

  void generateTypeDef(Package package, Library lib, Typedef typeDef) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': typeDef.documentation,
      'oneLineDoc': typeDef.oneLineDoc,
      'library': lib,
      'typeDef': typeDef,
      'title': '${typeDef.name} typedef - ${lib.name} library - Dart API',
      'layoutTitle':
          _layoutTitle(typeDef.name, 'typedef', typeDef.isDeprecated),
      'metaDescription':
          'API docs for the ${typeDef.name} property from the ${lib.name} library, for the Dart programming language.',
      'navLinks': [package, lib],
      'htmlBase': '..',
      'self': typeDef
    };

    _build(path.joinAll(typeDef.href.split('/')), _templates.typeDefTemplate,
        data);
  }

  // TODO: change this to use resource_loader
  Future _copyResources() async {
    final prefix = 'package:dartdoc/resources/';
    for (var resourcePath in resources.resource_names) {
      if (!resourcePath.startsWith(prefix)) {
        throw new StateError(
            'Resource paths must start with $prefix, encountered $resourcePath');
      }
      var destFileName = resourcePath.substring(prefix.length);
      var destFile =
          new File(path.join(out.path, 'static-assets', destFileName))
            ..createSync(recursive: true);
      var resourceBytes = await loader.loadAsBytes(resourcePath);
      destFile.writeAsBytesSync(resourceBytes);
    }
  }

  File _createOutputFile(String filename) {
    File f = new File(path.join(out.path, filename));
    if (!f.existsSync()) f.createSync(recursive: true);
    _htmlFiles.add(filename);
    return f;
  }

  void _build(String filename, TemplateRenderer template, Map data) {
    String content = template(data,
        assumeNullNonExistingProperty: false, errorOnMissingProperty: true);

    _writeFile(filename, content);
  }

  void _writeFile(String filename, String content) {
    File f = _createOutputFile(filename);
    f.writeAsStringSync(content);
  }
}

class Subnav {
  final String name;
  final String href;

  Subnav(this.name, this.href);

  String toString() => name;
}

List<Subnav> _gatherSubnavForClass(Class clazz) {
  List<Subnav> navs = [];

  if (clazz.hasConstants) navs
      .add(new Subnav('Constants', '${clazz.href}#constants'));
  if (clazz.hasStaticProperties) navs
      .add(new Subnav('Static Properties', '${clazz.href}#static-properties'));
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

List<Subnav> _gatherSubnavForInvokable(ModelElement element) {
  if (element is SourceCodeMixin &&
      (element as SourceCodeMixin).hasSourceCode) {
    return [new Subnav('Source', '${element.href}#source')];
  } else {
    return [];
  }
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

  TemplateData(this._package);

  Package get package => _package;
  String get documentation => self.documentation;
  String get oneLineDoc => self.oneLineDoc;
  String get title;
  String get layoutTitle;
  String get metaDescription;
  List get navLinks => [];
  List<Subnav> get subnavItems;
  String get htmlBase;
  dynamic get self;
  String get version => '';
  Function get markdown => renderMarkdown;

  String _layoutTitle(String name, String kind, bool isDeprecated) {
    if (kind.isEmpty) kind =
        '&nbsp;'; // Ugly. fixes https://github.com/dart-lang/dartdoc/issues/695
    String str = '<div class="kind">$kind</div>';
    if (!isDeprecated) return '${str} ${name}';
    return '${str} <span class="deprecated">$name</span>';
  }
}

class PackageTemplateData extends TemplateData {
  PackageTemplateData(Package package) : super(package);

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
  List<Subnav> get subnavLinks => _gatherSubnavForInvokable(constructor);
  String get htmlBase => '../..';
}
