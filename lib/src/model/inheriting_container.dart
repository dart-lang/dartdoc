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
import 'package:dartdoc/src/render/language_feature_renderer.dart';
import 'package:meta/meta.dart';

/// A mixin to build an [InheritingContainer] capable of being constructed
/// with a direct call to a [Constructor] in Dart.
///
/// Note that [Constructor]s are not considered to be modifiers so a
/// [hasModifiers] override is not necessary for this mixin.
mixin Constructable on InheritingContainer {
  late final List<Constructor> constructors = element.constructors
      .map((e) => getModelFor(e, library) as Constructor)
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
    implements EnclosedElement {
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
      containerModifiers
          .asLanguageFeatureSet(const LanguageFeatureRendererHtml())
          .toList();

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

  late final List<DefinedElementType> publicSuperChain =
      model_utils.filterNonPublic(superChain).toList(growable: false);

  /// A list of the inherited executable elements, one element per inherited
  /// `Name`.
  ///
  /// In this list, elements that are "closer" in the inheritance chain to
  /// _this_ element are preferred over elements that are further away. In the
  /// case of ties, concrete inherited elements are prefered to non-concrete
  /// ones.
  late final List<ExecutableElement> _inheritedElements = () {
    if (element is ClassElement && (element as ClassElement).isDartCoreObject) {
      return const <ExecutableElement>[];
    }

    var concreteInheritanceMap =
        packageGraph.inheritanceManager.getInheritedConcreteMap2(element);
    var inheritanceMap =
        packageGraph.inheritanceManager.getInheritedMap2(element);

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

      // If the concrete object from `getInheritedConcreteMap2` is farther in
      // the inheritance chain from this class than the one provided by
      // `inheritedMap2`, prefer `inheritedMap2`. This correctly accounts for
      // intermediate abstract classes that have method/field implementations.
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
      packageGraph.documentedExtensions
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

  bool get hasModifiers =>
      hasAnnotations ||
      hasPublicSuperChainReversed ||
      hasPotentiallyApplicableExtensions;

  @visibleForTesting
  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

  bool get hasPublicSuperChainReversed => publicSuperChainReversed.isNotEmpty;

  /// Not the same as [superChain] as it may include mixins.
  ///
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
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

  @visibleForTesting
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

  @visibleForTesting
  Iterable<Method> get publicInheritedMethods =>
      model_utils.filterNonPublic(inheritedMethods);

  Iterable<DefinedElementType> get publicInterfaces;

  Iterable<InheritingContainer> get publicInterfaceElements => [
        for (var interface in publicInterfaces)
          interface.modelElement as InheritingContainer,
      ];

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      publicSuperChain.reversed;

  List<DefinedElementType> get superChain {
    var typeChain = <DefinedElementType>[];
    var parent = supertype;
    while (parent != null) {
      typeChain.add(parent);
      final parentType = parent.type;
      if (parentType is! InterfaceType) {
        throw StateError('ancestor of $this is $parent with model element '
            '${parent.modelElement}');
      }

      var superclass = parentType.superclass;
      // Avoid adding [Object] to the [superChain] ([_supertype] already has
      // this check).
      if (superclass == null || superclass.superclass == null) {
        break;
      }
      parent = getTypeFor(superclass, library) as DefinedElementType?;
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
      return getModelForPropertyInducingElement(field, library,
          enclosingContainer: this, getter: getter, setter: setter) as Field;
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
  bool _isInheritingFrom(InheritingContainer? other) => superChain
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

  bool get hasPublicMixedInTypes => publicMixedInTypes.isNotEmpty;

  Iterable<DefinedElementType> get publicMixedInTypes =>
      model_utils.filterNonPublic(mixedInTypes);
}

/// Add the ability for an [InheritingContainer] to be implemented by other
/// InheritingContainers and to reference what it itself implements.
mixin TypeImplementing on InheritingContainer {
  late final List<DefinedElementType> _directInterfaces = [
    for (var interface in element.interfaces)
      getTypeFor(interface, library) as DefinedElementType
  ];

  late final List<InheritingContainer> publicImplementersSorted =
      publicImplementers.toList(growable: false)..sort(byName);

  @override
  bool get hasModifiers =>
      super.hasModifiers || hasPublicInterfaces || hasPublicImplementers;

  bool get hasPublicImplementers => publicImplementers.isNotEmpty;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  /// Interfaces directly implemented by this container.
  List<DefinedElementType> get interfaces => _directInterfaces;

  List<InheritingContainer> get interfaceElements => [
        for (var interface in interfaces)
          interface.modelElement as InheritingContainer,
      ];

  /// All the "immediate" public implementers of this [TypeImplementing].
  ///
  /// For a [Mixin], this is actually the mixin applications using the [Mixin].
  ///
  /// If this [InheritingContainer] has a private implementer, then that is
  /// counted as a proxy for any public implementers of that private container.
  Iterable<InheritingContainer> get publicImplementers {
    var result = <InheritingContainer>{};
    var seen = <InheritingContainer>{};

    // Recursively adds [implementer] if public, or the implementers of
    // [implementer] if not.
    void addToResult(InheritingContainer implementer) {
      if (seen.contains(implementer)) return;
      seen.add(implementer);
      if (implementer.isPublicAndPackageDocumented) {
        result.add(implementer);
      } else {
        var implementers = packageGraph.implementers[implementer];
        if (implementers != null) {
          model_utils.findCanonicalFor(implementers).forEach(addToResult);
        }
      }
    }

    var immediateImplementers = packageGraph.implementers[this];
    if (immediateImplementers != null) {
      model_utils.findCanonicalFor(immediateImplementers).forEach(addToResult);
    }
    return result;
  }

  /// The public interfaces may include substitutions for intermediate
  /// private interfaces, and so unlike other public* methods, is not
  /// a strict subset of [interfaces].
  @override
  Iterable<DefinedElementType> get publicInterfaces {
    var interfaces = <DefinedElementType>[];
    for (var interface in _directInterfaces) {
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
      if (interfaceElement.publicSuperChain.isNotEmpty) {
        interfaces.add(interfaceElement.publicSuperChain.first);
      }
      interfaces.addAll(interfaceElement.publicInterfaces);
    }
    return interfaces;
  }
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
