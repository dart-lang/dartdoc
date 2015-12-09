// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model.dart';

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

abstract class TemplateData<T extends Documentable> {
  final Package package;
  final HtmlOptions htmlOptions;

  List<Subnav> _subNameItemCache;

  TemplateData(this.htmlOptions, this.package);

  String get documentation => self.documentation;
  String get oneLineDoc => self.oneLineDoc;
  String get title;
  String get layoutTitle;
  String get metaDescription;
  List get navLinks;
  bool get includeVersion => false;

  bool get hasSubNav => subnavItems.isNotEmpty;

  List<Subnav> get subnavItems {
    if (_subNameItemCache == null) {
      _subNameItemCache = getSubNavItems().toList();
    }
    return _subNameItemCache;
  }

  String get htmlBase;
  T get self;
  String get version => htmlOptions.toolVersion;
  String get relCanonicalPrefix => htmlOptions.relCanonicalPrefix;

  Iterable<Subnav> getSubNavItems() => const Iterable<Subnav>.empty();

  String _layoutTitle(String name, String kind, bool isDeprecated) {
    if (kind.isEmpty)
      kind =
          '&nbsp;'; // Ugly. fixes https://github.com/dart-lang/dartdoc/issues/695
    String str = '<span class="kind">$kind</span>';
    if (!isDeprecated) return '${str} ${name}';
    return '${str} <span class="deprecated">$name</span>';
  }

  Iterable<Subnav> _gatherSubnavForInvokable(ModelElement element) sync* {
    if (element is SourceCodeMixin &&
        (element as SourceCodeMixin).hasSourceCode) {
      yield new Subnav('Source', '${element.href}#source');
    }
  }
}

class PackageTemplateData extends TemplateData<Package> {
  PackageTemplateData(HtmlOptions htmlOptions, Package package)
      : super(htmlOptions, package);

  bool get includeVersion => true;
  List get navLinks => [];
  String get title => '${package.name} - Dart API docs';
  Package get self => package;
  String get layoutTitle =>
      _layoutTitle(package.name, package.isSdk ? '' : 'package', false);
  String get metaDescription =>
      '${package.name} API docs, for the Dart programming language.';
  Iterable<Subnav> getSubNavItems() sync* {
    yield new Subnav('Libraries', '${package.href}#libraries');
  }

  /// `null` for packages because they are at the root – not needed
  String get htmlBase => null;
}

class LibraryTemplateData extends TemplateData<Library> {
  final Library library;

  LibraryTemplateData(HtmlOptions htmlOptions, Package package, this.library)
      : super(htmlOptions, package);

  String get title => '${library.name} library - Dart API';
  String get documentation => library.documentation;
  String get htmlBase => '..';
  String get metaDescription =>
      '${library.name} library API docs, for the Dart programming language.';
  List get navLinks => [package];
  Iterable<Subnav> getSubNavItems() sync* {
    if (library.hasConstants)
      yield new Subnav('Constants', '${library.href}#constants');
    if (library.hasTypedefs)
      yield new Subnav('Typedefs', '${library.href}#typedefs');
    if (library.hasProperties)
      yield new Subnav('Properties', '${library.href}#properties');
    if (library.hasFunctions)
      yield new Subnav('Functions', '${library.href}#functions');
    if (library.hasEnums) yield new Subnav('Enums', '${library.href}#enums');
    if (library.hasClasses)
      yield new Subnav('Classes', '${library.href}#classes');
    if (library.hasExceptions)
      yield new Subnav('Exceptions', '${library.href}#exceptions');
  }

  String get layoutTitle =>
      _layoutTitle(library.name, 'library', library.isDeprecated);
  Library get self => library;
}

class ClassTemplateData extends TemplateData<Class> {
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
  Iterable<Subnav> getSubNavItems() sync* {
    if (clazz.hasConstants)
      yield new Subnav('Constants', '${clazz.href}#constants');
    if (clazz.hasStaticProperties)
      yield new Subnav('Static Properties', '${clazz.href}#static-properties');
    if (clazz.hasStaticMethods)
      yield new Subnav('Static Methods', '${clazz.href}#static-methods');
    if (clazz.hasInstanceProperties)
      yield new Subnav('Properties', '${clazz.href}#instance-properties');
    if (clazz.hasConstructors)
      yield new Subnav('Constructors', '${clazz.href}#constructors');
    if (clazz.hasOperators)
      yield new Subnav('Operators', '${clazz.href}#operators');
    if (clazz.hasInstanceMethods)
      yield new Subnav('Methods', '${clazz.href}#instance-methods');
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

class ConstructorTemplateData extends TemplateData<Constructor> {
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
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(constructor);
  String get htmlBase => '../..';
  String get title => '${constructor.name} constructor - ${clazz.name} class - '
      '${library.name} library - Dart API';
  String get metaDescription =>
      'API docs for the ${constructor.name} constructor from the '
      '${clazz} class from the ${library.name} library, '
      'for the Dart programming language.';
}

class EnumTemplateData extends TemplateData<Enum> {
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
  Iterable<Subnav> getSubNavItems() => [
        new Subnav('Constants', '${clazz.href}#constants'),
        new Subnav('Properties', '${clazz.href}#properties')
      ];
}

class FunctionTemplateData extends TemplateData<ModelFunction> {
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
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(function);
  String get htmlBase => '..';
}

class MethodTemplateData extends TemplateData<Method> {
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
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(method);
  String get htmlBase => '../..';
}

class PropertyTemplateData extends TemplateData<Field> {
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
  String get htmlBase => '../..';

  String get type => 'property';
}

class ConstantTemplateData extends PropertyTemplateData {
  ConstantTemplateData(HtmlOptions htmlOptions, Package package,
      Library library, Class clazz, Field property)
      : super(htmlOptions, package, library, clazz, property);

  String get type => 'constant';
}

class TypedefTemplateData extends TemplateData<Typedef> {
  final Library library;
  final Typedef typeDef;

  TypedefTemplateData(
      HtmlOptions htmlOptions, Package package, this.library, this.typeDef)
      : super(htmlOptions, package);

  Typedef get self => typeDef;

  String get title =>
      '${typeDef.name} typedef - ${library.name} library - Dart API';
  String get layoutTitle =>
      _layoutTitle(typeDef.nameWithGenerics, 'typedef', typeDef.isDeprecated);
  String get metaDescription =>
      'API docs for the ${typeDef.name} property from the '
      '${library.name} library, for the Dart programming language.';
  List get navLinks => [package, library];
  String get htmlBase => '..';
}

class TopLevelPropertyTemplateData extends TemplateData<TopLevelVariable> {
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

  String get _type => 'property';
}

class TopLevelConstTemplateData extends TopLevelPropertyTemplateData {
  TopLevelConstTemplateData(HtmlOptions htmlOptions, Package package,
      Library library, TopLevelVariable property)
      : super(htmlOptions, package, library, property);

  String get _type => 'constant';
}
