// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/privacy.dart';

int byAttributeOrdering(Attribute a, Attribute b) {
  if (a.sortGroup < b.sortGroup) return -1;
  if (a.sortGroup > b.sortGroup) return 1;
  return compareAsciiLowerCaseNatural(a.name, b.name);
}

/// An attribute includes both explicit annotations in code (e.g. `deprecated`)
/// as well as others added by the documentation system (`read-write`).
abstract class Attribute implements Privacy {
  final String name;

  /// Numerical sort group for this attribute.
  ///
  /// Less than zero sorts before custom annotations. Above zero sorts after
  /// custom annotations. Zero sots alphabetically among custom annotations.
  // TODO(jcollins-g): consider [Comparable]?
  final int sortGroup;

  const Attribute(this.name, [this.sortGroup = 0]);

  const factory Attribute._builtIn(String name, int sortGroup) =
      _BuiltInAttribute;

  String get linkedName;

  String get linkedNameWithParameters;

  String get cssClassName;

  static const late_ = Attribute._builtIn('late', 1);
  static const noSetter = Attribute._builtIn('no setter', 1);
  static const final_ = Attribute._builtIn('final', 2);
  static const noGetter = Attribute._builtIn('no getter', 2);
  static const getterSetterPair = Attribute._builtIn('getter/setter pair', 2);
  static const covariant = Attribute._builtIn('covariant', 2);
  static const extended = Attribute._builtIn('extended', 3);
  static const inherited = Attribute._builtIn('inherited', 3);
  static const inheritedGetter = Attribute._builtIn('inherited-getter', 3);
  static const inheritedSetter = Attribute._builtIn('inherited-setter', 3);
  static const override_ = Attribute._builtIn('override', 3);
  static const overrideGetter = Attribute._builtIn('override-getter', 3);
  static const overrideSetter = Attribute._builtIn('override-setter', 3);
}

class _BuiltInAttribute extends Attribute {
  const _BuiltInAttribute(super.name, super.sortGroup);

  @override
  bool get isPublic => false;

  @override
  String get linkedName => name;

  @override
  String get linkedNameWithParameters => linkedName;

  @override
  // TODO(srawlins): Also rename to 'attribute' safely, with backwards
  // compatibility.
  String get cssClassName => 'feature';
}
