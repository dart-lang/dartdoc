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
import 'package_utils.dart';

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
  final String source;

  ElementType _modelType;
  String _documentation;

  List _parameters;

  ModelElement(this.element, this.library, [this.source]);

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
      var overrideElement = getOverriddenElement();
      if (overrideElement != null) {
        _documentation = overrideElement.documentation;
      }
    }

    _documentation = stripComments(_documentation);

    return _documentation;
  }

  String resolveReferences(String docs) {
    NodeList<CommentReference> _getCommentRefs() {
      if (_documentation == null && canOverride()) {
        var melement = getOverriddenElement();
        if (melement != null &&
            melement.element.node != null &&
            melement.element.node is AnnotatedNode) {
          var docComment =
              (melement.element.node as AnnotatedNode).documentationComment;
          if (docComment != null) return docComment.references;
          return null;
        }
      }
      if (element.node is AnnotatedNode) {
        if ((element.node as AnnotatedNode).documentationComment != null) {
          return (element.node as AnnotatedNode).documentationComment.references;
        }
      } else if (element is LibraryElement) {
        var node = element.node.parent.parent;
        if (node is AnnotatedNode) {
          if ((node as AnnotatedNode).documentationComment != null) {
            return (node as AnnotatedNode).documentationComment.references;
          }
        }
      }
      return null;
    }

    var commentRefs = _getCommentRefs();
    if (commentRefs == null || commentRefs.isEmpty) {
      return docs;
    }

    String _getMatchingLink(String codeRef) {
      var refElement;
      try {
        refElement = commentRefs.firstWhere(
            (ref) => ref.identifier.name == codeRef).identifier.staticElement;
      } on StateError catch (error) {
        // do nothing
      }
      if (refElement == null) {
        return null;
      }
      var refLibrary;
      if (this is Library) {
        refLibrary = this;
      } else {
        refLibrary = this.library;
      }
      var e = new ModelElement.from(refElement, refLibrary);
      return e.href;
    }

    return replaceAllLinks(docs, findMatchingLink: _getMatchingLink);
  }

  String get htmlId => name;

  String toString() => '$runtimeType $name';

  List<String> get annotations {
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

  ModelElement getOverriddenElement() => null;

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

  ElementType get modelType => _modelType;

  /// Returns the [ModelElement] that encloses this.
  ModelElement getEnclosingElement() {
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
    Class c = getEnclosingElement();
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

  // TODO: handle default values
  String linkedParams({bool showNames: true}) {
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
        buf.write('<span class="parameter">');
        if (p.hasAnnotations) {
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
          buf.write(p.modelType.element.linkedParams(showNames: showNames));
          buf.write(')');
        } else if (p.modelType != null && p.modelType.element != null) {
          var mt = p.modelType.element.modelType;
          String typeName = "";
          if (mt != null) {
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
        buf.write('</span><!-- end param -->');
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

  String get linkedParamsNoNames {
    return linkedParams(showNames: false);
  }

  /// End each parameter with a `<br>`
  String get linkedParamsLines {
    return linkedParams().replaceAll('<!-- end param -->,', ',<br>');
  }
}

class Dynamic extends ModelElement {
  Dynamic(DynamicElementImpl element, Library library, [String source])
      : super(element, library, source);

  String get _href => throw new StateError('dynamic should not have an href');
}

class Package {
  String _rootDirPath;
  final List<Library> _libraries = [];
  bool _isSdk;
  String _sdkVersion;
  final String _readmeLoc;

  String get name =>
      _isSdk ? 'Dart API Reference' : getPackageName(_rootDirPath);

  String get version => _isSdk ? _sdkVersion : getPackageVersion(_rootDirPath);

  String get sdkVersion => _sdkVersion;

  String get description =>
      getPackageDescription(_isSdk, _readmeLoc, _rootDirPath);

  List<Library> get libraries => _libraries;

  Package(Iterable<LibraryElement> libraryElements, this._rootDirPath,
      [this._sdkVersion, this._isSdk = false, this._readmeLoc]) {
    libraryElements.forEach((element) {
      //   print('adding lib $element to package $name');
      _libraries.add(new Library(element, this));
    });
    _libraries.forEach((library) {
      library._allClasses.forEach(_addToImplementors);
    });
  }

  String toString() => 'Package $name, isSdk: $_isSdk';

  bool isDocumented(ModelElement e) {
    // TODO: review this logic. I'm compensating for what's probably a bug
    // see also ElementType and how an elementType is linked to a library
    if (e is Library) {
      return _libraries.any((lib) => lib.element == e.element);
    } else {
      return _libraries.any((lib) => lib.element == e.element.library ||
          (lib.element as LibraryElement).exportedLibraries
              .contains(e.element.library));
    }
  }

  String get href => 'index.html';
}

class Library extends ModelElement {
  Package package;
  List<Class> _classes;
  List<Class> _enums;
  List<ModelFunction> _functions;
  List<Typedef> _typeDefs;
  List<TopLevelVariable> _variables;
  List<String> _nameSpace;

  LibraryElement get _library => (element as LibraryElement);

  Library(LibraryElement element, this.package, [String source])
      : super(element, null, source);

  List<String> get _exportedNameSpace {
    if (_nameSpace == null) _buildExportedNameSpace();
    return _nameSpace;
  }

  _buildExportedNameSpace() {
    _nameSpace = [];
    for (ExportElement e in _library.exports) {
      Namespace namespace =
          new NamespaceBuilder().createExportNamespaceForDirective(e);
      _nameSpace.addAll(namespace.definedNames.keys);
    }
  }

  String get name {
    var source = _library.definingCompilationUnit.source;
    return source.isInSystemLibrary ? source.encoding : super.name;
  }

  String get nameForFile => name.replaceAll(':', '_');

  bool get isInSdk => _library.isInSdk;

  List<TopLevelVariable> _getVariables() {
    if (_variables != null) return _variables;

    List<TopLevelVariableElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.topLevelVariables);
    }
    for (LibraryElement le in _library.exportedLibraries) {
      elements.addAll(le.definingCompilationUnit.topLevelVariables
          .where((v) => _exportedNameSpace.contains(v.name))
          .toList());
    }
    elements..removeWhere(isPrivate);
    _variables = elements
        .map((e) => new TopLevelVariable(e, this))
        .toList(growable: false);

    return _variables;
  }

  bool get hasProperties => _getVariables().any((v) => !v.isConst);

  /// All variables ("properties") except constants.
  List<TopLevelVariable> getProperties() {
    return _getVariables().where((v) => !v.isConst).toList(growable: false);
  }

  bool get hasConstants => _getVariables().any((v) => v.isConst);

  List<TopLevelVariable> getConstants() {
    return _getVariables().where((v) => v.isConst).toList(growable: false);
  }

  bool get hasEnums => getEnums().isNotEmpty;

  List<Class> getEnums() {
    if (_enums != null) return _enums;

    List<ClassElement> enumClasses = [];
    enumClasses.addAll(_library.definingCompilationUnit.enums);
    for (CompilationUnitElement cu in _library.parts) {
      enumClasses.addAll(cu.enums);
    }
    for (LibraryElement le in _library.exportedLibraries) {
      enumClasses.addAll(le.definingCompilationUnit.enums
          .where((e) => _exportedNameSpace.contains(e.name))
          .toList());
    }
    _enums = enumClasses
        .where(isPublic)
        .map((e) => new Enum(e, this))
        .toList(growable: false);
    return _enums;
  }

  Class getClassByName(String name) {
    return _allClasses.firstWhere((it) => it.name == name, orElse: () => null);
  }

  bool get hasTypedefs => getTypedefs().isNotEmpty;

  List<Typedef> getTypedefs() {
    if (_typeDefs != null) return _typeDefs;

    List<FunctionTypeAliasElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.functionTypeAliases);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.functionTypeAliases);
    }
    for (LibraryElement le in _library.exportedLibraries) {
      elements.addAll(le.definingCompilationUnit.functionTypeAliases
          .where((f) => _exportedNameSpace.contains(f.name))
          .toList());
    }
    elements..removeWhere(isPrivate);
    _typeDefs = elements.map((e) => new Typedef(e, this)).toList();
    return _typeDefs;
  }

  bool get hasFunctions => getFunctions().isNotEmpty;

  List<ModelFunction> getFunctions() {
    if (_functions != null) return _functions;

    List<FunctionElement> elements = [];
    elements.addAll(_library.definingCompilationUnit.functions);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.functions);
    }
    for (LibraryElement le in _library.exportedLibraries) {
      elements.addAll(le.definingCompilationUnit.functions
          .where((f) => _exportedNameSpace.contains(f.name))
          .toList());
    }
    // TODO(keerti): fix source for exported libraries
    elements..removeWhere(isPrivate);
    _functions = elements.map((e) {
      String eSource =
          (source != null) ? source.substring(e.node.offset, e.node.end) : null;
      return new ModelFunction(e, this, eSource);
    }).toList(growable: false);
    return _functions;
  }

  List<Class> get _allClasses {
    if (_classes != null) return _classes;

    List<ClassElement> types = [];
    types.addAll(_library.definingCompilationUnit.types);
    for (CompilationUnitElement cu in _library.parts) {
      types.addAll(cu.types);
    }
    for (LibraryElement le in _library.exportedLibraries) {
      types.addAll(le.definingCompilationUnit.types
          .where((t) => _exportedNameSpace.contains(t.name))
          .toList());
    }
    _classes = types
        .where(isPublic)
        .map((e) => new Class(
            e, this, source)) // is source a bug? it's the library's source
        .toList(growable: true);

    return _classes;
  }

  List<Class> getClasses() {
    if (package._isSdk) {
      return _allClasses;
    }

    return _allClasses.where((c) => !c.isErrorOrException).toList(
        growable: false);
  }

  List<Class> get allClasses => _allClasses;

  bool get hasClasses => getClasses().isNotEmpty;

  bool get hasExceptions => _allClasses.any((c) => c.isErrorOrException);

  List<Class> getExceptions() {
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
  List<Method> _inheritedMethods;
  List<Method> _staticMethods;
  List<Method> _instanceMethods;
  List<Field> _fields;
  List<Field> _staticFields;
  List<Field> _constants;
  List<Field> _instanceFields;
  List<Field> _inheritedProperties;

  ClassElement get _cls => (element as ClassElement);

  Class(ClassElement element, Library library, [String source])
      : super(element, library, source) {
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
    return '$name<${modelType.typeArguments.map((t) => t.name).join(', ')}>';
  }

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
      var cSource =
          (source != null) ? source.substring(e.node.offset, e.node.end) : null;
      return new Constructor(e, library, cSource);
    }).toList(growable: true);

    return _constructors;
  }

  bool get hasConstructors => constructors.isNotEmpty;

  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _cls.methods.where(isPublic).map((e) {
      var mSource =
          source != null ? source.substring(e.node.offset, e.node.end) : null;
      if (!e.isOperator) {
        return new Method(e, library, mSource);
      } else {
        return new Operator(e, library, mSource);
      }
    }).toList(growable: false);

    return _allMethods;
  }

  List<Operator> get operators {
    if (_operators != null) return _operators;

    _operators = _methods.where((m) => m.isOperator).toList(growable: false);

    return _operators;
  }

  bool get hasOperators => operators.isNotEmpty;

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

    vs.removeWhere((it) => _instanceFields.any((i) => it.name == i.name));

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
        _inheritedProperties.add(new Field(e, lib));
      }
    }
    return _inheritedProperties;
  }

  bool get hasMethods =>
      instanceMethods.isNotEmpty || inheritedMethods.isNotEmpty;

  bool get hasInheritedProperties => inheritedProperties.isNotEmpty;

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
  Enum(ClassElement element, Library library, [String source])
      : super(element, library, source);

  @override
  String get kind => 'enum';
}

class ModelFunction extends ModelElement {
  ModelFunction(FunctionElement element, Library library, [String contents])
      : super(element, library, contents) {
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

  String get _href => '${library.name}/$fileName';
}

class Field extends ModelElement {
  FieldElement get _field => (element as FieldElement);

  Field(FieldElement element, Library library) : super(element, library) {
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
    if (_field.node == null) return null;
    var v = _field.node.toSource();
    if (v == null) return null;
    return v.substring(v.indexOf('=') + 1, v.length).trim();
  }

  bool get hasGetter => _field.getter != null;

  bool get hasSetter => _field.setter != null;

  bool get readOnly => hasGetter && !hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;

  bool get readWrite => hasGetter && hasSetter;

  String get typeName => "property";

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

class Constructor extends ModelElement {
  ConstructorElement get _constructor => (element as ConstructorElement);

  Constructor(ConstructorElement element, Library library, [String source])
      : super(element, library, source);

  @override
  String get _href =>
      '${library.nameForFile}/${_constructor.enclosingElement.name}/$name.html';

  bool get isConst => _constructor.isConst;

  @override
  String get name {
    String constructorName = element.name;
    Class c = getEnclosingElement();
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

  Method(MethodElement element, Library library, [String source])
      : super(element, library, source) {
    _modelType = new ElementType(_method.type, this);
  }

  Method.inherited(MethodElement element, Library library, [String source])
      : super(element, library, source) {
    _modelType = new ElementType(_method.type, this);
    _isInherited = true;
  }

  Method getOverriddenElement() {
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
  Operator(MethodElement element, Library library, [String source])
      : super(element, library, source);

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
      '${library.nameForFile}/${_accessor.enclosingElement.name}.html#${htmlId}';
}

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement {
  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);

  TopLevelVariable(TopLevelVariableElement element, Library library)
      : super(element, library) {
    if (hasGetter) {
      var t = _variable.getter.returnType;
      var lib = new Library(t.element.library, package);
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
    return v.substring(v.indexOf('= ') + 2, v.length);
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

  @override
  String get _href {
    var p = _parameter.enclosingElement;

    if (p is FunctionElement) {
      return '${library.nameForFile}/${p.name}.html';
    } else {
      var name = Operator.friendlyNames.containsKey(p.name)
          ? Operator.friendlyNames[p.name]
          : p.name;
      return '${library.nameForFile}/${p.enclosingElement.name}/' +
          '${name}.html';
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

  @override
  String get _href =>
      throw new UnsupportedError('type parameters do not have hrefs');
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
      buf.write('&lt;');
      for (int i = 0; i < typeArguments.length; i++) {
        if (i > 0) {
          buf.write(', ');
        }
        ElementType t = typeArguments[i];
        buf.write(t.linkedName);
      }
      buf.write('&gt;');
    }
    _linkedName = buf.toString();

    return _linkedName;
  }

  // TODO: why does this method exist? Why can't we just use linkedName ?
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
