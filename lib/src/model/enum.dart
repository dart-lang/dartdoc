// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:dartdoc/src/render/enum_field_renderer.dart';

/// The [Enum] class only inherits from [InheritingContainer] because declared
/// `enum`s inherit methods from [Object].  It can't actually participate
/// meaningfully in other inheritance or have class modifiers.
class Enum extends InheritingContainer
    with Constructable, TypeImplementing, MixedInTypes {
  @override
  final EnumElement element;

  Enum(this.element, super.library, super.packageGraph);

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...constructors,
  ];

  @override
  late final List<InheritingContainer> inheritanceChain = [
    this,
    for (var container in mixedInTypes.reversed.modelElements)
      ...container.inheritanceChain,
    for (var container in superChain.modelElements)
      ...container.inheritanceChain,
    ...interfaces.expandInheritanceChain,
  ];

  @override
  String get kind => 'enum';

  @override
  String get relationshipsClass => 'eNum-relationships';

  @override
  Iterable<Field> get constantFields =>
      declaredFields.where((f) => f is! EnumField && f.isConst);

  @override
  late final Iterable<Field> publicEnumValues =
      model_utils.filterNonPublic(allFields).whereType<EnumField>();

  @override
  bool get hasPublicEnumValues => publicEnumValues.isNotEmpty;

  @override
  bool get isAbstract => false;

  @override
  bool get isBase => false;

  @override
  bool get isInterface => false;

  @override
  bool get isMixinClass => false;

  @override
  bool get isSealed => false;
}

/// A field specific to an enum's values.
///
/// Enum's value fields are virtual, so we do a little work to create usable
/// entries for the docs.
class EnumField extends Field {
  final int index;

  EnumField.forConstant(this.index, FieldElement element, Library library,
      PackageGraph packageGraph, Accessor? getter)
      : super(
            element, library, packageGraph, getter as ContainerAccessor?, null);

  @override
  bool get isEnumValue => true;

  @override
  bool get hasConstantValueForDisplay {
    final enum_ = element.enclosingElement as EnumElement;
    final enumHasDefaultConstructor =
        enum_.constructors.any((c) => c.isDefaultConstructor);
    // If this enum does not have any explicit constructors (and so only has a
    // default constructor), then there is no meaningful constant initializer to
    // display.
    return !enumHasDefaultConstructor;
  }

  @override
  String get constantValueBase =>
      element.library.featureSet.isEnabled(Feature.enhanced_enums)
          ? super.constantValueBase
          : _fieldRenderer.renderValue(this);

  @override
  List<DocumentationComment> get documentationFrom {
    if (name == 'values' || name == 'index') return [this];
    return super.documentationFrom;
  }

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(!(canonicalLibrary == null || canonicalEnclosingContainer == null));
    assert(canonicalLibrary == library);
    assert(canonicalEnclosingContainer == enclosingElement);
    return '${package.baseHref}${enclosingElement.library.dirName}/${enclosingElement.fileName}';
  }

  @override
  String get linkedName => _fieldRenderer.renderLinkedName(this);

  @override
  bool get isCanonical {
    if (name == 'index') return false;
    // If this is something inherited from Object, e.g. hashCode, let the
    // normal rules apply.
    // TODO(jcollins-g): We don't actually document this as a separate entity;
    //                   do that or change this to false and deal with the
    //                   consequences.
    return true;
  }

  @override
  String get oneLineDoc => documentationAsHtml;

  @override
  Inheritable? get overriddenElement => null;

  EnumFieldRenderer get _fieldRenderer =>
      packageGraph.rendererFactory.enumFieldRenderer;
}
