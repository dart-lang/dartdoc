// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

abstract class TemplateOptions {
  String get relCanonicalPrefix;
  String get toolVersion;
  bool get useBaseHref;
}

abstract class TemplateData<T extends Documentable> {
  final PackageGraph packageGraph;
  final TemplateOptions htmlOptions;

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
  bool get useBaseHref => htmlOptions.useBaseHref;

  String get bareHref {
    if (self is Indexable) {
      return (self as Indexable).href.replaceAll(HTMLBASE_PLACEHOLDER, '');
    }
    return '';
  }

  String _layoutTitle(String name, String kind, bool isDeprecated) =>
      packageGraph.rendererFactory.templateRenderer
          .composeLayoutTitle(name, kind, isDeprecated);
}

class PackageTemplateData extends TemplateData<Package> {
  final Package package;
  PackageTemplateData(
      TemplateOptions htmlOptions, PackageGraph packageGraph, this.package)
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

  /// empty for packages because they are at the root – not needed
  @override
  String get htmlBase => '';
}

class CategoryTemplateData extends TemplateData<Category> {
  final Category category;

  CategoryTemplateData(
      TemplateOptions htmlOptions, PackageGraph packageGraph, this.category)
      : super(htmlOptions, packageGraph);

  @override
  String get title => '${category.name} ${category.kind} - Dart API';

  @override
  String get htmlBase => '../';

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
      TemplateOptions htmlOptions, PackageGraph packageGraph, this.library)
      : super(htmlOptions, packageGraph);

  @override
  String get title => '${library.name} library - Dart API';
  @override
  String get htmlBase => '../';
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

  MixinTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
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

  ClassTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
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
  String get htmlBase => '../';

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    var dc = packageGraph.libraries
        .firstWhere((it) => it.name == 'dart:core', orElse: () => null);

    if (dc == null) {
      return _objectType = null;
    }

    return _objectType = dc.getClassByName('Object');
  }
}

/// Base template data class for [Extension].
class ExtensionTemplateData<T extends Extension> extends TemplateData<T> {
  final T extension;
  final Library library;

  ExtensionTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
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
  String get htmlBase => '../';
}

class ConstructorTemplateData extends TemplateData<Constructor> {
  final Library library;
  final Class clazz;
  final Constructor constructor;

  ConstructorTemplateData(TemplateOptions htmlOptions,
      PackageGraph packageGraph, this.library, this.clazz, this.constructor)
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
  String get htmlBase => '../../';
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
  EnumTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      Library library, Enum eNum)
      : super(htmlOptions, packageGraph, library, eNum);

  Enum get eNum => clazz;
  @override
  Enum get self => eNum;
}

class FunctionTemplateData extends TemplateData<ModelFunction> {
  final ModelFunction function;
  final Library library;

  FunctionTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
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
  String get htmlBase => '../';
}

class MethodTemplateData extends TemplateData<Method> {
  final Library library;
  final Method method;
  final Container container;
  String containerDesc;

  MethodTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.container, this.method)
      : super(htmlOptions, packageGraph) {
    containerDesc = container.isClass ? 'class' : 'extension';
  }

  @override
  Method get self => method;
  @override
  String get title =>
      '${method.name} method - ${container.name} ${containerDesc} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(
      method.nameWithGenerics, method.fullkind, method.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${method.name} method from the '
      '${container.name} ${containerDesc}, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  List get navLinksWithGenerics => [container];
  @override
  String get htmlBase => '../../';
}

class PropertyTemplateData extends TemplateData<Field> {
  final Library library;
  final Container container;
  final Field property;
  String containerDesc;

  PropertyTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.container, this.property)
      : super(htmlOptions, packageGraph) {
    containerDesc = container.isClass ? 'class' : 'extension';
  }

  @override
  Field get self => property;

  @override
  String get title =>
      '${property.name} $_type - ${container.name} ${containerDesc} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(property.name, _type, property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} $_type from the '
      '${container.name} ${containerDesc}, for the Dart programming language.';
  @override
  List get navLinks => [packageGraph.defaultPackage, library];
  @override
  List get navLinksWithGenerics => [container];
  @override
  String get htmlBase => '../../';

  String get _type => property.isConst ? 'constant' : 'property';
}

class TypedefTemplateData extends TemplateData<Typedef> {
  final Library library;
  final Typedef typeDef;

  TypedefTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
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
  String get htmlBase => '../';
}

class TopLevelPropertyTemplateData extends TemplateData<TopLevelVariable> {
  final Library library;
  final TopLevelVariable property;

  TopLevelPropertyTemplateData(TemplateOptions htmlOptions,
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
  String get htmlBase => '../';

  String get _type => property.isConst ? 'constant' : 'property';
}
