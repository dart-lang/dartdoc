// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Methods in-lined from package:quiver.

// From lib/iterables.dart:

/// Returns the concatenation of the input iterables.
///
/// The returned iterable is a lazily-evaluated view on the input iterables.
Iterable<T> concat<T>(Iterable<Iterable<T>> iterables) =>
    iterables.expand((x) => x);

// From lib/src/core/hash.dart:

/// Generates a hash code for two objects.
int hash2(Object a, Object b) =>
    _finish(_combine(_combine(0, a.hashCode), b.hashCode));

/// Generates a hash code for three objects.
int hash3(Object a, Object b, Object c) => _finish(
    _combine(_combine(_combine(0, a.hashCode), b.hashCode), c.hashCode));

/// Generates a hash code for four objects.
int hash4(Object a, Object b, Object c, Object d) => _finish(_combine(
    _combine(_combine(_combine(0, a.hashCode), b.hashCode), c.hashCode),
    d.hashCode));

// Jenkins hash functions

int _combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int _finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
