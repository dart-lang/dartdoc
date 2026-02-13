// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library;

import 'dart:collection';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' show FunctionType;
import 'package:analyzer/source/line_info.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/prefix.dart';
import 'package:dartdoc/src/model/tag.dart';
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
    with CommentReferable, Warnable, Nameable, SourceCode, DocumentationComment
    implements Comparable<ModelElement>, Documentable {
  /// The [Library] of a model can be `null` in three cases:
  ///
  /// * the library for `dynamic` and `Never`.
  /// * the library for type parameters. <!-- Is this true? -->
  /// * the library passed up to [ModelElement.library] when constructing a
  /// `Library`, via the super constructor.
  ///
  /// TODO(srawlins): I think this last case demonstrates that
  /// [ModelElement.library] should not be a field, and instead should be an
  /// abstract getter.
  @override
  final Library? library;

  // TODO(jcollins-g): This really wants a "member that has a type" class.
  final Element? _originalMember;

  final PackageGraph _packageGraph;

  ModelElement(this.library, this._packageGraph, {Element? originalElement})
      : _originalMember = originalElement {
    assert(!(this is HasLibrary && library == null));
  }

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
    var library = p.findButDoNotCreateLibraryFor(e);

    if (e is PropertyInducingElement) {
      var elementGetter = e.getter;
      var getter = elementGetter != null
          ? ModelElement.for_(elementGetter, library, p) as Accessor
          : null;
      var elementSetter = e.setter;
      var setter = elementSetter != null
          ? ModelElement.for_(elementSetter, library, p) as Accessor
          : null;

      return ModelElement.forPropertyInducingElement(e, library!, p,
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
    PropertyInducingElement e,
    Library library,
    PackageGraph packageGraph, {
    required Accessor? getter,
    required Accessor? setter,
    Container? enclosingContainer,
  }) {
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    e = e.baseElement as PropertyInducingElement;

    // Return the cached ModelElement if it exists.
    var cachedModelElement = packageGraph.allConstructedModelElements[
        ConstructedModelElementsKey(e, enclosingContainer)];
    if (cachedModelElement != null) {
      return cachedModelElement;
    }

    ModelElement newModelElement;
    if (e is TopLevelVariableElement) {
      assert(getter != null || setter != null);
      newModelElement =
          TopLevelVariable(e, library, packageGraph, getter, setter);
    } else if (e is FieldElement) {
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
        } else if (e.enclosingElement is ExtensionElement) {
          newModelElement = Field(e, library, packageGraph,
              getter as ContainerAccessor?, setter as ContainerAccessor?);
        } else {
          newModelElement = Field(e, library, packageGraph,
              getter as ContainerAccessor?, setter as ContainerAccessor?);
        }
      } else {
        // Enum fields and extension getters can't be inherited, so this case is
        // simpler.
        if (e.enclosingElement is ExtensionElement) {
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
      Element e, Library? library, PackageGraph packageGraph,
      {Container? enclosingContainer}) {
    assert(library != null ||
        e is FormalParameterElement ||
        e is TypeParameterElement ||
        e is GenericFunctionTypeElement ||
        e.kind == ElementKind.DYNAMIC ||
        e.kind == ElementKind.NEVER);

    Element? originalMember;
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is ExecutableElement) {
      originalMember = e;
      e = e.baseElement;
    } else if (e is ExecutableElement) {
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
      Element e, ModelElement newModelElement, Library? library,
      {Container? enclosingContainer}) {
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    assert(enclosingContainer == null || enclosingContainer.library == library,
        '$enclosingContainer.library != $library');
    if (library != null && newModelElement is! Parameter) {
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
    Element e,
    Library? library,
    PackageGraph packageGraph, {
    Container? enclosingContainer,
    Element? originalMember,
  }) {
    return switch (e) {
      LibraryElement() => packageGraph.findButDoNotCreateLibraryFor(e)!,
      PrefixElement() => Prefix(e, library!, packageGraph),
      EnumElement() => Enum(e, library!, packageGraph),
      MixinElement() => Mixin(e, library!, packageGraph),
      ClassElement() => Class(e, library!, packageGraph),
      ExtensionElement() => Extension(e, library!, packageGraph),
      ExtensionTypeElement() => ExtensionType(e, library!, packageGraph),
      TopLevelFunctionElement() => ModelFunction(e, library!, packageGraph),
      ConstructorElement() => Constructor(e, library!, packageGraph),
      GenericFunctionTypeElement() =>
        ModelFunctionTypedef(e as FunctionTypedElement, library!, packageGraph),
      TypeAliasElement(aliasedType: FunctionType()) =>
        FunctionTypedef(e, library!, packageGraph),
      TypeAliasElement()
          when e.aliasedType.documentableElement is InterfaceElement =>
        ClassTypedef(e, library!, packageGraph),
      TypeAliasElement() => GeneralizedTypedef(e, library!, packageGraph),
      MethodElement(isOperator: true) when enclosingContainer == null =>
        Operator(e, library!, packageGraph),
      MethodElement(isOperator: true)
          when e.enclosingElement is ExtensionElement =>
        Operator.providedByExtension(
            e, enclosingContainer, library!, packageGraph),
      MethodElement(isOperator: true) => Operator.inherited(
          e, enclosingContainer, library!, packageGraph,
          originalMember: originalMember),
      MethodElement(isOperator: false) when enclosingContainer == null =>
        Method(e, library!, packageGraph),
      MethodElement(isOperator: false)
          when e.enclosingElement is ExtensionElement =>
        Method.providedByExtension(
            e, enclosingContainer, library!, packageGraph),
      MethodElement(isOperator: false) => Method.inherited(
          e, enclosingContainer, library!, packageGraph,
          originalElement: originalMember as ExecutableElement?),
      FormalParameterElement() => Parameter(e, library, packageGraph,
          originalElement: originalMember as FormalParameterElement?),
      PropertyAccessorElement() => _constructFromPropertyAccessor(
          e,
          library!,
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
    required Element? originalMember,
  }) {
    // Accessors can be part of a [Container], or a part of a [Library].
    if (e.enclosingElement is ExtensionElement ||
        e.enclosingElement is InterfaceElement) {
      if (enclosingContainer == null || enclosingContainer is Extension) {
        return ContainerAccessor(e, library, packageGraph, enclosingContainer);
      }

      return ContainerAccessor.inherited(
          e, library, packageGraph, enclosingContainer,
          originalElement: originalMember as ExecutableElement?);
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

  @override
  ModelNode? get modelNode => packageGraph.getModelNodeFor(element);

  /// This element's [Annotation]s.
  ///
  /// Does not include annotations with `null` elements or that are otherwise
  /// supposed to be invisible (like `@pragma`). While `null` elements indicate
  /// invalid code from analyzer's perspective, some are present in `sky_engine`
  /// (`@Native`) so we don't want to crash here.
  late final List<Annotation> annotations = List.unmodifiable([
    if (library case var library?)
      for (var m in element.metadata.annotations)
        if (m.isVisibleAnnotation) Annotation(m, library, packageGraph)
  ]);

  @override
  late final bool isPublic = () {
    if (name.isEmpty) {
      return false;
    }

    var library = this.library;
    if (library == null) return false;
    assert(this is! Library);
    final canonicalLibrary = this.canonicalLibrary;
    var isLibraryAndCanonicalLibraryPrivate = !library.isPublic &&
        (canonicalLibrary == null || !canonicalLibrary.isPublic);
    if (isLibraryAndCanonicalLibraryPrivate) {
      // Both library and canonical-library (if they differ) are private
      // libraries.
      return false;
    }

    switch (enclosingElement) {
      // Remember to add new scope-constructs here.
      case Class(:final isPublic):
      case Extension(:final isPublic):
      case Mixin(:final isPublic):
      case ExtensionType(:final isPublic):
      case Enum(:final isPublic):
        if (!isPublic) return false;
    }

    if (element.nonSynthetic.metadata.hasInternal) return false;

    return !element.hasPrivateName && !hasNodoc;
  }();

  @override
  late final DartdocOptionContext config =
      DartdocOptionContext.fromContextElement(
          packageGraph.config, library!.element, packageGraph.resourceProvider);

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

  /// A list of tags that both apply to this [ModelElement] and make sense to
  /// display in context.
  List<Tag> get tags => const [];

  bool get hasTags => tags.isNotEmpty;

  /// Whether this is a function, or if it is an type alias to a function.
  bool get isCallable =>
      element is FunctionTypedElement ||
      (element is TypeAliasElement &&
          (element as TypeAliasElement).aliasedType is FunctionType);

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

    // If the defining library is local and public, we usually want to stay there
    // unless someone has claimed this element via `@canonicalFor`.
    var definingLibrary = library;
    if (definingLibrary != null &&
        packageGraph.localPublicLibraries.contains(definingLibrary)) {
      if (!packageGraph.libraryExports[definingLibrary.element]!.any((l) =>
          l.canonicalFor.contains(originalFullyQualifiedName) ||
          l.canonicalFor.contains(fullyQualifiedName))) {
        return definingLibrary;
      }
    }

    var possibleCanonicalLibrary = canonicalLibraryCandidate(this);

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

  @override
  String get documentation => injectMacros(
      documentationFrom.map((e) => e.documentationLocal).join('<p>'));

  /// The [ModelElement]s from which we will get documentation.
  ///
  /// Can be more than one if this is a [Field] composing documentation from
  /// multiple [Accessor]s.
  ///
  /// This will walk up the inheritance hierarchy to find docs, if the current
  /// object doesn't have docs for this element.
  List<ModelElement> get documentationFrom => [this];

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
  String get fileName => '$name.html';

  /// The full path of the output file in which this element will be primarily
  /// documented.
  String get filePath => '${canonicalLibraryOrThrow.dirName}/$fileName';

  @override
  String get fullyQualifiedName {
    var library = this.library;
    if (library == null || this is Library) return name;
    return '${library.name}.$qualifiedName';
  }

  /// The fully qualified name of this element, using the name of the library
  /// in which it is defined.
  late final String originalFullyQualifiedName = () {
    var libraryElement = element.library;
    if (libraryElement == null || this is Library) return name;
    var originalLibrary =
        packageGraph.getModelForElement(libraryElement) as Library;
    return '${originalLibrary.name}.$qualifiedName';
  }();

  /// Whether this element is defined in an internal library.
  late final bool isFromInternalLibrary = () {
    var libraryElement = element.library;
    if (libraryElement == null) return false;
    var uri = libraryElement.firstFragment.source.uri;
    if (uri.isScheme('dart')) {
      var segments = uri.pathSegments;
      if (segments case [var firstSegment, ...]
          when firstSegment.startsWith('_') ||
              firstSegment == 'nativewrappers') {
        return true;
      }
    }
    if (uri.isScheme('package')) {
      var segments = uri.pathSegments;
      if (segments.length > 1 && segments[1] == 'src') {
        return true;
      }
    }
    return false;
  }();

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
  String get sourceFileName => element.library!.firstFragment.source.fullName;

  @override
  late final CharacterLocation? characterLocation = () {
    var library = element.library;
    if (library == null) return null;

    // Many nodes are "synthetic" or do not have a "declaration" as their
    // origin. In these cases we calculate an appropriate character location.
    int? nameOffset;
    var lineInfo = library.firstFragment.lineInfo;
    switch ((element, enclosingElement?.element)) {
      case (
          ConstructorElement(isOriginDeclaration: false),
          InterfaceElement enclosingElement
        ):
        nameOffset = enclosingElement.firstFragment.nameOffset;
        lineInfo = enclosingElement.library.firstFragment.lineInfo;
      case ((ConstructorElement element, _)):
        // A "default constructor" is synthesized if a class is declared without
        // any explicit constructors.
        nameOffset = element.firstFragment.nameOffset ??
            element.firstFragment.typeNameOffset;
      case (MethodElement(), EnumElement enclosingElement)
          when element.name == 'toString':
        // The 'toString' method of an enum is synthetic.
        nameOffset = enclosingElement.firstFragment.nameOffset;
        lineInfo = enclosingElement.library.firstFragment.lineInfo;
      case (FieldElement(isOriginGetterSetter: true, :var getter?), _):
        // If a field is synthesized from a getter, use the getter's offset.
        nameOffset = getter.firstFragment.nameOffset;
      case (FieldElement(isOriginGetterSetter: true, :var setter?), _):
        // If a field is synthesized from a setter (and no getter), use the
        // setter's offset.
        nameOffset = setter.firstFragment.nameOffset;
      case (
            PropertyAccessorElement(isOriginDeclaration: false) && var element,
            EnumElement enclosingElement
          )
          // The 'index' and 'values' fields of an enum are synthetic.
          when element.name == 'index' || element.name == 'values':
        nameOffset = enclosingElement.firstFragment.nameOffset;
        lineInfo = enclosingElement.library.firstFragment.lineInfo;
      case (PropertyAccessorElement element, _)
          when !element.isOriginDeclaration:
        nameOffset = element.variable.firstFragment.nameOffset;
      default:
        nameOffset = element.firstFragment.nameOffset;
    }

    // TODO(scheglov): For extension types, or with primary constructors
    // and declaring formal parameters, the field has no declaration, so
    // no name offset.
    // assert(nameOffset != null && nameOffset >= 0,
    //     'Invalid location data, $nameOffset, for element: $fullyQualifiedName');
    if (nameOffset != null && nameOffset >= 0) {
      return lineInfo.getLocation(nameOffset);
    }
    return CharacterLocation(1, 1);
  }();

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
    final canonicalLibrary = this.canonicalLibrary;
    if (canonicalLibrary == null) return null;

    var documentedWhere = canonicalLibrary.package.documentedWhere;
    if (documentedWhere == DocumentLocation.remote) {
      return '${canonicalLibrary.package.baseHref}$filePath';
    }
    if (documentedWhere == DocumentLocation.local) {
      var packageBaseHref = package.baseHref;
      return '$packageBaseHref$filePath';
    }
    // documentedWhere == DocumentLocation.missing
    return null;
  }

  String get htmlId => name;

  bool get isConst => false;

  bool get isDeprecated {
    // If `element.annotations` is empty, it might be because this is a property
    // where the annotations belongs to the individual getter/setter.
    if (element case PropertyInducingElement element
        when element.metadata.annotations.isEmpty) {
      // The getter or the setter might be `null` – so the stored value may be
      // `true`, `false`, or `null`.
      var getterDeprecated = element.getter?.isDeprecatedWithKind('use');
      var setterDeprecated = element.setter?.isDeprecatedWithKind('use');

      var deprecatedValues = [getterDeprecated, setterDeprecated].nonNulls;

      // At least one of these should be non-null. Otherwise things are weird.
      assert(deprecatedValues.isNotEmpty);

      // If there are both a setter and getter, only show the property as
      // deprecated if both are deprecated.
      return deprecatedValues.every((d) => d);
    }

    return element.isDeprecatedWithKind('use');
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

  /// The name of this element, wrapped in an HTML link (an `<a>` tag) if [href]
  /// is non-`null`.
  late final String linkedName = () {
    var parts = linkedNameParts;
    return '${parts.tag}${parts.text}${parts.endTag}';
  }();

  ({String tag, String text, String endTag}) get linkedNameParts {
    // If `name` is empty, we probably have the wrong Element association or
    // there's an analyzer issue.
    assert(
        name.isNotEmpty ||
            element.kind == ElementKind.DYNAMIC ||
            element.kind == ElementKind.NEVER ||
            this is ModelFunction,
        'in $this.linkedNameParts(kind: ${element.kind}, name: "$name")');

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
  String get name => element.lookupName ?? '';

  Element? get originalMember => _originalMember;

  @override
  PackageGraph get packageGraph => _packageGraph;

  @override
  Package get package => library!.package;

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
    if (e is TypeAliasElement) {
      final aliasedType = e.aliasedType;
      if (aliasedType is FunctionType) {
        params = aliasedType.formalParameters;
      } else {
        return const <Parameter>[];
      }
    } else if (e is ExecutableElement) {
      if (_originalMember != null) {
        assert(_originalMember is ExecutableElement);
        params = (_originalMember as ExecutableElement).formalParameters;
      } else {
        params = e.formalParameters;
      }
    } else if (e is FunctionTypedElement) {
      if (_originalMember != null) {
        params = (_originalMember as FunctionTypedElement).formalParameters;
      } else {
        params = e.formalParameters;
      }
    } else {
      return const <Parameter>[];
    }

    return params
        .map((p) => ModelElement.for_(p, library, packageGraph) as Parameter)
        .toList(growable: false);
  }();

  @override
  late final String sourceCode = const HtmlEscape().convert(super.sourceCode);

  // TODO(lrn): Consider using `compareAsciiLowerCaseNatural`.
  @override
  int compareTo(ModelElement other) => compareAsciiLowerCase(name, other.name);

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
  bool get isVisibleAnnotation => switch (element) {
        null => false,
        Element(isPrivate: true) => false,
        GetterElement(:var enclosingElement) => !enclosingElement.isPrivate,
        ConstructorElement(:var enclosingElement) =>
          !enclosingElement.isPrivate &&
              !(enclosingElement.name == 'pragma' &&
                  enclosingElement.library.name == 'dart.core'),
        _ => true,
      };
}

// Copied from analyzer's `lib/src/dart/element/extensions.dart`. Re-use that
// extension if it becomes public.
extension ElementAnnotationExtension on ElementAnnotation {
  /// The kind of deprecation, if this annotation is a `Deprecated` annotation.
  ///
  /// `null` is returned if this is not a `Deprecated` annotation.
  String? get deprecationKind {
    if (!isDeprecated) return null;
    return computeConstantValue()
            ?.getField('_kind')
            ?.getField('_name')
            ?.toStringValue() ??
        // For SDKs where the `Deprecated` class does not have a deprecation kind.
        'use';
  }
}

/// Mixin for [ModelElement]s with a non-`null` [ModelElement.library].
mixin HasLibrary on ModelElement {
  @override
  Library get library => super.library!;
}
