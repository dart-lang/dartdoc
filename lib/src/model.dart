// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:collection' show UnmodifiableListView;
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart'
    show
        AnnotatedNode,
        Declaration,
        FieldDeclaration,
        VariableDeclaration,
        VariableDeclarationList;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
// TODO(jcollins-g): Stop using internal analyzer structures somehow.
import 'package:analyzer/src/generated/resolver.dart'
    show Namespace, NamespaceBuilder, InheritanceManager;
import 'package:analyzer/src/generated/utilities_dart.dart' show ParameterKind;
import 'package:analyzer/src/dart/element/member.dart' show Member;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import 'config.dart';
import 'element_type.dart';
import 'line_number_cache.dart';
import 'markdown_processor.dart' show Documentation;
import 'model_utils.dart';
import 'package_meta.dart' show PackageMeta, FileContents;
import 'utils.dart';

Map<String, Map<String, List<Map<String, dynamic>>>> __crossdartJson;

Map<String, Map<String, List<Map<String, dynamic>>>> get _crossdartJson {
  if (__crossdartJson == null) {
    if (config != null) {
      var crossdartFile =
          new File(p.join(config.inputDir.path, "crossdart.json"));
      if (crossdartFile.existsSync()) {
        __crossdartJson = JSON.decode(crossdartFile.readAsStringSync())
            as Map<String, Map<String, List<Map<String, dynamic>>>>;
      } else {
        __crossdartJson = {};
      }
    } else {
      __crossdartJson = {};
    }
  }
  return __crossdartJson;
}

int byName(Nameable a, Nameable b) =>
    compareAsciiLowerCaseNatural(a.name, b.name);

/// Items mapped less than zero will sort before custom annotations.
/// Items mapped above zero are sorted after custom annotations.
/// Items mapped to zero will sort alphabetically among custom annotations.
/// Custom annotations are assumed to be any annotation or feature not in this
/// map.
const Map<String, int> featureOrder = const {
  'read-only': 1,
  'write-only': 1,
  'read / write': 1,
  'final': 2,
  'inherited': 3,
};

int byFeatureOrdering(String a, String b) {
  int scoreA = 0;
  int scoreB = 0;

  if (featureOrder.containsKey(a)) scoreA = featureOrder[a];
  if (featureOrder.containsKey(b)) scoreB = featureOrder[b];

  if (scoreA < scoreB) return -1;
  if (scoreA > scoreB) return 1;
  return compareAsciiLowerCaseNatural(a, b);
}

final RegExp _locationSplitter = new RegExp(r"(package:|[\\/;.])");

/// Mixin for subclasses of ModelElement representing Elements that can be
/// inherited from one class to another.
///
/// Inheritable adds yet another view to help canonicalization for member
/// [ModelElement]s -- [Inheritable.definingEnclosingElement].  With this
/// as an end point, we can search the inheritance chain between this instance and
/// the [Inheritable.definingEnclosingElement] in [Inheritable.canonicalEnclosingElement],
/// for the canonical [Class] closest to where this member was defined.  We
/// can then know that when we find [Inheritable.element] inside that [Class]'s
/// namespace, that's the one we should treat as canonical and implementors
/// of this class can use that knowledge to determine canonicalization.
///
/// We pick the class closest to the definingEnclosingElement so that all
/// children of that class inheriting the same member will point to the same
/// place in the documentation, and we pick a canonical class because that's
/// the one in the public namespace that will be documented.
abstract class Inheritable {
  Element get element;
  ModelElement get enclosingElement;
  Package get package;
  bool get isInherited;
  bool get isPublic;
  bool _canonicalEnclosingClassIsSet = false;
  Class _canonicalEnclosingClass;
  Class _definingEnclosingClass;

  ModelElement get definingEnclosingElement {
    if (_definingEnclosingClass == null) {
      _definingEnclosingClass = new ModelElement.from(element.enclosingElement,
          package.findOrCreateLibraryFor(element.enclosingElement));
    }
    return _definingEnclosingClass;
  }

  ModelElement get canonicalEnclosingElement {
    Element searchElement = element;
    if (!_canonicalEnclosingClassIsSet) {
      if (isInherited) {
        searchElement = searchElement is Member
            ? Package.getBasestElement(searchElement)
            : searchElement;
        // TODO(jcollins-g): generate warning if an inherited element's definition
        // is in an intermediate non-canonical class in the inheritance chain?
        for (Class c in inheritance.reversed) {
          // Filter out mixins.
          if (c.contains(searchElement)) {
            Class canonicalC = package.findCanonicalModelElementFor(c.element);
            // TODO(jcollins-g): invert this lookup so traversal is recursive
            // starting from the ModelElement.
            if (canonicalC != null) {
              assert(canonicalC.contains(searchElement));
              _canonicalEnclosingClass = c;
              break;
            }
          }
        }
        if (definingEnclosingElement.isCanonical && isPublic) {
          assert(definingEnclosingElement == _canonicalEnclosingClass);
        }
      } else {
        if (enclosingElement.isCanonical) {
          _canonicalEnclosingClass = enclosingElement;
        }
      }
      _canonicalEnclosingClassIsSet = true;
    }
    return _canonicalEnclosingClass;
  }

  List<Class> get inheritance {
    List<Class> inheritance = [];
    inheritance.addAll((enclosingElement as Class).inheritanceChain);
    if (!inheritance.contains(definingEnclosingElement) &&
        definingEnclosingElement != null) {
      // TODO(jcollins-g): Why does this happen?
      inheritance.add(definingEnclosingElement);
    }
    // TODO(jcollins-g): Sometimes, we don't get Object added on.  Why?
    if (inheritance.last != package.objectElement &&
        package.objectElement != null) inheritance.add(package.objectElement);
    return inheritance;
  }
}

/// A getter or setter that is a member of a Class.
class InheritableAccessor extends Accessor with Inheritable {
  /// Factory will return an [InheritableAccessor] with isInherited = true
  /// if [element] is in [inheritedAccessors].
  factory InheritableAccessor.from(PropertyAccessorElement element,
      Set<PropertyAccessorElement> inheritedAccessors, Class enclosingClass) {
    if (element == null) return null;
    if (inheritedAccessors.contains(element)) {
      return new ModelElement.from(element, enclosingClass.library,
          enclosingClass: enclosingClass);
    }
    return new ModelElement.from(element, enclosingClass.library);
  }

  ModelElement _enclosingElement;
  bool _isInherited = false;
  InheritableAccessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  InheritableAccessor.inherited(
      PropertyAccessorElement element, Library library, this._enclosingElement)
      : super(element, library) {
    _isInherited = true;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  Class get enclosingElement {
    if (_enclosingElement == null) {
      _enclosingElement = super.enclosingElement;
    }
    return _enclosingElement;
  }
}

/// Getters and setters.
class Accessor extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  GetterSetterCombo _enclosingCombo;

  Accessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  ModelElement get enclosingCombo => _enclosingCombo;

  /// Call exactly once to set the enclosing combo for this Accessor.
  void set enclosingCombo(GetterSetterCombo combo) {
    assert(_enclosingCombo == null || combo == _enclosingCombo);
    _enclosingCombo = combo;
  }

  @override
  String get computeDocumentationComment {
    if (element.isSynthetic) {
      return (element as PropertyAccessorElement).variable.documentationComment;
    }
    return stripComments(super.computeDocumentationComment);
  }

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    if (enclosingCombo != null) {
      enclosingCombo.warn(kind,
          message: message,
          referredFrom: referredFrom,
          extendedDebug: extendedDebug);
    } else {
      super.warn(kind,
          message: message,
          referredFrom: referredFrom,
          extendedDebug: extendedDebug);
    }
  }

  @override
  ModelElement get enclosingElement {
    if (_accessor.enclosingElement is CompilationUnitElement) {
      return package
          .findOrCreateLibraryFor(_accessor.enclosingElement.enclosingElement);
    }

    return new ModelElement.from(_accessor.enclosingElement, library);
  }

  @override
  bool get isCanonical => enclosingCombo.isCanonical;

  bool get isInherited => false;

  @override
  String get href {
    return enclosingCombo.href;
  }

  bool get isGetter => _accessor.isGetter;

  bool _overriddenElementIsSet = false;
  ModelElement _overriddenElement;
  @override
  Accessor get overriddenElement {
    assert(package.allLibrariesAdded);
    if (!_overriddenElementIsSet) {
      _overriddenElementIsSet = true;
      Element parent = element.enclosingElement;
      if (parent is ClassElement) {
        for (InterfaceType t in getAllSupertypes(parent)) {
          Element accessor = this.isGetter
              ? t.getGetter(element.name)
              : t.getSetter(element.name);
          if (accessor != null) {
            if (accessor is Member) {
              accessor = Package.getBasestElement(accessor);
            }
            Class parentClass = new ModelElement.from(
                t.element, package.findOrCreateLibraryFor(t.element));
            List<Field> possibleFields = [];
            possibleFields.addAll(parentClass.allInstanceProperties);
            possibleFields.addAll(parentClass.staticProperties);
            String fieldName = accessor.name.replaceFirst('=', '');
            Field foundField = possibleFields.firstWhere(
                (f) => f.element.name == fieldName,
                orElse: () => null);
            if (foundField != null) {
              if (this.isGetter) {
                _overriddenElement = foundField.getter;
              } else {
                _overriddenElement = foundField.setter;
              }
              assert(!(_overriddenElement as Accessor).isInherited);
              break;
            }
          }
        }
      }
    }
    return _overriddenElement;
  }

  @override
  String get kind => 'accessor';

  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);
}

class Class extends ModelElement implements EnclosedElement {
  List<ElementType> _mixins;
  ElementType _supertype;
  List<ElementType> _interfaces;
  List<Constructor> _constructors;
  List<Method> _allMethods;
  List<Operator> _operators;
  List<Operator> _inheritedOperators;
  List<Operator> _allOperators;
  final Set<Operator> _genPageOperators = new Set();
  List<Method> _inheritedMethods;
  List<Method> _staticMethods;
  List<Method> _instanceMethods;
  List<Method> _allInstanceMethods;
  final Set<Method> _genPageMethods = new Set();
  List<Field> _fields;
  List<Field> _staticFields;
  List<Field> _constants;
  List<Field> _instanceFields;
  List<Field> _inheritedProperties;
  List<Field> _allInstanceProperties;

  Class(ClassElement element, Library library) : super(element, library) {
    Package p = library.package;
    _modelType = new ElementType(_cls.type, this);

    _mixins = _cls.mixins
        .map((f) {
          Library lib = new Library(f.element.library, p);
          ElementType t =
              new ElementType(f, new ModelElement.from(f.element, lib));
          return t;
        })
        .where((mixin) => mixin != null)
        .toList(growable: false);

    if (_cls.supertype != null && _cls.supertype.element.supertype != null) {
      Library lib = package.findOrCreateLibraryFor(_cls.supertype.element);

      _supertype = new ElementType(
          _cls.supertype, new ModelElement.from(_cls.supertype.element, lib));
    }

    _interfaces = _cls.interfaces
        .map((f) {
          var lib = new Library(f.element.library, p);
          var t = new ElementType(f, new ModelElement.from(f.element, lib));
          var exclude = t.element.element.isPrivate;
          if (exclude) {
            return null;
          } else {
            return t;
          }
        })
        .where((it) => it != null)
        .toList(growable: false);
  }

  List<Method> get allInstanceMethods {
    if (_allInstanceMethods != null) return _allInstanceMethods;
    _allInstanceMethods = []
      ..addAll([]
        ..addAll(instanceMethods)
        ..sort(byName))
      ..addAll([]
        ..addAll(inheritedMethods)
        ..sort(byName));
    return _allInstanceMethods;
  }

  bool get allInstanceMethodsInherited =>
      instanceMethods.every((f) => f.isInherited);

  List<Field> get allInstanceProperties {
    if (_allInstanceProperties != null) return _allInstanceProperties;

    // TODO best way to make this a fixed length list?
    _allInstanceProperties = []
      ..addAll([]
        ..addAll(instanceProperties)
        ..sort(byName))
      ..addAll([]
        ..addAll(inheritedProperties)
        ..sort(byName));

    return _allInstanceProperties;
  }

  bool get allInstancePropertiesInherited =>
      instanceProperties.every((f) => f.isInherited);

  List<Operator> get allOperators {
    if (_allOperators != null) return _allOperators;
    _allOperators = []
      ..addAll([]
        ..addAll(operators)
        ..sort(byName))
      ..addAll([]
        ..addAll(inheritedOperators)
        ..sort(byName));
    return _allOperators;
  }

  bool get allOperatorsInherited => operators.every((f) => f.isInherited);

  List<Field> get constants {
    if (_constants != null) return _constants;
    _constants = _allFields.where((f) => f.isConst).toList(growable: false)
      ..sort(byName);

    return _constants;
  }

  Map<Element, ModelElement> _allElements;
  Map<Element, ModelElement> get allElements {
    if (_allElements == null) {
      _allElements = new Map();
      for (ModelElement me in allModelElements) {
        assert(!_allElements.containsKey(me.element));
        _allElements[me.element] = me;
      }
    }
    return _allElements;
  }

  bool contains(Element element) => allElements.containsKey(element);

  ModelElement findModelElement(Element element) => allElements[element];

  final Set<ModelElement> _allModelElements = new Set();
  List<ModelElement> get allModelElements {
    if (_allModelElements.isEmpty) {
      _allModelElements
        ..addAll(allInstanceMethods)
        ..addAll(allInstanceProperties)
        ..addAll(allOperators)
        ..addAll(constants)
        ..addAll(constructors)
        ..addAll(staticMethods)
        ..addAll(staticProperties)
        ..addAll(allInstanceMethods)
        ..addAll(_typeParameters);
    }
    return _allModelElements.toList();
  }

  List<ModelElement> _allCanonicalModelElements;
  List<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }

  List<Constructor> get constructors {
    if (_constructors != null) return _constructors;

    _constructors = _cls.constructors
        .map((e) {
          return new ModelElement.from(e, library);
        })
        .where((e) => e.isPublic)
        .toList(growable: true)
          ..sort(byName);

    return _constructors;
  }

  /// Returns the library that encloses this element.
  @override
  ModelElement get enclosingElement => library;

  String get fileName => "${name}-class.html";

  String get fullkind {
    if (isAbstract) return 'abstract $kind';
    return kind;
  }

  bool get hasConstants => constants.isNotEmpty;

  bool get hasConstructors => constructors.isNotEmpty;

  bool get hasImplementors => implementors.isNotEmpty;

  bool get hasInheritedMethods => inheritedMethods.isNotEmpty;

  bool get hasInstanceMethods => instanceMethods.isNotEmpty;

  bool get hasInstanceProperties => instanceProperties.isNotEmpty;

  bool get hasInterfaces => interfaces.isNotEmpty;

  bool get hasMethods =>
      instanceMethods.isNotEmpty || inheritedMethods.isNotEmpty;

  bool get hasMixins => mixins.isNotEmpty;

  bool get hasModifiers =>
      hasMixins ||
      hasAnnotations ||
      hasInterfaces ||
      hasSupertype ||
      hasImplementors;

  bool get hasOperators =>
      operators.isNotEmpty || inheritedOperators.isNotEmpty;

  bool get hasProperties =>
      inheritedProperties.isNotEmpty || instanceProperties.isNotEmpty;

  bool get hasStaticMethods => staticMethods.isNotEmpty;

  bool get hasStaticProperties => staticProperties.isNotEmpty;

  bool get hasSupertype =>
      (supertype != null && supertype.element != package.objectElement);

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/$fileName';
  }

  /// Returns all the implementors of the class specified.
  List<Class> get implementors {
    return (package._implementors[href] != null
            ? package._implementors[href]
            : [])
        .toList(growable: false) as List<Class>;
  }

  List<Method> get inheritedMethods {
    if (_inheritedMethods != null) return _inheritedMethods;

    Map<String, ExecutableElement> cmap =
        library.inheritanceManager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        library.inheritanceManager.getMembersInheritedFromInterfaces(element);

    // remove methods that exist on this class
    _methods.forEach((method) {
      cmap.remove(method.name);
      imap.remove(method.name);
    });

    _inheritedMethods = [];
    List<ExecutableElement> values = [];
    Set<String> uniqueNames = new Set();

    instanceProperties.forEach((f) {
      if (f.setter != null) uniqueNames.add(f.setter.element.name);
      if (f.getter != null) uniqueNames.add(f.getter.element.name);
    });

    for (String key in cmap.keys) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(key)) continue;

      uniqueNames.add(key);
      values.add(cmap[key]);
    }

    for (String key in imap.keys) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(key)) continue;

      uniqueNames.add(key);
      values.add(imap[key]);
    }

    for (ExecutableElement value in values) {
      if (value != null &&
          value is MethodElement &&
          !value.isOperator &&
          value.enclosingElement != null) {
        Method m;
        if (!package.isDocumented(value.enclosingElement)) {
          m = new ModelElement.from(value, library, enclosingClass: this);
          if (m.isPublic) {
            _inheritedMethods.add(m);
            _genPageMethods.add(m);
          }
        } else {
          m = new ModelElement.from(value, library, enclosingClass: this);
          if (m.isPublic) _inheritedMethods.add(m);
        }
      }
    }

    _inheritedMethods.sort(byName);

    return _inheritedMethods;
  }

  // TODO(jcollins-g): this is very copy-paste from inheritedMethods that the
  // constructor is always [ModelElement.from].  Fix this.
  List<Operator> get inheritedOperators {
    if (_inheritedOperators != null) return _inheritedOperators;
    Map<String, ExecutableElement> cmap =
        library.inheritanceManager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        library.inheritanceManager.getMembersInheritedFromInterfaces(element);
    operators.forEach((operator) {
      cmap.remove(operator.element.name);
      imap.remove(operator.element.name);
    });
    _inheritedOperators = [];
    Map<String, ExecutableElement> values = {};

    bool _isInheritedOperator(ExecutableElement value) {
      if (value != null &&
          value is MethodElement &&
          !value.isPrivate &&
          value.isOperator &&
          value.enclosingElement != null) {
        return true;
      }
      return false;
    }

    for (String key in imap.keys) {
      ExecutableElement value = imap[key];
      if (_isInheritedOperator(value)) {
        values.putIfAbsent(value.name, () => value);
      }
    }

    for (String key in cmap.keys) {
      ExecutableElement value = cmap[key];
      if (_isInheritedOperator(value)) {
        values.putIfAbsent(value.name, () => value);
      }
    }

    for (ExecutableElement value in values.values) {
      if (!package.isDocumented(value.enclosingElement)) {
        Operator o =
            new ModelElement.from(value, library, enclosingClass: this);
        _inheritedOperators.add(o);
        _genPageOperators.add(o);
      } else {
        _inheritedOperators
            .add(new ModelElement.from(value, library, enclosingClass: this));
      }
    }

    _inheritedOperators.sort(byName);

    return _inheritedOperators;
  }

  List<Field> get inheritedProperties {
    if (_inheritedProperties == null) {
      _inheritedProperties = _allFields.where((f) => f.isInherited).toList()
        ..sort(byName);
    }
    return _inheritedProperties;
  }

  List<Method> get instanceMethods {
    if (_instanceMethods != null) return _instanceMethods;

    _instanceMethods = _methods
        .where((m) => !m.isStatic && !m.isOperator)
        .toList(growable: false)
          ..sort(byName);

    _genPageMethods.addAll(_instanceMethods);
    return _instanceMethods;
  }

  List<Field> get instanceProperties {
    if (_instanceFields != null) return _instanceFields;
    _instanceFields = _allFields
        .where((f) => !f.isStatic && !f.isInherited)
        .toList(growable: false)
          ..sort(byName);

    return _instanceFields;
  }

  List<ElementType> get interfaces => _interfaces;

  bool get isAbstract => _cls.isAbstract;

  // TODO(jcollins-g): Something still not quite right with privacy detection,
  // we shouldn't be checking for underscores here.
  @override
  bool get isCanonical => super.isCanonical && !name.startsWith('_');

  bool get isErrorOrException {
    bool _doCheck(InterfaceType type) {
      return (type.element.library.isDartCore &&
          (type.name == 'Exception' || type.name == 'Error'));
    }

    // if this class is itself Error or Exception, return true
    if (_doCheck(_cls.type)) return true;

    return _cls.allSupertypes.any(_doCheck);
  }

  /// Returns true if [other] is a parent class or mixin for this class.
  bool isInheritingFrom(Class other) =>
      superChain.map((et) => (et.element as Class)).contains(other);

  @override
  String get kind => 'class';

  List<Method> get methodsForPages => _genPageMethods.toList(growable: false);

  List<ElementType> get mixinsRaw => _mixins;

  // TODO(jcollins-g): This method knows nothing about public/private or
  // canonicalization of elements not in this package.  Fix this when we add
  // multiple-package awareness.
  List<ElementType> filterNonPublicTypes(List<ElementType> rawTypes) {
    List<ElementType> publicList = [];
    for (ElementType type in rawTypes) {
      if (!hasPrivateName(type.element.element)) publicList.add(type);
    }
    return publicList;
  }

  List<ElementType> get mixins => filterNonPublicTypes(mixinsRaw);

  @override
  String get nameWithGenerics {
    if (!modelType.isParameterizedType) return name;
    return '$name&lt;${_typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  List<Operator> get operators {
    if (_operators != null) return _operators;

    _operators = _methods.where((m) => m.isOperator).toList(growable: false)
      ..sort(byName);
    _genPageOperators.addAll(_operators);

    return _operators;
  }

  List<Operator> get operatorsForPages =>
      new UnmodifiableListView(_genPageOperators.toList());

  // TODO: make this method smarter about hierarchies and overrides. Right
  // now, we're creating a flat list. We're not paying attention to where
  // these methods are actually coming from. This might turn out to be a
  // problem if we want to show that info later.
  List<Field> _propertiesForPages;
  List<Field> get propertiesForPages {
    if (_propertiesForPages == null) {
      _propertiesForPages = []
        ..addAll(instanceProperties)
        ..addAll(inheritedProperties)
        ..sort(byName);
    }
    return _propertiesForPages;
  }

  List<Method> get staticMethods {
    if (_staticMethods != null) return _staticMethods;

    _staticMethods = _methods.where((m) => m.isStatic).toList(growable: false)
      ..sort(byName);

    return _staticMethods;
  }

  List<Field> get staticProperties {
    if (_staticFields != null) return _staticFields;
    _staticFields = _allFields
        .where((f) => f.isStatic)
        .where((f) => !f.isConst)
        .toList(growable: false)
          ..sort(byName);

    return _staticFields;
  }

  /// Not the same as superChain as it may include mixins.
  List<Class> _inheritanceChain;
  List<Class> get inheritanceChain {
    if (_inheritanceChain == null) {
      _inheritanceChain = [];
      _inheritanceChain.add(this);
      _inheritanceChain
          .addAll(mixinsRaw.reversed.map((e) => (e.returnElement as Class)));

      /// Caching should make this recursion a little less painful.
      for (Class c in superChainRaw.map((e) => (e.returnElement as Class))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }
    }
    return _inheritanceChain.toList(growable: false);
  }

  List<ElementType> get superChainRaw {
    List<ElementType> typeChain = [];
    var parent = _supertype;
    while (parent != null) {
      typeChain.add(parent);
      parent = (parent.element as Class)._supertype;
    }
    return typeChain;
  }

  List<ElementType> get superChainRawReversed =>
      superChainRaw.reversed.toList();
  List<ElementType> get superChain => filterNonPublicTypes(superChainRaw);
  List<ElementType> get superChainReversed => superChain.reversed.toList();

  ElementType get supertype => _supertype;

  List<Field> get _allFields {
    if (_fields != null) return _fields;
    _fields = [];
    Map<String, ExecutableElement> cmap =
        library.inheritanceManager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        library.inheritanceManager.getMembersInheritedFromInterfaces(element);

    Set<PropertyAccessorElement> inheritedAccessors = new Set();
    inheritedAccessors.addAll(cmap.values
        .where((e) => e is PropertyAccessorElement)
        .map((e) => Package.getBasestElement(e) as PropertyAccessorElement));

    // Interfaces are subordinate to members inherited from classes, so don't
    // add this to our accessor set if we already have something inherited from classes.
    inheritedAccessors.addAll(imap.values
        .where((e) => e is PropertyAccessorElement && !cmap.containsKey(e.name))
        .map((e) => Package.getBasestElement(e) as PropertyAccessorElement));

    assert(!inheritedAccessors.any((e) => e is Member));
    // This structure keeps track of inherited accessors, allowing lookup
    // by field name (stripping the '=' from setters).
    Map<String, List<PropertyAccessorElement>> accessorMap = new Map();
    for (PropertyAccessorElement accessorElement in inheritedAccessors) {
      String name = accessorElement.name.replaceFirst('=', '');
      accessorMap.putIfAbsent(name, () => []);
      accessorMap[name].add(accessorElement);
    }

    // For half-inherited fields, the analyzer only links the non-inherited
    // to the [FieldElement].  Compose our [Field] class by hand by looking up
    // inherited accessors that may be related.
    for (FieldElement f in _cls.fields) {
      PropertyAccessorElement getterElement = f.getter;
      if (getterElement == null && accessorMap.containsKey(f.name)) {
        getterElement = accessorMap[f.name]
            .firstWhere((e) => e.isGetter, orElse: () => null);
      }
      PropertyAccessorElement setterElement = f.setter;
      if (setterElement == null && accessorMap.containsKey(f.name)) {
        setterElement = accessorMap[f.name]
            .firstWhere((e) => e.isSetter, orElse: () => null);
      }
      _addSingleField(getterElement, setterElement, inheritedAccessors, f);
      accessorMap.remove(f.name);
    }

    // Now we only have inherited accessors who aren't associated with
    // anything in cls._fields.
    for (String fieldName in accessorMap.keys) {
      List<PropertyAccessorElement> elements = accessorMap[fieldName]
          .map((e) => Package.getBasestElement(e))
          .toList();
      PropertyAccessorElement getterElement =
          elements.firstWhere((e) => e.isGetter, orElse: () => null);
      PropertyAccessorElement setterElement =
          elements.firstWhere((e) => e.isSetter, orElse: () => null);
      _addSingleField(getterElement, setterElement, inheritedAccessors);
    }

    _fields.sort(byName);
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
    Accessor getter =
        new InheritableAccessor.from(getterElement, inheritedAccessors, this);
    Accessor setter =
        new InheritableAccessor.from(setterElement, inheritedAccessors, this);
    assert(!(getter == null && setter == null));
    if (f == null) {
      // Pick an appropriate FieldElement to represent this element.
      // Only hard when dealing with a synthetic Field.
      if (getter != null && setter == null) {
        f = Package.getBasestElement(getterElement.variable);
      } else if (getter == null && setter != null) {
        f = Package.getBasestElement(setterElement.variable);
      } else /* getter != null && setter != null */ {
        // In cases where a Field is composed of two Accessors defined in
        // different places in the inheritance chain, there are two FieldElements
        // for this single Field we're trying to compose.  Pick the one closest
        // to this class on the inheritance chain.
        if ((setter.enclosingElement as Class)
            .isInheritingFrom(getter.enclosingElement)) {
          f = Package.getBasestElement(setterElement.variable);
        } else {
          f = Package.getBasestElement(getterElement.variable);
        }
      }
    }
    Field field;
    if ((getter == null || getter.isInherited) &&
        (setter == null || setter.isInherited)) {
      // Field is 100% inherited.
      field = new ModelElement.from(f, library,
          enclosingClass: this, getter: getter, setter: setter);
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      field = new ModelElement.from(f, library, getter: getter, setter: setter);
    }
    if (field.isPublic) {
      _fields.add(field);
    }
  }

  ClassElement get _cls => (element as ClassElement);

  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _cls.methods
        .map((e) {
          return new ModelElement.from(e, library);
        })
        .where((e) => e.isPublic)
        .toList(growable: false)
          ..sort(byName);

    return _allMethods;
  }

  // a stronger hash?
  List<TypeParameter> get _typeParameters => _cls.typeParameters.map((f) {
        var lib = new Library(f.enclosingElement.library, package);
        return new ModelElement.from(f, lib);
      }).toList();

  @override
  bool operator ==(o) =>
      o is Class &&
      name == o.name &&
      o.library.name == library.name &&
      o.library.package.name == library.package.name;
}

class Constructor extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  Constructor(ConstructorElement element, Library library)
      : super(element, library);

  @override
  ModelElement get enclosingElement =>
      new ModelElement.from(_constructor.enclosingElement, library);

  String get fullKind {
    if (isConst) return 'const $kind';
    if (isFactory) return 'factory $kind';
    return kind;
  }

  @override
  String get fullyQualifiedName => '${library.name}.$name';

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/${_constructor.enclosingElement.name}/$name.html';
  }

  @override
  bool get isConst => _constructor.isConst;

  bool get isFactory => _constructor.isFactory;

  @override
  String get kind => 'constructor';

  @override
  String get name {
    String constructorName = element.name;
    Class c = new ModelElement.from(element.enclosingElement, library) as Class;
    if (constructorName.isEmpty) {
      return c.name;
    } else {
      return '${c.name}.$constructorName';
    }
  }

  String get shortName {
    if (name.contains('.')) {
      return name.substring(_constructor.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

  ConstructorElement get _constructor => (element as ConstructorElement);
}

/// Bridges the gap between model elements and packages,
/// both of which have documentation.
abstract class Documentable implements Warnable {
  String get name;
  String get documentation;
  String get documentationAsHtml;
  bool get hasDocumentation;
  bool get hasExtendedDocumentation;
  String get oneLineDoc;
  Documentable get overriddenDocumentedElement;
  Package get package;
}

class Dynamic extends ModelElement {
  Dynamic(Element element, Library library) : super(element, library);

  @override
  ModelElement get enclosingElement => throw new UnsupportedError('');

  @override
  String get href => throw new StateError('dynamic should not have an href');

  @override
  String get kind => 'dynamic';

  @override
  String get linkedName => 'dynamic';
}

/// An element that is enclosed by some other element.
///
/// Libraries are not enclosed.
abstract class EnclosedElement {
  ModelElement get enclosingElement;
}

class Enum extends Class {
  List<EnumField> _enumFields;

  Enum(ClassElement element, Library library) : super(element, library);

  @override
  List<EnumField> get constants {
    if (_enumFields != null) return _enumFields;

    // This is a hack to give 'values' an index of -1 and all other fields
    // their expected indices. https://github.com/dart-lang/dartdoc/issues/1176
    var index = -1;

    _enumFields = [];
    for (FieldElement f in _cls.fields.where((f) => f.isConst)) {
      // Enums do not have inheritance.
      Accessor accessor = new ModelElement.from(f.getter, library);
      EnumField enumField =
          new ModelElement.from(f, library, index: index++, getter: accessor);
      if (enumField.isPublic) _enumFields.add(enumField);
    }
    _enumFields.sort(byName);

    return _enumFields;
  }

  @override
  List<EnumField> get instanceProperties {
    return super
        .instanceProperties
        .map((Field p) => new ModelElement.from(p.element, p.library))
        .toList(growable: false);
  }

  @override
  List<Field> get propertiesForPages => allInstanceProperties;

  @override
  String get kind => 'enum';
}

/// Enum's fields are virtual, so we do a little work to create
/// usable values for the docs.
class EnumField extends Field {
  int _index;

  EnumField(
      FieldElement element, Library library, Accessor getter, Accessor setter)
      : super(element, library, getter, setter);

  EnumField.forConstant(
      this._index, FieldElement element, Library library, Accessor getter)
      : super(element, library, getter, null);

  @override
  String get constantValue {
    if (name == 'values') {
      return 'const List&lt;${_field.enclosingElement.name}&gt;';
    } else {
      return 'const ${_field.enclosingElement.name}($_index)';
    }
  }

  @override
  List<EnumField> get documentationFrom {
    if (name == 'values' && name == 'index') return [this];
    return super.documentationFrom;
  }

  @override
  String get documentation {
    if (name == 'values') {
      return 'A constant List of the values in this enum, in order of their declaration.';
    } else if (name == 'index') {
      return 'The integer index of this enum.';
    } else {
      return super.documentation;
    }
  }

  @override
  String get href {
    if (canonicalLibrary == null || canonicalEnclosingElement == null)
      return null;
    return '${canonicalEnclosingElement.library.dirName}/${(canonicalEnclosingElement as Class).fileName}';
  }

  @override
  String get linkedName => name;

  @override
  bool get isCanonical {
    if (name == 'index') return false;
    // If this is something inherited from Object, e.g. hashCode, let the
    // normal rules apply.
    if (_index == null) {
      return super.isCanonical;
    }
    // TODO(jcollins-g): We don't actually document this as a separate entity;
    //                   do that or change this to false and deal with the
    //                   consequences.
    return true;
  }

  @override
  String get oneLineDoc => documentationAsHtml;
}

class Field extends ModelElement
    with GetterSetterCombo, Inheritable
    implements EnclosedElement {
  String _constantValue;
  bool _isInherited = false;
  Class _enclosingClass;
  @override
  final InheritableAccessor getter;
  @override
  final InheritableAccessor setter;

  Field(FieldElement element, Library library, this.getter, this.setter)
      : super(element, library) {
    _setModelType();
    if (getter != null) getter.enclosingCombo = this;
    if (setter != null) setter.enclosingCombo = this;
  }

  factory Field.inherited(FieldElement element, Class enclosingClass,
      Library library, Accessor getter, Accessor setter) {
    Field newField = new Field(element, library, getter, setter);
    newField._isInherited = true;
    newField._enclosingClass = enclosingClass;
    // Can't set _isInherited to true if this is the defining element, because
    // that would mean it isn't inherited.
    assert(newField.enclosingElement != newField.definingEnclosingElement);
    return newField;
  }

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    Set<bool> assertCheck = new Set()
      ..addAll([hasPublicSetter, hasPublicGetterNoSetter]);
    assert(assertCheck.containsAll([true, false]));
    return super.documentation;
  }

  String get constantValue {
    if (_constantValue != null) return _constantValue;

    if (_field.computeNode() == null) return null;
    var v = _field.computeNode().toSource();
    if (v == null) return null;
    var string = v.substring(v.indexOf('=') + 1, v.length).trim();
    _constantValue = string.replaceAll(modelType.name, modelType.linkedName);

    return _constantValue;
  }

  String get constantValueTruncated => truncateString(constantValue, 200);

  @override
  ModelElement get enclosingElement {
    if (_enclosingClass == null) {
      _enclosingClass = new ModelElement.from(_field.enclosingElement, library);
    }
    return _enclosingClass;
  }

  @override
  String get href {
    String retval;
    if (canonicalLibrary == null) return null;
    if (enclosingElement is Class) {
      if (canonicalEnclosingElement == null) return null;
      retval =
          '${canonicalEnclosingElement.canonicalLibrary.dirName}/${canonicalEnclosingElement.name}/$_fileName';
    } else if (enclosingElement is Library) {
      retval = '${canonicalLibrary.dirName}/$_fileName';
    } else {
      throw new StateError(
          '$name is not in a class or library, instead it is a ${enclosingElement.element}');
    }
    return retval;
  }

  @override
  bool get isConst => _field.isConst;

  @override
  bool get isFinal {
    /// isFinal returns true for the field even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return _field.isFinal;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  String get kind => 'property';

  String get typeName => "property";

  @override
  List<String> get annotations {
    List<String> all_annotations = new List<String>();
    all_annotations.addAll(super.annotations);

    if (element is PropertyInducingElement) {
      var pie = element as PropertyInducingElement;
      all_annotations.addAll(annotationsFromMetadata(pie.getter?.metadata));
      all_annotations.addAll(annotationsFromMetadata(pie.setter?.metadata));
    }
    return all_annotations.toList(growable: false);
  }

  @override
  Set<String> get features {
    Set<String> all_features = super.features;
    all_features.addAll(annotations);

    /// final/const implies read-only, so don't display both strings.
    if (readOnly && !isFinal && !isConst) all_features.add('read-only');
    if (writeOnly) all_features.add('write-only');
    if (readWrite) all_features.add('read / write');
    if (hasPublicGetter && hasPublicSetter) {
      if (getter.isInherited && setter.isInherited) {
        all_features.add('inherited');
      } else {
        if (getter.isInherited) all_features.add('inherited-getter');
        if (setter.isInherited) all_features.add('inherited-setter');
      }
    } else {
      if (isInherited) all_features.add('inherited');
    }
    return all_features;
  }

  @override
  String get computeDocumentationComment {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _field.documentationComment;
    return docs;
  }

  FieldElement get _field => (element as FieldElement);

  String get _fileName => isConst ? '$name-constant.html' : '$name.html';

  void _setModelType() {
    if (hasGetter) {
      var t = (getter.element as PropertyAccessorElement).returnType;
      _modelType = new ElementType(
          t,
          new ModelElement.from(
              t.element, _findOrCreateEnclosingLibraryFor(t.element)));
    }
  }
}

/// Mixin for top-level variables and fields (aka properties)
abstract class GetterSetterCombo implements ModelElement {
  Accessor get getter;

  @override
  ModelElement enclosingElement;
  bool get isInherited;

  /// Returns true if both accessors are synthetic.
  bool get hasSyntheticAccessors {
    if ((hasPublicGetter && getter.element.isSynthetic) ||
        (hasPublicSetter && setter.element.isSynthetic)) {
      return true;
    }
    return false;
  }

  bool get hasPublicGetter => hasGetter && getter.isPublic;
  bool get hasPublicSetter => hasSetter && setter.isPublic;

  @override
  bool get isPublic => hasPublicGetter || hasPublicSetter;

  @override
  List<ModelElement> get documentationFrom {
    if (_documentationFrom == null) {
      _documentationFrom = [];
      if (hasPublicGetter) {
        _documentationFrom.addAll(getter.documentationFrom.where((e) =>
            e.computeDocumentationComment != computeDocumentationComment));
      }
      if (hasPublicSetter)
        _documentationFrom.addAll(setter.documentationFrom.where((e) =>
            e.computeDocumentationComment != computeDocumentationComment));
      if (_documentationFrom.length == 0 ||
          _documentationFrom.every((e) => e.documentation == ''))
        _documentationFrom = computeDocumentationFrom;
    }
    return _documentationFrom;
  }

  String _oneLineDoc;
  @override
  String get oneLineDoc {
    if (_oneLineDoc == null) {
      bool hasAccessorsWithDocs =
          (hasPublicGetter && getter.oneLineDoc.isNotEmpty ||
              hasPublicSetter && setter.oneLineDoc.isNotEmpty);
      if (!hasAccessorsWithDocs) {
        _oneLineDoc = _documentation.asOneLiner;
      } else {
        StringBuffer buffer = new StringBuffer();
        bool getterSetterBothAvailable = false;
        if (hasPublicGetter &&
            getter.oneLineDoc.isNotEmpty &&
            hasPublicSetter &&
            setter.oneLineDoc.isNotEmpty) {
          getterSetterBothAvailable = true;
        }
        if (hasPublicGetter && getter.oneLineDoc.isNotEmpty) {
          buffer.write('${getter.oneLineDoc}');
        }
        if (hasPublicSetter && setter.oneLineDoc.isNotEmpty) {
          buffer.write('${getterSetterBothAvailable ? "": setter.oneLineDoc}');
        }
        _oneLineDoc = buffer.toString();
      }
    }
    return _oneLineDoc;
  }

  String get getterSetterDocumentationComment {
    var buffer = new StringBuffer();

    if (hasPublicGetter && !getter.element.isSynthetic) {
      assert(getter.documentationFrom.length == 1);
      String docs = getter.documentationFrom.first.computeDocumentationComment;
      if (docs != null) buffer.write(docs);
    }

    if (hasPublicSetter && !setter.element.isSynthetic) {
      assert(setter.documentationFrom.length == 1);
      String docs = setter.documentationFrom.first.computeDocumentationComment;
      if (docs != null) {
        if (buffer.isNotEmpty) buffer.write('\n\n');
        buffer.write(docs);
      }
    }
    return buffer.toString();
  }

  String get linkedReturnType {
    if (hasGetter) return modelType.linkedName;
    return null;
  }

  @override
  bool get canHaveParameters => hasSetter;

  @override
  List<Parameter> get parameters => setter.parameters;

  @override
  String get genericParameters {
    if (hasSetter) return setter.genericParameters;
    return null;
  }

  @override
  String get linkedParamsNoMetadata {
    if (hasSetter) return setter.linkedParamsNoMetadata;
    return null;
  }

  bool get hasExplicitGetter => hasPublicGetter && !getter.element.isSynthetic;

  bool get hasExplicitSetter => hasPublicSetter && !setter.element.isSynthetic;
  bool get hasImplicitSetter => hasPublicSetter && setter.element.isSynthetic;

  bool get hasGetter => getter != null;

  bool get hasNoGetterSetter => !hasExplicitGetter && !hasExplicitSetter;

  bool get hasSetter => setter != null;

  bool get hasPublicGetterNoSetter => (hasPublicGetter && !hasPublicSetter);

  String get arrow {
    // →
    if (readOnly) return r'&#8594;';
    // ←
    if (writeOnly) return r'&#8592;';
    // ↔
    if (readWrite) return r'&#8596;';
    // A GetterSetterCombo should always be one of readOnly, writeOnly,
    // or readWrite (if documented).
    assert(!isPublic);
    return null;
  }

  bool get readOnly => hasPublicGetter && !hasPublicSetter;
  bool get readWrite => hasPublicGetter && hasPublicSetter;

  bool get writeOnly => hasPublicSetter && !hasPublicGetter;

  Accessor get setter;
}

class Library extends ModelElement {
  @override
  final Package package;

  List<Class> _classes;
  List<Class> _enums;
  List<ModelFunction> _functions;
  List<Typedef> _typeDefs;
  List<TopLevelVariable> _variables;
  Namespace _exportedNamespace;
  String _name;
  String _packageName;
  factory Library(LibraryElement element, Package package) {
    return package.findOrCreateLibraryFor(element);
  }

  Library._(LibraryElement element, this.package) : super(element, null) {
    if (element == null) throw new ArgumentError.notNull('element');
    _exportedNamespace =
        new NamespaceBuilder().createExportNamespaceForLibrary(element);
  }

  List<String> _allOriginalModelElementNames;

  /// [allModelElements] resolved to their original names.
  ///
  /// A collection of [ModelElement.fullyQualifiedNames] for [ModelElement]s
  /// documented with this library, but these ModelElements and names correspond
  /// to the defining library where each originally came from with respect
  /// to inheritance and reexporting.  Most useful for error reporting.
  Iterable<String> get allOriginalModelElementNames {
    if (_allOriginalModelElementNames == null) {
      _allOriginalModelElementNames = allModelElements.map((e) {
        Accessor getter;
        Accessor setter;
        if (e is GetterSetterCombo) {
          if (e.hasGetter) {
            getter = new ModelElement.from(e.getter.element,
                package.findOrCreateLibraryFor(e.getter.element));
          }
          if (e.hasSetter) {
            setter = new ModelElement.from(e.setter.element,
                package.findOrCreateLibraryFor(e.setter.element));
          }
        }
        return new ModelElement.from(
                e.element, package.findOrCreateLibraryFor(e.element),
                getter: getter, setter: setter)
            .fullyQualifiedName;
      }).toList();
    }
    return _allOriginalModelElementNames;
  }

  List<Class> get allClasses => _allClasses;

  List<Class> get classes {
    return _allClasses
        .where((c) => !c.isErrorOrException)
        .toList(growable: false);
  }

  List<TopLevelVariable> _constants;
  List<TopLevelVariable> get constants {
    if (_constants == null) {
      // _getVariables() is already sorted.
      _constants =
          _getVariables().where((v) => v.isConst).toList(growable: false);
    }
    return _constants;
  }

  String get dirName => name.replaceAll(':', '-');

  Set<String> _canonicalFor;

  Set<String> get canonicalFor {
    if (_canonicalFor == null) {
      // TODO(jcollins-g): restructure to avoid using side effects.
      documentation;
    }
    return _canonicalFor;
  }

  /// Hide canonicalFor from doc while leaving a note to ourselves to
  /// help with ambiguous canonicalization determination.
  ///
  /// Example:
  ///   {@canonicalFor libname.ClassName}
  String _setCanonicalFor(String rawDocs) {
    if (_canonicalFor == null) {
      _canonicalFor = new Set();
    }
    Set<String> notFoundInAllModelElements = new Set();
    final canonicalRegExp = new RegExp(r'{@canonicalFor\s([^}]+)}');
    rawDocs = rawDocs.replaceAllMapped(canonicalRegExp, (Match match) {
      canonicalFor.add(match.group(1));
      notFoundInAllModelElements.add(match.group(1));
      return '';
    });
    if (notFoundInAllModelElements.isNotEmpty) {
      notFoundInAllModelElements.removeAll(allOriginalModelElementNames);
    }
    for (String notFound in notFoundInAllModelElements) {
      warn(PackageWarning.ignoredCanonicalFor, message: notFound);
    }
    return rawDocs;
  }

  String _libraryDocs;
  @override
  String get documentation {
    if (_libraryDocs == null) {
      _libraryDocs = _setCanonicalFor(super.documentation);
    }
    return _libraryDocs;
  }

  /// Libraries are not enclosed by anything.
  @override
  ModelElement get enclosingElement => null;

  List<Class> get enums {
    if (_enums != null) return _enums;

    List<ClassElement> enumClasses = [];
    enumClasses.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is ClassElement && element.isEnum));
    _enums = enumClasses
        .map((e) => new ModelElement.from(e, this))
        .where((e) => e.isPublic)
        .toList(growable: false)
          ..sort(byName);

    return _enums;
  }

  List<Class> get exceptions {
    return _allClasses
        .where((c) => c.isErrorOrException)
        .toList(growable: false)
          ..sort(byName);
  }

  String get fileName => '$dirName-library.html';

  List<ModelFunction> get functions {
    if (_functions != null) return _functions;

    Set<FunctionElement> elements = new Set();
    elements.addAll(_libraryElement.definingCompilationUnit.functions);
    for (CompilationUnitElement cu in _libraryElement.parts) {
      elements.addAll(cu.functions);
    }
    elements.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is FunctionElement));

    _functions = elements
        .map((e) {
          return new ModelElement.from(e, this);
        })
        .where((e) => e.isPublic)
        .toList(growable: false)
          ..sort(byName);

    return _functions;
  }

  bool get hasClasses => classes.isNotEmpty;

  bool get hasConstants => constants.isNotEmpty;

  bool get hasEnums => enums.isNotEmpty;

  bool get hasExceptions => _allClasses.any((c) => c.isErrorOrException);

  bool get hasFunctions => functions.isNotEmpty;

  bool get hasProperties => _getVariables().any((v) => !v.isConst);

  bool get hasTypedefs => typedefs.isNotEmpty;

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/$fileName';
  }

  InheritanceManager _inheritanceManager;
  InheritanceManager get inheritanceManager {
    if (_inheritanceManager == null) {
      _inheritanceManager = new InheritanceManager(element);
    }
    return _inheritanceManager;
  }

  bool get isAnonymous => element.name == null || element.name.isEmpty;

  bool get isDocumented => oneLineDoc.isNotEmpty;

  bool get isInSdk => _libraryElement.isInSdk;

  @override
  String get kind => 'library';

  @override
  Library get library => this;

  @override
  String get name {
    if (_name != null) return _name;

    // handle the case of an anonymous library
    if (element.name == null || element.name.isEmpty) {
      _name = _libraryElement.definingCompilationUnit.name;
      if (_name.endsWith('.dart')) {
        _name = _name.substring(0, _name.length - '.dart'.length);
      }
    } else {
      _name = element.name;
    }

    // So, if the library is a system library, it's name is not
    // dart:___, it's dart.___. Apparently the way to get to the dart:___
    // name is to get source.encoding.
    // This may be wrong or misleading, but developers expect the name
    // of dart:____
    var source = _libraryElement.definingCompilationUnit.source;
    _name = source.isInSystemLibrary ? source.encoding : _name;

    return _name;
  }

  /// The real package, as opposed to the package we are documenting it with,
  /// [Package.name]
  String get packageName {
    if (_packageName == null) {
      String sourcePath = _libraryElement.source.fullName;
      File file = new File(sourcePath);
      if (file.existsSync()) {
        _packageName = _getPackageName(file.parent);
        if (_packageName == null) _packageName = '';
      } else {
        _packageName = '';
      }
    }

    return _packageName;
  }

  String get path => _libraryElement.definingCompilationUnit.name;

  List<TopLevelVariable> _properties;

  /// All variables ("properties") except constants.
  List<TopLevelVariable> get properties {
    if (_properties == null) {
      _properties =
          _getVariables().where((v) => !v.isConst).toList(growable: false);
    }
    return _properties;
  }

  List<Typedef> get typedefs {
    if (_typeDefs != null) return _typeDefs;

    Set<FunctionTypeAliasElement> elements = new Set();
    elements
        .addAll(_libraryElement.definingCompilationUnit.functionTypeAliases);
    for (CompilationUnitElement cu in _libraryElement.parts) {
      elements.addAll(cu.functionTypeAliases);
    }

    elements.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is FunctionTypeAliasElement));
    elements..removeWhere(hasPrivateName);
    _typeDefs = elements
        .map((e) => new ModelElement.from(e, this))
        .toList(growable: false)
          ..sort(byName);

    return _typeDefs;
  }

  List<Class> get _allClasses {
    if (_classes != null) return _classes;

    Set<ClassElement> types = new Set();
    types.addAll(_libraryElement.definingCompilationUnit.types);
    for (CompilationUnitElement cu in _libraryElement.parts) {
      types.addAll(cu.types);
    }
    for (LibraryElement le in _libraryElement.exportedLibraries) {
      types.addAll(le.definingCompilationUnit.types
          .where((t) => _exportedNamespace.definedNames.values.contains(t.name))
          .toList());
    }

    types.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is ClassElement && !element.isEnum));

    _classes = types
        .map((e) => new ModelElement.from(e, this))
        .where((e) => e.isPublic)
        .toList(growable: false)
          ..sort(byName);

    return _classes;
  }

  LibraryElement get _libraryElement => (element as LibraryElement);

  Class getClassByName(String name) {
    return _allClasses.firstWhere((it) => it.name == name, orElse: () => null);
  }

  bool hasInExportedNamespace(Element element) {
    Element found = _exportedNamespace.get(element.name);
    if (found == null) return false;
    if (found == element) return true; // this checks more than just the name

    // Fix for #587, comparison between elements isn't reliable on windows.
    // for some reason. sigh.

    return found.runtimeType == element.runtimeType &&
        found.nameOffset == element.nameOffset;
  }

  List<TopLevelVariable> _getVariables() {
    if (_variables != null) return _variables;

    Set<TopLevelVariableElement> elements = new Set();
    elements.addAll(_libraryElement.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in _libraryElement.parts) {
      elements.addAll(cu.topLevelVariables);
    }
    _exportedNamespace.definedNames.values.forEach((element) {
      if (element is PropertyAccessorElement) {
        elements.add(element.variable);
      }
    });
    _variables = [];
    for (TopLevelVariableElement element in elements) {
      Accessor getter;
      if (element.getter != null)
        getter = new ModelElement.from(element.getter, this);
      Accessor setter;
      if (element.setter != null)
        setter = new ModelElement.from(element.setter, this);
      ModelElement me =
          new ModelElement.from(element, this, getter: getter, setter: setter);
      if (me.isPublic) _variables.add(me);
    }

    _variables.sort(byName);
    return _variables;
  }

  static String getLibraryName(LibraryElement element) {
    String name = element.name;

    if (name == null || name.isEmpty) {
      name = element.definingCompilationUnit.name;
      name = name.substring(0, name.length - '.dart'.length);
    }

    return name;
  }

  static String _getPackageName(Directory dir) {
    if (!dir.existsSync() || !dir.path.contains(Platform.pathSeparator)) {
      return null;
    }

    File pubspec = new File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      PackageMeta meta = new PackageMeta.fromDir(dir);
      return meta.name;
    } else {
      return _getPackageName(dir.parent);
    }
  }

  Map<Element, Set<ModelElement>> _modelElementsMap;
  Map<Element, Set<ModelElement>> get modelElementsMap {
    if (_modelElementsMap == null) {
      final Set<ModelElement> results = new Set();
      results
        ..addAll(library.allClasses)
        ..addAll(library.constants)
        ..addAll(library.enums)
        ..addAll(library.functions)
        ..addAll(library.properties)
        ..addAll(library.typedefs);

      library.allClasses.forEach((c) {
        results.addAll(c.allModelElements);
        results.add(c);
      });

      _modelElementsMap = new Map<Element, Set<ModelElement>>();
      results.forEach((modelElement) {
        _modelElementsMap.putIfAbsent(modelElement.element, () => new Set());
        _modelElementsMap[modelElement.element].add(modelElement);
      });
      _modelElementsMap.putIfAbsent(element, () => new Set());
      _modelElementsMap[element].add(this);
    }
    return _modelElementsMap;
  }

  List<ModelElement> _allModelElements;
  Iterable<ModelElement> get allModelElements {
    if (_allModelElements == null) {
      _allModelElements = [];
      for (Set<ModelElement> modelElements in modelElementsMap.values) {
        _allModelElements.addAll(modelElements);
      }
    }
    return _allModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;
  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }

  final Map<Library, bool> _isReexportedBy = {};

  /// Heuristic that tries to guess if this library is actually largely
  /// reexported by some other library.  We guess this by comparing the elements
  /// inside each of allModelElements for both libraries.  Don't use this
  /// except as a last-resort for canonicalization as it is a pretty fuzzy
  /// definition.
  ///
  /// If most of the elements from this library appear in the other, but not
  /// the reverse, then the other library is considered to be a reexporter of
  /// this one.
  ///
  /// If not, then the situation is either ambiguous, or the reverse is true.
  /// Computing this is expensive, so cache it.
  bool isReexportedBy(Library library) {
    assert(package.allLibrariesAdded);
    if (_isReexportedBy.containsKey(library)) return _isReexportedBy[library];
    Set<Element> otherElements = new Set()
      ..addAll(library.allModelElements.map((l) => l.element));
    Set<Element> ourElements = new Set()
      ..addAll(allModelElements.map((l) => l.element));
    if (ourElements.difference(otherElements).length <=
        ourElements.length / 2) {
      // Less than half of our elements are unique to us.
      if (otherElements.difference(ourElements).length <=
          otherElements.length / 2) {
        // ... but the same is true for the other library.  Reexporting
        // is ambiguous.
        _isReexportedBy[library] = false;
      } else {
        _isReexportedBy[library] = true;
      }
    } else {
      // We have a lot of unique elements, we're probably not reexported by
      // the other libraries.
      _isReexportedBy[library] = false;
    }

    return _isReexportedBy[library];
  }
}

class Method extends ModelElement
    with SourceCodeMixin, Inheritable
    implements EnclosedElement {
  bool _isInherited = false;
  Class _enclosingClass;
  List<TypeParameter> typeParameters = [];

  Method(MethodElement element, Library library) : super(element, library) {
    _modelType = new ElementType(_method.type, this);
    _calcTypeParameters();
  }

  Method.inherited(MethodElement element, this._enclosingClass, Library library)
      : super(element, library) {
    _modelType = new ElementType(_method.type, this);
    _isInherited = true;
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = _method.typeParameters.map((f) {
      return new ModelElement.from(f, library);
    }).toList();
  }

  @override
  ModelElement get enclosingElement {
    if (_enclosingClass == null) {
      _enclosingClass =
          new ModelElement.from(_method.enclosingElement, library);
    }
    return _enclosingClass;
  }

  String get fileName => "${name}.html";

  String get fullkind {
    if (_method.isAbstract) return 'abstract $kind';
    return kind;
  }

  @override
  String get href {
    if (canonicalLibrary == null || canonicalEnclosingElement == null)
      return null;
    return '${canonicalEnclosingElement.canonicalLibrary.dirName}/${canonicalEnclosingElement.name}/${fileName}';
  }

  @override
  bool get isInherited => _isInherited;

  bool get isOperator => false;

  @override
  Set<String> get features {
    Set<String> all_features = super.features;
    if (isInherited) all_features.add('inherited');
    return all_features;
  }

  @override
  bool get isStatic => _method.isStatic;

  @override
  String get kind => 'method';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  @override
  String get nameWithGenerics {
    if (typeParameters.isEmpty) return name;
    return '$name&lt;${typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  @override
  String get genericParameters {
    if (typeParameters.isEmpty) return '';
    return '&lt;${typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  @override
  Method get overriddenElement {
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in getAllSupertypes(parent)) {
      Element e = t.getMethod(element.name);
      if (e != null) {
        assert(e.enclosingElement is ClassElement);
        Library l = _findOrCreateEnclosingLibraryFor(e.enclosingElement);
        return new ModelElement.from(e, l);
      }
    }
    return null;
  }

  String get typeName => 'method';

  MethodElement get _method => (element as MethodElement);
}

/// This class represents the score for a particular element; how likely
/// it is that this is the canonical element.
class ScoredCandidate implements Comparable<ScoredCandidate> {
  final List<String> reasons = [];

  /// The ModelElement being scored.
  final ModelElement element;
  final Library library;

  /// The score accumulated so far.  Higher means it is more likely that this
  /// is the intended canonical Library.
  double score = 0.0;

  ScoredCandidate(this.element, this.library);

  void alterScore(double scoreDelta, String reason) {
    score += scoreDelta;
    if (scoreDelta != 0) {
      reasons.add(
          "${reason} (${scoreDelta >= 0 ? '+' : ''}${scoreDelta.toStringAsPrecision(4)})");
    }
  }

  @override
  int compareTo(ScoredCandidate other) {
    assert(element == other.element);
    return score.compareTo(other.score);
  }

  @override
  String toString() =>
      "${library.name}: ${score.toStringAsPrecision(4)} - ${reasons.join(', ')}";
}

/// This class is the foundation of Dartdoc's model for source code.
/// All ModelElements are contained within a [Package], and laid out in a
/// structure that mirrors the availability of identifiers in the various
/// namespaces within that package.  For example, multiple [Class] objects
/// for a particular identifier ([ModelElement.element]) may show up in
/// different [Library]s as the identifier is reexported.
///
/// However, ModelElements have an additional concept vital to generating
/// documentation: canonicalization.
///
/// A ModelElement is canonical if it is the element in the namespace where that
/// element 'comes from' in the public interface to this [Package].  That often
/// means the [ModelElement.library] is contained in [Package.libraries], but
/// there are many exceptions and ambiguities the code tries to address here.
///
/// Non-canonical elements should refer to their canonical counterparts, making
/// it easy to calculate links via [ModelElement.href] without having to
/// know in a particular namespace which elements are canonical or not.
/// A number of [Package] methods, such as [Package.findCanonicalModelElementFor]
/// can help with this.
///
/// When documenting, Dartdoc should only write out files corresponding to
/// canonical instances of ModelElement ([ModelElement.isCanonical]).  This
/// helps prevent subtle bugs as generated output for a non-canonical
/// ModelElement will reference itself as part of the "wrong" [Library]
/// from the public interface perspective.
abstract class ModelElement extends Nameable
    implements Comparable, Documentable {
  final Element _element;
  final Library _library;

  ElementType _modelType;
  String _rawDocs;
  Documentation __documentation;
  UnmodifiableListView<Parameter> _parameters;
  String _linkedName;

  String _fullyQualifiedName;
  String _fullyQualifiedNameWithoutLibrary;

  // WARNING: putting anything into the body of this seems
  // to lead to stack overflows. Need to make a registry of ModelElements
  // somehow.
  ModelElement(this._element, this._library);

  // TODO(jcollins-g): this way of using the optional parameter is messy,
  // clean that up.
  // TODO(jcollins-g): Refactor this into class-specific factories that
  // call this one.
  // TODO(jcollins-g): Enforce construction restraint.
  // TODO(jcollins-g): Allow e to be null and drop extraneous null checks.
  // TODO(jcollins-g): Auto-vivify element's defining library for library
  // parameter when given a null.
  /// Do not construct any ModelElements unless they are from this constructor.
  /// Specify enclosingClass only if this is to be an inherited object.
  /// Specify index only if this is to be an EnumField.forConstant.
  factory ModelElement.from(Element e, Library library,
      {Class enclosingClass, int index, Accessor getter, Accessor setter}) {
    // We don't need index in this key because it isn't a disambiguator.
    // It isn't a disambiguator because EnumFields are not inherited, ever.
    // TODO(jcollins-g): cleanup class hierarchy so that EnumFields aren't
    // Inheritable, somehow?
    if (e is Member) {
      e = Package.getBasestElement(e);
    }
    Tuple3<Element, Library, Class> key =
        new Tuple3(e, library, enclosingClass);
    ModelElement newModelElement;
    if (e.kind != ElementKind.DYNAMIC &&
        library.package._allConstructedModelElements.containsKey(key)) {
      newModelElement = library.package._allConstructedModelElements[key];
    } else {
      if (e.kind == ElementKind.DYNAMIC) {
        newModelElement = new Dynamic(e, library);
      }
      if (e is LibraryElement) {
        newModelElement = new Library(e, library.package);
      }
      // Also handles enums
      if (e is ClassElement) {
        if (!e.isEnum) {
          newModelElement = new Class(e, library);
          if (newModelElement.library.name == 'dart:core' &&
              newModelElement.name == 'Object') {
            // We've found Object.  This is an important object, so save it in the package.
            newModelElement.library.package._objectElement = newModelElement;
          }
        } else {
          newModelElement = new Enum(e, library);
        }
      }
      if (e is FunctionElement) {
        newModelElement = new ModelFunction(e, library);
      }
      if (e is FunctionTypeAliasElement) {
        newModelElement = new Typedef(e, library);
      }
      if (e is FieldElement) {
        if (enclosingClass == null) {
          if (index != null) {
            assert(getter != null);
            newModelElement =
                new EnumField.forConstant(index, e, library, getter);
          } else {
            if (e.enclosingElement.isEnum) {
              newModelElement = new EnumField(e, library, getter, setter);
            } else {
              assert(getter != null || setter != null);
              newModelElement = new Field(e, library, getter, setter);
            }
          }
        } else {
          assert(getter != null || setter != null);
          newModelElement =
              new Field.inherited(e, enclosingClass, library, getter, setter);
        }
      }
      if (e is ConstructorElement) {
        newModelElement = new Constructor(e, library);
      }
      if (e is MethodElement && e.isOperator) {
        if (enclosingClass == null)
          newModelElement = new Operator(e, library);
        else
          newModelElement = new Operator.inherited(e, enclosingClass, library);
      }
      if (e is MethodElement && !e.isOperator) {
        if (enclosingClass == null)
          newModelElement = new Method(e, library);
        else
          newModelElement = new Method.inherited(e, enclosingClass, library);
      }
      if (e is TopLevelVariableElement) {
        if (getter == null && setter == null) {
          List<TopLevelVariable> allVariables = []
            ..addAll(library.properties)
            ..addAll(library.constants);
          newModelElement = allVariables.firstWhere((v) => v.element == e);
        } else {
          newModelElement = new TopLevelVariable(e, library, getter, setter);
        }
      }
      if (e is PropertyAccessorElement) {
        if (e.enclosingElement is ClassElement) {
          if (enclosingClass == null)
            newModelElement = new InheritableAccessor(e, library);
          else
            newModelElement =
                new InheritableAccessor.inherited(e, library, enclosingClass);
        } else {
          newModelElement = new Accessor(e, library);
        }
      }
      if (e is TypeParameterElement) {
        newModelElement = new TypeParameter(e, library);
      }
      if (e is ParameterElement) {
        newModelElement = new Parameter(e, library);
      }
    }
    if (newModelElement == null) throw "Unknown type ${e.runtimeType}";
    if (enclosingClass != null) assert(newModelElement is Inheritable);
    if (library != null) {
      library.package._allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        Tuple2<Element, Library> iKey = new Tuple2(e, library);
        library.package._allInheritableElements
            .putIfAbsent(iKey, () => new Set());
        library.package._allInheritableElements[iKey].add(newModelElement);
      }
    }
    if (newModelElement is GetterSetterCombo) {
      assert(getter == null || newModelElement.getter.enclosingCombo != null);
      assert(setter == null || newModelElement.setter.enclosingCombo != null);
    }

    return newModelElement;
  }

  Set<Library> get exportedInLibraries {
    return library.package.libraryElementReexportedBy[this.element.library];
  }

  Set<String> get locationPieces {
    return new Set()
      ..addAll(element.location
          .toString()
          .split(_locationSplitter)
          .where((s) => s.isNotEmpty));
  }

  // Use components of this element's location to return a score for library
  // location.
  ScoredCandidate scoreElementWithLibrary(Library lib) {
    ScoredCandidate scoredCandidate = new ScoredCandidate(this, lib);
    Iterable<String> resplit(Set<String> items) sync* {
      for (String item in items) {
        for (String subItem in item.split('_')) {
          yield subItem;
        }
      }
    }

    // Large boost for @canonicalFor, essentially overriding all other concerns.
    if (lib.canonicalFor.contains(fullyQualifiedName)) {
      scoredCandidate.alterScore(5.0, 'marked @canonicalFor');
    }
    // Penalty for deprecated libraries.
    if (lib.isDeprecated) scoredCandidate.alterScore(-1.0, 'is deprecated');
    // Give a big boost if the library has the package name embedded in it.
    if (package.namePieces.intersection(lib.namePieces).length > 0) {
      scoredCandidate.alterScore(1.0, 'embeds package name');
    }
    // Give a tiny boost for libraries with long names, assuming they're
    // more specific (and therefore more likely to be the owner of this symbol).
    scoredCandidate.alterScore(.01 * lib.namePieces.length, 'name is long');
    // If we don't know the location of this element, return our best guess.
    // TODO(jcollins-g): is that even possible?
    assert(!locationPieces.isEmpty);
    if (locationPieces.isEmpty) return scoredCandidate;
    // The more pieces we have of the location in our library name, the more we should boost our score.
    scoredCandidate.alterScore(
        lib.namePieces.intersection(locationPieces).length.toDouble() /
            locationPieces.length.toDouble(),
        'element location shares parts with name');
    // If pieces of location at least start with elements of our library name, boost the score a little bit.
    double scoreBoost = 0.0;
    for (String piece in resplit(locationPieces)) {
      for (String namePiece in lib.namePieces) {
        if (piece.startsWith(namePiece)) {
          scoreBoost += 0.001;
        }
      }
    }
    scoredCandidate.alterScore(
        scoreBoost, 'element location parts start with parts of name');
    return scoredCandidate;
  }

  // TODO(jcollins-g): annotations should now be able to use the utility
  // functions in package for finding elements and avoid using computeNode().
  List<String> get annotations {
    List<dynamic> metadata;
    if (element.computeNode() is AnnotatedNode) {
      AnnotatedNode node = element.computeNode() as AnnotatedNode;

      // Declarations are contained inside FieldDeclarations, and that is where
      // the actual annotations are.
      while ((node is VariableDeclaration || node is VariableDeclarationList) &&
          node is! FieldDeclaration) {
        assert(null != node.parent);
        node = node.parent;
      }
      metadata = node.metadata;
    } else {
      metadata = element.metadata;
    }
    return annotationsFromMetadata(metadata);
  }

  /// Returns annotations from a given metadata set, with escaping.
  /// md is a dynamic parameter since ElementAnnotation and Annotation have no
  /// common class for calling toSource() and element.
  List<String> annotationsFromMetadata(List<dynamic> md) {
    if (md == null) md = new List<dynamic>();
    return md.map((dynamic a) {
      String annotation = (const HtmlEscape()).convert(a.toSource());
      var me = package.findCanonicalModelElementFor(a.element.enclosingElement);
      if (me != null)
        annotation = annotation.replaceFirst(me.name, me.linkedName);
      return annotation;
    }).toList(growable: false);
  }

  bool _isPublic;
  bool get isPublic {
    if (_isPublic == null) {
      String docComment = computeDocumentationComment;
      if (docComment == null) {
        _isPublic = hasPublicName(element);
      } else {
        _isPublic = hasPublicName(element) &&
            !(docComment.contains('@nodoc') || docComment.contains('<nodoc>'));
      }
    }
    return _isPublic;
  }

  Set<String> get features {
    Set<String> all_features = new Set<String>();
    all_features.addAll(annotations);

    // override as an annotation should be replaced with direct information
    // from the analyzer if we decide to display it at this level.
    all_features.remove('@override');

    // Drop the plain "deprecated" annotation, that's indicated via
    // strikethroughs. Custom @Deprecated() will still appear.
    all_features.remove('@deprecated');
    // const and static are not needed here because const/static elements get
    // their own sections in the doc.
    if (isFinal) all_features.add('final');
    return all_features;
  }

  String get featuresAsString {
    List<String> all_features = features.toList()..sort(byFeatureOrdering);
    return all_features.join(', ');
  }

  bool get canHaveParameters =>
      element is ExecutableElement || element is FunctionTypeAliasElement;

  List<ModelElement> _documentationFrom;
  // TODO(jcollins-g): untangle when mixins can call super
  @override
  List<ModelElement> get documentationFrom {
    if (_documentationFrom == null) {
      _documentationFrom = computeDocumentationFrom;
    }
    return _documentationFrom;
  }

  /// Returns the ModelElement(s) from which we will get documentation.
  /// Can be more than one if this is a Field composing documentation from
  /// multiple Accessors.
  ///
  /// This getter will walk up the inheritance hierarchy
  /// to find docs, if the current class doesn't have docs
  /// for this element.
  List<ModelElement> get computeDocumentationFrom {
    List<ModelElement> docFrom;
    if (computeDocumentationComment == null &&
        canOverride() &&
        overriddenElement != null) {
      docFrom = [overriddenElement];
    } else if (this is Inheritable && (this as Inheritable).isInherited) {
      Inheritable thisInheritable = (this as Inheritable);
      InheritableAccessor newGetter;
      InheritableAccessor newSetter;
      if (this is GetterSetterCombo) {
        GetterSetterCombo thisAsCombo = this as GetterSetterCombo;
        if (thisAsCombo.hasGetter) {
          newGetter = new ModelElement.from(
              thisAsCombo.getter.element, thisAsCombo.getter.definingLibrary);
        }
        if (thisAsCombo.hasSetter) {
          newSetter = new ModelElement.from(
              thisAsCombo.setter.element, thisAsCombo.setter.definingLibrary);
        }
      }
      ModelElement fromThis = new ModelElement.from(
          element, thisInheritable.definingEnclosingElement.library,
          getter: newGetter, setter: newSetter);
      docFrom = fromThis.documentationFrom;
    } else {
      docFrom = [this];
    }
    return docFrom;
  }

  String get _documentationLocal {
    if (_rawDocs != null) return _rawDocs;
    if (config.dropTextFrom.contains(element.library.name)) {
      _rawDocs = '';
    } else {
      _rawDocs = computeDocumentationComment ?? '';
      _rawDocs = stripComments(_rawDocs) ?? '';
      _rawDocs = _injectExamples(_rawDocs);
      _rawDocs = _stripMacroTemplatesAndAddToIndex(_rawDocs);
      _rawDocs = _injectMacros(_rawDocs);
    }
    return _rawDocs;
  }

  /// Returns the docs, stripped of their leading comments syntax.
  @override
  String get documentation {
    return documentationFrom.map((e) => e._documentationLocal).join('\n');
  }

  Library get definingLibrary => package.findOrCreateLibraryFor(element);

  Library _canonicalLibrary;
  // _canonicalLibrary can be null so we can't check against null to see whether
  // we tried to compute it before.
  bool _canonicalLibraryIsSet = false;
  Library get canonicalLibrary {
    // This is not accurate if we are constructing the Package.
    assert(package.allLibrariesAdded);
    // Since we're looking for a library, find the [Element] immediately
    // contained by a [CompilationUnitElement] in the tree.
    Element topLevelElement = element;
    while (topLevelElement != null &&
        topLevelElement is! LibraryElement &&
        topLevelElement.enclosingElement is! CompilationUnitElement) {
      topLevelElement = topLevelElement.enclosingElement;
    }

    if (!_canonicalLibraryIsSet) {
      if (!package.libraries.contains(definingLibrary)) {
        List<Library> candidateLibraries = package
            .libraryElementReexportedBy[definingLibrary.element]
            ?.toList();
        if (candidateLibraries != null) {
          candidateLibraries = candidateLibraries.where((l) {
            Element lookup = (l.element as LibraryElement)
                .exportNamespace
                .definedNames[topLevelElement?.name];
            if (lookup is PropertyAccessorElement)
              lookup = (lookup as PropertyAccessorElement).variable;
            if (topLevelElement == lookup) return true;
            return false;
          }).toList();
          // Start with our top-level element.
          ModelElement warnable = new ModelElement.from(
              topLevelElement, package.findOrCreateLibraryFor(topLevelElement));
          if (candidateLibraries.length > 1) {
            // Heuristic scoring to determine which library a human likely
            // considers this element to be primarily 'from', and therefore,
            // canonical.  Still warn if the heuristic isn't that confident.
            List<ScoredCandidate> scoredCandidates =
                warnable.scoreCanonicalCandidates(candidateLibraries);
            candidateLibraries =
                scoredCandidates.map((s) => s.library).toList();
            double secondHighestScore =
                scoredCandidates[scoredCandidates.length - 2].score;
            double highestScore = scoredCandidates.last.score;
            double confidence = highestScore - secondHighestScore;
            String message =
                "${candidateLibraries.map((l) => l.name)} -> ${candidateLibraries.last.name} (confidence ${confidence.toStringAsPrecision(4)})";
            List<String> debugLines = [];
            debugLines.addAll(scoredCandidates.map((s) => '${s.toString()}'));

            if (config == null || confidence < config.reexportMinConfidence) {
              warnable.warn(PackageWarning.ambiguousReexport,
                  message: message, extendedDebug: debugLines);
            }
          }
          if (candidateLibraries.isNotEmpty)
            _canonicalLibrary = candidateLibraries.last;
        }
      } else {
        _canonicalLibrary = definingLibrary;
      }
      if (this is Inheritable) {
        if ((this as Inheritable).isInherited && _canonicalLibrary == null) {
          // In the event we've inherited a field from an object that isn't directly reexported,
          // we may need to pretend we are canonical for this.
          _canonicalLibrary = library;
        }
      }
      _canonicalLibraryIsSet = true;
    }
    return _canonicalLibrary;
  }

  List<ScoredCandidate> scoreCanonicalCandidates(List<Library> libraries) {
    return libraries.map((l) => scoreElementWithLibrary(l)).toList()..sort();
  }

  @override
  bool get isCanonical {
    if (library == canonicalLibrary) {
      if (this is Inheritable) {
        Inheritable i = (this as Inheritable);
        // If we're the defining element, or if the defining element is not
        // in the set of libraries being documented, then this element
        // should be treated as canonical (given library == canonicalLibrary).
        if (i.enclosingElement == i.canonicalEnclosingElement) {
          return true;
        } else {
          return false;
        }
      }
      // If there's no inheritance to deal with, we're done.
      return true;
    }
    return false;
  }

  @override
  String get documentationAsHtml => _documentation.asHtml;

  @override
  Element get element => _element;

  @override
  String get elementLocation {
    // Call nothing from here that can emit warnings or you'll cause stack overflows.
    if (lineAndColumn != null) {
      return "(${p.toUri(sourceFileName)}:${lineAndColumn.item1}:${lineAndColumn.item2})";
    }
    return "(${p.toUri(sourceFileName)})";
  }

  /// Returns a link to extended documentation, or the empty string if that
  /// does not exist.
  String get extendedDocLink {
    if (hasExtendedDocumentation) {
      return '<a href="${href}">[...]</a>';
    }
    return '';
  }

  /// Returns the fully qualified name.
  ///
  /// For example: libraryName.className.methodName
  @override
  String get fullyQualifiedName {
    return (_fullyQualifiedName ??= _buildFullyQualifiedName());
  }

  String get fullyQualifiedNameWithoutLibrary {
    // Remember, periods are legal in library names.
    if (_fullyQualifiedNameWithoutLibrary == null) {
      _fullyQualifiedNameWithoutLibrary =
          fullyQualifiedName.replaceFirst("${library.fullyQualifiedName}.", '');
    }
    return _fullyQualifiedNameWithoutLibrary;
  }

  String get sourceFileName => element.source.fullName;

  Tuple2<int, int> _lineAndColumn;
  bool _isLineNumberComputed = false;
  @override
  Tuple2<int, int> get lineAndColumn {
    // TODO(jcollins-g): implement lineAndColumn for explicit fields
    if (!_isLineNumberComputed) {
      _lineAndColumn = lineNumberCache.lineAndColumn(
          element.source.fullName, element.nameOffset);
    }
    return _lineAndColumn;
  }

  bool get hasAnnotations => annotations.isNotEmpty;

  @override
  bool get hasDocumentation =>
      documentation != null && documentation.isNotEmpty;

  @override
  bool get hasExtendedDocumentation =>
      href != null && _documentation.hasExtendedDocs;

  bool get hasParameters => parameters.isNotEmpty;

  /// If canonicalLibrary (or canonicalEnclosingElement, for Inheritable
  /// subclasses) is null, href should be null.
  @override
  String get href;

  String get htmlId => name;

  bool get isAsynchronous =>
      isExecutable && (element as ExecutableElement).isAsynchronous;

  bool get isConst => false;

  bool get isDeprecated {
    // If element.metadata is empty, it might be because this is a property
    // where the metadata belongs to the individual getter/setter
    if (element.metadata.isEmpty && element is PropertyInducingElement) {
      var pie = element as PropertyInducingElement;

      // The getter or the setter might be null – so the stored value may be
      // `true`, `false`, or `null`
      var getterDeprecated = pie.getter?.metadata?.any((a) => a.isDeprecated);
      var setterDeprecated = pie.setter?.metadata?.any((a) => a.isDeprecated);

      var deprecatedValues =
          [getterDeprecated, setterDeprecated].where((a) => a != null).toList();

      // At least one of these should be non-null. Otherwise things are weird
      assert(deprecatedValues.isNotEmpty);

      // If there are both a setter and getter, only show the property as
      // deprecated if both are deprecated.
      return deprecatedValues.every((d) => d);
    }
    return element.metadata.any((a) => a.isDeprecated);
  }

  bool get isExecutable => element is ExecutableElement;

  bool get isFinal => false;

  bool get isLocalElement => element is LocalElement;

  bool get isPropertyAccessor => element is PropertyAccessorElement;

  bool get isPropertyInducer => element is PropertyInducingElement;

  bool get isStatic {
    if (isPropertyInducer) {
      return (element as PropertyInducingElement).isStatic;
    }
    return false;
  }

  /// A human-friendly name for the kind of element this is.
  String get kind;

  Library get library => _library;

  String get linkedName {
    if (_linkedName == null) {
      _linkedName = _calculateLinkedName();
    }
    return _calculateLinkedName();
  }

  String get linkedParamsLines => linkedParams().trim();

  String get linkedParamsNoMetadata => linkedParams(showMetadata: false);

  String get linkedParamsNoMetadataOrNames {
    return linkedParams(showMetadata: false, showNames: false);
  }

  ElementType get modelType => _modelType;

  @override
  String get name => element.name;

  String get nameWithGenerics => name;

  String get genericParameters => '';

  @override
  String get oneLineDoc =>
      '${_documentation.asOneLiner}${extendedDocLink.isEmpty ? "" : " $extendedDocLink"}';

  ModelElement get overriddenElement => null;

  ModelElement _overriddenDocumentedElement;
  bool _overriddenDocumentedElementIsSet = false;
  // TODO(jcollins-g): This method prefers canonical elements, but it isn't
  // guaranteed and is probably the source of bugs or confusing warnings.
  @override
  ModelElement get overriddenDocumentedElement {
    if (!_overriddenDocumentedElementIsSet) {
      ModelElement found = this;
      while ((found.element.documentationComment == null ||
              found.element.documentationComment == "") &&
          !found.isCanonical &&
          found.overriddenElement != null) {
        found = found.overriddenElement;
      }
      _overriddenDocumentedElement = found;
      _overriddenDocumentedElementIsSet = true;
    }
    return _overriddenDocumentedElement;
  }

  int _overriddenDepth;
  int get overriddenDepth {
    if (_overriddenDepth == null) {
      _overriddenDepth = 0;
      ModelElement e = this;
      while (e.overriddenElement != null) {
        _overriddenDepth += 1;
        e = e.overriddenElement;
      }
    }
    return _overriddenDepth;
  }

  @override
  Package get package =>
      (this is Library) ? (this as Library).package : this.library.package;

  List<Parameter> _allParameters;
  // TODO(jcollins-g): This is in the wrong place.  Move parts to GetterSetterCombo,
  // elsewhere as appropriate?
  List<Parameter> get allParameters {
    if (_allParameters == null) {
      final Set<Parameter> recursedParameters = new Set();
      final Set<Parameter> newParameters = new Set();
      if (this is GetterSetterCombo &&
          (this as GetterSetterCombo).setter != null) {
        newParameters.addAll((this as GetterSetterCombo).setter.parameters);
      } else {
        if (canHaveParameters) newParameters.addAll(parameters);
      }
      while (newParameters.isNotEmpty) {
        recursedParameters.addAll(newParameters);
        newParameters.clear();
        for (Parameter p in recursedParameters) {
          if (p.modelType.element.canHaveParameters) {
            newParameters.addAll(p.modelType.element.parameters
                .where((p) => !recursedParameters.contains(p)));
          }
        }
      }
      _allParameters = recursedParameters.toList();
    }
    return _allParameters;
  }

  List<Parameter> get parameters {
    if (!canHaveParameters) {
      throw new StateError("$element cannot have parameters");
    }

    if (_parameters != null) return _parameters;

    List<ParameterElement> params;

    if (element is ExecutableElement) {
      // the as check silences the warning
      params = (element as ExecutableElement).parameters;
    }

    if (element is FunctionTypeAliasElement) {
      params = (element as FunctionTypeAliasElement).parameters;
    }

    _parameters = new UnmodifiableListView<Parameter>(params
        .map((p) => new ModelElement.from(p, library))
        .toList() as Iterable<Parameter>);

    return _parameters;
  }

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    package.warnOnElement(this, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  String get computeDocumentationComment => element.documentationComment;

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = new Documentation.forElement(this);
    return __documentation;
  }

  bool canOverride() =>
      element is ClassMemberElement || element is PropertyAccessorElement;

  @override
  int compareTo(dynamic other) {
    if (other is ModelElement) {
      return name.toLowerCase().compareTo(other.name.toLowerCase());
    } else {
      return 0;
    }
  }

  String linkedParams(
      {bool showMetadata: true, bool showNames: true, String separator: ', '}) {
    String renderParam(Parameter param, String suffix) {
      StringBuffer buf = new StringBuffer();
      buf.write('<span class="parameter" id="${param.htmlId}">');
      if (showMetadata && param.hasAnnotations) {
        param.annotations.forEach((String annotation) {
          buf.write('<span>$annotation</span> ');
        });
      }
      if (param.modelType.isFunctionType) {
        var returnTypeName;
        bool isTypedef = param.modelType.element is Typedef;
        if (isTypedef) {
          returnTypeName = param.modelType.linkedName;
        } else {
          returnTypeName = param.modelType.createLinkedReturnTypeName();
        }
        buf.write('<span class="type-annotation">${returnTypeName}</span>');
        if (showNames) {
          buf.write(' <span class="parameter-name">${param.name}</span>');
        }
        if (!isTypedef) {
          buf.write('(');
          buf.write(param.modelType.element
              .linkedParams(showNames: showNames, showMetadata: showMetadata));
          buf.write(')');
        }
      } else if (param.modelType != null && param.modelType.element != null) {
        var mt = param.modelType;
        String typeName = "";
        if (mt != null && !mt.isDynamic) {
          typeName = mt.linkedName;
        }
        if (typeName.isNotEmpty) {
          buf.write('<span class="type-annotation">$typeName</span>');
        }
        if (typeName.isNotEmpty && showNames && param.name.isNotEmpty)
          buf.write(' ');
        if (showNames && param.name.isNotEmpty) {
          buf.write('<span class="parameter-name">${param.name}</span>');
        }
      }

      if (param.hasDefaultValue) {
        if (param.isOptionalNamed) {
          buf.write(': ');
        } else {
          buf.write(' = ');
        }
        buf.write('<span class="default-value">${param.defaultValue}</span>');
      }
      buf.write('${suffix}</span>');
      return buf.toString();
    }

    List<Parameter> requiredParams =
        parameters.where((Parameter p) => !p.isOptional).toList();
    List<Parameter> positionalParams =
        parameters.where((Parameter p) => p.isOptionalPositional).toList();
    List<Parameter> namedParams =
        parameters.where((Parameter p) => p.isOptionalNamed).toList();

    StringBuffer builder = new StringBuffer();

    // prefix
    if (requiredParams.isEmpty && positionalParams.isNotEmpty) {
      builder.write('[');
    } else if (requiredParams.isEmpty && namedParams.isNotEmpty) {
      builder.write('{');
    }

    // index over params
    for (Parameter param in requiredParams) {
      bool isLast = param == requiredParams.last;
      String ext;
      if (isLast && positionalParams.isNotEmpty) {
        ext = ', [';
      } else if (isLast && namedParams.isNotEmpty) {
        ext = ', {';
      } else {
        ext = isLast ? '' : ', ';
      }
      builder.write(renderParam(param, ext));
      builder.write(' ');
    }
    for (Parameter param in positionalParams) {
      bool isLast = param == positionalParams.last;
      builder.write(renderParam(param, isLast ? '' : ', '));
      builder.write(' ');
    }
    for (Parameter param in namedParams) {
      bool isLast = param == namedParams.last;
      builder.write(renderParam(param, isLast ? '' : ', '));
      builder.write(' ');
    }

    // suffix
    if (namedParams.isNotEmpty) {
      builder.write('}');
    } else if (positionalParams.isNotEmpty) {
      builder.write(']');
    }

    return builder.toString().trim();
  }

  /// Gather all the used elements, from the parameters and return type, for example
  /// E.g. method <code>Iterable<String> blah(List<int> foo)</code> will return
  /// <code>[Iterable, String, List, int]</code>
  Iterable<ModelElement> get usedElements {
    final set = new Set<ModelElement>();
    if (modelType != null) {
      if (modelType.isFunctionType) {
        if (modelType.returnElement != null) {
          set.addAll(modelType.returnElement.usedElements);
        }
        if (canHaveParameters) {
          set.addAll(parameters.map((p) => p.usedElements).expand((i) => i));
        }
      } else if (modelType.element != null) {
        set.add(modelType.element);
        if (modelType.isParameterizedType) {
          set.addAll(modelType.typeArguments
              .map((arg) => arg.element.usedElements)
              .expand((i) => i));
        }
      }
    }
    return set;
  }

  @override
  String toString() => '$runtimeType $name';

  String _buildFullyQualifiedName([ModelElement e, String fqName]) {
    e ??= this;
    fqName ??= e.name;

    if (e is! EnclosedElement) {
      return fqName;
    }

    ModelElement parent = (e as EnclosedElement).enclosingElement;
    return _buildFullyQualifiedName(parent, '${parent.name}.$fqName');
  }

  String _calculateLinkedName() {
    // If we're calling this with an empty name, we probably have the wrong
    // element associated with a ModelElement or there's an analysis bug.
    assert(!name.isEmpty ||
        (this.element is TypeDefiningElement &&
            (this.element as TypeDefiningElement).type.name == "dynamic"));

    if (!isPublic) {
      return HTML_ESCAPE.convert(name);
    }

    if (href == null) {
      warn(PackageWarning.noCanonicalFound);
      return HTML_ESCAPE.convert(name);
    }

    var classContent = isDeprecated ? ' class="deprecated"' : '';
    return '<a${classContent} href="${href}">$name</a>';
  }

  // TODO(keertip): consolidate all the find library methods
  // This differs from package.findOrCreateLibraryFor in a small way,
  // searching for the [Library] associated with this element's enclosing
  // Library before trying to create one.
  Library _findOrCreateEnclosingLibraryFor(Element e) {
    var element = e.getAncestor((l) => l is LibraryElement);
    var lib;
    if (element != null) {
      lib = package.findLibraryFor(element);
    }
    if (lib == null) {
      lib = package.findOrCreateLibraryFor(e);
    }
    return lib;
  }

  /// Replace {@example ...} in API comments with the content of named file.
  ///
  /// Syntax:
  ///
  ///     {@example PATH [region=NAME] [lang=NAME]}
  ///
  /// where PATH and NAME are tokens _without_ whitespace; NAME can optionally be
  /// quoted (use of quotes is for backwards compatibility and discouraged).
  ///
  /// If PATH is `dir/file.ext` and region is `r` then we'll look for the file
  /// named `dir/file-r.ext.md`, relative to the project root directory (of the
  /// project for which the docs are being generated).
  ///
  /// Examples:
  ///
  ///     {@example examples/angular/quickstart/web/main.dart}
  ///     {@example abc/def/xyz_component.dart region=template lang=html}
  ///
  String _injectExamples(String rawdocs) {
    final dirPath = this.package.packageMeta.dir.path;
    RegExp exampleRE = new RegExp(r'{@example\s+([^}]+)}');
    return rawdocs.replaceAllMapped(exampleRE, (match) {
      var args = _getExampleArgs(match[1]);
      var lang = args['lang'] ?? p.extension(args['src']).replaceFirst('.', '');

      var replacement = match[0]; // default to fully matched string.

      var fragmentFile = new File(p.join(dirPath, args['file']));
      if (fragmentFile.existsSync()) {
        replacement = fragmentFile.readAsStringSync();
        if (!lang.isEmpty) {
          replacement = replacement.replaceFirst('```', '```$lang');
        }
      } else {
        // TODO(jcollins-g): move this to Package.warn system
        var filePath =
            this.element.source.fullName.substring(dirPath.length + 1);
        final msg =
            '\nwarning: ${filePath}: @example file not found, ${fragmentFile.path}';
        stderr.write(msg);
      }
      return replacement;
    });
  }

  /// Replace {@macro ...} in API comments with the contents of the macro
  ///
  /// Syntax:
  ///
  ///     {@macro NAME}
  ///
  /// Example:
  ///
  /// You define the template anywhere in the comments like:
  ///
  ///     {@template foo}
  ///     Foo contents!
  ///     {@endtemplate}
  ///
  /// and them somewhere use it like this:
  ///
  ///     Some comments
  ///     {@macro foo}
  ///     More comments
  ///
  /// Which will render
  ///
  ///     Some comments
  ///     Foo contents!
  ///     More comments
  ///
  String _injectMacros(String rawDocs) {
    final macroRegExp = new RegExp(r'{@macro\s+([^}]+)}');
    return rawDocs.replaceAllMapped(macroRegExp, (match) {
      return package.getMacro(match[1]);
    });
  }

  /// Parse {@template ...} in API comments and store them in the index on the package.
  ///
  /// Syntax:
  ///
  ///     {@template NAME}
  ///     The contents of the macro
  ///     {@endtemplate}
  ///
  String _stripMacroTemplatesAndAddToIndex(String rawDocs) {
    final templateRegExp = new RegExp(
        r'[ ]*{@template\s+(.+?)}([\s\S]+?){@endtemplate}[ ]*\n?',
        multiLine: true);
    return rawDocs.replaceAllMapped(templateRegExp, (match) {
      package.addMacro(match[1].trim(), match[2].trim());
      return "";
    });
  }

  /// Helper for _injectExamples used to process @example arguments.
  /// Returns a map of arguments. The first unnamed argument will have key 'src'.
  /// The computed file path, constructed from 'src' and 'region' will have key
  /// 'file'.
  Map<String, String> _getExampleArgs(String argsAsString) {
    // Extract PATH and return is under key 'src'
    var endOfSrc = argsAsString.indexOf(' ');
    if (endOfSrc < 0) endOfSrc = argsAsString.length;
    var src = argsAsString.substring(0, endOfSrc);
    src = src.replaceAll('/', Platform.pathSeparator);
    final args = {'src': src};

    // Process remaining named arguments
    var namedArgs = argsAsString.substring(endOfSrc);
    // Arg value: allow optional quotes; warning: we still don't support whitespace.
    RegExp keyValueRE = new RegExp('(\\w+)=[\'"]?(\\S*)[\'"]?');
    Iterable<Match> matches = keyValueRE.allMatches(namedArgs);
    matches.forEach((match) {
      // Ignore optional quotes
      args[match[1]] = match[2].replaceAll(new RegExp('[\'"]'), '');
    });

    // Compute 'file'
    final fragExtension = '.md';
    var file = src + fragExtension;
    var region = args['region'] ?? '';
    if (!region.isEmpty) {
      var dir = p.dirname(src);
      var basename = p.basenameWithoutExtension(src);
      var ext = p.extension(src);
      file = p.join(dir, '$basename-$region$ext$fragExtension');
    }
    args['file'] = config?.examplePathPrefix == null
        ? file
        : p.join(config.examplePathPrefix, file);
    return args;
  }
}

class ModelFunction extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  List<TypeParameter> typeParameters = [];

  ModelFunction(FunctionElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_func.type, this);
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = _func.typeParameters.map((f) {
      return new ModelElement.from(f, library);
    }).toList();
  }

  @override
  ModelElement get enclosingElement => library;

  String get fileName => "$name.html";

  @override
  String get name {
    if (element.enclosingElement is ParameterElement && super.name.isEmpty)
      return element.enclosingElement.name;
    return super.name;
  }

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/$fileName';
  }

  @override
  bool get isStatic => _func.isStatic;

  @override
  String get kind => 'function';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  @override
  String get nameWithGenerics {
    if (typeParameters.isEmpty) return name;
    return '$name&lt;${typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  @override
  String get genericParameters {
    if (typeParameters.isEmpty) return '';
    return '&lt;${typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  FunctionElement get _func => (element as FunctionElement);
}

/// Something that has a name.
abstract class Nameable {
  String get name;

  Set<String> get namePieces => new Set()
    ..addAll(name.split(_locationSplitter).where((s) => s.isNotEmpty));
}

class Operator extends Method {
  static const Map<String, String> friendlyNames = const {
    "[]": "get",
    "[]=": "put",
    "~": "bitwise_negate",
    "==": "equals",
    "-": "minus",
    "+": "plus",
    "*": "multiply",
    "/": "divide",
    "<": "less",
    ">": "greater",
    ">=": "greater_equal",
    "<=": "less_equal",
    "<<": "shift_left",
    ">>": "shift_right",
    "^": "bitwise_exclusive_or",
    "unary-": "unary_minus",
    "|": "bitwise_or",
    "&": "bitwise_and",
    "~/": "truncate_divide",
    "%": "modulo"
  };

  Operator(MethodElement element, Library library) : super(element, library);

  Operator.inherited(
      MethodElement element, Class enclosingClass, Library library)
      : super.inherited(element, enclosingClass, library) {
    _isInherited = true;
  }

  @override
  String get fileName {
    var actualName = super.name;
    if (friendlyNames.containsKey(actualName)) {
      return "operator_${friendlyNames[actualName]}.html";
    } else {
      return '$actualName.html';
    }
  }

  @override
  String get fullyQualifiedName =>
      '${library.name}.${enclosingElement.name}.${super.name}';

  @override
  bool get isOperator => true;

  @override
  String get name {
    return 'operator ${super.name}';
  }

  @override
  String get typeName => 'operator';
}

// The kinds of warnings that can be displayed when documenting a package.
enum PackageWarning {
  ambiguousDocReference,
  ambiguousReexport,
  ignoredCanonicalFor,
  noCanonicalFound,
  noLibraryLevelDocs,
  categoryOrderGivesMissingPackageName,
  unresolvedDocReference,
  brokenLink,
  orphanedFile,
  unknownFile,
  missingFromSearchIndex,
  typeAsHtml,
}

class PackageWarningHelpText {
  final String warningName;
  final String shortHelp;
  List<String> longHelp;
  final PackageWarning warning;

  PackageWarningHelpText(this.warning, this.warningName, this.shortHelp,
      [this.longHelp]) {
    this.longHelp ??= [];
  }
}

/// Provides description text and command line flags for warnings.
/// TODO(jcollins-g): Actually use this for command line flags.
Map<PackageWarning, PackageWarningHelpText> packageWarningText = {
  PackageWarning.ambiguousDocReference: new PackageWarningHelpText(
      PackageWarning.ambiguousDocReference,
      "ambiguous-doc-reference",
      "A comment reference could refer to two or more different objects"),
  PackageWarning.ambiguousReexport: new PackageWarningHelpText(
      PackageWarning.ambiguousReexport,
      "ambiguous-reexport",
      "A symbol is exported from private to public in more than one library and dartdoc can not determine which one is canonical",
      [
        "Use {@canonicalFor @@name@@} in the desired library's documentation to resolve",
        "the ambiguity and/or override dartdoc's decision, or structure your package ",
        "so the reexport is less ambiguous.  The symbol will still be referenced in ",
        "all candidates -- this only controls the location where it will be written ",
        "and which library will be displayed in navigation for the relevant pages.",
        "The flag --ambiguous-reexport-scorer-min-confidence allows you to set the",
        "threshold at which this warning will appear."
      ]),
  PackageWarning.ignoredCanonicalFor: new PackageWarningHelpText(
      PackageWarning.ignoredCanonicalFor,
      "ignored-canonical-for",
      "A @canonicalFor tag refers to a library which this symbol can not be canonical for"),
  PackageWarning.noCanonicalFound: new PackageWarningHelpText(
      PackageWarning.noCanonicalFound,
      "no-canonical-found",
      "A symbol is part of the public interface for this package, but no library documented with this package documents it so dartdoc can not link to it"),
  PackageWarning.noLibraryLevelDocs: new PackageWarningHelpText(
      PackageWarning.noLibraryLevelDocs,
      "no-library-level-docs",
      "There are no library level docs for this library"),
  PackageWarning.categoryOrderGivesMissingPackageName: new PackageWarningHelpText(
      PackageWarning.categoryOrderGivesMissingPackageName,
      "category-order-gives-missing-package-name",
      "The category-order flag on the command line was given the name of a nonexistent package"),
  PackageWarning.unresolvedDocReference: new PackageWarningHelpText(
      PackageWarning.unresolvedDocReference,
      "unresolved-doc-reference",
      "A comment reference could not be found in parameters, enclosing class, enclosing library, or at the top level of any documented library with the package"),
  PackageWarning.brokenLink: new PackageWarningHelpText(
      PackageWarning.brokenLink,
      "brokenLink",
      "Dartdoc generated a link to a non-existent file"),
  PackageWarning.orphanedFile: new PackageWarningHelpText(
      PackageWarning.orphanedFile,
      "orphanedFile",
      "Dartdoc generated files that are unreachable from the index"),
  PackageWarning.unknownFile: new PackageWarningHelpText(
      PackageWarning.unknownFile,
      "unknownFile",
      "A leftover file exists in the tree that dartdoc did not write in this pass"),
  PackageWarning.missingFromSearchIndex: new PackageWarningHelpText(
      PackageWarning.missingFromSearchIndex,
      "missingFromSearchIndex",
      "A file generated by dartdoc is not present in the generated index.json"),
  PackageWarning.typeAsHtml: new PackageWarningHelpText(
      PackageWarning.typeAsHtml,
      "typeAsHtml",
      "Use of <> in a comment for type parameters is being treated as HTML by markdown"),
};

/// Something that package warnings can be called on.
abstract class Warnable implements Locatable {
  void warn(PackageWarning warning,
      {String message, Iterable<Locatable> referredFrom});
  Warnable get enclosingElement;
}

/// Something that can be located for warning purposes.
abstract class Locatable {
  String get fullyQualifiedName;
  String get href;
  List<Locatable> get documentationFrom;
  Element get element;
  String get elementLocation;
  Tuple2<int, int> get lineAndColumn;
  bool get isCanonical;
}

class PackageWarningOptions {
  // PackageWarnings must be in one of _ignoreWarnings or union(_asWarnings, _asErrors)
  final Set<PackageWarning> _ignoreWarnings = new Set();
  // PackageWarnings can be in both asWarnings and asErrors, latter takes precedence
  final Set<PackageWarning> _asWarnings = new Set();
  final Set<PackageWarning> _asErrors = new Set();

  bool autoFlush = true;

  Set<PackageWarning> get ignoreWarnings => _ignoreWarnings;
  Set<PackageWarning> get asWarnings => _asWarnings;
  Set<PackageWarning> get asErrors => _asErrors;

  PackageWarningOptions() {
    _asWarnings.addAll(PackageWarning.values);
    ignore(PackageWarning.typeAsHtml);
  }

  void _assertInvariantsOk() {
    assert(_asWarnings
        .union(_asErrors)
        .union(_ignoreWarnings)
        .containsAll(PackageWarning.values.toSet()));
    assert(_asWarnings.union(_asErrors).intersection(_ignoreWarnings).isEmpty);
  }

  void ignore(PackageWarning kind) {
    _assertInvariantsOk();
    _asWarnings.remove(kind);
    _asErrors.remove(kind);
    _ignoreWarnings.add(kind);
    _assertInvariantsOk();
  }

  void warn(PackageWarning kind) {
    _assertInvariantsOk();
    _ignoreWarnings.remove(kind);
    _asWarnings.add(kind);
    _asErrors.remove(kind);
    _assertInvariantsOk();
  }

  void error(PackageWarning kind) {
    _assertInvariantsOk();
    _ignoreWarnings.remove(kind);
    _asWarnings.add(kind);
    _asErrors.add(kind);
    _assertInvariantsOk();
  }
}

class PackageWarningCounter {
  final Map<Element, Set<Tuple2<PackageWarning, String>>> _countedWarnings =
      new Map();
  final Map<PackageWarning, int> _warningCounts = new Map();
  final PackageWarningOptions options;

  StringBuffer buffer = new StringBuffer();

  PackageWarningCounter(this.options);

  /// Flush to stderr, but only if [options.autoFlush] is true.
  ///
  /// We keep a buffer because under certain conditions (--auto-include-dependencies)
  /// warnings here might be duplicated across multiple Package constructions.
  void maybeFlush() {
    if (options.autoFlush) {
      stderr.write(buffer.toString());
      buffer = new StringBuffer();
    }
  }

  /// Actually write out the warning.  Assumes it is already counted with add.
  void _writeWarning(PackageWarning kind, String name, String fullMessage) {
    if (options.ignoreWarnings.contains(kind)) return;
    String toWrite;
    if (!options.asErrors.contains(kind)) {
      if (options.asWarnings.contains(kind))
        toWrite = "warning: ${fullMessage}";
    } else {
      if (options.asErrors.contains(kind)) toWrite = "error: ${fullMessage}";
    }
    if (toWrite != null) {
      buffer.write("\n ${toWrite}");
      if (_warningCounts[kind] == 1 &&
          config.verboseWarnings &&
          packageWarningText[kind].longHelp.isNotEmpty) {
        // First time we've seen this warning.  Give a little extra info.
        final String separator = '\n            ';
        final String nameSub = r'@@name@@';
        String verboseOut =
            '$separator${packageWarningText[kind].longHelp.join(separator)}';
        verboseOut = verboseOut.replaceAll(nameSub, name);
        buffer.write(verboseOut);
      }
    }
    maybeFlush();
  }

  /// Returns true if we've already warned for this.
  bool hasWarning(Warnable element, PackageWarning kind, String message) {
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    if (_countedWarnings.containsKey(element?.element)) {
      return _countedWarnings[element?.element].contains(warningData);
    }
    return false;
  }

  /// Adds the warning to the counter, and writes out the fullMessage string
  /// if configured to do so.
  void addWarning(Warnable element, PackageWarning kind, String message,
      String fullMessage) {
    assert(!hasWarning(element, kind, message));
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    _warningCounts.putIfAbsent(kind, () => 0);
    _warningCounts[kind] += 1;
    _countedWarnings.putIfAbsent(element?.element, () => new Set());
    _countedWarnings[element?.element].add(warningData);
    _writeWarning(kind, element?.fullyQualifiedName, fullMessage);
  }

  int get errorCount {
    return _warningCounts.keys
        .map((w) => options.asErrors.contains(w) ? _warningCounts[w] : 0)
        .reduce((a, b) => a + b);
  }

  int get warningCount {
    return _warningCounts.keys
        .map((w) =>
            options.asWarnings.contains(w) && !options.asErrors.contains(w)
                ? _warningCounts[w]
                : 0)
        .reduce((a, b) => a + b);
  }

  @override
  String toString() {
    String errors = '$errorCount ${errorCount == 1 ? "error" : "errors"}';
    String warnings =
        '$warningCount ${warningCount == 1 ? "warning" : "warnings"}';
    return [errors, warnings].join(', ');
  }
}

class Package extends Nameable implements Documentable {
  // Library objects serving as entry points for documentation.
  final List<Library> _libraries = [];

  // All library objects related to this package; a superset of _libraries.
  final Map<LibraryElement, Library> allLibraries = new Map();

  // Objects to keep track of warnings.
  final PackageWarningOptions _packageWarningOptions;

  PackageWarningCounter _packageWarningCounter;

  // All ModelElements constructed for this package; a superset of allModelElements.
  final Map<Tuple3<Element, Library, Class>, ModelElement>
      _allConstructedModelElements = new Map();

  // Anything that might be inheritable, place here for later lookup.
  final Map<Tuple2<Element, Library>, Set<ModelElement>>
      _allInheritableElements = new Map();

  /// Map of Class.href to a list of classes implementing that class
  final Map<String, List<Class>> _implementors = new Map();

  final PackageMeta packageMeta;

  @override
  Package get package => this;

  @override
  Documentable get overriddenDocumentedElement => this;

  @override
  List<Documentable> get documentationFrom => [this];

  @override
  Warnable get enclosingElement => null;

  @override
  bool get hasExtendedDocumentation => documentation.isNotEmpty;

  final Map<Element, Library> _elementToLibrary = {};
  String _docsAsHtml;
  final Map<String, String> _macros = {};
  bool allLibrariesAdded = false;

  Package(Iterable<LibraryElement> libraryElements, this.packageMeta,
      this._packageWarningOptions) {
    assert(_allConstructedModelElements.isEmpty);
    assert(allLibraries.isEmpty);
    _packageWarningCounter = new PackageWarningCounter(_packageWarningOptions);
    libraryElements.forEach((element) {
      // add only if the element should be included in the public api
      var lib = new Library._(element, this);
      if (lib.isPublic) {
        _libraries.add(lib);
        allLibraries[element] = lib;
        assert(!_elementToLibrary.containsKey(lib.element));
        _elementToLibrary[element] = lib;
      }
    });

    _libraries.sort((a, b) => compareNatural(a.name, b.name));
    allLibrariesAdded = true;
    _libraries.forEach((library) {
      library._allClasses.forEach(_addToImplementors);
    });

    _implementors.values.forEach((l) => l.sort());
  }

  @override
  Element get element => null;

  @override
  String get elementLocation => '(top level package)';

  /// Flush out any warnings we might have collected while
  /// [_packageWarningOptions.autoFlush] was false.
  void flushWarnings() {
    _packageWarningCounter.maybeFlush();
  }

  @override
  Tuple2<int, int> get lineAndColumn => null;

  @override
  String get fullyQualifiedName => name;

  @override
  bool get isCanonical => true;

  PackageWarningCounter get packageWarningCounter => _packageWarningCounter;

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    warnOnElement(this, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  /// Returns colon-stripped name and location of the given locatable.
  static Tuple2<String, String> nameAndLocation(Locatable locatable) {
    String locatableName = '<unknown>';
    String locatableLocation = '';
    if (locatable != null) {
      locatableName = locatable.fullyQualifiedName.replaceFirst(':', '-');
      locatableLocation = locatable.elementLocation;
    }
    return new Tuple2(locatableName, locatableLocation);
  }

  void warnOnElement(Warnable warnable, PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    if (warnable != null) {
      // This sort of warning is only applicable to top level elements.
      if (kind == PackageWarning.ambiguousReexport) {
        while (warnable.enclosingElement is! Library &&
            warnable.enclosingElement != null) {
          warnable = warnable.enclosingElement;
        }
      }
      if (warnable is Accessor) {
        // This might be part of a Field, if so, assign this warning to the field
        // rather than the Accessor.
        if ((warnable as Accessor).enclosingCombo != null)
          warnable = (warnable as Accessor).enclosingCombo;
      }
    } else {
      // If we don't have an element, we need a message to disambiguate.
      assert(message != null);
    }
    if (_packageWarningCounter.hasWarning(warnable, kind, message)) {
      return;
    }
    // Elements that are part of the Dart SDK can have colons in their FQNs.
    // This confuses IntelliJ and makes it so it can't link to the location
    // of the error in the console window, so separate out the library from
    // the path.
    // TODO(jcollins-g): What about messages that may include colons?  Substituting
    //                   them out doesn't work as well there since it might confuse
    //                   the user, yet we still want IntelliJ to link properly.
    Tuple2<String, String> warnableStrings = nameAndLocation(warnable);
    String warnablePrefix = 'from';
    String referredFromPrefix = 'referred to by';
    String name = warnableStrings.item1;
    String warningMessage;
    switch (kind) {
      case PackageWarning.noCanonicalFound:
        // Fix these warnings by adding libraries with --include, or by using
        // --auto-include-dependencies.
        // TODO(jcollins-g): add a dartdoc flag to enable external website linking for non-canonical elements, using .packages for versioning
        // TODO(jcollins-g): support documenting multiple packages at once and linking between them
        warningMessage = "no canonical library found for ${name}, not linking";
        break;
      case PackageWarning.ambiguousReexport:
        // Fix these warnings by adding the original library exporting the
        // symbol with --include, by using --auto-include-dependencies,
        // or by using --exclude to hide one of the libraries involved
        warningMessage =
            "ambiguous reexport of ${name}, canonicalization candidates: ${message}";
        break;
      case PackageWarning.noLibraryLevelDocs:
        warningMessage =
            "${warnable.fullyQualifiedName} has no library level documentation comments";
        break;
      case PackageWarning.ambiguousDocReference:
        warningMessage = "ambiguous doc reference ${message}";
        break;
      case PackageWarning.ignoredCanonicalFor:
        warningMessage =
            "library says it is {@canonicalFor ${message}} but ${message} can't be canonical there";
        break;
      case PackageWarning.categoryOrderGivesMissingPackageName:
        warningMessage =
            "--category-order gives invalid package name: '${message}'";
        break;
      case PackageWarning.unresolvedDocReference:
        warningMessage = "unresolved doc reference [${message}]";
        if (referredFrom == null) {
          referredFrom = warnable.documentationFrom;
        }
        referredFromPrefix = 'in documentation inherited from';
        break;
      case PackageWarning.brokenLink:
        warningMessage = 'dartdoc generated a broken link to: ${message}';
        warnablePrefix = 'to element';
        referredFromPrefix = 'linked to from';
        break;
      case PackageWarning.orphanedFile:
        warningMessage = 'dartdoc generated a file orphan: ${message}';
        break;
      case PackageWarning.unknownFile:
        warningMessage =
            'dartdoc detected an unknown file in the doc tree: ${message}';
        break;
      case PackageWarning.missingFromSearchIndex:
        warningMessage =
            'dartdoc generated a file not in the search index: ${message}';
        break;
      case PackageWarning.typeAsHtml:
        // The message for this warning can contain many punctuation and other symbols,
        // so bracket with a triple quote for defense.
        warningMessage = 'generic type handled as HTML: """${message}"""';
        break;
    }

    List<String> messageParts = [warningMessage];
    if (warnable != null)
      messageParts.add(
          "${warnablePrefix} ${warnableStrings.item1}: ${warnableStrings.item2}");
    if (referredFrom != null) {
      for (Locatable referral in referredFrom) {
        if (referral != warnable) {
          Tuple2<String, String> referredFromStrings =
              nameAndLocation(referral);
          messageParts.add(
              "${referredFromPrefix} ${referredFromStrings.item1}: ${referredFromStrings.item2}");
        }
      }
    }
    if (config.verboseWarnings && extendedDebug != null)
      messageParts.addAll(extendedDebug.map((s) => "    $s"));
    String fullMessage;
    if (messageParts.length <= 2) {
      fullMessage = messageParts.join(', ');
    } else {
      fullMessage = messageParts.join('\n    ');
    }

    packageWarningCounter.addWarning(warnable, kind, message, fullMessage);
  }

  static Package _withAutoIncludedDependencies(
      Set<LibraryElement> libraryElements,
      PackageMeta packageMeta,
      PackageWarningOptions options) {
    var startLength = libraryElements.length;
    options.autoFlush = false;
    Package package = new Package(libraryElements, packageMeta, options);

    // TODO(jcollins-g): this is inefficient; keep track of modelElements better
    package.allModelElements.forEach((modelElement) {
      modelElement.usedElements.forEach((used) {
        if (used != null && used.modelType != null) {
          final ModelElement modelTypeElement = used.modelType.element;
          final library = package.findLibraryFor(modelTypeElement.element);
          if (library == null &&
              modelTypeElement.library != null &&
              !hasPrivateName(modelTypeElement.library.element) &&
              modelTypeElement.library.canonicalLibrary == null &&
              !libraryElements.contains(modelTypeElement.library.element)) {
            libraryElements.add(modelTypeElement.library.element);
          }
        }
      });
    });

    if (libraryElements.length > startLength)
      package =
          _withAutoIncludedDependencies(libraryElements, packageMeta, options);
    options.autoFlush = true;
    package.flushWarnings;
    return package;
  }

  static Package withAutoIncludedDependencies(
      Iterable<LibraryElement> libraryElements,
      PackageMeta packageMeta,
      PackageWarningOptions options) {
    return _withAutoIncludedDependencies(
        new Set()..addAll(libraryElements), packageMeta, options);
  }

  List<PackageCategory> get categories {
    Map<String, PackageCategory> result = {};

    for (Library library in _libraries) {
      String name = '';

      if (library.name.startsWith('dart:')) {
        name = 'Dart Core';
      } else {
        name = library.packageName;
      }

      if (!result.containsKey(name)) {
        result[name] = new PackageCategory(name, this);
      }
      result[name]._libraries.add(library);
    }
    // Help the user if they pass us a category that doesn't exist.
    for (String categoryName in config.categoryOrder) {
      if (!result.containsKey(categoryName))
        warnOnElement(null, PackageWarning.categoryOrderGivesMissingPackageName,
            message: "${categoryName}, categories: ${result.keys.join(',')}");
    }
    List<PackageCategory> packageCategories = result.values.toList()..sort();
    return packageCategories;
  }

  Map<LibraryElement, Set<Library>> _libraryElementReexportedBy;
  void _tagReexportsFor(
      final Library tll, final LibraryElement libraryElement) {
    _libraryElementReexportedBy.putIfAbsent(libraryElement, () => new Set());
    _libraryElementReexportedBy[libraryElement].add(tll);
    for (ExportElement exportedElement in libraryElement.exports) {
      if ((!_elementToLibrary.containsKey(exportedElement.library)) ||
          libraryElement == tll.element) {
        _tagReexportsFor(tll, exportedElement.exportedLibrary);
      }
    }
  }

  Map<LibraryElement, Set<Library>> get libraryElementReexportedBy {
    // Table must be reset if we're still in the middle of adding libraries.
    if (_libraryElementReexportedBy == null || !allLibrariesAdded) {
      _libraryElementReexportedBy = new Map<LibraryElement, Set<Library>>();
      for (Library library in libraries) {
        _tagReexportsFor(library, library.element);
      }
    }
    return _libraryElementReexportedBy;
  }

  @override
  String get documentation {
    return hasDocumentationFile ? documentationFile.contents : null;
  }

  /// A lookup index for hrefs to allow warnings to indicate where a broken
  /// link or orphaned file may have come from.  Not cached because
  /// [ModelElement]s can be created at any time and we're basing this
  /// on more than just [allModelElements] to make the error messages
  /// comprehensive.
  Map<String, Set<ModelElement>> get allHrefs {
    Map<String, Set<ModelElement>> hrefMap = new Map();
    // TODO(jcollins-g ): handle calculating hrefs causing new elements better
    //                    than toList().
    for (ModelElement modelElement
        in _allConstructedModelElements.values.toList()) {
      // Technically speaking we should be able to use canonical model elements
      // only here, but since the warnings that depend on this debug
      // canonicalization problems, don't limit ourselves in case an href is
      // generated for something non-canonical.
      if (modelElement.href == null) continue;
      hrefMap.putIfAbsent(modelElement.href, () => new Set());
      hrefMap[modelElement.href].add(modelElement);
    }
    for (Library library in _libraries) {
      if (library.href == null) continue;
      hrefMap.putIfAbsent(library.href, () => new Set());
      hrefMap[library.href].add(library);
    }
    return hrefMap;
  }

  @override
  String get documentationAsHtml {
    if (_docsAsHtml != null) return _docsAsHtml;
    _docsAsHtml = new Documentation.forElement(this).asHtml;

    return _docsAsHtml;
  }

  FileContents get documentationFile => packageMeta.getReadmeContents();

  // TODO: make this work
  @override
  bool get hasDocumentation =>
      documentationFile != null && documentationFile.contents.isNotEmpty;

  // TODO: Clients should use [documentationFile] so they can act differently on
  // plain text or markdown.
  bool get hasDocumentationFile => documentationFile != null;

  // TODO: make this work
  @override
  String get href => 'index.html';

  /// Does this package represent the SDK?
  bool get isSdk => packageMeta.isSdk;

  void _addToImplementors(Class c) {
    _implementors.putIfAbsent(c.href, () => []);
    void _checkAndAddClass(Class key, Class implClass) {
      _implementors.putIfAbsent(key.href, () => []);
      List list = _implementors[key.href];

      if (!list.any((l) => l.element == c.element)) {
        list.add(implClass);
      }
    }

    if (!c._mixins.isEmpty) {
      c._mixins.forEach((t) {
        _checkAndAddClass(t.element, c);
      });
    }
    if (c._supertype != null) {
      _checkAndAddClass(c._supertype.element, c);
    }
    if (!c._interfaces.isEmpty) {
      c._interfaces.forEach((t) {
        _checkAndAddClass(t.element, c);
      });
    }
  }

  List<Library> get libraries => _libraries.toList(growable: false);

  bool get hasHomepage =>
      packageMeta.homepage != null && packageMeta.homepage.isNotEmpty;
  String get homepage => packageMeta.homepage;

  @override
  String get name => packageMeta.name;

  String get kind =>
      (packageMeta.useCategories || package.isSdk) ? '' : 'package';

  @override
  String get oneLineDoc => '';

  // Written from ModelElement.from.
  ModelElement _objectElement;
  // Return the element for "Object".
  ModelElement get objectElement => _objectElement;

  String get version => packageMeta.version;

  /// Looks up some [Library] that is reexporting this [Element]; not
  /// necessarily the canonical [Library].
  Library findLibraryFor(Element element) {
    // Maybe we were given an element we already saw, or an element for the
    // Library itself added by the constructor in [ModelElement.from].
    if (_elementToLibrary.containsKey(element)) {
      return _elementToLibrary[element];
    }
    Library foundLibrary;
    if (libraryElementReexportedBy.containsKey(element.library)) {
      Set<Library> exportedIn = libraryElementReexportedBy[element.library];
      foundLibrary = exportedIn.firstWhere(
          (l) =>
              l.element.location.components[0] ==
              element.library.location.components[0],
          orElse: () => null);
    }
    if (foundLibrary != null) _elementToLibrary[element] = foundLibrary;
    return foundLibrary;
  }

  /// @deprecated('Whether something is documented should be a ModelElement property')
  bool isDocumented(Element element) {
    // If this isn't a private element and we have a canonical Library for it,
    // this element will be documented.
    if (hasPrivateName(element)) return false;
    return findCanonicalLibraryFor(element) != null;
  }

  @override
  String toString() => isSdk ? 'SDK' : 'Package $name';

  final Map<Element, Library> _canonicalLibraryFor = new Map();

  /// Tries to find a top level library that references this element.
  Library findCanonicalLibraryFor(Element e) {
    assert(allLibrariesAdded);
    Element searchElement = e;
    if (e is PropertyAccessorElement) {
      searchElement = e.variable;
    }

    if (_canonicalLibraryFor.containsKey(e)) {
      return _canonicalLibraryFor[e];
    }
    _canonicalLibraryFor[e] = null;
    for (Library library in libraries) {
      if (library.modelElementsMap.containsKey(searchElement)) {
        for (ModelElement modelElement
            in library.modelElementsMap[searchElement]) {
          if (modelElement.isCanonical) {
            _canonicalLibraryFor[e] = library;
            break;
          }
        }
      }
    }
    return _canonicalLibraryFor[e];
  }

  // TODO(jcollins-g): Revise when dart-lang/sdk#29600 is fixed.
  static Element getBasestElement(Element possibleMember) {
    Element element = possibleMember;
    while (element is Member) {
      element = (element as Member).baseElement;
    }
    return element;
  }

  /// Tries to find a canonical ModelElement for this element.  If we know
  /// this element is related to a particular class, pass preferredClass to
  /// disambiguate.
  ModelElement findCanonicalModelElementFor(Element e, {Class preferredClass}) {
    assert(allLibrariesAdded);
    Library lib = findCanonicalLibraryFor(e);
    if (lib == null && preferredClass != null) {
      lib = findCanonicalLibraryFor(preferredClass.element);
    }
    ModelElement modelElement;
    // TODO(jcollins-g): Special cases are pretty large here.  Refactor to split
    // out into helpers.
    // TODO(jcollins-g): The data structures should be changed to eliminate guesswork
    // with member elements.
    if (e is ClassMemberElement || e is PropertyAccessorElement) {
      // Prefer Fields over Accessors.
      if (e is PropertyAccessorElement)
        e = (e as PropertyAccessorElement).variable;
      if (e is Member) e = getBasestElement(e);
      Set<ModelElement> candidates = new Set();
      Tuple2<Element, Library> iKey = new Tuple2(e, lib);
      Tuple4<Element, Library, Class, ModelElement> key =
          new Tuple4(e, lib, null, null);
      Tuple4<Element, Library, Class, ModelElement> keyWithClass =
          new Tuple4(e, lib, preferredClass, null);
      if (_allConstructedModelElements.containsKey(key)) {
        candidates.add(_allConstructedModelElements[key]);
      }
      if (_allConstructedModelElements.containsKey(keyWithClass)) {
        candidates.add(_allConstructedModelElements[keyWithClass]);
      }
      if (candidates.isEmpty && _allInheritableElements.containsKey(iKey)) {
        candidates.addAll(
            _allInheritableElements[iKey].where((me) => me.isCanonical));
      }
      Class canonicalClass = findCanonicalModelElementFor(e.enclosingElement);
      if (canonicalClass != null) {
        candidates.addAll(canonicalClass.allCanonicalModelElements.where((m) {
          if (m.element is FieldElement) {
            FieldElement fieldElement = m.element as FieldElement;
            Element getter;
            Element setter;
            if (fieldElement.getter?.isSynthetic == true) {
              getter = fieldElement.getter.variable;
            } else {
              getter = fieldElement.getter;
            }
            if (fieldElement.setter?.isSynthetic == true) {
              setter = fieldElement.setter.variable;
            } else {
              setter = fieldElement.setter;
            }
            if (setter == e || getter == e) return true;
          }
          if (m.element == e) return true;
          return false;
        }));
      }
      Set<ModelElement> matches = new Set()
        ..addAll(candidates.where((me) => me.isCanonical));

      // This is for situations where multiple classes may actually be canonical
      // for an inherited element whose defining Class is not canonical.
      if (matches.length > 1 && preferredClass != null) {
        // Search for matches inside our superchain.
        List<Class> superChain =
            preferredClass.superChainRaw.map((et) => et.element).toList();
        superChain.add(preferredClass);
        matches.removeWhere((me) =>
            !superChain.contains((me as EnclosedElement).enclosingElement));
      }
      assert(matches.length <= 1);
      if (!matches.isEmpty) modelElement = matches.first;
    } else {
      if (lib != null) {
        Accessor getter;
        Accessor setter;
        if (e is PropertyInducingElement) {
          if (e.getter != null) getter = new ModelElement.from(e.getter, lib);
          if (e.setter != null) setter = new ModelElement.from(e.setter, lib);
        }
        modelElement =
            new ModelElement.from(e, lib, getter: getter, setter: setter);
      }
      assert(modelElement is! Inheritable);
      if (modelElement != null && !modelElement.isCanonical) {
        modelElement = null;
      }
    }
    return modelElement;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library findOrCreateLibraryFor(Element e) {
    // This is just a cache to avoid creating lots of libraries over and over.
    if (allLibraries.containsKey(e.library)) {
      return allLibraries[e.library];
    }
    // can be null if e is for dynamic
    if (e.library == null) {
      return null;
    }
    Library foundLibrary = findLibraryFor(e);

    if (foundLibrary == null) {
      foundLibrary = new Library._(e.library, this);
      allLibraries[e.library] = foundLibrary;
    }
    return foundLibrary;
  }

  List<ModelElement> _allModelElements;
  Iterable<ModelElement> get allModelElements {
    assert(allLibrariesAdded);
    if (_allModelElements == null) {
      _allModelElements = [];
      this.libraries.forEach((library) {
        _allModelElements.addAll(library.allModelElements);
      });
    }
    return _allModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;
  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }

  String getMacro(String name) => _macros[name];

  void addMacro(String name, String content) {
    _macros[name] = content;
  }
}

class PackageCategory implements Comparable<PackageCategory> {
  final String name;
  final List<Library> _libraries = [];
  Package package;

  PackageCategory(this.name, this.package);

  List<Library> get libraries => _libraries;

  @override
  String toString() => name;

  /// Returns:
  /// -1 if this category is listed in --category-order.
  /// 0 if this category is the original package we are documenting.
  /// 1 if this group represents the Dart SDK.
  /// 2 if this group has a name that contains the name of the original
  ///   package we are documenting.
  /// 3 otherwise.
  int get _group {
    if (config.categoryOrder.contains(name)) return -1;
    if (name.toLowerCase() == package.name.toLowerCase()) return 0;
    if (name == "Dart Core") return 1;
    if (name.toLowerCase().contains(package.name.toLowerCase())) return 2;
    return 3;
  }

  @override
  int compareTo(PackageCategory other) {
    if (_group == other._group) {
      if (_group == -1) {
        return Comparable.compare(config.categoryOrder.indexOf(name),
            config.categoryOrder.indexOf(other.name));
      } else {
        return name.toLowerCase().compareTo(other.name.toLowerCase());
      }
    }
    return Comparable.compare(_group, other._group);
  }
}

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(ParameterElement element, Library library)
      : super(element, library) {
    var t = _parameter.type;
    _modelType = new ElementType(
        t,
        new ModelElement.from(
            t.element, _findOrCreateEnclosingLibraryFor(t.element)));
  }

  String get defaultValue {
    if (!hasDefaultValue) return null;
    return _parameter.defaultValueCode;
  }

  @override
  ModelElement get enclosingElement =>
      new ModelElement.from(_parameter.enclosingElement, library);

  bool get hasDefaultValue {
    return _parameter.defaultValueCode != null &&
        _parameter.defaultValueCode.isNotEmpty;
  }

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    var p = _parameter.enclosingElement;

    if (p is FunctionElement) {
      return '${canonicalLibrary.dirName}/${p.name}.html';
    } else {
      // TODO: why is this logic here?
      var name = Operator.friendlyNames.containsKey(p.name)
          ? Operator.friendlyNames[p.name]
          : p.name;
      return '${canonicalLibrary.dirName}/${p.enclosingElement.name}/' +
          '${name}.html#${htmlId}';
    }
  }

  @override
  String get htmlId => '${_parameter.enclosingElement.name}-param-${name}';

  bool get isOptional => _parameter.parameterKind.isOptional;

  bool get isOptionalNamed => _parameter.parameterKind == ParameterKind.NAMED;

  bool get isOptionalPositional =>
      _parameter.parameterKind == ParameterKind.POSITIONAL;

  @override
  String get kind => 'parameter';

  ParameterElement get _parameter => element as ParameterElement;

  @override
  String toString() => element.name;
}

abstract class SourceCodeMixin {
  String _sourceCodeCache;
  String get crossdartHtmlTag {
    if (config != null && config.addCrossdart && _crossdartUrl != null) {
      return "<a class='crossdart' href='${_crossdartUrl}'>Link to Crossdart</a>";
    } else {
      return "";
    }
  }

  Tuple2<int, int> get lineAndColumn;

  Element get element;

  bool get hasSourceCode => config.includeSource && sourceCode.isNotEmpty;

  Library get library;

  String get sourceCode {
    if (_sourceCodeCache == null) {
      String contents = getFileContentsFor(element);
      var node = element.computeNode();
      if (node != null) {
        // Find the start of the line, so that we can line up all the indents.
        int i = node.offset;
        while (i > 0) {
          i -= 1;
          if (contents[i] == '\n' || contents[i] == '\r') {
            i += 1;
            break;
          }
        }

        // Trim the common indent from the source snippet.
        var start = node.offset - (node.offset - i);
        String source = contents.substring(start, node.end);

        if (config != null && config.addCrossdart) {
          source = crossdartifySource(_crossdartJson, source, element, start);
        } else {
          source = const HtmlEscape().convert(source);
        }
        source = stripIndentFromSource(source);
        source = stripDartdocCommentsFromSource(source);

        _sourceCodeCache = source.trim();
      } else {
        _sourceCodeCache = '';
      }
    }

    return _sourceCodeCache;
  }

  String get _crossdartPath {
    var node = element.computeNode();
    if (node is Declaration && node.element != null) {
      var source = node.element.source;
      var filePath = source.fullName;
      var uri = source.uri.toString();
      var packageMeta = library.package.packageMeta;
      if (uri.startsWith("package:")) {
        var splittedUri =
            uri.replaceAll(new RegExp(r"^package:"), "").split("/");
        var packageName = splittedUri.first;
        var packageVersion;
        if (packageName == packageMeta.name) {
          packageVersion = packageMeta.version;
        } else {
          var match = new RegExp(
                  ".pub-cache/(hosted/pub.dartlang.org|git)/${packageName}-([^/]+)")
              .firstMatch(filePath);
          if (match != null) {
            packageVersion = match[2];
          }
        }
        if (packageVersion != null) {
          return "${packageName}/${packageVersion}/${splittedUri.skip(1).join("/")}";
        } else {
          return null;
        }
      } else if (uri.startsWith("dart:")) {
        var packageName = "sdk";
        var packageVersion = config.sdkVersion;
        return "${packageName}/${packageVersion}/lib/${uri.replaceAll(new RegExp(r"^dart:"), "")}";
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String get _crossdartUrl {
    if (lineAndColumn != null && _crossdartPath != null) {
      String url = "//www.crossdart.info/p/${_crossdartPath}.html";
      return "${url}#line-${lineAndColumn.item1}";
    } else {
      return null;
    }
  }

  void clearSourceCodeCache() {
    _sourceCodeCache = null;
  }
}

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement
    with GetterSetterCombo
    implements EnclosedElement {
  @override
  final Accessor getter;
  @override
  final Accessor setter;

  TopLevelVariable(TopLevelVariableElement element, Library library,
      this.getter, this.setter)
      : super(element, library) {
    if (hasGetter) {
      var t = _variable.getter.returnType;

      _modelType = new ElementType(
          t,
          new ModelElement.from(
              t.element, package.findOrCreateLibraryFor(t.element)));
    } else {
      var s = _variable.setter.parameters.first.type;
      _modelType = new ElementType(
          s,
          new ModelElement.from(
              s.element, package.findOrCreateLibraryFor(s.element)));
    }
    if (getter != null) getter.enclosingCombo = this;
    if (setter != null) setter.enclosingCombo = this;
  }

  @override
  bool get isInherited => false;

  String get constantValue {
    var v = _variable.computeNode().toSource();
    if (v == null) return '';
    var string = v.substring(v.indexOf('=') + 1, v.length).trim();
    string = HTML_ESCAPE.convert(string);
    return string.replaceAll(modelType.name, modelType.linkedName);
  }

  String get constantValueTruncated => truncateString(constantValue, 200);

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    Set<bool> assertCheck = new Set()
      ..addAll([hasPublicSetter, hasPublicGetterNoSetter]);
    assert(assertCheck.containsAll([true, false]));
    return super.documentation;
  }

  @override
  ModelElement get enclosingElement => library;

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/$_fileName';
  }

  @override
  bool get isConst => _variable.isConst;

  @override
  bool get isFinal {
    /// isFinal returns true for the variable even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return _variable.isFinal;
  }

  @override
  String get kind => 'top-level property';

  @override
  Set<String> get features {
    Set<String> all_features = super.features;

    /// final/const implies read-only, so don't display both strings.
    if (readOnly && !isFinal && !isConst) all_features.add('read-only');
    if (writeOnly) all_features.add('write-only');
    if (readWrite) all_features.add('read / write');
    return all_features;
  }

  @override
  String get computeDocumentationComment {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _variable.documentationComment;
    return docs;
  }

  String get _fileName => isConst ? '$name-constant.html' : '$name.html';

  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);
}

class Typedef extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  Typedef(FunctionTypeAliasElement element, Library library)
      : super(element, library) {
    if (element.type != null) {
      _modelType = new ElementType(element.type, this);
    }
  }

  @override
  ModelElement get enclosingElement => library;

  String get fileName => '$name.html';

  @override
  String get genericParameters {
    if (element is GenericTypeAliasElement) {
      List<TypeParameterElement> genericTypeParameters =
          (element as GenericTypeAliasElement).function.typeParameters;
      if (genericTypeParameters.isNotEmpty) {
        return '&lt;${genericTypeParameters.map((t) => t.name).join(', ')}&gt;';
      }
    } // else, all types are resolved.
    return '';
  }

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/$fileName';
  }

  @override
  String get kind => 'typedef';

  String get linkedReturnType => modelType != null
      ? modelType.createLinkedReturnTypeName()
      : _typedef.returnType.name;

  @override
  String get nameWithGenerics {
    if (!modelType.isParameterizedType) return name;
    return '$name&lt;${_typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  List<TypeParameter> get _typeParameters => _typedef.typeParameters.map((f) {
        return new ModelElement.from(f, library);
      }).toList();
}

class TypeParameter extends ModelElement {
  TypeParameter(TypeParameterElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_typeParameter.type, this);
  }

  @override
  ModelElement get enclosingElement =>
      new ModelElement.from(element.enclosingElement, library);

  @override
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/${_typeParameter.enclosingElement.name}/$name';
  }

  @override
  String get kind => 'type parameter';

  @override
  String get name {
    var bound = _typeParameter.bound;
    return bound != null
        ? '${_typeParameter.name} extends ${bound.name}'
        : _typeParameter.name;
  }

  TypeParameterElement get _typeParameter => element as TypeParameterElement;

  @override
  String toString() => element.name;
}
