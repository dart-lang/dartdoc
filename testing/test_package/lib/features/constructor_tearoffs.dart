// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exercise a number of constructor-tearoff related features inside dartdoc.
///
/// References to tearoffs should work at a top level too:
///   [A.new], [B.new], [At.new], [Bt.new], [C], [C.new], [D.new],
///
library constructor_tearoffs;

abstract class A {
  final int number;

  /// Even though this is abstract, dartdoc should still allow referring to
  /// [A.new].
  A.new(this.number);
}

class B extends A {
  B.new() : super(5);
}

class C {}

typedef At = A;
typedef Bt = B;
typedef Ct = C;

/// [Dt.new] and [D.new] should be a thing.
abstract class D<T extends String> {}

typedef Dt = D;

/// I refer to many things, including typedef constructor tearoffs [At.new],
/// [Bt.new], [Ct.new], [Et.new].
/// Don't forget about [E.new], [E.E], or [D<String>.new].
class E extends D<String> {
  final String aValue;
  E.new(this.aValue) {}
}

typedef Et = E;

/// Referring to [F<T>.new] and [F<Object>.new] should work fine.
class F<T> {
  F() {
    print('I too am a valid constructor invocation with this feature.');
  }

  F.alternative() {}
}

typedef Ft<T> = F<T>;

/// Referring to [Fstring.new] should be fine.
typedef Fstring = F<String>;

/// Can't refer to `.new` here.
typedef NotAClass = Function;

/// Mixins don't have constructors either, so disallow `M.new`.
mixin M<T> on C {}
