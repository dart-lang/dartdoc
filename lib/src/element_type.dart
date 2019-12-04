// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';

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
          return CallableGenericTypeAliasElementType(
              f, library, packageGraph, element, returnedFrom);
        }
        return CallableElementType(
            f, library, packageGraph, element, returnedFrom);
      } else if (isGenericTypeAlias) {
        assert(f is TypeParameterType);
        return GenericTypeAliasElementType(
            f, library, packageGraph, element, returnedFrom);
      }
      if (f is TypeParameterType) {
        return TypeParameterElementType(
            f, library, packageGraph, element, returnedFrom);
      }
      assert(f is ParameterizedType);
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

/// A FunctionType that does not have an underpinning Element.
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
      _linkedName = _renderer.renderLinkedName(this);
    }
    return _linkedName;
  }

  @override
  String createLinkedReturnTypeName() => returnType.linkedName;

  String _nameWithGenerics;

  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      _nameWithGenerics = _renderer.renderNameWithGenerics(this);
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

  ElementTypeRenderer<FunctionTypeElementType> get _renderer =>
      packageGraph.rendererFactory.functionTypeElementTypeRenderer;
}

class ParameterizedElementType extends DefinedElementType {
  ParameterizedElementType(ParameterizedType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom);

  String _linkedName;
  @override
  String get linkedName {
    if (_linkedName == null) {
      _linkedName = _renderer.renderLinkedName(this);
    }
    return _linkedName;
  }

  String _nameWithGenerics;
  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      _nameWithGenerics = _renderer.renderNameWithGenerics(this);
    }
    return _nameWithGenerics;
  }

  ElementTypeRenderer<ParameterizedElementType> get _renderer =>
      packageGraph.rendererFactory.parameterizedElementTypeRenderer;
}

class TypeParameterElementType extends DefinedElementType {
  TypeParameterElementType(TypeParameterType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom);

  @override
  String get linkedName => name;

  @override
  String get nameWithGenerics => name;

  @override
  ClassElement get _boundClassElement => interfaceType.element;

  @override
  InterfaceType get interfaceType => (type as TypeParameterType).bound;
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

  /// By default, the bound is the type of the declared class.
  ClassElement get _boundClassElement => (element.element as ClassElement);
  Class get boundClass =>
      ModelElement.fromElement(_boundClassElement, packageGraph);
  InterfaceType get interfaceType => type;

  InterfaceType _instantiatedType;

  /// Return this type, instantiated to bounds if it isn't already.
  DartType get instantiatedType {
    if (_instantiatedType == null) {
      if (!interfaceType.typeArguments.every((t) => t is InterfaceType)) {
        _instantiatedType =
            packageGraph.typeSystem.instantiateToBounds(interfaceType);
      } else {
        _instantiatedType = interfaceType;
      }
    }
    return _instantiatedType;
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
    if (_typeArguments == null) {
      Iterable<DartType> dartTypeArguments;
      if (returnedFrom is FunctionTypeElementType) {
        if (type.typeFormals.isEmpty) {
          dartTypeArguments = type.typeArguments;
        } else {
          dartTypeArguments = type.typeFormals.map(_legacyTypeParameterType);
        }
      } else {
        if (type.typeFormals.isEmpty) {
          dartTypeArguments = type.typeArguments;
        } else if (returnedFrom != null &&
            returnedFrom.type.element is GenericFunctionTypeElement) {
          _typeArguments = (returnedFrom as DefinedElementType).typeArguments;
        } else {
          dartTypeArguments = type.typeFormals.map(_legacyTypeParameterType);
        }
      }
      if (dartTypeArguments != null) {
        _typeArguments = dartTypeArguments
            .map((f) => ElementType.from(f, library, packageGraph))
            .toList();
      }
    }
    return _typeArguments;
  }

  /// Return the [TypeParameterType] with the legacy nullability for the given
  /// type parameter [element].
  ///
  /// TODO(scheglov) This method is a work around that fact that DartDoc
  /// currently represents both type formals and uses of them as actual types,
  /// as [TypeParameterType]s. This was not perfect, but worked before NNBD.
  /// With NNBD types have nullability suffixes, but type formals should not.
  /// Eventually we should separate models for type formals and types.
  static TypeParameterType _legacyTypeParameterType(
    TypeParameterElement element,
  ) {
    return element.instantiate(nullabilitySuffix: NullabilitySuffix.star);
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
    if (_linkedName == null) {
      _linkedName = _renderer.renderLinkedName(this);
    }
    return _linkedName;
  }

  String get superLinkedName => super.linkedName;

  @override
  ElementTypeRenderer<CallableElementType> get _renderer =>
      packageGraph.rendererFactory.callableElementTypeRenderer;
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
      _returnType =
          ElementType.from(type.returnType, library, packageGraph, this);
    }
    return _returnType;
  }
}
