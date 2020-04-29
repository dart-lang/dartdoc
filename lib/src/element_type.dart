// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart' show ClassElementImpl;
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
    if (f.element == null ||
        f.element.kind == ElementKind.DYNAMIC ||
        f.element.kind == ElementKind.NEVER) {
      if (f is FunctionType) {
        return FunctionTypeElementType(f, library, packageGraph, returnedFrom);
      }
      return UndefinedElementType(f, library, packageGraph, returnedFrom);
    } else {
      var element = ModelElement.fromElement(f.element, packageGraph);
      assert(f is ParameterizedType || f is TypeParameterType);
      var isGenericTypeAlias =
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

  String get name;

  String get nameWithGenerics;

  List<Parameter> get parameters => [];

  DartType get instantiatedType;

  bool isBoundSupertypeTo(ElementType t);
  bool isSubtypeOf(ElementType t);

  @override
  String toString() => '$type';

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
  String get name {
    if (type.isDynamic) {
      if (returnedFrom != null &&
          (returnedFrom is DefinedElementType &&
              (returnedFrom as DefinedElementType).element.isAsynchronous)) {
        return 'Future';
      } else {
        return 'dynamic';
      }
    }
    if (type.isVoid) return 'void';
    if (type.isBottom) return 'Never';
    assert(false,
        'Unrecognized type for UndefinedElementType: ${type.toString()}');
    return '';
  }

  @override
  String get nameWithGenerics => name;

  /// Assume that undefined elements don't have useful bounds.
  @override
  DartType get instantiatedType => type;

  @override
  bool isBoundSupertypeTo(ElementType t) => false;

  @override
  bool isSubtypeOf(ElementType t) => type.isBottom && !t.type.isBottom;

  @override
  String get linkedName => name;
}

/// A FunctionType that does not have an underpinning Element.
class FunctionTypeElementType extends UndefinedElementType {
  FunctionTypeElementType(DartType f, Library library,
      PackageGraph packageGraph, ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom);

  @override
  FunctionType get type => super.type;

  @override
  List<Parameter> get parameters {
    var params = type.parameters;
    return UnmodifiableListView<Parameter>(params
        .map((p) => ModelElement.from(p, library, packageGraph) as Parameter)
        .toList());
  }

  ElementType get returnType =>
      ElementType.from(type.returnType, library, packageGraph, this);

  @override
  String get linkedName {
    _linkedName ??= _renderer.renderLinkedName(this);
    return _linkedName;
  }

  @override
  String createLinkedReturnTypeName() => returnType.linkedName;

  String _nameWithGenerics;

  @override
  String get nameWithGenerics {
    _nameWithGenerics ??= _renderer.renderNameWithGenerics(this);
    return _nameWithGenerics;
  }

  List<TypeParameter> get typeFormals {
    var typeFormals = type.typeFormals;
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
    _linkedName ??= _renderer.renderLinkedName(this);
    return _linkedName;
  }

  String _nameWithGenerics;
  @override
  String get nameWithGenerics {
    _nameWithGenerics ??= _renderer.renderNameWithGenerics(this);
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
  TypeParameterType get type => super.type;

  @override
  String get linkedName => name;

  @override
  String get nameWithGenerics => name;

  @override
  DartType get _bound => type.bound;
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

  @override
  String get name => type.element.name;

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
    _returnType ??= ElementType.from(type, library, packageGraph, this);
    return _returnType;
  }

  @override
  String createLinkedReturnTypeName() => returnType.linkedName;

  Iterable<ElementType> _typeArguments;
  Iterable<ElementType> get typeArguments {
    _typeArguments ??= (type as ParameterizedType)
        .typeArguments
        .map((f) => ElementType.from(f, library, packageGraph))
        .toList();
    return _typeArguments;
  }

  DartType get _bound => type;

  DartType _instantiatedType;

  /// Return this type, instantiated to bounds if it isn't already.
  @override
  DartType get instantiatedType {
    if (_instantiatedType == null) {
      if (_bound is InterfaceType &&
          !(_bound as InterfaceType)
              .typeArguments
              .every((t) => t is InterfaceType)) {
        var typeSystem = library.element.typeSystem;
        _instantiatedType = typeSystem.instantiateToBounds2(
            classElement: _bound.element as ClassElement,
            nullabilitySuffix: _bound.nullabilitySuffix);
      } else {
        _instantiatedType = _bound;
      }
    }
    return _instantiatedType;
  }

  /// The instantiated to bounds type of this type is a subtype of
  /// [t].
  @override
  bool isSubtypeOf(ElementType t) =>
      library.typeSystem.isSubtypeOf(instantiatedType, t.instantiatedType);

  /// Returns true if at least one supertype (including via mixins and
  /// interfaces) is equivalent to or a subtype of [this] when
  /// instantiated to bounds.
  @override
  bool isBoundSupertypeTo(ElementType t) =>
      _isBoundSupertypeTo(t.instantiatedType, HashSet());

  bool _isBoundSupertypeTo(DartType superType, HashSet<DartType> visited) {
    // Only InterfaceTypes can have superTypes.
    if (superType is! InterfaceType) return false;
    ClassElement superClass = superType?.element;
    if (visited.contains(superType)) return false;
    visited.add(superType);
    if (superClass == type.element &&
        (superType == instantiatedType ||
            library.typeSystem.isSubtypeOf(superType, instantiatedType))) {
      return true;
    }
    var supertypes = <InterfaceType>[];
    ClassElementImpl.collectAllSupertypes(supertypes, superType, null);
    for (var toVisit in supertypes) {
      if (_isBoundSupertypeTo(toVisit, visited)) return true;
    }
    return false;
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
    _returnType ??=
        ElementType.from(type.returnType, library, packageGraph, this);
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
    _linkedName ??= _renderer.renderLinkedName(this);
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
    _returnElement ??=
        ModelElement.fromElement(type.element.enclosingElement, packageGraph);
    return _returnElement;
  }

  @override
  ElementType get returnType {
    _returnType ??=
        ElementType.from(type.returnType, library, packageGraph, this);
    return _returnType;
  }

  @override
  DartType get instantiatedType => type;
}
