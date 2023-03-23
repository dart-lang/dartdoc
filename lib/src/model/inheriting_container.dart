// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/container_modifiers.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:meta/meta.dart';

/// A mixin to build an [InheritingContainer] capable of being constructed
/// with a direct call to a [Constructor] in Dart.
///
/// Note that [Constructor]s are not considered to be modifiers so a
/// [hasModifiers] override is not necessary for this mixin.
mixin Constructable on InheritingContainer {
  late final Iterable<Constructor> constructors = element.constructors
      .map((e) => modelBuilder.from(e, library) as Constructor)
      .toList(growable: false);

  @override
  late final List<Constructor> publicConstructorsSorted =
      model_utils.filterNonPublic(constructors).toList(growable: false)..sort();

  @override
  @visibleForOverriding
  Iterable<MapEntry<String, CommentReferable>>
      get extraReferenceChildren sync* {
    yield* _constructorGenerator(constructors);
    // TODO(jcollins-g): wean important users off of relying on static method
    // inheritance (dart-lang/dartdoc#2698)
    for (var container
        in publicSuperChain.map((t) => t.modelElement).whereType<Container>()) {
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
      if (constructor.isDefaultConstructor) {
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
abstract class InheritingContainer extends Container
    with ExtensionTarget
    implements EnclosedElement {
  late final DefinedElementType? supertype = () {
    final elementSupertype = element.supertype;
    return elementSupertype == null ||
            elementSupertype.element.supertype == null
        ? null
        : modelBuilder.typeFrom(elementSupertype, library)
            as DefinedElementType;
  }();

  /// Class modifiers from the Dart feature specification.
  ///
  /// These apply to or have some meaning for [Class]es and [Mixin]s.
  late List<ContainerModifier> containerModifiers = [
    if (isAbstract) ContainerModifier.abstract,
    if (isSealed) ContainerModifier.sealed,
    if (isBase) ContainerModifier.base,
    if (isInterface) ContainerModifier.interface,
    if (isFinal) ContainerModifier.finalModifier,
    if (isMixinClass) ContainerModifier.mixin,
  ];

  late final List<ModelElement> _allModelElements = [
    ...super.allModelElements,
    ...typeParameters,
  ];

  late final Iterable<Method> inheritedMethods = () {
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
        modelBuilder.from(e, library, enclosingContainer: this) as Method,
    ];
  }();
  late final List<Operator> inheritedOperators = () {
    var operatorNames = declaredOperators.map((o) => o.element.name).toSet();
    var inheritedOperatorElements = _inheritedElements
        .whereType<MethodElement>()
        .where((e) => e.isOperator && !operatorNames.contains(e.name))
        .toSet();

    return [
      for (var e in inheritedOperatorElements)
        modelBuilder.from(e, library, enclosingContainer: this) as Operator,
    ];
  }();
  @override
  late final DefinedElementType modelType =
      modelBuilder.typeFrom(element.thisType, library) as DefinedElementType;
  late final List<DefinedElementType> publicSuperChain =
      model_utils.filterNonPublic(superChain).toList(growable: false);
  late final List<ExecutableElement> _inheritedElements = () {
    if (element is ClassElement && (element as ClassElement).isDartCoreObject) {
      return const <ExecutableElement>[];
    }

    final inheritance = definingLibrary.inheritanceManager;
    final concreteInheritenceMap =
        inheritance.getInheritedConcreteMap2(element);
    final inheritenceMap = inheritance.getInheritedMap2(element);

    List<InterfaceElement>? inheritanceChainElements;

    final combinedMap = {
      for (final name in concreteInheritenceMap.keys)
        name.name: concreteInheritenceMap[name]!,
    };
    for (final name in inheritenceMap.keys) {
      final inheritenceElement = inheritenceMap[name]!;
      final combinedMapElement = combinedMap[name.name];
      if (combinedMapElement == null) {
        combinedMap[name.name] = inheritenceElement;
        continue;
      }

      // Elements in the inheritance chain starting from `this.element` down to,
      // but not including, [Object].
      inheritanceChainElements ??=
          inheritanceChain.map((c) => c.element).toList(growable: false);
      final enclosingElement =
          inheritenceElement.enclosingElement as InterfaceElement;
      assert(inheritanceChainElements.contains(enclosingElement) ||
          enclosingElement.isDartCoreObject);

      // If the concrete object from
      // [InheritanceManager3.getInheritedConcreteMap2] is farther from this
      // class in the inheritance chain than the one provided by
      // `inheritedMap2`, prefer `inheritedMap2`. This correctly accounts for
      // intermediate abstract classes that have method/field implementations.
      if (inheritanceChainElements.indexOf(
              combinedMapElement.enclosingElement as InterfaceElement) <
          inheritanceChainElements.indexOf(enclosingElement)) {
        combinedMap[name.name] = inheritenceElement;
      }
    }

    return combinedMap.values.toList(growable: false);
  }();

  /// All fields defined on this container, _including inherited fields_.
  late final List<Field> allFields = () {
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
  late final Iterable<Method> declaredMethods =
      element.methods.map((e) => modelBuilder.from(e, library) as Method);

  @override
  late final List<TypeParameter> typeParameters = element.typeParameters
      .map((typeParameter) => modelBuilder.from(
          typeParameter,
          modelBuilder.fromElement(typeParameter.enclosingElement!.library!)
              as Library) as TypeParameter)
      .toList(growable: false);

  InheritingContainer(super.library, super.packageGraph);

  @override
  List<ModelElement> get allModelElements => _allModelElements;

  @override
  Iterable<Field> get constantFields => allFields.where((f) => f.isConst);

  @override
  Iterable<Field> get declaredFields => allFields.where((f) => !f.isInherited);

  /// The [InheritingContainer] with the library in which [element] is defined.
  InheritingContainer get definingContainer =>
      modelBuilder.from(element, definingLibrary) as InheritingContainer;

  @override
  InterfaceElement get element;

  @override
  Library get enclosingElement => library;

  String get fullkind {
    if (containerModifiers.isNotEmpty) {
      return '${containerModifiers.modifiersAsFullKindPrefix()} $kind';
    }
    return kind;
  }

  @override
  bool get hasModifiers =>
      hasAnnotations ||
      hasPublicSuperChainReversed ||
      hasPotentiallyApplicableExtensions;

  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

  bool get hasPublicSuperChainReversed => publicSuperChainReversed.isNotEmpty;

  /// Not the same as [superChain] as it may include mixins.
  ///
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  List<InheritingContainer> get inheritanceChain;

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

  Iterable<Field> get publicInheritedFields =>
      model_utils.filterNonPublic(inheritedFields);

  @override
  bool get publicInheritedInstanceFields =>
      publicInstanceFields.every((f) => f.isInherited);

  @override
  bool get publicInheritedInstanceMethods =>
      instanceMethods.every((f) => f.isInherited);

  @override
  bool get publicInheritedInstanceOperators =>
      publicInstanceOperators.every((f) => f.isInherited);

  Iterable<Method> get publicInheritedMethods =>
      model_utils.filterNonPublic(inheritedMethods);

  Iterable<DefinedElementType> get publicInterfaces => const [];

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      publicSuperChain.reversed;

  List<DefinedElementType> get superChain {
    var typeChain = <DefinedElementType>[];
    var parent = supertype;
    while (parent != null) {
      typeChain.add(parent);
      final parentType = parent.type;
      if (parentType is InterfaceType) {
        // Avoid adding [Object] to the [superChain] ([_supertype] already has
        // this check).
        if (parentType.superclass?.superclass == null) {
          break;
        } else {
          parent = modelBuilder.typeFrom(parentType.superclass!, library)
              as DefinedElementType?;
        }
      } else {
        parent = (parent.modelElement as Class).supertype;
      }
    }
    return typeChain;
  }

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
      return modelBuilder.from(element, library,
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
                getter.enclosingElement as InheritingContainer?)) {
          field = setterElement!.variable as FieldElement;
        } else {
          field = getterElement!.variable as FieldElement;
        }
      }
    }

    if ((getter == null || getter.isInherited) &&
        (setter == null || setter.isInherited)) {
      // Field is 100% inherited.
      return modelBuilder.fromPropertyInducingElement(field, library,
          enclosingContainer: this, getter: getter, setter: setter) as Field;
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      return modelBuilder.fromPropertyInducingElement(field, library,
          getter: getter, setter: setter) as Field;
    }
  }

  /// Returns true if [other] is a parent class for this class.
  bool _isInheritingFrom(InheritingContainer? other) => superChain
      .map((et) => et.modelElement as InheritingContainer)
      .contains(other);
}

/// Add the ability to support mixed-in types to an [InheritingContainer].
mixin MixedInTypes on InheritingContainer {
  late final List<DefinedElementType> mixedInTypes = element.mixins
      .map((f) => modelBuilder.typeFrom(f, library) as DefinedElementType)
      .toList(growable: false);

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicMixedInTypes;

  bool get hasPublicMixedInTypes => publicMixedInTypes.isNotEmpty;

  Iterable<DefinedElementType> get publicMixedInTypes =>
      model_utils.filterNonPublic(mixedInTypes);
}

/// Add the ability for an [InheritingContainer] to be implemented by other
/// InheritingContainers and to reference what it itself implements.
mixin TypeImplementing on InheritingContainer {
  late final List<DefinedElementType> directInterfaces = [
    for (var interface in element.interfaces)
      modelBuilder.typeFrom(interface, library) as DefinedElementType
  ];

  late final List<InheritingContainer> publicImplementorsSorted =
      publicImplementors.toList(growable: false)..sort(byName);

  @override
  bool get hasModifiers =>
      super.hasModifiers || hasPublicInterfaces || hasPublicImplementors;

  bool get hasPublicImplementors => publicImplementors.isNotEmpty;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  /// Interfaces directly implemented by this container.
  List<DefinedElementType> get interfaces => directInterfaces;

  /// Returns all the "immediate" public implementors of this
  /// [TypeImplementing].  For a [Mixin], this is actually the mixin
  /// applications using the [Mixin].
  ///
  /// If this [InheritingContainer] has a private implementor, then that is
  /// counted as a proxy for any public implementors of that private container.
  Iterable<InheritingContainer> get publicImplementors {
    var result = <InheritingContainer>{};
    var seen = <InheritingContainer>{};

    // Recursively adds [implementor] if public, or the implementors of
    // [implementor] if not.
    void addToResult(InheritingContainer implementor) {
      if (seen.contains(implementor)) return;
      seen.add(implementor);
      if (implementor.isPublicAndPackageDocumented) {
        result.add(implementor);
      } else {
        model_utils
            .findCanonicalFor(
                packageGraph.implementors[implementor] ?? const [])
            .forEach(addToResult);
      }
    }

    model_utils
        .findCanonicalFor(packageGraph.implementors[this] ?? const [])
        .forEach(addToResult);
    return result;
  }

  /// The public interfaces may include substitutions for intermediate
  /// private interfaces, and so unlike other public* methods, is not
  /// a strict subset of [interfaces].
  @override
  Iterable<DefinedElementType> get publicInterfaces sync* {
    for (var i in directInterfaces) {
      /// Do not recurse if we can find an element here.
      if (i.modelElement.canonicalModelElement != null) {
        yield i;
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
      if (i.modelElement is InheritingContainer) {
        var hiddenContainer = i.modelElement as InheritingContainer;
        if (hiddenContainer.publicSuperChain.isNotEmpty) {
          yield hiddenContainer.publicSuperChain.first;
        }
        yield* hiddenContainer.publicInterfaces;
      } else {
        assert(
            false,
            'Can not handle intermediate non-public interfaces created by '
            'ModelElements that are not classes or mixins: $fullyQualifiedName '
            'contains an interface $i, defined by ${i.modelElement}');
        continue;
      }
    }
  }
}

extension on InterfaceElement {
  bool get isDartCoreObject => name == 'Object' && library.name == 'dart.core';
}

extension DefinedElementTypeIterableExtensions on Iterable<DefinedElementType> {
  /// Expands the `ModelElement` for each element to its inheritance chain.
  Iterable<InheritingContainer> get expandInheritanceChain =>
      expand((e) => (e.modelElement as InheritingContainer).inheritanceChain);

  /// Returns the `ModelElement` for each element.
  Iterable<InheritingContainer> get modelElements =>
      map((e) => e.modelElement as InheritingContainer);
}
