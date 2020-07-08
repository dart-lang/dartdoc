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

/// A [Container] defined with a `class` declaration in Dart.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// **instance**: As with [Container], but also includes inherited children.
/// **inherited**: Filtered getters giving only inherited children.
class Class extends Container
    with TypeParameters, Categorization, ExtensionTarget
    implements EnclosedElement {
  List<DefinedElementType> mixins;
  DefinedElementType supertype;
  List<DefinedElementType> _interfaces;
  List<Operator> _inheritedOperators;
  List<Method> _inheritedMethods;

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

  @override
  Iterable<Method> get instanceMethods =>
      quiver.concat([super.instanceMethods, inheritedMethods]);

  bool get publicInheritedInstanceMethods =>
      instanceMethods.every((f) => f.isInherited);

  @override
  Iterable<Operator> get instanceOperators =>
      quiver.concat([super.instanceOperators, inheritedOperators]);

  List<ModelElement> _allModelElements;
  @override
  List<ModelElement> get allModelElements {
    _allModelElements ??= List.from(
        quiver.concat([
          super.allModelElements,
          constructors,
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

  Iterable<Constructor> get constructors => element.constructors.map((e) {
        return ModelElement.from(e, library, packageGraph) as Constructor;
      });

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

  bool get hasPublicConstructors => publicConstructorsSorted.isNotEmpty;

  List<Constructor> _publicConstructorsSorted;
  List<Constructor> get publicConstructorsSorted =>
      _publicConstructorsSorted ??= publicConstructors.toList()..sort(byName);

  bool get hasPublicImplementors => publicImplementors.isNotEmpty;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  bool get hasPublicMixins => publicMixins.isNotEmpty;

  @override
  bool get hasModifiers =>
      hasPublicMixins ||
      hasAnnotations ||
      hasPublicInterfaces ||
      hasPublicSuperChainReversed ||
      hasPublicImplementors ||
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

  /// Returns all the implementors of this class.
  Iterable<Class> get publicImplementors {
    return model_utils.filterNonPublic(
        model_utils.findCanonicalFor(packageGraph.implementors[href] ?? []));
  }

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

  Iterable get publicInheritedMethods =>
      model_utils.filterNonPublic(inheritedMethods);

  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

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

  Iterable<Operator> get publicInheritedInstanceOperators =>
      model_utils.filterNonPublic(inheritedOperators);

  Iterable<Field> get inheritedFields => allFields.where((f) => f.isInherited);

  Iterable<Field> get publicInheritedFields =>
      model_utils.filterNonPublic(inheritedFields);

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

  bool get publicInheritedInstanceFields =>
      publicInstanceFields.every((f) => f.isInherited);

  @override
  Iterable<Field> get constantFields => allFields.where((f) => f.isConst);

  @override
  bool operator ==(o) =>
      o is Class &&
      name == o.name &&
      o.library.name == library.name &&
      o.library.package.name == library.package.name;
}
