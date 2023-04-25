// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';

final _canonicalRegExp = RegExp(r'{@canonicalFor\s([^}]+)}');

/// Used by [Library] to implement the canonicalFor directive.
mixin CanonicalFor on ModelElement {
  Set<String>? _canonicalFor;

  Set<String> get canonicalFor {
    if (_canonicalFor == null) {
      buildDocumentationAddition(documentationComment);
    }
    return _canonicalFor!;
  }

  /// Hides [canonicalFor] from doc while leaving a note to ourselves to
  /// help with ambiguous canonicalization determination.
  ///
  /// Example:
  ///
  ///     {@canonicalFor libname.ClassName}
  @override
  String buildDocumentationAddition(String rawDocs) {
    rawDocs = super.buildDocumentationAddition(rawDocs);
    var newCanonicalFor = <String>{};
    rawDocs = rawDocs.replaceAllMapped(_canonicalRegExp, (Match match) {
      var elementName = match.group(1)!;
      newCanonicalFor.add(elementName);
      return '';
    });

    _canonicalFor = newCanonicalFor;
    return rawDocs;
  }
}