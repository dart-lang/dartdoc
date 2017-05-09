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
        FormalParameter,
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
        while (searchElement is Member) {
          searchElement = (searchElement as Member).baseElement;
        }
        bool foundElement = false;
        // TODO(jcollins-g): generate warning if an inherited element's definition
        // is in an intermediate non-canonical class in the inheritance chain
        for (Class c in inheritance.reversed) {
          if (!foundElement && c.contains(searchElement)) {
            foundElement = true;
          }
          Class canonicalC = package.findCanonicalModelElementFor(c.element);
          if (canonicalC != null && foundElement) {
            _canonicalEnclosingClass = c;
            break;
          }
        }
        if (definingEnclosingElement.isCanonical) {
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

/// Getters and setters.
class Accessor extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  ModelElement _enclosingCombo;
  Accessor(
      PropertyAccessorElement element, Library library, this._enclosingCombo)
      : super(element, library);

  ModelElement get enclosingCombo => _enclosingCombo;

  @override
  void warn(PackageWarning kind, [String message]) {
    if (enclosingCombo != null) {
      enclosingCombo.warn(kind, message);
    } else {
      super.warn(kind, message);
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
  String get href {
    if (canonicalLibrary == null) return null;
    return '${canonicalLibrary.dirName}/${_accessor.enclosingElement.name}/${name}.html';
  }

  bool get isGetter => _accessor.isGetter;

  ModelElement _overriddenElement;
  @override
  Accessor get overriddenElement {
    assert(package.allLibrariesAdded);
    if (_overriddenElement == null) {
      Element parent = element.enclosingElement;
      if (parent is ClassElement) {
        for (InterfaceType t in getAllSupertypes(parent)) {
          var accessor = this.isGetter
              ? t.getGetter(element.name)
              : t.getSetter(element.name);
          if (accessor != null) {
            Class parentClass = new ModelElement.from(
                parent, package.findOrCreateLibraryFor(parent));
            List<Field> possibleFields = [];
            possibleFields.addAll(parentClass.allInstanceProperties);
            possibleFields.addAll(parentClass.staticProperties);
            String fieldName = accessor.name.replaceFirst('=', '');
            _overriddenElement = new ModelElement.from(accessor, library,
                enclosingCombo: possibleFields
                    .firstWhere((f) => f.element.name == fieldName));
            break;
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
  final Set<Field> _genPageProperties = new Set();

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

  final Set<Element> _allElements = new Set();

  // TODO(jcollins-g): optimize this.
  bool contains(Element element) {
    if (_allElements.isEmpty) {
      _allElements.addAll(allInstanceMethods.map((e) => e.element));
      _allElements.addAll(allInstanceProperties.map((e) => e.element));
      _allElements.addAll(allOperators.map((e) => e.element));
      _allElements.addAll(constructors.map((e) => e.element));
      _allElements.addAll(staticMethods.map((e) => e.element));
      _allElements.addAll(staticProperties.map((e) => e.element));
      _allElements.addAll(_allElements.where((e) => e is Member)
        ..map((e) => (e as Member).baseElement));
    }
    return _allElements.contains(element);
  }

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

    _constructors = _cls.constructors.where(isPublic).map((e) {
      return new ModelElement.from(e, library);
    }).toList(growable: true)
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
      if (f._setter != null) uniqueNames.add(f._setter.name);
      if (f._getter != null) uniqueNames.add(f._getter.name);
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
          isPublic(value) &&
          !value.isOperator &&
          value.enclosingElement != null) {
        if (!package.isDocumented(value.enclosingElement)) {
          Method m =
              new ModelElement.from(value, library, enclosingClass: this);
          _inheritedMethods.add(m);
          _genPageMethods.add(m);
        } else {
          _inheritedMethods
              .add(new ModelElement.from(value, library, enclosingClass: this));
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
    if (_inheritedProperties != null) return _inheritedProperties;
    Map<String, ExecutableElement> cmap =
        library.inheritanceManager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        library.inheritanceManager.getMembersInheritedFromInterfaces(element);

    _inheritedProperties = [];
    List<ExecutableElement> values = [];
    Set<String> uniqueNames = new Set();

    instanceProperties.forEach((f) {
      if (f._setter != null) uniqueNames.add(f._setter.name);
      if (f._getter != null) uniqueNames.add(f._getter.name);
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
    values
        .removeWhere((it) => instanceProperties.any((i) => it.name == i.name));

    for (var value in values) {
      if (value != null &&
          value is PropertyAccessorElement &&
          isPublic(value) &&
          value.enclosingElement != null) {
        // This seems to be here to deal with half-field inheritance, where
        // we inherit a getter but not a setter, or vice-versa.  (Or if a parent
        // class has the same trouble). In that case, just drop any duplicate
        // names we see.  This probably results in bugs.
        // TODO(jcollins-g): deal with half-inherited fields better
        var e = value.variable;

        if (instanceProperties.any((f) => f.element.name == e.name)) continue;
        if (_inheritedProperties.any((f) => f.element.name == e.name)) continue;

        if (!package.isDocumented(value.enclosingElement)) {
          Field f = new ModelElement.from(e, library, enclosingClass: this);
          _inheritedProperties.add(f);
          _genPageProperties.add(f);
        } else {
          _inheritedProperties
              .add(new ModelElement.from(e, library, enclosingClass: this));
        }
      }
    }

    _inheritedProperties.sort(byName);

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
        .where((f) => !f.isStatic)
        .toList(growable: false)
          ..sort(byName);

    _genPageProperties.addAll(_instanceFields);
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
      if (!isPrivate(type.element.element)) publicList.add(type);
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
  List<Field> get propertiesForPages =>
      _genPageProperties.toList(growable: false);

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

    _fields = _cls.fields
        .where(isPublic)
        .map((e) => new ModelElement.from(e, library))
        .toList(growable: false)
          ..sort(byName);

    return _fields;
  }

  ClassElement get _cls => (element as ClassElement);

  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _cls.methods.where(isPublic).map((e) {
      return new ModelElement.from(e, library);
    }).toList(growable: false)
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
abstract class Documentable {
  String get documentation;
  String get documentationAsHtml;
  bool get hasDocumentation;
  String get oneLineDoc;
}

class Dynamic extends ModelElement {
  Dynamic(Element element, Library library) : super(element, library);

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
    // their expected indicies. https://github.com/dart-lang/dartdoc/issues/1176
    var index = -1;

    _enumFields = _cls.fields
        .where(isPublic)
        .where((f) => f.isConst)
        .map((field) => new ModelElement.from(field, library, index: index++))
        .toList(growable: false)
          ..sort(byName);

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

  EnumField(FieldElement element, Library library) : super(element, library);

  EnumField.forConstant(this._index, FieldElement element, Library library)
      : super(element, library);

  @override
  String get constantValue {
    if (name == 'values') {
      return 'const List&lt;${_field.enclosingElement.name}&gt;';
    } else {
      return 'const ${_field.enclosingElement.name}($_index)';
    }
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

  Field(FieldElement element, Library library) : super(element, library) {
    _setModelType();
  }

  Field.inherited(FieldElement element, this._enclosingClass, Library library)
      : super(element, library) {
    _isInherited = true;
    _setModelType();
    // Can't set _isInherited to true if this is the defining element, because
    // that would mean it isn't inherited.
    assert(enclosingElement != definingEnclosingElement);
  }

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    Set<bool> assertCheck = new Set()..addAll([hasSetter, hasGetterNoSetter]);
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
  bool get hasGetter => _field.getter != null;

  @override
  bool get hasSetter => _field.setter != null;

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
    if (isInherited) all_features.add('inherited');
    return all_features;
  }

  @override
  String get _computeDocumentationComment {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _field.documentationComment;
    return docs;
  }

  FieldElement get _field => (element as FieldElement);

  String get _fileName => isConst ? '$name-constant.html' : '$name.html';

  @override
  PropertyAccessorElement get _getter => _field.getter;

  @override
  PropertyAccessorElement get _setter => _field.setter;

  void _setModelType() {
    if (hasGetter) {
      var t = _field.getter.returnType;
      _modelType = new ElementType(
          t,
          new ModelElement.from(
              t.element, _findOrCreateEnclosingLibraryFor(t.element)));
    }
  }
}

/// Mixin for top-level variables and fields (aka properties)
abstract class GetterSetterCombo implements ModelElement {
  Accessor get getter {
    return _getter == null
        ? null
        : new ModelElement.from(_getter, library, enclosingCombo: this);
  }

  String get getterSetterDocumentationComment {
    var buffer = new StringBuffer();

    if (hasGetter && !_getter.isSynthetic) {
      String docs = stripComments(_getter.documentationComment);
      if (docs != null) buffer.write(docs);
    }

    if (hasSetter && !_setter.isSynthetic) {
      String docs = stripComments(_setter.documentationComment);
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

  bool get hasExplicitGetter => hasGetter && !_getter.isSynthetic;

  bool get hasExplicitSetter => hasSetter && !_setter.isSynthetic;
  bool get hasImplicitSetter => hasSetter && _setter.isSynthetic;

  bool get hasGetter;

  bool get hasNoGetterSetter => !hasExplicitGetter && !hasExplicitSetter;

  bool get hasSetter;

  bool get hasGetterNoSetter => (hasGetter && !hasSetter);

  String get arrow {
    // →
    if (readOnly) return r'&#8594;';
    // ←
    if (writeOnly) return r'&#8592;';
    // ↔
    if (readWrite) return r'&#8596;';
    // A GetterSetterCombo should always be one of readOnly, writeOnly,
    // or readWrite.
    assert(false);
    return null;
  }

  bool get readOnly => hasGetter && !hasSetter;
  bool get readWrite => hasGetter && hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;

  Accessor get setter {
    return _setter == null
        ? null
        : new ModelElement.from(_setter, library, enclosingCombo: this);
  }

  PropertyAccessorElement get _getter;

  // TODO: now that we have explicit getter and setters, we probably
  // want a cleaner way to do this. Only the one-liner is using this
  // now. The detail pages should be using getter and setter directly.
  PropertyAccessorElement get _setter;
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

  List<Class> get allClasses => _allClasses;

  List<Class> get classes {
    return _allClasses
        .where((c) => !c.isErrorOrException)
        .toList(growable: false);
  }

  List<TopLevelVariable> get constants {
    return _getVariables().where((v) => v.isConst).toList(growable: false)
      ..sort(byName);
  }

  String get dirName => name.replaceAll(':', '-');

  /// Libraries are not enclosed by anything.
  ModelElement get enclosingElement => null;

  List<Class> get enums {
    if (_enums != null) return _enums;

    List<ClassElement> enumClasses = [];
    enumClasses.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is ClassElement && element.isEnum));
    _enums = enumClasses
        .where(isPublic)
        .map((e) => new ModelElement.from(e, this))
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

    _functions = elements.where(isPublic).map((e) {
      return new ModelElement.from(e, this);
    }).toList(growable: false)
      ..sort(byName);

    return _functions;
  }

  bool get hasClasses => classes.isNotEmpty;

  bool get hasConstants => _getVariables().any((v) => v.isConst);

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

  /// All variables ("properties") except constants.
  List<TopLevelVariable> get properties {
    return _getVariables().where((v) => !v.isConst).toList(growable: false)
      ..sort(byName);
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
    elements..removeWhere(isPrivate);
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
        .where(isPublic)
        .map((e) => new ModelElement.from(e, this))
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
      if (element is PropertyAccessorElement) elements.add(element.variable);
    });
    _variables = elements
        .where(isPublic)
        .map((e) => new ModelElement.from(e, this))
        .toList(growable: false)
          ..sort(byName);

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

  Iterable<ModelElement> get allModelElements sync* {
    for (Set<ModelElement> modelElements in modelElementsMap.values) {
      for (ModelElement modelElement in modelElements) {
        yield modelElement;
      }
    }
  }

  List<ModelElement> _allCanonicalModelElements;
  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
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
      if (t.getMethod(element.name) != null) {
        return new ModelElement.from(t.getMethod(element.name), library);
      }
    }
    return null;
  }

  String get typeName => 'method';

  MethodElement get _method => (element as MethodElement);
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
abstract class ModelElement
    implements Comparable, Nameable, Documentable, Locatable {
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

  /// Do not construct any ModelElements unless they are from this constructor.
  /// TODO(jcollins-g): enforce this.
  /// Specify enclosingClass only if this is to be an inherited object.
  /// Specify index only if this is to be an EnumField.forConstant.
  /// Specify enclosingCombo (a GetterSetterCombo) only if this is to be an
  /// Accessor.
  /// TODO(jcollins-g): this way of using the optional parameter is messy,
  /// clean that up.
  factory ModelElement.from(Element e, Library library,
      {Class enclosingClass, int index, ModelElement enclosingCombo}) {
    // We don't need index in this key because it isn't a disambiguator.
    // It isn't a disambiguator because EnumFields are not inherited, ever.
    // TODO(jcollins-g): cleanup class hierarchy so that EnumFields aren't
    // Inheritable, somehow?
    if (e is Member) e = (e as Member).baseElement;
    Tuple4<Element, Library, Class, ModelElement> key =
        new Tuple4(e, library, enclosingClass, enclosingCombo);
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
            newModelElement = new EnumField.forConstant(index, e, library);
          } else {
            if (e.enclosingElement.isEnum) {
              newModelElement = new EnumField(e, library);
            } else {
              newModelElement = new Field(e, library);
            }
          }
        } else {
          newModelElement = new Field.inherited(e, enclosingClass, library);
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
        newModelElement = new TopLevelVariable(e, library);
      }
      if (e is PropertyAccessorElement) {
        newModelElement = new Accessor(e, library, enclosingCombo);
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
    if (newModelElement is Accessor) {
      assert(newModelElement.enclosingCombo == enclosingCombo);
    } else {
      assert(enclosingCombo == null);
    }

    return newModelElement;
  }

  Set<Library> get exportedInLibraries {
    return library.package.libraryElementReexportedBy[this.element.library];
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
    } else if (element.computeNode() is! FormalParameter) {
      // TODO(jcollins-g): This is special cased to suppress annotations for
      //                   parameters in constructor documentation.  Do we
      //                   want to do this?
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

  /// Returns the docs, stripped of their leading comments syntax.
  ///
  /// This getter will walk up the inheritance hierarchy
  /// to find docs, if the current class doesn't have docs
  /// for this element.
  @override
  String get documentation {
    if (_rawDocs != null) return _rawDocs;

    _rawDocs = _computeDocumentationComment;

    if (_rawDocs == null && canOverride()) {
      var overrideElement = overriddenElement;
      if (overrideElement != null) {
        _rawDocs = overrideElement.documentation ?? '';
        return _rawDocs;
      }
    }

    _rawDocs = stripComments(_rawDocs) ?? '';
    _rawDocs = _injectExamples(_rawDocs);
    _rawDocs = _stripMacroTemplatesAndAddToIndex(_rawDocs);
    _rawDocs = _injectMacros(_rawDocs);
    return _rawDocs;
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
          // If path inspection or other disambiguation heuristics are needed,
          // they should go here.
          if (candidateLibraries.length > 1) {
            warn(PackageWarning.ambiguousReexport,
                "${candidateLibraries.map((l) => l.name)}");
          }
          if (candidateLibraries.isNotEmpty)
            _canonicalLibrary = candidateLibraries.first;
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
    // TODO(jcollins-g): we should always be able to get line numbers.  Why can't we, sometimes?
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
  String get oneLineDoc => _documentation.asOneLiner;

  ModelElement get overriddenElement => null;

  ModelElement _overriddenDocumentedElement;
  bool _overriddenDocumentedElementIsSet = false;
  // TODO(jcollins-g): This method prefers canonical elements, but it isn't
  // guaranteed and is probably the source of bugs or confusing warnings.
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

  void warn(PackageWarning kind, [String message]) {
    if (kind == PackageWarning.unresolvedDocReference &&
        overriddenElement != null) {
      // The documentation we're using for this element came from somewhere else.
      // Attach the warning to that element to deduplicate.
      overriddenElement.warn(kind, message);
    } else {
      library.package.warn(this, kind, message);
    }
  }

  String get _computeDocumentationComment => element.documentationComment;

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
          buf.write('<span class="type-annotation">$typeName</span> ');
        }
        if (showNames) {
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

    if (isPrivate(element)) {
      return HTML_ESCAPE.convert(name);
    }

    if (href == null) {
      warn(PackageWarning.noCanonicalFound);
      return HTML_ESCAPE.convert(name);
    }

    var classContent = isDeprecated ? 'class="deprecated" ' : '';
    return '<a ${classContent}href="${href}">$name</a>';
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
  noCanonicalFound,
  noLibraryLevelDocs,
  categoryOrderGivesMissingPackageName,
  unresolvedDocReference,
  brokenLink,
  orphanedFile,
  unknownFile,
  typeAsHtml,
}

/// Provides description text and command line flags for warnings.
/// TODO(jcollins-g): Actually use this for command line flags.
Map<PackageWarning, List<String>> packageWarningText = {
  PackageWarning.ambiguousDocReference: [
    "ambiguous-doc-reference",
    "A comment reference could refer to two or more different objects"
  ],
  PackageWarning.ambiguousReexport: [
    "ambiguous-reexport",
    "A symbol is exported from private to public in more than one place and dartdoc is forced to guess which one is canonical"
  ],
  PackageWarning.noCanonicalFound: [
    "no-canonical-found",
    "A symbol is is part of the public interface for this package, but no library documented with this package documents it so dartdoc can not link to it"
  ],
  PackageWarning.noLibraryLevelDocs: [
    "no-library-level-docs",
    "There are no library level docs for this library"
  ],
  PackageWarning.categoryOrderGivesMissingPackageName: [
    "category-order-gives-missing-package-name",
    "The category-order flag on the command line was given the name of a nonexistent package"
  ],
  PackageWarning.unresolvedDocReference: [
    "unresolved-doc-reference",
    "A comment reference could not be found in parameters, enclosing class, enclosing library, or at the top level of any documented library with the package"
  ],
  PackageWarning.brokenLink: [
    "brokenLink",
    "Dartdoc generated a link to a non-existent file"
  ],
  PackageWarning.orphanedFile: [
    "orphanedFile",
    "Dartdoc generated files that are unreachable from the index"
  ],
  PackageWarning.unknownFile: [
    "unknownFile",
    "A leftover file exists in the tree that dartdoc did not write in this pass"
  ],
  PackageWarning.typeAsHtml: [
    "typeAsHtml",
    "Use of <> in a comment for type parameters is being treated as HTML by markdown"
  ],
};

// Something that can be located for warning purposes.
abstract class Locatable {
  String get fullyQualifiedName;
  String get href;
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

  PackageWarningCounter(this.options);

  /// Actually write out the warning.  Assumes it is already counted with add.
  void _writeWarning(PackageWarning kind, String fullMessage) {
    if (options.ignoreWarnings.contains(kind)) return;
    String toWrite;
    if (!options.asErrors.contains(kind)) {
      if (options.asWarnings.contains(kind))
        toWrite = "warning: ${fullMessage}";
    } else {
      if (options.asErrors.contains(kind)) toWrite = "error: ${fullMessage}";
    }
    if (toWrite != null) stderr.write("\n ${toWrite}");
  }

  /// Returns true if we've already warned for this.
  bool hasWarning(Element element, PackageWarning kind, String message) {
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    if (_countedWarnings.containsKey(element)) {
      return _countedWarnings[element].contains(warningData);
    }
    return false;
  }

  /// Adds the warning to the counter, and writes out the fullMessage string
  /// if configured to do so.
  void addWarning(Element element, PackageWarning kind, String message,
      String fullMessage) {
    assert(!hasWarning(element, kind, message));
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    _warningCounts.putIfAbsent(kind, () => 0);
    _warningCounts[kind] += 1;
    _countedWarnings.putIfAbsent(element, () => new Set());
    _countedWarnings[element].add(warningData);
    _writeWarning(kind, fullMessage);
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

class Package implements Nameable, Documentable, Locatable {
  // Library objects serving as entry points for documentation.
  final List<Library> _libraries = [];
  // All library objects related to this package; a superset of _libraries.
  final Map<LibraryElement, Library> _allLibraries = new Map();

  // Objects to keep track of warnings.
  final PackageWarningOptions _packageWarningOptions;
  PackageWarningCounter _packageWarningCounter;
  // All ModelElements constructed for this package; a superset of allModelElements.
  final Map<Tuple4<Element, Library, Class, ModelElement>, ModelElement>
      _allConstructedModelElements = new Map();

  // Anything that might be inheritable, place here for later lookup.
  final Map<Tuple2<Element, Library>, Set<ModelElement>>
      _allInheritableElements = new Map();

  /// Map of Class.href to a list of classes implementing that class
  final Map<String, List<Class>> _implementors = new Map();

  final PackageMeta packageMeta;

  final Map<Element, Library> _elementToLibrary = {};
  String _docsAsHtml;
  final Map<String, String> _macros = {};
  bool allLibrariesAdded = false;

  Package(Iterable<LibraryElement> libraryElements, this.packageMeta,
      this._packageWarningOptions) {
    assert(_allConstructedModelElements.isEmpty);
    assert(_allLibraries.isEmpty);
    _packageWarningCounter = new PackageWarningCounter(_packageWarningOptions);
    libraryElements.forEach((element) {
      // add only if the element should be included in the public api
      if (isPublic(element)) {
        var lib = new Library._(element, this);
        _libraries.add(lib);
        _allLibraries[element] = lib;
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

  @override
  Tuple2<int, int> get lineAndColumn => null;

  @override
  String get fullyQualifiedName => name;

  @override
  bool get isCanonical => true;

  PackageWarningCounter get packageWarningCounter => _packageWarningCounter;

  void warn(Locatable modelElement, PackageWarning kind, [String message]) {
    if (modelElement != null) {
      // This sort of warning is only applicable to top level elements.
      if (kind == PackageWarning.ambiguousReexport) {
        Element topLevelElement = modelElement.element;
        while (topLevelElement.enclosingElement is! CompilationUnitElement) {
          topLevelElement = topLevelElement.enclosingElement;
        }
        modelElement = new ModelElement.from(
            topLevelElement, findOrCreateLibraryFor(topLevelElement));
      }
      if (modelElement is Accessor) {
        // This might be part of a Field, if so, assign this warning to the field
        // rather than the Accessor.
        if ((modelElement as Accessor).enclosingCombo != null)
          modelElement = (modelElement as Accessor).enclosingCombo;
      }
    } else {
      // If we don't have an element, we need a message to disambiguate.
      assert(message != null);
    }
    if (_packageWarningCounter.hasWarning(
        modelElement?.element, kind, message)) {
      return;
    }
    // Elements that are part of the Dart SDK can have colons in their FQNs.
    // This confuses IntelliJ and makes it so it can't link to the location
    // of the error in the console window, so separate out the library from
    // the path.
    // TODO(jcollins-g): What about messages that may include colons?  Substituting
    //                   them out doesn't work as well there since it might confuse
    //                   the user, yet we still want IntelliJ to link properly.
    String nameSplitFromColonPieces;
    if (modelElement != null) {
      nameSplitFromColonPieces =
          modelElement.fullyQualifiedName.replaceFirst(':', '-');
    }
    String warningMessage;
    switch (kind) {
      case PackageWarning.noCanonicalFound:
        // Fix these warnings by adding libraries with --include, or by using
        // --auto-include-dependencies.
        // TODO(jcollins-g): add a dartdoc flag to enable external website linking for non-canonical elements, using .packages for versioning
        // TODO(jcollins-g): support documenting multiple packages at once and linking between them
        warningMessage =
            "no canonical library found for ${nameSplitFromColonPieces}, not linking";
        break;
      case PackageWarning.ambiguousReexport:
        // Fix these warnings by adding the original library exporting the
        // symbol with --include, or by using --auto-include-dependencies.
        // TODO(jcollins-g): add a dartdoc flag to force a particular resolution order for (or drop) ambiguous reexports
        warningMessage =
            "ambiguous reexport of ${nameSplitFromColonPieces}, canonicalization candidates: ${message}";
        break;
      case PackageWarning.noLibraryLevelDocs:
        warningMessage =
            "${modelElement.fullyQualifiedName} has no library level documentation comments";
        break;
      case PackageWarning.ambiguousDocReference:
        warningMessage =
            "ambiguous doc reference in ${nameSplitFromColonPieces}: ${message}";
        break;
      case PackageWarning.categoryOrderGivesMissingPackageName:
        warningMessage =
            "--category-order gives invalid package name: '${message}'";
        break;
      case PackageWarning.unresolvedDocReference:
        warningMessage =
            "unresolved doc reference [${message}], from ${nameSplitFromColonPieces}";
        break;
      case PackageWarning.brokenLink:
        warningMessage =
            'dartdoc generated a broken link to: ${message}, from ${nameSplitFromColonPieces == null ? "<unknown>" : nameSplitFromColonPieces}';
        break;
      case PackageWarning.orphanedFile:
        warningMessage =
            'dartdoc generated a file orphan: ${message}, from ${nameSplitFromColonPieces == null ? "<unknown>" : nameSplitFromColonPieces}';
        break;
      case PackageWarning.unknownFile:
        warningMessage =
            'dartdoc detected an unknown file in the doc tree:  ${message}';
        break;
      case PackageWarning.typeAsHtml:
        // The message for this warning can contain many punctuation and other symbols,
        // so bracket with a triple quote for defense.
        warningMessage = 'generic type handled as HTML: """${message}"""';
        break;
    }
    String fullMessage =
        "${warningMessage} ${modelElement != null ? modelElement.elementLocation : ''}";
    packageWarningCounter.addWarning(
        modelElement?.element, kind, message, fullMessage);
  }

  static Package _withAutoIncludedDependencies(
      Set<LibraryElement> libraryElements,
      PackageMeta packageMeta,
      PackageWarningOptions options) {
    var startLength = libraryElements.length;
    Package package = new Package(libraryElements, packageMeta, options);

    // TODO(jcollins-g): this is inefficient; keep track of modelElements better
    package.allModelElements.forEach((modelElement) {
      modelElement.usedElements.forEach((used) {
        if (used != null && used.modelType != null) {
          final ModelElement modelTypeElement = used.modelType.element;
          final library = package.findLibraryFor(modelTypeElement.element);
          if (library == null &&
              modelTypeElement.library != null &&
              !isPrivate(modelTypeElement.library.element) &&
              modelTypeElement.library.canonicalLibrary == null &&
              !libraryElements.contains(modelTypeElement.library.element)) {
            libraryElements.add(modelTypeElement.library.element);
          }
        }
      });
    });

    if (libraryElements.length > startLength)
      return _withAutoIncludedDependencies(
          libraryElements, packageMeta, options);
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
        warn(null, PackageWarning.categoryOrderGivesMissingPackageName,
            "${categoryName}, categories: ${result.keys.join(',')}");
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
      if (modelElement.href == null) continue;
      hrefMap.putIfAbsent(modelElement.href, () => new Set());
      hrefMap[modelElement.href].add(modelElement);
    }
    return hrefMap;
  }

  @override
  String get documentationAsHtml {
    if (_docsAsHtml != null) return _docsAsHtml;

    _docsAsHtml = new Documentation(documentation).asHtml;

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

  @override
  String get name => packageMeta.name;

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

  bool isDocumented(Element element) {
    // If this isn't a private element and we have a canonical Library for it,
    // this element will be documented.
    if (isPrivate(element)) return false;
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

  /// Tries to find a canonical ModelElement for this element.  If we know
  /// this element is related to a particular class, pass preferredClass to
  /// disambiguate.
  ModelElement findCanonicalModelElementFor(Element e, {Class preferredClass}) {
    assert(allLibrariesAdded);
    Library lib = findCanonicalLibraryFor(e);
    ModelElement modelElement;
    // TODO(jcollins-g): The data structures should be changed to eliminate guesswork
    // with member elements.
    if (e is ClassMemberElement || e is PropertyAccessorElement) {
      // Prefer Fields over Accessors.
      if (e is PropertyAccessorElement)
        e = (e as PropertyAccessorElement).variable;
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
      if (lib != null) modelElement = new ModelElement.from(e, lib);
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
    if (_allLibraries.containsKey(e.library)) {
      return _allLibraries[e.library];
    }
    // can be null if e is for dynamic
    if (e.library == null) {
      return null;
    }
    Library foundLibrary = findLibraryFor(e);

    if (foundLibrary == null) {
      foundLibrary = new Library._(e.library, this);
      _allLibraries[e.library] = foundLibrary;
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
  TopLevelVariable(TopLevelVariableElement element, Library library)
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
  }

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
    Set<bool> assertCheck = new Set()..addAll([hasSetter, hasGetterNoSetter]);
    assert(assertCheck.containsAll([true, false]));
    return super.documentation;
  }

  @override
  ModelElement get enclosingElement => library;

  @override
  bool get hasGetter => _variable.getter != null;

  @override
  bool get hasSetter => _variable.setter != null;

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
  String get _computeDocumentationComment {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _variable.documentationComment;
    return docs;
  }

  String get _fileName => isConst ? '$name-constant.html' : '$name.html';

  @override
  PropertyAccessorElement get _getter => _variable.getter;

  @override
  PropertyAccessorElement get _setter => _variable.setter;

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
