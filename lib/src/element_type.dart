// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart types, all subclasses of [ElementType].
///
/// The only entrypoint for constructing these classes is [ElementType.for_].
library;

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/element_type_renderer.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:meta/meta.dart';

/// Base class representing a type in Dartdoc.  It wraps a [DartType], and
/// may link to a [ModelElement].
abstract class ElementType with CommentReferable, Nameable {
  final DartType type;
  @override
  final PackageGraph packageGraph;
  @override
  final Library library;

  final String nullabilitySuffix;

  ElementType._(this.type, this.library, this.packageGraph)
      : nullabilitySuffix = type.nullabilitySuffixWithin(library);

  factory ElementType.for_(
      DartType type, Library library, PackageGraph packageGraph) {
    runtimeStats.incrementAccumulator('elementTypeInstantiation');
    var fElement = type.documentableElement2;
    if (fElement == null ||
        fElement.kind == ElementKind.DYNAMIC ||
        fElement.kind == ElementKind.NEVER) {
      return UndefinedElementType._from(type, library, packageGraph);
    }
    var modelElement = packageGraph.getModelForElement2(fElement);
    return DefinedElementType._from(type, modelElement, library, packageGraph);
  }

  bool get isTypedef => false;

  String get linkedName;

  /// Name with generics and nullability indication, in HTML tags.
  String get nameWithGenerics;

  /// Name with generics and nullability indication, in plain text, with
  /// unescaped angle brackets.
  String get nameWithGenericsPlain;

  @override
  String get displayName => throw UnimplementedError();

  @override
  String get breadcrumbName => throw UnimplementedError();

  Iterable<ElementType> get typeArguments;

  @override
  String toString() => '$type';
}

/// An [ElementType] that isn't pinned to an [Element2] (or one that is, but
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
    assert(const {'Never'}.contains(type.documentableElement2?.name3),
        'Unrecognized type for UndefinedElementType: $type');
    return type.documentableElement2!.name3!;
  }

  @override
  String get linkedName => name;

  @override
  String get nameWithGenerics => '$name$nullabilitySuffix';

  @override
  String get nameWithGenericsPlain => '$name$nullabilitySuffix';

  @override
  Iterable<ElementType> get typeArguments => const [];

  @override
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  Iterable<CommentReferable> get referenceParents => const [];

  @override
  Iterable<CommentReferable>? get referenceGrandparentOverrides => null;
}

/// A [FunctionType] that does not have an underpinning [Element2].
class FunctionTypeElementType extends UndefinedElementType
    with Rendered, Callable {
  FunctionTypeElementType._(
      FunctionType super.type, super.library, super.packageGraph)
      : super._();

  List<TypeParameter> get typeFormals => type.typeParameters
      .map((p) => getModelFor2(p, library) as TypeParameter)
      .toList(growable: false);

  @override
  String get name => 'Function';

  @override
  ElementTypeRenderer get _renderer =>
      const FunctionTypeElementTypeRendererHtml();
}

/// A [RecordType] which does not have an underpinning Element.
class RecordElementType extends UndefinedElementType with Rendered {
  RecordElementType._(RecordType super.type, super.library, super.packageGraph)
      : super._();

  @override
  String get name => 'Record';

  @override
  ElementTypeRenderer get _renderer => const RecordElementTypeRendererHtml();

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
      const AliasedUndefinedElementTypeRendererHtml();
}

class ParameterizedElementType extends DefinedElementType with Rendered {
  ParameterizedElementType._(ParameterizedType super.type, super.library,
      super.packageGraph, super.element)
      : super._();

  @override
  ParameterizedType get type => super.type as ParameterizedType;

  @override
  ElementTypeRenderer<ParameterizedElementType> get _renderer =>
      const ParameterizedElementTypeRendererHtml();

  @override
  late final List<ElementType> typeArguments = type.typeArguments
      .map((f) => getTypeFor(f, library))
      .toList(growable: false);
}

/// An [ElementType] whose underlying type was referred to by a type alias.
mixin Aliased implements ElementType {
  Element2 get typeAliasElement2 => type.alias!.element2;

  @override
  String get name => typeAliasElement2.name3!;

  @override
  bool get isTypedef => true;

  late final ModelElement aliasElement =
      ModelElement.forElement(typeAliasElement2, packageGraph);

  late final List<ElementType> aliasArguments = type.alias!.typeArguments
      .map((f) => getTypeFor(f, library))
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
      const AliasedElementTypeRendererHtml();
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
  String get nameWithGenericsPlain => '$name$nullabilitySuffix';
}

/// An [ElementType] associated with an [Element2].
abstract class DefinedElementType extends ElementType {
  final ModelElement modelElement;

  DefinedElementType._(
      super.type, super.library, super.packageGraph, this.modelElement)
      : super._();

  factory DefinedElementType._from(DartType type, ModelElement modelElement,
      Library library, PackageGraph packageGraph) {
    if (type is! TypeAliasElement2 && type.alias != null) {
      // Here, `alias.element` signals that this is a type referring to an
      // alias. (`TypeAliasElement.alias.element` has different implications.
      // In that case it is an actual type alias of some kind (generic or
      // otherwise).)
      return switch (type) {
        TypeParameterType() =>
          TypeParameterElementType._(type, library, packageGraph, modelElement),
        ParameterizedType() =>
          AliasedElementType._(type, library, packageGraph, modelElement),
        _ => throw UnimplementedError(
            'No ElementType implemented for aliased ${type.runtimeType}'),
      };
    }
    return switch (type) {
      TypeParameterType() =>
        TypeParameterElementType._(type, library, packageGraph, modelElement),
      ParameterizedType() =>
        ParameterizedElementType._(type, library, packageGraph, modelElement),
      _ => throw UnimplementedError(
          'No ElementType implemented for ${type.runtimeType}'),
    };
  }

  @override
  String get name => type.documentableElement2!.name3!;

  @override
  String get fullyQualifiedName => modelElement.fullyQualifiedName;

  /// Whether the underlying, canonical element is public.
  ///
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    var canonicalClass =
        packageGraph.findCanonicalModelElementFor(modelElement) ?? modelElement;
    return canonicalClass.isPublic;
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
      ModelElement.forElement(modelElement.element2, packageGraph);
}

/// Any callable [ElementType] will mix-in this class, whether anonymous or not,
/// unless it is an alias reference.
mixin Callable on ElementType {
  List<Parameter> get parameters => type.formalParameters
      .map((p) => getModelFor2(p, library) as Parameter)
      .toList(growable: false);

  late final ElementType returnType = getTypeFor(type.returnType, library);

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

  @override
  late final String nameWithGenericsPlain =
      _renderer.renderNameWithGenerics(this, plain: true);

  ElementTypeRenderer<ElementType> get _renderer;
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
