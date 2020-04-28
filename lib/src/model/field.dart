// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';

class Field extends ModelElement
    with GetterSetterCombo, ContainerMember, Inheritable
    implements EnclosedElement {
  bool _isInherited = false;
  Container _enclosingClass;
  @override
  final ContainerAccessor getter;
  @override
  final ContainerAccessor setter;

  Field(FieldElement element, Library library, PackageGraph packageGraph,
      this.getter, this.setter)
      : super(element, library, packageGraph, null) {
    assert(getter != null || setter != null);
    if (getter != null) getter.enclosingCombo = this;
    if (setter != null) setter.enclosingCombo = this;
    _setModelType();
  }

  factory Field.inherited(
      FieldElement element,
      Class enclosingClass,
      Library library,
      PackageGraph packageGraph,
      Accessor getter,
      Accessor setter) {
    var newField = Field(element, library, packageGraph, getter, setter);
    newField._isInherited = true;
    newField._enclosingClass = enclosingClass;
    // Can't set _isInherited to true if this is the defining element, because
    // that would mean it isn't inherited.
    assert(newField.enclosingElement != newField.definingEnclosingContainer);
    return newField;
  }

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    if (isPublic) {
      var assertCheck = <dynamic>{}
        ..addAll([hasPublicSetter, hasPublicGetterNoSetter]);
      assert(assertCheck.containsAll([true, false]));
    }
    documentationFrom;
    return super.documentation;
  }

  @override
  ModelElement get enclosingElement {
    _enclosingClass ??=
        ModelElement.from(field.enclosingElement, library, packageGraph);
    return _enclosingClass;
  }

  @override
  String get filePath =>
      '${enclosingElement.library.dirName}/${enclosingElement.name}/$fileName';

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalEnclosingContainer == enclosingElement);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  @override
  bool get isConst => field.isConst;

  /// Returns true if the FieldElement is covariant, or if the first parameter
  /// for the setter is covariant.
  @override
  bool get isCovariant =>
      setter?.isCovariant == true || (field as FieldElementImpl).isCovariant;

  @override
  bool get isFinal {
    /// isFinal returns true for the field even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return field.isFinal;
  }

  @override
  bool get isLate => isFinal && field.isLate;

  @override
  bool get isInherited => _isInherited;

  @override
  String get kind => isConst ? 'constant' : 'property';

  @override
  List<String> get annotations {
    var all_annotations = <String>[];
    all_annotations.addAll(super.annotations);

    if (element is PropertyInducingElement) {
      var pie = element as PropertyInducingElement;
      all_annotations.addAll(annotationsFromMetadata(pie.getter?.metadata));
      all_annotations.addAll(annotationsFromMetadata(pie.setter?.metadata));
    }
    return all_annotations.toList(growable: false);
  }

  @override
  Set<String> get features {
    var allFeatures = super.features..addAll(comboFeatures);
    // Combo features can indicate 'inherited' and 'override' if
    // either the getter or setter has one of those properties, but that's not
    // really specific enough for [Field]s that have public getter/setters.
    if (hasPublicGetter && hasPublicSetter) {
      if (getter.isInherited && setter.isInherited) {
        allFeatures.add('inherited');
      } else {
        allFeatures.remove('inherited');
        if (getter.isInherited) allFeatures.add('inherited-getter');
        if (setter.isInherited) allFeatures.add('inherited-setter');
      }
      if (getter.isOverride && setter.isOverride) {
        allFeatures.add('override');
      } else {
        allFeatures.remove('override');
        if (getter.isOverride) allFeatures.add('override-getter');
        if (setter.isOverride) allFeatures.add('override-setter');
      }
    } else {
      if (isInherited) allFeatures.add('inherited');
      if (isOverride) allFeatures.add('override');
    }
    return allFeatures;
  }

  @override
  String computeDocumentationComment() {
    var docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return field.documentationComment;
    return docs;
  }

  FieldElement get field => (element as FieldElement);

  @override
  String get fileName => '${isConst ? '$name-constant' : name}.$fileType';

  String _sourceCode;

  @override
  String get sourceCode {
    if (_sourceCode == null) {
      // We could use a set to figure the dupes out, but that would lose ordering.
      var fieldSourceCode = modelNode.sourceCode ?? '';
      var getterSourceCode = getter?.sourceCode ?? '';
      var setterSourceCode = setter?.sourceCode ?? '';
      var buffer = StringBuffer();
      if (fieldSourceCode.isNotEmpty) {
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
      _sourceCode = buffer.toString();
    }
    return _sourceCode;
  }

  void _setModelType() {
    if (hasGetter) {
      setModelType(getter.modelType);
    }
  }

  @override
  CallableElementType get modelType => super.modelType;

  @override
  Inheritable get overriddenElement => null;
}
