// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../markdown_processor.dart';
import '../model.dart';

typedef String MarkdownRenderer(String input);

/// Converts a markdown formatted string into HTML, and removes any script tags.
/// Returns the HTML as a string.
String renderMarkdown(String markdown) => renderMarkdownToHtml(markdown);

abstract class HtmlOptions {
  String get relCanonicalPrefix;
  String get toolVersion;
}

class Subnav {
  final String name;
  final String href;

  Subnav(this.name, this.href);

  String toString() => name;
}

abstract class TemplateData {
  final Package package;
  final MarkdownRenderer markdownRenderer;
  final HtmlOptions htmlOptions;

  TemplateData(this.htmlOptions, this.package, {MarkdownRenderer markdown})
      : this.markdownRenderer = markdown == null ? renderMarkdown : markdown;

  String get documentation => self.documentation;
  String get oneLineDoc => self.oneLineDoc;
  String get title;
  String get layoutTitle;
  String get metaDescription;
  List get navLinks;
  List<Subnav> get subnavItems;
  String get htmlBase;
  dynamic get self;
  String get version => htmlOptions.toolVersion;
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
      {MarkdownRenderer markdown})
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
