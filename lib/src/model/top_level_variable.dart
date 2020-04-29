// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement
    with Canonicalization, GetterSetterCombo, SourceCodeMixin, Categorization
    implements EnclosedElement {
  @override
  final Accessor getter;
  @override
  final Accessor setter;

  TopLevelVariable(TopLevelVariableElement element, Library library,
      PackageGraph packageGraph, this.getter, this.setter)
      : super(element, library, packageGraph, null) {
    if (getter != null) {
      getter.enclosingCombo = this;
    }
    if (setter != null) {
      setter.enclosingCombo = this;
    }
  }

  @override
  bool get isInherited => false;

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    if (isPublic) {
      var assertCheck = {hasPublicSetter, hasPublicGetterNoSetter};
      assert(assertCheck.containsAll([true, false]));
    }
    return super.documentation;
  }

  @override
  ModelElement get enclosingElement => library;

  @override
  String get filePath => '${library.dirName}/$fileName';

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  @override
  bool get isConst => _variable.isConst;

  @override
  bool get isFinal {
    /// isFinal returns true for the variable even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return _variable.isFinal;
  }

  @override
  bool get isLate => isFinal && _variable.isLate;

  @override
  String get kind => isConst ? 'top-level constant' : 'top-level property';

  @override
  Set<String> get features => super.features..addAll(comboFeatures);

  @override
  String computeDocumentationComment() {
    var docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _variable.documentationComment;
    return docs;
  }

  @override
  String get fileName => '${isConst ? '$name-constant' : name}.$fileType';

  @override
  DefinedElementType get modelType => super.modelType;

  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);
}
