// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/documentation_comment.dart';
import 'package:dartdoc/src/model/model_element.dart';

final _hideConstantImplementationsRegExp =
    RegExp(r'{@hideConstantImplementations}');

/// Implement parsing the hideConstantImplementations dartdoc directive
/// for this [ModelElement].  Used by [Container].
mixin HideConstantImplementations on DocumentationComment {
  bool? _hasHideConstantImplementations;

  /// [true] if the {@hideConstantImplementations} dartdoc directive is present
  /// in the documentation for this class.
  bool get hasHideConstantImplementations {
    if (_hasHideConstantImplementations == null) {
      buildDocumentationAddition(documentationComment);
    }
    return _hasHideConstantImplementations!;
  }

  /// Hides [hasHideConstantImplementations] from doc while leaving a note to
  /// ourselves to change rendering for these constants.
  /// Example:
  ///
  ///     {@hideConstantImplementations}
  @override
  String buildDocumentationAddition(String rawDocs) {
    rawDocs = super.buildDocumentationAddition(rawDocs);
    _hasHideConstantImplementations = false;
    rawDocs = rawDocs.replaceAllMapped(_hideConstantImplementationsRegExp,
        (Match match) {
      _hasHideConstantImplementations = true;
      return '';
    });
    return rawDocs;
  }
}
