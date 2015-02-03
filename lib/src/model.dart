// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code
library dartdoc.models;

import 'package:analyzer/src/generated/element.dart';

import 'html_utils.dart';
import 'model_utils.dart';
import 'package_utils.dart';

String getFileNameFor(String name) {
  // dart.dartdoc => dart_dartdoc
  // dart:core => dart_core
  return '${name.replaceAll('.', '_').replaceAll(':', '_')}.html';
}

abstract class ModelElement {
  final Element element;
  final Library library;
  final Package package;
  final String source;

  // add getter for ElementType

  String _documentation;

  ModelElement(this.element, this.library, this.package, [this.source]);

  factory ModelElement.from(Element e, Library library, Package package) {
    if (e is ClassElement) {
      return new Class(e, library, package);
    }
    if (e is FunctionElement) {
      return new ModelFunction(e, library, package);
    }
    if (e is FunctionTypeAliasElement) {
      return new Typedef(e, library, package);
    }
    if (e is FieldElement) {
      return new Field(e, library, package);
    }
    if (e is ConstructorElement) {
      return new Constructor(e, library, package);
    }
    if (e is MethodElement) {
      return new Method(e, library, package);
    }
    if (e is PropertyAccessorElement) {
      return new Accessor(e, library, package);
    }
    if (e is TopLevelVariableElement) {
      return new Variable(e, library, package);
    }
    if (e is TypeParameterElement) {
      return new TypeParameter(e, library, package);
    }
  }

  String get documentation {
    if (_documentation != null) return _documentation;

    if (element == null) {
      return null;
    }

    _documentation = element.computeDocumentationComment();

    if (_documentation == null && canOverride()) {
      if (getOverriddenElement() != null) {
        _documentation = getOverriddenElement().documentation;
      }
    }

    if (_documentation != null) {
      _documentation = stripComments(_documentation);
    }

    return _documentation;
  }

  String toString() => '$runtimeType $name';

  ModelElement getChild(String reference) {
    Element e = (element as ElementImpl).getChild(reference);
    if (e is LocalElement /*|| e is TypeVariableElement*/) {
      return null;
    }
    return new ModelElement.from(e, library, package);
  }

  List<String> getAnnotations() {
    List<ElementAnnotation> a = element.metadata;
    if (a.isNotEmpty) {
      return a.map((f) => f.element.name).toList();
    }
    return [];
  }

  bool canOverride() => element is ClassMemberElement;

  ModelElement getOverriddenElement() => null;

  String get typeName => 'element';

  String get name => element.name;

  bool get isExecutable => element is ExecutableElement;

  bool get isPropertyInducer => element is PropertyInducingElement;

  bool get isPropertyAccessor => element is PropertyAccessorElement;

  bool get isLocalElement => element is LocalElement;

  bool get isStatic {
    if (isPropertyInducer) {
      return (element as PropertyInducingElement).isStatic;
    }
    return false;
  }

  bool get isFinal => false;

  bool get isConst => false;

  Class getEnclosingElement() {
    if (element is ClassMemberElement) {
      return new Class(element.enclosingElement, library, package);
    } else {
      return null;
    }
  }

  String createLinkedSummary() {
    if (isExecutable) {
      ExecutableElement ex = (element as ExecutableElement);
      String retType = createLinkedReturnTypeName(new ElementType(ex.type, library, package));

      return '${createLinkedName(this)}'
          '(${printParams(ex.parameters.map((f) =>
                 new Parameter(f, library, package)).toList())})'
          '${retType.isEmpty ? '' : ': $retType'}';
    }
    if (isPropertyInducer) {
      PropertyInducingElement pe = (element as PropertyInducingElement);
      StringBuffer buf = new StringBuffer();
      buf.write('${createLinkedName(this)}');
      String type = createLinkedName(pe.type == null
          ? null
          : new ModelElement.from(pe.type.element, library, package));
      if (!type.isEmpty) {
        buf.write(': $type');
      }
      return buf.toString();
    }
    return createLinkedName(this);
  }

  String createLinkedDescription() {
    if (isExecutable && !(element is ConstructorElement)) {
      ExecutableElement e = (element as ExecutableElement);
      StringBuffer buf = new StringBuffer();

      if (e.isStatic) {
        buf.write('static ');
      }

      buf.write(createLinkedReturnTypeName(new ElementType(e.type, library, package)));
      buf.write(
          ' ${e.name}(${printParams(e.parameters.map((f) => new Parameter(f, library, package)).toList())})');
      return buf.toString();
    }
    if (isPropertyInducer) {
      PropertyInducingElement e = (element as PropertyInducingElement);
      StringBuffer buf = new StringBuffer();
      if (e.isStatic) {
        buf.write('static ');
      }
      if (e.isFinal) {
        buf.write('final ');
      }
      if (e.isConst) {
        buf.write('const ');
      }

      buf.write(createLinkedName(e.type == null
          ? null
          : new ModelElement.from(e.type.element, library, package)));
      buf.write(' ${e.name}');

      // write out any constant value
      Object value = getConstantValue(e);

      if (value != null) {
        if (value is String) {
          String str = stringEscape(value, "'");
          buf.write(" = '${str}'");
        } else if (value is num) {
          buf.write(" = ${value}");
        }
        //NumberFormat.decimalPattern
      }
      return buf.toString();
    }
    return null;
  }

  String createLinkedName(ModelElement e, [bool appendParens = false]) {
    if (e == null) {
      return '';
    }
    if (!package.isDocumented(e)) {
      return htmlEscape(e.name);
    }
    if (e.name.startsWith('_')) {
      return htmlEscape(e.name);
    }
    Class c = e.getEnclosingElement();
    if (c != null && c.name.startsWith('_')) {
      return '${c.name}.${htmlEscape(e.name)}';
    }
    if (c != null && e is Constructor) {
      String name;
      if (e.name.isEmpty) {
        name = c.name;
      } else {
        name = '${c.name}.${htmlEscape(e.name)}';
      }
      if (appendParens) {
        return '<a href="${createHrefFor(e)}">${name}()</a>';
      } else {
        return '<a href="${createHrefFor(e)}">${name}</a>';
      }
    } else {
      String append = '';

      if (appendParens && (e is Method || e is ModelFunction)) {
        append = '()';
      }
      return '<a href="${createHrefFor(e)}">${htmlEscape(e.name)}$append</a>';
    }
  }

  String createHrefFor(ModelElement e) {
    if (!package.isDocumented(e)) {
      return '';
    }
    Class c = e.getEnclosingElement();
    if (c != null) {
      return '${getFileNameFor(e.library.name)}#${c.name}.${escapeBrackets(e.name)}';
    } else {
      return '${getFileNameFor(e.library.name)}#${e.name}';
    }
  }

  String printParams(List<Parameter> params) {
    StringBuffer buf = new StringBuffer();

    for (Parameter p in params) {
      if (buf.length > 0) {
        buf.write(', ');
      }
      if (p.type != null && p.type.name != null) {
        String typeName = createLinkedTypeName(p.type);
        if (typeName.isNotEmpty) buf.write('${typeName} ');
      }
      buf.write(p.name);
    }
    return buf.toString();
  }

  String createLinkedTypeName(ElementType type) {
    StringBuffer buf = new StringBuffer();

    if (type.isParameterType) {
      buf.write(type.element.name);
    } else {
      buf.write(createLinkedName(type.element));
    }

    // TODO: apparently, EVERYTHING is a parameterized type ?!?!
    // this is always true
    if (type.isParameterizedType) {
      if (!type.typeArguments.isEmpty && (type.typeArguments.length > 1 || type.typeArguments.first.toString() != 'dynamic')) {
        buf.write('&lt;');
        for (int i = 0; i < type.typeArguments.length; i++) {
          if (i > 0) {
            buf.write(', ');
          }
          ElementType t = type.typeArguments[i];
          buf.write(createLinkedTypeName(t));
        }
        buf.write('&gt;');
      }
    }
    return buf.toString();
  }

  String createLinkedReturnTypeName(ElementType type) {
    if (type.returnElement == null) {
      if (type.returnTypeName != null) {
        return type.returnTypeName;
      } else {
        return '';
      }
    } else {
      return createLinkedTypeName(type.returnType);
    }
  }

  String get docOneLiner {
    var doc = stripComments(documentation);
    if (doc == null || doc == '') return null;
    var endOfFirstSentence = doc.indexOf('.');
    if (endOfFirstSentence >= 0) {
      return doc.substring(0, endOfFirstSentence + 1);
    } else {
      return doc;
    }
  }
}

class Package {
  String _rootDirPath;
  final List<Library> _libraries = [];
  bool _isSdk;
  String _sdkVersion;

  String get name =>
      _isSdk ? 'Dart API Reference' : getPackageName(_rootDirPath);

  String get version => _isSdk ? _sdkVersion : getPackageVersion(_rootDirPath);

  String get sdkVersion => _sdkVersion;

  String get description =>
      _isSdk ? 'Dart API Libraries' : getPackageDescription(_rootDirPath);

  List<Library> get libraries => _libraries;

  Package(Iterable<LibraryElement> libraryElements, this._rootDirPath,
      [this._sdkVersion, this._isSdk = false]) {
    libraryElements.forEach((element) {
      print('adding lib $element to package $name');
      _libraries.add(new Library(element, this));
    });
  }

  String toString() => 'Package $name, isSdk: $_isSdk';

  bool isDocumented(ModelElement e) {
    // TODO: review this logic. I'm compensating for what's probably a bug
    // see also ElementType and how an elementType is linked to a library
    if (e is Library) {
      return _libraries.any((lib) => lib.element == e.element);
    } else {
      return _libraries.any((lib) => lib.element == e.element.library);
    }
  }
}

class Library extends ModelElement {
  LibraryElement get _library => (element as LibraryElement);

  Library(LibraryElement element, Package package, [String source])
      : super(element, null, package, source);

  String get name {
    var source = _library.definingCompilationUnit.source;
    return source.isInSystemLibrary ? source.encoding : super.name;
  }

  List<Library> get exported =>
      _library.exportedLibraries.map((lib) => new Library(lib, package)).toList();

  List<Variable> getVariables() {
    List<TopLevelVariableElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.topLevelVariables);
    }
    elements
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return elements.map((e) => new Variable(e, this, package)).toList();
  }

  List<Accessor> getAccessors() {
    List<PropertyAccessorElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.accessors);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.accessors);
    }
    elements
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    elements.removeWhere((e) => e.isSynthetic);
    return elements.map((e) => new Accessor(e, this, package)).toList();
  }

  List<Typedef> getTypedefs() {
    List<FunctionTypeAliasElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.functionTypeAliases);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.functionTypeAliases);
    }
    elements
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return elements.map((e) => new Typedef(e, this, null)).toList();
  }

  List<ModelFunction> getFunctions() {
    List<FunctionElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.functions);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.functions);
    }
    elements
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return elements.map((e) {
      String eSource =
          (source != null) ? source.substring(e.node.offset, e.node.end) : null;
      return new ModelFunction(e, this, package, eSource);
    }).toList();
  }

  List<Class> getTypes() {
    List<ClassElement> types = [];
    types.addAll(_library.definingCompilationUnit.types);
    for (CompilationUnitElement cu in _library.parts) {
      types.addAll(cu.types);
    }
    types
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return types.map((e) => new Class(e, this, package, source)).toList();
  }
}

class Class extends ModelElement {
  ClassElement get _cls => (element as ClassElement);

  String get typeName => 'Classes';

  Class(ClassElement element, Library library, Package package, [String source])
      : super(element, library, package, source);

  bool get isAbstract => _cls.isAbstract;

  bool get hasSupertype =>
      _cls.supertype != null && _cls.supertype.element.supertype != null;

  ElementType get supertype => new ElementType(_cls.supertype, library, package);

  List<ElementType> get mixins =>
      _cls.mixins.map((f) => new ElementType(f, library, package)).toList();

  List<ElementType> get interfaces =>
      _cls.interfaces.map((f) => new ElementType(f, library, package)).toList();

  List<Field> _getAllfields() {
    List<FieldElement> elements = _cls.fields.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return elements.map((e) => new Field(e, library, package)).toList();
  }

  List<Field> getStaticFields() =>
      _getAllfields()..removeWhere((f) => !f.isStatic);

  List<Field> getInstanceFields() =>
      _getAllfields()..removeWhere((f) => f.isStatic);

  List<Accessor> getAccessors() {
    List<PropertyAccessorElement> accessors = _cls.accessors.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    accessors.removeWhere((e) => e.isSynthetic);
    return accessors.map((e) => new Accessor(e, library, package)).toList();
  }

  List<Constructor> getCtors() {
    List<ConstructorElement> c = _cls.constructors.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return c.map((e) {
      var cSource =
          (source != null) ? source.substring(e.node.offset, e.node.end) : null;
      return new Constructor(e, library, cSource);
    }).toList();
  }

  List<Method> getMethods() {
    List<MethodElement> m = _cls.methods.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return m.map((e) {
      var mSource =
          source != null ? source.substring(e.node.offset, e.node.end) : null;
      return new Method(e, library, mSource);
    }).toList();
  }

  String createLinkedDescription() {
    return '';
  }
}

class ModelFunction extends ModelElement {

  ModelFunction(FunctionElement element, Library library, Package package,
                [String contents])
      : super(element, library, package, contents);

  FunctionElement get _func => (element as FunctionElement);

  bool get isStatic => _func.isStatic;

  String get typeName => 'Functions';

  String get linkedSummary {
    String retType = createLinkedReturnTypeName(new ElementType(_func.type, library, package));

    return '${createLinkedName(this)}'
        '(${printParams(_func.parameters.map((f) => new Parameter(f, library, package)))})'
        '${retType.isEmpty ? '' : ': $retType'}';
  }

  String createLinkedDescription() {
    StringBuffer buf = new StringBuffer();
    if (_func.isStatic) {
      buf.write('static ');
    }
    buf.write(createLinkedReturnTypeName(new ElementType(_func.type, library, package)));
    buf.write(
        ' ${_func.name}(${printParams(_func.parameters.map((f) => new Parameter(f, library, package)).toList())})');
    return buf.toString();
  }

  String get linkedParams {
    return printParams(_func.parameters.map((f) => new Parameter(f, library, package)).toList());
  }

  String get linkedReturnType {
    return createLinkedReturnTypeName(new ElementType(_func.type, library, package));
  }
}

class Typedef extends ModelElement {
  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  Typedef(FunctionTypeAliasElement element, Library library, Package package)
      : super(element, library, package);

  String get typeName => 'Typedefs';

  String createLinkedSummary() {
    // Comparator<T>(T a, T b): int
    StringBuffer buf = new StringBuffer();
    buf.write(createLinkedName(this));
    if (!_typedef.typeParameters.isEmpty) {
      buf.write('&lt;');
      for (int i = 0; i < _typedef.typeParameters.length; i++) {
        if (i > 0) {
          buf.write(', ');
        }
        buf.write(_typedef.typeParameters[i].name);
      }
      buf.write('&gt;');
    }
    buf.write(
        '(${printParams(_typedef.parameters.map((f) => new Parameter(f, library, package)).toList())}): ');
    buf.write(createLinkedReturnTypeName(new ElementType(_typedef.type, library, package)));
    return buf.toString();
  }

  String createLinkedDescription() {
    // typedef int Comparator<T>(T a, T b)

    StringBuffer buf = new StringBuffer();
    buf.write(
        'typedef ${createLinkedReturnTypeName(new ElementType(_typedef.type, library, package))} ${_typedef.name}');
    if (!_typedef.typeParameters.isEmpty) {
      buf.write('&lt;');
      for (int i = 0; i < _typedef.typeParameters.length; i++) {
        if (i > 0) {
          buf.write(', ');
        }
        buf.write(_typedef.typeParameters[i].name);
      }
      buf.write('&gt;');
    }
    buf.write(
        '(${printParams(_typedef.parameters.map((f) => new Parameter(f, library, package)).toList())}): ');
    return buf.toString();
  }
}

class Field extends ModelElement {
  FieldElement get _field => (element as FieldElement);

  Field(FieldElement element, Library library, Package package)
      : super(element, library, package);

  bool get isFinal => _field.isFinal;

  bool get isConst => _field.isConst;

  String get typeName => 'Fields';
}

class Constructor extends ModelElement {
  ConstructorElement get _constructor => (element as ConstructorElement);

  Constructor(ConstructorElement element, Library library, Package package, [String source])
      : super(element, library, package, source);

  String get typeName => 'Constructors';

  String createLinkedSummary() {
    return '${createLinkedName(this)}' '(${printParams(_constructor.parameters.map((f) => new Parameter(f, library, package)).toList())})';
  }

  String createLinkedDescription() {
    StringBuffer buf = new StringBuffer();
    if (_constructor.isStatic) {
      buf.write('static ');
    }
    if (_constructor.isFactory) {
      buf.write('factory ');
    }
    buf.write(
        '${_constructor.type.returnType.name}${_constructor.name.isEmpty?'':'.'}'
        '${_constructor.name}'
        '(${printParams(
                      _constructor.parameters.map((f) => new Parameter(f, library, package)).toList())})');
    return buf.toString();
  }
}

class Method extends ModelElement {
//  MethodElement get _method => (element as MethodElement);

  Method(MethodElement element, Library library, Package package, [String source])
      : super(element, library, package, source);

  Method getOverriddenElement() {
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in getAllSupertypes(parent)) {
      if (t.getMethod(element.name) != null) {
        return new Method(t.getMethod(element.name), library, package);
      }
    }
    return null;
  }

  String get typeName => 'Methods';
}

class Accessor extends ModelElement {
  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);

  Accessor(PropertyAccessorElement element, Library library, Package package)
      : super(element, library, package);

  String get typeName => 'Getters and Setters';

  bool get isGetter => _accessor.isGetter;

  String createLinkedSummary() {
    StringBuffer buf = new StringBuffer();

    if (_accessor.isGetter) {
      buf.write(createLinkedName(this));
      buf.write(': ');
      buf.write(createLinkedReturnTypeName(new ElementType(
          _accessor.type,
          new ModelElement.from(_accessor.type.element, library, package),
          package)));
    } else {
      buf.write('${createLinkedName(this)}('
          '${printParams(_accessor.parameters.map((f) =>
                    new Parameter(f,library,package)))})');
    }
    return buf.toString();
  }

  String createLinkedDescription() {
    StringBuffer buf = new StringBuffer();
    if (_accessor.isStatic) {
      buf.write('static ');
    }
    if (_accessor.isGetter) {
      buf.write(
          '${createLinkedReturnTypeName(new ElementType(_accessor.type, new ModelElement.from(_accessor.type.element, library, package), package))} get ${_accessor.name}');
    } else {
      buf.write(
          'set ${_accessor.name}(${printParams(_accessor.parameters.map((f) => new Parameter(f,library,package)))})');
    }
    return buf.toString();
  }
}

class Variable extends ModelElement {
  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);

  Variable(TopLevelVariableElement element, Library library, Package package)
      : super(element, library, package);

  String get typeName => 'Top-Level Variables';

  bool get isFinal => _variable.isFinal;

  bool get isConst => _variable.isConst;
}

class Parameter extends ModelElement {
  Parameter(ParameterElement element, Library library, Package package)
      : super(element, library, package);

  ParameterElement get _parameter => element as ParameterElement;

  ElementType get type => new ElementType(_parameter.type, library, package);

  String toString() => element.name;

  String get typeName => 'Parameters';
}

class TypeParameter extends ModelElement {
  TypeParameter(TypeParameterElement element, Library library, Package package)
      : super(element, library, package);

  TypeParameterElement get _typeParameter => element as TypeParameterElement;

  ElementType get type => new ElementType(_typeParameter.type, library, package);

  String toString() => element.name;

  String get typeName => 'Type Parameters';
}

class ElementType {
  DartType _type;
  Library library;
  Package package;

  // TODO: Should this be the program's library and package, or the
  // library and package of the actual _type ?
  ElementType(this._type, this.library, this.package);

  String toString() => "$_type";

  bool get isParameterType => (_type is TypeParameterType);

  ModelElement get element => new ModelElement.from(_type.element, library, package);

  String get name => _type.name;

  bool get isParameterizedType => (_type is ParameterizedType);

  String get returnTypeName => (_type as FunctionType).returnType.name;

  ElementType get returnType =>
      new ElementType((_type as FunctionType).returnType, library, package);

  ModelElement get returnElement {
    Element e = (_type as FunctionType).returnType.element;
    if (e == null) {
      return null;
    }
    // TODO: this is probably a bug. e and element are probably not the same?
    return (new ModelElement.from(e, element.library, package));
  }
  List<ElementType> get typeArguments =>
      (_type as ParameterizedType).typeArguments
          .map((f) => new ElementType(f, library, package))
          .toList();
}

//abstract class Helper {
//  String createLinkedName(ModelElement e, [bool appendParens = false]);
//  String createLinkedReturnTypeName(ElementType type);
//  String createLinkedTypeName(ElementType type);
//  String printParams(List<Parameter> params);
//  String createHrefFor(ModelElement e);
//}
