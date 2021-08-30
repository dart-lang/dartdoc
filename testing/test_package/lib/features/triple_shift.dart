// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests for verifying triple_shift operator, borrowed from the SDK.
library triple_shift;

class C {
  static int ctr = 0;

  /// Check that constants using a triple shift operator appear correctly.
  static const int constantTripleShifted = 3 >>> 5;
  final Object? _text;
  C([Object? text]) : _text = text ?? "${++ctr}";

  // It's possible to declare a `>>>` operator.
  C operator >>>(arg) => C("(${++ctr}:$_text>>>$arg)");

  // + binds more strongly than `>>`, `>>>` and `<<`.
  C operator +(arg) => C("(${++ctr}:$_text+$arg)");
  // Both `>>` and `<<` binds exactly as strongly as `>>>`.
  C operator >>(arg) => C("(${++ctr}:$_text>>$arg)");
  C operator <<(arg) => C("(${++ctr}:$_text<<$arg)");
  // & binds less strongly than `>>`, `>>>` and `<<`.
  C operator &(arg) => C("(${++ctr}:$_text&$arg)");

  String toString() => "${_text}";
}

class _D extends C {}

class E extends _D {}

class F extends E {
  @override
  F operator >>>(arg) => F();
}

// Valid in extensions too.
extension ShiftIt<T> on T {
  List<T> operator >>>(int count) => List<T>.filled(count, this);
}
