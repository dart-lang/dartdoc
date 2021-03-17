// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

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
    if (f.element == null ||
        f.element.kind == ElementKind.DYNAMIC ||
        f.element.kind == ElementKind.NEVER) {
      if (f is FunctionType) {
        return FunctionTypeElementType(f, library, packageGraph, returnedFrom);
      }
      return UndefinedElementType(f, library, packageGraph, returnedFrom);
    } else {
      var element = ModelElement.fromElement(f.element, packageGraph);
      // [TypeAliasElement.aliasElement] has different implications.
      // In that case it is an actual type alias of some kind (generic
      // or otherwise.   Here however aliasElement signals that this is a
      // type referring to an alias.
      if (f is! TypeAliasElement && f.aliasElement != null) {
        return AliasedElementType(
            f, library, packageGraph, element, returnedFrom);
      }
      assert(f is ParameterizedType || f is TypeParameterType);
      // TODO(jcollins-g): strip out all the cruft that's accumulated
      // here for non-generic type aliases.
      var isGenericTypeAlias = f.aliasElement != null && f is! InterfaceType;
      if (f is FunctionType) {
        assert(f is ParameterizedType);
        if (isGenericTypeAlias) {
          return CallableGenericTypeAliasElementType(
              f, library, packageGraph, element, returnedFrom);
        }
        return CallableElementType(
            f, library, packageGraph, element, returnedFrom);
      } else if (isGenericTypeAlias) {
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

  bool get isTypedef => false;

  String get linkedName;

  String get name;

  /// Name with generics and nullability indication.
  String get nameWithGenerics;

  /// Return a dartdoc nullability suffix for this type.
  String get nullabilitySuffix {
    if (library.isNullSafety && !type.isVoid && !type.isBottom) {
      /// If a legacy type appears inside the public interface of a Null
      /// safety library, we pretend it is nullable for the purpose of
      /// documentation (since star-types are not supposed to be public).
      if (type.nullabilitySuffix == NullabilitySuffix.question ||
          type.nullabilitySuffix == NullabilitySuffix.star) {
        return '?';
      }
    }
    return '';
  }

  /// An unmodifiable list of this element type's parameters.
  List<Parameter> get parameters;

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
    if (isImpliedFuture) return 'Future';
    if (type.isVoid) return 'void';
    assert({'Never', 'void', 'dynamic'}.contains(type.element.name),
        'Unrecognized type for UndefinedElementType: ${type.toString()}');
    return type.element.name;
  }

  /// Returns true if this type is an implied `Future`.
  bool get isImpliedFuture => (type.isDynamic &&
      returnedFrom != null &&
      returnedFrom is DefinedElementType &&
      (returnedFrom as DefinedElementType).element.isAsynchronous);

  @override
  String get nameWithGenerics => '$name$nullabilitySuffix';

  @override
  String get nullabilitySuffix =>
      isImpliedFuture && library.isNullSafety ? '?' : super.nullabilitySuffix;

  /// Assume that undefined elements don't have useful bounds.
  @override
  DartType get instantiatedType => type;

  @override
  bool isBoundSupertypeTo(ElementType t) => false;

  @override
  bool isSubtypeOf(ElementType t) => type.isBottom && !t.type.isBottom;

  @override
  String get linkedName => name;

  @override
  // TODO(jcollins-g): remove the need for an empty list here.
  List<Parameter> get parameters => [];
}

/// A FunctionType that does not have an underpinning Element.
class FunctionTypeElementType extends UndefinedElementType
    with CallableElementTypeMixin {
  FunctionTypeElementType(DartType f, Library library,
      PackageGraph packageGraph, ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom);

  @override
  List<Parameter> get parameters => type.parameters
      .map((p) => ModelElement.from(p, library, packageGraph) as Parameter)
      .toList(growable: false);

  @override
  ElementType get returnType =>
      ElementType.from(type.returnType, library, packageGraph, this);

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

  /// An unmodifiable list of this function element's type parameters.
  List<TypeParameter> get typeFormals => type.typeFormals
      .map((p) => ModelElement.from(p, library, packageGraph) as TypeParameter)
      .toList(growable: false);

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

class AliasedElementType extends ParameterizedElementType {
  AliasedElementType(ParameterizedType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom) {
    assert(type.aliasElement != null);
  }

  ModelElement _aliasElement;
  ModelElement get aliasElement => _aliasElement ??=
      ModelElement.fromElement(type.aliasElement, packageGraph);

  Iterable<ElementType> _aliasArguments;
  Iterable<ElementType> get aliasArguments =>
      _aliasArguments ??= type.aliasArguments
          .map((f) => ElementType.from(f, library, packageGraph))
          .toList(growable: false);

  @override
  ElementTypeRenderer<AliasedElementType> get _renderer =>
      packageGraph.rendererFactory.aliasedElementTypeRenderer;
}

class TypeParameterElementType extends DefinedElementType {
  TypeParameterElementType(TypeParameterType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom);

  @override
  TypeParameterType get type => super.type;

  @override
  String get linkedName => '$name$nullabilitySuffix';

  @override
  String get nameWithGenerics => '$name$nullabilitySuffix';

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
      element.isCallable ? element.parameters : [];

  ModelElement get returnElement => element;
  ElementType _returnType;
  ElementType get returnType {
    _returnType ??= ElementType.from(type, library, packageGraph, this);
    return _returnType;
  }

  Iterable<ElementType> _typeArguments;

  /// An unmodifiable list of this element type's parameters.
  Iterable<ElementType> get typeArguments =>
      _typeArguments ??= (type as ParameterizedType)
          .typeArguments
          .map((f) => ElementType.from(f, library, packageGraph))
          .toList(growable: false);

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
  bool isBoundSupertypeTo(ElementType t) {
    var type = t.instantiatedType;
    if (type is InterfaceType) {
      var superTypes = type.allSupertypes;
      for (var superType in superTypes) {
        if (library.typeSystem.isSubtypeOf(superType, instantiatedType)) {
          return true;
        }
      }
    }
    return false;
  }
}

/// Any callable ElementType will mix-in this class, whether anonymous or not.
abstract class CallableElementTypeMixin implements ElementType {
  Iterable<ElementType> _typeArguments;

  ModelElement get returnElement => returnType is DefinedElementType
      ? (returnType as DefinedElementType).element
      : null;

  ElementType _returnType;
  ElementType get returnType {
    _returnType ??=
        ElementType.from(type.returnType, library, packageGraph, this);
    return _returnType;
  }

  @override
  FunctionType get type => _type;

  // TODO(jcollins-g): Rewrite this and improve object model so this doesn't
  // require type checking everywhere.
  Iterable<ElementType> get typeArguments {
    if (_typeArguments == null) {
      Iterable<DartType> dartTypeArguments;
      if (returnedFrom is FunctionTypeElementType) {
        if (type.typeFormals.isEmpty) {
          dartTypeArguments = type.aliasArguments;
        } else {
          dartTypeArguments = type.typeFormals.map(_legacyTypeParameterType);
        }
      } else {
        if (type.typeFormals.isEmpty) {
          dartTypeArguments = type.aliasArguments;
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
  /// TODO(scheglov): This method is a work around that fact that DartDoc
  /// currently represents both type formals and uses of them as actual types,
  /// as [TypeParameterType]s. This was not perfect, but worked before Null
  /// safety. With Null safety, types have nullability suffixes, but type
  /// formals should not. Eventually we should separate models for type formals
  /// and types.
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
      if (name != null && name.isNotEmpty) {
        _linkedName = super.linkedName;
      } else {
        _linkedName = _renderer.renderLinkedName(this);
      }
    }
    return _linkedName;
  }

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
    _returnElement ??= ModelElement.fromElement(
        type.aliasElement.enclosingElement, packageGraph);
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
