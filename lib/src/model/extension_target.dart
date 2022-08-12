// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';

// TODO(jcollins-g): Mix-in ExtensionTarget on Method, ModelFunction, Typedef,
// and other possible documented symbols that could be extended (#2701).
mixin ExtensionTarget on ModelElement {
  bool get hasModifiers;

  bool get hasPotentiallyApplicableExtensions =>
      potentiallyApplicableExtensionsSorted.isNotEmpty;

  /// The sorted list of potentially applicable extensions, for display in
  /// templates.
  ///
  /// This is defined as those extensions where an instantiation of the type
  /// defined by [element] can exist where this extension applies, not including
  /// any extension that applies to every type.
  @Deprecated('Use potentiallyApplicableExtensionsSorted')
  late final List<Extension> potentiallyApplicableExtensions = packageGraph
      .documentedExtensions
      .where((e) => !e.alwaysApplies)
      .where((e) => e.couldApplyTo(this))
      .toList(growable: false)
    ..sort(byName);

  ElementType get modelType;

  List<Extension> get potentiallyApplicableExtensionsSorted =>
      // ignore: deprecated_member_use_from_same_package
      potentiallyApplicableExtensions;
}
