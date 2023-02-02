// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/inheritance_manager3.dart'
    show InheritanceManager3;
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show SdkLibrary;
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart' show PackageMeta;
import 'package:dartdoc/src/warnings.dart';

/// Finds all hashable children of a given element that are defined in the
/// [LibraryElement] given at initialization.
// TODO(srawlins): Do we not need to visit the parameters in
// [ConstructorElement], [FunctionElement], [MethodElement],
// [PropertyAccessorElement], [TypeAliasElement]?
class _HashableChildLibraryElementVisitor
    extends RecursiveElementVisitor<void> {
  final DartDocResolvedLibrary resolvedLibrary;
  final PackageGraph packageGraph;

  _HashableChildLibraryElementVisitor(this.resolvedLibrary, this.packageGraph);

  @override
  void visitClassElement(ClassElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
    super.visitClassElement(element);
  }

  @override
  void visitConstructorElement(ConstructorElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitEnumElement(EnumElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
    super.visitEnumElement(element);
  }

  @override
  void visitExtensionElement(ExtensionElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
    super.visitExtensionElement(element);
  }

  @override
  void visitFieldElement(FieldElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitFieldFormalParameterElement(FieldFormalParameterElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitFunctionElement(FunctionElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitLibraryElement(LibraryElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
    super.visitLibraryElement(element);
  }

  @override
  void visitMixinElement(MixinElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
    super.visitMixinElement(element);
  }

  @override
  void visitMultiplyDefinedElement(MultiplyDefinedElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
    super.visitMultiplyDefinedElement(element);
  }

  @override
  void visitMethodElement(MethodElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitParameterElement(ParameterElement element) {
    // [ParameterElement]s without names do not provide sufficiently distinct
    // hashes / comparison, so just skip them all. (dart-lang/sdk#30146)
  }

  @override
  void visitPrefixElement(PrefixElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitPropertyAccessorElement(PropertyAccessorElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitSuperFormalParameterElement(SuperFormalParameterElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitTopLevelVariableElement(TopLevelVariableElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitTypeAliasElement(TypeAliasElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }

  @override
  void visitTypeParameterElement(TypeParameterElement element) {
    packageGraph.populateModelNodeFor(element, resolvedLibrary);
  }
}

class _LibrarySentinel implements Library {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('No members on Library.sentinel are accessible');
}

class Library extends ModelElement with Categorization, TopLevelContainer {
  @override
  final LibraryElement element;

  final Set<Element> _exportedAndLocalElements;
  final String _restoredUri;

  @override
  final Package package;

  /// A [Library] value used as a sentinel in three cases:
  ///
  /// * the library for `dynamic` and `Never`
  /// * the library for type parameters
  /// * the library passed up to [ModelElement.library] when constructing a
  /// `Library`, via the super constructor.
  ///
  /// TODO(srawlins): I think this last case demonstrates that
  /// [ModelElement.library] should not be a field, and instead should be an
  /// abstract getter.
  static final Library sentinel = _LibrarySentinel();

  Library._(this.element, PackageGraph packageGraph, this.package,
      this._restoredUri, this._exportedAndLocalElements)
      : super(sentinel, packageGraph);

  factory Library.fromLibraryResult(DartDocResolvedLibrary resolvedLibrary,
      PackageGraph packageGraph, Package package) {
    var element = resolvedLibrary.element;

    _HashableChildLibraryElementVisitor(resolvedLibrary, packageGraph)
        .visitLibraryElement(element);

    var exportedAndLocalElements = {
      // Initialize the list of elements defined in this library and
      // exported via its export directives.
      ...element.exportNamespace.definedNames.values,
      // TODO(jcollins-g): Consider switch to [_libraryElement.topLevelElements].
      ..._getDefinedElements(element.definingCompilationUnit),
      ...element.parts
          .map((e) => e.uri)
          .whereType<DirectiveUriWithUnit>()
          .map((part) => part.unit)
    };
    var library = Library._(
        element,
        packageGraph,
        package,
        resolvedLibrary.element.source.uri.toString(),
        exportedAndLocalElements);

    package.allLibraries.add(library);
    return library;
  }

  static Iterable<Element> _getDefinedElements(
          CompilationUnitElement compilationUnit) =>
      [
        ...compilationUnit.accessors,
        ...compilationUnit.classes,
        ...compilationUnit.enums,
        ...compilationUnit.extensions,
        ...compilationUnit.functions,
        ...compilationUnit.mixins,
        ...compilationUnit.topLevelVariables,
        ...compilationUnit.typeAliases,
      ];

  /// Allow scope for Libraries.
  @override
  Scope get scope => element.scope;

  bool get isInSdk => element.isInSdk;

  /// [allModelElements] resolved to their original names.
  ///
  /// A collection of [ModelElement.fullyQualifiedName]s for [ModelElement]s
  /// documented with this library, but these ModelElements and names correspond
  /// to the defining library where each originally came from with respect
  /// to inheritance and reexporting.  Most useful for error reporting.
  late final Iterable<String> _allOriginalModelElementNames =
      allModelElements.map((e) {
    if (e is GetterSetterCombo) {
      Accessor? getter;
      Accessor? setter;
      var elementGetter = e.getter;
      if (elementGetter != null) {
        getter = modelBuilder.fromElement(elementGetter.element) as Accessor;
      }
      var elementSetter = e.setter;
      if (elementSetter != null) {
        setter = modelBuilder.fromElement(elementSetter.element) as Accessor;
      }
      return modelBuilder
          .fromPropertyInducingElement(e.element,
              modelBuilder.fromElement(e.element.library!) as Library,
              getter: getter, setter: setter)
          .fullyQualifiedName;
    }
    return modelBuilder.fromElement(e.element).fullyQualifiedName;
  }).toList(growable: false);

  @override
  CharacterLocation? get characterLocation {
    if (element.nameOffset == -1) {
      assert(isAnonymous,
          'Only anonymous libraries are allowed to have no declared location');
      return CharacterLocation(1, 1);
    }
    return super.characterLocation;
  }

  @override
  CompilationUnitElement get compilationUnitElement =>
      element.definingCompilationUnit;

  @override
  Iterable<Class> get classes => allClasses.where((c) => !c.isErrorOrException);

  @override
  late final Iterable<Extension> extensions = _exportedAndLocalElements
      .whereType<ExtensionElement>()
      .map((e) => modelBuilder.from(e, this) as Extension)
      .toList(growable: false);

  SdkLibrary? get _sdkLib =>
      packageGraph.sdkLibrarySources[element.librarySource];

  @Deprecated('Will be removed soon')
  SdkLibrary? get sdkLib => _sdkLib;

  @override
  bool get isPublic {
    if (!super.isPublic) return false;
    final sdkLib = _sdkLib;
    if (sdkLib != null && (sdkLib.isInternal || !sdkLib.isDocumented)) {
      return false;
    }
    if (config.isLibraryExcluded(name) ||
        config.isLibraryExcluded(element.librarySource.uri.toString())) {
      return false;
    }
    return true;
  }

  @override
  Iterable<TopLevelVariable> get constants =>
      _variables.where((v) => v.isConst);

  /// Map of each import prefix ('import "foo" as prefix;') to the set of
  /// libraries which are imported via that prefix.
  late final Map<String, Set<Library>> prefixToLibrary = () {
    var prefixToLibrary = <String, Set<Library>>{};
    // It is possible to have overlapping prefixes.
    for (var i in element.libraryImports) {
      var prefixName = i.prefix?.element.name;
      // Ignore invalid imports.
      if (prefixName != null && i.importedLibrary != null) {
        prefixToLibrary
            .putIfAbsent(prefixName, () => {})
            .add(modelBuilder.from(i.importedLibrary!, library) as Library);
      }
    }
    return prefixToLibrary;
  }();

  late final String dirName = (isAnonymous ? nameFromPath : name)
      .replaceAll(':', '-')
      .replaceAll('/', '_');

  Set<String>? _canonicalFor;

  Set<String> get canonicalFor {
    if (_canonicalFor == null) {
      // TODO(jcollins-g): restructure to avoid using side effects.
      buildDocumentationAddition(documentationComment);
    }
    return _canonicalFor!;
  }

  static final _canonicalRegExp = RegExp(r'{@canonicalFor\s([^}]+)}');

  /// Hides [canonicalFor] from doc while leaving a note to ourselves to
  /// help with ambiguous canonicalization determination.
  ///
  /// Example:
  ///
  ///     {@canonicalFor libname.ClassName}
  @override
  String buildDocumentationAddition(String rawDocs) {
    rawDocs = super.buildDocumentationAddition(rawDocs);
    var newCanonicalFor = <String>{};
    var notFoundInAllModelElements = <String>{};
    rawDocs = rawDocs.replaceAllMapped(_canonicalRegExp, (Match match) {
      var elementName = match.group(1)!;
      newCanonicalFor.add(elementName);
      if (!_allOriginalModelElementNames.contains(elementName)) {
        notFoundInAllModelElements.add(elementName);
      }
      return '';
    });
    for (var notFound in notFoundInAllModelElements) {
      warn(PackageWarning.ignoredCanonicalFor, message: notFound);
    }
    // TODO(jcollins-g): warn if a macro/tool _does_ generate an unexpected
    // canonicalFor?
    _canonicalFor ??= newCanonicalFor;
    return rawDocs;
  }

  /// Libraries are not enclosed by anything.
  @override
  ModelElement? get enclosingElement => null;

  @override
  late final List<Enum> enums = _exportedAndLocalElements
      .whereType<EnumElement>()
      .map((e) => modelBuilder.from(e, this) as Enum)
      .toList(growable: false);

  @override
  late final List<Mixin> mixins = _exportedAndLocalElements
      .whereType<MixinElement>()
      .map((e) => modelBuilder.from(e, this) as Mixin)
      .toList(growable: false);

  @override
  late final List<Class> exceptions =
      allClasses.where((c) => c.isErrorOrException).toList(growable: false);

  @override
  String get fileName => '$dirName-library.$fileType';

  @override
  String get filePath => '${library.dirName}/$fileName';

  @override
  late final List<ModelFunction> functions =
      _exportedAndLocalElements.whereType<FunctionElement>().map((e) {
    return modelBuilder.from(e, this) as ModelFunction;
  }).toList(growable: false);

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    return '${package.baseHref}$filePath';
  }

  // TODO(srawlins): Make a static field, likely on [Class].
  late final InheritanceManager3 inheritanceManager = InheritanceManager3();

  bool get isAnonymous => element.name.isEmpty;

  @override
  String get kind => 'library';

  @override
  Library get library => this;

  @override
  late final String name = () {
    var source = element.source;
    if (source.uri.isScheme('dart')) {
      // There are inconsistencies in library naming + URIs for the Dart
      // SDK libraries; we rationalize them here.
      if (source.uri.toString().contains('/')) {
        return element.name.replaceFirst('dart.', 'dart:');
      }
      return source.uri.toString();
    } else if (element.name.isNotEmpty) {
      // An empty name indicates that the library is "implicitly named" with the
      // empty string. That is, it either has no `library` directive, or it has
      // a `library` directive with no name.
      return element.name;
    }
    var baseName = pathContext.basename(source.fullName);
    if (baseName.endsWith('.dart')) {
      const dartExtensionLength = '.dart'.length;
      return baseName.substring(0, baseName.length - dartExtensionLength);
    }
    return baseName;
  }();

  /// Generate a name for this library based on its location.
  ///
  /// nameFromPath provides filename collision-proofing for anonymous libraries
  /// by incorporating more from the location of the anonymous library into
  /// the name calculation.  Simple cases (such as an anonymous library in
  /// 'lib') are the same, but this will include slashes and possibly colons
  /// for anonymous libraries in subdirectories or other packages.
  late final String nameFromPath =
      _getNameFromPath(element, package, _restoredUri);

  /// The name of the package we were defined in.
  String get packageName => packageMeta?.name ?? '';

  /// The real packageMeta, as opposed to the package we are documenting with.
  late final PackageMeta? packageMeta =
      packageGraph.packageMetaProvider.fromElement(element, config.sdkDir);

  /// All variables ("properties") except constants.
  @override
  late final Iterable<TopLevelVariable> properties =
      _variables.where((v) => !v.isConst).toList(growable: false);

  @override
  late final List<Typedef> typedefs = _exportedAndLocalElements
      .whereType<TypeAliasElement>()
      .map((e) => modelBuilder.from(e, this) as Typedef)
      .toList(growable: false);

  TypeSystem get typeSystem => element.typeSystem;

  late final List<Class> allClasses = _exportedAndLocalElements
      .whereType<ClassElement>()
      .where((e) => e is! EnumElement && e is! MixinElement)
      .map((e) => modelBuilder.from(e, this) as Class)
      .toList(growable: false);

  late final List<TopLevelVariable> _variables = () {
    var elements =
        _exportedAndLocalElements.whereType<TopLevelVariableElement>().toSet();
    elements.addAll(_exportedAndLocalElements
        .whereType<PropertyAccessorElement>()
        .map((a) => a.variable as TopLevelVariableElement));
    var variables = <TopLevelVariable>[];
    for (var element in elements) {
      Accessor? getter;
      var elementGetter = element.getter;
      if (elementGetter != null) {
        getter = modelBuilder.from(elementGetter, this) as Accessor;
      }
      Accessor? setter;
      var elementSetter = element.setter;
      if (elementSetter != null) {
        setter = modelBuilder.from(elementSetter, this) as Accessor;
      }
      var me = modelBuilder.fromPropertyInducingElement(element, this,
          getter: getter, setter: setter);
      variables.add(me as TopLevelVariable);
    }
    return variables;
  }();

  /// Reverses URIs if needed to get a package URI.
  ///
  /// Not the same as [PackageGraph.name] because there we always strip all
  /// path components; this function only strips the package prefix if the
  /// library is part of the default package or if it is being documented
  /// remotely.
  static String _getNameFromPath(
      LibraryElement element, Package package, String restoredUri) {
    assert(!restoredUri.startsWith('file:'),
        '"$restoredUri" must not start with "file:"');
    var hidePackage = package.documentedWhere == DocumentLocation.remote
        ? package.packageMeta
        : package.packageGraph.packageMeta;
    var defaultPackagePrefix = 'package:$hidePackage/';

    var name = restoredUri;
    if (name.startsWith(defaultPackagePrefix)) {
      name = name.substring(defaultPackagePrefix.length, name.length);
    }
    if (name.endsWith('.dart')) {
      name = name.substring(0, name.length - '.dart'.length);
    }
    assert(!name.startsWith('file:'));
    return name;
  }

  /// A mapping of all [Element]s in this library to the [ModelElement]s which
  /// represent them in dartdoc.
  late final HashMap<Element, Set<ModelElement>> modelElementsMap = () {
    var modelElements = HashMap<Element, Set<ModelElement>>();
    for (var modelElement in <ModelElement>[
      ...library.constants,
      ...library.functions,
      ...library.properties,
      ...library.typedefs,
      ...library.extensions.expand((e) => [e, ...e.allModelElements]),
      ...library.allClasses.expand((c) => [c, ...c.allModelElements]),
      ...library.enums.expand((e) => [e, ...e.allModelElements]),
      ...library.mixins.expand((m) => [m, ...m.allModelElements]),
    ]) {
      modelElements
          .putIfAbsent(modelElement.element, () => {})
          .add(modelElement);
    }
    modelElements.putIfAbsent(element, () => {}).add(this);
    return modelElements;
  }();

  Iterable<ModelElement> get allModelElements => [
        for (var modelElements in modelElementsMap.values) ...modelElements,
      ];

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    var referenceChildrenBuilder = <String, CommentReferable>{};
    var definedNamesModelElements = element.exportNamespace.definedNames.values
        .map(modelBuilder.fromElement);
    referenceChildrenBuilder.addEntries(
        definedNamesModelElements.whereNotType<Accessor>().generateEntries());
    // TODO(jcollins-g): warn and get rid of this case where it shows up.
    // If a user is hiding parts of a prefix import, the user should not
    // refer to hidden members via the prefix, because that can be
    // ambiguous.  dart-lang/dartdoc#2683.
    for (var prefixEntry in prefixToLibrary.entries) {
      referenceChildrenBuilder.putIfAbsent(
          prefixEntry.key, () => prefixEntry.value.first);
    }
    return referenceChildrenBuilder;
  }();

  @override
  Iterable<CommentReferable> get referenceParents => [package];
}
