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
import 'package:dartdoc/src/io_utils.dart';
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

  @Deprecated('Use [modelBuilder.fromElement] instead of this factory.')
  factory Library(LibraryElement element, PackageGraph packageGraph) {
    return packageGraph.modelBuilder.fromElement(element) as Library;
  }

  Library._(LibraryElement element, PackageGraph packageGraph, this.package,
      this._restoredUri, this._exportedAndLocalElements)
      : super(element, null, packageGraph);

  factory Library.fromLibraryResult(DartDocResolvedLibrary resolvedLibrary,
      PackageGraph packageGraph, Package package) {
    var element = resolvedLibrary.result.element;
    if (element == null) throw ArgumentError.notNull('element');

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

  List<String>? __allOriginalModelElementNames;

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
  Iterable<String>? get _allOriginalModelElementNames {
    __allOriginalModelElementNames ??= allModelElements.map((e) {
      if (e is GetterSetterCombo) {
        late Accessor getter;
        late Accessor setter;
        if (e.hasGetter) {
          getter = modelBuilder.fromElement(e.getter!.element!) as Accessor;
        }
        if (e.hasSetter) {
          setter = modelBuilder.fromElement(e.setter!.element!) as Accessor;
        }
        return modelBuilder
            .fromPropertyInducingElement(
                e.element!, modelBuilder.fromElement(e.element!.library!) as Library,
                getter: getter, setter: setter)
            .fullyQualifiedName;
      }
      return modelBuilder.fromElement(e.element!).fullyQualifiedName;
    }).toList();
    return __allOriginalModelElementNames;
  }

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
    if (packageGraph.sdkLibrarySources!.containsKey(element.librarySource)) {
      return packageGraph.sdkLibrarySources![element.librarySource];
    }
    return null;
  }

  @override
  bool get isPublic {
    if (!super.isPublic) return false;
    if (sdkLib != null &&
        (sdkLib!.isInternal || !isSdkLibraryDocumented(sdkLib!))) {
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
        _getVariables().where((v) => v.isConst).toList(growable: false);

  late final Set<Library> _packageImportedExportedLibraries;

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
      packageGraph.publicLibraries!
          .where((l) => l.packageName == packageName)
          .forEach((l) {
        _packageImportedExportedLibraries.addAll(l.importedExportedLibraries);
      });
    }
    return _packageImportedExportedLibraries;
  }

  late final Set<Library> _importedExportedLibraries;

  /// Returns all libraries either imported by or exported by this library,
  /// recursively.
  Set<Library> get importedExportedLibraries {
    if (_importedExportedLibraries == null) {
      _importedExportedLibraries = {};
      var importedExportedLibraryElements = <LibraryElement>{};
      importedExportedLibraryElements.addAll(element.importedLibraries);
      importedExportedLibraryElements.addAll(element.exportedLibraries);
      for (var l in importedExportedLibraryElements) {
        var lib = modelBuilder.fromElement(l) as Library;
        _importedExportedLibraries.add(lib);
        _importedExportedLibraries.addAll(lib.importedExportedLibraries);
      }
    }
    return _importedExportedLibraries;
  }

  late final Map<String, Set<Library>> _prefixToLibrary;

  /// Map of import prefixes ('import "foo" as prefix;') to [Library].
  Map<String, Set<Library>> get prefixToLibrary {
    if (_prefixToLibrary == null) {
      _prefixToLibrary = {};
      // It is possible to have overlapping prefixes.
      for (var i in element.imports) {
        var prefixName = i.prefix?.name;
        // Ignore invalid imports.
        if (prefixName != null && i.importedLibrary != null) {
          _prefixToLibrary
              .putIfAbsent(prefixName, () => {})
              .add(modelBuilder.from(i.importedLibrary!, library) as Library);
        }
      }
    }
    return _prefixToLibrary;
  }

  late final String _dirName;

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

  late final Set<String>? _canonicalFor;

  Set<String> get canonicalFor {
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
      notFoundInAllModelElements.removeAll(_allOriginalModelElementNames!);
    }
    for (var notFound in notFoundInAllModelElements) {
      warn(PackageWarning.ignoredCanonicalFor, message: notFound);
    }
    // TODO(jcollins-g): warn if a macro/tool _does_ generate an unexpected
    // canonicalFor?
    _canonicalFor ??= newCanonicalFor as Set<String>;
    return rawDocs;
  }

  /// Libraries are not enclosed by anything.
  @override
  ModelElement? get enclosingElement => null;

  @override
  late final List<Enum> enums  = _exportedAndLocalElements
        .whereType<ClassElement>()
        .where((element) => element.isEnum)
        .map((e) => modelBuilder.from(e, this) as Enum)
        .toList(growable: false);

  @override
  late final List<Mixin> mixins  =
        _exportedAndLocalElements
        .whereType<ClassElement>()
        .where((ClassElement c) => c.isMixin)
        .map((e) => modelBuilder.from(e, this) as Mixin)
        .toList(growable: false);

  @override
  late final List<Class> exceptions = allClasses.where((c) => c.isErrorOrException).toList(growable: false);

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

  InheritanceManager3? _inheritanceManager;

  // TODO(srawlins): Make a static field, likely on [Class].
  InheritanceManager3? get inheritanceManager {
    _inheritanceManager ??= InheritanceManager3();
    return _inheritanceManager;
  }

  bool get isAnonymous => element.name == null || element.name.isEmpty;

  @override
  String get kind => 'library';

  @override
  Library get library => this;

  late final String _name;

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
        _name = pathContext.basename(source.fullName);
        if (_name.endsWith('.dart')) {
          _name = _name.substring(0, _name.length - '.dart'.length);
        }
      }
    }

    return _name;
  }


  /// Generate a name for this library based on its location.
  ///
  /// nameFromPath provides filename collision-proofing for anonymous libraries
  /// by incorporating more from the location of the anonymous library into
  /// the name calculation.  Simple cases (such as an anonymous library in
  /// 'lib') are the same, but this will include slashes and possibly colons
  /// for anonymous libraries in subdirectories or other packages.
  late final String nameFromPath = _getNameFromPath(element, package, _restoredUri);

  /// The name of the package we were defined in.
  String get packageName => packageMeta?.name ?? '';

  /// The real packageMeta, as opposed to the package we are documenting with.
  PackageMeta? _packageMeta;

  PackageMeta? get packageMeta {
    _packageMeta ??= packageGraph.packageMetaProvider.fromElement(
      element,
      config.sdkDir,
    );
    return _packageMeta;
  }

  /// All variables ("properties") except constants.
  @override
  late final Iterable<TopLevelVariable> properties = _getVariables().where((v) => !v.isConst).toList(growable: false);

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

  late final List<TopLevelVariable> _variables;

  List<TopLevelVariable> _getVariables() {
    if (_variables == null) {
      var elements = _exportedAndLocalElements
          .whereType<TopLevelVariableElement>()
          .toSet();
      elements.addAll(_exportedAndLocalElements
          .whereType<PropertyAccessorElement>()
          .map((a) => a.variable as TopLevelVariableElement));
      _variables = [];
      for (var element in elements) {
        late Accessor getter;
        if (element.getter != null) {
          getter = modelBuilder.from(element.getter!, this) as Accessor;
        }
        late Accessor setter;
        if (element.setter != null) {
          setter = modelBuilder.from(element.setter!, this) as Accessor;
        }
        var me = modelBuilder.fromPropertyInducingElement(element, this,
            getter: getter, setter: setter);
        _variables.add(me as TopLevelVariable);
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

  late final HashMap<Element, Set<ModelElement>> _modelElementsMap;

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
            e.allModelElements!
          ]);
        }),
        library.allClasses.expand((c) {
          return quiver.concat([
            [c],
            c.allModelElements!
          ]);
        }),
        library.enums.expand((e) {
          return quiver.concat([
            [e],
            e.allModelElements!
          ]);
        }),
        library.mixins.expand((m) {
          return quiver.concat([
            [m],
            m.allModelElements!
          ]);
        }),
      ]);
      _modelElementsMap = HashMap<Element, Set<ModelElement>>();
      for (var modelElement in results) {
        _modelElementsMap
            .putIfAbsent(modelElement.element!, () => {})
            .add(modelElement);
      }
      _modelElementsMap.putIfAbsent(element, () => {}).add(this);
    }
    return _modelElementsMap;
  }

  late final Iterable<ModelElement> allModelElements = [
      for (var modelElements in modelElementsMap.values) ...modelElements,
    ];


  late final Iterable<ModelElement> allCanonicalModelElements  =
        allModelElements.where((e) => e.isCanonical).toList();

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      var definedNamesModelElements = element.exportNamespace.definedNames.values
          .map((v) => modelBuilder.fromElement(v));
      _referenceChildren!.addEntries(
          definedNamesModelElements.whereNotType<Accessor>().generateEntries());
      /*
      Map.fromEntries(
          element.exportNamespace.definedNames.entries.expand((entry) sync* {
        var modelElement = ModelElement.fromElement(entry.value, packageGraph);
        if (modelElement is! Accessor) {
          yield MapEntry(
              modelElement.referenceName, modelElement);
        }
      }));
      */
      // TODO(jcollins-g): warn and get rid of this case where it shows up.
      // If a user is hiding parts of a prefix import, the user should not
      // refer to hidden members via the prefix, because that can be
      // ambiguous.  dart-lang/dartdoc#2683.
      for (var prefixEntry in prefixToLibrary.entries) {
        if (!_referenceChildren!.containsKey(prefixEntry.key)) {
          _referenceChildren![prefixEntry.key] = prefixEntry.value.first;
        }
      }
    }
    return _referenceChildren!;
  }

  @override
  Iterable<CommentReferable> get referenceParents => [package];
}
