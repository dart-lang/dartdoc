// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart' show PackageMeta;
import 'package:dartdoc/src/quiver.dart' as quiver;
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;

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
    return null;
  }

  @override
  void visitExportElement(ExportElement element) {
    // [ExportElement]s are not always hashable; skip them.
    return null;
  }

  @override
  void visitImportElement(ImportElement element) {
    // [ImportElement]s are not always hashable; skip them.
    return null;
  }

  @override
  void visitParameterElement(ParameterElement element) {
    // [ParameterElement]s without names do not provide sufficiently distinct
    // hashes / comparison, so just skip them all. (dart-lang/sdk#30146)
    return null;
  }
}

class Library extends ModelElement with Categorization, TopLevelContainer {
  final Set<Element> _exportedAndLocalElements;
  final String _restoredUri;

  @override
  final Package package;

  factory Library(LibraryElement element, PackageGraph packageGraph) {
    return packageGraph.findButDoNotCreateLibraryFor(element);
  }

  Library._(LibraryElement element, PackageGraph packageGraph, this.package,
      this._restoredUri, this._exportedAndLocalElements)
      : super(element, null, packageGraph, null);

  factory Library.fromLibraryResult(DartDocResolvedLibrary resolvedLibrary,
      PackageGraph packageGraph, Package package) {
    var element = resolvedLibrary.result.element;
    if (element == null) throw ArgumentError.notNull('element');

    // Initialize [packageGraph]'s cache of ModelNodes for relevant
    // elements in this library.
    var _compilationUnitMap = <String, CompilationUnit>{};
    _compilationUnitMap.addEntries(resolvedLibrary.result.units
        .map((ResolvedUnitResult u) => MapEntry(u.path, u.unit)));
    _HashableChildLibraryElementVisitor((Element e) =>
            packageGraph.populateModelNodeFor(e, _compilationUnitMap))
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
      compilationUnit.enums,
      compilationUnit.extensions,
      compilationUnit.functions,
      compilationUnit.functionTypeAliases,
      compilationUnit.mixins,
      compilationUnit.topLevelVariables,
      compilationUnit.types,
    ]);
  }

  @Deprecated(
      'Public method intended to be private; will be removed as early as '
      'Dartdoc 1.0.0')
  static Iterable<Element> getDefinedElements(
          CompilationUnitElement compilationUnit) =>
      _getDefinedElements(compilationUnit);

  List<String> __allOriginalModelElementNames;

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
  Iterable<String> get _allOriginalModelElementNames {
    __allOriginalModelElementNames ??= allModelElements.map((e) {
      if (e is GetterSetterCombo) {
        Accessor getter;
        Accessor setter;
        if (e.hasGetter) {
          getter = ModelElement.fromElement(e.getter.element, packageGraph);
        }
        if (e.hasSetter) {
          setter = ModelElement.fromElement(e.setter.element, packageGraph);
        }
        return ModelElement.fromPropertyInducingElement(
                e.element,
                packageGraph.findButDoNotCreateLibraryFor(e.element),
                packageGraph,
                getter: getter,
                setter: setter)
            .fullyQualifiedName;
      }
      return ModelElement.from(
              e.element,
              packageGraph.findButDoNotCreateLibraryFor(e.element),
              packageGraph)
          .fullyQualifiedName;
    }).toList();
    return __allOriginalModelElementNames;
  }

  @Deprecated(
      'Public getter intended to be private; will be removed as early as '
      'Dartdoc 1.0.0')
  Iterable<String> get allOriginalModelElementNames =>
      _allOriginalModelElementNames;

  @override
  CharacterLocation get characterLocation {
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
  LibraryElement get element => super.element;

  /*late final*/ List<Extension> _extensions;

  @override
  Iterable<Extension> get extensions {
    _extensions ??= _exportedAndLocalElements
        .whereType<ExtensionElement>()
        .map((e) => ModelElement.from(e, this, packageGraph) as Extension)
        .toList(growable: false);
    return _extensions;
  }

  SdkLibrary get sdkLib {
    if (packageGraph.sdkLibrarySources.containsKey(element.librarySource)) {
      return packageGraph.sdkLibrarySources[element.librarySource];
    }
    return null;
  }

  @override
  bool get isPublic {
    if (!super.isPublic) return false;
    if (sdkLib != null &&
        (sdkLib.isInternal || !isSdkLibraryDocumented(sdkLib))) {
      return false;
    }
    if (config.isLibraryExcluded(name) ||
        config.isLibraryExcluded(element.librarySource.uri.toString())) {
      return false;
    }
    return true;
  }

  /*late final*/ List<TopLevelVariable> _constants;

  @override
  Iterable<TopLevelVariable> get constants {
    _constants ??=
        _getVariables().where((v) => v.isConst).toList(growable: false);
    return _constants;
  }

  /*late final*/ Set<Library> _packageImportedExportedLibraries;

  /// Returns all libraries either imported by or exported by any public library
  /// this library's package.  (Not [PackageGraph], but sharing a package name).
  ///
  /// Note: will still contain non-public libraries because those can be
  /// imported or exported.
  // TODO(jcollins-g): move this to [Package] once it really knows about
  // more than one package.
  Set<Library> get packageImportedExportedLibraries {
    if (_packageImportedExportedLibraries == null) {
      _packageImportedExportedLibraries = {};
      packageGraph.publicLibraries
          .where((l) => l.packageName == packageName)
          .forEach((l) {
        _packageImportedExportedLibraries.addAll(l.importedExportedLibraries);
      });
    }
    return _packageImportedExportedLibraries;
  }

  /*late final*/ Set<Library> _importedExportedLibraries;

  /// Returns all libraries either imported by or exported by this library,
  /// recursively.
  Set<Library> get importedExportedLibraries {
    if (_importedExportedLibraries == null) {
      _importedExportedLibraries = {};
      var importedExportedLibraryElements = <LibraryElement>{};
      importedExportedLibraryElements.addAll(element.importedLibraries);
      importedExportedLibraryElements.addAll(element.exportedLibraries);
      for (var l in importedExportedLibraryElements) {
        var lib = packageGraph.findButDoNotCreateLibraryFor(l);
        _importedExportedLibraries.add(lib);
        _importedExportedLibraries.addAll(lib.importedExportedLibraries);
      }
    }
    return _importedExportedLibraries;
  }

  /*late final*/ Map<String, Set<Library>> _prefixToLibrary;

  /// Map of import prefixes ('import "foo" as prefix;') to [Library].
  Map<String, Set<Library>> get prefixToLibrary {
    if (_prefixToLibrary == null) {
      _prefixToLibrary = {};
      // It is possible to have overlapping prefixes.
      for (var i in element.imports) {
        // Ignore invalid imports.
        if (i.prefix?.name != null && i.importedLibrary != null) {
          _prefixToLibrary
              .putIfAbsent(i.prefix?.name, () => {})
              .add(ModelElement.from(i.importedLibrary, library, packageGraph));
        }
      }
    }
    return _prefixToLibrary;
  }

  /*late final*/ String _dirName;

  String get dirName {
    if (_dirName == null) {
      _dirName = name;
      if (isAnonymous) {
        _dirName = nameFromPath;
      }
      _dirName = _dirName.replaceAll(':', '-').replaceAll('/', '_');
    }
    return _dirName;
  }

  /*late final*/ Set<String> _canonicalFor;

  Set<String> get canonicalFor {
    if (_canonicalFor == null) {
      // TODO(jcollins-g): restructure to avoid using side effects.
      buildDocumentationAddition(documentationComment);
    }
    return _canonicalFor;
  }

  static final _canonicalRegExp = RegExp(r'{@canonicalFor\s([^}]+)}');

  /// Hide canonicalFor from doc while leaving a note to ourselves to
  /// help with ambiguous canonicalization determination.
  ///
  /// Example:
  ///   {@canonicalFor libname.ClassName}
  @override
  String buildDocumentationAddition(String rawDocs) {
    rawDocs = super.buildDocumentationAddition(rawDocs);
    var newCanonicalFor = <String>{};
    var notFoundInAllModelElements = <String>{};
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
  ModelElement get enclosingElement => null;

  /*late final*/ List<Enum> _enums;

  @override
  List<Enum> get enums {
    _enums ??= _exportedAndLocalElements
        .whereType<ClassElement>()
        .where((element) => element.isEnum)
        .map((e) => ModelElement.from(e, this, packageGraph) as Enum)
        .toList(growable: false);
    return _enums;
  }

  /*late final*/ List<Mixin> _mixins;

  @override
  List<Mixin> get mixins {
    _mixins ??= _exportedAndLocalElements
        .whereType<ClassElement>()
        .where((ClassElement c) => c.isMixin)
        .map((e) => ModelElement.from(e, this, packageGraph) as Mixin)
        .toList(growable: false);
    return _mixins;
  }

  /*late final*/ List<Class> _exceptions;

  @override
  List<Class> get exceptions {
    _exceptions ??=
        allClasses.where((c) => c.isErrorOrException).toList(growable: false);
    return _exceptions;
  }

  @override
  String get fileName => '$dirName-library.$fileType';

  @override
  String get filePath => '${library.dirName}/$fileName';

  List<ModelFunction> _functions;

  @override
  List<ModelFunction> get functions {
    _functions ??=
        _exportedAndLocalElements.whereType<FunctionElement>().map((e) {
      return ModelElement.from(e, this, packageGraph) as ModelFunction;
    }).toList(growable: false);
    return _functions;
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    return '${package.baseHref}$filePath';
  }

  InheritanceManager3 _inheritanceManager;

  // TODO(srawlins): Make a static field, likely on [Class].
  InheritanceManager3 get inheritanceManager {
    _inheritanceManager ??= InheritanceManager3();
    return _inheritanceManager;
  }

  bool get isAnonymous => element.name == null || element.name.isEmpty;

  @override
  String get kind => 'library';

  @override
  Library get library => this;

  /*late final*/ String _name;

  @override
  String get name {
    if (_name == null) {
      var source = element.source;

      if (source.uri.isScheme('dart')) {
        // There are inconsistencies in library naming + URIs for the dart
        // internal libraries; rationalize them here.
        if (source.uri.toString().contains('/')) {
          _name = element.name.replaceFirst('dart.', 'dart:');
        } else {
          _name = source.uri.toString();
        }
      } else if (element.name != null && element.name.isNotEmpty) {
        _name = element.name;
      } else {
        _name = path.basename(source.fullName);
        if (_name.endsWith('.dart')) {
          _name = _name.substring(0, _name.length - '.dart'.length);
        }
      }
    }

    return _name;
  }

  /*late final*/ String _nameFromPath;

  /// Generate a name for this library based on its location.
  ///
  /// nameFromPath provides filename collision-proofing for anonymous libraries
  /// by incorporating more from the location of the anonymous library into
  /// the name calculation.  Simple cases (such as an anonymous library in
  /// 'lib') are the same, but this will include slashes and possibly colons
  /// for anonymous libraries in subdirectories or other packages.
  String get nameFromPath {
    _nameFromPath ??= _getNameFromPath(element, package, _restoredUri);
    return _nameFromPath;
  }

  /// The name of the package we were defined in.
  String get packageName => packageMeta?.name ?? '';

  /// The real packageMeta, as opposed to the package we are documenting with.
  PackageMeta _packageMeta;

  PackageMeta get packageMeta {
    _packageMeta ??= packageGraph.packageMetaProvider.fromElement(
      element,
      config.sdkDir,
    );
    return _packageMeta;
  }

  /*late final*/ List<TopLevelVariable> _properties;

  /// All variables ("properties") except constants.
  @override
  Iterable<TopLevelVariable> get properties {
    _properties ??=
        _getVariables().where((v) => !v.isConst).toList(growable: false);
    return _properties;
  }

  /*late final*/ List<Typedef> _typedefs;

  @override
  List<Typedef> get typedefs {
    _typedefs ??= _exportedAndLocalElements
        .whereType<FunctionTypeAliasElement>()
        .map((e) => ModelElement.from(e, this, packageGraph) as Typedef)
        .toList(growable: false);
    return _typedefs;
  }

  TypeSystem get typeSystem => element.typeSystem;

  List<Class> _classes;

  List<Class> get allClasses {
    _classes ??= _exportedAndLocalElements
        .whereType<ClassElement>()
        .where((e) => !e.isMixin && !e.isEnum)
        .map((e) => ModelElement.from(e, this, packageGraph) as Class)
        .toList(growable: false);
    return _classes;
  }

  Class getClassByName(String name) {
    return allClasses.firstWhere((it) => it.name == name, orElse: () => null);
  }

  /*late final*/ List<TopLevelVariable> _variables;

  List<TopLevelVariable> _getVariables() {
    if (_variables == null) {
      var elements = _exportedAndLocalElements
          .whereType<TopLevelVariableElement>()
          .toSet();
      elements.addAll(_exportedAndLocalElements
          .whereType<PropertyAccessorElement>()
          .map((a) => a.variable));
      _variables = [];
      for (var element in elements) {
        Accessor getter;
        if (element.getter != null) {
          getter = ModelElement.from(element.getter, this, packageGraph);
        }
        Accessor setter;
        if (element.setter != null) {
          setter = ModelElement.from(element.setter, this, packageGraph);
        }
        var me = ModelElement.fromPropertyInducingElement(
            element, this, packageGraph,
            getter: getter, setter: setter);
        _variables.add(me);
      }
    }
    return _variables;
  }

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

  /*late final*/ HashMap<String, Set<ModelElement>> _modelElementsNameMap;

  /// Map of [fullyQualifiedNameWithoutLibrary] to all matching [ModelElement]s
  /// in this library.  Used for code reference lookups.
  HashMap<String, Set<ModelElement>> get modelElementsNameMap {
    if (_modelElementsNameMap == null) {
      _modelElementsNameMap = HashMap<String, Set<ModelElement>>();
      allModelElements.forEach((ModelElement modelElement) {
        // [definingLibrary] may be null if [element] has been imported or
        // exported with a non-normalized URI, like "src//a.dart".
        if (modelElement.definingLibrary == null) return;
        _modelElementsNameMap
            .putIfAbsent(
                modelElement.fullyQualifiedNameWithoutLibrary, () => {})
            .add(modelElement);
      });
    }
    return _modelElementsNameMap;
  }

  /*late final*/ HashMap<Element, Set<ModelElement>> _modelElementsMap;

  HashMap<Element, Set<ModelElement>> get modelElementsMap {
    if (_modelElementsMap == null) {
      var results = quiver.concat(<Iterable<ModelElement>>[
        library.constants,
        library.functions,
        library.properties,
        library.typedefs,
        library.extensions.expand((e) {
          return quiver.concat([
            [e],
            e.allModelElements
          ]);
        }),
        library.allClasses.expand((c) {
          return quiver.concat([
            [c],
            c.allModelElements
          ]);
        }),
        library.enums.expand((e) {
          return quiver.concat([
            [e],
            e.allModelElements
          ]);
        }),
        library.mixins.expand((m) {
          return quiver.concat([
            [m],
            m.allModelElements
          ]);
        }),
      ]);
      _modelElementsMap = HashMap<Element, Set<ModelElement>>();
      results.forEach((modelElement) {
        _modelElementsMap
            .putIfAbsent(modelElement.element, () => {})
            .add(modelElement);
      });
      _modelElementsMap.putIfAbsent(element, () => {}).add(this);
    }
    return _modelElementsMap;
  }

  /*late final*/ List<ModelElement> _allModelElements;

  Iterable<ModelElement> get allModelElements {
    return _allModelElements ??= [
      for (var modelElements in modelElementsMap.values) ...modelElements,
    ];
  }

  /*late final*/ List<ModelElement> _allCanonicalModelElements;

  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }
}
