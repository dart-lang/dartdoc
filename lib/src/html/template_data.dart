// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model.dart';

abstract class HtmlOptions {
  String get relCanonicalPrefix;
  String get toolVersion;
}

abstract class TemplateData<T extends Documentable> {
  final PackageGraph packageGraph;
  final HtmlOptions htmlOptions;

  TemplateData(this.htmlOptions, this.packageGraph);

  String get title;
  String get layoutTitle;
  String get metaDescription;

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

  String get htmlBase;
  T get self;
  String get version => htmlOptions.toolVersion;
  String get relCanonicalPrefix => htmlOptions.relCanonicalPrefix;

  String _layoutTitle(String name, String kind, bool isDeprecated) {
    if (isDeprecated) {
      return '<span class="deprecated">${name}</span> ${kind}';
    } else {
      return '${name} ${kind}';
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
  String get layoutTitle => _layoutTitle(package.name, package.kind, false);
  @override
  String get metaDescription =>
      '${package.name} API docs, for the Dart programming language.';

  @override
  bool get hasHomepage => package.hasHomepage;
  String get homepage => package.homepage;

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
  String get htmlBase => '..';
  @override
  String get metaDescription =>
      '${library.name} library API docs, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage];

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

/// Base template data class for [Extension].
class ExtensionTemplateData<T extends Extension> extends TemplateData<T> {
  final T extension;
  final Library library;

  ExtensionTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.extension)
      : super(htmlOptions, packageGraph);

  @override
  T get self => extension;

  @override
  String get title =>
      '${extension.name} ${extension.kind} - ${library.name} library - Dart API';
  @override
  String get metaDescription =>
      'API docs for the ${extension.name} ${extension.kind} from the '
      '${library.name} library, for the Dart programming language.';

  @override
  String get layoutTitle => _layoutTitle(extension.name, extension.kind, false);
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '..';
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
  String get htmlBase => '..';
}

class MethodTemplateData extends TemplateData<Method> {
  final Library library;
  final Method method;
  final Container clazz;
  String container;

  MethodTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.clazz, this.method)
      : super(htmlOptions, packageGraph) {
    container = clazz.isClass ? 'class' : 'extension';
  }

  @override
  Method get self => method;
  @override
  String get title => '${method.name} method - ${clazz.name} ${container} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(
      method.nameWithGenerics, method.fullkind, method.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${method.name} method from the ${clazz.name} ${container}, '
      'for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  List get navLinksWithGenerics => [clazz];
  @override
  String get htmlBase => '../..';
}

class PropertyTemplateData extends TemplateData<Field> {
  final Library library;
  final Container clazz;
  final Field property;
  String container;

  PropertyTemplateData(HtmlOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.clazz, this.property)
      : super(htmlOptions, packageGraph) {
    container = clazz.isClass ? 'class' : 'extension';
  }

  @override
  Field get self => property;

  @override
  String get title => '${property.name} $type - ${clazz.name} ${container} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(property.name, type, property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} $type from the ${clazz.name} ${container}, '
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
      Library library, Container clazz, Field property)
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
