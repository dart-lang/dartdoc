// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:dartdoc/src/quiver.dart' as quiver;
import 'package:meta/meta.dart';

/// A mixin to build an [InheritingContainer] capable of being constructed
/// with a direct call to a [Constructor] in Dart.
///
/// Note that [Constructor]s are not considered to be modifiers so a
/// [hasModifiers] override is not necessary for this mixin.
mixin Constructable on InheritingContainer {
  List<Constructor>? _constructors;
  Iterable<Constructor> get constructors => _constructors ??= [
        ...element!.constructors
            .map((e) => modelBuilder.from(e, library) as Constructor)
      ];

  @override
  bool get hasPublicConstructors => publicConstructorsSorted.isNotEmpty;

  @visibleForTesting
  Iterable<Constructor> get publicConstructors =>
      model_utils.filterNonPublic(constructors);

  List<Constructor>? _publicConstructorsSorted;

  @override
  Iterable<Constructor> get publicConstructorsSorted =>
      _publicConstructorsSorted ??= publicConstructors.toList()..sort(byName);

  Constructor? _unnamedConstructor;
  Constructor? get unnamedConstructor {
    _unnamedConstructor ??=
        constructors.firstWhereOrNull((c) => c.isUnnamedConstructor);
    return _unnamedConstructor;
  }

  Constructor? _defaultConstructor;

  /// With constructor tearoffs, this is no longer equivalent to the unnamed
  /// constructor and assumptions based on that are incorrect.
  Constructor? get defaultConstructor {
    _defaultConstructor ??= unnamedConstructor ??
        constructors.firstWhere((c) => c.isDefaultConstructor);
    return _defaultConstructor;
  }

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

  @override
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
      if (container is Class) {
        yield* _constructorGenerator(container.constructors);
      }
    }
  }
}

/// Add the ability to support mixed-in types to an [InheritingContainer].
mixin MixedInTypes on InheritingContainer {
  List<DefinedElementType>? _mixedInTypes;

  List<DefinedElementType> get mixedInTypes =>
      _mixedInTypes ??
      [
        ...element!.mixins.map<DefinedElementType>(
            (f) => modelBuilder.typeFrom(f, library) as DefinedElementType)
      ];

  bool get hasPublicMixedInTypes => publicMixedInTypes.isNotEmpty;

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicMixedInTypes;

  Iterable<DefinedElementType> get publicMixedInTypes =>
      model_utils.filterNonPublic(mixedInTypes);
}

/// Add the ability for an [InheritingContainer] to be implemented by other
/// InheritingContainers and to reference what it itself implements.
mixin TypeImplementing on InheritingContainer {
  List<DefinedElementType>? _directInterfaces;
  List<DefinedElementType> get directInterfaces =>
      _directInterfaces ??
      [
        ...element!.interfaces
            .map<DefinedElementType>(
                (f) => modelBuilder.typeFrom(f, library) as DefinedElementType)
            .toList(growable: false)
      ];

  /// Interfaces directly implemented by this container.
  List<DefinedElementType> get interfaces => directInterfaces;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  @override
  bool get hasModifiers =>
      super.hasModifiers || hasPublicInterfaces || hasPublicImplementors;

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
            'Can not handle intermediate non-public interfaces '
            'created by ModelElements that are not classes or mixins:  '
            '$fullyQualifiedName contains an interface {$i}, '
            'defined by ${i.modelElement}');
        continue;
      }
    }
  }

  bool get hasPublicImplementors => publicImplementors.isNotEmpty;

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
            .findCanonicalFor(packageGraph.implementors[implementor] ?? [])
            .forEach(addToResult);
      }
    }

    model_utils
        .findCanonicalFor(packageGraph.implementors[this] ?? [])
        .forEach(addToResult);
    return result;
  }

  List<InheritingContainer>? _publicImplementorsSorted;

  Iterable<InheritingContainer> get publicImplementorsSorted =>
      _publicImplementorsSorted ??= publicImplementors.toList()..sort(byName);
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
  /// [ClassElement] is analogous to [InheritingContainer].
  @override
  ClassElement? get element => super.element as ClassElement?;

  DefinedElementType? _supertype;
  DefinedElementType? get supertype =>
      _supertype ??= element!.supertype?.element.supertype == null
          ? null
          : modelBuilder.typeFrom(element!.supertype!, library)
              as DefinedElementType?;

  InheritingContainer(
      ClassElement element, Library? library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  Iterable<Method> get instanceMethods =>
      quiver.concat([super.instanceMethods, inheritedMethods]);

  @override
  bool get publicInheritedInstanceMethods =>
      instanceMethods.every((f) => f.isInherited);

  @override
  Iterable<Operator> get instanceOperators =>
      quiver.concat([super.instanceOperators, inheritedOperators]);

  @override
  bool get publicInheritedInstanceOperators =>
      publicInstanceOperators.every((f) => f.isInherited);

  @override
  late final List<ModelElement> allModelElements = List.of(
      quiver.concat<ModelElement>([
        super.allModelElements!,
        typeParameters,
      ]),
      growable: false);

  /// Returns the [InheritingContainer] with the library in which [element] is defined.
  InheritingContainer get definingContainer =>
      modelBuilder.from(element!, definingLibrary) as InheritingContainer;

  /// Returns the library that encloses this element.
  @override
  ModelElement? get enclosingElement => library;

  @override
  String get filePath => '${library.dirName}/$fileName';

  String get fullkind => kind;

  @override
  bool get hasModifiers =>
      hasAnnotations ||
      hasPublicSuperChainReversed ||
      hasPotentiallyApplicableExtensions;

  bool get hasPublicSuperChainReversed => publicSuperChainReversed.isNotEmpty;

  late final Iterable<Method> inheritedMethods = () {
    var methodNames = declaredMethods.map((m) => m.element!.name).toSet();
    var inheritedMethodElements =
        _inheritedElements!.whereType<MethodElement>().where((e) {
      return (!e.isOperator &&
          e is! PropertyAccessorElement &&
          !methodNames.contains(e.name));
    }).toSet();

    return [
      for (var e in inheritedMethodElements)
        modelBuilder.from(e, library, enclosingContainer: this) as Method,
    ];
  }();

  Iterable<Method> get publicInheritedMethods =>
      model_utils.filterNonPublic(inheritedMethods);

  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

  late final List<Operator> inheritedOperators = () {
    var operatorNames = declaredOperators.map((o) => o.element!.name).toSet();
    var inheritedOperatorElements = _inheritedElements!
        .whereType<MethodElement>()
        .where((e) => (e.isOperator && !operatorNames.contains(e.name)))
        .toSet();

    return [
      for (var e in inheritedOperatorElements)
        modelBuilder.from(e, library, enclosingContainer: this) as Operator,
    ];
  }();

  Iterable<Field> get inheritedFields => allFields.where((f) => f.isInherited);

  Iterable<DefinedElementType> get publicInterfaces => [];

  Iterable<Field> get publicInheritedFields =>
      model_utils.filterNonPublic(inheritedFields);

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  /// Returns true if [other] is a parent class for this class.
  bool _isInheritingFrom(InheritingContainer? other) => superChain
      .map((et) => (et.modelElement as InheritingContainer))
      .contains(other);

  DefinedElementType? _modelType;

  @override
  DefinedElementType get modelType =>
      (_modelType ??= modelBuilder.typeFrom(element!.thisType, library)
          as DefinedElementType?)!;

  /// Not the same as superChain as it may include mixins.
  ///
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  List<InheritingContainer?> get inheritanceChain;

  List<DefinedElementType> get superChain {
    var typeChain = <DefinedElementType>[];
    var parent = supertype;
    while (parent != null) {
      typeChain.add(parent);
      if (parent.type is InterfaceType) {
        // Avoid adding [Object] to the superChain (_supertype already has this
        // check)
        if ((parent.type as InterfaceType).superclass?.superclass == null) {
          parent = null;
        } else {
          parent = modelBuilder.typeFrom(
                  (parent.type as InterfaceType).superclass!, library)
              as DefinedElementType?;
        }
      } else {
        parent = (parent.modelElement as Class).supertype;
      }
    }
    return typeChain;
  }

  late final List<DefinedElementType> publicSuperChain = [
    ...model_utils.filterNonPublic(superChain)
  ];

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      publicSuperChain.reversed;

  List<ExecutableElement?>? __inheritedElements;

  List<ExecutableElement?>? get _inheritedElements {
    if (__inheritedElements == null) {
      if (element!.isDartCoreObject) {
        return __inheritedElements = <ExecutableElement>[];
      }

      var inheritance = definingLibrary.inheritanceManager;
      var cmap = inheritance.getInheritedConcreteMap2(element!);
      var imap = inheritance.getInheritedMap2(element!);

      List<ClassElement?>? inheritanceChainElements;

      var combinedMap = <String, ExecutableElement?>{};
      for (var nameObj in cmap.keys) {
        combinedMap[nameObj.name] = cmap[nameObj];
      }
      for (var nameObj in imap.keys) {
        if (combinedMap[nameObj.name] != null) {
          // Elements in the inheritance chain starting from [this.element]
          // down to, but not including, [Object].
          inheritanceChainElements ??=
              inheritanceChain.map((c) => c!.element).toList();
          // [packageGraph.specialClasses] is not available yet.
          bool _isDartCoreObject(ClassElement e) =>
              e.name == 'Object' && e.library.name == 'dart.core';
          assert(inheritanceChainElements
                  .contains(imap[nameObj]!.enclosingElement) ||
              _isDartCoreObject(
                  imap[nameObj]!.enclosingElement as ClassElement));

          // If the concrete object from [InheritanceManager3.getInheritedConcreteMap2]
          // is farther from this class in the inheritance chain than the one
          // provided by InheritedMap2, prefer InheritedMap2.  This
          // correctly accounts for intermediate abstract classes that have
          // method/field implementations.
          if (inheritanceChainElements.indexOf(combinedMap[nameObj.name]!
                  .enclosingElement as ClassElement?) <
              inheritanceChainElements
                  .indexOf(imap[nameObj]!.enclosingElement as ClassElement?)) {
            combinedMap[nameObj.name] = imap[nameObj];
          }
        } else {
          combinedMap[nameObj.name] = imap[nameObj];
        }
      }

      __inheritedElements = combinedMap.values.toList();
    }
    return __inheritedElements;
  }

  late final List<Field> allFields = () {
    var fields = <Field>[];
    var inheritedAccessorElements = <PropertyAccessorElement>{}
      ..addAll(_inheritedElements!.whereType<PropertyAccessorElement>());

    // This structure keeps track of inherited accessors, allowing lookup
    // by field name (stripping the '=' from setters).
    var accessorMap = <String, List<PropertyAccessorElement>>{};
    for (var accessorElement in inheritedAccessorElements) {
      var name = accessorElement.name.replaceFirst('=', '');
      accessorMap.putIfAbsent(name, () => []).add(accessorElement);
    }

    // For half-inherited fields, the analyzer only links the non-inherited
    // to the [FieldElement].  Compose our [Field] class by hand by looking up
    // inherited accessors that may be related.
    for (var f in element!.fields) {
      var getterElement = f.getter;
      if (getterElement == null && accessorMap.containsKey(f.name)) {
        getterElement =
            accessorMap[f.name]!.firstWhereOrNull((e) => e.isGetter);
      }
      var setterElement = f.setter;
      if (setterElement == null && accessorMap.containsKey(f.name)) {
        setterElement =
            accessorMap[f.name]!.firstWhereOrNull((e) => e.isSetter);
      }
      fields.add(_createSingleField(
          getterElement, setterElement, inheritedAccessorElements, f));
      accessorMap.remove(f.name);
    }

    // Now we only have inherited accessors who aren't associated with
    // anything in cls._fields.
    for (var fieldName in accessorMap.keys) {
      var elements = accessorMap[fieldName]!.toList();
      var getterElement = elements.firstWhereOrNull((e) => e.isGetter);
      var setterElement = elements.firstWhereOrNull((e) => e.isSetter);
      fields.add(_createSingleField(
          getterElement, setterElement, inheritedAccessorElements));
    }

    return fields;
  }();

  @override
  Iterable<Field> get declaredFields => allFields.where((f) => !f.isInherited);

  /// Add a single Field to _fields.
  ///
  /// If [f] is not specified, pick the FieldElement from the PropertyAccessorElement
  /// whose enclosing class inherits from the other (defaulting to the getter)
  /// and construct a Field using that.
  Field _createSingleField(
      PropertyAccessorElement? getterElement,
      PropertyAccessorElement? setterElement,
      Set<PropertyAccessorElement> inheritedAccessors,
      [FieldElement? f]) {
    /// Return an [ContainerAccessor] with isInherited = true
    /// if [element] is in [inheritedAccessors].
    ContainerAccessor? containerAccessorFrom(
        PropertyAccessorElement? element,
        Set<PropertyAccessorElement> inheritedAccessors,
        Container enclosingContainer) {
      ContainerAccessor accessor;
      if (element == null) return null;
      if (inheritedAccessors.contains(element)) {
        accessor = modelBuilder.from(element, enclosingContainer.library,
            enclosingContainer: enclosingContainer) as ContainerAccessor;
      } else {
        accessor = modelBuilder.from(element, enclosingContainer.library)
            as ContainerAccessor;
      }
      return accessor;
    }

    var getter = containerAccessorFrom(getterElement, inheritedAccessors, this);
    var setter = containerAccessorFrom(setterElement, inheritedAccessors, this);
    // Rebind getterElement/setterElement as ModelElement.from can resolve
    // MultiplyInheritedExecutableElements or resolve Members.
    getterElement = getter?.element;
    setterElement = setter?.element;
    assert(!(getter == null && setter == null));
    if (f == null) {
      // Pick an appropriate FieldElement to represent this element.
      // Only hard when dealing with a synthetic Field.
      if (getter != null && setter == null) {
        f = getterElement!.variable as FieldElement?;
      } else if (getter == null && setter != null) {
        f = setterElement!.variable as FieldElement?;
      } else {
        /* getter != null && setter != null */
        // In cases where a Field is composed of two Accessors defined in
        // different places in the inheritance chain, there are two FieldElements
        // for this single Field we're trying to compose.  Pick the one closest
        // to this class on the inheritance chain.
        if (setter!.enclosingElement is Class &&
            (setter.enclosingElement as Class)._isInheritingFrom(
                getter!.enclosingElement as InheritingContainer?)) {
          f = setterElement!.variable as FieldElement?;
        } else {
          f = getterElement!.variable as FieldElement?;
        }
      }
    }
    if ((getter == null || getter.isInherited) &&
        (setter == null || setter.isInherited)) {
      // Field is 100% inherited.
      return modelBuilder.fromPropertyInducingElement(f!, library,
          enclosingContainer: this, getter: getter, setter: setter) as Field;
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      return modelBuilder.fromPropertyInducingElement(f!, library,
          getter: getter, setter: setter) as Field;
    }
  }

  Iterable<Method>? _declaredMethods;

  @override
  Iterable<Method> get declaredMethods =>
      _declaredMethods ??= element!.methods.map((e) {
        return modelBuilder.from(e, library) as Method;
      });

  List<TypeParameter>? _typeParameters;

  @override
  List<TypeParameter> get typeParameters {
    _typeParameters ??= element!.typeParameters.map((f) {
      var lib = modelBuilder.fromElement(f.enclosingElement!.library!);
      return modelBuilder.from(f, lib as Library) as TypeParameter;
    }).toList();
    return _typeParameters!;
  }

  Iterable<Field>? _instanceFields;

  @override
  Iterable<Field> get instanceFields =>
      _instanceFields ??= allFields.where((f) => !f.isStatic);

  @override
  bool get publicInheritedInstanceFields =>
      publicInstanceFields.every((f) => f.isInherited);

  @override
  Iterable<Field> get constantFields => allFields.where((f) => f.isConst);

  /// The CSS class to use in an inheritance list.
  String get relationshipsClass;
}

extension DefinedElementTypeIterableExtensions on Iterable<DefinedElementType> {
  /// Returns the `ModelElement` for each element.
  Iterable<InheritingContainer> get modelElements =>
      map((e) => e.modelElement as InheritingContainer);

  /// Expands the `ModelElement` for each element to its inheritance chain.
  Iterable<InheritingContainer?> get expandInheritanceChain =>
      expand((e) => (e.modelElement as InheritingContainer).inheritanceChain);
}
