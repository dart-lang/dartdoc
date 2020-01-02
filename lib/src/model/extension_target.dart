// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

// TODO(jcollins-g): Mix-in ExtensionTarget on Method, ModelFunction, Typedef,
// and other possible documented symbols that could be extended.
mixin ExtensionTarget on ModelElement {
  bool get hasModifiers;

  bool get hasPotentiallyApplicableExtensions =>
      potentiallyApplicableExtensions.isNotEmpty;

  List<Extension> _potentiallyApplicableExtensions;

  Iterable<Extension> get potentiallyApplicableExtensions {
    if (_potentiallyApplicableExtensions == null) {
      _potentiallyApplicableExtensions = packageGraph.documentedExtensions
          .where((e) => e.couldApplyTo(this))
          .toList(growable: false)
            ..sort(byName);
    }
    return _potentiallyApplicableExtensions;
  }
}
