// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: analyzer_use_new_elements

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart' show PackageMeta;
import 'package:dartdoc/src/warnings.dart';

class _LibrarySentinel implements Library {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('No members on Library.sentinel are accessible');
}

class Library extends ModelElement
    with Categorization, TopLevelContainer, CanonicalFor {
  @override
  final LibraryElement element;

  /// The set of [Element]s declared directly in this library.
  final Set<Element> _localElements;

  /// The set of [Element]s exported by this library but not directly declared
  /// in this library.
  final Set<Element> _exportedElements;

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
      this._restoredUri, this._localElements, this._exportedElements)
      : super(sentinel, packageGraph);

  factory Library.fromLibraryResult(DartDocResolvedLibrary resolvedLibrary,
      PackageGraph packageGraph, Package package) {
    packageGraph.gatherModelNodes(resolvedLibrary);

    var element = resolvedLibrary.element;

    var localElements = {
      // TODO(jcollins-g): Consider switch to `element.topLevelElements`.
      ..._getDefinedElements(element.definingCompilationUnit),
      ...element.definingCompilationUnit.parts
          .map((e) => e.uri)
          .whereType<DirectiveUriWithUnit>()
          .map((part) => part.unit)
    };
    var exportedElements = {...element.exportNamespace.definedNames.values}
        .difference(localElements);
    var library = Library._(
      element,
      packageGraph,
      package,
      resolvedLibrary.element.source.uri.toString(),
      localElements,
      exportedElements,
    );

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
        ...compilationUnit.extensionTypes,
        ...compilationUnit.functions,
        ...compilationUnit.mixins,
        ...compilationUnit.topLevelVariables,
        ...compilationUnit.typeAliases,
      ];

  /// Allow scope for Libraries.
  @override
  Scope get scope => element.definingCompilationUnit.scope;

  bool get isInSdk => element.isInSdk;

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

  /// Whether this library is considered "public."
  ///
  /// A library is considered public if it:
  /// * is an SDK library and it is documented and it is not internal, or
  /// * is found in a package's top-level 'lib' directory, and
  ///   not found in it's 'lib/src' directory, and it is not excluded.
  bool get isPublic {
    if (!super.isPublic) return false;
    final sdkLib = packageGraph.sdkLibrarySources[element.librarySource];
    if (sdkLib != null && (sdkLib.isInternal || !sdkLib.isDocumented)) {
      return false;
    }
    if (
        // TODO(srawlins): Stop supporting a 'name' here.
        config.isLibraryExcluded(name) ||
            config.isLibraryExcluded(element.librarySource.uri.toString())) {
      return false;
    }
    return true;
  }

  /// Map of each import prefix ('import "foo" as prefix;') to the set of
  /// libraries which are imported via that prefix.
  Map<String, Set<Library>> get _prefixToLibrary {
    var prefixToLibrary = <String, Set<Library>>{};
    // It is possible to have overlapping prefixes.
    for (var i in element.definingCompilationUnit.libraryImports) {
      var prefixName = i.prefix?.element.name;
      // Ignore invalid imports.
      if (prefixName != null && i.importedLibrary != null) {
        prefixToLibrary
            .putIfAbsent(prefixName, () => {})
            .add(getModelFor(i.importedLibrary!, library) as Library);
      }
    }
    return prefixToLibrary;
  }

  /// An identifier for this library based on its location.
  ///
  /// This provides filename collision-proofing for anonymous libraries by
  /// incorporating more from the location of the anonymous library into the
  /// name calculation. Simple cases (such as an anonymous library in 'lib/')
  /// are the same, but this will include slashes and possibly colons
  /// for anonymous libraries in subdirectories or other packages.
  late final String dirName = () {
    String nameFromPath;
    if (isAnonymous) {
      assert(!_restoredUri.startsWith('file:'),
          '"$_restoredUri" must not start with "file:"');
      // Strip the package prefix if the library is part of the default package
      // or if it is being documented remotely.
      var defaultPackage = package.documentedWhere == DocumentLocation.remote
          ? package.packageMeta
          : package.packageGraph.packageMeta;
      var packageNameToHide = defaultPackage.toString().toLowerCase();
      var schemaToHide = 'package:$packageNameToHide/';

      nameFromPath = _restoredUri;
      if (nameFromPath.startsWith(schemaToHide)) {
        nameFromPath = nameFromPath.substring(schemaToHide.length);
      }
      // Remove the trailing `.dart`.
      if (nameFromPath.endsWith('.dart')) {
        const dartExtensionLength = '.dart'.length;
        nameFromPath = nameFromPath.substring(
            0, nameFromPath.length - dartExtensionLength);
      }
    } else {
      nameFromPath = name;
    }
    // Turn `package:foo/bar/baz` into `package-foo_bar_baz`.
    return nameFromPath.replaceAll(':', '-').replaceAll('/', '_');
  }();

  /// Libraries are not enclosed by anything.
  @override
  ModelElement? get enclosingElement => null;

  @override
  String get filePath => '$dirName/$fileName';

  @override
  String get fileName => 'index.html';

  String get sidebarPath => '$dirName/$dirName-library-sidebar.html';

  /// The library template manually includes 'packages' in the left/above
  /// sidebar.
  @override
  String? get aboveSidebarPath => null;

  @override
  String get belowSidebarPath => sidebarPath;

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    // The file name for a library is 'index.html', so we just link to the
    // directory name. This keeps the URL looking short, _without_ the
    // 'index.html' in the URL.
    return '${package.baseHref}$dirName/';
  }

  /// The previous value of [filePath].
  ///
  /// This path is used to write a file that ontains an HTML redirect (not an
  /// HTTP redirect) to a library's current [filePath].
  String get redirectingPath => '$dirName/$dirName-library.html';

  /// Whether a libary is anonymous, either because it has no library directive
  /// or it has a library directive without a name.
  bool get isAnonymous => element.name.isEmpty;

  @override
  Kind get kind => Kind.library;

  @override
  Library get library => this;

  @override
  String get name {
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
  }

  @override
  String get displayName {
    var fullName = breadcrumbName;
    if (fullName.endsWith('.dart')) {
      const dartExtensionLength = '.dart'.length;
      return fullName.substring(0, fullName.length - dartExtensionLength);
    }
    return fullName;
  }

  @override
  String get breadcrumbName {
    var source = element.source;
    if (source.uri.isScheme('dart')) {
      return name;
    }

    return _importPath;
  }

  /// The path portion of this library's import URI as a 'package:' URI.
  String get _importPath {
    // This code should not be used for Dart SDK libraries.
    assert(!element.source.uri.isScheme('dart'));
    var fullName = element.source.fullName;
    if (!pathContext.isWithin(fullName, package.packagePath) &&
        package.packagePath.contains('/google3/')) {
      // In google3, `fullName` is specified as if the root of google3 was `/`.
      // And `package.packagePath` contains the true google3 root.
      var root = pathContext
          .joinAll(pathContext.split(package.packagePath)..removeLast());
      fullName = '$root$fullName';
    }
    var relativePath =
        pathContext.relative(fullName, from: package.packagePath);
    assert(relativePath.startsWith('lib${pathContext.separator}'));
    const libDirectoryLength = 'lib/'.length;
    return relativePath.substring(libDirectoryLength);
  }

  /// The name of the package we were defined in.
  String get packageName => packageMeta?.name ?? '';

  /// The real packageMeta, as opposed to the package we are documenting with.
  late final PackageMeta? packageMeta =
      packageGraph.packageMetaProvider.fromElement(element, config.sdkDir);

  late final List<Class> classesAndExceptions = [
    ..._localElementsOfType<ClassElement, Class>(),
    ..._exportedElementsOfType<ClassElement, Class>(),
  ];

  @override
  Iterable<Class> get classes =>
      classesAndExceptions.where((c) => !c.isErrorOrException);

  @override
  late final Iterable<TopLevelVariable> constants = [
    ..._localVariables.where((v) => v.isConst),
    ..._exportedVariables.where((v) => v.isConst),
  ];

  @override
  late final List<Enum> enums = [
    ..._localElementsOfType<EnumElement, Enum>(),
    ..._exportedElementsOfType<EnumElement, Enum>(),
  ];

  @override
  late final List<Class> exceptions = classesAndExceptions
      .where((c) => c.isErrorOrException)
      .toList(growable: false);

  @override
  late final List<Extension> extensions = [
    ..._localElementsOfType<ExtensionElement, Extension>(),
    ..._exportedElementsOfType<ExtensionElement, Extension>(),
  ];

  @override
  late final List<ExtensionType> extensionTypes = [
    ..._localElementsOfType<ExtensionTypeElement, ExtensionType>(),
    ..._exportedElementsOfType<ExtensionTypeElement, ExtensionType>(),
  ];

  @override
  late final List<ModelFunction> functions = [
    ..._localElementsOfType<FunctionElement, ModelFunction>(),
    ..._exportedElementsOfType<FunctionElement, ModelFunction>(),
  ];

  @override
  late final List<Mixin> mixins = [
    ..._localElementsOfType<MixinElement, Mixin>(),
    ..._exportedElementsOfType<MixinElement, Mixin>(),
  ];

  @override
  late final List<TopLevelVariable> properties = [
    ..._localVariables.where((v) => !v.isConst),
    ..._exportedVariables.where((v) => !v.isConst),
  ];

  @override
  late final List<Typedef> typedefs = [
    ..._localElementsOfType<TypeAliasElement, Typedef>(),
    ..._exportedElementsOfType<TypeAliasElement, Typedef>(),
  ];

  Iterable<U>
      _localElementsOfType<T extends Element, U extends ModelElement>() =>
          _localElements
              .whereType<T>()
              .map((e) => packageGraph.getModelFor(e, this) as U);

  Iterable<U>
      _exportedElementsOfType<T extends Element, U extends ModelElement>() =>
          _exportedElements.whereType<T>().map((e) {
            var library = e.library;
            if (library == null) {
              throw StateError("The library of '$e' is null!");
            }
            return packageGraph.getModelFor(
              e,
              packageGraph.getModelForElement(library) as Library,
            ) as U;
          });

  Iterable<TopLevelVariable> get _localVariables {
    return {
      ..._localElements.whereType<TopLevelVariableElement>(),
      ..._localElements
          .whereType<PropertyAccessorElement>()
          .map((a) => a.variable2! as TopLevelVariableElement),
    }.map(_topLevelVariableFor);
  }

  Iterable<TopLevelVariable> get _exportedVariables {
    return {
      ..._exportedElements.whereType<TopLevelVariableElement>(),
      ..._exportedElements
          .whereType<PropertyAccessorElement>()
          .map((a) => a.variable2! as TopLevelVariableElement),
    }.map(_topLevelVariableFor);
  }

  TopLevelVariable _topLevelVariableFor(TopLevelVariableElement element) {
    Accessor? getter;
    var elementGetter = element.getter;
    if (elementGetter != null) {
      getter = packageGraph.getModelFor(elementGetter, this) as Accessor;
    }
    Accessor? setter;
    var elementSetter = element.setter;
    if (elementSetter != null) {
      setter = packageGraph.getModelFor(elementSetter, this) as Accessor;
    }
    return getModelForPropertyInducingElement(element, this,
        getter: getter, setter: setter) as TopLevelVariable;
  }

  /// All [ModelElement]s, direct and indirect, which are part of this library's
  /// export namespace.
  // Note: Keep this a late final field; converting to a getter (without further
  // investigation) causes dartdoc to hang.
  late final List<ModelElement> allModelElements = [
    ...constants,
    ...functions,
    ...properties,
    ...typedefs,
    ...extensions,
    for (var e in extensions) ...e.allModelElements,
    ...extensionTypes,
    for (var e in extensionTypes) ...e.allModelElements,
    ...classesAndExceptions,
    for (var c in classesAndExceptions) ...c.allModelElements,
    ...enums,
    for (var e in enums) ...e.allModelElements,
    ...mixins,
    for (var m in mixins) ...m.allModelElements,
    this,
  ];

  @override
  Map<String, CommentReferable> get referenceChildren {
    var referenceChildrenBuilder = <String, CommentReferable>{};
    var definedNamesModelElements =
        element.exportNamespace.definedNames.values.map(getModelForElement);
    referenceChildrenBuilder
        .addAll(definedNamesModelElements.whereNotType<Accessor>().asMapByName);
    // TODO(jcollins-g): warn and get rid of this case where it shows up.
    // If a user is hiding parts of a prefix import, the user should not
    // refer to hidden members via the prefix, because that can be
    // ambiguous.  dart-lang/dartdoc#2683.
    for (var MapEntry(key: prefix, value: libraries)
        in _prefixToLibrary.entries) {
      if (prefix == '_' &&
          element.featureSet.isEnabled(Feature.wildcard_variables)) {
        // A wildcard import prefix is non-binding.
        continue;
      }
      referenceChildrenBuilder.putIfAbsent(prefix, () => libraries.first);
    }
    return referenceChildrenBuilder;
  }

  @override
  Iterable<CommentReferable> get referenceParents => [package];

  /// Check [canonicalFor] for correctness and warn if it refers to
  /// non-existent elements (or those that this Library can not be canonical
  /// for).
  @override
  String buildDocumentationAddition(String rawDocs) {
    rawDocs = super.buildDocumentationAddition(rawDocs);
    var elementNames = _allOriginalModelElementNames;
    var notFoundInAllModelElements = {
      for (var elementName in canonicalFor)
        if (!elementNames.contains(elementName)) elementName,
    };
    for (var notFound in notFoundInAllModelElements) {
      warn(PackageWarning.ignoredCanonicalFor, message: notFound);
    }
    // TODO(jcollins-g): warn if a macro/tool generates an unexpected
    // canonicalFor?
    return rawDocs;
  }

  /// The immediate elements of this library, resolved to their original names.
  ///
  /// A collection of [ModelElement.fullyQualifiedName]s for [ModelElement]s
  /// documented with this library, but these ModelElements and names correspond
  /// to the defining library where each originally came from with respect
  /// to inheritance and re-exporting. Only used for reporting
  /// [PackageWarning.ignoredCanonicalFor].
  late final Set<String> _allOriginalModelElementNames = () {
    // Instead of using `allModelElements`, which includes deeper elements like
    // methods on classes, gather up only the library's immediate members.
    var libraryMembers = [
      ...library.extensions,
      ...library.extensionTypes,
      ...library.classesAndExceptions,
      ...library.enums,
      ...library.mixins,
      ...library.constants,
      ...library.functions,
      ...library.properties,
      ...library.typedefs,
    ];
    return libraryMembers.map((member) {
      if (member is! GetterSetterCombo) {
        return getModelForElement(member.element).fullyQualifiedName;
      }
      var getter = switch (member.getter) {
        Accessor accessor => getModelForElement(accessor.element) as Accessor,
        _ => null,
      };
      var setter = switch (member.setter) {
        Accessor accessor => getModelForElement(accessor.element) as Accessor,
        _ => null,
      };
      return getModelForPropertyInducingElement(
        member.element as PropertyInducingElement,
        getModelForElement(member.element.library!) as Library,
        getter: getter,
        setter: setter,
      ).fullyQualifiedName;
    }).toSet();
  }();
}
