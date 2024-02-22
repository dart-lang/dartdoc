// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' show FunctionType;
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart'
    show ExecutableMember, Member, ParameterMember;
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/file_structure.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/prefix.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;

/// This class is the foundation of Dartdoc's model for source code.
///
/// All ModelElements are contained within a [PackageGraph], and laid out in a
/// structure that mirrors the availability of identifiers in the various
/// namespaces within that package.  For example, multiple [Class] objects for a
/// particular identifier ([ModelElement.element]) may show up in different
/// [Library]s as the identifier is reexported.
///
/// However, ModelElements have an additional concept vital to generating
/// documentation: canonicalization.
///
/// A ModelElement is canonical if it is the element in the namespace where that
/// element 'comes from' in the public interface to this [PackageGraph].  That
/// often means the [ModelElement.library] is contained in
/// [PackageGraph.libraries], but there are many exceptions and ambiguities the
/// code tries to address here.
///
/// Non-canonical elements should refer to their canonical counterparts, making
/// it easy to calculate links via [ModelElement.href] without having to know in
/// a particular namespace which elements are canonical or not.  A number of
/// [PackageGraph] methods, such as [PackageGraph.findCanonicalModelElementFor]
/// can help with this.
///
/// When documenting, Dartdoc should only write out files corresponding to
/// canonical instances of ModelElement ([ModelElement.isCanonical]).  This
/// helps prevent subtle bugs as generated output for a non-canonical
/// ModelElement will reference itself as part of the "wrong" [Library] from the
/// public interface perspective.
abstract class ModelElement extends Canonicalization
    with
        CommentReferable,
        Warnable,
        Locatable,
        Nameable,
        SourceCode,
        Indexable,
        FeatureSet,
        DocumentationComment
    implements Comparable<ModelElement>, Documentable, Privacy {
  // TODO(jcollins-g): This really wants a "member that has a type" class.
  final Member? _originalMember;
  final Library _library;

  final PackageGraph _packageGraph;

  ModelElement(this._library, this._packageGraph, [this._originalMember]);

  /// Returns a [ModelElement] for an [Element], which can be a
  /// property-inducing element or not.
  ///
  /// This constructor is used when the caller does not know the element's
  /// library, or whether it is property-inducing.
  factory ModelElement.forElement(Element e, PackageGraph p) {
    if (e is MultiplyDefinedElement) {
      // The code-to-document has static errors. We can pick the first
      // conflicting element and move on.
      e = e.conflictingElements.first;
    }
    var library = p.findButDoNotCreateLibraryFor(e) ?? Library.sentinel;

    if (e is PropertyInducingElement) {
      var elementGetter = e.getter;
      var getter = elementGetter != null
          ? ModelElement.for_(elementGetter, library, p)
          : null;
      var elementSetter = e.setter;
      var setter = elementSetter != null
          ? ModelElement.for_(elementSetter, library, p)
          : null;
      return ModelElement.forPropertyInducingElement(e, library, p,
          getter: getter as Accessor?, setter: setter as Accessor?);
    }
    return ModelElement.for_(e, library, p);
  }

  /// Returns a [ModelElement] for a property-inducing element.
  ///
  /// Do not construct any [ModelElement]s except from this constructor or
  /// [ModelElement.for_]. Specify [enclosingContainer] if and only if this is
  /// to be an inherited or extended object.
  factory ModelElement.forPropertyInducingElement(
    PropertyInducingElement e,
    Library library,
    PackageGraph packageGraph, {
    required Accessor? getter,
    required Accessor? setter,
    Container? enclosingContainer,
  }) {
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      e = e.declaration as PropertyInducingElement;
    }

    // Return the cached ModelElement if it exists.
    var cachedModelElement = packageGraph.allConstructedModelElements[
        ConstructedModelElementsKey(e, library, enclosingContainer)];
    if (cachedModelElement != null) {
      return cachedModelElement;
    }

    ModelElement newModelElement;
    if (e is FieldElement) {
      if (enclosingContainer == null) {
        if (e.isEnumConstant) {
          var constantValue = e.computeConstantValue();
          if (constantValue == null) {
            throw StateError(
                'Enum $e (${e.runtimeType}) does not have a constant value.');
          }
          var constantIndex = constantValue.getField('index');
          if (constantIndex == null) {
            throw StateError(
                'Enum $e (${e.runtimeType}) does not have a constant value.');
          }
          var index = constantIndex.toIntValue()!;
          newModelElement =
              EnumField.forConstant(index, e, library, packageGraph, getter);
        } else if (e.enclosingElement is ExtensionElement) {
          newModelElement = Field(e, library, packageGraph,
              getter as ContainerAccessor?, setter as ContainerAccessor?);
        } else {
          newModelElement = Field(e, library, packageGraph,
              getter as ContainerAccessor?, setter as ContainerAccessor?);
        }
      } else {
        // EnumFields can't be inherited, so this case is simpler.
        // TODO(srawlins): Correct this? Is this dead?
        newModelElement = Field.inherited(
            e, enclosingContainer, library, packageGraph, getter, setter);
      }
    } else if (e is TopLevelVariableElement) {
      assert(getter != null || setter != null);
      newModelElement =
          TopLevelVariable(e, library, packageGraph, getter, setter);
    } else {
      throw UnimplementedError(
          'Unrecognized property inducing element: $e (${e.runtimeType})');
    }

    if (enclosingContainer != null) assert(newModelElement is Inheritable);
    _cacheNewModelElement(e, newModelElement, library,
        enclosingContainer: enclosingContainer);

    assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    return newModelElement;
  }

  /// Returns a [ModelElement] from a non-property-inducing [e].
  ///
  /// Do not construct any ModelElements except from this constructor or
  /// [ModelElement.forPropertyInducingElement]. Specify [enclosingContainer]
  /// if and only if this is to be an inherited or extended object.
  // TODO(jcollins-g): this way of using the optional parameter is messy,
  // clean that up.
  // TODO(jcollins-g): Enforce construction restraint.
  // TODO(jcollins-g): Allow e to be null and drop extraneous null checks.
  // TODO(jcollins-g): Auto-vivify element's defining library for library
  // parameter when given a null.
  factory ModelElement.for_(
      Element e, Library library, PackageGraph packageGraph,
      {Container? enclosingContainer}) {
    assert(library != Library.sentinel ||
        e is ParameterElement ||
        e is TypeParameterElement ||
        e is GenericFunctionTypeElement ||
        e.kind == ElementKind.DYNAMIC ||
        e.kind == ElementKind.NEVER);

    if (e.kind == ElementKind.DYNAMIC) {
      return Dynamic(e, packageGraph);
    }
    if (e.kind == ElementKind.NEVER) {
      return NeverType(e, packageGraph);
    }

    Member? originalMember;
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      originalMember = e;
      e = e.declaration;
    }

    // Return the cached ModelElement if it exists.
    var cachedModelElement = packageGraph.allConstructedModelElements[
        ConstructedModelElementsKey(e, library, enclosingContainer)];
    if (cachedModelElement != null) {
      return cachedModelElement;
    }

    var newModelElement = ModelElement._constructFromElementDeclaration(
      e,
      library,
      packageGraph,
      enclosingContainer: enclosingContainer,
      originalMember: originalMember,
    );

    if (enclosingContainer != null) assert(newModelElement is Inheritable);
    _cacheNewModelElement(e, newModelElement, library,
        enclosingContainer: enclosingContainer);

    assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    return newModelElement;
  }

  /// Caches a newly-created [ModelElement] from [ModelElement._from] or
  /// [ModelElement.forPropertyInducingElement].
  static void _cacheNewModelElement(
      Element e, ModelElement newModelElement, Library library,
      {Container? enclosingContainer}) {
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    assert(enclosingContainer == null || enclosingContainer.library == library,
        '$enclosingContainer.library != $library');
    if (library != Library.sentinel && newModelElement is! Parameter) {
      runtimeStats.incrementAccumulator('modelElementCacheInsertion');
      var key = ConstructedModelElementsKey(e, library, enclosingContainer);
      library.packageGraph.allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        library.packageGraph.allInheritableElements
            .putIfAbsent(InheritableElementsKey(e, library), () => {})
            .add(newModelElement);
      }
    }
  }

  static ModelElement _constructFromElementDeclaration(
    Element e,
    Library library,
    PackageGraph packageGraph, {
    Container? enclosingContainer,
    Member? originalMember,
  }) {
    return switch (e) {
      MultiplyInheritedExecutableElement() => e.resolveMultiplyInheritedElement(
          library, packageGraph, enclosingContainer as Class),
      LibraryElement() => packageGraph.findButDoNotCreateLibraryFor(e)!,
      PrefixElement() => Prefix(e, library, packageGraph),
      EnumElement() => Enum(e, library, packageGraph),
      MixinElement() => Mixin(e, library, packageGraph),
      ClassElement() => Class(e, library, packageGraph),
      ExtensionElement() => Extension(e, library, packageGraph),
      ExtensionTypeElement() => ExtensionType(e, library, packageGraph),
      FunctionElement() => ModelFunction(e, library, packageGraph),
      ConstructorElement() => Constructor(e, library, packageGraph),
      GenericFunctionTypeElement() =>
        ModelFunctionTypedef(e, library, packageGraph),
      TypeAliasElement(aliasedType: FunctionType()) =>
        FunctionTypedef(e, library, packageGraph),
      TypeAliasElement()
          when e.aliasedType.documentableElement is InterfaceElement =>
        ClassTypedef(e, library, packageGraph),
      TypeAliasElement() => GeneralizedTypedef(e, library, packageGraph),
      MethodElement(isOperator: true) => enclosingContainer == null
          ? Operator(e, library, packageGraph)
          : Operator.inherited(e, enclosingContainer, library, packageGraph,
              originalMember: originalMember),
      MethodElement(isOperator: false) => enclosingContainer == null
          ? Method(e, library, packageGraph)
          : Method.inherited(e, enclosingContainer, library, packageGraph,
              originalMember: originalMember as ExecutableMember?),
      ParameterElement() => Parameter(e, library, packageGraph,
          originalMember: originalMember as ParameterMember?),
      PropertyAccessorElement() => _constructFromPropertyAccessor(
          e,
          library,
          packageGraph,
          enclosingContainer: enclosingContainer,
          originalMember: originalMember,
        ),
      TypeParameterElement() => TypeParameter(e, library, packageGraph),
      _ => throw UnimplementedError('Unknown type ${e.runtimeType}'),
    };
  }

  /// Constructs a [ModelElement] from a [PropertyAccessorElement].
  static ModelElement _constructFromPropertyAccessor(
    PropertyAccessorElement e,
    Library library,
    PackageGraph packageGraph, {
    required Container? enclosingContainer,
    required Member? originalMember,
  }) {
    // Accessors can be part of a [Container], or a part of a [Library].
    if (e.enclosingElement is ExtensionElement ||
        e.enclosingElement is InterfaceElement ||
        e is MultiplyInheritedExecutableElement) {
      if (enclosingContainer == null) {
        return ContainerAccessor(e, library, packageGraph);
      }

      assert(e.enclosingElement is! ExtensionElement);
      return ContainerAccessor.inherited(
          e, library, packageGraph, enclosingContainer,
          originalMember: originalMember as ExecutableMember?);
    }

    return Accessor(e, library, packageGraph);
  }

  ModelElement? get enclosingElement;

  // Stub for mustache, which would otherwise search enclosing elements to find
  // names for members.
  bool get hasCategoryNames => false;

  // Stub for mustache.
  Iterable<Category?> get displayedCategories => const [];

  @override
  ModelNode? get modelNode => packageGraph.getModelNodeFor(element);

  /// This element's [Annotation]s.
  ///
  /// Does not include annotations with `null` elements or that are otherwise
  /// supposed to be invisible (like `@pragma`). While `null` elements indicate
  /// invalid code from analyzer's perspective, some are present in `sky_engine`
  /// (`@Native`) so we don't want to crash here.
  late final List<Annotation> annotations = element.metadata
      .whereNot((m) =>
          m.element == null ||
          packageGraph.specialClasses[SpecialClass.pragma]!.element.constructors
              .contains(m.element))
      .map((m) => Annotation(m, library, packageGraph))
      .toList(growable: false);

  @override
  late final bool isPublic = () {
    if (name.isEmpty) {
      return false;
    }
    if (this is! Library &&
        (library == Library.sentinel || !library.isPublic)) {
      return false;
    }
    if (enclosingElement is Class && !(enclosingElement as Class).isPublic) {
      return false;
    }
    // TODO(srawlins): Er, mixin? enum?
    if (enclosingElement is Extension &&
        !(enclosingElement as Extension).isPublic) {
      return false;
    }
    return utils.hasPublicName(element) && !hasNodoc;
  }();

  @override
  late final DartdocOptionContext config =
      DartdocOptionContext.fromContextElement(
          packageGraph.config, library.element, packageGraph.resourceProvider);

  @override
  late final Set<String> locationPieces = element.location
      .toString()
      .split(locationSplitter)
      .where((s) => s.isNotEmpty)
      .toSet();

  bool get hasAttributes => attributes.isNotEmpty;

  /// This element's attributes.
  ///
  /// This includes tags applied by Dartdoc for various attributes that should
  /// be called out. See [Attribute] for a list.
  Set<Attribute> get attributes {
    return {
      // 'const' and 'static' are not needed here because 'const' and 'static'
      // elements get their own sections in the doc.
      if (isFinal) Attribute.final_,
      if (isLate) Attribute.late_,
    };
  }

  String get attributesAsString => modelElementRenderer.renderAttributes(this);

  // True if this is a function, or if it is an type alias to a function.
  bool get isCallable =>
      element is FunctionTypedElement ||
      (element is TypeAliasElement &&
          (element as TypeAliasElement).aliasedType is FunctionType);

  // The canonical ModelElement for this ModelElement,
  // or null if there isn't one.
  late final ModelElement? canonicalModelElement = () {
    final enclosingElement = this.enclosingElement;
    var preferredClass = switch (enclosingElement) {
      // TODO(srawlins): Add mixin.
      Class() => enclosingElement,
      Enum() => enclosingElement,
      Extension() => enclosingElement,
      ExtensionType() => enclosingElement,
      _ => null,
    };
    return packageGraph.findCanonicalModelElementFor(element,
        preferredClass: preferredClass);
  }();

  bool get hasSourceHref => sourceHref.isNotEmpty;

  late final String sourceHref = SourceLinker.fromElement(this).href();

  Library get definingLibrary =>
      getModelForElement(element.library!) as Library;

  late final Library? canonicalLibrary = () {
    if (!utils.hasPublicName(element)) {
      // Privately named elements can never have a canonical library.
      return null;
    }

    // This is not accurate if we are still constructing the Package.
    assert(packageGraph.allLibrariesAdded);

    var definingLibraryIsLocalPublic =
        packageGraph.localPublicLibraries.contains(definingLibrary);
    var possibleCanonicalLibrary = definingLibraryIsLocalPublic
        ? definingLibrary
        : _searchForCanonicalLibrary();

    if (possibleCanonicalLibrary != null) return possibleCanonicalLibrary;

    if (this case Inheritable(isInherited: true)) {
      if (!config.linkToRemote &&
          packageGraph.publicLibraries.contains(library)) {
        // If this is an element inherited from a container that isn't directly
        // reexported, and we're not linking to remote, we can pretend that
        // [library] is canonical.
        return library;
      }
    }

    return null;
  }();

  Library? _searchForCanonicalLibrary() {
    var thisAndExported = packageGraph.libraryExports[definingLibrary.element];
    if (thisAndExported == null) {
      return null;
    }

    // Since we're looking for a library, find the [Element] immediately
    // contained by a [CompilationUnitElement] in the tree.
    var topLevelElement = element;
    while (topLevelElement.enclosingElement is! LibraryElement &&
        topLevelElement.enclosingElement is! CompilationUnitElement &&
        topLevelElement.enclosingElement != null) {
      topLevelElement = topLevelElement.enclosingElement!;
    }

    final candidateLibraries = thisAndExported
        .where((l) =>
            l.isPublic && l.package.documentedWhere != DocumentLocation.missing)
        .where((l) {
      var lookup =
          l.element.exportNamespace.definedNames[topLevelElement.name!];
      return switch (lookup) {
        PropertyAccessorElement() => topLevelElement == lookup.variable,
        _ => topLevelElement == lookup,
      };
    }).toList(growable: true);

    // Avoid claiming canonicalization for elements outside of this element's
    // defining package.
    // TODO(jcollins-g): Make the else block unconditional.
    if (candidateLibraries.isNotEmpty &&
        !candidateLibraries.any((l) => l.package == definingLibrary.package)) {
      warn(PackageWarning.reexportedPrivateApiAcrossPackages,
          message: definingLibrary.package.fullyQualifiedName,
          referredFrom: candidateLibraries);
    } else {
      candidateLibraries
          .removeWhere((l) => l.package != definingLibrary.package);
    }

    if (candidateLibraries.isEmpty) {
      return null;
    }
    if (candidateLibraries.length == 1) {
      return candidateLibraries.single;
    }

    var topLevelModelElement =
        ModelElement.forElement(topLevelElement, packageGraph);
    return topLevelModelElement.calculateCanonicalCandidate(candidateLibraries);
  }

  @override
  bool get isCanonical {
    if (!isPublic) return false;
    if (library != canonicalLibrary) return false;
    // If there's no inheritance to deal with, we're done.
    if (this is! Inheritable) return true;
    final self = this as Inheritable;
    // If we're the defining element, or if the defining element is not in the
    // set of libraries being documented, then this element should be treated as
    // canonical (given `library == canonicalLibrary`).
    return self.enclosingElement == self.canonicalEnclosingContainer;
  }

  /// The documentaion, stripped of its comment syntax, like `///` characters.
  @override
  String get documentation => injectMacros(
      documentationFrom.map((e) => e.documentationLocal).join('<p>'));

  @override
  Element get element;

  @override
  String get location {
    // Call nothing from here that can emit warnings or you'll cause stack
    // overflows.
    var sourceUri = pathContext.toUri(sourceFileName);
    if (characterLocation != null) {
      return '($sourceUri:${characterLocation.toString()})';
    }
    return '($sourceUri)';
  }

  /// The name of the output file in which this element will be primarily
  /// documented.
  @Deprecated('replace with fileStructure.fileName')
  String get fileName => fileStructure.fileName;

  /// The full path of the output file in which this element will be primarily
  /// documented.
  String get filePath;

  /// Returns the fully qualified name.
  ///
  /// For example: 'libraryName.className.methodName'
  @override
  late final String fullyQualifiedName = _buildFullyQualifiedName(this, name);

  late final String _fullyQualifiedNameWithoutLibrary =
      fullyQualifiedName.replaceFirst('${library.fullyQualifiedName}.', '');

  @override
  String get fullyQualifiedNameWithoutLibrary =>
      _fullyQualifiedNameWithoutLibrary;

  @override
  String get sourceFileName => element.source!.fullName;

  @override
  late final CharacterLocation? characterLocation = () {
    final lineInfo = compilationUnitElement.lineInfo;
    late final element = this.element;
    assert(element.nameOffset >= 0,
        'Invalid location data for element: $fullyQualifiedName');
    var nameOffset = element.nameOffset;
    if (nameOffset >= 0) {
      return lineInfo.getLocation(nameOffset);
    }
    return null;
  }();

  CompilationUnitElement get compilationUnitElement =>
      element.thisOrAncestorOfType<CompilationUnitElement>()!;

  bool get hasAnnotations => annotations.isNotEmpty;

  @override
  bool get hasDocumentation => documentation.isNotEmpty;

  bool get hasParameters => parameters.isNotEmpty;

  /// If [canonicalLibrary] (or [canonicalEnclosingElement], for [Inheritable]
  /// subclasses) is null, this is null.
  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary == library);
    var packageBaseHref = package.baseHref;
    return '$packageBaseHref$filePath';
  }

  String get htmlId => name;

  bool get isConst => false;

  bool get isDeprecated {
    // If element.metadata is empty, it might be because this is a property
    // where the metadata belongs to the individual getter/setter
    if (element.metadata.isEmpty && element is PropertyInducingElement) {
      var pie = element as PropertyInducingElement;

      // The getter or the setter might be null – so the stored value may be
      // `true`, `false`, or `null`
      var getterDeprecated = pie.getter?.metadata.any((a) => a.isDeprecated);
      var setterDeprecated = pie.setter?.metadata.any((a) => a.isDeprecated);

      var deprecatedValues = [getterDeprecated, setterDeprecated].nonNulls;

      // At least one of these should be non-null. Otherwise things are weird
      assert(deprecatedValues.isNotEmpty);

      // If there are both a setter and getter, only show the property as
      // deprecated if both are deprecated.
      return deprecatedValues.every((d) => d);
    }
    return element.metadata.any((a) => a.isDeprecated);
  }

  @override
  bool get isDocumented => isCanonical && isPublic;

  /// Whether this element is an enum value.
  bool get isEnumValue => false;

  bool get isFinal => false;

  bool get isLate => false;

  /// A human-friendly name for the kind of element this is.
  @override
  Kind get kind;

  @override
  Library get library => _library;

  late final String linkedName = () {
    // If we're calling this with an empty name, we probably have the wrong
    // element associated with a ModelElement or there's an analysis bug.
    assert(name.isNotEmpty ||
        element.kind == ElementKind.DYNAMIC ||
        element.kind == ElementKind.NEVER ||
        this is ModelFunction);

    if (href == null) {
      if (isPublicAndPackageDocumented) {
        warn(PackageWarning.noCanonicalFound);
      }
      return htmlEscape.convert(name);
    }

    return modelElementRenderer.renderLinkedName(this);
  }();

  @visibleForTesting
  @override
  ModelElementRenderer get modelElementRenderer =>
      const ModelElementRendererHtml();

  ParameterRenderer get _parameterRenderer => const ParameterRendererHtml();

  ParameterRenderer get _parameterRendererDetailed =>
      const ParameterRendererHtmlList();

  SourceCodeRenderer get _sourceCodeRenderer => const SourceCodeRendererHtml();

  String get linkedParams => _parameterRenderer.renderLinkedParams(parameters);

  String get linkedParamsLines =>
      _parameterRendererDetailed.renderLinkedParams(parameters).trim();

  String? get linkedParamsNoMetadata =>
      _parameterRenderer.renderLinkedParams(parameters, showMetadata: false);

  @override
  String get name => element.name!;

  @override
  String get oneLineDoc => elementDocumentation.asOneLiner;

  Member? get originalMember => _originalMember;

  @override
  PackageGraph get packageGraph => _packageGraph;

  @override
  Package get package => library.package;

  bool get isPublicAndPackageDocumented => isPublic && package.isDocumented;

  @override
  p.Context get pathContext => packageGraph.resourceProvider.pathContext;

  // TODO(srawlins): This really smells like it should just be implemented in
  // the subclasses.
  late final List<Parameter> parameters = () {
    final element = this.element;
    if (!isCallable) {
      throw StateError(
          '$element (${element.runtimeType}) cannot have parameters');
    }

    final List<ParameterElement> params;
    if (element is TypeAliasElement) {
      final aliasedType = element.aliasedType;
      if (aliasedType is FunctionType) {
        params = aliasedType.parameters;
      } else {
        return const <Parameter>[];
      }
    } else if (element is ExecutableElement) {
      if (_originalMember != null) {
        assert(_originalMember is ExecutableMember);
        params = (_originalMember as ExecutableMember).parameters;
      } else {
        params = element.parameters;
      }
    } else if (element is FunctionTypedElement) {
      if (_originalMember != null) {
        params = (_originalMember as FunctionTypedElement).parameters;
      } else {
        params = element.parameters;
      }
    } else {
      return const <Parameter>[];
    }

    return List.of(
      params
          .map((p) => ModelElement.for_(p, library, packageGraph) as Parameter),
      growable: false,
    );
  }();

  @override
  late final String sourceCode =
      _sourceCodeRenderer.renderSourceCode(super.sourceCode);

  @override
  int compareTo(Object other) {
    if (other is ModelElement) {
      return name.toLowerCase().compareTo(other.name.toLowerCase());
    } else {
      return 0;
    }
  }

  @override
  String toString() => '$runtimeType $name';

  String _buildFullyQualifiedName(ModelElement e, String fullyQualifiedName) {
    final enclosingElement = e.enclosingElement;
    return enclosingElement == null
        ? fullyQualifiedName
        : _buildFullyQualifiedName(
            enclosingElement, '${enclosingElement.name}.$fullyQualifiedName');
  }

  @internal
  @override
  CommentReferable get definingCommentReferable {
    var element = this.element;
    return getModelForElement(element);
  }

  String get linkedObjectType => _packageGraph.dartCoreObject;

  @override
  late final FileStructure fileStructure = FileStructure.fromDocumentable(this);
}

extension on MultiplyInheritedExecutableElement {
  /// Resolves this very rare case incorrectly by picking the closest element in
  /// the inheritance and interface chains from the analyzer.
  // TODO(jcollins-g): Implement resolution per ECMA-408 4th edition, page 39
  // #22.
  ModelElement resolveMultiplyInheritedElement(
      Library library, PackageGraph packageGraph, Class enclosingClass) {
    var inheritables = inheritedElements
        .map((e) => ModelElement.forElement(e, packageGraph) as Inheritable);
    late Inheritable foundInheritable;
    var lowIndex = enclosingClass.inheritanceChain.length;
    for (var inheritable in inheritables) {
      var index = enclosingClass.inheritanceChain
          .indexOf(inheritable.enclosingElement as InheritingContainer);
      if (index < lowIndex) {
        foundInheritable = inheritable;
        lowIndex = index;
      }
    }
    return ModelElement.for_(foundInheritable.element, library, packageGraph,
        enclosingContainer: enclosingClass);
  }
}
