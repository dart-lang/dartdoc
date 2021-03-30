// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/privacy.dart';

int byFeatureOrdering(Feature a, Feature b) {
  if (a.sortGroup < b.sortGroup) return -1;
  if (a.sortGroup > b.sortGroup) return 1;
  return compareAsciiLowerCaseNatural(a.name, b.name);
}

class ElementFeatureNotFoundError extends Error {
  final String message;

  ElementFeatureNotFoundError([this.message]);

  @override
  String toString() => 'ElementFeatureNotFoundError: $message';
}

/// A "feature" includes both explicit annotations in code (e.g. `deprecated`)
/// as well as others added by the documentation systme (`read-write`);
class Feature implements Privacy {
  final String _name;

  /// Do not use this except in subclasses, prefer const members of this
  /// class instead.
  const Feature(this._name, [this.sortGroup = 0]);

  String get rendered => name;

  String get name => _name;

  @override
  bool get isPublic => !name.startsWith('_');

  /// Numerical sort group for this feature.
  /// Less than zero will sort before custom annotations.
  /// Above zero will sort after custom annotations.
  /// Zero will sort alphabetically among custom annotations.
  // TODO(jcollins-g): consider [Comparable]?
  final int sortGroup;

  static const readOnly = Feature('read-only', 1);
  static const finalFeature = Feature('final', 2);
  static const writeOnly = Feature('write-only', 2);
  static const readWrite = Feature('read / write', 2);
  static const covariant = Feature('covariant', 2);
  static const extended = Feature('extended', 3);
  static const inherited = Feature('inherited', 3);
  static const inheritedGetter = Feature('inherited-getter', 3);
  static const inheritedSetter = Feature('inherited-setter', 3);
  static const lateFeature = Feature('late', 3);
  static const overrideFeature = Feature('override', 3);
  static const overrideGetter = Feature('override-getter', 3);
  static const overrideSetter = Feature('override-setter', 3);
}
