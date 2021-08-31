// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/class.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:dartdoc/src/quiver.dart' as quiver;

/// A [Container] that participates in inheritance in Dart.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// **instance**: As with [Container], but also includes inherited children.
/// **inherited**: Filtered getters giving only inherited children.
abstract class InheritingContainer extends Container
    with ExtensionTarget
    implements EnclosedElement {
  // TODO(srawlins): To make final, remove public getter, setter, rename to be
  // public, and add `final` modifier.
  DefinedElementType _supertype;

  DefinedElementType get supertype => _supertype;

  @Deprecated('Field intended to be final; setter will be removed as early as '
      'Dartdoc 1.0.0')
  set supertype(DefinedElementType value) => _supertype = value;

  InheritingContainer(
      ClassElement element, Library library, PackageGraph packageGraph)
      : _supertype = element.supertype?.element?.supertype == null
            ? null
            : ElementType.from(element.supertype, library, packageGraph),
        super(element, library, packageGraph);

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

  List<ModelElement> _allModelElements;

  @override
  List<ModelElement> get allModelElements {
    _allModelElements ??= List.from(
        quiver.concat<ModelElement>([
          super.allModelElements,
          typeParameters,
        ]),
        growable: false);
    return _allModelElements;
  }

  bool get hasPublicImplementors => publicImplementors.isNotEmpty;

  /// Returns all the "immediate" public implementors of this
  /// [InheritingContainer].  For a [Mixin], this is actually the mixin
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

  List<InheritingContainer> _publicImplementorsSorted;

  Iterable<InheritingContainer> get publicImplementorsSorted =>
      _publicImplementorsSorted ??= publicImplementors.toList()..sort(byName);

  /// Returns the [InheritingContainer] with the library in which [element] is defined.
  InheritingContainer get definingContainer =>
      ModelElement.from(element, definingLibrary, packageGraph);

  /// Returns the library that encloses this element.
  @override
  ModelElement get enclosingElement => library;

  @override
  ClassElement get element => super.element;

  @override
  String get filePath => '${library.dirName}/$fileName';

  String get fullkind => kind;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  @override
  bool get hasModifiers =>
      hasAnnotations ||
      hasPublicSuperChainReversed ||
      hasPublicInterfaces ||
      hasPotentiallyApplicableExtensions;

  bool get hasPublicSuperChainReversed => publicSuperChainReversed.isNotEmpty;

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  /*lazy final*/
  List<Method> _inheritedMethods;

  Iterable<Method> get inheritedMethods {
    if (_inheritedMethods == null) {
      _inheritedMethods = <Method>[];
      var methodNames = declaredMethods.map((m) => m.element.name).toSet();

      var inheritedMethodElements = _inheritedElements.where((e) {
        return (e is MethodElement &&
            !e.isOperator &&
            e is! PropertyAccessorElement &&
            !methodNames.contains(e.name));
      }).toSet();

      for (var e in inheritedMethodElements) {
        Method m = ModelElement.from(e, library, packageGraph,
            enclosingContainer: this);
        _inheritedMethods.add(m);
      }
    }
    return _inheritedMethods;
  }

  Iterable<Method> get publicInheritedMethods =>
      model_utils.filterNonPublic(inheritedMethods);

  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

  /*lazy final*/
  List<Operator> _inheritedOperators;

  Iterable<Operator> get inheritedOperators {
    if (_inheritedOperators == null) {
      _inheritedOperators = [];
      var operatorNames = declaredOperators.map((o) => o.element.name).toSet();

      var inheritedOperatorElements = _inheritedElements.where((e) {
        return (e is MethodElement &&
            e.isOperator &&
            !operatorNames.contains(e.name));
      }).toSet();
      for (var e in inheritedOperatorElements) {
        Operator o = ModelElement.from(e, library, packageGraph,
            enclosingContainer: this);
        _inheritedOperators.add(o);
      }
    }
    return _inheritedOperators;
  }

  Iterable<Field> get inheritedFields => allFields.where((f) => f.isInherited);

  Iterable<DefinedElementType> get publicInterfaces => [];

  Iterable<Field> get publicInheritedFields =>
      model_utils.filterNonPublic(inheritedFields);

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  /// Returns true if [other] is a parent class for this class.
  bool _isInheritingFrom(InheritingContainer other) => superChain
      .map((et) => (et.modelElement as InheritingContainer))
      .contains(other);

  @Deprecated(
      'Public method intended to be private; will be removed as early as '
      'Dartdoc 1.0.0')
  bool isInheritingFrom(InheritingContainer other) => _isInheritingFrom(other);

  DefinedElementType _modelType;

  @override
  DefinedElementType get modelType =>
      _modelType ??= ElementType.from(element.thisType, library, packageGraph);

  /// Not the same as superChain as it may include mixins.
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  List<InheritingContainer> get inheritanceChain;

  List<DefinedElementType> get superChain {
    var typeChain = <DefinedElementType>[];
    var parent = supertype;
    while (parent != null) {
      typeChain.add(parent);
      if (parent.type is InterfaceType) {
        // Avoid adding [Object] to the superChain (_supertype already has this
        // check)
        if ((parent.type as InterfaceType)?.superclass?.superclass == null) {
          parent = null;
        } else {
          parent = ElementType.from(
              (parent.type as InterfaceType).superclass, library, packageGraph);
        }
      } else {
        parent = (parent.modelElement as Class).supertype;
      }
    }
    return typeChain;
  }

  Iterable<DefinedElementType> get publicSuperChain =>
      model_utils.filterNonPublic(superChain);

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      publicSuperChain.toList().reversed;

  List<ExecutableElement> __inheritedElements;

  List<ExecutableElement> get _inheritedElements {
    if (__inheritedElements == null) {
      if (element.isDartCoreObject) {
        return __inheritedElements = <ExecutableElement>[];
      }

      if (definingLibrary == null) {
        // [definingLibrary] may be null if [element] has been imported or
        // exported with a non-normalized URI, like "src//a.dart".
        // TODO(srawlins): It would be nice to allow references from such
        // libraries, but for now, PackageGraph.allLibraries is a Map with
        // LibraryElement keys, which include [Element.location] in their
        // `==` calculation; I think we should not key off of Elements.
        return __inheritedElements = <ExecutableElement>[];
      }

      var inheritance = definingLibrary.inheritanceManager;
      var cmap = inheritance.getInheritedConcreteMap2(element);
      var imap = inheritance.getInheritedMap2(element);

      List<ClassElement> inheritanceChainElements;

      var combinedMap = <String, ExecutableElement>{};
      for (var nameObj in cmap.keys) {
        combinedMap[nameObj.name] = cmap[nameObj];
      }
      for (var nameObj in imap.keys) {
        if (combinedMap[nameObj.name] != null) {
          // Elements in the inheritance chain starting from [this.element]
          // down to, but not including, [Object].
          inheritanceChainElements ??=
              inheritanceChain.map((c) => c.element).toList();
          // [packageGraph.specialClasses] is not available yet.
          bool _isDartCoreObject(ClassElement e) =>
              e.name == 'Object' && e.library.name == 'dart.core';
          if (!(inheritanceChainElements
                  .contains(imap[nameObj].enclosingElement) ||
              _isDartCoreObject(imap[nameObj].enclosingElement))) {
            print('wtf');
          }

          // If the concrete object from [InheritanceManager3.getInheritedConcreteMap2]
          // is farther from this class in the inheritance chain than the one
          // provided by InheritedMap2, prefer InheritedMap2.  This
          // correctly accounts for intermediate abstract classes that have
          // method/field implementations.
          if (inheritanceChainElements
                  .indexOf(combinedMap[nameObj.name].enclosingElement) <
              inheritanceChainElements
                  .indexOf(imap[nameObj].enclosingElement)) {
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

  List<Field> _allFields;

  List<Field> get allFields {
    if (_allFields == null) {
      _allFields = [];
      var inheritedAccessorElements = <PropertyAccessorElement>{}
        ..addAll(_inheritedElements.whereType<PropertyAccessorElement>());

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
      for (var f in element.fields) {
        var getterElement = f.getter;
        if (getterElement == null && accessorMap.containsKey(f.name)) {
          getterElement = accessorMap[f.name]
              .firstWhere((e) => e.isGetter, orElse: () => null);
        }
        var setterElement = f.setter;
        if (setterElement == null && accessorMap.containsKey(f.name)) {
          setterElement = accessorMap[f.name]
              .firstWhere((e) => e.isSetter, orElse: () => null);
        }
        _addSingleField(
            getterElement, setterElement, inheritedAccessorElements, f);
        accessorMap.remove(f.name);
      }

      // Now we only have inherited accessors who aren't associated with
      // anything in cls._fields.
      for (var fieldName in accessorMap.keys) {
        var elements = accessorMap[fieldName].toList();
        var getterElement =
            elements.firstWhere((e) => e.isGetter, orElse: () => null);
        var setterElement =
            elements.firstWhere((e) => e.isSetter, orElse: () => null);
        _addSingleField(
            getterElement, setterElement, inheritedAccessorElements);
      }
    }
    return _allFields;
  }

  @override
  Iterable<Field> get declaredFields => allFields.where((f) => !f.isInherited);

  /// Add a single Field to _fields.
  ///
  /// If [f] is not specified, pick the FieldElement from the PropertyAccessorElement
  /// whose enclosing class inherits from the other (defaulting to the getter)
  /// and construct a Field using that.
  void _addSingleField(
      PropertyAccessorElement getterElement,
      PropertyAccessorElement setterElement,
      Set<PropertyAccessorElement> inheritedAccessors,
      [FieldElement f]) {
    var getter =
        ContainerAccessor.from(getterElement, inheritedAccessors, this);
    var setter =
        ContainerAccessor.from(setterElement, inheritedAccessors, this);
    // Rebind getterElement/setterElement as ModelElement.from can resolve
    // MultiplyInheritedExecutableElements or resolve Members.
    getterElement = getter?.element;
    setterElement = setter?.element;
    assert(!(getter == null && setter == null));
    if (f == null) {
      // Pick an appropriate FieldElement to represent this element.
      // Only hard when dealing with a synthetic Field.
      if (getter != null && setter == null) {
        f = getterElement.variable;
      } else if (getter == null && setter != null) {
        f = setterElement.variable;
      } else {
        /* getter != null && setter != null */
        // In cases where a Field is composed of two Accessors defined in
        // different places in the inheritance chain, there are two FieldElements
        // for this single Field we're trying to compose.  Pick the one closest
        // to this class on the inheritance chain.
        if (setter.enclosingElement is Class &&
            (setter.enclosingElement as Class)
                ._isInheritingFrom(getter.enclosingElement)) {
          f = setterElement.variable;
        } else {
          f = getterElement.variable;
        }
      }
    }
    Field field;
    if ((getter == null || getter.isInherited) &&
        (setter == null || setter.isInherited)) {
      // Field is 100% inherited.
      field = ModelElement.fromPropertyInducingElement(f, library, packageGraph,
          enclosingContainer: this, getter: getter, setter: setter);
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      field = ModelElement.fromPropertyInducingElement(f, library, packageGraph,
          getter: getter, setter: setter);
    }
    _allFields.add(field);
  }

  Iterable<Method> _declaredMethods;

  @override
  Iterable<Method> get declaredMethods =>
      _declaredMethods ??= element.methods.map((e) {
        return ModelElement.from(e, library, packageGraph) as Method;
      });

  List<TypeParameter> _typeParameters;

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    _typeParameters ??= element.typeParameters.map((f) {
      var lib = Library(f.enclosingElement.library, packageGraph);
      return ModelElement.from(f, lib, packageGraph) as TypeParameter;
    }).toList();
    return _typeParameters;
  }

  Iterable<Field> _instanceFields;

  @override
  Iterable<Field> get instanceFields =>
      _instanceFields ??= allFields.where((f) => !f.isStatic);

  @override
  bool get publicInheritedInstanceFields =>
      publicInstanceFields.every((f) => f.isInherited);

  @override
  Iterable<Field> get constantFields => allFields.where((f) => f.isConst);
}
