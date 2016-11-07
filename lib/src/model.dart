// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart'
    show AnnotatedNode, Annotation, Declaration;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/resolver.dart'
    show Namespace, NamespaceBuilder, InheritanceManager;
import 'package:analyzer/src/generated/utilities_dart.dart' show ParameterKind;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/core.dart' show hash3;

import 'config.dart';
import 'element_type.dart';
import 'line_number_cache.dart';
import 'markdown_processor.dart' show Documentation;
import 'model_utils.dart';
import 'package_meta.dart' show PackageMeta, FileContents;
import 'utils.dart';

Map<String, Map<String, List<Map<String, dynamic>>>> __crossdartJson;

final Map<Class, List<Class>> _implementors = new Map();

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

void _addToImplementors(Class c) {
  _implementors.putIfAbsent(c, () => []);

  void _checkAndAddClass(Class key, Class implClass) {
    _implementors.putIfAbsent(key, () => []);
    List list = _implementors[key];

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

/// Getters and setters.
class Accessor extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  Accessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  @override
  ModelElement get enclosingElement {
    if (_accessor.enclosingElement is CompilationUnitElement) {
      return package
          ._getLibraryFor(_accessor.enclosingElement.enclosingElement);
    }

    return new ModelElement.from(_accessor.enclosingElement, library);
  }

  @override
  String get href =>
      '${library.dirName}/${_accessor.enclosingElement.name}/${name}.html';

  bool get isGetter => _accessor.isGetter;

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
  final List<Operator> _genPageOperators = <Operator>[];
  List<Method> _inheritedMethods;
  List<Method> _staticMethods;
  List<Method> _instanceMethods;
  List<Method> _allInstanceMethods;
  final List<Method> _genPageMethods = <Method>[];
  List<Field> _fields;
  List<Field> _staticFields;
  List<Field> _constants;
  List<Field> _instanceFields;
  List<Field> _inheritedProperties;
  List<Field> _allInstanceProperties;
  final List<Field> _genPageProperties = <Field>[];

  Class(ClassElement element, Library library) : super(element, library) {
    Package p = library.package;
    _modelType = new ElementType(_cls.type, this);

    _mixins = _cls.mixins
        .map((f) {
          Library lib = new Library(f.element.library, p);
          ElementType t =
              new ElementType(f, new ModelElement.from(f.element, lib));
          bool exclude = t.element.element.isPrivate;
          if (exclude) {
            return null;
          } else {
            return t;
          }
        })
        .where((mixin) => mixin != null)
        .toList(growable: false);

    if (_cls.supertype != null && _cls.supertype.element.supertype != null) {
      Library lib = package._getLibraryFor(_cls.supertype.element);

      _supertype = new ElementType(
          _cls.supertype, new ModelElement.from(_cls.supertype.element, lib));

      /* Private Superclasses should not be shown. */
      var exclude = _supertype.element.element.isPrivate;

      /* Hide dart2js related stuff */
      exclude = exclude ||
          (lib.name.startsWith("dart:") &&
              _supertype.name == "NativeFieldWrapperClass2");

      if (exclude) {
        _supertype = null;
      }
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
      ..addAll(instanceMethods)
      ..addAll(inheritedMethods)
      ..sort(byName);
    return _allInstanceMethods;
  }

  bool get allInstanceMethodsInherited =>
      instanceMethods.every((f) => f.isInherited);

  List<Field> get allInstanceProperties {
    if (_allInstanceProperties != null) return _allInstanceProperties;

    // TODO best way to make this a fixed length list?
    _allInstanceProperties = []
      ..addAll(instanceProperties)
      ..addAll(inheritedProperties)
      ..sort(byName);

    return _allInstanceProperties;
  }

  bool get allInstancePropertiesInherited =>
      instanceProperties.every((f) => f.isInherited);

  List<Operator> get allOperators {
    if (_allOperators != null) return _allOperators;
    _allOperators = []
      ..addAll(operators)
      ..addAll(inheritedOperators)
      ..sort(byName);
    return _allOperators;
  }

  bool get allOperatorsInherited => operators.every((f) => f.isInherited);

  List<Field> get constants {
    if (_constants != null) return _constants;
    _constants = _allFields.where((f) => f.isConst).toList(growable: false)
      ..sort(byName);

    return _constants;
  }

  List<Constructor> get constructors {
    if (_constructors != null) return _constructors;

    _constructors = _cls.constructors.where(isPublic).map((e) {
      return new Constructor(e, library);
    }).toList(growable: true)..sort(byName);

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

  @override
  int get hashCode => hash3(
      name.hashCode, library.name.hashCode, library.package.name.hashCode);

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

  bool get hasSupertype => supertype != null;

  @override
  String get href => '${library.dirName}/$fileName';

  /// Returns all the implementors of the class specified.
  List<Class> get implementors =>
      _implementors[this] != null ? _implementors[this] : [];

  List<Method> get inheritedMethods {
    if (_inheritedMethods != null) return _inheritedMethods;

    InheritanceManager manager = new InheritanceManager(element.library);
    Map<String, ExecutableElement> cmap =
        manager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        manager.getMembersInheritedFromInterfaces(element);

    // remove methods that exist on this class
    _methods.forEach((method) {
      cmap.remove(method.name);
      imap.remove(method.name);
    });

    _inheritedMethods = [];
    List<ExecutableElement> vs = [];
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
      vs.add(cmap[key]);
    }

    for (String key in imap.keys) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(key)) continue;

      uniqueNames.add(key);
      vs.add(imap[key]);
    }

    for (ExecutableElement value in vs) {
      if (value != null &&
          value is MethodElement &&
          isPublic(value) &&
          !value.isOperator &&
          value.enclosingElement != null) {
        if (!package.isDocumented(value.enclosingElement)) {
          Method m = new Method.inherited(value, this, library);
          _inheritedMethods.add(m);
          _genPageMethods.add(m);
        } else {
          Library lib = package._getLibraryFor(value.enclosingElement);
          _inheritedMethods.add(new Method.inherited(
              value, new Class(value.enclosingElement, lib), lib));
        }
      }
    }

    _inheritedMethods.sort(byName);

    return _inheritedMethods;
  }

  List<Operator> get inheritedOperators {
    if (_inheritedOperators != null) return _inheritedOperators;
    InheritanceManager manager = new InheritanceManager(element.library);
    Map<String, ExecutableElement> cmap =
        manager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        manager.getMembersInheritedFromInterfaces(element);
    operators.forEach((operator) {
      cmap.remove(operator.element.name);
      imap.remove(operator.element.name);
    });
    _inheritedOperators = [];
    Map<String, ExecutableElement> vs = {};

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
        vs.putIfAbsent(value.name, () => value);
      }
    }

    for (String key in cmap.keys) {
      ExecutableElement value = cmap[key];
      if (_isInheritedOperator(value)) {
        vs.putIfAbsent(value.name, () => value);
      }
    }

    for (ExecutableElement value in vs.values) {
      if (!package.isDocumented(value.enclosingElement)) {
        Operator o = new Operator.inherited(value, this, library);
        _inheritedOperators.add(o);
        _genPageOperators.add(o);
      } else {
        Library lib = package._getLibraryFor(value.enclosingElement);
        _inheritedOperators.add(new Operator.inherited(
            value, new Class(value.enclosingElement, lib), lib));
      }
    }

    _inheritedOperators.sort(byName);

    return _inheritedOperators;
  }

  List<Field> get inheritedProperties {
    if (_inheritedProperties != null) return _inheritedProperties;

    InheritanceManager manager = new InheritanceManager(element.library);
    Map<String, ExecutableElement> cmap =
        manager.getMembersInheritedFromClasses(element);
    Map<String, ExecutableElement> imap =
        manager.getMembersInheritedFromInterfaces(element);

    _inheritedProperties = [];
    List<ExecutableElement> vs = [];
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
      vs.add(cmap[key]);
    }

    for (String key in imap.keys) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(key)) continue;

      uniqueNames.add(key);
      vs.add(imap[key]);
    }

    vs.removeWhere((it) => instanceProperties.any((i) => it.name == i.name));

    for (var value in vs) {
      if (value != null &&
          value is PropertyAccessorElement &&
          isPublic(value) &&
          value.enclosingElement != null) {
        // TODO: why is this here?
        var e = value.variable;
        if (_inheritedProperties.any((f) => f.element == e)) {
          continue;
        }
        if (!package.isDocumented(value.enclosingElement)) {
          Field f = new Field.inherited(e, this, library);
          _inheritedProperties.add(f);
          _genPageProperties.add(f);
        } else {
          Library lib = package._getLibraryFor(e.enclosingElement);
          _inheritedProperties.add(
              new Field.inherited(e, new Class(e.enclosingElement, lib), lib));
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
        .toList(growable: false)..sort(byName);

    _genPageMethods.addAll(_instanceMethods);
    return _instanceMethods;
  }

  List<Field> get instanceProperties {
    if (_instanceFields != null) return _instanceFields;
    _instanceFields = _allFields
        .where((f) => !f.isStatic)
        .toList(growable: false)..sort(byName);

    _genPageProperties.addAll(_instanceFields);
    return _instanceFields;
  }

  List<ElementType> get interfaces => _interfaces;

  bool get isAbstract => _cls.isAbstract;

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

  List<Method> get methodsForPages => _genPageMethods;

  // TODO: make this method smarter about hierarchies and overrides. Right
  // now, we're creating a flat list. We're not paying attention to where
  // these methods are actually coming from. This might turn out to be a
  // problem if we want to show that info later.
  List<ElementType> get mixins => _mixins;

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

  List<Operator> get operatorsForPages => _genPageOperators;

  // TODO: make this method smarter about hierarchies and overrides. Right
  // now, we're creating a flat list. We're not paying attention to where
  // these methods are actually coming from. This might turn out to be a
  // problem if we want to show that info later.
  List<Field> get propertiesForPages => _genPageProperties;

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
        .toList(growable: false)..sort(byName);

    return _staticFields;
  }

  List<ElementType> get superChain {
    List<ElementType> typeChain = [];
    var parent = _supertype;
    while (parent != null) {
      typeChain.add(parent);
      parent = (parent.element as Class)._supertype;
    }
    return typeChain;
  }

  List<ElementType> get superChainReversed => superChain.reversed.toList();

  ElementType get supertype => _supertype;

  List<Field> get _allFields {
    if (_fields != null) return _fields;

    _fields = _cls.fields
        .where(isPublic)
        .map((e) => new Field(e, library))
        .toList(growable: false)..sort(byName);

    return _fields;
  }

  ClassElement get _cls => (element as ClassElement);

  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _cls.methods.where(isPublic).map((e) {
      if (!e.isOperator) {
        return new Method(e, library);
      } else {
        return new Operator(e, library);
      }
    }).toList(growable: false)..sort(byName);

    return _allMethods;
  }

  // a stronger hash?
  List<TypeParameter> get _typeParameters => _cls.typeParameters.map((f) {
        var lib = new Library(f.enclosingElement.library, package);
        return new TypeParameter(f, lib);
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
  String get href =>
      '${library.dirName}/${_constructor.enclosingElement.name}/$name.html';

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
        .map((field) => new EnumField.forConstant(index++, field, library))
        .toList(growable: false)..sort(byName);

    return _enumFields;
  }

  @override
  List<EnumField> get instanceProperties {
    return super
        .instanceProperties
        .map((Field p) => new EnumField(p.element, p.library))
        .toList(growable: false);
  }

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
    } else {
      return super.documentation;
    }
  }

  @override
  String get href =>
      '${library.dirName}/${(enclosingElement as Class).fileName}';

  @override
  String get linkedName => name;

  @override
  String get oneLineDoc => documentationAsHtml;
}

class Field extends ModelElement
    with GetterSetterCombo
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
    if (enclosingElement is Class) {
      return '${library.dirName}/${enclosingElement.name}/$_fileName';
    } else if (enclosingElement is Library) {
      return '${library.dirName}/$_fileName';
    } else {
      throw new StateError(
          '$name is not in a class or library, instead it is a ${enclosingElement.element}');
    }
  }

  @override
  bool get isConst => _field.isConst;

  @override
  bool get isFinal => _field.isFinal;

  bool get isInherited => _isInherited;

  @override
  String get kind => 'property';

  String get linkedReturnType => modelType.linkedName;

  bool get readOnly => hasGetter && !hasSetter;
  bool get readWrite => hasGetter && hasSetter;

  String get typeName => "property";

  bool get writeOnly => hasSetter && !hasGetter;

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
          t, new ModelElement.from(t.element, _findLibraryFor(t.element)));
    } else {
      var s = _field.setter.parameters.first.type;
      _modelType = new ElementType(
          s, new ModelElement.from(s.element, _findLibraryFor(s.element)));
    }
  }
}

/// Mixin for top-level variables and fields (aka properties)
abstract class GetterSetterCombo {
  Accessor get getter {
    return _getter == null ? null : new ModelElement.from(_getter, library);
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

  bool get hasExplicitGetter => hasGetter && !_getter.isSynthetic;

  bool get hasExplicitSetter => hasSetter && !_setter.isSynthetic;
  bool get hasGetter;

  bool get hasNoGetterSetter => !hasExplicitGetter && !hasExplicitSetter;

  bool get hasSetter;

  Library get library;

  Accessor get setter {
    return _setter == null ? null : new ModelElement.from(_setter, library);
  }

  PropertyAccessorElement get _getter;

  // TODO: now that we have explicit getter and setters, we probably
  // want a cleaner way to do this. Only the one-liner is using this
  // now. The detail pages should be using getter and setter directly.
  PropertyAccessorElement get _setter;
}

class Library extends ModelElement {
  static final Map<String, Library> _libraryMap = <String, Library>{};

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
    String key = element == null ? 'null' : element.name;

    if (key.isEmpty) {
      String name = element.definingCompilationUnit.name;
      key = name.substring(0, name.length - '.dart'.length);
    }

    if (_libraryMap.containsKey(key)) {
      return _libraryMap[key];
    }
    Library library = new Library._(element, package);
    _libraryMap[key] = library;

    return library;
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
        .map((e) => new Enum(e, this))
        .toList(growable: false)..sort(byName);

    return _enums;
  }

  List<Class> get exceptions {
    return _allClasses
        .where((c) => c.isErrorOrException)
        .toList(growable: false)..sort(byName);
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
      return new ModelFunction(e, this);
    }).toList(growable: false)..sort(byName);

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
  String get href => '$dirName/$fileName';

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
        .map((e) => new Typedef(e, this))
        .toList(growable: false)..sort(byName);

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
        .map((e) => new Class(e, this))
        .toList(growable: false)..sort(byName);

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
        .map((e) => new TopLevelVariable(e, this))
        .toList(growable: false)..sort(byName);

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
}

class Method extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  bool _isInherited = false;
  Class _enclosingClass;

  Method(MethodElement element, Library library) : super(element, library) {
    _modelType = new ElementType(_method.type, this);
  }

  Method.inherited(MethodElement element, this._enclosingClass, Library library)
      : super(element, library) {
    _modelType = new ElementType(_method.type, this);
    _isInherited = true;
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
  String get href => '${library.dirName}/${enclosingElement.name}/${fileName}';

  bool get isInherited => _isInherited;

  bool get isOperator => false;

  @override
  bool get isStatic => _method.isStatic;

  @override
  String get kind => 'method';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  @override
  Method get overriddenElement {
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in getAllSupertypes(parent)) {
      if (t.getMethod(element.name) != null) {
        return new Method(t.getMethod(element.name), library);
      }
    }
    return null;
  }

  String get typeName => 'method';

  MethodElement get _method => (element as MethodElement);
}

abstract class ModelElement implements Comparable, Nameable, Documentable {
  final Element _element;
  final Library _library;

  ElementType _modelType;
  String _rawDocs;
  Documentation __documentation;
  List<Parameter> _parameters;
  String _linkedName;

  String _fullyQualifiedName;

  // WARNING: putting anything into the body of this seems
  // to lead to stack overflows. Need to make a registry of ModelElements
  // somehow.
  ModelElement(this._element, this._library);

  factory ModelElement.from(Element e, Library library) {
    if (e.kind == ElementKind.DYNAMIC) {
      return new Dynamic(e, library);
    }
    // Also handles enums
    if (e is ClassElement) {
      return new Class(e, library);
    }
    if (e is FunctionElement) {
      return new ModelFunction(e, library);
    }
    if (e is FunctionTypeAliasElement) {
      return new Typedef(e, library);
    }
    if (e is FieldElement) {
      return new Field(e, library);
    }
    if (e is ConstructorElement) {
      return new Constructor(e, library);
    }
    if (e is MethodElement && e.isOperator) {
      return new Operator(e, library);
    }
    if (e is MethodElement && !e.isOperator) {
      return new Method(e, library);
    }
    if (e is TopLevelVariableElement) {
      return new TopLevelVariable(e, library);
    }
    if (e is PropertyAccessorElement) {
      return new Accessor(e, library);
    }
    if (e is TypeParameterElement) {
      return new TypeParameter(e, library);
    }
    if (e is ParameterElement) {
      return new Parameter(e, library);
    }
    throw "Unknown type ${e.runtimeType}";
  }

  List<String> get annotations {
    // Check https://code.google.com/p/dart/issues/detail?id=23181
    // If that is fixed, this code might get a lot easier
    var computedNode = element.computeNode();
    var ret = <String>[];
    if (computedNode != null && computedNode is AnnotatedNode) {
      ret = computedNode.metadata.map((Annotation a) {
        var annotationString = a.toSource().substring(1); // remove the @
        var e = a.element;
        if (e != null && (e is ConstructorElement)) {
          var me = new ModelElement.from(
              e.enclosingElement, package._getLibraryFor(e.enclosingElement));
          if (me.href != null) {
            return annotationString.replaceAll(me.name, me.linkedName);
          }
        }
        return annotationString;
      }).toList(growable: false);
    }
    if (ret.isEmpty || computedNode is! AnnotatedNode) {
      ret = element.metadata.map((ElementAnnotation a) {
        // TODO link to the element's href
        var name = a.element.name;
        if (name.isEmpty) {
          name = a.constantValue.type.displayName;
        }
        return name;
      }).toList(growable: false);
    }
    return ret;
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
    return _rawDocs;
  }

  @override
  String get documentationAsHtml => _documentation.asHtml;

  Element get element => _element;

  /// Returns the fully qualified name.
  ///
  /// For example: libraryName.className.methodName
  String get fullyQualifiedName {
    return (_fullyQualifiedName ??= _buildFullyQualifiedName());
  }

  bool get hasAnnotations => annotations.isNotEmpty;

  @override
  bool get hasDocumentation =>
      documentation != null && documentation.isNotEmpty;

  bool get hasParameters => parameters.isNotEmpty;

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
    return _linkedName;
  }

  String get linkedParamsLines => linkedParams().trim();

  String get linkedParamsNoMetadata => linkedParams(showMetadata: false);

  ElementType get modelType => _modelType;

  @override
  String get name => element.name;

  @override
  String get oneLineDoc => _documentation.asOneLiner;

  ModelElement get overriddenElement => null;

  Package get package =>
      (this is Library) ? (this as Library).package : this.library.package;

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

    _parameters =
        params.map((p) => new Parameter(p, library)).toList(growable: false);

    return _parameters;
  }

  String get _computeDocumentationComment => element.documentationComment;

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = new Documentation.forElement(this);
    return __documentation;
  }

  bool canOverride() => element is ClassMemberElement;

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
          buf.write('<span>@$annotation</span> ');
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
    if (name.startsWith('_')) {
      return HTML_ESCAPE.convert(name);
    }
    if (!(this is Method || this is Field) && !package.isDocumented(element)) {
      return HTML_ESCAPE.convert(name);
    }

    ModelElement c = (this is EnclosedElement)
        ? (this as EnclosedElement).enclosingElement
        : null;
    if (c != null) {
      if (!package.isDocumented(c.element)) {
        return HTML_ESCAPE.convert(name);
      }
      if (c.name.startsWith('_')) {
        return '${c.name}.${HTML_ESCAPE.convert(name)}';
      }
    }

    var classContent = '';
    if (isDeprecated) {
      classContent = 'class="deprecated" ';
    }

    return '<a ${classContent}href="${href}">$name</a>';
  }

  // TODO(keertip): consolidate all the find library methods
  Library _findLibraryFor(Element e) {
    var element = e.getAncestor((l) => l is LibraryElement);
    var lib;
    if (element != null) {
      lib = package.findLibraryFor(element);
    }
    if (lib == null) {
      lib = package._getLibraryFor(e);
    }
    return lib;
  }

  // process the {@example ...} in comments and inject the example
  // code into the doc commment.
  // {@example core/ts/bootstrap/bootstrap.ts region='bootstrap'}
  String _injectExamples(String rawdocs) {
    if (rawdocs.contains('@example')) {
      RegExp exp = new RegExp(r"{@example .+}");
      Iterable<Match> matches = exp.allMatches(rawdocs);
      var dirPath = this.package.packageMeta.dir.path;
      for (var match in matches) {
        var strings = match.group(0).split(' ');
        var path = strings[1].replaceAll('/', Platform.pathSeparator);
        if (path.contains(Platform.pathSeparator) &&
            !path.startsWith(Platform.pathSeparator)) {
          var file = new File(p.join(dirPath, 'examples', path));
          if (file.existsSync()) {
            // TODO(keertip):inject example
          } else {
            var filepath =
                this.element.source.fullName.substring(dirPath.length + 1);
            stdout.write(
                '\nwarning: ${filepath}: file ${strings[1]} does not exist.');
          }
        }
      }
    }
    return rawdocs;
  }
}

class ModelFunction extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  ModelFunction(FunctionElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_func.type, this);
  }

  @override
  ModelElement get enclosingElement => library;

  String get fileName => "$name.html";

  @override
  String get href => '${library.dirName}/$fileName';

  @override
  bool get isStatic => _func.isStatic;

  @override
  String get kind => 'function';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

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

class Package implements Nameable, Documentable {
  final List<Library> _libraries = [];
  final PackageMeta packageMeta;
  final Map<String, Library> elementLibaryMap = {};
  String _docsAsHtml;

  Package(Iterable<LibraryElement> libraryElements, this.packageMeta) {
    libraryElements.forEach((element) {
      // add only if the element should be included in the public api
      if (isPublic(element)) {
        var lib = new Library(element, this);
        Library._libraryMap.putIfAbsent(lib.name, () => lib);
        elementLibaryMap.putIfAbsent('${lib.kind}.${lib.name}', () => lib);
        _libraries.add(lib);
      }
    });

    _libraries.forEach((library) {
      library._allClasses.forEach(_addToImplementors);
    });

    _libraries.sort();
    _implementors.values.forEach((l) => l.sort());
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

      if (!result.containsKey(name)) result[name] = new PackageCategory(name);
      result[name]._libraries.add(library);
    }

    return result.values.toList()..sort();
  }

  @override
  String get documentation {
    return hasDocumentationFile ? documentationFile.contents : null;
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
  String get href => 'index.html';

  /// Does this package represent the SDK?
  bool get isSdk => packageMeta.isSdk;

  List<Library> get libraries => _libraries;

  @override
  String get name => packageMeta.name;

  @override
  String get oneLineDoc => '';

  String get version => packageMeta.version;

  Library findLibraryFor(final Element element, {final ModelElement scopedTo}) {
    if (element is LibraryElement) {
      // will equality work here? or should we check names?
      return _libraries.firstWhere((lib) => lib.element == element,
          orElse: () => null);
    }

    Element el;
    if (element is ClassMemberElement || element is PropertyAccessorElement) {
      if (element.enclosingElement is! CompilationUnitElement) {
        el = element.enclosingElement;
      } else {
        // get the library
        el = element.enclosingElement.enclosingElement;
      }
    } else if (element is TopLevelVariableElement) {
      final TopLevelVariableElement variableElement = element;
      if (variableElement.getter != null) {
        el = variableElement.getter;
      } else if (variableElement.setter != null) {
        el = variableElement.setter;
      } else {
        el = variableElement;
      }
    } else {
      el = element;
    }
    return _libraries.firstWhere((lib) => lib.hasInExportedNamespace(el),
        orElse: () => null);
  }

  bool isDocumented(Element element) => findLibraryFor(element) != null;

  @override
  String toString() => isSdk ? 'SDK' : 'Package $name';

  /// Will try to find the library that exports the element.
  /// Checks if a library exports a name.
  /// Can return null if not appropriate library can be found.
  Library _getLibraryFor(Element e) {
    // can be null if e is for dynamic
    if (e.library == null) {
      return null;
    }

    Library lib = elementLibaryMap['${e.kind}.${e.name}.${e.enclosingElement}'];
    if (lib != null) return lib;
    lib =
        libraries.firstWhere((l) => l.hasInExportedNamespace(e), orElse: () {});
    if (lib != null) {
      elementLibaryMap.putIfAbsent(
          '${e.kind}.${e.name}.${e.enclosingElement}', () => lib);
      return lib;
    }
    return new Library(e.library, this);
  }
}

class PackageCategory implements Comparable<PackageCategory> {
  final String name;
  final List<Library> _libraries = [];

  PackageCategory(this.name);

  List<Library> get libraries => _libraries;

  @override
  int compareTo(PackageCategory other) => name.compareTo(other.name);
}

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(ParameterElement element, Library library)
      : super(element, library) {
    var t = _parameter.type;
    _modelType = new ElementType(
        t, new ModelElement.from(t.element, _findLibraryFor(t.element)));
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
    var p = _parameter.enclosingElement;

    if (p is FunctionElement) {
      return '${library.dirName}/${p.name}.html';
    } else {
      // TODO: why is this logic here?
      var name = Operator.friendlyNames.containsKey(p.name)
          ? Operator.friendlyNames[p.name]
          : p.name;
      return '${library.dirName}/${p.enclosingElement.name}/' +
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
    if (_lineNumber != null && _crossdartPath != null) {
      String url = "//www.crossdart.info/p/${_crossdartPath}.html";
      return "${url}#line-${_lineNumber}";
    } else {
      return null;
    }
  }

  int get _lineNumber {
    var node = element.computeNode();
    if (node is Declaration && node.element != null) {
      var element = node.element;
      var lineNumber = lineNumberCache.lineNumber(
          element.source.fullName, element.nameOffset);
      return lineNumber + 1;
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

      _modelType = new ElementType(t,
          new ModelElement.from(t.element, package._getLibraryFor(t.element)));
    } else {
      var s = _variable.setter.parameters.first.type;
      _modelType = new ElementType(s,
          new ModelElement.from(s.element, package._getLibraryFor(s.element)));
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
  ModelElement get enclosingElement => library;

  @override
  bool get hasGetter => _variable.getter != null;

  @override
  bool get hasSetter => _variable.setter != null;

  @override
  String get href => '${library.dirName}/$_fileName';

  @override
  bool get isConst => _variable.isConst;

  @override
  bool get isFinal => _variable.isFinal;

  @override
  String get kind => 'top-level property';

  String get linkedReturnType => modelType.linkedName;

  bool get readOnly => hasGetter && !hasSetter;
  bool get readWrite => hasGetter && hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;
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
  String get href => '${library.dirName}/$fileName';

  @override
  String get kind => 'typedef';

  String get linkedReturnType => modelType != null
      ? modelType.createLinkedReturnTypeName()
      : _typedef.returnType.name;

  String get nameWithGenerics {
    if (!modelType.isParameterizedType) return name;
    return '$name&lt;${_typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  List<TypeParameter> get _typeParameters => _typedef.typeParameters.map((f) {
        return new TypeParameter(f, library);
      }).toList();
}

class TypeParameter extends ModelElement {
  TypeParameter(TypeParameterElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_typeParameter.type, this);
  }

  @override
  String get href =>
      '${library.dirName}/${_typeParameter.enclosingElement.name}/$name';

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
