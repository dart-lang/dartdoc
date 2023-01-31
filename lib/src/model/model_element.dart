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
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/model/prefix.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;

// TODO(jcollins-g): Implement resolution per ECMA-408 4th edition, page 39 #22.
/// Resolves this very rare case incorrectly by picking the closest element in
/// the inheritance and interface chains from the analyzer.
ModelElement resolveMultiplyInheritedElement(
    MultiplyInheritedExecutableElement e,
    Library library,
    PackageGraph packageGraph,
    Class enclosingClass) {
  var inheritables = e.inheritedElements
      .map((ee) => ModelElement._fromElement(ee, packageGraph) as Inheritable);
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
  return ModelElement._from(foundInheritable.element, library, packageGraph,
      enclosingContainer: enclosingClass);
}

mixin ModelElementBuilderImpl implements ModelElementBuilder {
  PackageGraph get packageGraph;

  @override
  ModelElement from(Element e, Library library,
          {Container? enclosingContainer}) =>
      ModelElement._from(e, library, packageGraph,
          enclosingContainer: enclosingContainer);

  @override
  ModelElement fromElement(Element e) =>
      ModelElement._fromElement(e, packageGraph);

  @override
  ModelElement fromPropertyInducingElement(Element e, Library l,
          {Container? enclosingContainer,
          Accessor? getter,
          Accessor? setter}) =>
      ModelElement._fromPropertyInducingElement(
          e as PropertyInducingElement, l, packageGraph,
          enclosingContainer: enclosingContainer,
          getter: getter,
          setter: setter);
}

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
        Privacy,
        Warnable,
        Locatable,
        Nameable,
        SourceCodeMixin,
        Indexable,
        FeatureSet,
        DocumentationComment,
        ModelBuilder
    implements Comparable<ModelElement>, Documentable {
  // TODO(jcollins-g): This really wants a "member that has a type" class.
  final Member? _originalMember;
  final Library _library;

  final PackageGraph _packageGraph;

  ModelElement(this._library, this._packageGraph, [this._originalMember]);

  /// Creates a [ModelElement] from [e].
  factory ModelElement._fromElement(Element e, PackageGraph p) {
    if (e is MultiplyDefinedElement) {
      // The code-to-document has static errors. We can pick the first
      // conflicting element and move on.
      e = e.conflictingElements.first;
    }
    var library = p.findButDoNotCreateLibraryFor(e) ?? Library.sentinel;

    if (e is PropertyInducingElement) {
      var elementGetter = e.getter;
      var getter = elementGetter != null
          ? ModelElement._from(elementGetter, library, p)
          : null;
      var elementSetter = e.setter;
      var setter = elementSetter != null
          ? ModelElement._from(elementSetter, library, p)
          : null;
      return ModelElement._fromPropertyInducingElement(e, library, p,
          getter: getter as Accessor?, setter: setter as Accessor?);
    }
    return ModelElement._from(e, library, p);
  }

  /// Creates a [ModelElement] from [PropertyInducingElement] [e].
  ///
  /// Do not construct any ModelElements except from this constructor or
  /// [ModelElement._from]. Specify [enclosingContainer]
  /// if and only if this is to be an inherited or extended object.
  factory ModelElement._fromPropertyInducingElement(
      PropertyInducingElement e, Library library, PackageGraph packageGraph,
      {required Accessor? getter,
      required Accessor? setter,
      Container? enclosingContainer}) {
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      e = e.declaration as PropertyInducingElement;
    }

    // Return the cached ModelElement if it exists.
    var key =
        Tuple3<Element, Library, Container?>(e, library, enclosingContainer);
    var cachedModelElement = packageGraph.allConstructedModelElements[key];
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

  /// Creates a [ModelElement] from a non-property-inducing [e].
  ///
  /// Do not construct any ModelElements except from this constructor or
  /// [ModelElement._fromPropertyInducingElement]. Specify [enclosingContainer]
  /// if and only if this is to be an inherited or extended object.
  // TODO(jcollins-g): this way of using the optional parameter is messy,
  // clean that up.
  // TODO(jcollins-g): Enforce construction restraint.
  // TODO(jcollins-g): Allow e to be null and drop extraneous null checks.
  // TODO(jcollins-g): Auto-vivify element's defining library for library
  // parameter when given a null.
  factory ModelElement._from(
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
    var key =
        Tuple3<Element, Library?, Container?>(e, library, enclosingContainer);
    var cachedModelElement = packageGraph.allConstructedModelElements[key];
    if (cachedModelElement != null) {
      return cachedModelElement;
    }

    var newModelElement = ModelElement._fromParameters(
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
  /// [ModelElement._fromPropertyInducingElement].
  static void _cacheNewModelElement(
      Element e, ModelElement? newModelElement, Library library,
      {Container? enclosingContainer}) {
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    if (library != Library.sentinel && newModelElement is! Parameter) {
      var key =
          Tuple3<Element, Library, Container?>(e, library, enclosingContainer);
      library.packageGraph.allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        var iKey = Tuple2<Element, Library>(e, library);
        library.packageGraph.allInheritableElements
            .putIfAbsent(iKey, () => {})
            .add(newModelElement);
      }
    }
  }

  static ModelElement _fromParameters(
    Element e,
    Library library,
    PackageGraph packageGraph, {
    Container? enclosingContainer,
    Member? originalMember,
  }) {
    if (e is MultiplyInheritedExecutableElement) {
      return resolveMultiplyInheritedElement(
          e, library, packageGraph, enclosingContainer as Class);
    }
    if (e is LibraryElement) {
      return packageGraph.findButDoNotCreateLibraryFor(e)!;
    }
    if (e is PrefixElement) {
      return Prefix(e, library, packageGraph);
    }
    if (e is EnumElement) {
      return Enum(e, library, packageGraph);
    }
    if (e is MixinElement) {
      return Mixin(e, library, packageGraph);
    }
    if (e is ClassElement) {
      return Class(e, library, packageGraph);
    }
    if (e is ExtensionElement) {
      return Extension(e, library, packageGraph);
    }
    if (e is FunctionElement) {
      return ModelFunction(e, library, packageGraph);
    } else if (e is GenericFunctionTypeElement) {
      assert(e.enclosingElement is TypeAliasElement);
      assert(e.enclosingElement!.name != '');
      return ModelFunctionTypedef(e, library, packageGraph);
    }
    if (e is TypeAliasElement) {
      if (e.aliasedType is FunctionType) {
        return FunctionTypedef(e, library, packageGraph);
      }
      if (DartTypeExtension(e.aliasedType).element is InterfaceElement) {
        return ClassTypedef(e, library, packageGraph);
      }
      return GeneralizedTypedef(e, library, packageGraph);
    }
    if (e is ConstructorElement) {
      return Constructor(e, library, packageGraph);
    }
    if (e is MethodElement && e.isOperator) {
      if (enclosingContainer == null) {
        return Operator(e, library, packageGraph);
      } else {
        return Operator.inherited(e, enclosingContainer, library, packageGraph,
            originalMember: originalMember);
      }
    }
    if (e is MethodElement && !e.isOperator) {
      if (enclosingContainer == null) {
        return Method(e, library, packageGraph);
      } else {
        return Method.inherited(e, enclosingContainer, library, packageGraph,
            originalMember: originalMember as ExecutableMember?);
      }
    }
    if (e is PropertyAccessorElement) {
      // Accessors can be part of a [Container], or a part of a [Library].
      if (e.enclosingElement is ExtensionElement ||
          e.enclosingElement is InterfaceElement ||
          e is MultiplyInheritedExecutableElement) {
        if (enclosingContainer == null) {
          return ContainerAccessor(e, library, packageGraph);
        } else {
          assert(e.enclosingElement is! ExtensionElement);
          return ContainerAccessor.inherited(
              e, library, packageGraph, enclosingContainer,
              originalMember: originalMember as ExecutableMember?);
        }
      } else {
        return Accessor(e, library, packageGraph);
      }
    }
    if (e is TypeParameterElement) {
      return TypeParameter(e, library, packageGraph);
    }
    if (e is ParameterElement) {
      return Parameter(e, library, packageGraph,
          originalMember: originalMember as ParameterMember?);
    }
    throw UnimplementedError('Unknown type ${e.runtimeType}');
  }

  ModelElement? get enclosingElement;

  // Stub for mustache, which would otherwise search enclosing elements to find
  // names for members.
  bool get hasCategoryNames => false;

  // Stub for mustache.
  Iterable<Category?> get displayedCategories => const [];

  Set<Library>? get exportedInLibraries {
    return library.packageGraph.libraryElementReexportedBy[element.library!];
  }

  @override
  late final ModelNode? modelNode = packageGraph.getModelNodeFor(element);

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

  bool get hasFeatures => features.isNotEmpty;

  /// The set of attributes or "features" of this element.
  ///
  /// This includes tags applied by Dartdoc for various attributes that should
  /// be called out. See [Feature] for a list.
  Set<Feature> get features {
    return {
      // 'const' and 'static' are not needed here because 'const' and 'static'
      // elements get their own sections in the doc.
      if (isFinal) Feature.finalFeature,
      if (isLate) Feature.lateFeature,
    };
  }

  String get featuresAsString => modelElementRenderer.renderFeatures(this);

  // True if this is a function, or if it is an type alias to a function.
  bool get isCallable =>
      element is FunctionTypedElement ||
      (element is TypeAliasElement &&
          (element as TypeAliasElement).aliasedType is FunctionType);

  // The canonical ModelElement for this ModelElement,
  // or null if there isn't one.
  late final ModelElement? canonicalModelElement = () {
    Container? preferredClass;
    // TODO(srawlins): Add mixin.
    if (enclosingElement is Class ||
        enclosingElement is Enum ||
        enclosingElement is Extension) {
      preferredClass = enclosingElement as Container?;
    }
    return packageGraph.findCanonicalModelElementFor(element,
        preferredClass: preferredClass);
  }();

  bool get hasSourceHref => sourceHref.isNotEmpty;

  late final String sourceHref = SourceLinker.fromElement(this).href();

  Library get definingLibrary =>
      modelBuilder.fromElement(element.library!) as Library;

  @override
  late final Library? canonicalLibrary = () {
    // This is not accurate if we are constructing the Package.
    assert(packageGraph.allLibrariesAdded);
    Library? canonicalLibraryPossibility;

    // Privately named elements can never have a canonical library, so
    // just shortcut them out.
    if (!utils.hasPublicName(element)) {
      canonicalLibraryPossibility = null;
    } else if (!packageGraph.localPublicLibraries.contains(definingLibrary)) {
      canonicalLibraryPossibility = _searchForCanonicalLibrary();
    } else {
      canonicalLibraryPossibility = definingLibrary;
    }
    // Only pretend when not linking to remote packages.
    if (this is Inheritable && !config.linkToRemote) {
      if ((this as Inheritable).isInherited &&
          canonicalLibraryPossibility == null &&
          packageGraph.publicLibraries.contains(library)) {
        // In the event we've inherited a field from an object that isn't
        // directly reexported, we may need to pretend we are canonical for
        // this.
        canonicalLibraryPossibility = library;
      }
    }
    assert(canonicalLibraryPossibility == null ||
        packageGraph.publicLibraries.contains(canonicalLibraryPossibility));
    return canonicalLibraryPossibility;
  }();

  Library? _searchForCanonicalLibrary() {
    var thisAndExported = definingLibrary.exportedInLibraries;

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
      if (lookup is PropertyAccessorElement) {
        lookup = lookup.variable;
      }
      return topLevelElement == lookup;
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

    // Start with our top-level element.
    var warnable = ModelElement._fromElement(topLevelElement, packageGraph);
    // Heuristic scoring to determine which library a human likely
    // considers this element to be primarily 'from', and therefore,
    // canonical.  Still warn if the heuristic isn't that confident.
    var scoredCandidates =
        warnable.scoreCanonicalCandidates(candidateLibraries);
    final librariesByScore = scoredCandidates.map((s) => s.library).toList();
    var secondHighestScore =
        scoredCandidates[scoredCandidates.length - 2].score;
    var highestScore = scoredCandidates.last.score;
    var confidence = highestScore - secondHighestScore;
    final canonicalLibrary = librariesByScore.last;

    if (confidence < config.ambiguousReexportScorerMinConfidence) {
      var libraryNames = librariesByScore.map((l) => l.name);
      var message = '$libraryNames -> ${canonicalLibrary.name} '
          '(confidence ${confidence.toStringAsPrecision(4)})';
      warnable.warn(PackageWarning.ambiguousReexport,
          message: message, extendedDebug: scoredCandidates.map((s) => '$s'));
    }

    return canonicalLibrary;
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

  String get fileName => '$name.$fileType';

  String get fileType => package.fileType;

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
  bool get hasDocumentation => documentation.isNotEmpty == true;

  bool get hasParameters => parameters.isNotEmpty;

  /// If [canonicalLibrary] (or [canonicalEnclosingElement], for [Inheritable]
  /// subclasses) is null, this is null.
  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    var packageBaseHref = package.baseHref;
    return '$packageBaseHref$filePath';
  }

  String get htmlId => name;

  @Deprecated('Will soon only be defined on ModelFunction')
  bool get isAsynchronous =>
      isExecutable && (element as ExecutableElement).isAsynchronous;

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

      var deprecatedValues =
          [getterDeprecated, setterDeprecated].whereNotNull();

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

  @Deprecated('Will soon only be defined on ModelFunction')
  bool get isExecutable => element is ExecutableElement;

  bool get isFinal => false;

  bool get isLate => false;

  @Deprecated('Will be removed in the next release')
  bool get isLocalElement => element is LocalElement;

  @Deprecated('Will be removed in the next release')
  bool get isPropertyAccessor => element is PropertyAccessorElement;

  @Deprecated('Will be removed in the next release')
  bool get isPropertyInducer => element is PropertyInducingElement;

  @Deprecated('Will be removed in the next release')
  bool get isStatic {
    if (isPropertyInducer) {
      return (element as PropertyInducingElement).isStatic;
    }
    return false;
  }

  /// A human-friendly name for the kind of element this is.
  @override
  String get kind;

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
      packageGraph.rendererFactory.modelElementRenderer;

  ParameterRenderer get _parameterRenderer =>
      packageGraph.rendererFactory.parameterRenderer;

  ParameterRenderer get _parameterRendererDetailed =>
      packageGraph.rendererFactory.parameterRendererDetailed;

  SourceCodeRenderer get _sourceCodeRenderer =>
      packageGraph.rendererFactory.sourceCodeRenderer;

  String get linkedParams => _parameterRenderer.renderLinkedParams(parameters);

  String get linkedParamsLines =>
      _parameterRendererDetailed.renderLinkedParams(parameters).trim();

  String? get linkedParamsNoMetadata =>
      _parameterRenderer.renderLinkedParams(parameters, showMetadata: false);

  @Deprecated('Unused, will be removed')
  String get linkedParamsNoMetadataOrNames => _parameterRenderer
      .renderLinkedParams(parameters, showMetadata: false, showNames: false);

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
      params.map(
          (p) => ModelElement._from(p, library, packageGraph) as Parameter),
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
    return modelBuilder.fromElement(element);
  }

  String get linkedObjectType => _packageGraph.dartCoreObject;
}
