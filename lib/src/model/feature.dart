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
  final String? message;

  ElementFeatureNotFoundError([this.message]);

  @override
  String toString() => 'ElementFeatureNotFoundError: $message';
}

/// A "feature" includes both explicit annotations in code (e.g. `deprecated`)
/// as well as others added by the documentation system (`read-write`).
class Feature implements Privacy {
  final String _name;
  final String _cssClassName;

  /// Do not use this except in subclasses, prefer const members of this
  /// class instead.
  const Feature(this._name, this._cssClassName, [this.sortGroup = 0]);

  final String featurePrefix = '';

  String get css => _cssClassName;

  String get name => _name;

  String get linkedName => name;

  String get linkedNameWithParameters => linkedName;

  @override
  bool get isPublic => !name.startsWith('_');

  /// Numerical sort group for this feature.
  /// Less than zero will sort before custom annotations.
  /// Above zero will sort after custom annotations.
  /// Zero will sort alphabetically among custom annotations.
  // TODO(jcollins-g): consider [Comparable]?
  final int sortGroup;

  static const lateFeature = Feature('late', 'feature', 1);
  static const readOnly = Feature('read-only', 'feature', 1);
  static const finalFeature = Feature('final', 'feature', 2);
  static const writeOnly = Feature('write-only', 'feature', 2);
  static const readWrite = Feature('read / write', 'feature', 2);
  static const covariant = Feature('covariant', 'feature', 2);
  static const extended = Feature('extended', 'feature', 3);
  static const inherited = Feature('inherited', 'feature', 3);
  static const inheritedGetter = Feature('inherited-getter', 'feature', 3);
  static const inheritedSetter = Feature('inherited-setter', 'feature', 3);
  static const overrideFeature = Feature('override', 'feature', 3);
  static const overrideGetter = Feature('override-getter', 'feature', 3);
  static const overrideSetter = Feature('override-setter', 'feature', 3);
}
