// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

typedef ContainerSidebar = String Function(
    Container, TemplateDataWithContainer);
typedef LibrarySidebar = String Function(Library, TemplateDataWithLibrary);

/// Shared options for [TemplateData] classes, which can be referenced across
/// template files.
abstract class TemplateOptions {
  String? get relCanonicalPrefix;
  String get toolVersion;
  bool get useBaseHref;
  String get customHeaderContent;
  String get customFooterContent;
  String get customInnerFooterText;
}

abstract class TemplateDataBase {
  final PackageGraph _packageGraph;
  final TemplateOptions htmlOptions;

  TemplateDataBase(this.htmlOptions, this._packageGraph);

  String get title;

  String get layoutTitle;

  String get metaDescription;

  String get version => htmlOptions.toolVersion;

  String? get relCanonicalPrefix => htmlOptions.relCanonicalPrefix;

  bool get useBaseHref => htmlOptions.useBaseHref;

  String get customHeader => htmlOptions.customHeaderContent;

  String get customFooter => htmlOptions.customFooterContent;

  String get customInnerFooter => htmlOptions.customInnerFooterText;

  List<Package> get localPackages => _packageGraph.localPackages;

  Package get defaultPackage => _packageGraph.defaultPackage;

  bool get hasFooterVersion => _packageGraph.hasFooterVersion;

  bool get includeVersion => false;

  List<Documentable> get navLinks;
  List<Container> get navLinksWithGenerics => const [];
  Documentable? get parent {
    if (navLinksWithGenerics.isEmpty) {
      return navLinks.isNotEmpty ? navLinks.last : null;
    }
    return navLinksWithGenerics.last;
  }

  bool get hasHomepage => false;

  String? get homepage => null;

  /// The [Documentable] being documented.
  Documentable get self;

  /// When not using the HTML 'base' tag (default behavior), this represents the
  /// path from this page back to the HTML base.
  ///
  /// See [GeneratorBackendBase.write] for how this text is used in generating
  /// link URLs.
  String get htmlBase;

  String get bareHref => (self.href ?? '').replaceAll(htmlBasePlaceholder, '');
}

/// Implementation for template data which is rendered one directory down from
/// the HTML base.
mixin OneDirectoryDown<T extends Documentable> on TemplateData<T> {
  @override
  String get htmlBase => '../';
}

/// Implementation for template data which is rendered two directories down from
/// the HTML base.
mixin TwoDirectoriesDown<T extends Documentable> on TemplateData<T> {
  @override
  String get htmlBase => '../../';
}

/// A grab bag of data for a template that an element of type [T] can be
/// rendered into.
abstract class TemplateData<T extends Documentable> extends TemplateDataBase {
  TemplateData(super.htmlOptions, super.packageGraph);

  @override
  T get self;

  String _layoutTitle(String name, String kind, {required bool isDeprecated}) =>
      _packageGraph.rendererFactory.templateRenderer
          .composeLayoutTitle(name, kind, isDeprecated);
}

/// A [TemplateData] which contains a library, for rendering the
/// sidebar-for-library.
abstract class TemplateDataWithLibrary<T extends Documentable>
    implements TemplateData<T> {
  Library get library;
}

/// A [TemplateData] which contains a container, for rendering the
/// sidebar-for-container.
abstract class TemplateDataWithContainer<T extends Documentable>
    implements TemplateData<T> {
  Container get container;
}

class PackageTemplateData extends TemplateData<Package> {
  final Package package;
  PackageTemplateData(super.htmlOptions, super.packageGraph, this.package);

  @override
  bool get includeVersion => true;
  @override
  List<Documentable> get navLinks => const [];
  @override
  String get title => '${package.name} - Dart API docs';
  @override
  Package get self => package;
  @override
  String get layoutTitle =>
      _layoutTitle(package.name, package.kind, isDeprecated: false);
  @override
  String get metaDescription =>
      '${package.name} API docs, for the Dart programming language.';

  @override
  bool get hasHomepage => package.hasHomepage;
  @override
  String get homepage => package.homepage;

  /// Empty for packages because they are at the root ('htmlBase' is not
  /// needed).
  @override
  String get htmlBase => '';

  @override
  String get bareHref => '';
}

class PackageTemplateDataForSearch extends PackageTemplateData {
  PackageTemplateDataForSearch(
      super.htmlOptions, super.packageGraph, super.package);

  @override
  List<Documentable> get navLinks => [defaultPackage];

  @override
  String get htmlBase => './';

  @override
  String get layoutTitle => 'Search';

  @override
  bool get hasHomepage => false;
}

class CategoryTemplateData extends TemplateData<Category>
    with OneDirectoryDown {
  final Category category;

  CategoryTemplateData(super.htmlOptions, super.packageGraph, this.category);

  @override
  String get title => '${category.name} ${category.kind} - Dart API';

  @override
  String get layoutTitle =>
      _layoutTitle(category.name, category.kind, isDeprecated: false);

  @override
  String get metaDescription =>
      '${category.name} ${category.kind} docs, for the Dart programming language.';

  @override
  List<Documentable> get navLinks => [category.package];

  @override
  Category get self => category;
}

class LibraryTemplateData extends TemplateData<Library>
    with OneDirectoryDown
    implements TemplateDataWithLibrary<Library> {
  @override
  final Library library;
  final LibrarySidebar _sidebarForLibrary;

  LibraryTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this._sidebarForLibrary);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);
  @override
  String get title => '${library.name} library - Dart API';
  @override
  String get metaDescription =>
      '${library.name} library API docs, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage];

  @override
  String get layoutTitle =>
      _layoutTitle(library.name, 'library', isDeprecated: library.isDeprecated);

  @override
  Library get self => library;
}

/// Template data for Mixin declarations.
class MixinTemplateData extends InheritingContainerTemplateData<Mixin> {
  MixinTemplateData(super.htmlOptions, super.packageGraph, super.library,
      super.mixin, super.sidebarForLibrary, super.sidebarForContainer);

  Mixin get mixin => clazz;

  @override
  Mixin get self => mixin;
}

/// Template data for Dart classes.
class ClassTemplateData extends InheritingContainerTemplateData<Class> {
  ClassTemplateData(super.htmlOptions, super.packageGraph, super.library,
      super.clazz, super.sidebarForLibrary, super.sidebarForContainer);

  @override
  // Mustachio generation requires this unnecessary override.
  // Likely a bug or serious missing feature in Mustachio.
  // ignore: unnecessary_overrides
  Class get clazz => super.clazz;
}

/// Base template data class for [Class], [Enum], and [Mixin].
abstract class InheritingContainerTemplateData<T extends InheritingContainer>
    extends TemplateData<T>
    with OneDirectoryDown
    implements TemplateDataWithLibrary<T>, TemplateDataWithContainer<T> {
  final T clazz;
  @override
  final Library library;
  final LibrarySidebar _sidebarForLibrary;
  final ContainerSidebar _sidebarForContainer;

  InheritingContainerTemplateData(
      super.htmlOptions,
      super.packageGraph,
      this.library,
      this.clazz,
      this._sidebarForLibrary,
      this._sidebarForContainer);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);
  String get sidebarForContainer => _sidebarForContainer(container, this);

  @override
  Container get container => clazz;

  @override
  T get self => clazz;

  @override
  String get title =>
      '${clazz.name} ${clazz.kind} - ${library.name} library - Dart API';
  @override
  String get metaDescription =>
      'API docs for the ${clazz.name} ${clazz.kind} from the '
      '${library.name} library, for the Dart programming language.';

  @override
  String get layoutTitle =>
      _layoutTitle(clazz.nameWithLinkedGenerics, clazz.fullkind,
          isDeprecated: clazz.isDeprecated);
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
}

/// Base template data class for [Extension].
class ExtensionTemplateData<T extends Extension> extends TemplateData<T>
    with OneDirectoryDown
    implements TemplateDataWithLibrary<T>, TemplateDataWithContainer<T> {
  final T extension;
  @override
  final Library library;
  final ContainerSidebar _sidebarForContainer;
  final LibrarySidebar _sidebarForLibrary;

  ExtensionTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this.extension, this._sidebarForLibrary, this._sidebarForContainer);

  String get sidebarForContainer => _sidebarForContainer(container, this);
  String get sidebarForLibrary => _sidebarForLibrary(library, this);

  @override
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
  String get layoutTitle =>
      _layoutTitle(extension.name, extension.kind, isDeprecated: false);
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
}

class ConstructorTemplateData extends TemplateData<Constructor>
    with TwoDirectoriesDown
    implements
        TemplateDataWithLibrary<Constructor>,
        TemplateDataWithContainer<Constructor> {
  @override
  final Library library;
  final Constructable constructable;
  final Constructor constructor;
  final ContainerSidebar _sidebarForContainer;

  ConstructorTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this.constructable, this.constructor, this._sidebarForContainer);

  String get sidebarForContainer => _sidebarForContainer(container, this);

  @override
  Container get container => constructable;
  @override
  Constructor get self => constructor;
  @override
  String get layoutTitle => _layoutTitle(constructor.name, constructor.fullKind,
      isDeprecated: constructor.isDeprecated);
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  List<Container> get navLinksWithGenerics => [constructable];
  @override
  String get title =>
      '${constructor.name} constructor - ${constructable.name} - '
      '${library.name} library - Dart API';
  @override
  String get metaDescription =>
      'API docs for the ${constructor.name} constructor from $constructable '
      'from the ${library.name} library, for the Dart programming language.';
}

class EnumTemplateData extends InheritingContainerTemplateData<Enum> {
  EnumTemplateData(super.htmlOptions, super.packageGraph, super.library,
      super.eNum, super.sidebarForLibrary, super.sidebarForContainer);

  Enum get eNum => clazz;
  @override
  Enum get self => eNum;
}

class FunctionTemplateData extends TemplateData<ModelFunction>
    with OneDirectoryDown
    implements TemplateDataWithLibrary<ModelFunction> {
  final ModelFunction function;
  @override
  final Library library;
  final LibrarySidebar _sidebarForLibrary;

  FunctionTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this.function, this._sidebarForLibrary);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);

  @override
  ModelFunction get self => function;
  @override
  String get title =>
      '${function.name} function - ${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(function.nameWithGenerics, 'function',
      isDeprecated: function.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${function.name} function from the '
      '${library.name} library, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
}

class MethodTemplateData extends TemplateData<Method>
    with TwoDirectoriesDown
    implements
        TemplateDataWithLibrary<Method>,
        TemplateDataWithContainer<Method> {
  @override
  final Library library;
  final Method method;
  @override
  final Container container;
  final ContainerSidebar _sidebarForContainer;

  MethodTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this.container, this.method, this._sidebarForContainer);

  String get sidebarForContainer => _sidebarForContainer(container, this);

  @override
  Method get self => method;
  @override
  String get title =>
      '${method.name} method - ${container.name} ${container.kind} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(method.nameWithGenerics, method.fullkind,
          isDeprecated: method.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${method.name} method from the ${container.name} '
      '${container.kind}, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  List<Container> get navLinksWithGenerics => [container];
}

class PropertyTemplateData extends TemplateData<Field>
    with TwoDirectoriesDown
    implements
        TemplateDataWithLibrary<Field>,
        TemplateDataWithContainer<Field> {
  @override
  final Library library;
  @override
  final Container container;
  final Field property;
  final ContainerSidebar _sidebarForContainer;

  PropertyTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this.container, this.property, this._sidebarForContainer);

  String get sidebarForContainer => _sidebarForContainer(container, this);

  @override
  Field get self => property;

  @override
  String get title => '${property.name} ${property.kind} - '
      '${container.name} ${container.kind} - '
      '${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(property.name, property.fullkind,
      isDeprecated: property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} ${property.kind} from the '
      '${container.name} ${container.kind}, '
      'for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
  @override
  List<Container> get navLinksWithGenerics => [container];
}

class TypedefTemplateData extends TemplateData<Typedef>
    with OneDirectoryDown
    implements TemplateDataWithLibrary<Typedef> {
  @override
  final Library library;
  final Typedef typeDef;
  final LibrarySidebar _sidebarForLibrary;

  TypedefTemplateData(super.htmlOptions, super.packageGraph, this.library,
      this.typeDef, this._sidebarForLibrary);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);

  @override
  Typedef get self => typeDef;

  @override
  String get title =>
      '${typeDef.name} typedef - ${library.name} library - Dart API';
  @override
  String get layoutTitle => _layoutTitle(typeDef.nameWithGenerics, 'typedef',
      isDeprecated: typeDef.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${typeDef.name} typedef from the '
      '${library.name} library, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];
}

class TopLevelPropertyTemplateData extends TemplateData<TopLevelVariable>
    with OneDirectoryDown
    implements TemplateDataWithLibrary<TopLevelVariable> {
  @override
  final Library library;
  final TopLevelVariable property;
  final LibrarySidebar _sidebarForLibrary;

  TopLevelPropertyTemplateData(super.htmlOptions, super.packageGraph,
      this.library, this.property, this._sidebarForLibrary);

  String get sidebarForLibrary => _sidebarForLibrary(library, this);

  @override
  TopLevelVariable get self => property;

  @override
  String get title =>
      '${property.name} $_type - ${library.name} library - Dart API';
  @override
  String get layoutTitle =>
      _layoutTitle(property.name, _type, isDeprecated: property.isDeprecated);
  @override
  String get metaDescription =>
      'API docs for the ${property.name} $_type from the '
      '${library.name} library, for the Dart programming language.';
  @override
  List<Documentable> get navLinks => [_packageGraph.defaultPackage, library];

  String get _type => property.isConst ? 'constant' : 'property';
}
