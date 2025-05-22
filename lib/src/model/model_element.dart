// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library;

import 'dart:collection';
import 'dart:convert';

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart' show FunctionType;
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart'
    show ExecutableMember, FieldMember, Member, ParameterMember;
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/prefix.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/source_linker.dart';
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
abstract class ModelElement
    with
        CommentReferable,
        Warnable,
        Locatable,
        Nameable,
        SourceCode,
        FeatureSet,
        DocumentationComment
    implements Comparable<ModelElement>, Documentable {
  // TODO(jcollins-g): This really wants a "member that has a type" class.
  final Member? _originalMember;
  final Library _library;

  final PackageGraph _packageGraph;

  ModelElement(this._library, this._packageGraph, {Member? originalMember})
      : _originalMember = originalMember;

  /// Returns a [ModelElement] for an [Element2], which can be a
  /// property-inducing element or not.
  ///
  /// This constructor is used when the caller does not know the element's
  /// library, or whether it is property-inducing.
  factory ModelElement.forElement(Element2 e, PackageGraph p) {
    if (e is MultiplyDefinedElement2) {
      // The code-to-document has static errors. We can pick the first
      // conflicting element and move on.
      e = e.conflictingElements2.first;
    }
    var library = p.findButDoNotCreateLibraryFor(e) ?? Library.sentinel;

    if (e is PropertyInducingElement2) {
      var elementGetter = e.getter2;
      var getter = elementGetter != null
          ? ModelElement.for_(elementGetter, library, p) as Accessor
          : null;
      var elementSetter = e.setter2;
      var setter = elementSetter != null
          ? ModelElement.for_(elementSetter, library, p) as Accessor
          : null;

      return ModelElement.forPropertyInducingElement(e, library, p,
          getter: getter, setter: setter);
    }
    return ModelElement.for_(e, library, p);
  }

  /// Returns a [ModelElement] for a property-inducing element.
  ///
  /// Do not construct any [ModelElement]s except from this constructor or
  /// [ModelElement.for_]. Specify [enclosingContainer] if and only if this is
  /// to be an inherited or extended object.
  factory ModelElement.forPropertyInducingElement(
    PropertyInducingElement2 e,
    Library library,
    PackageGraph packageGraph, {
    required Accessor? getter,
    required Accessor? setter,
    Container? enclosingContainer,
  }) {
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      e = e.baseElement as PropertyInducingElement2;
    }

    // Return the cached ModelElement if it exists.
    var cachedModelElement = packageGraph.allConstructedModelElements[
        ConstructedModelElementsKey(e, enclosingContainer)];
    if (cachedModelElement != null) {
      return cachedModelElement;
    }

    ModelElement newModelElement;
    if (e is TopLevelVariableElement2) {
      assert(getter != null || setter != null);
      newModelElement =
          TopLevelVariable(e, library, packageGraph, getter, setter);
    } else if (e is FieldElement2) {
      if (enclosingContainer is Extension) {
        newModelElement = Field(e, library, packageGraph,
            getter as ContainerAccessor?, setter as ContainerAccessor?);
      } else if (enclosingContainer == null) {
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
        } else if (e.enclosingElement2 is ExtensionElement2) {
          newModelElement = Field(e, library, packageGraph,
              getter as ContainerAccessor?, setter as ContainerAccessor?);
        } else {
          newModelElement = Field(e, library, packageGraph,
              getter as ContainerAccessor?, setter as ContainerAccessor?);
        }
      } else {
        // Enum fields and extension getters can't be inherited, so this case is
        // simpler.
        if (e.enclosingElement2 is ExtensionElement2) {
          newModelElement = Field.providedByExtension(
            e,
            enclosingContainer,
            library,
            packageGraph,
            getter as ContainerAccessor?,
            setter as ContainerAccessor?,
          );
        } else {
          newModelElement = Field.inherited(
            e,
            enclosingContainer,
            library,
            packageGraph,
            getter as ContainerAccessor?,
            setter as ContainerAccessor?,
          );
        }
      }
    } else {
      throw UnimplementedError(
          'Unrecognized property inducing element: $e (${e.runtimeType})');
    }

    _cacheNewModelElement(e, newModelElement, library,
        enclosingContainer: enclosingContainer);

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
  factory ModelElement.for_(
      Element2 e, Library library, PackageGraph packageGraph,
      {Container? enclosingContainer}) {
    assert(library != Library.sentinel ||
        e is FormalParameterElement ||
        e is TypeParameterElement2 ||
        e is GenericFunctionTypeElement2 ||
        e.kind == ElementKind.DYNAMIC ||
        e.kind == ElementKind.NEVER);

    Member? originalMember;
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is ExecutableMember) {
      originalMember = e;
      e = e.baseElement;
    } else if (e is FieldMember) {
      originalMember = e;
      e = e.baseElement;
    }

    // Return the cached ModelElement if it exists.
    var key = ConstructedModelElementsKey(e, enclosingContainer);
    var cachedModelElement = packageGraph.allConstructedModelElements[key];
    if (cachedModelElement != null) {
      return cachedModelElement;
    }

    if (e.kind == ElementKind.DYNAMIC) {
      return packageGraph.allConstructedModelElements[key] =
          Dynamic(e, packageGraph);
    }
    if (e.kind == ElementKind.NEVER) {
      return packageGraph.allConstructedModelElements[key] =
          NeverType(e, packageGraph);
    }

    var newModelElement = ModelElement._constructFromElementDeclaration(
      e,
      library,
      packageGraph,
      enclosingContainer: enclosingContainer,
      originalMember: originalMember,
    );

    _cacheNewModelElement(e, newModelElement, library,
        enclosingContainer: enclosingContainer);

    return newModelElement;
  }

  /// Caches a newly-created [ModelElement] from [ModelElement.for_] or
  /// [ModelElement.forPropertyInducingElement].
  static void _cacheNewModelElement(
      Element2 e, ModelElement newModelElement, Library library,
      {Container? enclosingContainer}) {
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    assert(enclosingContainer == null || enclosingContainer.library == library,
        '$enclosingContainer.library != $library');
    if (library != Library.sentinel && newModelElement is! Parameter) {
      runtimeStats.incrementAccumulator('modelElementCacheInsertion');
      var key = ConstructedModelElementsKey(e, enclosingContainer);
      library.packageGraph.allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        library.packageGraph.allInheritableElements
            .putIfAbsent(InheritableElementsKey(e, library), () => {})
            .add(newModelElement);
      }
    }
  }

  static ModelElement _constructFromElementDeclaration(
    Element2 e,
    Library library,
    PackageGraph packageGraph, {
    Container? enclosingContainer,
    Member? originalMember,
  }) {
    return switch (e) {
      LibraryElement2() => packageGraph.findButDoNotCreateLibraryFor(e)!,
      PrefixElement2() => Prefix(e, library, packageGraph),
      EnumElement2() => Enum(e, library, packageGraph),
      MixinElement2() => Mixin(e, library, packageGraph),
      ClassElement2() => Class(e, library, packageGraph),
      ExtensionElement2() => Extension(e, library, packageGraph),
      ExtensionTypeElement2() => ExtensionType(e, library, packageGraph),
      TopLevelFunctionElement() => ModelFunction(e, library, packageGraph),
      ConstructorElement2() => Constructor(e, library, packageGraph),
      GenericFunctionTypeElement2() =>
        ModelFunctionTypedef(e as FunctionTypedElement2, library, packageGraph),
      TypeAliasElement2(aliasedType: FunctionType()) =>
        FunctionTypedef(e, library, packageGraph),
      TypeAliasElement2()
          when e.aliasedType.documentableElement2 is InterfaceElement2 =>
        ClassTypedef(e, library, packageGraph),
      TypeAliasElement2() => GeneralizedTypedef(e, library, packageGraph),
      MethodElement2(isOperator: true) when enclosingContainer == null =>
        Operator(e, library, packageGraph),
      MethodElement2(isOperator: true)
          when e.enclosingElement2 is ExtensionElement2 =>
        Operator.providedByExtension(
            e, enclosingContainer, library, packageGraph),
      MethodElement2(isOperator: true) => Operator.inherited(
          e, enclosingContainer, library, packageGraph,
          originalMember: originalMember),
      MethodElement2(isOperator: false) when enclosingContainer == null =>
        Method(e, library, packageGraph),
      MethodElement2(isOperator: false)
          when e.enclosingElement2 is ExtensionElement2 =>
        Method.providedByExtension(
            e, enclosingContainer, library, packageGraph),
      MethodElement2(isOperator: false) => Method.inherited(
          e, enclosingContainer, library, packageGraph,
          originalMember: originalMember as ExecutableMember?),
      FormalParameterElement() => Parameter(e, library, packageGraph,
          originalMember: originalMember as ParameterMember?),
      PropertyAccessorElement2() => _constructFromPropertyAccessor(
          e,
          library,
          packageGraph,
          enclosingContainer: enclosingContainer,
          originalMember: originalMember,
        ),
      TypeParameterElement2() => TypeParameter(e, library, packageGraph),
      _ => throw UnimplementedError('Unknown type ${e.runtimeType}'),
    };
  }

  /// Constructs a [ModelElement] from a [PropertyAccessorElement2].
  static ModelElement _constructFromPropertyAccessor(
    PropertyAccessorElement2 e,
    Library library,
    PackageGraph packageGraph, {
    required Container? enclosingContainer,
    required Member? originalMember,
  }) {
    // Accessors can be part of a [Container], or a part of a [Library].
    if (e.enclosingElement2 is ExtensionElement2 ||
        e.enclosingElement2 is InterfaceElement2) {
      if (enclosingContainer == null || enclosingContainer is Extension) {
        return ContainerAccessor(e, library, packageGraph, enclosingContainer);
      }

      return ContainerAccessor.inherited(
          e, library, packageGraph, enclosingContainer,
          originalMember: originalMember as ExecutableMember?);
    }

    return Accessor(e, library, packageGraph);
  }

  /// The model element enclosing this one.
  ///
  /// As some examples:
  /// * Instances of some subclasses have no enclosing element, like [Library]
  /// and [Dynamic].
  /// * A [Container] is enclosed by a [Library].
  /// * A [Method] is enclosed by a [Container].
  /// * An [Accessor] is either enclosed by a [Container] or a [Library].
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
  late final List<Annotation> annotations = element.annotations
      .where((m) => m.isVisibleAnnotation)
      .map((m) => Annotation(m, library, packageGraph))
      .toList(growable: false);

  @override
  late final bool isPublic = () {
    if (name.isEmpty) {
      return false;
    }
    if (this is! Library) {
      final canonicalLibrary = this.canonicalLibrary;
      var isLibraryOrCanonicalLibraryPrivate = !library.isPublic &&
          (canonicalLibrary == null || !canonicalLibrary.isPublic);
      if (library == Library.sentinel || isLibraryOrCanonicalLibraryPrivate) {
        return false;
      }
    }
    if (enclosingElement is Class && !(enclosingElement as Class).isPublic) {
      return false;
    }
    // TODO(srawlins): Er, mixin? enum?
    if (enclosingElement is Extension &&
        !(enclosingElement as Extension).isPublic) {
      return false;
    }

    if (element case LibraryElement2(:var identifier, :var firstFragment)) {
      // Private Dart SDK libraries are not public.
      if (identifier.startsWith('dart:_') ||
          identifier.startsWith('dart:nativewrappers/') ||
          'dart:nativewrappers' == identifier) {
        return false;
      }
      // Package-private libraries are not public.
      var elementUri = firstFragment.source.uri;
      if (elementUri.scheme == 'package' &&
          elementUri.pathSegments[1] == 'src') {
        return false;
      }
    }

    if (element.isInternal) {
      return false;
    }
    return !element.hasPrivateName && !hasNodoc;
  }();

  @override
  late final DartdocOptionContext config =
      DartdocOptionContext.fromContextElement(
          packageGraph.config, library.element, packageGraph.resourceProvider);

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

  String get attributesAsString {
    var allAttributes = attributes.toList(growable: false)
      ..sort(byAttributeOrdering);
    return allAttributes
        .map((f) =>
            '<span class="${f.cssClassName}">${f.linkedNameWithParameters}</span>')
        .join();
  }

  /// Whether this is a function, or if it is an type alias to a function.
  bool get isCallable =>
      element is FunctionTypedElement2 ||
      (element is TypeAliasElement2 &&
          (element as TypeAliasElement2).aliasedType is FunctionType);

  /// The canonical ModelElement for this ModelElement, or null if there isn't
  /// one.
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
    return packageGraph.findCanonicalModelElementFor(this,
        preferredClass: preferredClass);
  }();

  bool get hasSourceHref => sourceHref.isNotEmpty;

  late final String sourceHref = SourceLinker.fromElement(this).href();

  Library get canonicalLibraryOrThrow {
    final canonicalLibrary = this.canonicalLibrary;
    if (canonicalLibrary == null) {
      throw StateError(
          "Expected the canonical library of '$fullyQualifiedName' to be non-null.");
    }
    return canonicalLibrary;
  }

  /// A public, documented library which exports this [ModelElement], ideally in
  /// [library]'s package.
  late final Library? canonicalLibrary = () {
    if (element.hasPrivateName) {
      // Privately named elements can never have a canonical library.
      return null;
    }

    // This is not accurate if we are still constructing the Package.
    assert(packageGraph.allLibrariesAdded);

    var definingLibraryIsLocalPublic =
        packageGraph.localPublicLibraries.contains(library);
    var possibleCanonicalLibrary = definingLibraryIsLocalPublic
        ? library
        : canonicalLibraryCandidate(this);

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

  @override
  bool get isCanonical {
    if (!isPublic) return false;
    if (this is Library && library != canonicalLibrary) return false;
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
  Element2 get element;

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
  String get fileName => '$name.html';

  /// The full path of the output file in which this element will be primarily
  /// documented.
  String get filePath => '${canonicalLibraryOrThrow.dirName}/$fileName';

  @override
  String get fullyQualifiedName =>
      this is Library ? name : '${library.name}.$qualifiedName';

  @override
  late final String qualifiedName = () {
    var enclosingElement = this.enclosingElement;

    var result = name;
    while (enclosingElement != null && enclosingElement is! Library) {
      result = '${enclosingElement.name}.$result';
      enclosingElement = enclosingElement.enclosingElement;
    }
    return result;
  }();

  @override
  String get sourceFileName => element.library2!.firstFragment.source.fullName;

  @override
  late final CharacterLocation? characterLocation = () {
    final lineInfo = unitElement.lineInfo;

    final nameOffset = element.firstFragment.nameOffset2;
    assert(nameOffset != null && nameOffset >= 0,
        'Invalid location data, $nameOffset, for element: $fullyQualifiedName');
    if (nameOffset != null && nameOffset >= 0) {
      return lineInfo.getLocation(nameOffset);
    }
    return null;
  }();

  LibraryFragment get unitElement {
    Fragment? fragment = element.firstFragment;
    while (fragment != null) {
      if (fragment is LibraryFragment) return fragment;
      fragment = fragment.enclosingFragment;
    }
    throw StateError('Unable to find enclosing LibraryFragment for $element');
  }

  bool get hasAnnotations => annotations.isNotEmpty;

  @override
  bool get hasDocumentation => documentation.isNotEmpty;

  bool get hasParameters => parameters.isNotEmpty;

  /// If [canonicalLibrary] (or [Inheritable.canonicalEnclosingContainer], for
  /// [Inheritable] subclasses) is `null`, this is `null`.
  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    var packageBaseHref = package.baseHref;
    return '$packageBaseHref$filePath';
  }

  String get htmlId => name;

  bool get isConst => false;

  bool get isDeprecated {
    // If element.metadata is empty, it might be because this is a property
    // where the metadata belongs to the individual getter/setter
    if (element.annotations.isEmpty && element is PropertyInducingElement2) {
      var pie = element as PropertyInducingElement2;

      // The getter or the setter might be null – so the stored value may be
      // `true`, `false`, or `null`
      var getterDeprecated = pie.getter2?.metadata2.hasDeprecated;
      var setterDeprecated = pie.setter2?.metadata2.hasDeprecated;

      var deprecatedValues = [getterDeprecated, setterDeprecated].nonNulls;

      // At least one of these should be non-null. Otherwise things are weird
      assert(deprecatedValues.isNotEmpty);

      // If there are both a setter and getter, only show the property as
      // deprecated if both are deprecated.
      return deprecatedValues.every((d) => d);
    }

    if (element case Annotatable element) {
      return element.metadata2.hasDeprecated;
    }

    return false;
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

  /// The name of this element, wrapped in an HTML link (an `<a>` tag) if [href]
  /// is non-`null`.
  late final String linkedName = () {
    var parts = linkedNameParts;
    return '${parts.tag}${parts.text}${parts.endTag}';
  }();

  ({String tag, String text, String endTag}) get linkedNameParts {
    // If `name` is empty, we probably have the wrong Element association or
    // there's an analyzer issue.
    assert(name.isNotEmpty ||
        element.kind == ElementKind.DYNAMIC ||
        element.kind == ElementKind.NEVER ||
        this is ModelFunction);

    final href = this.href;
    if (href == null) {
      if (isPublicAndPackageDocumented) {
        warn(PackageWarning.noCanonicalFound);
      }
      return (tag: '', text: htmlEscape.convert(name), endTag: '');
    }

    var cssClass = isDeprecated ? ' class="deprecated"' : '';
    return (
      tag: '<a$cssClass href="$href">',
      text: displayName,
      endTag: '</a>'
    );
  }

  ParameterRenderer get _parameterRenderer => const ParameterRendererHtml();

  ParameterRenderer get _parameterRendererDetailed =>
      const ParameterRendererHtmlList();

  /// The list of linked parameters, as inline HTML, including metadata.
  ///
  /// The text does not contain the leading or trailing parentheses.
  String get linkedParams => _parameterRenderer.renderLinkedParams(parameters);

  /// The list of linked parameters, as block HTML, including metadata.
  ///
  /// The text does not contain the leading or trailing parentheses.
  String get linkedParamsLines =>
      _parameterRendererDetailed.renderLinkedParams(parameters).trim();

  /// The list of linked parameters, as inline HTML, without metadata.
  ///
  /// The text does not contain the leading or trailing parentheses.
  String? get linkedParamsNoMetadata =>
      _parameterRenderer.renderLinkedParams(parameters, showMetadata: false);

  @override
  String get name => element.lookupName!;

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
    final e = element;
    if (!isCallable) {
      throw StateError('$e (${e.runtimeType}) cannot have parameters');
    }

    final List<FormalParameterElement> params;
    if (e is TypeAliasElement2) {
      final aliasedType = e.aliasedType;
      if (aliasedType is FunctionType) {
        params = aliasedType.formalParameters;
      } else {
        return const <Parameter>[];
      }
    } else if (e is ExecutableElement2) {
      if (_originalMember != null) {
        assert(_originalMember is ExecutableMember);
        params = (_originalMember as ExecutableMember).formalParameters;
      } else {
        params = e.formalParameters;
      }
    } else if (e is FunctionTypedElement2) {
      if (_originalMember != null) {
        params = (_originalMember as FunctionTypedElement2).formalParameters;
      } else {
        params = e.formalParameters;
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
  late final String sourceCode = const HtmlEscape().convert(super.sourceCode);

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

  @internal
  @override
  CommentReferable get definingCommentReferable {
    return getModelForElement(element);
  }

  String get linkedObjectType => _packageGraph.dartCoreObject;
}

extension on ElementAnnotation {
  /// Whether this annotation should be displayed in documentation.
  ///
  /// At the moment, `pragma` is the only invisible annotation.
  bool get isVisibleAnnotation {
    if (element2 == null) return false;

    if (element2 case ConstructorElement2(:var enclosingElement2)) {
      return !(enclosingElement2.name3 == 'pragma' &&
          enclosingElement2.library2.name3 == 'dart.core');
    }

    return true;
  }
}

extension on Element2 {
  List<ElementAnnotation> get annotations {
    if (this case Annotatable self) {
      return self.metadata2.annotations;
    } else {
      return const [];
    }
  }
}
