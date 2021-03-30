// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/privacy.dart';

/// Use this constant to insure your feature is sorted last.
const featureSortedLast = 1>>63;

/// Items mapped less than zero will sort before custom annotations.
/// Items mapped above zero are sorted after custom annotations.
/// Items mapped to zero will sort alphabetically among custom annotations.
/// Custom annotations are assumed to be any annotation or feature not in this
/// map.
const Map<String, Feature> _elementFeatures = {
  'read-only': Feature('read-only', 1),
  'write-only': Feature('write-only', 2),
  'read / write': Feature('read / write', 2),
  'covariant': Feature('covariant', 2),
  'final': Feature('final', 2),
  'late': Feature('late', 3),
  'inherited': Feature('inherited', 3),
  'inherited-getter': Feature('inherited-getter', 3),
  'inherited-setter': Feature('inherited-setter', 3),
  'override': Feature('override', 3),
  'override-getter': Feature('override-getter', 3),
  'override-setter': Feature('override-setter', 3),
  'extended': Feature('extended', 3),
};

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
  const Feature(this._name, [this.sortGroup = featureSortedLast]);

  /// Use this to get prebuilt feature objects (preferred).
  factory Feature.added(String name) => _elementFeatures.containsKey(name) ? _elementFeatures[name] : throw ElementFeatureNotFoundError(name);

  String get rendered => name;

  String get name => _name;

  @override
  bool get isPublic => !name.startsWith('_');

  final int sortGroup;
}