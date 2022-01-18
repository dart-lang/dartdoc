// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit;
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
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart' show PackageMeta;
import 'package:dartdoc/src/quiver.dart' as quiver;
import 'package:dartdoc/src/warnings.dart';

/// Find all hashable children of a given element that are defined in the
/// [LibraryElement] given at initialization.
class _HashableChildLibraryElementVisitor
    extends GeneralizingElementVisitor<void> {
  final void Function(Element) libraryProcessor;

  _HashableChildLibraryElementVisitor(this.libraryProcessor);

  @override
  void visitElement(Element element) {
    libraryProcessor(element);
    super.visitElement(element);
  }

  @override
  void visitExportElement(ExportElement element) {
    // [ExportElement]s are not always hashable; skip them.
  }

  @override
  void visitImportElement(ImportElement element) {
    // [ImportElement]s are not always hashable; skip them.
  }

  @override
  void visitParameterElement(ParameterElement element) {
    // [ParameterElement]s without names do not provide sufficiently distinct
    // hashes / comparison, so just skip them all. (dart-lang/sdk#30146)
  }
}

class Library extends ModelElement with Categorization, TopLevelContainer {
  final Set<Element> _exportedAndLocalElements;
  final String _restoredUri;

  @override
  final Package package;

  Library._(LibraryElement element, PackageGraph packageGraph, this.package,
      this._restoredUri, this._exportedAndLocalElements)
      : super(element, null, packageGraph);

  factory Library.fromLibraryResult(DartDocResolvedLibrary resolvedLibrary,
      PackageGraph packageGraph, Package package) {
    var element = resolvedLibrary.result.element;

    // Initialize [packageGraph]'s cache of [ModelNode]s for relevant
    // elements in this library.
    var compilationUnitMap = <String, CompilationUnit>{
      for (var unit in resolvedLibrary.result.units) unit.path: unit.unit,
    };
    _HashableChildLibraryElementVisitor((Element e) =>
            packageGraph.populateModelNodeFor(e, compilationUnitMap))
        .visitElement(element);

    var exportedAndLocalElements = {
      // Initialize the list of elements defined in this library and
      // exported via its export directives.
      ...element.exportNamespace.definedNames.values,
      // TODO(jcollins-g): Consider switch to [_libraryElement.topLevelElements].
      ..._getDefinedElements(element.definingCompilationUnit),
      for (var cu in element.parts) ..._getDefinedElements(cu),
    };
    var library = Library._(element, packageGraph, package,
        resolvedLibrary.restoredUri, exportedAndLocalElements);

    package.allLibraries.add(library);
    return library;
  }

  static Iterable<Element> _getDefinedElements(
      CompilationUnitElement compilationUnit) {
    return quiver.concat([
      compilationUnit.accessors,
      compilationUnit.classes,
      compilationUnit.enums,
      compilationUnit.extensions,
      compilationUnit.functions,
      compilationUnit.mixins,
      compilationUnit.topLevelVariables,
      compilationUnit.typeAliases,
    ]);
  }

  /// Allow scope for Libraries.
  @override
  Scope get scope => element.scope;

  /// Return true if this library is in a package configured to be treated as
  /// as using Null safety and itself uses Null safety.
  bool get _allowsNullSafety => element.isNonNullableByDefault;

  /// Return true if this library should be documented as using Null safety.
  /// A library may use Null safety but not documented that way.
  @override
  bool get isNullSafety =>
      config.enableExperiment.contains('non-nullable') && _allowsNullSafety;

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
          .fromPropertyInducingElement(e.element!,
              modelBuilder.fromElement(e.element!.library!) as Library,
              getter: getter, setter: setter)
          .fullyQualifiedName;
    }
    return modelBuilder.fromElement(e.element!).fullyQualifiedName;
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
  LibraryElement get element => super.element as LibraryElement;

  @override
  late final Iterable<Extension> extensions = _exportedAndLocalElements
      .whereType<ExtensionElement>()
      .map((e) => modelBuilder.from(e, this) as Extension)
      .toList(growable: false);

  SdkLibrary? get sdkLib {
    if (packageGraph.sdkLibrarySources.containsKey(element.librarySource)) {
      return packageGraph.sdkLibrarySources[element.librarySource];
    }
    return null;
  }

  @override
  bool get isPublic {
    if (!super.isPublic) return false;
    var sdkLib = this.sdkLib;
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
  late final Iterable<TopLevelVariable> constants =
      _variables.where((v) => v.isConst).toList(growable: false);

  /// Map of import prefixes ('import "foo" as prefix;') to [Library].
  late final Map<String, Set<Library>> prefixToLibrary = () {
    var prefixToLibrary = <String, Set<Library>>{};
    // It is possible to have overlapping prefixes.
    for (var i in element.imports) {
      var prefixName = i.prefix?.name;
      // Ignore invalid imports.
      if (prefixName != null && i.importedLibrary != null) {
        prefixToLibrary
            .putIfAbsent(prefixName, () => {})
            .add(modelBuilder.from(i.importedLibrary!, library) as Library);
      }
    }
    return prefixToLibrary;
  }();

  late final String dirName = () {
    var directoryName = isAnonymous ? nameFromPath : name;
    directoryName = directoryName.replaceAll(':', '-').replaceAll('/', '_');
    return directoryName;
  }();

  Set<String?>? _canonicalFor;

  Set<String?> get canonicalFor {
    if (_canonicalFor == null) {
      // TODO(jcollins-g): restructure to avoid using side effects.
      buildDocumentationAddition(documentationComment);
    }
    return _canonicalFor!;
  }

  static final _canonicalRegExp = RegExp(r'{@canonicalFor\s([^}]+)}');

  /// Hide canonicalFor from doc while leaving a note to ourselves to
  /// help with ambiguous canonicalization determination.
  ///
  /// Example:
  ///   {@canonicalFor libname.ClassName}
  @override
  String buildDocumentationAddition(String? rawDocs) {
    rawDocs = super.buildDocumentationAddition(rawDocs);
    var newCanonicalFor = <String?>{};
    var notFoundInAllModelElements = <String?>{};
    rawDocs = rawDocs.replaceAllMapped(_canonicalRegExp, (Match match) {
      newCanonicalFor.add(match.group(1));
      notFoundInAllModelElements.add(match.group(1));
      return '';
    });
    if (notFoundInAllModelElements.isNotEmpty) {
      notFoundInAllModelElements.removeAll(_allOriginalModelElementNames);
    }
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
      .whereType<ClassElement>()
      .where((element) => element.isEnum)
      .map((e) => modelBuilder.from(e, this) as Enum)
      .toList(growable: false);

  @override
  late final List<Mixin> mixins = _exportedAndLocalElements
      .whereType<ClassElement>()
      .where((ClassElement c) => c.isMixin)
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
      // There are inconsistencies in library naming + URIs for the dart
      // internal libraries; rationalize them here.
      if (source.uri.toString().contains('/')) {
        return element.name.replaceFirst('dart.', 'dart:');
      }
      return source.uri.toString();
    } else if (element.name.isNotEmpty) {
      return element.name;
    }
    var baseName = pathContext.basename(source.fullName);
    if (baseName.endsWith('.dart')) {
      return baseName.substring(0, baseName.length - '.dart'.length);
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
      packageGraph.packageMetaProvider.fromElement(
    element,
    config.sdkDir,
  );

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
      .where((e) => !e.isMixin && !e.isEnum)
      .map((e) => modelBuilder.from(e, this) as Class)
      .toList(growable: false);

  Class? getClassByName(String name) {
    return allClasses.firstWhereOrNull((it) => it.name == name);
  }

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
    var name = restoredUri;
    PackageMeta hidePackage;
    if (package.documentedWhere == DocumentLocation.remote) {
      hidePackage = package.packageMeta;
    } else {
      hidePackage = package.packageGraph.packageMeta;
    }
    // restoreUri must not result in another file URI.
    assert(!name.startsWith('file:'), '"$name" must not start with "file:"');

    var defaultPackagePrefix = 'package:$hidePackage/';
    if (name.startsWith(defaultPackagePrefix)) {
      name = name.substring(defaultPackagePrefix.length, name.length);
    }
    if (name.endsWith('.dart')) {
      name = name.substring(0, name.length - '.dart'.length);
    }
    assert(!name.startsWith('file:'));
    return name;
  }

  late final HashMap<Element, Set<ModelElement>> modelElementsMap = () {
    var modelElements = HashMap<Element, Set<ModelElement>>();
    for (var modelElement in <ModelElement>[
      ...library.constants,
      ...library.functions,
      ...library.properties,
      ...library.typedefs,
      ...library.extensions.expand((e) {
        return [e, ...e.allModelElements];
      }),
      ...library.allClasses.expand((c) {
        return [c, ...c.allModelElements];
      }),
      ...library.enums.expand((e) {
        return [e, ...e.allModelElements];
      }),
      ...library.mixins.expand((m) {
        return [m, ...m.allModelElements];
      }),
    ]) {
      modelElements
          .putIfAbsent(modelElement.element!, () => {})
          .add(modelElement);
    }
    modelElements.putIfAbsent(element, () => {}).add(this);
    return modelElements;
  }();

  late final Iterable<ModelElement> allModelElements = [
    for (var modelElements in modelElementsMap.values) ...modelElements,
  ];

  late final Iterable<ModelElement> allCanonicalModelElements =
      allModelElements.where((e) => e.isCanonical).toList(growable: false);

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    var referenceChildrenBuilder = <String, CommentReferable>{};
    var definedNamesModelElements = element.exportNamespace.definedNames.values
        .map((v) => modelBuilder.fromElement(v));
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
