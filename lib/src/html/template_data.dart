// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model.dart';

abstract class HtmlOptions {
  String get relCanonicalPrefix;
  String get toolVersion;
}

class Subnav {
  final String name;
  final String href;

  Subnav(this.name, this.href);

  @override
  String toString() => name;
}

abstract class TemplateData<T extends Documentable> {
  final PackageGraph packageGraph;
  final HtmlOptions htmlOptions;

  List<Subnav> _subNameItemCache;

  TemplateData(this.htmlOptions, this.packageGraph);

  List<Category> get displayedCategories => <Category>[];
  String get documentation => self.documentation;
  String get oneLineDoc => self.oneLineDoc;
  String get title;
  String get layoutTitle;
  String get metaDescription;
  String get name => self.name;
  String get kind => self is ModelElement ? (self as ModelElement).kind : null;

  List get navLinks;
  List get navLinksWithGenerics => [];
  Documentable get parent {
    if (navLinksWithGenerics.isEmpty) {
      return navLinks.isNotEmpty ? navLinks.last : null;
    }
    return navLinksWithGenerics.last;
  }

  bool get includeVersion => false;

  bool get hasHomepage => false;
  String get homepage => null;

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

  Iterable<Subnav> getSubNavItems() => <Subnav>[];

  String _layoutTitle(String name, String kind, bool isDeprecated) {
    if (isDeprecated) {
      return '<span class="deprecated">${name}</span> ${kind}';
    } else {
      return '${name} ${kind}';
    }
  }

  Iterable<Subnav> _gatherSubnavForInvokable(ModelElement element) {
    if (element.hasSourceCode) {
      return [new Subnav('Source', '${element.href}#source')];
    } else {
      return <Subnav>[];
    }
  }
}

class PackageTemplateData extends TemplateData<Package> {
  final Package package;
  PackageTemplateData(
      HtmlOptions htmlOptions, PackageGraph packageGraph, this.package)
      : super(htmlOptions, packageGraph);

  @override
  bool get includeVersion => true;
  @override
  List get navLinks => [];
  @override
  String get title => '${package.name} - Dart API docs';
  @override
  Package get self => package;
  @override
  String get layoutTitle => _layoutTitle(package.name, kind, false);
  @override
  String get metaDescription =>
      '${package.name} API docs, for the Dart programming language.';
  @override
  Iterable<Subnav> getSubNavItems() {
    return [new Subnav('Libraries', '${package.href}#libraries')];
  }

  @override
  bool get hasHomepage => package.hasHomepage;
  @override
  String get homepage => package.homepage;
  @override
  String get kind => package.kind;

  /// `null` for packages because they are at the root – not needed
  @override
  String get htmlBase => null;
}

class CategoryTemplateData extends TemplateData<Category> {
  final Category category;

  CategoryTemplateData(
      HtmlOptions htmlOptions, PackageGraph packageGraph, this.category)
      : super(htmlOptions, packageGraph);

  @override
  String get title => '${category.name} ${category.kind} - Dart API';

  @override
  String get htmlBase => '..';

  @override
  String get layoutTitle => _layoutTitle(category.name, category.kind, false);

  @override
  String get metaDescription =>
      '${category.name} ${category.kind} docs, for the Dart programming language.';

  @override
  List get navLinks => [category.package];
  @override
  Iterable<Subnav> getSubNavItems() sync* {
    if (category.hasPublicClasses)
      yield new Subnav('Libraries', '${category.href}#libraries');
    if (category.hasPublicClasses)
      yield new Subnav('Classes', '${category.href}#classes');
    if (category.hasPublicConstants)
      yield new Subnav('Constants', '${category.href}#constants');
    if (category.hasPublicProperties)
      yield new Subnav('Properties', '${category.href}#properties');
    if (category.hasPublicFunctions)
      yield new Subnav('Functions', '${category.href}#functions');
    if (category.hasPublicEnums)
      yield new Subnav('Enums', '${category.href}#enums');
    if (category.hasPublicTypedefs)
      yield new Subnav('Typedefs', '${category.href}#typedefs');
    if (category.hasPublicExceptions)
      yield new Subnav('Exceptions', '${category.href}#exceptions');
  }

  @override
  Category get self => category;
}

class LibraryTemplateData extends TemplateData<Library> {
  final Library library;

  LibraryTemplateData(
      HtmlOptions htmlOptions, PackageGraph packageGraph, this.library)
      : super(htmlOptions, packageGraph);

  @override
  String get title => '${library.name} library - Dart API';
  @override
  String get documentation => library.documentation;
  @override
  String get htmlBase => '..';
  @override
  String get metaDescription =>
      '${library.name} library API docs, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage];
  @override
  Iterable<Subnav> getSubNavItems() sync* {
    if (library.hasPublicClasses)
      yield new Subnav('Classes', '${library.href}#classes');
    if (library.hasPublicConstants)
      yield new Subnav('Constants', '${library.href}#constants');
    if (library.hasPublicProperties)
      yield new Subnav('Properties', '${library.href}#properties');
    if (library.hasPublicFunctions)
      yield new Subnav('Functions', '${library.href}#functions');
    if (library.hasPublicEnums)
      yield new Subnav('Enums', '${library.href}#enums');
    if (library.hasPublicTypedefs)
      yield new Subnav('Typedefs', '${library.href}#typedefs');
    if (library.hasPublicExceptions)
      yield new Subnav('Exceptions', '${library.href}#exceptions');
  }

  @override
  String get layoutTitle =>
      _layoutTitle(library.name, 'library', library.isDeprecated);

  @override
  Library get self => library;
}

/// Template data for Dart 2.1-style mixin declarations.
class MixinTemplateData extends ClassTemplateData<Mixin> {
  final Mixin mixin;

  MixinTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      Library library, this.mixin)
      : super(htmlOptions, packageGraph, library, mixin);

  @override
  Mixin get self => mixin;
}

/// Base template data class for [Class], [Enum], and [Mixin].
class ClassTemplateData<T extends Class> extends TemplateData<T> {
  final Class clazz;
  final Library library;
  Class _objectType;

  ClassTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.clazz)
      : super(htmlOptions, packageGraph);

  @override
  T get self => clazz;
  String get linkedObjectType =>
      objectType == null ? 'Object' : objectType.linkedName;
  @override
  String get title =>
      '${clazz.name} ${clazz.kind} - ${library.name} library - Dart API';
  @override
  String get metaDescription =>
      'API docs for the ${clazz.name} ${clazz.kind} from the '
      '${library.name} library, for the Dart programming language.';

  @override
  String get layoutTitle => _layoutTitle(
      clazz.nameWithLinkedGenerics, clazz.fullkind, clazz.isDeprecated);
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '..';
  @override
  Iterable<Subnav> getSubNavItems() sync* {
    if (clazz.hasPublicConstructors)
      yield new Subnav('Constructors', '${clazz.href}#constructors');
    if (clazz.hasPublicProperties)
      yield new Subnav('Properties', '${clazz.href}#instance-properties');
    if (clazz.hasPublicMethods)
      yield new Subnav('Methods', '${clazz.href}#instance-methods');
    if (clazz.hasPublicOperators)
      yield new Subnav('Operators', '${clazz.href}#operators');
    if (clazz.hasPublicStaticProperties)
      yield new Subnav('Static Properties', '${clazz.href}#static-properties');
    if (clazz.hasPublicStaticMethods)
      yield new Subnav('Static Methods', '${clazz.href}#static-methods');
    if (clazz.hasPublicConstants)
      yield new Subnav('Constants', '${clazz.href}#constants');
  }

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    Library dc = packageGraph.libraries
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

  ConstructorTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.clazz, this.constructor)
      : super(htmlOptions, packageGraph);

  @override
  Constructor get self => constructor;
  @override
  String get layoutTitle => _layoutTitle(
      constructor.name, constructor.fullKind, constructor.isDeprecated);
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  List get navLinksWithGenerics => [clazz];
  @override
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(constructor);
  @override
  String get htmlBase => '../..';
  @override
  String get title => '${constructor.name} constructor - ${clazz.name} class - '
      '${library.name} library - Dart API';
  @override
  String get metaDescription =>
      'API docs for the ${constructor.name} constructor from the '
      '${clazz} class from the ${library.name} library, '
      'for the Dart programming language.';
}

class EnumTemplateData extends ClassTemplateData<Enum> {
  EnumTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      Library library, Enum eNum)
      : super(htmlOptions, packageGraph, library, eNum);

  Enum get eNum => clazz;
  @override
  Enum get self => eNum;
  @override
  Iterable<Subnav> getSubNavItems() => [
        new Subnav('Constants', '${eNum.href}#constants'),
        new Subnav('Properties', '${eNum.href}#instance-properties'),
        new Subnav('Methods', '${eNum.href}#instance-methods'),
        new Subnav('Operators', '${eNum.href}#operators')
      ];
}

class FunctionTemplateData extends TemplateData<ModelFunction> {
  final ModelFunction function;
  final Library library;

  FunctionTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.function)
      : super(htmlOptions, packageGraph);

  @override
  ModelFunction get self => function;
  @override
  String get title =>
      '${function.name} function - ${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(
      function.nameWithGenerics, 'function', function.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${function.name} function from the '
      '${library.name} library, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(function);
  @override
  String get htmlBase => '..';
}

class MethodTemplateData extends TemplateData<Method> {
  final Library library;
  final Method method;
  final Class clazz;

  MethodTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.clazz, this.method)
      : super(htmlOptions, packageGraph);

  @override
  Method get self => method;
  @override
  String get title => '${method.name} method - ${clazz.name} class - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(
      method.nameWithGenerics, method.fullkind, method.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${method.name} method from the ${clazz.name} class, '
      'for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  List get navLinksWithGenerics => [clazz];
  @override
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(method);
  @override
  String get htmlBase => '../..';
}

class PropertyTemplateData extends TemplateData<Field> {
  final Library library;
  final Class clazz;
  final Field property;

  PropertyTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.clazz, this.property)
      : super(htmlOptions, packageGraph);

  @override
  Field get self => property;

  @override
  String get title => '${property.name} $type - ${clazz.name} class - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(property.name, type, property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} $type from the ${clazz.name} class, '
      'for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  List get navLinksWithGenerics => [clazz];
  @override
  String get htmlBase => '../..';

  String get type => 'property';
}

class ConstantTemplateData extends PropertyTemplateData {
  ConstantTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      Library library, Class clazz, Field property)
      : super(htmlOptions, packageGraph, library, clazz, property);

  @override
  String get type => 'constant';
}

class TypedefTemplateData extends TemplateData<Typedef> {
  final Library library;
  final Typedef typeDef;

  TypedefTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.typeDef)
      : super(htmlOptions, packageGraph);

  @override
  Typedef get self => typeDef;

  @override
  String get title =>
      '${typeDef.name} typedef - ${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(typeDef.nameWithGenerics, 'typedef', typeDef.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${typeDef.name} property from the '
      '${library.name} library, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '..';
  @override
  Iterable<Subnav> getSubNavItems() => _gatherSubnavForInvokable(typeDef);
}

class TopLevelPropertyTemplateData extends TemplateData<TopLevelVariable> {
  final Library library;
  final TopLevelVariable property;

  TopLevelPropertyTemplateData(HtmlOptions htmlOptions,
      PackageGraph packageGraph, this.library, this.property)
      : super(htmlOptions, packageGraph);

  @override
  TopLevelVariable get self => property;

  @override
  String get title =>
      '${property.name} $_type - ${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(property.name, _type, property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} $_type from the '
      '${library.name} library, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '..';

  String get _type => 'property';
}

class TopLevelConstTemplateData extends TopLevelPropertyTemplateData {
  TopLevelConstTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      Library library, TopLevelVariable property)
      : super(htmlOptions, packageGraph, library, property);

  @override
  String get _type => 'constant';
}
