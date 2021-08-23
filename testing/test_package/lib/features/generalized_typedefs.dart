// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library validates that dartdoc will not crash on generalized
/// typedef syntax, and produce correct results.
library generalized_typedefs;

// from basic_syntax_test (Dart SDK)

typedef T0 = void;
typedef T1 = Function;

/// [List], [String]
typedef T2<X> = List<X>;
typedef T3<X, Y> = Map<X, Y>;
typedef T4 = void Function();
typedef T5<X> = X Function(X, {X name});
typedef T6<X, Y> = X Function(Y, [Map<Y, Y>]);
typedef T7<X extends String, Y extends List<X>> = X Function(Y, [Map<Y, Y>]);

T0 a;

class C2 {
  T0 b;
  T1? c;
  T2? d(T3 e, T4 f) {}
}

class C1<T extends T3> {
  T2? a;
  T0 b(T1 c, T d) {}
}

typedef T8 = C1;

abstract class C extends T8 {
  T0 f;
  T1 g(T2 a, T3 b);

  T2 operator +(T2 other) => other;

  static final T4 h = () {};
  static T5<C>? i;

  T7<String, List<String>> get j;

  set k(T6<int, bool> value);
}

extension E on T6 {
  static T4 f = () {};

  T2 myMethod() => [5];
}
