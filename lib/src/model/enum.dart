// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

class Enum extends InheritingContainer with Constructable, MixedInTypes {
  @override
  final EnumElement2 element;

  Enum(this.element, super.library, super.packageGraph);

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...constructors,
  ];

  @override
  late final List<InheritingContainer> inheritanceChain = [
    this,
    for (var container in mixedInTypes.modelElements.reversed)
      ...container.inheritanceChain,
    for (var container in superChain.modelElements)
      ...container.inheritanceChain,
    ...interfaceElements.expandInheritanceChain,
  ];

  @override
  // Prevent a collision with the library file.
  String get fileName => name == 'index' ? '$name-enum.html' : '$name.html';

  @override
  String get sidebarPath =>
      '${canonicalLibraryOrThrow.dirName}/$name-enum-sidebar.html';

  @override
  Kind get kind => Kind.enum_;

  @override
  String get relationshipsClass => 'eNum-relationships';

  @override
  Iterable<Field> get constantFields =>
      declaredFields.where((f) => f is! EnumField && f.isConst);

  @override
  late final List<Field> publicEnumValues = [
    for (var value in element.constants2)
      getModelForPropertyInducingElement(value, library,
          getter: getModelFor(value.getter2!, library) as ContainerAccessor,
          setter: null) as Field
  ];

  @override
  bool get isAbstract => false;

  @override
  bool get isBase => false;

  @override
  bool get isImplementableInterface => false;

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

  EnumField.forConstant(this.index, FieldElement2 element, Library library,
      PackageGraph packageGraph, Accessor? getter)
      : super(
            element, library, packageGraph, getter as ContainerAccessor?, null);

  @override
  bool get isEnumValue => true;

  @override
  bool get hasConstantValueForDisplay {
    final enum_ = element.enclosingElement2 as EnumElement2;
    final enumHasDefaultConstructor =
        enum_.constructors2.any((c) => c.isDefaultConstructor);
    // If this enum does not have any explicit constructors (and so only has a
    // default constructor), then there is no meaningful constant initializer to
    // display.
    return !enumHasDefaultConstructor;
  }

  @override
  String get constantValueBase =>
      element.library2.featureSet.isEnabled(Feature.enhanced_enums)
          ? super.constantValueBase
          : renderedName;

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
    assert(canonicalEnclosingContainer == enclosingElement);
    assert(canonicalLibrary != null);
    return '${package.baseHref}${canonicalLibrary!.dirName}/'
        '${enclosingElement.fileName}';
  }

  @override
  String get linkedName {
    var cssClass = isDeprecated ? ' class="deprecated"' : '';
    return '<a$cssClass href="$href#$htmlId">$name</a>';
  }

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

  @visibleForTesting
  String get renderedName => name == 'values'
      ? 'const List&lt;<wbr>'
          '<span class="type-parameter">${enclosingElement.name}</span>'
          '&gt;'
      : constantValue;
}
