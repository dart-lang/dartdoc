// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code
library dartdoc.models;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/source.dart' show SourceRange;
import 'package:analyzer/src/generated/utilities_dart.dart' show ParameterKind;

import 'html_utils.dart';
import 'model_utils.dart';
import 'package_utils.dart';

abstract class ModelElement {
  final Element element;
  final Library library;
  final String source;

  // add getter for ElementType

  String _documentation;

  ModelElement(this.element, this.library, [this.source]);

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
    if (e is DynamicElementImpl) {
      return new Dynamic(e, library);
    }
    throw "Unknown type ${e.runtimeType}";
  }

  String get documentation {
    var commentRefs;
    if (_documentation != null) {
      return _documentation;
    }
    if (element == null) {
      return null;
    }
    _documentation = element.computeDocumentationComment();

    if (_documentation == null && canOverride()) {
      var overrideElement = getOverriddenElement();
      if (overrideElement != null) {
        _documentation = overrideElement.documentation;
        if (overrideElement.element.node is AnnotatedNode) {
          commentRefs =
              (overrideElement.element.node as AnnotatedNode).documentationComment.references;
        }
      }
    } else {
      if (_documentation != null) {
        if (element.node is AnnotatedNode) {
          commentRefs =
              (element.node as AnnotatedNode).documentationComment.references;
        }
      }
    }
    if (_documentation != null) {
      _documentation = _processRefs(stripComments(_documentation), commentRefs);
    }
    return _documentation;
  }

  String _processRefs(String docs, NodeList<CommentReference> commentRefs) {
    var matchChars = ['[', ']'];
    int lastWritten = 0;
    int index = docs.indexOf(matchChars[0]);
    StringBuffer buf = new StringBuffer();

    while (index != -1) {
      int end = docs.indexOf(matchChars[1], index + 1);
      if (end != -1) {
        if (index - lastWritten > 0) {
          buf.write(docs.substring(lastWritten, index));
        }
        String codeRef = docs.substring(index + matchChars[0].length, end);
        buf.write('[$codeRef]');
        var refElement = commentRefs.firstWhere(
            (ref) => ref.identifier.name == codeRef).identifier.staticElement;
        var refLibrary = new Library(refElement.library, package);
        var e = new ModelElement.from(refElement, refLibrary);
        buf.write('(${e.href})');
        lastWritten = end + matchChars[1].length;
      } else {
        break;
      }
      index = docs.indexOf(matchChars[0], end + 1);
    }
    if (lastWritten < docs.length) {
      buf.write(docs.substring(lastWritten, docs.length));
    }
    return buf.toString();
  }

  String get htmlId => name;

  String toString() => '$runtimeType $name';

  List<String> getAnnotations() {
    List<ElementAnnotation> a = element.metadata;
    if (a.isNotEmpty) {
      return a.map((f) => f.element.name).toList();
    }
    return [];
  }

  bool canOverride() => element is ClassMemberElement;

  ModelElement getOverriddenElement() => null;

  String get name => element.name;

  bool get hasParameters => element is ExecutableElement || element is FunctionTypeAliasElement;

  List<Parameter> get parameters {
    if (!hasParameters) {
      throw new StateError("$element does not have parameters");
    }

    List<ParameterElement> params;

    if (element is ExecutableElement) {
      // the as check silences the warning
      params = (element as ExecutableElement).parameters;
    }

    if (element is FunctionTypeAliasElement) {
      params = (element as FunctionTypeAliasElement).parameters;
    }

    return params.map((p) => new Parameter(p, library)).toList(growable:false);
  }

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

  /// Returns the [ModelElement] that encloses this.
  ModelElement getEnclosingElement() {
    // A class's enclosing element is a library, and there isn't a
    // modelelement for a library.
    if (element.enclosingElement != null && element.enclosingElement is ClassElement) {
      return new ModelElement.from(element.enclosingElement, library);
    } else {
      return null;
    }
  }

//  String createLinkedSummary() {
//    if (isExecutable) {
//      ExecutableElement ex = (element as ExecutableElement);
//      String retType =
//          createLinkedReturnTypeName(new ElementType(ex.type, library));
//
//      return '${createLinkedName(this)}'
//          '($linkedParams)'
//          '${retType.isEmpty ? '' : ': $retType'}';
//    }
//    if (isPropertyInducer) {
//      PropertyInducingElement pe = (element as PropertyInducingElement);
//      StringBuffer buf = new StringBuffer();
//      buf.write('${createLinkedName(this)}');
//      String type = createLinkedName(pe.type == null
//          ? null
//          : new ModelElement.from(pe.type.element, library));
//      if (!type.isEmpty) {
//        buf.write(': $type');
//      }
//      return buf.toString();
//    }
//    return createLinkedName(this);
//  }

//  String createLinkedDescription() {
//    if (isExecutable && !(element is ConstructorElement)) {
//      ExecutableElement e = (element as ExecutableElement);
//      StringBuffer buf = new StringBuffer();
//
//      if (e.isStatic) {
//        buf.write('static ');
//      }
//
//      buf.write(createLinkedReturnTypeName(new ElementType(e.type, library)));
//      buf.write(
//          ' ${e.name}($linkedParams)');
//      return buf.toString();
//    }
//    if (isPropertyInducer) {
//      PropertyInducingElement e = (element as PropertyInducingElement);
//      StringBuffer buf = new StringBuffer();
//      if (e.isStatic) {
//        buf.write('static ');
//      }
//      if (e.isFinal) {
//        buf.write('final ');
//      }
//      if (e.isConst) {
//        buf.write('const ');
//      }
//
//      buf.write(createLinkedName(e.type == null
//          ? null
//          : new ModelElement.from(e.type.element, library)));
//      buf.write(' ${e.name}');
//
//      // write out any constant value
//      Object value = getConstantValue(e);
//
//      if (value != null) {
//        if (value is String) {
//          String str = stringEscape(value, "'");
//          buf.write(" = '${str}'");
//        } else if (value is num) {
//          buf.write(" = ${value}");
//        }
//        //NumberFormat.decimalPattern
//      }
//      return buf.toString();
//    }
//    return null;
//  }

  Package get package =>
      (this is Library) ? (this as Library).package : this.library.package;

  String get linkedName {
    if (!package.isDocumented(this)) {
      return htmlEscape(name);
    }
    if (name.startsWith('_')) {
      return htmlEscape(name);
    }
    Class c = getEnclosingElement();
    if (c != null && c.name.startsWith('_')) {
      return '${c.name}.${htmlEscape(name)}';
    }
    if (c != null && this is Constructor) {
      String name;
      if (name.isEmpty) {
        name = c.name;
      } else {
        name = '${c.name}.${htmlEscape(name)}';
      }
      return '<a href="${href}">${name}</a>';
    } else {
      return '<a href="${href}">${htmlEscape(name)}</a>';
    }
  }

  String get href {
    if (!package.isDocumented(this)) return null;
    return _href;
  }

  String get _href;

  // TODO: handle default values
  String get linkedParams {
    List<Parameter> allParams = parameters;

    List<Parameter> requiredParams =
      allParams.where((Parameter p) => !p.isOptional).toList();

    List<Parameter> positionalParams =
      allParams.where((Parameter p) => p.isOptionalPositional).toList();

    List<Parameter> namedParams =
      allParams.where((Parameter p) => p.isOptionalNamed).toList();

    StringBuffer buf = new StringBuffer();

    void renderParams(StringBuffer buf, List<Parameter> params) {
      for (int i = 0; i < params.length; i++) {
        Parameter p = params[i];
        if (i > 0) buf.write(', ');
        if (p.type != null && p.type.name != null) {
          String typeName = createLinkedTypeName(p.type);
          if (typeName.isNotEmpty) {
            buf.write('<span class="type-annotation">$typeName</span> ');
          }
        }
        buf.write('<span class="parameter-name">${p.name}</span>');

        if (p.hasDefaultValue) {
          if (p.isOptionalNamed) {
            buf.write(': ');
          } else {
            buf.write('= ');
          }
          buf.write('<span class="default-value">${p.defaultValue}</span>');
        }
      }
    }

    renderParams(buf, requiredParams);

    if (positionalParams.isNotEmpty) {
      if (requiredParams.isNotEmpty) {
        buf.write(', ');
      }
      buf.write('[');
      renderParams(buf, positionalParams);
      buf.write(']');
    }

    if (namedParams.isNotEmpty) {
      if (requiredParams.isNotEmpty) {
        buf.write(', ');
      }
      buf.write('{');
      renderParams(buf, namedParams);
      buf.write('}');
    }

    return buf.toString();
  }

  String createLinkedTypeName(ElementType type) {
    StringBuffer buf = new StringBuffer();

    if (type.isParameterType) {
      buf.write(type.element.name);
    } else {
      buf.write(type.element.linkedName);
    }

    // TODO: apparently, EVERYTHING is a parameterized type ?!?!
    // this is always true
    if (type.isParameterizedType) {
      if (!type.typeArguments.isEmpty &&
          (type.typeArguments.length > 1 ||
              type.typeArguments.first.toString() != 'dynamic')) {
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
    var doc = documentation;
    if (doc == null || doc == '') return null;
    var endOfFirstSentence = doc.indexOf('. ');
    if (endOfFirstSentence >= 0) {
      return doc.substring(0, endOfFirstSentence + 1);
    }
    return doc;
  }
}

class Dynamic extends ModelElement {
  Dynamic(DynamicElementImpl element, Library library, [String source])
      : super(element, library, source);
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
      //   print('adding lib $element to package $name');
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
  Package package;

  LibraryElement get _library => (element as LibraryElement);

  Library(LibraryElement element, this.package, [String source])
      : super(element, null, source);

  String get name {
    var source = _library.definingCompilationUnit.source;
    return source.isInSystemLibrary ? source.encoding : super.name;
  }

  bool get isInSdk => _library.isInSdk;

  List<Library> get exported => _library.exportedLibraries
      .map((lib) => new Library(lib, package))
      .toList();

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

  /// Returns getters and setters?
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
      // TODO not sure we want to sort these. Source order might be best.
      ..sort(elementCompare);
    return elements.map((e) {
      String eSource =
          (source != null) ? source.substring(e.node.offset, e.node.end) : null;
      return new ModelFunction(e, this, eSource);
    }).toList();
  }

  // TODO: rename this to getClasses
  List<Class> getTypes() {
    List<ClassElement> types = [];
    types.addAll(_library.definingCompilationUnit.types);
    for (CompilationUnitElement cu in _library.parts) {
      types.addAll(cu.types);
    }
    types
      ..removeWhere(isPrivate)
      ..sort(elementCompare);
    return types.map((e) => new Class(e, this, source)).toList();
  }

  List<Class> getExceptions() {
    LibraryElement coreLib =
        _library.importedLibraries.firstWhere((i) => i.name == 'dart.core');
    ClassElement exception = coreLib.getType('Exception');
    ClassElement error = coreLib.getType('Error');
    bool isExceptionOrError(Class t) {
      return t._cls.type.isSubtypeOf(exception.type) ||
          t._cls.type.isSubtypeOf(error.type);
    }
    return getTypes().where(isExceptionOrError).toList();
  }
}

class Class extends ModelElement {
  ClassElement get _cls => (element as ClassElement);

  Class(ClassElement element, Library library, [String source])
      : super(element, library, source);

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

  String get _href => '${library.name}/$name.html';
}

class ModelFunction extends ModelElement {
  ModelFunction(FunctionElement element, Library library, [String contents])
      : super(element, library, contents);

  FunctionElement get _func => (element as FunctionElement);

  bool get isStatic => _func.isStatic;

  String get linkedSummary {
    String retType =
        createLinkedReturnTypeName(new ElementType(_func.type, library));

    return '${linkedName}'
        '($linkedParams)'
        '${retType.isEmpty ? '' : ': $retType'}';
  }

  String createLinkedDescription() {
    StringBuffer buf = new StringBuffer();
    if (_func.isStatic) {
      buf.write('static ');
    }
    buf.write(createLinkedReturnTypeName(new ElementType(_func.type, library)));
    buf.write(
        ' ${_func.name}($linkedParams)');
    return buf.toString();
  }

  String get linkedReturnType {
    return createLinkedReturnTypeName(new ElementType(_func.type, library));
  }
}

class Typedef extends ModelElement {
  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  Typedef(FunctionTypeAliasElement element, Library library)
      : super(element, library);

  // TODO: will the superclass version work?
//  String get linkedName {
//    StringBuffer buf = new StringBuffer();
//    buf.write(_typedef.name);
//    if (!_typedef.typeParameters.isEmpty) {
//      buf.write('<');
//      for (int i = 0; i < _typedef.typeParameters.length; i++) {
//        if (i > 0) {
//          buf.write(', ');
//        }
//        // TODO link this name
//        buf.write(_typedef.typeParameters[i].name);
//      }
//      buf.write('>');
//    }
//    return buf.toString();
//  }

  String get linkedReturnType {
    return createLinkedReturnTypeName(new ElementType(_typedef.type, library));
  }

  String get _href => '${library.name}.html#$name';

}

class Field extends ModelElement {
  FieldElement get _field => (element as FieldElement);

  Field(FieldElement element, Library library) : super(element, library);

  bool get isFinal => _field.isFinal;

  bool get isConst => _field.isConst;

  String get _href {
    if (element.enclosingElement is ClassElement) {
      return '/${library.name}/${element.enclosingElement.name}.html#$name';
    } else if (element.enclosingElement is LibraryElement) {
      return '/${library.name}.html#$name';
    } else {
      throw new StateError('$name is not in a class or library, instead a ${element.enclosingElement}');
    }
  }
}

class Constructor extends ModelElement {
  ConstructorElement get _constructor => (element as ConstructorElement);

  Constructor(ConstructorElement element, Library library, [String source])
      : super(element, library, source);

  String createLinkedSummary() {
    return '${linkedName} ($linkedParams)';
  }
}

class Method extends ModelElement {
//  MethodElement get _method => (element as MethodElement);

  Method(MethodElement element, Library library, [String source])
      : super(element, library, source);

  Method getOverriddenElement() {
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in getAllSupertypes(parent)) {
      if (t.getMethod(element.name) != null) {
        return new Method(t.getMethod(element.name), library);
      }
    }
    return null;
  }
}

/// Getters and setters.
class Accessor extends ModelElement {
  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);

  Accessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  bool get isGetter => _accessor.isGetter;
}

/// Top-level variables. But also picks up getters and setters?
class Variable extends ModelElement {
  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);

  Variable(TopLevelVariableElement element, Library library)
      : super(element, library);

  bool get isFinal => _variable.isFinal;

  bool get isConst => _variable.isConst;

  // TODO: is this correct? this handles const, final, getters, and setters
  String get linkedReturnType {
    if (hasGetter) {
      return createLinkedTypeName(new ElementType(_variable.getter.returnType, library));
    } else {
      return createLinkedTypeName(new ElementType(_variable.setter.parameters.first.type, library));
    }
  }

  bool get hasGetter => _variable.getter != null;

  bool get hasSetter => _variable.setter != null;
}

class Parameter extends ModelElement {
  Parameter(ParameterElement element, Library library)
      : super(element, library);

  ParameterElement get _parameter => element as ParameterElement;

  ElementType get type => new ElementType(_parameter.type,
      new Library(_parameter.type.element.library, package));

  bool get isOptional => _parameter.parameterKind.isOptional;

  bool get isOptionalPositional => _parameter.parameterKind == ParameterKind.POSITIONAL;

  bool get isOptionalNamed => _parameter.parameterKind == ParameterKind.NAMED;

  bool get hasDefaultValue {
    return _parameter.defaultValueRange != null &&
           _parameter.defaultValueRange != SourceRange.EMPTY;
  }

  String get defaultValue {
    if (!hasDefaultValue) return null;
    SourceRange range = _parameter.defaultValueRange;
    return _parameter.source.contents.data.substring(range.offset, range.end);
  }

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

  // TODO: Should this be the program's library and package, or the
  // library and package of the actual _type ?
  ElementType(this._type, this.library);

  String toString() => "$_type";

  bool get isDynamic => _type.isDynamic;

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
    // TODO: this is probably a bug. e and element are probably not the same?
    return (new ModelElement.from(e, element.library));
  }
  List<ElementType> get typeArguments =>
      (_type as ParameterizedType).typeArguments
          .map((f) => new ElementType(f, library))
          .toList();
}

