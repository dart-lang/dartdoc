// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Borrowed from the Dart SDK:
/// tests/language/generic/generic_metadata_test.dart
/// with modifications to remove cases dartdoc is not interested in.

// Check that metadata constructor invocations can have type arguments.

@A<B>(0)
library generic_metadata;

/// A type to refer to.
typedef B = int;

/// The annotation to use.
class A<T> {
  final int value;

  const A(this.value);
}

// Annotations on various declarations.

// Library declarations.
@A<B>(0)
const c = 0;

@A<B>(0)
final f = 0;

@A<B>(0)
void mp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

@A<B>(0)
void mn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

@A<B>(0)
int get g => 0;

@A<B>(0)
void set s(@A<B>(0) int x) {}

/// Class declaration and members.
@A<B>(0)
class C<@A<B>(0) T> {
  final value;

  /// Constructor and initializing formal.
  @A<B>(0)
  const C(@A<B>(0) this.value);

  @A<B>(0)
  C.genRed(@A<B>(0) int x) : this(x);

  @A<B>(0)
  factory C.fac(@A<B>(0) int x) => C(x);

  @A<B>(0)
  factory C.facRed(@A<B>(0) int x) = C;

  // Instance (virtual) declarations.
  @A<B>(0)
  final f = 0;

  @A<B>(0)
  void mp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

  @A<B>(0)
  void mn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

  @A<B>(0)
  int get g => 0;

  @A<B>(0)
  void set s(@A<B>(0) int x) {}

  @A<B>(0)
  int operator +(@A<B>(0) int x) => x;

  // Static declarations.
  @A<B>(0)
  static const sc = C<int>(0);

  @A<B>(0)
  static final sf = C<int>(0);

  @A<B>(0)
  static void smp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

  @A<B>(0)
  static void smn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

  @A<B>(0)
  static int get sg => 0;

  @A<B>(0)
  static void set ss(@A<B>(0) int x) {}
}

@A<B>(0)
abstract class AC<@A<B>(0) T> {
  // Instance (virtual) declarations.
  @A<B>(0)
  abstract final f;

  @A<B>(0)
  void mp(@A<B>(0) Object x, [@A<B>(0) int y = 0]);

  @A<B>(0)
  void mn(@A<B>(0) Object x, {@A<B>(0) int y = 0});

  @A<B>(0)
  int get g;

  @A<B>(0)
  void set s(@A<B>(0) int x);

  @A<B>(0)
  int operator +(@A<B>(0) int x);
}

@A<B>(0)
extension E<@A<B>(0) T> on T {
  // Instance extension member declarations.
  @A<B>(0)
  void mp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

  @A<B>(0)
  void mn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

  @A<B>(0)
  int get g => 0;

  @A<B>(0)
  void set s(@A<B>(0) int x) {}

  @A<B>(0)
  int operator +(@A<B>(0) int x) => x;

  // Static declarations.
  @A<B>(0)
  static const sc = C<int>(0);

  @A<B>(0)
  static final sf = C<int>(0);

  @A<B>(0)
  static void smp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

  @A<B>(0)
  static void smn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

  @A<B>(0)
  static int get sg => 0;

  @A<B>(0)
  static void set ss(@A<B>(0) int x) {}
}

@A<B>(0)
mixin M<@A<B>(0) T> {
  // Instance member declarations.
  @A<B>(0)
  final f = 0;

  @A<B>(0)
  void mp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

  @A<B>(0)
  void mn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

  @A<B>(0)
  int get g => 0;

  @A<B>(0)
  void set s(@A<B>(0) int x) {}

  @A<B>(0)
  int operator +(@A<B>(0) int x) => x;

  // Static declarations.
  @A<B>(0)
  static const sc = C<int>(0);

  @A<B>(0)
  static final sf = C<int>(0);

  @A<B>(0)
  static void smp(@A<B>(0) Object x, [@A<B>(0) int y = 0]) {}

  @A<B>(0)
  static void smn(@A<B>(0) Object x, {@A<B>(0) int y = 0}) {}

  @A<B>(0)
  static int get sg => 0;

  @A<B>(0)
  static void set ss(@A<B>(0) int x) {}
}

@A<B>(0)
enum En {
  @A<B>(0)
  foo
}

@A<B>(0)
typedef F<@A<B>(0) T> = int Function<@A<B>(0) X>(@A<B>(0) int);

void main() {}
