// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code
library dartdoc.models;

import 'package:analyzer/src/generated/element.dart';

import 'html_utils.dart';
import 'model_utils.dart';
import 'package_utils.dart';

abstract class ModelElement {
  Element element;

  Library library;

  ModelElement(this.element, this.library);

  factory ModelElement.from(Element e, Library library) {
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
    if (e is MethodElement) {
      return new Method(e, library);
    }
    if (e is PropertyAccessorElement) {
      return new Accessor(e, library);
    }
    if (e is TopLevelVariableElement) {
      return new Variable(e, library);
    }
    if (e is TypeParameterElement) {
      return new TypeParameter(e, library);
    }
  }

  String getDocumentation() {
    if (element == null) {
      return null;
    }

    String comments = element.computeDocumentationComment();

    if (comments != null) {
      return comments;
    }

    if (canOverride()) {
      if (getOverriddenElement() != null) {
        return getOverriddenElement().getDocumentation();
      }
    }
    return null;
  }

  ModelElement getChild(String reference) {
    Element e = (element as ElementImpl).getChild(reference);
    if (e is LocalElement /*|| e is TypeVariableElement*/) {
      return null;
    }
    return new ModelElement.from(e, library);
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
      return new Class(element.enclosingElement, library);
    } else {
      return null;
    }
  }

  String createLinkedSummary(Helper generator) {
    if (isExecutable) {
      ExecutableElement ex = (element as ExecutableElement);
      String retType = generator.createLinkedReturnTypeName(
          new ElementType(ex.type, library));

      return '${generator.createLinkedName(this)}'
          '(${generator.printParams(ex.parameters.map((f) =>
                 new Parameter(f, library)).toList())})'
          '${retType.isEmpty ? '' : ': $retType'}';
    }
    if (isPropertyInducer) {
      PropertyInducingElement pe = (element as PropertyInducingElement);
      StringBuffer buf = new StringBuffer();
      buf.write('${generator.createLinkedName(this)}');
      String type = generator.createLinkedName(pe.type == null ? null :
          new ModelElement.from(pe.type.element, library));
      if (!type.isEmpty) {
        buf.write(': $type');
      }
      return buf.toString();
    }
    return generator.createLinkedName(this);
  }

  String createLinkedDescription(Helper generator) {
    if (isExecutable && !(element is ConstructorElement)) {
      ExecutableElement e = (element as ExecutableElement);
      StringBuffer buf = new StringBuffer();

      if (e.isStatic) {
        buf.write('static ');
      }

      buf.write(generator.createLinkedReturnTypeName(
          new ElementType(e.type, library)));
      buf.write(
          ' ${e.name}(${generator.printParams(e.parameters.map((f) => new Parameter(f, library)).toList())})');
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

      buf.write(generator.createLinkedName(e.type == null ? null :
          new ModelElement.from(e.type.element, library)));
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
}

class Package {
  String _rootDirPath;

  List<Library> _libraries = [];

  String get name => getPackageName(_rootDirPath);

  String get version => getPackageVersion(_rootDirPath);

  String get description => getPackageDescription(_rootDirPath);

  List<Library> get libraries => _libraries;

  Package(Iterable<LibraryElement> libraryElements, this._rootDirPath) {
    libraryElements.forEach((element) {
      _libraries.add(new Library(element));
    });
  }

  bool isDocumented(ModelElement e) {
    if (e is Library) {
      return _libraries.contains(e);
    }
    return _libraries.contains(e.library);
  }
}

class Library extends ModelElement {
  LibraryElement get _library => (element as LibraryElement);

  Library(LibraryElement element) : super(element, null);

  List<Library> get exported =>
      _library.exportedLibraries.map((lib) => new Library(lib)).toList();

  List<Variable> getVariables() {
    List<TopLevelVariableElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.topLevelVariables);
    }
    elements
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return elements.map((e) => new Variable(e, this)).toList();
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
    return elements.map((e) => new Accessor(e, this)).toList();
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
    return elements.map((e) => new Typedef(e, this)).toList();
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
    return elements.map((e) => new ModelFunction(e, this)).toList();
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
    return types.map((e) => new Class(e, this)).toList();
  }
}

class Class extends ModelElement {
  ClassElement get _cls => (element as ClassElement);

  String get typeName => 'Classes';

  Class(ClassElement element, Library library) : super(element, library);

  bool get isAbstract => _cls.isAbstract;

  bool get hasSupertype =>
      _cls.supertype != null && _cls.supertype.element.supertype != null;

  ElementType get supertype => new ElementType(_cls.supertype, library);

  List<ElementType> get mixins =>
      _cls.mixins.map((f) => new ElementType(f, library)).toList();

  List<ElementType> get interfaces =>
      _cls.interfaces.map((f) => new ElementType(f, library)).toList();

  List<Field> _getAllfields() {
    List<FieldElement> elements = _cls.fields.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return elements.map((e) => new Field(e, library)).toList();
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
    return accessors.map((e) => new Accessor(e, library)).toList();
  }

  List<Constructor> getCtors() {
    List<ConstructorElement> c = _cls.constructors.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return c.map((e) => new Constructor(e, library)).toList();
  }

  List<Method> getMethods() {
    List<MethodElement> m = _cls.methods.toList()
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return m.map((e) => new Method(e, library)).toList();
  }

  String createLinkedDescription(Helper generator) {
    return '';
  }
}

class ModelFunction extends ModelElement {
  ModelFunction(FunctionElement element, Library library)
      : super(element, library);

  FunctionElement get _func => (element as FunctionElement);

  String get typeName => 'Functions';

  String createLinkedSummary(Helper generator) {
    String retType = generator.createLinkedReturnTypeName(
        new ElementType(_func.type, library));

    return '${generator.createLinkedName(this)}'
        '(${generator.printParams(_func.parameters.map((f) => new Parameter(f, library)))})'
        '${retType.isEmpty ? '' : ': $retType'}';
  }

  String createLinkedDescription(Helper generator) {
    StringBuffer buf = new StringBuffer();
    if (_func.isStatic) {
      buf.write('static ');
    }
    buf.write(generator.createLinkedReturnTypeName(
        new ElementType(_func.type, library)));
    buf.write(
        ' ${_func.name}(${generator.printParams(_func.parameters.map((f) => new Parameter(f, library)).toList())})');
    return buf.toString();
  }
}

class Typedef extends ModelElement {
  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  Typedef(FunctionTypeAliasElement element, Library library)
      : super(element, library);

  String get typeName => 'Typedefs';

  String createLinkedSummary(Helper generator) {
    // Comparator<T>(T a, T b): int
    StringBuffer buf = new StringBuffer();
    buf.write(generator.createLinkedName(this));
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
        '(${generator.printParams(_typedef.parameters.map((f) => new Parameter(f, library)).toList())}): ');
    buf.write(generator.createLinkedReturnTypeName(
        new ElementType(_typedef.type, library)));
    return buf.toString();
  }

  String createLinkedDescription(Helper generator) {
    // typedef int Comparator<T>(T a, T b)

    StringBuffer buf = new StringBuffer();
    buf.write(
        'typedef ${generator.createLinkedReturnTypeName(new ElementType(_typedef.type, library))} ${_typedef.name}');
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
        '(${generator.printParams(_typedef.parameters.map((f) => new Parameter(f, library)).toList())}): ');
    return buf.toString();
  }
}

class Field extends ModelElement {
  FieldElement get _field => (element as FieldElement);

  Field(FieldElement element, Library library) : super(element, library);

  bool get isFinal => _field.isFinal;

  bool get isConst => _field.isConst;

  String get typeName => 'Fields';
}

class Constructor extends ModelElement {
  ConstructorElement get _constructor => (element as ConstructorElement);

  Constructor(ConstructorElement element, Library library)
      : super(element, library);

  String get typeName => 'Constructors';

  String createLinkedSummary(Helper generator) {
    return '${generator.createLinkedName(this)}' '(${generator.printParams(_constructor.parameters.map((f) => new Parameter(f, library)).toList())})';
  }

  String createLinkedDescription(Helper generator) {
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
        '(${generator.printParams(
                      _constructor.parameters.map((f) => new Parameter(f, library)).toList())})');
    return buf.toString();
  }
}

class Method extends ModelElement {
  // MethodElement get _method => (element as MethodElement);

  Method(MethodElement element, Library library) : super(element, library);

  Method getOverriddenElement() {
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in getAllSupertypes(parent)) {
      if (t.getMethod(element.name) != null) {
        return new Method(t.getMethod(element.name), library);
      }
    }
    return null;
  }

  String get typeName => 'Methods';
}

class Accessor extends ModelElement {
  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);

  Accessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  String get typeName => 'Getters and Setters';

  bool get isGetter => _accessor.isGetter;

  String createLinkedSummary(Helper generator) {
    StringBuffer buf = new StringBuffer();

    if (_accessor.isGetter) {
      buf.write(generator.createLinkedName(this));
      buf.write(': ');
      buf.write(generator.createLinkedReturnTypeName(new ElementType(
          _accessor.type, new ModelElement.from(
              _accessor.type.element, library))));
    } else {
      buf.write('${generator.createLinkedName(this)}('
          '${generator.printParams(_accessor.parameters.map((f) =>
                    new Parameter(f,library)))})');
    }
    return buf.toString();
  }

  String createLinkedDescription(Helper generator) {
    StringBuffer buf = new StringBuffer();
    if (_accessor.isStatic) {
      buf.write('static ');
    }
    if (_accessor.isGetter) {
      buf.write(
          '${generator.createLinkedReturnTypeName(new ElementType(_accessor.type, new ModelElement.from(_accessor.type.element, library)))} get ${_accessor.name}');
    } else {
      buf.write(
          'set ${_accessor.name}(${generator.printParams(_accessor.parameters.map((f) => new Parameter(f,library)))})');
    }
    return buf.toString();
  }
}

class Variable extends ModelElement {
  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);

  Variable(TopLevelVariableElement element, Library library)
      : super(element, library);

  String get typeName => 'Top-Level Variables';

  bool get isFinal => _variable.isFinal;

  bool get isConst => _variable.isConst;
}

class Parameter extends ModelElement {
  Parameter(ParameterElement element, Library library)
      : super(element, library);

  ParameterElement get _parameter => element as ParameterElement;

  ElementType get type => new ElementType(_parameter.type, library);

  String toString() => element.name;
}

class TypeParameter extends ModelElement {
  TypeParameter(TypeParameterElement element, Library library)
       : super(element, library);

   TypeParameterElement get _typeParameter => element as TypeParameterElement;

   ElementType get type => new ElementType(_typeParameter.type, library);

   String toString() => element.name;
}

class ElementType {
  DartType _type;
  Library library;

  ElementType(this._type, this.library);

  bool get isParameterType => (_type is TypeParameterType);

  ModelElement get element => new ModelElement.from(_type.element, library);

  String get name => _type.name;

  bool get isParameterizedType => (_type is ParameterizedType);

  String get returnTypeName => (_type as FunctionType).returnType.name;

  ElementType get returnType =>
      new ElementType((_type as FunctionType).returnType, library);

  ModelElement get returnElement {
    Element e = (_type as FunctionType).returnType.element;
    if (e == null) {
      return null;
    }
    return (new ModelElement.from(e, element.library));
  }
  List<ElementType> get typeArguments =>
      (_type as ParameterizedType).typeArguments
      .map((f) => new ElementType(f, library))
      .toList();
}

abstract class Helper {
  String createLinkedName(ModelElement e, [bool appendParens = false]);
  String createLinkedReturnTypeName(ElementType type);
  String createLinkedTypeName(ElementType type);
  String printParams(List<Parameter> params);
  String createHrefFor(ModelElement e);
}
