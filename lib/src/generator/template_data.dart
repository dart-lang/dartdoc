// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

typedef ContainerSidebar = String Function(Container, TemplateData);
typedef LibrarySidebar = String Function(Library, TemplateData);

abstract class TemplateOptions {
  String get relCanonicalPrefix;
  String get toolVersion;
  bool get useBaseHref;
}

abstract class TemplateData<T extends Documentable> {
  final PackageGraph _packageGraph;
  final TemplateOptions htmlOptions;

  TemplateData(this.htmlOptions, this._packageGraph);

  String get title;
  String get layoutTitle;
  String get metaDescription;

  List<Documentable> get navLinks;
  List<Container> get navLinksWithGenerics => [];
  Documentable get parent {
    if (navLinksWithGenerics.isEmpty) {
      return navLinks.isNotEmpty ? navLinks.last : null;
    }
    return navLinksWithGenerics.last;
  }

  bool get includeVersion => false;

  bool get hasHomepage => false;

  String get homepage => null;

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

  List<Package> get localPackages => _packageGraph.localPackages;

  Package get defaultPackage => _packageGraph.defaultPackage;

  bool get hasFooterVersion => _packageGraph.hasFooterVersion;

  String _layoutTitle(String name, String kind, bool isDeprecated) =>
      _packageGraph.rendererFactory.templateRenderer
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
  List<Documentable> get navLinks => [];
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
  @override
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
  List<Documentable> get navLinks => [category.package];

  @override
  Category get self => category;
}

class LibraryTemplateData extends TemplateData<Library> {
  final Library library;
  final LibrarySidebar _sidebarForLibrary;

  LibraryTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this._sidebarForLibrary)
      : super(htmlOptions, packageGraph);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);
  @override
  String get title => '${library.name} library - Dart API';
  @override
  String get htmlBase => '../';
  @override
  String get metaDescription =>
      '${library.name} library API docs, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage];

  @override
  String get layoutTitle =>
      _layoutTitle(library.name, 'library', library.isDeprecated);

  @override
  Library get self => library;
}

/// Template data for Dart 2.1-style mixin declarations.
class MixinTemplateData extends ClassTemplateData<Mixin> {
  final Mixin mixin;

  MixinTemplateData(
      TemplateOptions htmlOptions,
      PackageGraph packageGraph,
      Library library,
      this.mixin,
      LibrarySidebar _sidebarForLibrary,
      ContainerSidebar _sidebarForContainer)
      : super(htmlOptions, packageGraph, library, mixin, _sidebarForLibrary,
            _sidebarForContainer);

  @override
  Mixin get self => mixin;
}

/// Base template data class for [Class], [Enum], and [Mixin].
class ClassTemplateData<T extends Class> extends TemplateData<T> {
  final Class clazz;
  final Library library;
  Class _objectType;
  final LibrarySidebar _sidebarForLibrary;
  final ContainerSidebar _sidebarForContainer;

  ClassTemplateData(
      TemplateOptions htmlOptions,
      PackageGraph packageGraph,
      this.library,
      this.clazz,
      this._sidebarForLibrary,
      this._sidebarForContainer)
      : super(htmlOptions, packageGraph);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);
  String get sidebarForContainer => _sidebarForContainer(container, this);

  Container get container => clazz;

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
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '../';

  Class get objectType {
    if (_objectType != null) {
      return _objectType;
    }

    var dc = _packageGraph.libraries
        .firstWhere((it) => it.name == 'dart:core', orElse: () => null);

    return _objectType = dc?.getClassByName('Object');
  }
}

/// Base template data class for [Extension].
class ExtensionTemplateData<T extends Extension> extends TemplateData<T> {
  final T extension;
  final Library library;
  final ContainerSidebar _sidebarForContainer;
  final LibrarySidebar _sidebarForLibrary;

  ExtensionTemplateData(
      TemplateOptions htmlOptions,
      PackageGraph packageGraph,
      this.library,
      this.extension,
      this._sidebarForLibrary,
      this._sidebarForContainer)
      : super(htmlOptions, packageGraph);

  String get sidebarForContainer => _sidebarForContainer(container, this);
  String get sidebarForLibrary => _sidebarForLibrary(library, this);

  Container get container => extension;

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
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '../';
}

class ConstructorTemplateData extends TemplateData<Constructor> {
  final Library library;
  final Class clazz;
  final Constructor constructor;
  final ContainerSidebar _sidebarForContainer;

  ConstructorTemplateData(
      TemplateOptions htmlOptions,
      PackageGraph packageGraph,
      this.library,
      this.clazz,
      this.constructor,
      this._sidebarForContainer)
      : super(htmlOptions, packageGraph);

  String get sidebarForContainer => _sidebarForContainer(container, this);

  Container get container => clazz;
  @override
  Constructor get self => constructor;
  @override
  String get layoutTitle => _layoutTitle(
      constructor.name, constructor.fullKind, constructor.isDeprecated);
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  List<Container> get navLinksWithGenerics => [clazz];
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
  EnumTemplateData(
      TemplateOptions htmlOptions,
      PackageGraph packageGraph,
      Library library,
      Enum eNum,
      LibrarySidebar _sidebarForLibrary,
      ContainerSidebar _sidebarForContainer)
      : super(htmlOptions, packageGraph, library, eNum, _sidebarForLibrary,
            _sidebarForContainer);

  Enum get eNum => clazz;
  @override
  Enum get self => eNum;
}

class FunctionTemplateData extends TemplateData<ModelFunction> {
  final ModelFunction function;
  final Library library;
  final LibrarySidebar _sidebarForLibrary;

  FunctionTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.function, this._sidebarForLibrary)
      : super(htmlOptions, packageGraph);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);

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
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '../';
}

class MethodTemplateData extends TemplateData<Method> {
  final Library library;
  final Method method;
  final Container container;
  final ContainerSidebar _sidebarForContainer;

  String containerDesc;

  MethodTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.container, this.method, this._sidebarForContainer)
      : super(htmlOptions, packageGraph) {
    containerDesc = container.isClass ? 'class' : 'extension';
  }

  String get sidebarForContainer => _sidebarForContainer(container, this);

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
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  List<Container> get navLinksWithGenerics => [container];
  @override
  String get htmlBase => '../../';
}

class PropertyTemplateData extends TemplateData<Field> {
  final Library library;
  final Container container;
  final Field property;
  final ContainerSidebar _sidebarForContainer;
  String containerDesc;

  PropertyTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.container, this.property, this._sidebarForContainer)
      : super(htmlOptions, packageGraph) {
    containerDesc = container.isClass ? 'class' : 'extension';
  }

  String get sidebarForContainer => _sidebarForContainer(container, this);

  @override
  Field get self => property;

  @override
  String get title =>
      '${property.name} ${property.kind} - ${container.name} ${containerDesc} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(property.name, property.fullkind, property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} ${property.kind} from the '
      '${container.name} ${containerDesc}, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  List<Container> get navLinksWithGenerics => [container];
  @override
  String get htmlBase => '../../';
}

class TypedefTemplateData extends TemplateData<Typedef> {
  final Library library;
  final Typedef typeDef;
  final LibrarySidebar _sidebarForLibrary;

  TypedefTemplateData(TemplateOptions htmlOptions, PackageGraph packageGraph,
      this.library, this.typeDef, this._sidebarForLibrary)
      : super(htmlOptions, packageGraph);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);

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
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '../';
}

class TopLevelPropertyTemplateData extends TemplateData<TopLevelVariable> {
  final Library library;
  final TopLevelVariable property;
  final LibrarySidebar _sidebarForLibrary;

  TopLevelPropertyTemplateData(
      TemplateOptions htmlOptions,
      PackageGraph packageGraph,
      this.library,
      this.property,
      this._sidebarForLibrary)
      : super(htmlOptions, packageGraph);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);

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
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  String get htmlBase => '../';

  String get _type => property.isConst ? 'constant' : 'property';
}
