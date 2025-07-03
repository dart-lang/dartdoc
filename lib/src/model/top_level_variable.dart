// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement
    with GetterSetterCombo, Categorization {
  @override
  final TopLevelVariableElement2 element;

  @override
  final Accessor? getter;
  @override
  final Accessor? setter;

  TopLevelVariable(this.element, super.library, super.packageGraph, this.getter,
      this.setter) {
    getter?.enclosingCombo = this;
    setter?.enclosingCombo = this;
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
  Library get enclosingElement => library;

  @override
  String get aboveSidebarPath => canonicalLibraryOrThrow.sidebarPath;

  @override
  String? get belowSidebarPath => null;

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    return '${package.baseHref}$filePath';
  }

  @override
  bool get isConst => element.isConst;

  @override
  bool get isFinal {
    /// isFinal returns true for the variable even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return element.isFinal;
  }

  @override
  bool get isLate => isFinal && element.isLate;

  // For use in templates.
  bool get isProvidedByExtension => false;

  // For use in templates.
  Extension get enclosingExtension => throw UnsupportedError(
      'Top-level variables are not provided by extensions');

  @override
  Kind get kind => isConst ? Kind.topLevelConstant : Kind.topLevelProperty;

  @override
  Set<Attribute> get attributes => {...super.attributes, ...comboAttributes};

  @override
  Iterable<CommentReferable> get referenceParents => [library];
}
