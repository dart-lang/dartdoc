// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/container_modifiers.dart';
import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:meta/meta.dart';

/// A mixin to build an [InheritingContainer] capable of being constructed
/// with a direct call to a [Constructor] in Dart.
///
/// Note that [Constructor]s are not considered to be modifiers so a
/// [hasModifiers] override is not necessary for this mixin.
mixin Constructable implements InheritingContainer {
  late final List<Constructor> constructors = element.constructors
      .map((e) => getModelFor(e, library) as Constructor)
      .toList(growable: false);

  @override
  late final List<Constructor> publicConstructorsSorted =
      constructors.wherePublic.toList(growable: false)..sort(byName);

  @override
  @visibleForOverriding
  Map<String, CommentReferable> get extraReferenceChildren => {
        for (var container in superChain.wherePublic
            .map((t) => t.modelElement)
            .whereType<Container>()) ...{
          if (container is Constructable)
            ..._mapConstructorsByName(container.constructors),
          for (var modelElement in [
            // TODO(jcollins-g): wean important users off of relying on static
            // method inheritance (dart-lang/dartdoc#2698).
            ...container.staticFields, ...container.staticMethods
          ])
            modelElement.referenceName: modelElement,
        },
        ..._mapConstructorsByName(constructors),
      };

  @override
  bool get hasPublicConstructors => publicConstructorsSorted.isNotEmpty;

  static Map<String, CommentReferable> _mapConstructorsByName(
          Iterable<Constructor> constructors) =>
      {
        for (var constructor in constructors) ...{
          constructor.referenceName: constructor,
          '${constructor.enclosingElement.referenceName}.${constructor.referenceName}':
              constructor,
          if (constructor.isUnnamedConstructor) 'new': constructor,
        },
      };
}

/// A [Container] that participates in inheritance in Dart.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// * **instance**: As with [Container], but also includes inherited children.
/// * **inherited**: Filtered getters giving only inherited children.
abstract class InheritingContainer extends Container {
  InheritingContainer(super.library, super.packageGraph);

  DefinedElementType? get supertype {
    final elementSupertype = element.supertype;
    return elementSupertype == null
        ? null
        : getTypeFor(elementSupertype, library) as DefinedElementType;
  }

  /// Class modifiers from the Dart feature specification.
  ///
  /// These apply to or have some meaning for [Class]es and [Mixin]s.
  late final List<ContainerModifier> containerModifiers = [
    if (isAbstract) ContainerModifier.abstract,
    if (isSealed) ContainerModifier.sealed,
    if (isBase) ContainerModifier.base,
    if (isImplementableInterface) ContainerModifier.interface,
    if (isFinal) ContainerModifier.finalModifier,
    if (isMixinClass) ContainerModifier.mixin,
  ]..sort();

  @override
  late final List<LanguageFeature> displayedLanguageFeatures =
      containerModifiers.asLanguageFeatureSet.toList();

  late final List<ModelElement> _allModelElements = [
    ...super.allModelElements,
    ...typeParameters,
  ];

  @visibleForTesting
  Iterable<Method> get inheritedMethods {
    var methodNames = declaredMethods.map((m) => m.element.name).toSet();
    var inheritedMethodElements = element.inheritedMembers.values
        .whereType<MethodElement>()
        .where((e) => !e.isOperator)
        .where((e) => !methodNames.contains(e.name));

    return [
      for (var e in inheritedMethodElements)
        getModelFor(e, library, enclosingContainer: this) as Method,
    ];
  }

  @visibleForTesting
  List<Operator> get inheritedOperators {
    var operatorNames =
        declaredOperators.map((o) => o.element.lookupName).toSet();
    var inheritedOperatorElements = element.inheritedMembers.values
        .whereType<MethodElement>()
        .where((e) => e.isOperator)
        .where((e) => !operatorNames.contains(e.name));

    return [
      for (var e in inheritedOperatorElements)
        getModelFor(e, library, enclosingContainer: this) as Operator,
    ];
  }

  late final DefinedElementType modelType =
      getTypeFor(element.thisType, library) as DefinedElementType;

  /// All fields defined on this container, _including inherited fields_.
  late final List<Field> _allFields = () {
    var inheritedAccessorElements = {
      ...element.inheritedMembers.values.whereType<PropertyAccessorElement>()
    };

    // This structure keeps track of inherited accessors, allowing lookup
    // by field name (stripping the '=' from setters).
    // TODO(srawlins): Each value List should only contain 1 or 2 elements:
    // up to one getter and one setter. We then perform repeated
    // `.firstWhereOrNull((e) => e.isGetter)` and
    // `.firstWhereOrNull((e) => e.isSetter)` calls, which would be much simpler
    // if we used some sort of "pair" class instead.
    var accessorMap = <String, List<PropertyAccessorElement>>{};
    for (var accessorElement in inheritedAccessorElements) {
      accessorMap
          .putIfAbsent(
              accessorElement.name?.replaceFirst('=', '') ?? '', () => [])
          .add(accessorElement);
    }

    var fields = <Field>[];

    // For half-inherited fields, the analyzer only links the non-inherited
    // to the [FieldElement].  Compose our [Field] class by hand by looking up
    // inherited accessors that may be related.
    for (var field in element.fields) {
      var getterElement = field.getter;
      if (getterElement == null && accessorMap.containsKey(field.name)) {
        getterElement = accessorMap[field.name]!
            .firstWhereOrNull((e) => e is GetterElement) as GetterElement?;
      }
      var setterElement = field.setter;
      if (setterElement == null && accessorMap.containsKey(field.name)) {
        setterElement = accessorMap[field.name]!
            .firstWhereOrNull((e) => e is SetterElement) as SetterElement?;
      }
      fields.add(_createSingleField(
          getterElement, setterElement, inheritedAccessorElements, field));
      accessorMap.remove(field.name);
    }

    // Now we only have inherited accessors who aren't associated with
    // anything in the fields.
    accessorMap.forEach((fieldName, elements) {
      final getterElement =
          elements.firstWhereOrNull((e) => e is GetterElement);
      final setterElement =
          elements.firstWhereOrNull((e) => e is SetterElement);

      final isNullOrTopMergeGetter = getterElement == null ||
          getterElement.enclosingElement == element &&
              !element.getters.contains(getterElement);
      final isNullOrTopMergeSetter = setterElement == null ||
          setterElement.enclosingElement == element &&
              !element.setters.contains(setterElement);
      if (isNullOrTopMergeGetter && isNullOrTopMergeSetter) {
        return;
      }

      fields.add(_createSingleField(
          getterElement, setterElement, inheritedAccessorElements));
    });

    return fields;
  }();

  @override
  late final List<Method> declaredMethods = element.methods
      .map((e) => getModelFor(e, library) as Method)
      .toList(growable: false);

  @override
  late final List<TypeParameter> typeParameters = element.typeParameters
      .map((typeParameter) => getModelFor(
          typeParameter,
          getModelForElement(typeParameter.enclosingElement!.library!)
              as Library) as TypeParameter)
      .toList(growable: false);

  bool get hasPotentiallyApplicableExtensions =>
      potentiallyApplicableExtensionsSorted.isNotEmpty;

  /// The sorted list of potentially applicable extensions, for display in
  /// templates.
  ///
  /// This is defined as those extensions where an instantiation of the type
  /// defined by [element] can exist where this extension applies, not including
  /// any extension that applies to every type.
  late final List<Extension> potentiallyApplicableExtensionsSorted =
      packageGraph.extensions
          .where((e) => !e.alwaysApplies)
          .where((e) => e.couldApplyTo(this))
          .toList(growable: false)
        ..sort(byName);

  @override
  List<ModelElement> get allModelElements => _allModelElements;

  @override
  Iterable<Field> get constantFields => _allFields.where((f) => f.isConst);

  @override
  Iterable<Field> get declaredFields => _allFields.where((f) => !f.isInherited);

  /// The [InheritingContainer] with the library in which [element] is defined.
  InheritingContainer get definingContainer =>
      getModelFor(element, library) as InheritingContainer;

  @override
  InterfaceElement get element;

  @override
  Library get enclosingElement => library;

  String get fullkind => kind.toString();

  /// Whether this container has any "modifiers" that should be displayed on the
  /// container's page, above it's members.
  // TODO(srawlins): This name is confusing, especially after the language
  // feature, "new class modifiers." I think the only purpose is to avoid
  // writing a `<section>` and a `<dl>` tag, if they would be empty. But with
  // CSS, we should be able to just always write those tags, and visually make
  // them take up zero space if they are empty.
  bool get hasModifiers =>
      hasAnnotations ||
      hasPublicSuperChainReversed ||
      hasPotentiallyApplicableExtensions ||
      hasPublicInterfaces ||
      hasPublicImplementers;

  @visibleForTesting
  bool get hasPublicInheritedMethods => inheritedMethods.any((e) => e.isPublic);

  bool get hasPublicSuperChainReversed => superChain.any((e) => e.isPublic);

  @visibleForTesting
  Iterable<Field> get inheritedFields => _allFields.where((f) => f.isInherited);

  @override
  Iterable<Field> get instanceFields => _allFields.where((f) => !f.isStatic);

  @override
  late final List<Field> availableInstanceFieldsSorted = [
    ...instanceFields.wherePublic,
    ..._extensionInstanceFields.wherePublic,
  ]..sort();

  List<Field> get _extensionInstanceFields => [
        for (var extension in potentiallyApplicableExtensionsSorted)
          for (var field in extension.instanceFields)
            getModelForPropertyInducingElement(
              field.element,
              library,
              enclosingContainer: extension,
              getter: field.getter,
              setter: field.setter,
            ) as Field,
      ];

  @override
  Iterable<Method> get instanceMethods => [
        ...declaredMethods.where((m) => !m.isStatic && !m.isOperator),
        ...inheritedMethods,
      ];

  @override
  late final List<Method> availableInstanceMethodsSorted = [
    ...instanceMethods.wherePublic,
    ..._extensionInstanceMethods.wherePublic,
  ]..sort();

  List<Method> get _extensionInstanceMethods => [
        for (var extension in potentiallyApplicableExtensionsSorted)
          for (var method in extension.instanceMethods)
            getModelFor(method.element, library, enclosingContainer: extension)
                as Method,
      ];

  @override
  Iterable<Operator> get instanceOperators =>
      [...super.instanceOperators, ...inheritedOperators];

  @override
  late final List<Operator> availableInstanceOperatorsSorted = [
    ...instanceOperators.wherePublic,
    ..._extensionInstanceOperators.wherePublic,
  ]..sort();

  List<Operator> get _extensionInstanceOperators => [
        for (var extension in potentiallyApplicableExtensionsSorted)
          for (var operator in extension.instanceOperators)
            getModelFor(operator.element, library,
                enclosingContainer: extension) as Operator,
      ];

  bool get isAbstract;

  bool get isBase;

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  @override
  bool get isFinal;

  /// Whether this element is a publicly implementable interface.
  bool get isImplementableInterface;

  bool get isMixinClass;

  bool get isSealed;

  @override
  // TODO(srawlins): Rename this, and `publicInheritedInstanceMethods` and
  // `publicInheritedInstanceOperators` after custom template support is
  // removed. Maybe `areAllInstanceFieldsInherited`.
  bool get publicInheritedInstanceFields =>
      instanceFields.wherePublic.every((f) => f.isInherited);

  @override
  bool get publicInheritedInstanceMethods =>
      instanceMethods.every((f) => f.isInherited);

  @override
  bool get publicInheritedInstanceOperators =>
      instanceOperators.wherePublic.every((f) => f.isInherited);

  @visibleForTesting
  late final List<DefinedElementType> directInterfaces = [
    for (var interface in element.interfaces)
      getTypeFor(interface, library) as DefinedElementType
  ];

  bool get hasPublicImplementers => publicImplementersSorted.isNotEmpty;

  /// All the "immediate" public implementers of this container.
  ///
  /// For a [Mixin], this is actually the mixin applications that use the
  /// [Mixin].
  ///
  /// If this container has a private implementer, then that is counted as a
  /// proxy for any public implementers of that private container.
  List<InheritingContainer> get publicImplementersSorted {
    var result = <InheritingContainer>{};
    var seen = <InheritingContainer>{};

    // Recursively adds [implementer] if public, or just the implementers of
    // [implementer] if not.
    void addToResult(InheritingContainer implementer) {
      if (seen.contains(implementer)) return;
      seen.add(implementer);
      if (implementer.isPublicAndPackageDocumented) {
        result.add(implementer);
      } else {
        var implementers = packageGraph.implementers[implementer];
        if (implementers != null) {
          _findCanonicalFor(implementers).forEach(addToResult);
        }
      }
    }

    var immediateImplementers = packageGraph.implementers[this];
    if (immediateImplementers != null) {
      _findCanonicalFor(immediateImplementers).forEach(addToResult);
    }
    return result.toList(growable: false)..sort(byName);
  }

  /// Finds canonical classes for all classes in the iterable, if possible.
  /// If a canonical class can not be found, returns the original class.
  Iterable<InheritingContainer> _findCanonicalFor(
      Iterable<InheritingContainer> containers) {
    return containers.map((container) {
      var canonical = packageGraph.findCanonicalModelElementFor(container);
      return canonical as InheritingContainer? ?? container;
    });
  }

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  List<InheritingContainer> get interfaceElements => [
        for (var interface in directInterfaces)
          interface.modelElement as InheritingContainer,
      ];

  /// The public interfaces of this container.
  ///
  /// This list may include substitutions for intermediate private interfaces,
  /// and so unlike other `public*` methods, is not a strict subset of
  /// [directInterfaces] (the direct interfaces).
  List<DefinedElementType> get publicInterfaces {
    var interfaceElements = <InterfaceElement>{};
    var interfaces = <DefinedElementType>[];

    // Only interfaces with unique elements should be returned. Elements can
    // implement an interface through multiple inheritance routes (e.g.
    // `List<E>` implements `Iterable<E>` but also `_ListIterable<E>` which
    // implements `EfficientLengthIterable<T>` which implements `Iterable<T>`),
    // but there is no chance of type arguments differing, as that is illegal.
    void addInterfaceIfUnique(DefinedElementType type) {
      var firstPublicSuperElement = type.modelElement.element;
      if (firstPublicSuperElement is InterfaceElement) {
        if (interfaceElements.add(firstPublicSuperElement)) {
          interfaces.add(type);
        }
      }
    }

    void addFromSupertype(DefinedElementType supertype,
        {required bool addSupertypes}) {
      var superElement = supertype.modelElement;

      /// Do not recurse if we can find an element here.
      if (superElement.canonicalModelElement != null) {
        if (addSupertypes) addInterfaceIfUnique(supertype);
        return;
      }

      // This type is not backed by a canonical Class; it is not documented.
      // Search it's `superChain` and `publicInterfaces` to pretend that `this`
      // container directly implements canonical classes further up the chain.

      if (superElement is! InheritingContainer) {
        assert(
          false,
          'Cannot handle intermediate non-public interfaces created by '
          "ModelElements that are not classes or mixins: '$fullyQualifiedName' "
          "contains a supertype '$supertype', defined by '$superElement'",
        );
        return;
      }
      var publicSuperChain = superElement.superChain.wherePublic;
      if (publicSuperChain.isNotEmpty && addSupertypes) {
        addInterfaceIfUnique(publicSuperChain.first);
      }
      superElement.publicInterfaces.forEach(addInterfaceIfUnique);
    }

    for (var interface in directInterfaces) {
      addFromSupertype(interface, addSupertypes: true);
    }
    for (var supertype in superChain) {
      var interfaceElement = supertype.modelElement;

      // Do not recurse if we can find an element here.
      if (interfaceElement.canonicalModelElement != null) {
        continue;
      }
      addFromSupertype(supertype, addSupertypes: false);
    }
    if (this case Class(:var mixedInTypes) || Enum(:var mixedInTypes)) {
      for (var mixin in mixedInTypes) {
        addFromSupertype(mixin, addSupertypes: false);
      }
    }
    return interfaces;
  }

  Iterable<InheritingContainer> get publicInterfaceElements =>
      publicInterfaces.modelElements;

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      [...superChain.wherePublic].reversed;

  /// The chain of super-types, starting with [supertype], up to, but not
  /// including, `Object`.
  late final List<DefinedElementType> superChain = () {
    var typeChain = <DefinedElementType>[];
    var parent = supertype;
    while (parent != null) {
      if ((parent.modelElement as Container).isDartCoreObject) {
        break;
      }
      typeChain.add(parent);
      final parentType = parent.type;
      if (parentType is! InterfaceType) {
        throw StateError("ancestor of '$this' is '$parent' with model element "
            "'${parent.modelElement}'");
      }

      var superclass = parentType.superclass;
      if (superclass == null) {
        break;
      }
      parent = getTypeFor(superclass, library) as DefinedElementType?;
    }
    return typeChain;
  }();

  /// Creates a single Field.
  ///
  /// If [field] is not specified, picks the [FieldElement] from the
  /// [PropertyAccessorElement] whose enclosing class inherits from the other
  /// (defaulting to the getter) and constructs a [Field] using that.
  Field _createSingleField(
      PropertyAccessorElement? getterElement,
      PropertyAccessorElement? setterElement,
      Set<PropertyAccessorElement> inheritedAccessors,
      [FieldElement? field]) {
    // Return a [ContainerAccessor] with `isInherited = true` if [element] is
    // in [inheritedAccessors].
    ContainerAccessor? containerAccessorFrom(
        PropertyAccessorElement? element) {
      if (element == null) return null;
      final enclosingContainer =
          inheritedAccessors.contains(element) ? this : null;
      return getModelFor(element, library,
          enclosingContainer: enclosingContainer) as ContainerAccessor;
    }

    var getter = containerAccessorFrom(getterElement);
    var setter = containerAccessorFrom(setterElement);
    // Rebind [getterElement], [setterElement] as [ModelElement.from] can
    // resolve [Member]s.
    getterElement = getter?.element;
    setterElement = setter?.element;
    assert(getter != null || setter != null);
    if (field == null) {
      // Pick an appropriate [FieldElement] to represent this element.
      // Only hard when dealing with a synthetic [Field].
      if (getter != null && setter == null) {
        field = getterElement!.variable as FieldElement;
      } else if (getter == null && setter != null) {
        field = setterElement!.variable as FieldElement;
      } else {
        // In this case: `getter != null && setter != null`.
        getter!;
        setter!;
        final setterEnclosingElement = setter.enclosingElement;
        // In cases where a Field is composed of two Accessors defined in
        // different places in the inheritance chain, there are two
        // [FieldElement]s for this single [Field] we're trying to compose.
        // Pick the one closest to this class on the inheritance chain.
        if (setterEnclosingElement is Class &&
            setterEnclosingElement._isInheritingFrom(
                getter.enclosingElement as InheritingContainer)) {
          field = setterElement!.variable as FieldElement;
        } else {
          field = getterElement!.variable as FieldElement;
        }
      }
    }

    if ((getter == null || getter.isInherited) &&
        (setter == null || setter.isInherited)) {
      // Field is 100% inherited.
      return getModelForPropertyInducingElement(field, library,
          getter: getter, setter: setter, enclosingContainer: this) as Field;
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      return getModelForPropertyInducingElement(field, library,
          getter: getter, setter: setter) as Field;
    }
  }

  /// Returns true if [other] is a parent class for this class.
  bool _isInheritingFrom(InheritingContainer other) => superChain
      .map((et) => et.modelElement as InheritingContainer)
      .contains(other);
}

/// Add the ability to support mixed-in types to an [InheritingContainer].
mixin MixedInTypes on InheritingContainer {
  late final List<DefinedElementType> mixedInTypes = element.mixins
      .map((f) => getTypeFor(f, library) as DefinedElementType)
      .toList(growable: false);

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicMixedInTypes;

  bool get hasPublicMixedInTypes => mixedInTypes.any((e) => e.isPublic);

  Iterable<DefinedElementType> get publicMixedInTypes =>
      mixedInTypes.wherePublic;
}

extension DefinedElementTypeIterableExtension on Iterable<DefinedElementType> {
  /// The [ModelElement] for each element.
  List<InheritingContainer> get modelElements =>
      map((e) => e.modelElement as InheritingContainer).toList();
}
