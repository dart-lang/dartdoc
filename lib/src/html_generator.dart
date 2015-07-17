// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future;
import 'dart:io';
import 'dart:profiler';

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

final UserTag _HTML_GENERATE = new UserTag('HTML GENERATE');

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
      'name_summary'
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
  final String url;
  final Templates _templates;

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
    var previousTag = _HTML_GENERATE.makeCurrent();
    await _templates.init();
    if (!out.existsSync()) out.createSync();
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

    //if (url != null) generateSiteMap();

    await _copyResources();

    previousTag.makeCurrent();
  }

  void generatePackage() {
    // TODO: Should we add _this_ to the context and avoid putting stuff in the
    // map?
    Map data = {
      'package': package,
      'documentation': package.documentation,
      'title': '${package.name} - Dart API docs',
      'layoutTitle':
          _layoutTitle(package.name, package.isSdk ? '' : 'package', false),
      'metaDescription':
          '${package.name} API docs, for the Dart programming language.',
      'navLinks': [], // we're at the root
      'subnavItems': _gatherSubnavForPackage(package),
      'htmlBase': '.',
      'self': package
    };

    if (package.hasDocumentation) {
      FileContents readme = package.documentationFile;
      data['markdown'] = readme.isMarkdown ? renderMarkdown : renderPlainText;
    }

    _build('index.html', _templates.indexTemplate, data);
  }

  void generateLibrary(Package package, Library lib) {
    print('generating docs for library ${lib.path}...');

    if (!lib.hasDocumentation) {
      print("  warning: library '${lib.name}' has no documentation");
    }

    // TODO: Should we add _this_ to the context and avoid putting stuff in the
    // map?
    Map data = {
      'package': package,
      'library': lib,
      'markdown': renderMarkdown,
      'documentation': lib.documentation,
      'oneLineDoc': lib.oneLineDoc,
      'title': '${lib.name} library - Dart API',
      'htmlBase': '..',
      'metaDescription':
          '${lib.name} library API docs, for the Dart programming language.',
      'navLinks': [package],
      'subnavItems': _gatherSubnavForLibrary(lib),
      'layoutTitle': _layoutTitle(lib.name, 'library', lib.isDeprecated),
      'self': lib
    };

    _build(path.join(lib.dirName, '${lib.fileName}'),
        _templates.libraryTemplate, data);
  }

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    Library dc = package.libraries.firstWhere((it) => it.name == "dart:core",
        orElse: () => null);

    if (dc == null) {
      return _objectType = null;
    }

    return _objectType = dc.getClassByName("Object");
  }

  Class _objectType;

  void generateClass(Package package, Library lib, Class clazz) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': clazz.documentation,
      'oneLineDoc': clazz.oneLineDoc,
      'library': lib,
      'class': clazz,
      'linkedObjectType': objectType == null ? 'Object' : objectType.linkedName,
      'title': '${clazz.name} ${clazz.kind} - ${lib.name} library - Dart API',
      'metaDescription':
          'API docs for the ${clazz.name} ${clazz.kind} from the ${lib.name} library, for the Dart programming language.',
      'layoutTitle':
          _layoutTitle(clazz.nameWithGenerics, clazz.kind, clazz.isDeprecated),
      'navLinks': [package, lib],
      'subnavItems': _gatherSubnavForClass(clazz),
      'htmlBase': '..',
      'self': clazz
    };

    _build(path.joinAll(clazz.href.split('/')), _templates.classTemplate, data);
  }

  void generateConstructor(
      Package package, Library lib, Class clazz, Constructor constructor) {
    Map data = {
      'package': package,
      'markdown': renderMarkdown,
      'documentation': constructor.documentation,
      'oneLineDoc': constructor.oneLineDoc,
      'library': lib,
      'class': clazz,
      'constructor': constructor,
      'layoutTitle': _layoutTitle(
          constructor.name, 'constructor', constructor.isDeprecated),
      'navLinks': [package, lib, clazz],
      'htmlBase': '../..',
      'self': constructor
    };

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

List<Subnav> _gatherSubnavForPackage(Package package) {
  return [new Subnav('Libraries', '${package.href}#libraries')];
}

List<Subnav> _gatherSubnavForLibrary(Library lib) {
  List<Subnav> navs = [];

  if (lib.hasConstants) navs
      .add(new Subnav('Constants', '${lib.href}#constants'));
  if (lib.hasTypedefs) navs.add(new Subnav('Typedefs', '${lib.href}#typedefs'));
  if (lib.hasProperties) navs
      .add(new Subnav('Properties', '${lib.href}#properties'));
  if (lib.hasFunctions) navs
      .add(new Subnav('Functions', '${lib.href}#functions'));
  if (lib.hasEnums) navs.add(new Subnav('Enums', '${lib.href}#enums'));
  if (lib.hasClasses) navs.add(new Subnav('Classes', '${lib.href}#classes'));
  if (lib.hasExceptions) navs
      .add(new Subnav('Exceptions', '${lib.href}#exceptions'));

  return navs;
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

String _layoutTitle(String name, String kind, bool isDeprecated) {
  if (kind.isEmpty) return name;
  String str = '<div class="kind">$kind</div>';
  if (!isDeprecated) return '${str} ${name}';
  return '${str} <span class="deprecated">$name</span>';
}

/// Converts a markdown formatted string into HTML, and removes any script tags.
/// Returns the HTML as a string.
String renderMarkdown(String markdown) => renderMarkdownToHtml(markdown);

/// Convert the given plain text into HTML.
String renderPlainText(String text) {
  if (text == null) return '';

  return "<code class='fixed'>${text.trim()}</code>";
}
