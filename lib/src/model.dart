// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:convert';

import 'package:analyzer/src/generated/ast.dart'
    show AnnotatedNode, Annotation, Declaration;
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/resolver.dart'
    show Namespace, NamespaceBuilder, InheritanceManager, MemberMap;
import 'package:analyzer/src/generated/utilities_dart.dart' show ParameterKind;
import 'package:analyzer/src/generated/source_io.dart';
import 'package:quiver/core.dart' show hash3;

import 'config.dart';
import 'line_number_cache.dart';
import 'markdown_processor.dart' show Documentation, renderMarkdownToHtml;
import 'model_utils.dart';
import 'package_meta.dart' show PackageMeta, FileContents;
import 'utils.dart' show stripComments;

int byName(Nameable a, Nameable b) =>
    a.name.toUpperCase().compareTo(b.name.toUpperCase());

final Map<Class, List<Class>> _implementors = new Map();

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

/// An element that is enclosed by some other element.
///
/// Libraries are not enclosed.
abstract class EnclosedElement {
  ModelElement get enclosingElement;
}

/// Something that has a name.
abstract class Nameable {
  String get name;
}

/// Bridges the gap between model elements and packages,
/// both of which have documentation.
abstract class Documentable {
  String get oneLineDoc;
  String get documentation;
  String get documentationAsHtml;
  bool get hasMoreThanOneLineDocs;
  bool get hasDocumentation;
}

abstract class ModelElement implements Comparable, Nameable, Documentable {
  final Element element;
  final Library library;

  ElementType _modelType;
  String _rawDocs;
  Documentation __documentation;
  List _parameters;

  String _fullyQualifiedName;

  // WARNING: putting anything into the body of this seems
  // to lead to stack overflows. Need to make a registry of ModelElements
  // somehow.
  ModelElement(this.element, this.library);

  factory ModelElement.from(Element e, Library library) {
    if (e is DynamicElementImpl) {
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

  int compareTo(dynamic other) {
    if (other is ModelElement) {
      return name.toLowerCase().compareTo(other.name.toLowerCase());
    } else {
      return 0;
    }
  }

  /// A human-friendly name for the kind of element this is.
  String get kind;

  String get _computeDocumentationComment =>
      element.computeDocumentationComment();

  /// Returns the docs, stripped of their
  /// leading comments syntax.
  ///
  /// This getter will walk up the inheritance hierarchy
  /// to find docs, if the current class doesn't have docs
  /// for this element.
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
    return _rawDocs;
  }

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = new Documentation(this);
    return __documentation;
  }

  @override
  bool get hasDocumentation =>
      documentation != null && documentation.isNotEmpty;

  @override
  String get documentationAsHtml => _documentation.asHtml;

  @override
  String get oneLineDoc => _documentation.asOneLiner;

  @override
  bool get hasMoreThanOneLineDocs => _documentation.hasMoreThanOneLineDocs;

  String get htmlId => name;

  String toString() => '$runtimeType $name';

  List<String> get annotations {
    // Check https://code.google.com/p/dart/issues/detail?id=23181
    // If that is fixed, this code might get a lot easier
    if (element.computeNode() != null &&
        element.computeNode() is AnnotatedNode) {
      return (element.computeNode() as AnnotatedNode)
          .metadata
          .map((Annotation a) {
        var annotationString = a.toSource().substring(1); // remove the @
        var e = a.element;
        if (e != null && (e is ConstructorElement)) {
          var me = new ModelElement.from(
              e.enclosingElement, new Library(e.library, package));
          if (me.href != null) {
            return annotationString.replaceAll(me.name, me.linkedName);
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

  /// Returns the fully qualified name.
  ///
  /// For example: libraryName.className.methodName
  String get fullyQualifiedName {
    return (_fullyQualifiedName ??= _buildFullyQualifiedName());
  }

  String _buildFullyQualifiedName([ModelElement e, String fqName]) {
    e ??= this;
    fqName ??= e.name;

    if (e is! EnclosedElement) {
      return fqName;
    }

    ModelElement parent = (e as EnclosedElement).enclosingElement;
    return _buildFullyQualifiedName(parent, '${parent.name}.$fqName');
  }

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

  Package get package =>
      (this is Library) ? (this as Library).package : this.library.package;

  String get linkedName {
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
      if (!package.isDocumented(c.element)) return HTML_ESCAPE.convert(name);
      if (c.name
          .startsWith('_')) return '${c.name}.${HTML_ESCAPE.convert(name)}';
    }

    return '<a class="${isDeprecated ? 'deprecated' : ''}" href="${href}">$name</a>';
  }

  String get href;

  String linkedParams(
      {bool showMetadata: true, bool showNames: true, String separator: ', '}) {
    String renderParam(Parameter p) {
      StringBuffer buf = new StringBuffer();
      buf.write('<span class="parameter" id="${p.htmlId}">');
      if (showMetadata && p.hasAnnotations) {
        buf.write('<ol class="annotation-list">');
        p.annotations.forEach((String annotation) {
          buf.write('<li>$annotation</li>');
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
        buf.write(p.modelType.element
            .linkedParams(showNames: showNames, showMetadata: showMetadata));
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

  String get linkedParamsLines => linkedParams().trim();
}

// TODO: how do we get rid of this class?
class Dynamic extends ModelElement {
  Dynamic(DynamicElementImpl element, Library library)
      : super(element, library);

  ModelElement get enclosingElement => throw new UnsupportedError('');

  @override
  String get href => throw new StateError('dynamic should not have an href');

  @override
  String get kind => 'dynamic';

  @override
  String get linkedName => 'dynamic';
}

class Package implements Nameable, Documentable {
  final List<Library> _libraries = [];
  final PackageMeta packageMeta;
  final Map<String, Library> elementLibaryMap = {};
  String _docsAsHtml;

  String get name => packageMeta.name;

  String get version => packageMeta.version;

  bool get hasDocumentation =>
      documentationFile != null && documentationFile.contents.isNotEmpty;

  bool get hasDocumentationFile => documentationFile != null;

  FileContents get documentationFile => packageMeta.getReadmeContents();

  // TODO: make this work
  String get oneLineDoc => '';

  // TODO: Clients should use [documentationFile] so they can act differently on
  // plain text or markdown.
  String get documentation {
    return hasDocumentationFile ? documentationFile.contents : null;
  }

  String get documentationAsHtml {
    if (_docsAsHtml != null) return _docsAsHtml;

    _docsAsHtml = renderMarkdownToHtml(documentation);

    return _docsAsHtml;
  }

  // TODO: make this work
  bool get hasMoreThanOneLineDocs => true;

  List<Library> get libraries => _libraries;

  Package(Iterable<LibraryElement> libraryElements, this.packageMeta) {
    libraryElements.forEach((element) {
      var lib = new Library(element, this);
      Library._libraryMap.putIfAbsent(lib.name, () => lib);
      elementLibaryMap.putIfAbsent('${lib.kind}.${lib.name}', () => lib);
      _libraries.add(lib);
    });

    _libraries.forEach((library) {
      library._allClasses.forEach(_addToImplementors);
    });

    _libraries.sort();
    _implementors.values.forEach((l) => l.sort());
  }

  /// Does this package represent the SDK?
  bool get isSdk => packageMeta.isSdk;

  String toString() => isSdk ? 'SDK' : 'Package $name';

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

  String get href => 'index.html';

  /// Will try to find the library that exports the element.
  /// Checks if a library exports a name.
  /// Can return null if not appropriate library can be found.
  Library _getLibraryFor(Element e) {
    // can be null if e is for dynamic
    if (e.library == null) {
      return null;
    }

    Library lib = elementLibaryMap['${e.kind}.${e.name}'];
    if (lib != null) return lib;
    lib = libraries.firstWhere((l) => l.hasInExportedNamespace(e),
        orElse: () {});
    if (lib != null) {
      elementLibaryMap.putIfAbsent('${e.kind}.${e.name}', () => lib);
      return lib;
    }
    return new Library(e.library, this);
  }
}

class Library extends ModelElement {
  static final Map<String, Library> _libraryMap = <String, Library>{};

  final Package package;
  List<Class> _classes;
  List<Class> _enums;
  List<ModelFunction> _functions;
  List<Typedef> _typeDefs;
  List<TopLevelVariable> _variables;
  Namespace _exportedNamespace;
  String _name;

  LibraryElement get _library => (element as LibraryElement);

  Library._(LibraryElement element, this.package) : super(element, null) {
    if (element == null) throw new ArgumentError.notNull('element');
    _exportedNamespace =
        new NamespaceBuilder().createExportNamespaceForLibrary(element);
  }

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

  @override
  String get kind => 'library';

  /// Libraries are not enclosed by anything.
  ModelElement get enclosingElement => null;

  Library get library => this;

  bool hasInExportedNamespace(Element element) {
    Element found = _exportedNamespace.get(element.name);
    if (found == null) return false;
    if (found == element) return true; // this checks more than just the name

    // Fix for #587, comparison between elements isn't reliable on windows.
    // for some reason. sigh.

    return found.runtimeType == element.runtimeType &&
        found.nameOffset == element.nameOffset;
  }

  bool get isAnonymous => element.name == null || element.name.isEmpty;

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

    // So, if the library is a system library, it's name is not
    // dart:___, it's dart.___. Apparently the way to get to the dart:___
    // name is to get source.encoding.
    // This may be wrong or misleading, but developers expect the name
    // of dart:____
    var source = _library.definingCompilationUnit.source;
    _name = source.isInSystemLibrary ? source.encoding : _name;

    return _name;
  }

  String get path => _library.definingCompilationUnit.name;

  String get dirName => name.replaceAll(':', '-');

  String get fileName => '$dirName-library.html';

  bool get isInSdk => _library.isInSdk;

  bool get isDocumented => oneLineDoc.isNotEmpty;

  List<TopLevelVariable> _getVariables() {
    if (_variables != null) return _variables;

    Set<TopLevelVariableElement> elements = new Set();
    elements.addAll(_library.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in _library.parts) {
      elements.addAll(cu.topLevelVariables);
    }
    _exportedNamespace.definedNames.values.forEach((element) {
      if (element is PropertyAccessorElement) elements.add(element.variable);
    });
    elements..removeWhere(isPrivate);
    _variables = elements
        .map((e) => new TopLevelVariable(e, this))
        .toList(growable: false)..sort(byName);

    return _variables;
  }

  bool get hasProperties => _getVariables().any((v) => !v.isConst);

  /// All variables ("properties") except constants.
  List<TopLevelVariable> get properties {
    return _getVariables().where((v) => !v.isConst).toList(growable: false)
      ..sort(byName);
  }

  bool get hasConstants => _getVariables().any((v) => v.isConst);

  List<TopLevelVariable> get constants {
    return _getVariables().where((v) => v.isConst).toList(growable: false)
      ..sort(byName);
  }

  bool get hasEnums => enums.isNotEmpty;

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

    elements.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is FunctionTypeAliasElement));
    elements..removeWhere(isPrivate);
    _typeDefs = elements
        .map((e) => new Typedef(e, this))
        .toList(growable: false)..sort(byName);

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
    elements.addAll(_exportedNamespace.definedNames.values
        .where((element) => element is FunctionElement));

    elements..removeWhere(isPrivate);
    _functions = elements.map((e) {
      return new ModelFunction(e, this);
    }).toList(growable: false)..sort(byName);

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

  List<Class> get classes {
    return _allClasses
        .where((c) => !c.isErrorOrException)
        .toList(growable: false);
  }

  List<Class> get allClasses => _allClasses;

  bool get hasClasses => classes.isNotEmpty;

  bool get hasExceptions => _allClasses.any((c) => c.isErrorOrException);

  List<Class> get exceptions {
    return _allClasses
        .where((c) => c.isErrorOrException)
        .toList(growable: false)..sort(byName);
  }

  @override
  String get href => '$dirName/$fileName';
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

  ClassElement get _cls => (element as ClassElement);

  Class(ClassElement element, Library library) : super(element, library) {
    Package p = library.package;
    _modelType = new ElementType(_cls.type, this);

    _mixins = _cls.mixins.map((f) {
      Library lib = new Library(f.element.library, p);
      ElementType t = new ElementType(f, new ModelElement.from(f.element, lib));
      bool exclude = t.element.element.isPrivate;
      if (exclude) {
        return null;
      } else {
        return t;
      }
    }).where((mixin) => mixin != null).toList(growable: false);

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

  /// Returns the library that encloses this element.
  ModelElement get enclosingElement => library;

  String get nameWithGenerics {
    if (!modelType.isParameterizedType) return name;
    return '$name&lt;${_typeParameters.map((t) => t.name).join(', ')}&gt;';
  }

  List<TypeParameter> get _typeParameters => _cls.typeParameters.map((f) {
        var lib = new Library(f.enclosingElement.library, package);
        return new TypeParameter(f, lib);
      }).toList();

  @override
  String get kind => 'class';

  String get fullkind {
    if (isAbstract) return 'abstract $kind';
    return kind;
  }

  String get fileName => "${name}-class.html";

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

  List<ElementType> get superChainReversed => superChain.reversed.toList();

  List<ElementType> get mixins => _mixins;

  bool get hasMixins => mixins.isNotEmpty;

  List<ElementType> get interfaces => _interfaces;

  bool get hasInterfaces => interfaces.isNotEmpty;

  /// Returns all the implementors of the class specified.
  List<Class> get implementors =>
      _implementors[this] != null ? _implementors[this] : [];

  bool get hasImplementors => implementors.isNotEmpty;

  List<Field> get _allFields {
    if (_fields != null) return _fields;

    _fields = _cls.fields
        .where(isPublic)
        .map((e) => new Field(e, library))
        .toList(growable: false)..sort(byName);

    return _fields;
  }

  List<Field> get staticProperties {
    if (_staticFields != null) return _staticFields;
    _staticFields = _allFields
        .where((f) => f.isStatic)
        .where((f) => !f.isConst)
        .toList(growable: false)..sort(byName);

    return _staticFields;
  }

  bool get hasInstanceProperties => instanceProperties.isNotEmpty;

  bool get allInstancePropertiesInherited =>
      instanceProperties.every((f) => f.isInherited);

  bool get allOperatorsInherited => operators.every((f) => f.isInherited);

  bool get allInstanceMethodsInherited =>
      instanceMethods.every((f) => f.isInherited);

  List<Field> get instanceProperties {
    if (_instanceFields != null) return _instanceFields;
    _instanceFields = _allFields
        .where((f) => !f.isStatic)
        .toList(growable: false)..sort(byName);

    _genPageProperties.addAll(_instanceFields);
    return _instanceFields;
  }

  List<Field> get constants {
    if (_constants != null) return _constants;
    _constants = _allFields.where((f) => f.isConst).toList(growable: false)
      ..sort(byName);

    return _constants;
  }

  bool get hasConstants => constants.isNotEmpty;

  bool get hasStaticProperties => staticProperties.isNotEmpty;

  List<Constructor> get constructors {
    if (_constructors != null) return _constructors;

    _constructors = _cls.constructors.where(isPublic).map((e) {
      return new Constructor(e, library);
    }).toList(growable: true)..sort(byName);

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
    }).toList(growable: false)..sort(byName);

    return _allMethods;
  }

  List<Operator> get operators {
    if (_operators != null) return _operators;

    _operators = _methods.where((m) => m.isOperator).toList(growable: false)
      ..sort(byName);
    _genPageOperators.addAll(_operators);

    return _operators;
  }

  bool get hasOperators =>
      operators.isNotEmpty || inheritedOperators.isNotEmpty;

  List<Operator> get allOperators {
    if (_allOperators != null) return _allOperators;
    _allOperators = []
      ..addAll(operators)
      ..addAll(inheritedOperators)
      ..sort(byName);
    return _allOperators;
  }

  List<Method> get staticMethods {
    if (_staticMethods != null) return _staticMethods;

    _staticMethods = _methods.where((m) => m.isStatic).toList(growable: false)
      ..sort(byName);

    return _staticMethods;
  }

  bool get hasStaticMethods => staticMethods.isNotEmpty;

  List<Method> get instanceMethods {
    if (_instanceMethods != null) return _instanceMethods;

    _instanceMethods = _methods
        .where((m) => !m.isStatic && !m.isOperator)
        .toList(growable: false)..sort(byName);

    _genPageMethods.addAll(_instanceMethods);
    return _instanceMethods;
  }

  bool get hasInstanceMethods => instanceMethods.isNotEmpty;

  // TODO: make this method smarter about hierarchies and overrides. Right
  // now, we're creating a flat list. We're not paying attention to where
  // these methods are actually coming from. This might turn out to be a
  // problem if we want to show that info later.
  List<Method> get inheritedMethods {
    if (_inheritedMethods != null) return _inheritedMethods;

    InheritanceManager manager = new InheritanceManager(element.library);
    MemberMap cmap = manager.getMapOfMembersInheritedFromClasses(element);
    MemberMap imap = manager.getMapOfMembersInheritedFromInterfaces(element);

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

    for (var i = 0; i < cmap.size; i++) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(cmap.getKey(i))) continue;

      uniqueNames.add(cmap.getKey(i));
      vs.add(cmap.getValue(i));
    }

    for (var i = 0; i < imap.size; i++) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(imap.getKey(i))) continue;

      uniqueNames.add(imap.getKey(i));
      vs.add(imap.getValue(i));
    }

    for (ExecutableElement value in vs) {
      if (value != null &&
          value is MethodElement &&
          !value.isPrivate &&
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

  List<Method> get allInstanceMethods {
    if (_allInstanceMethods != null) return _allInstanceMethods;
    _allInstanceMethods = []
      ..addAll(instanceMethods)
      ..addAll(inheritedMethods)
      ..sort(byName);
    return _allInstanceMethods;
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

    for (int i = 0; i < imap.size; i++) {
      ExecutableElement value = imap.getValue(i);
      if (_isInheritedOperator(value)) {
        vs.putIfAbsent(value.name, () => value);
      }
    }

    for (int i = 0; i < cmap.size; i++) {
      ExecutableElement value = cmap.getValue(i);
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

  bool get hasInheritedMethods => inheritedMethods.isNotEmpty;

  // TODO: make this method smarter about hierarchies and overrides. Right
  // now, we're creating a flat list. We're not paying attention to where
  // these methods are actually coming from. This might turn out to be a
  // problem if we want to show that info later.
  List<Field> get inheritedProperties {
    if (_inheritedProperties != null) return _inheritedProperties;

    InheritanceManager manager = new InheritanceManager(element.library);
    MemberMap cmap = manager.getMapOfMembersInheritedFromClasses(element);
    MemberMap imap = manager.getMapOfMembersInheritedFromInterfaces(element);

    _inheritedProperties = [];
    List<ExecutableElement> vs = [];
    Set<String> uniqueNames = new Set();

    instanceProperties.forEach((f) {
      if (f._setter != null) uniqueNames.add(f._setter.name);
      if (f._getter != null) uniqueNames.add(f._getter.name);
    });

    for (var i = 0; i < cmap.size; i++) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(cmap.getKey(i))) continue;

      uniqueNames.add(cmap.getKey(i));
      vs.add(cmap.getValue(i));
    }

    for (var i = 0; i < imap.size; i++) {
      // XXX: if we care about showing a hierarchy with our inherited methods,
      // then don't do this
      if (uniqueNames.contains(imap.getKey(i))) continue;

      uniqueNames.add(imap.getKey(i));
      vs.add(imap.getValue(i));
    }

    vs.removeWhere((it) => instanceProperties.any((i) => it.name == i.name));

    for (var value in vs) {
      if (value != null &&
          value is PropertyAccessorElement &&
          !value.isPrivate &&
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

  bool get hasMethods =>
      instanceMethods.isNotEmpty || inheritedMethods.isNotEmpty;

  bool get hasProperties =>
      inheritedProperties.isNotEmpty || instanceProperties.isNotEmpty;

  List<Field> get allInstanceProperties {
    if (_allInstanceProperties != null) return _allInstanceProperties;

    // TODO best way to make this a fixed length list?
    _allInstanceProperties = []
      ..addAll(instanceProperties)
      ..addAll(inheritedProperties)
      ..sort(byName);

    return _allInstanceProperties;
  }

  List<Field> get propertiesForPages => _genPageProperties;

  List<Method> get methodsForPages => _genPageMethods;

  List<Operator> get operatorsForPages => _genPageOperators;

  bool get isErrorOrException {
    bool _doCheck(InterfaceType type) {
      return (type.element.library.isDartCore &&
          (type.name == 'Exception' || type.name == 'Error'));
    }

    // if this class is itself Error or Exception, return true
    if (_doCheck(_cls.type)) return true;

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
  String get href => '${library.dirName}/$fileName';
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
        .map((field) => new EnumField.forConstant(index++, field, library))
        .toList(growable: false)..sort(byName);

    return _constants;
  }

  @override
  List<EnumField> get instanceProperties {
    return super
        .instanceProperties
        .map((Field p) => new EnumField(p.element, p.library))
        .toList(growable: false);
  }
}

abstract class SourceCodeMixin {
  String get sourceCode {
    String contents = element.source.contents.data;
    var node = element.computeNode();
    if (node == null) return '';

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
    String source =
        contents.substring(node.offset - (node.offset - i), node.end);
    source = stripIndentFromSource(source);
    source = stripDartdocCommentsFromSource(source);
    return source;
  }

  String get crossdartHtmlTag {
    if (config != null && config.addCrossdart && _crossdartUrl != null) {
      return "<a class='crossdart' href='${_crossdartUrl}'>Link to Crossdart</a>";
    } else {
      return "";
    }
  }

  int get _lineNumber {
    var node = element.computeNode();
    if (node is Declaration && (node as Declaration).element != null) {
      return lineNumberCache.lineNumber(
          (node as Declaration).element.source.fullName, node.offset);
    } else {
      return null;
    }
  }

  String get _crossdartUrl {
    if (_lineNumber != null && _sourceFilePath != null) {
      String packageName = library.package.isSdk ? "sdk" : library.package.name;
      String packageVersion = library.package.version;
      var root = "${library.package.packageMeta.resolvedDir}/lib"
          .replaceAll("\\", "/");
      var sourceFilePath = _sourceFilePath
          .replaceAll("\\", "/")
          .replaceAll(root, "")
          .replaceAll(new RegExp(r"^/*"), "");
      String url =
          "//crossdart.info/p/$packageName/$packageVersion/$sourceFilePath.html";
      return "${url}#line-${_lineNumber}";
    } else {
      return null;
    }
  }

  String get _sourceFilePath {
    var node = element.computeNode();
    if (node is Declaration && (node as Declaration).element != null) {
      return ((node as Declaration).element.source as FileBasedSource)
          .file
          .toString();
    } else {
      return null;
    }
  }

  bool get hasSourceCode => sourceCode.trim().isNotEmpty;

  Library get library;
  Element get element;
}

class ModelFunction extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  ModelFunction(FunctionElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_func.type, this);
  }

  ModelElement get enclosingElement => library;

  FunctionElement get _func => (element as FunctionElement);

  bool get isStatic => _func.isStatic;

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  String get fileName => "$name.html";

  @override
  String get kind => 'function';

  @override
  String get href => '${library.dirName}/$fileName';
}

class Typedef extends ModelElement implements EnclosedElement {
  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  Typedef(FunctionTypeAliasElement element, Library library)
      : super(element, library) {
    if (element.type != null) {
      _modelType = new ElementType(element.type, this);
    }
  }

  @override
  String get kind => 'typedef';

  @override
  ModelElement get enclosingElement => library;

  String get fileName => '$name.html';

  String get linkedReturnType => modelType != null
      ? modelType.createLinkedReturnTypeName()
      : _typedef.returnType.name;

  @override
  String get href => '${library.dirName}/$fileName';
}

// TODO: rename this to Property
class Field extends ModelElement
    with GetterSetterCombo
    implements EnclosedElement {
  String _constantValue;
  bool _isInherited = false;
  Class _enclosingClass;

  FieldElement get _field => (element as FieldElement);

  Field(FieldElement element, Library library) : super(element, library) {
    _setModelType();
  }

  Field.inherited(FieldElement element, this._enclosingClass, Library library)
      : super(element, library) {
    _isInherited = true;
    _setModelType();
  }

  @override
  String get kind => 'property';

  @override
  ModelElement get enclosingElement {
    if (_enclosingClass == null) {
      _enclosingClass = new ModelElement.from(_field.enclosingElement, library);
    }
    return _enclosingClass;
  }

  void _setModelType() {
    if (hasGetter) {
      var t = _field.getter.returnType;
      _modelType = new ElementType(t,
          new ModelElement.from(t.element, package._getLibraryFor(t.element)));
    } else {
      var s = _field.setter.parameters.first.type;
      _modelType = new ElementType(s,
          new ModelElement.from(s.element, package._getLibraryFor(s.element)));
    }
  }

  bool get isFinal => _field.isFinal;

  bool get isConst => _field.isConst;

  String get linkedReturnType => modelType.linkedName;

  String get constantValue {
    if (_constantValue != null) return _constantValue;

    if (_field.computeNode() == null) return null;
    var v = _field.computeNode().toSource();
    if (v == null) return null;
    var string = v.substring(v.indexOf('=') + 1, v.length).trim();
    _constantValue = string.replaceAll(modelType.name, modelType.linkedName);

    return _constantValue;
  }

  bool get hasGetter => _field.getter != null;

  bool get hasSetter => _field.setter != null;

  PropertyAccessorElement get _getter => _field.getter;
  PropertyAccessorElement get _setter => _field.setter;

  @override
  String get _computeDocumentationComment {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _field.computeDocumentationComment();
    return docs;
  }

  bool get readOnly => hasGetter && !hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;

  bool get readWrite => hasGetter && hasSetter;

  String get typeName => "property";

  bool get isInherited => _isInherited;

  @override
  String get href {
    if (enclosingElement is Class) {
      return '${library.dirName}/${enclosingElement.name}/$name.html';
    } else if (enclosingElement is Library) {
      return '${library.dirName}/$name.html';
    } else {
      throw new StateError(
          '$name is not in a class or library, instead it is a ${enclosingElement.element}');
    }
  }
}

/// Enum's fields are virtual, so we do a little work to create
/// usable values for the docs.
class EnumField extends Field {
  int _index;

  EnumField.forConstant(this._index, FieldElement element, Library library)
      : super(element, library);

  EnumField(FieldElement element, Library library) : super(element, library);

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
  String get linkedName => name;

  @override
  String get href =>
      '${library.dirName}/${(enclosingElement as Class).fileName}';
}

class Constructor extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  ConstructorElement get _constructor => (element as ConstructorElement);

  Constructor(ConstructorElement element, Library library)
      : super(element, library);

  @override
  String get kind => 'constructor';

  String get fullKind {
    if (isConst) return 'const $kind';
    if (isFactory) return 'factory $kind';
    return kind;
  }

  @override
  String get fullyQualifiedName => '${library.name}.$name';

  @override
  ModelElement get enclosingElement =>
      new ModelElement.from(_constructor.enclosingElement, library);

  @override
  String get href =>
      '${library.dirName}/${_constructor.enclosingElement.name}/$name.html';

  bool get isConst => _constructor.isConst;

  bool get isFactory => _constructor.isFactory;

  String get shortName {
    if (name.contains('.')) {
      return name.substring(_constructor.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

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
}

class Method extends ModelElement
    with SourceCodeMixin
    implements EnclosedElement {
  bool _isInherited = false;
  Class _enclosingClass;

  MethodElement get _method => (element as MethodElement);

  Method(MethodElement element, Library library) : super(element, library) {
    _modelType = new ElementType(_method.type, this);
  }

  Method.inherited(MethodElement element, this._enclosingClass, Library library)
      : super(element, library) {
    _modelType = new ElementType(_method.type, this);
    _isInherited = true;
  }

  @override
  String get kind => 'method';

  @override
  ModelElement get enclosingElement {
    if (_enclosingClass == null) {
      _enclosingClass =
          new ModelElement.from(_method.enclosingElement, library);
    }
    return _enclosingClass;
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
  String get href => '${library.dirName}/${enclosingElement.name}/${fileName}';

  bool get isInherited => _isInherited;
}

class Operator extends Method {
  Operator(MethodElement element, Library library) : super(element, library);

  Operator.inherited(
      MethodElement element, Class enclosingClass, Library library)
      : super.inherited(element, enclosingClass, library) {
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
  String get fullyQualifiedName =>
      '${library.name}.${enclosingElement.name}.${super.name}';

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
class Accessor extends ModelElement implements EnclosedElement {
  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);

  Accessor(PropertyAccessorElement element, Library library)
      : super(element, library);

  @override
  String get kind => 'accessor';

  @override
  ModelElement get enclosingElement {
    if (_accessor.enclosingElement is CompilationUnitElement) {
      return package
          ._getLibraryFor(_accessor.enclosingElement.enclosingElement);
    }

    return new ModelElement.from(_accessor.enclosingElement, library);
  }

  bool get isGetter => _accessor.isGetter;

  @override
  String get href =>
      '${library.dirName}/${_accessor.enclosingElement.name}/${name}.html';
}

/// Mixin for top-level variables and fields (aka properties)
abstract class GetterSetterCombo {
  bool get hasGetter;
  bool get hasSetter;
  Library get library;

  PropertyAccessorElement get _getter;
  PropertyAccessorElement get _setter;

  Accessor get getter {
    return _getter == null ? null : new ModelElement.from(_getter, library);
  }

  Accessor get setter {
    return _setter == null ? null : new ModelElement.from(_setter, library);
  }

  bool get hasExplicitSetter => hasSetter && !_setter.isSynthetic;

  bool get hasExplicitGetter => hasGetter && !_getter.isSynthetic;

  bool get hasNoGetterSetter => !hasExplicitGetter && !hasExplicitSetter;

  // TODO: now that we have explicit getter and setters, we probably
  // want a cleaner way to do this. Only the one-liner is using this
  // now. The detail pages should be using getter and setter directly.
  String get getterSetterDocumentationComment {
    var buffer = new StringBuffer();

    if (hasGetter && !_getter.isSynthetic) {
      String docs = stripComments(_getter.computeDocumentationComment());
      if (docs != null) buffer.write(docs);
    }

    if (hasSetter && !_setter.isSynthetic) {
      String docs = stripComments(_setter.computeDocumentationComment());
      if (docs != null) {
        if (buffer.isNotEmpty) buffer.write('\n\n');
        buffer.write(docs);
      }
    }
    return buffer.toString();
  }
}

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement
    with GetterSetterCombo
    implements EnclosedElement {
  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);

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

  @override
  String get kind => 'top-level property';

  @override
  ModelElement get enclosingElement => library;

  bool get isFinal => _variable.isFinal;

  bool get isConst => _variable.isConst;

  bool get readOnly => hasGetter && !hasSetter;

  bool get writeOnly => hasSetter && !hasGetter;

  bool get readWrite => hasGetter && hasSetter;

  String get linkedReturnType => modelType.linkedName;

  bool get hasGetter => _variable.getter != null;
  bool get hasSetter => _variable.setter != null;

  PropertyAccessorElement get _getter => _variable.getter;
  PropertyAccessorElement get _setter => _variable.setter;

  @override
  String get _computeDocumentationComment {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _variable.computeDocumentationComment();
    return docs;
  }

  String get constantValue {
    var v = (_variable as ConstTopLevelVariableElementImpl)
        .computeNode()
        .toSource();
    if (v == null) return '';
    var string = v.substring(v.indexOf('=') + 1, v.length).trim();
    return string.replaceAll(modelType.name, modelType.linkedName);
  }

  @override
  String get href => '${library.dirName}/${name}.html';
}

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(ParameterElement element, Library library)
      : super(element, library) {
    var t = _parameter.type;
    _modelType = new ElementType(
        t, new ModelElement.from(t.element, package._getLibraryFor(t.element)));
  }

  @override
  String get kind => 'parameter';

  @override
  ModelElement get enclosingElement =>
      new ModelElement.from(_parameter.enclosingElement, library);

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
}

class TypeParameter extends ModelElement {
  TypeParameter(TypeParameterElement element, Library library)
      : super(element, library) {
    _modelType = new ElementType(_typeParameter.type, this);
  }

  @override
  String get kind => 'type parameter';

  TypeParameterElement get _typeParameter => element as TypeParameterElement;

  String toString() => element.name;

  String get name {
    var bound = _typeParameter.bound;
    return bound != null
        ? '${_typeParameter.name} extends ${bound.name}'
        : _typeParameter.name;
  }

  @override
  String get href =>
      '${library.dirName}/${_typeParameter.enclosingElement.name}/$name';
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
    Library lib = _element.package.findLibraryFor(rt.element);
    if (lib == null) {
      lib = new Library(rt.element.library, _element.package);
    }
    return new ElementType(rt, new ModelElement.from(rt.element, lib));
  }

  ModelElement get returnElement {
    Element e = (_type as FunctionType).returnType.element;
    if (e == null) {
      return null;
    }
    Library lib = _element.package.findLibraryFor(e);
    if (lib == null) {
      lib = new Library(e.library, _element.package);
    }
    return (new ModelElement.from(e, lib));
  }

  List<ElementType> get typeArguments =>
      (_type as ParameterizedType).typeArguments.map((f) {
        Library lib;
        // can happen if element is dynamic
        lib = _element.package.findLibraryFor(f.element);
        if (lib == null && f.element.library != null) {
          lib = new Library(f.element.library, _element.package);
        }
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
      if (typeArguments.every((t) => t.linkedName == 'dynamic')) {
        _linkedName = buf.toString();
        return _linkedName;
      }
      if (typeArguments.isNotEmpty) {
        buf.write('&lt;');
        buf.writeAll(typeArguments.map((t) => t.linkedName), ', ');
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
