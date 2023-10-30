// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart types, all subclasses of [ElementType].
///
/// The only entrypoint for constructing these classes is
/// [ElementTypeBuilderImpl.typeFrom], which delegates instantiation to various
/// factories.
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:meta/meta.dart';

mixin ElementTypeBuilderImpl implements ElementTypeBuilder {
  PackageGraph get packageGraph;

  @override
  ElementType typeFrom(DartType type, Library library) =>
      ElementType._from(type, library, packageGraph);
}

/// Base class representing a type in Dartdoc.  It wraps a [DartType], and
/// may link to a [ModelElement].
abstract class ElementType
    with CommentReferable, Nameable, ModelBuilder
    implements Privacy {
  final DartType type;
  @override
  final PackageGraph packageGraph;
  @override
  final Library library;

  final String nullabilitySuffix;

  ElementType._(this.type, this.library, this.packageGraph)
      : nullabilitySuffix = type.nullabilitySuffixWithin(library);

  factory ElementType._from(
      DartType type, Library library, PackageGraph packageGraph) {
    runtimeStats.incrementAccumulator('elementTypeInstantiation');
    var fElement = type.documentableElement;
    if (fElement == null ||
        fElement.kind == ElementKind.DYNAMIC ||
        fElement.kind == ElementKind.NEVER) {
      return UndefinedElementType._from(type, library, packageGraph);
    }
    var modelElement = packageGraph.modelBuilder.fromElement(fElement);
    return DefinedElementType._from(type, modelElement, library, packageGraph);
  }

  bool get canHaveParameters => false;

  bool get isTypedef => false;

  String get linkedName;

  /// Name with generics and nullability indication.
  String get nameWithGenerics;

  DartType get instantiatedType;

  Iterable<ElementType> get typeArguments;

  bool isBoundSupertypeTo(ElementType t);
  bool isSubtypeOf(ElementType t);

  @override
  String toString() => '$type';
}

/// An [ElementType] that isn't pinned to an [Element] (or one that is, but
/// whose element is irrelevant).
class UndefinedElementType extends ElementType {
  UndefinedElementType._(super.type, super.library, super.packageGraph)
      : super._();

  factory UndefinedElementType._from(
      DartType type, Library library, PackageGraph packageGraph) {
    // [UndefinedElementType]s.
    if (type.alias != null) {
      if (type is FunctionType) {
        return AliasedUndefinedFunctionElementType._(
            type, library, packageGraph);
      }
      return AliasedUndefinedElementType._(type, library, packageGraph);
    }
    if (type is RecordType) {
      return RecordElementType._(type, library, packageGraph);
    }
    if (type is FunctionType) {
      return FunctionTypeElementType._(type, library, packageGraph);
    }
    return UndefinedElementType._(type, library, packageGraph);
  }

  @override
  bool get isPublic => true;

  @override
  String get name {
    if (type is VoidType) return 'void';
    if (type is DynamicType) return 'dynamic';
    // We can not simply throw here because not all SDK libraries resolve
    // all types.
    if (type is InvalidType) return 'dynamic';
    assert(const {'Never'}.contains(type.documentableElement?.name),
        'Unrecognized type for UndefinedElementType: $type');
    return type.documentableElement!.name!;
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
  Iterable<ElementType> get typeArguments => const [];

  @override
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  Iterable<CommentReferable> get referenceParents => const [];

  @override
  Iterable<CommentReferable>? get referenceGrandparentOverrides => null;
}

/// A [FunctionType] that does not have an underpinning [Element].
class FunctionTypeElementType extends UndefinedElementType
    with Rendered, Callable {
  FunctionTypeElementType._(
      FunctionType super.type, super.library, super.packageGraph)
      : super._();

  List<TypeParameter> get typeFormals => type.typeFormals
      .map((p) => packageGraph.modelBuilder.from(p, library) as TypeParameter)
      .toList(growable: false);

  @override
  String get name => 'Function';

  @override
  ElementTypeRenderer get _renderer =>
      packageGraph.rendererFactory.functionTypeElementTypeRenderer;
}

/// A [RecordType] which does not have an underpinning Element.
class RecordElementType extends UndefinedElementType with Rendered {
  RecordElementType._(RecordType super.type, super.library, super.packageGraph)
      : super._();

  @override
  String get name => 'Record';

  @override
  ElementTypeRenderer get _renderer =>
      packageGraph.rendererFactory.recordElementTypeRenderer;

  List<RecordTypeField> get positionalFields => type.positionalFields;

  List<RecordTypeField> get namedFields => type.namedFields;

  @override
  RecordType get type => super.type as RecordType;
}

class AliasedUndefinedFunctionElementType extends AliasedUndefinedElementType
    with Callable {
  AliasedUndefinedFunctionElementType._(
      super.type, super.library, super.packageGraph)
      : super._();
}

class AliasedUndefinedElementType extends UndefinedElementType
    with Aliased, Rendered {
  AliasedUndefinedElementType._(super.type, super.library, super.packageGraph)
      : assert(type.alias != null),
        super._();

  @override
  ElementTypeRenderer get _renderer =>
      packageGraph.rendererFactory.aliasedUndefinedElementTypeRenderer;
}

class ParameterizedElementType extends DefinedElementType with Rendered {
  ParameterizedElementType._(ParameterizedType super.type, super.library,
      super.packageGraph, super.element)
      : super._();

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
  Element get typeAliasElement => type.alias!.element;

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
  AliasedElementType._(
      super.type, super.library, super.packageGraph, super.element)
      : assert(type.alias != null),
        super._();

  @override
  ParameterizedType get type;

  @override
  ElementTypeRenderer<AliasedElementType> get _renderer =>
      packageGraph.rendererFactory.aliasedElementTypeRenderer;
}

class TypeParameterElementType extends DefinedElementType {
  TypeParameterElementType._(TypeParameterType super.type, super.library,
      super.packageGraph, super.element)
      : super._();

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

  DefinedElementType._(
      super.type, super.library, super.packageGraph, this.modelElement)
      : super._();

  factory DefinedElementType._from(DartType type, ModelElement modelElement,
      Library library, PackageGraph packageGraph) {
    // `TypeAliasElement.alias.element` has different implications.
    // In that case it is an actual type alias of some kind (generic or
    // otherwise). Here however `alias.element` signals that this is a type
    // referring to an alias.
    if (type is! TypeAliasElement && type.alias != null) {
      return AliasedElementType._(
          type as ParameterizedType, library, packageGraph, modelElement);
    }
    if (type is TypeParameterType) {
      return TypeParameterElementType._(
          type, library, packageGraph, modelElement);
    }
    return ParameterizedElementType._(
        type as ParameterizedType, library, packageGraph, modelElement);
  }

  @override
  String get name => type.documentableElement!.name!;

  @override
  String get fullyQualifiedName => modelElement.fullyQualifiedName;

  /// Whether the underlying, canonical element is public.
  ///
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    var canonicalClass =
        packageGraph.findCanonicalModelElementFor(modelElement.element) ??
            modelElement;
    return canonicalClass.isPublic;
  }

  DartType get _bound => type;

  /// This type, instantiated to bounds if it isn't already.
  @override
  late final DartType instantiatedType = () {
    final bound = _bound;
    if (bound is InterfaceType &&
        !bound.typeArguments.every((t) => t is InterfaceType)) {
      return library.typeSystem.instantiateInterfaceToBounds(
          element: bound.element, nullabilitySuffix: _bound.nullabilitySuffix);
    } else {
      return _bound;
    }
  }();

  /// Returns whether the instantiated-to-bounds type of this type is a subtype
  /// of [type].
  @override
  bool isSubtypeOf(ElementType type) =>
      library.typeSystem.isSubtypeOf(instantiatedType, type.instantiatedType);

  /// Whether at least one supertype (including via mixins and interfaces) is
  /// equivalent to or a subtype of `this` when instantiated to bounds.
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
      modelBuilder.fromElement(modelElement.element);
}

/// Any callable [ElementType] will mix-in this class, whether anonymous or not,
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

/// This [ElementType] uses an [ElementTypeRenderer] to generate some of its
/// parameters.
mixin Rendered implements ElementType {
  @override
  late final String linkedName = _renderer.renderLinkedName(this);

  @override
  late final String nameWithGenerics = _renderer.renderNameWithGenerics(this);

  ElementTypeRenderer<ElementType> get _renderer;
}

/// A callable type that may or may not be backed by a declaration using the
/// generic function syntax.
class CallableElementType extends DefinedElementType with Rendered, Callable {
  CallableElementType._(
      FunctionType super.t, super.library, super.packageGraph, super.element)
      : super._();

  @override
  String get name => super.name.isNotEmpty ? super.name : 'Function';

  @override
  ElementTypeRenderer<CallableElementType> get _renderer =>
      packageGraph.rendererFactory.callableElementTypeRenderer;

  @override
  late final Iterable<ElementType> typeArguments = type.alias?.typeArguments
          .map((f) => modelBuilder.typeFrom(f, library))
          .toList(growable: false) ??
      const [];
}

extension on DartType {
  /// The dartdoc nullability suffix for this type in [library].
  String nullabilitySuffixWithin(Library library) {
    if (this is! VoidType && !isBottom) {
      /// If a legacy type appears inside the public interface of a Null
      /// safety library, we pretend it is nullable for the purpose of
      /// documentation (since star-types are not supposed to be public).
      if (nullabilitySuffix == NullabilitySuffix.question ||
          nullabilitySuffix == NullabilitySuffix.star) {
        return '?';
      }
    }
    return '';
  }
}
