// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'dart:collection';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';

/// Base class representing a type in Dartdoc.  It wraps a [DartType], and
/// may link to a [ModelElement].
abstract class ElementType extends Privacy {
  final DartType _type;
  final PackageGraph packageGraph;
  final ElementType returnedFrom;
  final Library library;

  ElementType(this._type, this.library, this.packageGraph, this.returnedFrom);

  factory ElementType.from(
      DartType f, Library library, PackageGraph packageGraph,
      [ElementType returnedFrom]) {
    if (f.element == null || f.element.kind == ElementKind.DYNAMIC) {
      if (f is FunctionType) {
        return FunctionTypeElementType(f, library, packageGraph, returnedFrom);
      }
      return UndefinedElementType(f, library, packageGraph, returnedFrom);
    } else {
      ModelElement element = ModelElement.fromElement(f.element, packageGraph);
      assert(f is ParameterizedType || f is TypeParameterType);
      bool isGenericTypeAlias =
          f.element.enclosingElement is GenericTypeAliasElement;
      if (f is FunctionType) {
        assert(f is ParameterizedType);
        if (isGenericTypeAlias) {
          assert(element is! ModelFunctionAnonymous);
          return CallableGenericTypeAliasElementType(
              f, library, packageGraph, element, returnedFrom);
        } else {
          if (element is ModelFunctionAnonymous) {
            return CallableAnonymousElementType(
                f, library, packageGraph, element, returnedFrom);
          } else {
            assert(element is! ModelFunctionAnonymous);
            return CallableElementType(
                f, library, packageGraph, element, returnedFrom);
          }
        }
      } else if (isGenericTypeAlias) {
        assert(f is TypeParameterType);
        assert(element is! ModelFunctionAnonymous);
        return GenericTypeAliasElementType(
            f, library, packageGraph, element, returnedFrom);
      }
      if (f is TypeParameterType) {
        assert(element is! ModelFunctionAnonymous);
        return TypeParameterElementType(
            f, library, packageGraph, element, returnedFrom);
      }
      assert(f is ParameterizedType);
      assert(element is! ModelFunctionAnonymous);
      return ParameterizedElementType(
          f, library, packageGraph, element, returnedFrom);
    }
  }

  bool get canHaveParameters => false;

  // TODO(jcollins-g): change clients of ElementType to use subtypes more consistently
  // and eliminate createLinkedReturnTypeName (instead, using returnType.linkedName);
  String createLinkedReturnTypeName() => linkedName;

  bool get isTypedef => false;

  String get linkedName;

  String get name => type.name ?? type.element.name;

  String get nameWithGenerics;

  List<Parameter> get parameters => [];

  @override
  String toString() => "$type";

  DartType get type => _type;
}

/// An [ElementType] that isn't pinned to an Element (or one that is, but whose
/// element is irrelevant).
class UndefinedElementType extends ElementType {
  UndefinedElementType(DartType f, Library library, PackageGraph packageGraph,
      ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom);

  String _linkedName;

  @override
  bool get isPublic => true;

  @override
  String get nameWithGenerics => name;

  /// dynamic and void are not allowed to have parameterized types.
  @override
  String get linkedName {
    if (type.isDynamic &&
        returnedFrom != null &&
        (returnedFrom is DefinedElementType &&
            (returnedFrom as DefinedElementType).element.isAsynchronous)) {
      return 'Future';
    }
    return name;
  }

  @override
  String get name => type.name ?? '';
}

// A FunctionType that does not have an underpinning Element.
class FunctionTypeElementType extends UndefinedElementType {
  FunctionTypeElementType(DartType f, Library library,
      PackageGraph packageGraph, ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom);

  @override
  List<Parameter> get parameters {
    List<ParameterElement> params = (type as FunctionType).parameters;
    return UnmodifiableListView<Parameter>(params
        .map((p) => ModelElement.from(p, library, packageGraph) as Parameter)
        .toList());
  }

  ElementType get returnType => ElementType.from(
      (type as FunctionType).returnType, library, packageGraph, this);

  @override
  String get linkedName {
    if (_linkedName == null) {
      StringBuffer buf = StringBuffer();
      buf.write('${returnType.linkedName} ');
      buf.write('${nameWithGenerics}');
      buf.write('<span class="signature">');
      buf.write('(${linkedParams(parameters)})');
      buf.write('</span>');
      _linkedName = buf.toString();
    }
    return _linkedName;
  }

  @override
  String createLinkedReturnTypeName() => returnType.linkedName;

  String _nameWithGenerics;

  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      StringBuffer buf = StringBuffer();
      buf.write(name);
      if ((type as FunctionType).typeFormals.isNotEmpty) {
        if (!typeFormals.every((t) => t.name == 'dynamic')) {
          buf.write('&lt;<wbr><span class="type-parameter">');
          buf.writeAll(typeFormals.map((t) => t.name),
              '</span>, <span class="type-parameter">');
          buf.write('</span>&gt;');
        }
      }
      _nameWithGenerics = buf.toString();
    }
    return _nameWithGenerics;
  }

  List<TypeParameter> get typeFormals {
    List<TypeParameterElement> typeFormals = (type as FunctionType).typeFormals;
    return UnmodifiableListView<TypeParameter>(typeFormals
        .map(
            (p) => ModelElement.from(p, library, packageGraph) as TypeParameter)
        .toList());
  }

  @override
  String get name => 'Function';
}

class ParameterizedElementType extends DefinedElementType {
  ParameterizedElementType(ParameterizedType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom);

  String _linkedName;
  @override
  String get linkedName {
    if (_linkedName == null) {
      StringBuffer buf = StringBuffer();

      buf.write(element.linkedName);

      if (!typeArguments.every((t) => t.name == 'dynamic') &&
          typeArguments.isNotEmpty) {
        buf.write('<span class="signature">');
        buf.write('&lt;<wbr><span class="type-parameter">');
        buf.writeAll(typeArguments.map((t) => t.linkedName),
            '</span>, <span class="type-parameter">');
        buf.write('</span>&gt;');
        buf.write('</span>');
      }

      _linkedName = buf.toString();
    }
    return _linkedName;
  }

  String _nameWithGenerics;
  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      StringBuffer buf = StringBuffer();

      buf.write(element.name);

      if (!typeArguments.every((t) => t.name == 'dynamic') &&
          typeArguments.isNotEmpty) {
        buf.write('&lt;<wbr><span class="type-parameter">');
        buf.writeAll(typeArguments.map((t) => t.nameWithGenerics),
            '</span>, <span class="type-parameter">');
        buf.write('</span>&gt;');
      }
      _nameWithGenerics = buf.toString();
    }
    return _nameWithGenerics;
  }
}

class TypeParameterElementType extends DefinedElementType {
  TypeParameterElementType(TypeParameterType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom);

  @override
  String get linkedName => name;

  String _nameWithGenerics;
  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      _nameWithGenerics = name;
    }
    return _nameWithGenerics;
  }
}

/// An [ElementType] associated with an [Element].
abstract class DefinedElementType extends ElementType {
  final ModelElement _element;

  DefinedElementType(DartType type, Library library, PackageGraph packageGraph,
      this._element, ElementType returnedFrom)
      : super(type, library, packageGraph, returnedFrom);

  ModelElement get element {
    assert(_element != null);
    return _element;
  }

  bool get isParameterType => (type is TypeParameterType);

  /// This type is a public type if the underlying, canonical element is public.
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    Container canonicalClass =
        element.packageGraph.findCanonicalModelElementFor(element.element) ??
            element;
    return canonicalClass.isPublic;
  }

  @override
  bool get isTypedef => element is Typedef || element is ModelFunctionTypedef;

  @override
  List<Parameter> get parameters =>
      element.canHaveParameters ? element.parameters : [];

  ModelElement get returnElement => element;
  ElementType _returnType;
  ElementType get returnType {
    if (_returnType == null) {
      _returnType = ElementType.from(type, library, packageGraph, this);
    }
    return _returnType;
  }

  @override
  String createLinkedReturnTypeName() => returnType.linkedName;

  Iterable<ElementType> _typeArguments;
  Iterable<ElementType> get typeArguments {
    if (_typeArguments == null) {
      _typeArguments = (type as ParameterizedType)
          .typeArguments
          .map((f) => ElementType.from(f, library, packageGraph))
          .toList();
    }
    return _typeArguments;
  }
}

/// Any callable ElementType will mix-in this class, whether anonymous or not.
abstract class CallableElementTypeMixin implements ParameterizedElementType {
  @override
  ModelElement get returnElement => returnType is DefinedElementType
      ? (returnType as DefinedElementType).element
      : null;

  @override
  ElementType get returnType {
    if (_returnType == null) {
      _returnType =
          ElementType.from(type.returnType, library, packageGraph, this);
    }
    return _returnType;
  }

  @override
  FunctionType get type => _type;

  @override
  // TODO(jcollins-g): Rewrite this and improve object model so this doesn't
  // require type checking everywhere.
  Iterable<ElementType> get typeArguments {
    DefinedElementType elementType = returnedFrom as DefinedElementType;
    if (_typeArguments == null) {
      Iterable<DartType> dartTypeArguments;
      if (type.typeFormals.isEmpty &&
          element is! ModelFunctionAnonymous &&
          elementType?.element is! ModelFunctionAnonymous) {
        dartTypeArguments = type.typeArguments;
      } else if (returnedFrom != null &&
          returnedFrom.type.element is GenericFunctionTypeElement) {
        _typeArguments = elementType.typeArguments;
      } else {
        dartTypeArguments = type.typeFormals.map((f) => f.type);
      }
      if (dartTypeArguments != null) {
        _typeArguments = dartTypeArguments
            .map((f) => ElementType.from(f, library, packageGraph))
            .toList();
      }
    }
    return _typeArguments;
  }
}

/// A callable type that may or may not be backed by a declaration using the generic
/// function syntax.
class CallableElementType extends ParameterizedElementType
    with CallableElementTypeMixin {
  CallableElementType(FunctionType t, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(t, library, packageGraph, element, returnedFrom);

  @override
  String get linkedName {
    if (name != null && name.isNotEmpty) return super.linkedName;
    return '${nameWithGenerics}(${linkedParams(element.parameters, showNames: false).trim()}) → ${returnType.linkedName}';
  }
}

/// This is an anonymous function using the generic function syntax (declared
/// literally with "Function").
class CallableAnonymousElementType extends CallableElementType {
  CallableAnonymousElementType(FunctionType t, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(t, library, packageGraph, element, returnedFrom);
  @override
  String get name => 'Function';

  @override
  String get linkedName {
    if (_linkedName == null) {
      _linkedName =
          '${returnType.linkedName} ${super.linkedName}<span class="signature">(${linkedParams(element.parameters)})</span>';
    }
    return _linkedName;
  }
}

/// Types backed by a [GenericTypeAliasElement] that may or may not be callable.
abstract class GenericTypeAliasElementTypeMixin {}

/// A non-callable type backed by a [GenericTypeAliasElement].
class GenericTypeAliasElementType extends TypeParameterElementType
    with GenericTypeAliasElementTypeMixin {
  GenericTypeAliasElementType(TypeParameterType t, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(t, library, packageGraph, element, returnedFrom);
}

/// A Callable generic type alias that may or may not have a name.
class CallableGenericTypeAliasElementType extends ParameterizedElementType
    with CallableElementTypeMixin, GenericTypeAliasElementTypeMixin {
  CallableGenericTypeAliasElementType(FunctionType t, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(t, library, packageGraph, element, returnedFrom);

  ModelElement _returnElement;
  @override
  ModelElement get returnElement {
    if (_returnElement == null) {
      _returnElement =
          ModelElement.fromElement(type.element.enclosingElement, packageGraph);
    }
    return _returnElement;
  }

  @override
  ElementType get returnType {
    if (_returnType == null) {
      _returnType = ElementType.from(
          returnElement.modelType.type, library, packageGraph, this);
    }
    return _returnType;
  }
}
