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
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:meta/meta.dart';

mixin ElementTypeBuilderImpl implements ElementTypeBuilder {
  PackageGraph get packageGraph;

  @override
  ElementType typeFrom(DartType f, Library library) =>
      ElementType._from(f, library, packageGraph);
}

/// Base class representing a type in Dartdoc.  It wraps a [DartType], and
/// may link to a [ModelElement].
abstract class ElementType extends Privacy
    with CommentReferable, Nameable, ModelBuilder {
  final DartType type;
  @override
  final PackageGraph packageGraph;
  @override
  final Library library;

  ElementType(this.type, this.library, this.packageGraph);

  factory ElementType._from(
      DartType f, Library library, PackageGraph packageGraph) {
    var fElement = f.element;
    if (fElement == null ||
        fElement.kind == ElementKind.DYNAMIC ||
        fElement.kind == ElementKind.NEVER) {
      // [UndefinedElementType]s.
      if (f is FunctionType) {
        if (f.alias?.element != null) {
          return AliasedFunctionTypeElementType(f, library, packageGraph);
        }
        return FunctionTypeElementType(f, library, packageGraph);
      }
      return UndefinedElementType(f, library, packageGraph);
    }
    // [DefinedElementType]s.
    var element = packageGraph.modelBuilder.fromElement(fElement);
    // [TypeAliasElement.aliasElement] has different implications.
    // In that case it is an actual type alias of some kind (generic
    // or otherwise.   Here however aliasElement signals that this is a
    // type referring to an alias.
    if (f is! TypeAliasElement && f.alias?.element != null) {
      return AliasedElementType(
          f as ParameterizedType, library, packageGraph, element);
    }
    assert(f is ParameterizedType || f is TypeParameterType);
    // TODO(jcollins-g): strip out all the cruft that's accumulated
    // here for non-generic type aliases.
    var isGenericTypeAlias = f.alias?.element != null && f is! InterfaceType;
    if (f is FunctionType) {
      assert(f is ParameterizedType);
      // This is an indication we have an extremely out of date analyzer....
      assert(!isGenericTypeAlias, 'should never occur: out of date analyzer?');
      // And finally, delete this case and its associated class
      // after https://dart-review.googlesource.com/c/sdk/+/201520
      // is in all published versions of analyzer this version of dartdoc
      // is compatible with.
      return CallableElementType(f, library, packageGraph, element);
    } else if (isGenericTypeAlias) {
      return GenericTypeAliasElementType(
          f as TypeParameterType, library, packageGraph, element);
    }
    if (f is TypeParameterType) {
      return TypeParameterElementType(f, library, packageGraph, element);
    }
    assert(f is ParameterizedType);
    return ParameterizedElementType(
        f as ParameterizedType, library, packageGraph, element);
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
}

/// An [ElementType] that isn't pinned to an Element (or one that is, but whose
/// element is irrelevant).
class UndefinedElementType extends ElementType {
  UndefinedElementType(super.f, super.library, super.packageGraph);

  @override
  bool get isPublic => true;

  @override
  String get name {
    if (type.isVoid) return 'void';
    assert((const {'Never', 'void', 'dynamic'}).contains(type.element!.name),
        'Unrecognized type for UndefinedElementType: ${type.toString()}');
    return type.element!.name!;
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
  Iterable<CommentReferable>? get referenceGrandparentOverrides => null;
}

/// A FunctionType that does not have an underpinning Element.
class FunctionTypeElementType extends UndefinedElementType
    with Rendered, Callable {
  FunctionTypeElementType(
      FunctionType super.f, super.library, super.packageGraph);

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
  AliasedFunctionTypeElementType(super.f, super.library, super.packageGraph) {
    assert(type.alias?.element != null);
    assert(type.alias?.typeArguments != null);
  }

  @override
  ElementTypeRenderer<AliasedFunctionTypeElementType> get _renderer =>
      packageGraph.rendererFactory.aliasedFunctionTypeElementTypeRenderer;
}

class ParameterizedElementType extends DefinedElementType with Rendered {
  ParameterizedElementType(ParameterizedType super.type, super.library,
      super.packageGraph, super.element);

  @override
  ParameterizedType get type => super.type as ParameterizedType;

  @override
  ElementTypeRenderer<ParameterizedElementType> get _renderer =>
      packageGraph.rendererFactory.parameterizedElementTypeRenderer;

  @override
  late final Iterable<ElementType> typeArguments = type.typeArguments
      .map((f) => modelBuilder.typeFrom(f, library))
      .toList(growable: false);
}

/// A [ElementType] whose underlying type was referred to by a type alias.
mixin Aliased implements ElementType, ModelBuilderInterface {
  late final Element typeAliasElement = type.alias!.element;

  @override
  String get name => typeAliasElement.name!;

  @override
  bool get isTypedef => true;

  late final ModelElement aliasElement =
      modelBuilder.fromElement(typeAliasElement);

  late final Iterable<ElementType> aliasArguments = type.alias!.typeArguments
      .map((f) => modelBuilder.typeFrom(f, library))
      .toList(growable: false);
}

class AliasedElementType extends ParameterizedElementType with Aliased {
  AliasedElementType(
      super.type, super.library, super.packageGraph, super.element)
      : assert(type.alias?.element != null);

  @override
  ParameterizedType get type;

  /// Parameters, if available, for the underlying typedef.
  late final List<Parameter> aliasedParameters =
      modelElement.isCallable ? modelElement.parameters : [];

  @override
  ElementTypeRenderer<AliasedElementType> get _renderer =>
      packageGraph.rendererFactory.aliasedElementTypeRenderer;
}

class TypeParameterElementType extends DefinedElementType {
  TypeParameterElementType(TypeParameterType super.type, super.library,
      super.packageGraph, super.element);

  @override
  TypeParameterType get type => super.type as TypeParameterType;

  @override
  String get linkedName => '$name$nullabilitySuffix';

  @override
  String get nameWithGenerics => '$name$nullabilitySuffix';

  @override
  DartType get _bound => type.bound;
}

/// An [ElementType] associated with an [Element].
abstract class DefinedElementType extends ElementType {
  final ModelElement modelElement;

  DefinedElementType(
      super.type, super.library, super.packageGraph, this.modelElement);

  Element get element => modelElement.element!;

  @override
  String get name => type.element!.name!;

  @override
  String get fullyQualifiedName => modelElement.fullyQualifiedName;

  bool get isParameterType => (type is TypeParameterType);

  /// This type is a public type if the underlying, canonical element is public.
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    var canonicalClass = modelElement.packageGraph
            .findCanonicalModelElementFor(modelElement.element) ??
        modelElement;
    return canonicalClass.isPublic;
  }

  DartType get _bound => type;

  /// Return this type, instantiated to bounds if it isn't already.
  @override
  late final DartType instantiatedType = () {
    if (_bound is InterfaceType &&
        !(_bound as InterfaceType)
            .typeArguments
            .every((t) => t is InterfaceType)) {
      var typeSystem = library.element.typeSystem;
      return typeSystem.instantiateToBounds2(
          classElement: _bound.element as ClassElement,
          nullabilitySuffix: _bound.nullabilitySuffix);
    } else {
      return _bound;
    }
  }();

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
  Iterable<CommentReferable>? get referenceGrandparentOverrides =>
      modelElement.referenceGrandparentOverrides;

  @internal
  @override
  CommentReferable get definingCommentReferable =>
      modelBuilder.fromElement(element);
}

/// Any callable ElementType will mix-in this class, whether anonymous or not,
/// unless it is an alias reference.
mixin Callable on ElementType {
  List<Parameter> get parameters => type.parameters
      .map((p) => modelBuilder.from(p, library) as Parameter)
      .toList(growable: false);

  late final ElementType returnType =
      modelBuilder.typeFrom(type.returnType, library);

  @override
  // TODO(jcollins-g): mustachio should not require this
  String get linkedName;

  @override
  FunctionType get type => super.type as FunctionType;
}

/// This [ElementType] uses an [ElementTypeRenderer] to generate
/// some of its parameters.
mixin Rendered implements ElementType {
  @override
  late final String linkedName = _renderer.renderLinkedName(this);

  @override
  late final String nameWithGenerics = _renderer.renderNameWithGenerics(this);

  ElementTypeRenderer<ElementType> get _renderer;
}

/// A callable type that may or may not be backed by a declaration using the generic
/// function syntax.
class CallableElementType extends DefinedElementType with Rendered, Callable {
  CallableElementType(
      FunctionType super.t, super.library, super.packageGraph, super.element);

  @override
  String get name => super.name.isNotEmpty ? super.name : 'Function';

  @override
  ElementTypeRenderer<CallableElementType> get _renderer =>
      packageGraph.rendererFactory.callableElementTypeRenderer;

  @override
  late final Iterable<ElementType> typeArguments =
      (type.alias?.typeArguments ?? [])
          .map((f) => modelBuilder.typeFrom(f, library))
          .toList(growable: false);
}

/// A non-callable type backed by a [GenericTypeAliasElement].
class GenericTypeAliasElementType extends TypeParameterElementType {
  GenericTypeAliasElementType(
      super.t, super.library, super.packageGraph, super.element);
}
