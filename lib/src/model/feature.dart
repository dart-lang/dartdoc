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

  ElementFeatureNotFoundError(this.message);

  @override
  String toString() => 'ElementFeatureNotFoundError: $message';
}

/// A "feature" includes both explicit annotations in code (e.g. `deprecated`)
/// as well as others added by the documentation system (`read-write`).
// TODO(srawlins): Rename to avoid confusion with the language feature concept
// and class from package:analyzer. 'Attribute' isn't a bad name.
abstract class Feature implements Privacy {
  final String name;

  /// Numerical sort group for this feature.
  /// Less than zero will sort before custom annotations.
  /// Above zero will sort after custom annotations.
  /// Zero will sort alphabetically among custom annotations.
  // TODO(jcollins-g): consider [Comparable]?
  final int sortGroup;

  const Feature(this.name, [this.sortGroup = 0]);

  const factory Feature._builtIn(String name, int sortGroup) = _BuiltInFeature;

  String get featurePrefix => '';

  String get linkedName;

  String get linkedNameWithParameters;

  String get cssClassName;

  static const lateFeature = Feature._builtIn('late', 1);
  // TODO(srawlins): Change to a Dart term, like "no setter".
  static const readOnly = Feature._builtIn('read-only', 1);
  static const finalFeature = Feature._builtIn('final', 2);
  // TODO(srawlins): Change to a Dart term, like "no getter".
  static const writeOnly = Feature._builtIn('write-only', 2);
  // TODO(srawlins): Change to a Dart term, like "getter/setter pair".
  static const readWrite = Feature._builtIn('read / write', 2);
  static const covariant = Feature._builtIn('covariant', 2);
  static const extended = Feature._builtIn('extended', 3);
  static const inherited = Feature._builtIn('inherited', 3);
  static const inheritedGetter = Feature._builtIn('inherited-getter', 3);
  static const inheritedSetter = Feature._builtIn('inherited-setter', 3);
  static const overrideFeature = Feature._builtIn('override', 3);
  static const overrideGetter = Feature._builtIn('override-getter', 3);
  static const overrideSetter = Feature._builtIn('override-setter', 3);
}

class _BuiltInFeature extends Feature {
  const _BuiltInFeature(super.name, super.sortGroup);

  @override
  bool get isPublic => false;

  @override
  String get linkedName => name;

  @override
  String get linkedNameWithParameters => linkedName;

  @override
  String get cssClassName => 'feature';
}
