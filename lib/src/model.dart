// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code
library dartdoc.models;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:analyzer/src/generated/utilities_dart.dart' show ParameterKind;
import 'package:quiver/core.dart';

import 'html_utils.dart';
import 'model_utils.dart';
import 'package_meta.dart';
import '../markdown_processor.dart';

final Map<Class, List<Class>> _implementors = new Map();

void _addToImplementors(Class c) {
  _implementors.putIfAbsent(c, () => []);

  void _checkAndAddClass(Class key, Class implClass) {
    _implementors.putIfAbsent(key, () => []);
    List list = _implementors[key];

    if (!list.contains(implClass)) {
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

abstract class ModelElement {
  final Element element;
  final Library library;

  ElementType _modelType;
  String _documentation;
  String _documentationAsHtml;

  List _parameters;

  ModelElement(this.element, this.library);

  factory ModelElement.from(Element e, Library library) {
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
    if (e is PropertyAccessorElement) {
      return new Accessor(e, library);
    }
    if (e is TopLevelVariableElement) {
      return new TopLevelVariable(e, library);
    }
    if (e is TypeParameterElement) {
      return new TypeParameter(e, library);
    }
    if (e is DynamicElementImpl) {
      return new Dynamic(e, library);
    }
    if (e is ParameterElement) {
      return new Parameter(e, library);
    }
    throw "Unknown type ${e.runtimeType}";
  }

  String get documentation {
    if (_documentation != null) {
      return _documentation;
    }

    if (element == null) {
      return null;
    }

    _documentation = element.computeDocumentationComment();

    if (_documentation == null && canOverride()) {
      var overrideElement = overriddenElement;
      if (overrideElement != null) {
        _documentation = overrideElement.documentation;
      }
    }

    _documentation = stripComments(_documentation);

    return _documentation;
  }

  bool get hasDocumentation =>
      documentation != null && documentation.isNotEmpty;

  String get documentationAsHtml {
    if (_documentationAsHtml != null) return _documentationAsHtml;

    _documentationAsHtml = processDocsAsMarkdown(this);

    return _documentationAsHtml;
  }

  String get oneLineDoc => oneLiner(this);

  String get htmlId => name;

  String toString() => '$runtimeType $name';

  List<String> get annotations {
    // Check https://code.google.com/p/dart/issues/detail?id=23181
    // If that is fixed, this code might get a lot easier
    if (element.node != null && element.node is AnnotatedNode) {
      return (element.node as AnnotatedNode).metadata.map((Annotation a) {
        var annotationString = a.toSource().substring(1); // remove the @
        var e = a.element;
        if (e != null && (e is ConstructorElement)) {
          var me = new ModelElement.from(
              e.enclosingElement, new Library(e.library, package));
          if (me.href != null) {
            return annotationString.replaceAll(
                me.name, '<a href="${me.href}">${me.name}</a>');
          }
        }
        return annotationString;
      }).toList(growable: false);
    } else {
      return element.metadata.map((ElementAnnotation a) {
        // TODO link to the element's href
        return a.element.name;
      }).toList(growable: false);
    }
  }

  bool get hasAnnotations => annotations.isNotEmpty;

  bool canOverride() => element is ClassMemberElement;

  ModelElement get overriddenElement => null;

  String get name => element.name;

  bool get canHaveParameters =>
      element is ExecutableElement || element is FunctionTypeAliasElement;

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

  bool get hasParameters => parameters.isNotEmpty;

  bool get isExecutable => element is ExecutableElement;

  bool get isPropertyInducer => element is PropertyInducingElement;

  bool get isPropertyAccessor => element is PropertyAccessorElement;

  bool get isLocalElement => element is LocalElement;

  bool get isAsynchronous =>
      isExecutable && (element as ExecutableElement).isAsynchronous;

  bool get isStatic {
    if (isPropertyInducer) {
      return (element as PropertyInducingElement).isStatic;
    }
    return false;
  }

  bool get isFinal => false;

  bool get isConst => false;

  bool get isDeprecated => element.metadata.any((a) => a.isDeprecated);

  ElementType get modelType => _modelType;

  /// Returns the [ModelElement] that encloses this.
  ModelElement get enclosingElement {
    // A class's enclosing element is a library, and there isn't a
    // modelelement for a library.
    if (element.enclosingElement != null &&
        element.enclosingElement is ClassElement) {
      return new ModelElement.from(element.enclosingElement, library);
    } else {
      return null;
    }
  }

  Package get package =>
      (this is Library) ? (this as Library).package : this.library.package;

  String get linkedName {
    if (!package.isDocumented(this)) {
      return htmlEscape(name);
    }
    if (name.startsWith('_')) {
      return htmlEscape(name);
    }
    Class c = enclosingElement;
    if (c != null && c.name.startsWith('_')) {
      return '${c.name}.${htmlEscape(name)}';
    }

    return '<a href="${href}">$name</a>';
  }

  String get href {
    if (!package.isDocumented(this)) {
      return null;
    }
    return _href;
  }

  String get _href;

  String linkedParams(
      {bool showMetadata: true, bool showNames: true, String separator: ', '}) {
    String renderParam(Parameter p) {
      StringBuffer buf = new StringBuffer();
      buf.write('<span class="parameter" id="${p.htmlId}">');
      if (showMetadata && p.hasAnnotations) {
        buf.write('<ol class="comma-separated metadata-annotations">');
        p.annotations.forEach((String annotation) {
          buf.write('<li class="metadata-annotation">@$annotation</li>');
        });
        buf.write('</ol> ');
      }
      if (p.modelType.isFunctionType) {
        buf.write(
            '<span class="type-annotation">${(p.modelType.element as Typedef).linkedReturnType}</span>');
        if (showNames) {
          buf.write(' <span class="parameter-name">${p.name}</span>');
        }
        buf.write('(');
        buf.write(p.modelType.element.linkedParams(
            showNames: showNames, showMetadata: showMetadata));
        buf.write(')');
      } else if (p.modelType != null && p.modelType.element != null) {
        var mt = p.modelType;
        String typeName = "";
        if (mt != null && !mt.isDynamic) {
          typeName = mt.linkedName;
        }
        if (typeName.isNotEmpty) {
          buf.write('<span class="type-annotation">$typeName</span> ');
        }
        if (showNames) {
          buf.write('<span class="parameter-name">${p.name}</span>');
        }
      }

      if (p.hasDefaultValue) {
        if (p.isOptionalNamed) {
          buf.write(': ');
        } else {
          buf.write(' = ');
        }
        buf.write('<span class="default-value">${p.defaultValue}</span>');
      }
      buf.write('</span>');
      return buf.toString();
    }

    String renderParams(Iterable<Parameter> params,
        {String open: '', String close: ''}) {
      return '$open${params.map(renderParam).join(separator)}$close';
    }

    Iterable<Parameter> requiredParams =
        parameters.where((Parameter p) => !p.isOptional);
    Iterable<Parameter> positionalParams =
        parameters.where((Parameter p) => p.isOptionalPositional);
    Iterable<Parameter> namedParams =
        parameters.where((Parameter p) => p.isOptionalNamed);

    List<String> fragments = [];
    if (requiredParams.isNotEmpty) {
      fragments.add(renderParams(requiredParams));
    }
    if (positionalParams.isNotEmpty) {
      fragments.add(renderParams(positionalParams, open: '[', close: ']'));
    }
    if (namedParams.isNotEmpty) {
      fragments.add(renderParams(namedParams, open: '{', close: '}'));
    }

    return fragments.join(separator);
  }

  String get linkedParamsNoMetadata => linkedParams(showMetadata: false);

  /// End each parameter with `<br>`
  String get linkedParamsLines {
    return linkedParams(separator: ',<br>');
  }
}

class Dynamic extends ModelElement {
  Dynamic(DynamicElementImpl element, Library library)
      : super(element, library);

  String get _href => throw new StateError('dynamic should not have an href');
}

class Package {
  final List<Library> _libraries = [];
  final PackageMeta packageMeta;

  String get name => packageMeta.name;

  String get version => packageMeta.version;

  bool get hasDocumentation => documentationFile != null;

  FileContents get documentationFile => packageMeta.getReadmeContents();

  // TODO: Clients should use [documentationFile] so they can act differently on
  // plain text or markdown.
  String get documentation =>
      hasDocumentation ? documentationFile.contents : null;

  String get documentationAsHtml => renderMarkdownToHtml(documentation);

  String get oneLineDoc => oneLinerWithoutReferences(documentation);

  List<Library> get libraries => _libraries;

  Package(Iterable<LibraryElement> libraryElements, this.packageMeta) {
    libraryElements.forEach((element) {
      var lib = new Library(element, this);
      Library._libraryMap.putIfAbsent(lib.name, () => lib);
      _libraries.add(lib);
    });
    _libraries.forEach((library) {
      library._allClasses.forEach(_addToImplementors);
    });
  }

  /// Does this package represent the SDK?
  bool get isSdk => packageMeta.isSdk;

  String toString() => isSdk ? 'SDK' : 'Package $name';

  bool isDocumented(ModelElement e) {
    if (e is Library) {
      return _libraries.any((lib) => lib.element == e.element);
    }

    Element el;
    if (e.element is ClassMemberElement || e.element is ExecutableElement) {
      el = e.element.enclosingElement;
    } else if (e.element is TopLevelVariableElement) {
      TopLevelVariableElement variable = (e.element as TopLevelVariableElement);
      if (variable.getter != null) el = variable.getter;
      else if (variable.setter != null) el = variable.setter;
      else el = variable;
    } else {
      el = e.element;
    }
    return _libraries.any((lib) => lib.hasInNamespace(el));
  }

  String get href => 'index.html';
}

class Library extends ModelElement {
  static final Map<String, Library> _libraryMap = <String, Library>{};

  final Package package;
  List<Class> _classes;
  List<Class> _enums;
  List<ModelFunction> _functions;
  List<Typedef> _typeDefs;
  List<TopLevelVariable> _variables;
  Iterable<Element> _nameSpaceElements;
  Namespace _namespace;
  String _name;

  LibraryElement get _library => (element as LibraryElement);

  Library._(LibraryElement element, this.package) : super(element, null);

  factory Library(LibraryElement element, Package package) {
    var key = element == null ? 'null' : element.name;

    if (key.isEmpty) {
      var name = element.definingCompilationUnit.name;
      key = name.substring(0, name.length - '.dart'.length);
    }

    if (_libraryMap.containsKey(key)) {
      return _libraryMap[key];
    }
    var library = new Library._(element, package);
    _libraryMap[key] = library;

    return library;
  }

  Library get library => this;

  Iterable<Element> get _exportedNamespace {
    if (_nameSpaceElements == null) _buildExportedNamespace();
    return _nameSpaceElements;
  }

  _buildExportedNamespace() {
    _namespace =
        new NamespaceBuilder().createExportNamespaceForLibrary(_library);
    _nameSpaceElements = _namespace.definedNames.values;
  }

  bool hasInNamespace(Element element) {
    if (_namespace == null) _buildExportedNamespace();
    var e = _namespace.get(element.name);
    return e == element;
  }

  String get name {
    if (_name != null) return _name;

    // handle the case of an anonymous library
    if (element.name == null || element.name.isEmpty) {
      _name = _library.definingCompilationUnit.name;
      if (_name.endsWith('.dart')) {
        _name = _name.substring(0, _name.length - '.dart'.length);
      }
    } else {
      _name = element.name;
    }

    // calculate this once, instead on every invocation of name getter
    var source = _library.definingCompilationUnit.source;
    _name = source.isInSystemLibrary ? source.encoding : _name;

    return _name;
  }

  String get path => _library.definingCompilationUnit.name;

  String get nameForFile => name.replaceAll(':', '-');

  bool get isInSdk => _library.isInSdk;

  List<TopLevelVariable> _getVariables() {
    if (_variables != null) return _variables;

    Set<TopLevelVariableElement> elements = new Set();
    elements.addAll(_library.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.topLevelVariables);
    }
    _exportedNamespace.forEach((element) {
      if (element is PropertyAccessorElement) elements.add(element.variable);
    });
    elements..removeWhere(isPrivate);
    _variables = elements
        .map((e) => new TopLevelVariable(e, this))
        .toList(growable: false);

    return _variables;
  }

  bool get hasProperties => _getVariables().any((v) => !v.isConst);

  /// All variables ("properties") except constants.
  List<TopLevelVariable> get properties {
    return _getVariables().where((v) => !v.isConst).toList(growable: false);
  }

  bool get hasConstants => _getVariables().any((v) => v.isConst);

  List<TopLevelVariable> get constants {
    return _getVariables().where((v) => v.isConst).toList(growable: false);
  }

  bool get hasEnums => enums.isNotEmpty;

  List<Class> get enums {
    if (_enums != null) return _enums;

    List<ClassElement> enumClasses = [];
    enumClasses.addAll(_exportedNamespace
        .where((element) => element is ClassElement && element.isEnum));
    _enums = enumClasses
        .where(isPublic)
        .map((e) => new Enum(e, this))
        .toList(growable: false);
    return _enums;
  }

  Class getClassByName(String name) {
    return _allClasses.firstWhere((it) => it.name == name, orElse: () => null);
  }

  bool get hasTypedefs => typedefs.isNotEmpty;

  List<Typedef> get typedefs {
    if (_typeDefs != null) return _typeDefs;

    Set<FunctionTypeAliasElement> elements = new Set();
    elements.addAll(_library.definingCompilationUnit.functionTypeAliases);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.functionTypeAliases);
    }

    elements.addAll(_exportedNamespace
        .where((element) => element is FunctionTypeAliasElement));
    elements..removeWhere(isPrivate);
    _typeDefs = elements.map((e) => new Typedef(e, this)).toList();
    return _typeDefs;
  }

  bool get hasFunctions => functions.isNotEmpty;

  List<ModelFunction> get functions {
    if (_functions != null) return _functions;

    Set<FunctionElement> elements = new Set();
    elements.addAll(_library.definingCompilationUnit.functions);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.functions);
    }
    elements.addAll(
        _exportedNamespace.where((element) => element is FunctionElement));

    elements..removeWhere(isPrivate);
    _functions = elements.map((e) {
      return new ModelFunction(e, this);
    }).toList(growable: false);
    return _functions;
  }

  List<Class> get _allClasses {
    if (_classes != null) return _classes;

    Set<ClassElement> types = new Set();
    types.addAll(_library.definingCompilationUnit.types);
    for (CompilationUnitElement cu in _library.parts) {
      types.addAll(cu.types);
    }
    for (LibraryElement le in _library.exportedLibraries) {
      types.addAll(le.definingCompilationUnit.types
          .where((t) => _exportedNamespace.contains(t.name))
          .toList());
    }

    types.addAll(_exportedNamespace
        .where((element) => element is ClassElement && !element.isEnum));

    _classes = types
        .where(isPublic)
        .map((e) => new Class(e, this))
        .toList(growable: true);

    return _classes;
  }

  /// if SDK, return all classes
  /// if package, return classes that are not [Error] or [Exception]
  List<Class> get classes {
    if (package.isSdk) {
      return _allClasses;
    }
    return _allClasses.where((c) => !c.isErrorOrException).toList(
        growable: false);
  }

  List<Class> get allClasses => _allClasses;

  bool get hasClasses => classes.isNotEmpty;

  bool get hasExceptions => _allClasses.any((c) => c.isErrorOrException);

  List<Class> get exceptions {
    return _allClasses.where((c) => c.isErrorOrException).toList(
        growable: false);
  }

  @override
  String get _href => '$nameForFile/index.html';
}

class Class extends ModelElement {
  List<ElementType> _mixins;
  ElementType _supertype;
  List<ElementType> _interfaces;
  List<Constructor> _constructors;
  List<Method> _allMethods;
  List<Operator> _operators;
  List<Operator> _inheritedOperators;
  List<Method> _inheritedMethods;
  List<Method> _staticMethods;
  List<Method> _instanceMethods;
  List<Field> _fields;
  List<Field> _staticFields;
  List<Field> _constants;
  List<Field> _instanceFields;
  List<Field> _inheritedProperties;

  ClassElement get _cls => (element as ClassElement);

  Class(ClassElement element, Library library) : super(element, library) {
    var p = library.package;
    _modelType = new ElementType(_cls.type, this);

    _mixins = _cls.mixins.map((f) {
      var lib = new Library(f.element.library, p);
      var t = new ElementType(f, new ModelElement.from(f.element, lib));
      var exclude = t.element.element.isPrivate;
      if (exclude) {
        return null;
      } else {
        return t;
      }
    }).where((mixin) => mixin != null).toList(growable: false);

    if (_cls.supertype != null && _cls.supertype.element.supertype != null) {
      var lib = new Library(_cls.supertype.element.library, p);
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

    _interfaces = _cls.interfaces.map((f) {
      var lib = new Library(f.element.library, p);
      var t = new ElementType(f, new ModelElement.from(f.element, lib));
      var exclude = t.element.element.isPrivate;
      if (exclude) {
        return null;
      } else {
        return t;
      }
    }).where((it) => it != null).toList(growable: false);
  }

  String get nameWithGenerics {
    if (!modelType.isParameterizedType) return name;
    return '$name&lt${_typeParameters.map((t) => t.name).join(', ')}&gt';
  }

  List<TypeParameter> get _typeParameters => _cls.typeParameters.map((f) {
    var lib = new Library(f.enclosingElement.library, package);
    return new TypeParameter(f, lib);
  }).toList();

  String get kind => 'class';

  String get fileName => "${name}_class.html";

  bool get isAbstract => _cls.isAbstract;

  bool get hasSupertype => supertype != null;

  bool get hasModifiers => hasMixins ||
      hasAnnotations ||
      hasInterfaces ||
      hasSupertype ||
      hasImplementors;

  ElementType get supertype => _supertype;

  List<ElementType> get superChain {
    List<ElementType> typeChain = [];
    var parent = _supertype;
    while (parent != null) {
      typeChain.add(parent);
      parent = (parent.element as Class)._supertype;
    }
    return typeChain;
  }

  List<ElementType> get mixins => _mixins;

  bool get hasMixins => mixins.isNotEmpty;

  List<ElementType> get interfaces => _interfaces;

  bool get hasInterfaces => interfaces.isNotEmpty;

  /// Returns all the implementors of the class specified.
  List<Class> get implementors =>
      _implementors[this] != null ? _implementors[this] : new List(0);

  bool get hasImplementors => implementors.isNotEmpty;

  List<Field> get _allFields {
    if (_fields != null) return _fields;

    _fields = _cls.fields
        .where(isPublic)
        .map((e) => new Field(e, library))
        .toList(growable: false);

    return _fields;
  }

  List<Field> get staticProperties {
    if (_staticFields != null) return _staticFields;
    _staticFields = _allFields
        .where((f) => f.isStatic)
        .where((f) => !f.isConst)
        .toList(growable: false);
    return _staticFields;
  }

  List<Field> get instanceProperties {
    if (_instanceFields != null) return _instanceFields;
    _instanceFields =
        _allFields.where((f) => !f.isStatic).toList(growable: false);
    return _instanceFields;
  }

  List<Field> get constants {
    if (_constants != null) return _constants;
    _constants = _allFields.where((f) => f.isConst).toList(growable: false);
    return _constants;
  }

  bool get hasConstants => constants.isNotEmpty;

  bool get hasStaticProperties => staticProperties.isNotEmpty;

  bool get hasInstanceProperties => instanceProperties.isNotEmpty;

  List<Constructor> get constructors {
    if (_constructors != null) return _constructors;

    _constructors = _cls.constructors.where(isPublic).map((e) {
      return new Constructor(e, library);
    }).toList(growable: true);

    return _constructors;
  }

  bool get hasConstructors => constructors.isNotEmpty;

  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _cls.methods.where(isPublic).map((e) {
      if (!e.isOperator) {
        return new Method(e, library);
      } else {
        return new Operator(e, library);
      }
    }).toList(growable: false);

    return _allMethods;
  }

  List<Operator> get operators {
    if (_operators != null) return _operators;

    _operators = _methods.where((m) => m.isOperator).toList(growable: false);

    return _operators;
  }

  bool get hasOperators =>
      operators.isNotEmpty || inheritedOperators.isNotEmpty;

  List<Method> get staticMethods {
    if (_staticMethods != null) return _staticMethods;

    _staticMethods = _methods.where((m) => m.isStatic).toList(growable: false);

    return _staticMethods;
  }

  bool get hasStaticMethods => staticMethods.isNotEmpty;

  List<Method> get instanceMethods {
    if (_instanceMethods != null) return _instanceMethods;

    _instanceMethods = _methods
        .where((m) => !m.isStatic && !m.isOperator)
        .toList(growable: false);

    return _instanceMethods;
  }

  bool get hasInstanceMethods => instanceMethods.isNotEmpty;

  List<Method> get inheritedMethods {
    if (_inheritedMethods != null) return _inheritedMethods;
    InheritanceManager manager = new InheritanceManager(element.library);
    MemberMap cmap = manager.getMapOfMembersInheritedFromClasses(element);
    MemberMap imap = manager.getMapOfMembersInheritedFromInterfaces(element);
    _methods.forEach((method) {
      cmap.remove(method.name);
      imap.remove(method.name);
    });
    _inheritedMethods = [];
    var vs = [];

    for (var i = 0; i < cmap.size; i++) {
      vs.add(cmap.getValue(i));
    }

    for (var i = 0; i < imap.size; i++) {
      vs.add(imap.getValue(i));
    }

    vs = vs.toSet().toList();

    for (var value in vs) {
      if (value != null &&
          value is MethodElement &&
          !value.isPrivate &&
          !value.isOperator &&
          value.enclosingElement != null &&
          value.enclosingElement.name != 'Object') {
        var lib = value.library == library.element
            ? library
            : new Library(value.library, package);
        _inheritedMethods.add(new Method.inherited(value, lib));
      }
    }

    return _inheritedMethods;
  }

  List<Method> get inheritedOperators {
    if (_inheritedOperators != null) return _inheritedOperators;
    InheritanceManager manager = new InheritanceManager(element.library);
    MemberMap cmap = manager.getMapOfMembersInheritedFromClasses(element);
    MemberMap imap = manager.getMapOfMembersInheritedFromInterfaces(element);
    operators.forEach((operator) {
      cmap.remove(operator.element.name);
      imap.remove(operator.element.name);
    });
    _inheritedOperators = [];
    var vs = {};

    bool _isInheritedOperator(ExecutableElement value) {
      if (value != null &&
          value is MethodElement &&
          !value.isPrivate &&
          value.isOperator &&
          value.enclosingElement != null &&
          value.enclosingElement.name != 'Object') {
        return true;
      }
      return false;
    }

    for (var i = 0; i < imap.size; i++) {
      var value = imap.getValue(i);
      if (_isInheritedOperator(value)) {
        vs.putIfAbsent(value.name, () => value);
      }
    }

    for (var i = 0; i < cmap.size; i++) {
      var value = cmap.getValue(i);
      if (_isInheritedOperator(value)) {
        vs.putIfAbsent(value.name, () => value);
      }
    }

    for (var value in vs.values) {
      var lib = value.library == library.element
          ? library
          : new Library(value.library, package);
      _inheritedOperators.add(new Operator.inherited(value, lib));
    }

    return _inheritedOperators;
  }

  bool get hasInheritedMethods => inheritedMethods.isNotEmpty;

  List<Field> get inheritedProperties {
    if (_inheritedProperties != null) return _inheritedProperties;
    InheritanceManager manager = new InheritanceManager(element.library);
    MemberMap cmap = manager.getMapOfMembersInheritedFromClasses(element);
    MemberMap imap = manager.getMapOfMembersInheritedFromInterfaces(element);
    _inheritedProperties = [];
    var vs = [];
    for (var i = 0; i < cmap.size; i++) {
      vs.add(cmap.getValue(i));
    }

    for (var i = 0; i < imap.size; i++) {
      vs.add(imap.getValue(i));
    }

    vs = vs.toSet().toList();

    vs.removeWhere((it) => instanceProperties.any((i) => it.name == i.name));

    for (var value in vs) {
      if (value != null &&
          value is PropertyAccessorElement &&
          !value.isPrivate &&
          value.enclosingElement != null &&
          value.enclosingElement.name != 'Object') {
        var e = value.variable;
        if (_inheritedProperties.any((f) => f.element == e)) {
          continue;
        }
        var lib = value.library == library.element
            ? library
            : new Library(value.library, package);
        _inheritedProperties.add(new Field.inherited(e, lib));
      }
    }
    return _inheritedProperties;
  }

  bool get hasMethods =>
      instanceMethods.isNotEmpty || inheritedMethods.isNotEmpty;

  bool get hasProperties =>
      inheritedProperties.isNotEmpty || instanceProperties.isNotEmpty;

  bool get isErrorOrException {
    bool _doCheck(InterfaceType type) {
      return (type.element.library.isDartCore &&
          (type.name == 'Exception' || type.name == 'Error'));
    }

    return _cls.allSupertypes.any(_doCheck);
  }

  bool operator ==(o) => o is Class &&
      name == o.name &&
      o.library.name == library.name &&
      o.library.package.name == library.package.name;

  // a stronger hash?
  int get hashCode => hash3(
      name.hashCode, library.name.hashCode, library.package.name.hashCode);

  @override
  String get _href => '${library.nameForFile}/$fileName';
}

class Enum extends Class {
  List<EnumField> _constants;

  Enum(ClassElement element, Library library) : super(element, library);

  @override
  String get kind => 'enum';

  @override
  List<EnumField> get constants {
    if (_constants != null) return _constants;

    // is there a better way to get the index during a map() ?
    var index = 0;

    _constants = _cls.fields
        .where(isPublic)
        .where((f) => f.isConst)
        .map((field) => new EnumField(index++, field, library))
        .toList(growable: false);

    return _constants;
  }
}

class ModelFunction extends ModelElement {
  ModelFunction(FunctionElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_func.type, this);
  }

  FunctionElement get _func => (element as FunctionElement);

  bool get isStatic => _func.isStatic;

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  String get fileName => "$name.html";

  @override
  String get _href => '${library.nameForFile}/$fileName';
}

class Typedef extends ModelElement {
  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  Typedef(FunctionTypeAliasElement element, Library library)
      : super(element, library) {
    if (element.type != null) {
      _modelType = new ElementType(element.type, this);
    }
  }

  String get fileName => '$name.html';

  String get linkedReturnType => modelType != null
      ? modelType.createLinkedReturnTypeName()
      : _typedef.returnType.name;

  String get _href => '${library.nameForFile}/$fileName';
}

class Field extends ModelElement {
  String _constantValue;
  bool _isInherited = false;

  FieldElement get _field => (element as FieldElement);

  Field(FieldElement element, Library library) : super(element, library) {
    _setModelType();
  }

  Field.inherited(FieldElement element, Library library)
      : super(element, library) {
    _isInherited = true;
    _setModelType();
  }

  void _setModelType() {
    if (hasGetter) {
      var t = _field.getter.returnType;
      var lib = new Library(t.element.library, package);
      _modelType = new ElementType(t, new ModelElement.from(t.element, lib));
    } else {
      var s = _field.setter.parameters.first.type;
      var lib = new Library(s.element.library, package);
      _modelType = new ElementType(s, new ModelElement.from(s.element, lib));
    }
  }

  bool get isFinal => _field.isFinal;

  bool get isConst => _field.isConst;

  String get linkedReturnType => modelType.linkedName;

  String get constantValue {
    if (_constantValue != null) return _constantValue;

    if (_field.node == null) return null;
    var v = _field.node.toSource();
    if (v == null) return null;
    var string = v.substring(v.indexOf('=') + 1, v.length).trim();
    _constantValue = string.replaceAll(modelType.name, modelType.linkedName);

    return _constantValue;
  }

  bool get hasGetter => _field.getter != null;

  bool get hasSetter => _field.setter != null;

  bool get readOnly => hasGetter && !hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;

  bool get readWrite => hasGetter && hasSetter;

  String get typeName => "property";

  bool get isInherited => _isInherited;

  String get _href {
    if (element.enclosingElement is ClassElement) {
      return '${library.nameForFile}/${element.enclosingElement.name}/$name.html';
    } else if (element.enclosingElement is LibraryElement) {
      return '${library.nameForFile}/$name.html';
    } else {
      throw new StateError(
          '$name is not in a class or library, instead a ${element.enclosingElement}');
    }
  }
}

/// Enum's fields are virtual, so we do a little work to create
/// usable values for the docs.
class EnumField extends Field {
  final int index;

  EnumField(this.index, FieldElement element, Library library)
      : super(element, library);

  @override
  String get constantValue {
    if (name == 'values') {
      return 'const List&lt;${_field.enclosingElement.name}&gt;';
    } else {
      return 'const ${_field.enclosingElement.name}($index)';
    }
  }

  @override
  String get documentation {
    if (name == 'values') {
      return 'A constant List of the values in this enum, in order of their declaration';
    } else {
      return super.documentation;
    }
  }

  @override
  String get linkedName => name;
}

class Constructor extends ModelElement {
  ConstructorElement get _constructor => (element as ConstructorElement);

  Constructor(ConstructorElement element, Library library)
      : super(element, library);

  @override
  String get _href =>
      '${library.nameForFile}/${_constructor.enclosingElement.name}/$name.html';

  bool get isConst => _constructor.isConst;

  @override
  String get name {
    String constructorName = element.name;
    Class c = enclosingElement;
    if (constructorName.isEmpty) {
      return c.name;
    } else {
      return '${c.name}.$constructorName';
    }
  }
}

class Method extends ModelElement {
  bool _isInherited = false;

  MethodElement get _method => (element as MethodElement);

  Method(MethodElement element, Library library) : super(element, library) {
    _modelType = new ElementType(_method.type, this);
  }

  Method.inherited(MethodElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_method.type, this);
    _isInherited = true;
  }

  Method get overriddenElement {
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in getAllSupertypes(parent)) {
      if (t.getMethod(element.name) != null) {
        return new Method(t.getMethod(element.name), library);
      }
    }
    return null;
  }

  @override
  bool get isStatic => _method.isStatic;

  bool get isOperator => false;

  String get typeName => 'method';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  String get fileName => "${name}.html";

  @override
  String get _href =>
      '${library.nameForFile}/${_method.enclosingElement.name}/${fileName}';

  bool get isInherited => _isInherited;
}

class Operator extends Method {
  Operator(MethodElement element, Library library) : super(element, library);

  Operator.inherited(MethodElement element, Library library)
      : super(element, library) {
    _isInherited = true;
  }

  bool get isOperator => true;

  String get typeName => 'operator';

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
  String get name {
    return 'operator ${super.name}';
  }

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
}

/// Getters and setters.
class Accessor extends ModelElement {
  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);

  Accessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  bool get isGetter => _accessor.isGetter;

  @override
  String get _href =>
      '${library.nameForFile}/${_accessor.enclosingElement.name}/${name}.html';
}

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement {
  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);

  TopLevelVariable(TopLevelVariableElement element, Library library)
      : super(element, library) {
    if (hasGetter) {
      var t = _variable.getter.returnType;
      var lib = new Library(t.element.library,
          package); //_getLibraryFor(t.element.library, package);
      _modelType = new ElementType(t, new ModelElement.from(t.element, lib));
    } else {
      var s = _variable.setter.parameters.first.type;
      var lib = new Library(s.element.library, package);
      _modelType = new ElementType(s, new ModelElement.from(s.element, lib));
    }
  }

  bool get isFinal => _variable.isFinal;

  bool get isConst => _variable.isConst;

  bool get readOnly => hasGetter && !hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;

  bool get readWrite => hasGetter && hasSetter;

  String get linkedReturnType => modelType.linkedName;

  String get constantValue {
    var v = (_variable as ConstTopLevelVariableElementImpl).node.toSource();
    if (v == null) return '';
    var string = v.substring(v.indexOf('=') + 1, v.length).trim();
    return string.replaceAll(modelType.name, modelType.linkedName);
  }

  bool get hasGetter => _variable.getter != null;

  bool get hasSetter => _variable.setter != null;

  @override
  String get _href => '${library.nameForFile}/${name}.html';
}

class Parameter extends ModelElement {
  Parameter(ParameterElement element, Library library)
      : super(element, library) {
    var t = _parameter.type;
    _modelType = new ElementType(t, new ModelElement.from(
        t.element, new Library(t.element.library, library.package)));
  }

  ParameterElement get _parameter => element as ParameterElement;

  bool get isOptional => _parameter.parameterKind.isOptional;

  bool get isOptionalPositional =>
      _parameter.parameterKind == ParameterKind.POSITIONAL;

  bool get isOptionalNamed => _parameter.parameterKind == ParameterKind.NAMED;

  bool get hasDefaultValue {
    return _parameter.defaultValueCode != null &&
        _parameter.defaultValueCode.isNotEmpty;
  }

  String get defaultValue {
    if (!hasDefaultValue) return null;
    return _parameter.defaultValueCode;
  }

  String toString() => element.name;

  String get htmlId => '${_parameter.enclosingElement.name}-param-${name}';

  @override
  String get _href {
    var p = _parameter.enclosingElement;

    if (p is FunctionElement) {
      return '${library.nameForFile}/${p.name}.html';
    } else {
      // TODO: why is this logic here?
      var name = Operator.friendlyNames.containsKey(p.name)
          ? Operator.friendlyNames[p.name]
          : p.name;
      return '${library.nameForFile}/${p.enclosingElement.name}/' +
          '${name}.html#${htmlId}';
    }
  }
}

class TypeParameter extends ModelElement {
  TypeParameter(TypeParameterElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_typeParameter.type, this);
  }

  TypeParameterElement get _typeParameter => element as TypeParameterElement;

  String toString() => element.name;

  String get name {
    var bound = _typeParameter.bound;
    return bound != null
        ? '${_typeParameter.name} extends ${bound.name}'
        : _typeParameter.name;
  }

  @override
  String get _href =>
      '${library.nameForFile}/${_typeParameter.enclosingElement.name}/$name';
}

class ElementType {
  DartType _type;
  ModelElement _element;
  String _linkedName;

  ElementType(this._type, this._element);

  String toString() => "$_type";

  bool get isDynamic => _type.isDynamic;

  bool get isParameterType => (_type is TypeParameterType);

  bool get isFunctionType => (_type is FunctionType);

  ModelElement get element => _element;

  String get name => _type.name;

  // TODO: this is probably a bug. Apparently, EVERYTHING is a parameterized type?
  bool get isParameterizedType => (_type is ParameterizedType) &&
      (_type as ParameterizedType).typeArguments.isNotEmpty;

  String get _returnTypeName => (_type as FunctionType).returnType.name;

  ElementType get _returnType {
    var rt = (_type as FunctionType).returnType;
    return new ElementType(rt, new ModelElement.from(
        rt.element, new Library(rt.element.library, _element.package)));
  }
  ModelElement get returnElement {
    Element e = (_type as FunctionType).returnType.element;
    if (e == null) {
      return null;
    }
    Library lib = new Library(e.library, _element.package);
    return (new ModelElement.from(e, lib));
  }

  List<ElementType> get typeArguments =>
      (_type as ParameterizedType).typeArguments.map((f) {
    var lib = new Library(f.element.library, _element.package);
    return new ElementType(f, new ModelElement.from(f.element, lib));
  }).toList();

  String get linkedName {
    if (_linkedName != null) return _linkedName;

    StringBuffer buf = new StringBuffer();

    if (isParameterType) {
      buf.write(name);
    } else {
      buf.write(element.linkedName);
    }

    // not TypeParameterType or Void or Union type
    if (isParameterizedType) {
      var list = typeArguments.where((t) => t.linkedName != 'dynamic').toList();
      if (list.isNotEmpty) {
        buf.write('&lt;');
        var string = list.map((t) => t.linkedName).join(',');
        buf.write(string);
        buf.write('&gt;');
      }
    }
    _linkedName = buf.toString();

    return _linkedName;
  }

  String createLinkedReturnTypeName() {
    if ((_type as FunctionType).returnType.element == null ||
        (_type as FunctionType).returnType.element.library == null) {
      if (_returnTypeName != null) {
        if (_returnTypeName == 'dynamic' && element.isAsynchronous) {
          // TODO(keertip): for SDK docs it should be a link
          return 'Future';
        }
        return _returnTypeName;
      } else {
        return '';
      }
    } else {
      return _returnType.linkedName;
    }
  }
}
