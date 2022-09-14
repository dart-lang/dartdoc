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

/// This should have return type of `Future?`.
// ignore: unnecessary_question_mark
dynamic? oddAsyncFunction() async {}

/// This should also have return type of `Future?`.
dynamic anotherOddFunction() async {}

Never neverReturns() {
  throw Exception();
}

Never? almostNeverReturns() {}

void some(int? nullable, String? parameters) {}

class NullableMembers {
  NullableMembers();

  operator *(NullableMembers? nullableOther) => this;

  int? methodWithNullables(String? foo) => foo?.length;
}

class ComplexNullableMembers<T extends String?> {
  X? aMethod<X extends T?>(X? f) => null;
}
