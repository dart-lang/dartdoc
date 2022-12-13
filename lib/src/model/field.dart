// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';

class Field extends ModelElement
    with GetterSetterCombo, ContainerMember, Inheritable
    implements EnclosedElement {
  @override
  final FieldElement element;

  bool _isInherited = false;
  late final Container _enclosingContainer;
  @override
  final ContainerAccessor? getter;
  @override
  final ContainerAccessor? setter;

  Field(
      this.element, super.library, super.packageGraph, this.getter, this.setter)
      : assert(getter != null || setter != null) {
    getter?.enclosingCombo = this;
    setter?.enclosingCombo = this;
  }

  factory Field.inherited(
      FieldElement element,
      Container enclosingContainer,
      Library library,
      PackageGraph packageGraph,
      Accessor? getter,
      Accessor? setter) {
    var newField = Field(element, library, packageGraph,
        getter as ContainerAccessor?, setter as ContainerAccessor?);
    newField._isInherited = true;
    newField._enclosingContainer = enclosingContainer;
    // Can't set _isInherited to true if this is the defining element, because
    // that would mean it isn't inherited.
    assert(newField.enclosingElement != newField.definingEnclosingContainer);
    return newField;
  }

  @override
  String get documentation {
    if (enclosingElement is Enum) {
      if (name == 'values') {
        return 'A constant List of the values in this enum, in order of their declaration.';
      } else if (name == 'index') {
        return 'The integer index of this enum value.';
      }
    }

    // Verify that [hasSetter] and [hasGetthasPublicGetterNoSettererNoSetter]
    // are mutually exclusive, to prevent displaying more or less than one
    // summary.
    if (isPublic) {
      assert((hasPublicSetter && !hasPublicGetterNoSetter) ||
          (!hasPublicSetter && hasPublicGetterNoSetter));
    }
    return super.documentation;
  }

  @override
  Container get enclosingElement => isInherited
      ? _enclosingContainer
      : modelBuilder.from(element.enclosingElement, library) as Container;

  @override
  String get filePath =>
      '${enclosingElement.library.dirName}/${enclosingElement.name}/$fileName';

  @override
  String? get href {
    assert(!identical(canonicalModelElement, this) ||
        canonicalEnclosingContainer == enclosingElement);
    return super.href;
  }

  @override
  bool get isConst => element.isConst;

  /// Returns true if the FieldElement is covariant, or if the first parameter
  /// for the setter is covariant.
  @override
  bool get isCovariant => setter?.isCovariant == true || element.isCovariant;

  /// Whether this field is final.
  ///
  /// `Element.isFinal` returns `true` even if it has an explicit getter (which
  /// means we should not document it as "final").
  @override
  bool get isFinal {
    if (hasExplicitGetter) return false;
    return element.isFinal;
  }

  @override
  bool get isLate => isFinal && element.isLate;

  @override
  bool get isInherited => _isInherited;

  @override
  bool get isStatic => element.isStatic;

  @override
  String get kind => isConst ? 'constant' : 'property';

  String get fullkind => element.isAbstract ? 'abstract $kind' : kind;

  @override
  Set<Feature> get features {
    var allFeatures = {...super.features, ...comboFeatures};
    // Combo features can indicate 'inherited' and 'override' if
    // either the getter or setter has one of those properties, but that's not
    // really specific enough for [Field]s that have public getter/setters.
    if (hasPublicGetter && hasPublicSetter) {
      if (getter!.isInherited && setter!.isInherited) {
        allFeatures.add(Feature.inherited);
      } else {
        allFeatures.remove(Feature.inherited);
        if (getter!.isInherited) allFeatures.add(Feature.inheritedGetter);
        if (setter!.isInherited) allFeatures.add(Feature.inheritedSetter);
      }
      if (getter!.isOverride && setter!.isOverride) {
        allFeatures.add(Feature.overrideFeature);
      } else {
        allFeatures.remove(Feature.overrideFeature);
        if (getter!.isOverride) allFeatures.add(Feature.overrideGetter);
        if (setter!.isOverride) allFeatures.add(Feature.overrideSetter);
      }
    } else {
      if (isInherited) allFeatures.add(Feature.inherited);
      if (isOverride) allFeatures.add(Feature.overrideFeature);
    }
    return allFeatures;
  }

  @Deprecated('Use `element`')
  FieldElement? get field => element;

  @override
  String get fileName => '${isConst ? '$name-constant' : name}.$fileType';

  SourceCodeRenderer get _sourceCodeRenderer =>
      packageGraph.rendererFactory.sourceCodeRenderer;

  late final String _sourceCode = () {
    // We could use a set to figure the dupes out, but that would lose ordering.
    var fieldSourceCode = modelNode?.sourceCode ?? '';
    var getterSourceCode = getter?.sourceCode ?? '';
    var setterSourceCode = setter?.sourceCode ?? '';
    var buffer = StringBuffer();
    if (fieldSourceCode.isNotEmpty) {
      fieldSourceCode = _sourceCodeRenderer.renderSourceCode(fieldSourceCode);
      buffer.write(fieldSourceCode);
    }
    if (buffer.isNotEmpty) buffer.write('\n\n');
    if (fieldSourceCode != getterSourceCode) {
      if (getterSourceCode != setterSourceCode) {
        buffer.write(getterSourceCode);
        if (buffer.isNotEmpty) buffer.write('\n\n');
      }
    }
    if (fieldSourceCode != setterSourceCode) {
      buffer.write(setterSourceCode);
    }
    return buffer.toString().trim();
  }();

  @override
  String get sourceCode => _sourceCode;

  @override
  Inheritable? get overriddenElement => null;
}
