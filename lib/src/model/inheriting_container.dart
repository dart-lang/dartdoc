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
  late final List<Constructor> constructors = element.augmented.constructors
      .map((e) => getModelFor(e, library) as Constructor)
      .toList(growable: false);

  @override
  late final List<Constructor> publicConstructorsSorted =
      constructors.wherePublic.toList(growable: false)..sort();

  @override
  @visibleForOverriding
  Iterable<MapEntry<String, CommentReferable>>
      get extraReferenceChildren sync* {
    yield* _constructorGenerator(constructors);
    // TODO(jcollins-g): wean important users off of relying on static method
    // inheritance (dart-lang/dartdoc#2698)
    for (var container in superChain.wherePublic
        .map((t) => t.modelElement)
        .whereType<Container>()) {
      for (var modelElement in [
        ...container.staticFields,
        ...container.staticMethods,
      ]) {
        yield MapEntry(modelElement.referenceName, modelElement);
      }
      if (container is Constructable) {
        yield* _constructorGenerator(container.constructors);
      }
    }
  }

  @override
  bool get hasPublicConstructors => publicConstructorsSorted.isNotEmpty;

  static Iterable<MapEntry<String, CommentReferable>> _constructorGenerator(
      Iterable<Constructor> source) sync* {
    for (var constructor in source) {
      yield MapEntry(constructor.referenceName, constructor);
      yield MapEntry(
          '${constructor.enclosingElement.referenceName}.${constructor.referenceName}',
          constructor);
      if (constructor.isUnnamedConstructor) {
        yield MapEntry('new', constructor);
      }
    }
  }
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
    return elementSupertype == null ||
            elementSupertype.element.supertype == null
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
    if (isInterface) ContainerModifier.interface,
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

  Iterable<Method> get inheritedMethods {
    var methodNames = declaredMethods.map((m) => m.element.name).toSet();
    var inheritedMethodElements = _inheritedElements
        .whereType<MethodElement>()
        .where((e) =>
            !e.isOperator &&
            e is! PropertyAccessorElement &&
            !methodNames.contains(e.name))
        .toSet();

    return [
      for (var e in inheritedMethodElements)
        getModelFor(e, library, enclosingContainer: this) as Method,
    ];
  }

  List<Operator> get inheritedOperators {
    var operatorNames = declaredOperators.map((o) => o.element.name).toSet();
    var inheritedOperatorElements = _inheritedElements
        .whereType<MethodElement>()
        .where((e) => e.isOperator && !operatorNames.contains(e.name))
        .toSet();

    return [
      for (var e in inheritedOperatorElements)
        getModelFor(e, library, enclosingContainer: this) as Operator,
    ];
  }

  late final DefinedElementType modelType =
      getTypeFor(element.thisType, library) as DefinedElementType;

  /// A list of the inherited executable elements, one element per inherited
  /// `Name`.
  ///
  /// In this list, elements that are "closer" in the inheritance chain to
  /// _this_ element are preferred over elements that are further away. In the
  /// case of ties, concrete inherited elements are prefered to non-concrete
  /// ones.
  late final List<ExecutableElement> _inheritedElements = () {
    if (element case ClassElement classElement
        when classElement.isDartCoreObject) {
      return const <ExecutableElement>[];
    }

    // The mapping of all of the inherited element names to their _concrete_
    // implementation element.
    var concreteInheritanceMap = packageGraph.inheritanceManager
        .getInheritedConcreteMap2(element.augmented.declaration);
    // The mapping of all inherited element names to the nearest inherited
    // element that they resolve to.
    var inheritanceMap = packageGraph.inheritanceManager
        .getInheritedMap2(element.augmented.declaration);

    var inheritanceChainElements =
        inheritanceChain.map((c) => c.element).toList(growable: false);

    // A combined map of names to inherited _concrete_ Elements, and other
    // inherited Elements.
    var combinedMap = {
      for (var MapEntry(:key, :value) in concreteInheritanceMap.entries)
        key.name: value,
    };
    for (var MapEntry(key: name, value: inheritedElement)
        in inheritanceMap.entries) {
      var combinedMapElement = combinedMap[name.name];
      if (combinedMapElement == null) {
        combinedMap[name.name] = inheritedElement;
        continue;
      }

      // Elements in the inheritance chain starting from `this.element` up to,
      // but not including, `Object`.
      var enclosingElement =
          inheritedElement.enclosingElement as InterfaceElement;
      assert(inheritanceChainElements.contains(enclosingElement) ||
          enclosingElement.isDartCoreObject);

      // If the concrete element from `getInheritedConcreteMap2` is farther in
      // the inheritance chain from this class than the (non-concrete) one
      // provided by `getInheritedMap2`, prefer the latter. This correctly
      // accounts for intermediate abstract classes that have method/field
      // implementations.
      var enclosingElementFromCombined =
          combinedMapElement.enclosingElement as InterfaceElement;
      if (inheritanceChainElements.indexOf(enclosingElementFromCombined) <
          inheritanceChainElements.indexOf(enclosingElement)) {
        combinedMap[name.name] = inheritedElement;
      }
    }

    // Finally, return all of the elements ultimately collected in the combined
    // map.
    return combinedMap.values.toList(growable: false);
  }();

  /// All fields defined on this container, _including inherited fields_.
  late List<Field> allFields = () {
    var inheritedAccessorElements = {
      ..._inheritedElements.whereType<PropertyAccessorElement>()
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
          .putIfAbsent(accessorElement.name.replaceFirst('=', ''), () => [])
          .add(accessorElement);
    }

    var fields = <Field>[];

    // For half-inherited fields, the analyzer only links the non-inherited
    // to the [FieldElement].  Compose our [Field] class by hand by looking up
    // inherited accessors that may be related.
    for (var field in element.fields) {
      var getterElement = field.getter;
      if (getterElement == null && accessorMap.containsKey(field.name)) {
        getterElement =
            accessorMap[field.name]!.firstWhereOrNull((e) => e.isGetter);
      }
      var setterElement = field.setter;
      if (setterElement == null && accessorMap.containsKey(field.name)) {
        setterElement =
            accessorMap[field.name]!.firstWhereOrNull((e) => e.isSetter);
      }
      fields.add(_createSingleField(
          getterElement, setterElement, inheritedAccessorElements, field));
      accessorMap.remove(field.name);
    }

    // Now we only have inherited accessors who aren't associated with
    // anything in the fields.
    accessorMap.forEach((fieldName, elements) {
      final getterElement = elements.firstWhereOrNull((e) => e.isGetter);
      final setterElement = elements.firstWhereOrNull((e) => e.isSetter);
      fields.add(_createSingleField(
          getterElement, setterElement, inheritedAccessorElements));
    });

    return fields;
  }();

  @override
  late final List<Method> declaredMethods = element.augmented.methods
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
      packageGraph.extensions.whereDocumented
          .where((e) => !e.alwaysApplies)
          .where((e) => e.couldApplyTo(this))
          .toList(growable: false)
        ..sort(byName);

  @override
  List<ModelElement> get allModelElements => _allModelElements;

  @override
  Iterable<Field> get constantFields => allFields.where((f) => f.isConst);

  @override
  Iterable<Field> get declaredFields => allFields.where((f) => !f.isInherited);

  /// The [InheritingContainer] with the library in which [element] is defined.
  InheritingContainer get definingContainer =>
      getModelFor(element, definingLibrary) as InheritingContainer;

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

  /// A sorted list of [element]'s inheritance chain, including interfaces and
  /// mixins.
  ///
  /// Note: this list is really not even the same as ordinary Dart inheritance,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes.
  List<InheritingContainer> get inheritanceChain;

  @visibleForTesting
  Iterable<Field> get inheritedFields => allFields.where((f) => f.isInherited);

  @override
  Iterable<Field> get instanceFields => allFields.where((f) => !f.isStatic);

  @override
  Iterable<Method> get instanceMethods =>
      [...super.instanceMethods, ...inheritedMethods];

  @override
  Iterable<Operator> get instanceOperators =>
      [...super.instanceOperators, ...inheritedOperators];

  bool get isAbstract;

  bool get isBase;

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  @override
  bool get isFinal;

  bool get isInterface;

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
  /// For a [Mixin], this is actually the mixin applications using the [Mixin].
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
    var interfaces = <DefinedElementType>[];
    for (var interface in directInterfaces) {
      var interfaceElement = interface.modelElement;

      /// Do not recurse if we can find an element here.
      if (interfaceElement.canonicalModelElement != null) {
        interfaces.add(interface);
        continue;
      }
      // Public types used to be unconditionally exposed here.  However,
      // if the packages are [DocumentLocation.missing] we generally treat types
      // defined in them as actually defined in a documented package.
      // That translates to them being defined here, but in 'src/' or similar,
      // and so, are now always hidden.

      // This type is not backed by a canonical Class; search
      // the superchain and publicInterfaces of this interface to pretend
      // as though the hidden class didn't exist and this class was declared
      // directly referencing the canonical classes further up the chain.
      if (interfaceElement is! InheritingContainer) {
        assert(
          false,
          'Can not handle intermediate non-public interfaces created by '
          "ModelElements that are not classes or mixins: '$fullyQualifiedName' "
          "contains an interface '$interface', defined by '$interfaceElement'",
        );
        continue;
      }
      var publicSuperChain = interfaceElement.superChain.wherePublic;
      if (publicSuperChain.isNotEmpty) {
        interfaces.add(publicSuperChain.first);
      }
      interfaces.addAll(interfaceElement.publicInterfaces);
    }
    return interfaces;
  }

  Iterable<InheritingContainer> get publicInterfaceElements => [
        for (var interface in publicInterfaces)
          interface.modelElement as InheritingContainer,
      ];

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      [...superChain.wherePublic].reversed;

  /// The chain of super-types, starting with [supertype], up to, but not
  /// including, `Object`.
  late final List<DefinedElementType> superChain = () {
    var typeChain = <DefinedElementType>[];
    var parent = supertype;
    while (parent != null) {
      typeChain.add(parent);
      final parentType = parent.type;
      if (parentType is! InterfaceType) {
        throw StateError("ancestor of '$this' is '$parent' with model element "
            "'${parent.modelElement}'");
      }

      var superclass = parentType.superclass;
      // Avoid adding `Object` to the `superChain` (`_supertype` already has
      // this check).
      if (superclass == null || superclass.superclass == null) {
        break;
      }
      parent = getTypeFor(superclass, library) as DefinedElementType?;
    }
    return typeChain;
  }();

  /// Add a single Field to _fields.
  ///
  /// If [field] is not specified, pick the FieldElement from the PropertyAccessorElement
  /// whose enclosing class inherits from the other (defaulting to the getter)
  /// and construct a Field using that.
  Field _createSingleField(
      PropertyAccessorElement? getterElement,
      PropertyAccessorElement? setterElement,
      Set<PropertyAccessorElement> inheritedAccessors,
      [FieldElement? field]) {
    // Return a [ContainerAccessor] with `isInherited = true` if [element] is
    // in [inheritedAccessors].
    ContainerAccessor? containerAccessorFrom(PropertyAccessorElement? element) {
      if (element == null) return null;
      final enclosingContainer =
          inheritedAccessors.contains(element) ? this : null;
      return getModelFor(element, library,
          enclosingContainer: enclosingContainer) as ContainerAccessor;
    }

    var getter = containerAccessorFrom(getterElement);
    var setter = containerAccessorFrom(setterElement);
    // Rebind [getterElement], [setterElement] as [ModelElement.from] can
    // resolve [MultiplyInheritedExecutableElement]s or resolve [Member]s.
    getterElement = getter?.element;
    setterElement = setter?.element;
    assert(getter != null || setter != null);
    if (field == null) {
      // Pick an appropriate [FieldElement] to represent this element.
      // Only hard when dealing with a synthetic [Field].
      if (getter != null && setter == null) {
        field = getterElement!.variable2 as FieldElement;
      } else if (getter == null && setter != null) {
        field = setterElement!.variable2 as FieldElement;
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
          field = setterElement!.variable2 as FieldElement;
        } else {
          field = getterElement!.variable2 as FieldElement;
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
  @visibleForTesting
  late final List<DefinedElementType> mixedInTypes = element.mixins
      .map((f) => getTypeFor(f, library) as DefinedElementType)
      .toList(growable: false);

  List<InheritingContainer> get mixedInElements => [
        for (var t in mixedInTypes) t.modelElement as InheritingContainer,
      ];

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicMixedInTypes;

  bool get hasPublicMixedInTypes => mixedInTypes.any((e) => e.isPublic);

  Iterable<DefinedElementType> get publicMixedInTypes =>
      mixedInTypes.wherePublic;
}

extension on InterfaceElement {
  bool get isDartCoreObject => name == 'Object' && library.name == 'dart.core';
}

extension DefinedElementTypeIterableExtension on Iterable<DefinedElementType> {
  /// The [ModelElement] for each element.
  Iterable<InheritingContainer> get modelElements =>
      map((e) => e.modelElement as InheritingContainer);
}

extension InheritingContainerIterableExtension
    on Iterable<InheritingContainer> {
  /// Expands each element to its inheritance chain.
  Iterable<InheritingContainer> get expandInheritanceChain =>
      expand((e) => e.inheritanceChain);
}
