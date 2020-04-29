// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:quiver/iterables.dart' as quiver;

class Class extends Container
    with TypeParameters, Categorization, ExtensionTarget
    implements EnclosedElement {
  List<DefinedElementType> mixins;
  DefinedElementType supertype;
  List<DefinedElementType> _interfaces;
  List<Constructor> _constructors;
  List<Operator> _inheritedOperators;
  List<Method> _inheritedMethods;
  List<Field> _inheritedProperties;

  Class(ClassElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph) {
    packageGraph.specialClasses.addSpecial(this);
    mixins = element.mixins
        .map((f) {
          DefinedElementType t = ElementType.from(f, library, packageGraph);
          return t;
        })
        .where((mixin) => mixin != null)
        .toList(growable: false);

    if (element.supertype != null &&
        element.supertype.element.supertype != null) {
      supertype = ElementType.from(element.supertype, library, packageGraph);
    }

    _interfaces = element.interfaces
        .map((f) =>
            ElementType.from(f, library, packageGraph) as DefinedElementType)
        .toList(growable: false);
  }

  Constructor _defaultConstructor;

  Constructor get defaultConstructor {
    _defaultConstructor ??= constructors
        .firstWhere((c) => c.isDefaultConstructor, orElse: () => null);
    return _defaultConstructor;
  }

  Iterable<Method> get allInstanceMethods =>
      quiver.concat([instanceMethods, inheritedMethods]);

  @override
  Iterable<Method> get allPublicInstanceMethods =>
      model_utils.filterNonPublic(allInstanceMethods);

  bool get allPublicInstanceMethodsInherited =>
      instanceMethods.every((f) => f.isInherited);

  @override
  Iterable<Field> get allInstanceFields =>
      quiver.concat([instanceProperties, inheritedProperties]);

  bool get allPublicInstancePropertiesInherited =>
      allPublicInstanceProperties.every((f) => f.isInherited);

  @override
  Iterable<Operator> get allOperators =>
      quiver.concat([operators, inheritedOperators]);

  bool get allPublicOperatorsInherited =>
      allPublicOperators.every((f) => f.isInherited);

  Map<Element, ModelElement> _allElements;

  Map<Element, ModelElement> get allElements {
    if (_allElements == null) {
      _allElements = {};
      for (var me in allModelElements) {
        assert(!_allElements.containsKey(me.element));
        _allElements[me.element] = me;
      }
    }
    return _allElements;
  }

  Map<String, List<ModelElement>> _allModelElementsByNamePart;

  /// Helper for `_MarkdownCommentReference._getResultsForClass`.
  Map<String, List<ModelElement>> get allModelElementsByNamePart {
    if (_allModelElementsByNamePart == null) {
      _allModelElementsByNamePart = {};
      for (var me in allModelElements) {
        _allModelElementsByNamePart.update(
            me.namePart, (List<ModelElement> v) => v..add(me),
            ifAbsent: () => <ModelElement>[me]);
      }
    }
    return _allModelElementsByNamePart;
  }

  /// This class might be canonical for elements it does not contain.
  /// See [Inheritable.canonicalEnclosingContainer].
  bool contains(Element element) => allElements.containsKey(element);

  Map<String, List<ModelElement>> _membersByName;

  /// Given a ModelElement that is a member of some other class, return
  /// a member of this class that has the same name and return type.
  ///
  /// This enables object substitution for canonicalization, such as Interceptor
  /// for Object.
  ModelElement memberByExample(ModelElement example) {
    if (_membersByName == null) {
      _membersByName = {};
      for (var me in allModelElements) {
        if (!_membersByName.containsKey(me.name)) {
          _membersByName[me.name] = [];
        }
        _membersByName[me.name].add(me);
      }
    }
    ModelElement member;
    var possibleMembers = _membersByName[example.name]
        .where((e) => e.runtimeType == example.runtimeType);
    if (example.runtimeType == Accessor) {
      possibleMembers = possibleMembers.where(
          (e) => (example as Accessor).isGetter == (e as Accessor).isGetter);
    }
    member = possibleMembers.first;
    assert(possibleMembers.length == 1);
    return member;
  }

  List<ModelElement> _allModelElements;

  List<ModelElement> get allModelElements {
    _allModelElements ??= List.from(
        quiver.concat([
          allInstanceMethods,
          allInstanceFields,
          allAccessors,
          allOperators,
          constants,
          constructors,
          staticMethods,
          staticProperties,
          typeParameters,
        ]),
        growable: false);
    return _allModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;

  List<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }

  List<Constructor> get constructors {
    if (_constructors != null) return _constructors;

    _constructors = element.constructors.map((e) {
      return ModelElement.from(e, library, packageGraph) as Constructor;
    }).toList(growable: true)
      ..sort(byName);

    return _constructors;
  }

  Iterable<Constructor> get publicConstructors =>
      model_utils.filterNonPublic(constructors);

  /// Returns the library that encloses this element.
  @override
  ModelElement get enclosingElement => library;

  @override
  ClassElement get element => super.element;

  @override
  String get fileName => '$name-class.$fileType';

  @override
  String get filePath => '${library.dirName}/$fileName';

  String get fullkind {
    if (isAbstract) return 'abstract $kind';
    return kind;
  }

  bool get hasPublicConstructors => publicConstructors.isNotEmpty;

  bool get hasPublicImplementors => publicImplementors.isNotEmpty;

  bool get hasInstanceProperties => instanceProperties.isNotEmpty;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  @override
  bool get hasPublicMethods =>
      publicInstanceMethods.isNotEmpty || publicInheritedMethods.isNotEmpty;

  bool get hasPublicMixins => publicMixins.isNotEmpty;

  @override
  bool get hasModifiers =>
      hasPublicMixins ||
      hasAnnotations ||
      hasPublicInterfaces ||
      hasPublicSuperChainReversed ||
      hasPublicImplementors ||
      hasPotentiallyApplicableExtensions;

  @override
  bool get hasPublicOperators =>
      publicOperators.isNotEmpty || publicInheritedOperators.isNotEmpty;

  @override
  bool get hasPublicProperties =>
      publicInheritedProperties.isNotEmpty ||
      publicInstanceProperties.isNotEmpty;

  @override
  bool get hasPublicStaticMethods => publicStaticMethods.isNotEmpty;

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

  /// Returns all the implementors of this class.
  Iterable<Class> get publicImplementors {
    return model_utils.filterNonPublic(
        model_utils.findCanonicalFor(packageGraph.implementors[href] ?? []));
  }

  List<Method> get inheritedMethods {
    if (_inheritedMethods == null) {
      _inheritedMethods = <Method>[];
      var methodNames = methods.map((m) => m.element.name).toSet();

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
      _inheritedMethods.sort(byName);
    }
    return _inheritedMethods;
  }

  Iterable get publicInheritedMethods =>
      model_utils.filterNonPublic(inheritedMethods);

  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

  List<Operator> get inheritedOperators {
    if (_inheritedOperators == null) {
      _inheritedOperators = [];
      var operatorNames = operators.map((o) => o.element.name).toSet();

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
      _inheritedOperators.sort(byName);
    }
    return _inheritedOperators;
  }

  Iterable<Operator> get publicInheritedOperators =>
      model_utils.filterNonPublic(inheritedOperators);

  List<Field> get inheritedProperties {
    _inheritedProperties ??= allFields.where((f) => f.isInherited).toList()
      ..sort(byName);
    return _inheritedProperties;
  }

  Iterable<Field> get publicInheritedProperties =>
      model_utils.filterNonPublic(inheritedProperties);

  Iterable<Method> get publicInstanceMethods => instanceMethods;

  List<DefinedElementType> get interfaces => _interfaces;

  Iterable<DefinedElementType> get publicInterfaces =>
      model_utils.filterNonPublic(interfaces);

  bool get isAbstract => element.isAbstract;

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  bool get isErrorOrException {
    bool _doCheck(ClassElement element) {
      return (element.library.isDartCore &&
          (element.name == 'Exception' || element.name == 'Error'));
    }

    // if this class is itself Error or Exception, return true
    if (_doCheck(element)) return true;

    return element.allSupertypes.map((t) => t.element).any(_doCheck);
  }

  /// Returns true if [other] is a parent class for this class.
  @override
  bool isInheritingFrom(covariant Class other) =>
      superChain.map((et) => (et.element as Class)).contains(other);

  @override
  String get kind => 'class';

  Iterable<DefinedElementType> get publicMixins =>
      model_utils.filterNonPublic(mixins);

  @override
  DefinedElementType get modelType => super.modelType;

  /// Not the same as superChain as it may include mixins.
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  List<Class> _inheritanceChain;

  List<Class> get inheritanceChain {
    if (_inheritanceChain == null) {
      _inheritanceChain = [];
      _inheritanceChain.add(this);

      /// Caching should make this recursion a little less painful.
      for (var c in mixins.reversed.map((e) => (e.element as Class))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }

      for (var c in superChain.map((e) => (e.element as Class))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }

      /// Interfaces need to come last, because classes in the superChain might
      /// implement them even when they aren't mentioned.
      _inheritanceChain.addAll(
          interfaces.expand((e) => (e.element as Class).inheritanceChain));
    }
    return _inheritanceChain.toList(growable: false);
  }

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
        parent = (parent.element as Class).supertype;
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

      var inheritance = definingLibrary.inheritanceManager;
      var classType = element.thisType;
      var cmap = inheritance.getInheritedConcreteMap(classType);
      var imap = inheritance.getInheritedMap(classType);

      var combinedMap = <String, ExecutableElement>{};
      for (var nameObj in cmap.keys) {
        combinedMap[nameObj.name] = cmap[nameObj];
      }
      for (var nameObj in imap.keys) {
        combinedMap[nameObj.name] ??= imap[nameObj];
      }

      __inheritedElements = combinedMap.values.toList();
    }
    return __inheritedElements;
  }

  List<Field> _fields;

  @override
  List<Field> get allFields {
    if (_fields == null) {
      _fields = [];
      var inheritedAccessors = <PropertyAccessorElement>{}
        ..addAll(_inheritedElements.whereType<PropertyAccessorElement>());

      // This structure keeps track of inherited accessors, allowing lookup
      // by field name (stripping the '=' from setters).
      var accessorMap = <String, List<PropertyAccessorElement>>{};
      for (var accessorElement in inheritedAccessors) {
        var name = accessorElement.name.replaceFirst('=', '');
        accessorMap.putIfAbsent(name, () => []);
        accessorMap[name].add(accessorElement);
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
        _addSingleField(getterElement, setterElement, inheritedAccessors, f);
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
        _addSingleField(getterElement, setterElement, inheritedAccessors);
      }

      _fields.sort(byName);
    }
    return _fields;
  }

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
        if ((setter.enclosingElement)
            .isInheritingFrom(getter.enclosingElement)) {
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
      field = ModelElement.from(f, library, packageGraph,
          enclosingContainer: this, getter: getter, setter: setter);
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      field = ModelElement.from(f, library, packageGraph,
          getter: getter, setter: setter);
    }
    _fields.add(field);
  }

  List<Method> _methods;

  @override
  List<Method> get methods {
    _methods ??= element.methods.map((e) {
      return ModelElement.from(e, library, packageGraph) as Method;
    }).toList(growable: false)
      ..sort(byName);
    return _methods;
  }

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

  @override
  bool operator ==(o) =>
      o is Class &&
      name == o.name &&
      o.library.name == library.name &&
      o.library.package.name == library.package.name;
}
