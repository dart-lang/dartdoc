// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library nullable_elements;

int? publicNullable;

String? get nullableGetter => null;

String? _nullableSetter;

void set nullableSetter(String? value) {
  _nullableSetter = _nullableSetter ??= value;
}

void some(int? nullable, String? parameters) {}

class NullableMembers {
  final Map<String, Map>? initialized;

  /// Nullable constructor parameters.
  NullableMembers(this.initialized);

  Iterable<BigInt>? nullableField;

  operator *(NullableMembers? nullableOther) => this;

  int? methodWithNullables(String? foo) => foo?.length;
}

class ComplexNullableMembers<T extends String?> {
  Map<T?, String?> aComplexType = <T?, String?>{null: null};

  void set aComplexSetterOnlyType(List<Map<T?, String?>?> value) => null;

  X? aMethod<X extends T?>(X? f) => null;
}