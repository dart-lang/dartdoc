// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_element_builder.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';

/// Base class representing a type in Dartdoc.  It wraps a [DartType], and
/// may link to a [ModelElement].
abstract class ElementType extends Privacy with CommentReferable, Nameable, ModelBuilderInterface {
  final DartType _type;
  @override
  final PackageGraph packageGraph;
  final ElementType returnedFrom;
  @override
  final Library library;

  ElementType(this._type, this.library, this.packageGraph, this.returnedFrom);

  factory ElementType.from(
      DartType f, Library library, PackageGraph packageGraph,
      {ElementType returnedFrom}) {
    if (f.element == null ||
        f.element.kind == ElementKind.DYNAMIC ||
        f.element.kind == ElementKind.NEVER) {
      if (f is FunctionType) {
        if (f.alias?.element != null) {
          return AliasedFunctionTypeElementType(
              f, library, packageGraph, returnedFrom);
        }
        return FunctionTypeElementType(f, library, packageGraph, returnedFrom);
      }
      return UndefinedElementType(f, library, packageGraph, returnedFrom);
    } else {
      var element = packageGraph.modelBuilder.fromElement(f.element);
      // [TypeAliasElement.aliasElement] has different implications.
      // In that case it is an actual type alias of some kind (generic
      // or otherwise.   Here however aliasElement signals that this is a
      // type referring to an alias.
      if (f is! TypeAliasElement && f.alias?.element != null) {
        return AliasedElementType(
            f, library, packageGraph, element, returnedFrom);
      }
      assert(f is ParameterizedType || f is TypeParameterType);
      // TODO(jcollins-g): strip out all the cruft that's accumulated
      // here for non-generic type aliases.
      var isGenericTypeAlias = f.alias?.element != null && f is! InterfaceType;
      if (f is FunctionType) {
        assert(f is ParameterizedType);
        // This is an indication we have an extremely out of date analyzer....
        assert(
            !isGenericTypeAlias, 'should never occur: out of date analyzer?');
        // And finally, delete this case and its associated class
        // after https://dart-review.googlesource.com/c/sdk/+/201520
        // is in all published versions of analyzer this version of dartdoc
        // is compatible with.
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

  DartType get instantiatedType;

  Iterable<ElementType> get typeArguments;

  bool isBoundSupertypeTo(ElementType t);
  bool isSubtypeOf(ElementType t);

  @override
  String toString() => '$type';

  DartType get type => _type;

  ModelElementBuilder _modelBuilder;
  @override
  ModelElementBuilder get modelBuilder => _modelBuilder ??= ModelElementBuilderImpl(packageGraph);
}

/// An [ElementType] that isn't pinned to an Element (or one that is, but whose
/// element is irrelevant).
class UndefinedElementType extends ElementType {
  UndefinedElementType(DartType f, Library library, PackageGraph packageGraph,
      ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom);

  @override
  Element get element => null;

  @override
  bool get isPublic => true;

  @override
  String get name {
    if (type.isVoid) return 'void';
    assert({'Never', 'void', 'dynamic'}.contains(type.element.name),
        'Unrecognized type for UndefinedElementType: ${type.toString()}');
    return type.element.name;
  }

  @override
  String get nameWithGenerics => '$name$nullabilitySuffix';

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
  Iterable<ElementType> get typeArguments => [];

  @override
  Map<String, CommentReferable> get referenceChildren => {};

  @override
  Iterable<CommentReferable> get referenceParents => [];

  @override
  Iterable<CommentReferable> get referenceGrandparentOverrides => null;

}

/// A FunctionType that does not have an underpinning Element.
class FunctionTypeElementType extends UndefinedElementType
    with Rendered, Callable {
  FunctionTypeElementType(FunctionType f, Library library,
      PackageGraph packageGraph, ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom);

  /// An unmodifiable list of this function element's type parameters.
  List<TypeParameter> get typeFormals => type.typeFormals
      .map((p) => packageGraph.modelBuilder.from(p, library) as TypeParameter)
      .toList(growable: false);

  @override
  String get name => 'Function';

  @override
  ElementTypeRenderer get _renderer =>
      packageGraph.rendererFactory.functionTypeElementTypeRenderer;
}

class AliasedFunctionTypeElementType extends FunctionTypeElementType
    with Aliased {
  AliasedFunctionTypeElementType(FunctionType f, Library library,
      PackageGraph packageGraph, ElementType returnedFrom)
      : super(f, library, packageGraph, returnedFrom) {
    assert(type.alias?.element != null);
    assert(type.alias?.typeArguments != null);
  }

  @override
  ElementTypeRenderer<AliasedFunctionTypeElementType> get _renderer =>
      packageGraph.rendererFactory.aliasedFunctionTypeElementTypeRenderer;
}

class ParameterizedElementType extends DefinedElementType with Rendered {
  ParameterizedElementType(ParameterizedType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom);

  @override
  ParameterizedType get type => super.type;

  @override
  ElementTypeRenderer<ParameterizedElementType> get _renderer =>
      packageGraph.rendererFactory.parameterizedElementTypeRenderer;

  Iterable<ElementType> _typeArguments;
  @override
  Iterable<ElementType> get typeArguments =>
      _typeArguments ??= type.typeArguments
          .map((f) => ElementType.from(f, library, packageGraph))
          .toList(growable: false);
}

/// A [ElementType] whose underlying type was referrred to by a type alias.
mixin Aliased implements ElementType, ModelBuilderInterface {
  @override
  String get name => type.alias.element.name;

  @override
  bool get isTypedef => true;

  ModelElement _aliasElement;
  ModelElement get aliasElement => _aliasElement ??=
      modelBuilder.fromElement(type.alias.element);

  Iterable<ElementType> _aliasArguments;
  Iterable<ElementType> get aliasArguments =>
      _aliasArguments ??= type.alias.typeArguments
          .map((f) => ElementType.from(f, library, packageGraph))
          .toList(growable: false);
}

class AliasedElementType extends ParameterizedElementType with Aliased {
  AliasedElementType(ParameterizedType type, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(type, library, packageGraph, element, returnedFrom) {
    assert(type.alias?.element != null);
  }

  @override
  ParameterizedType get type;

  /// Parameters, if available, for the underlying typedef.
  List<Parameter> get aliasedParameters =>
      modelElement.isCallable ? modelElement.parameters : [];

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
  final ModelElement _modelElement;

  DefinedElementType(DartType type, Library library, PackageGraph packageGraph,
      this._modelElement, ElementType returnedFrom)
      : super(type, library, packageGraph, returnedFrom);

  @override
  Element get element => modelElement.element;

  ModelElement get modelElement {
    assert(_modelElement != null);
    return _modelElement;
  }

  @override
  String get name => type.element.name;

  @override
  String get fullyQualifiedName => modelElement.fullyQualifiedName;

  bool get isParameterType => (type is TypeParameterType);

  /// This type is a public type if the underlying, canonical element is public.
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    Container canonicalClass = modelElement.packageGraph
            .findCanonicalModelElementFor(modelElement.element) ??
        modelElement;
    return canonicalClass?.isPublic ?? false;
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

  @override
  Iterable<ElementType> get typeArguments => [];

  @override
  Map<String, CommentReferable> get referenceChildren =>
      modelElement.referenceChildren;

  @override
  Iterable<CommentReferable> get referenceParents =>
      modelElement.referenceParents;

  @override
  Iterable<CommentReferable> get referenceGrandparentOverrides =>
      modelElement.referenceGrandparentOverrides;
}

/// Any callable ElementType will mix-in this class, whether anonymous or not,
/// unless it is an alias reference.
mixin Callable implements ElementType {
  List<Parameter> get parameters => type.parameters
      .map((p) => modelBuilder.from(p, library) as Parameter)
      .toList(growable: false);

  ElementType _returnType;
  ElementType get returnType {
    _returnType ??= ElementType.from(type.returnType, library, packageGraph);
    return _returnType;
  }

  @override
  // TODO(jcollins-g): mustachio should not require this
  String get linkedName;

  @override
  FunctionType get type => _type;
}

/// This [ElementType] uses an [ElementTypeRenderer] to generate
/// some of its parameters.
mixin Rendered implements ElementType {
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

  ElementTypeRenderer<ElementType> get _renderer;
}

/// A callable type that may or may not be backed by a declaration using the generic
/// function syntax.
class CallableElementType extends DefinedElementType with Rendered, Callable {
  CallableElementType(FunctionType t, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(t, library, packageGraph, element, returnedFrom);

  @override
  String get name =>
      super.name != null && super.name.isNotEmpty ? super.name : 'Function';

  @override
  ElementTypeRenderer<CallableElementType> get _renderer =>
      packageGraph.rendererFactory.callableElementTypeRenderer;

  Iterable<ElementType> _typeArguments;
  @override
  Iterable<ElementType> get typeArguments =>
      _typeArguments ??= (type.alias?.typeArguments ?? [])
          .map((f) => ElementType.from(f, library, packageGraph))
          .toList(growable: false);
}

/// A non-callable type backed by a [GenericTypeAliasElement].
class GenericTypeAliasElementType extends TypeParameterElementType {
  GenericTypeAliasElementType(TypeParameterType t, Library library,
      PackageGraph packageGraph, ModelElement element, ElementType returnedFrom)
      : super(t, library, packageGraph, element, returnedFrom);
}
