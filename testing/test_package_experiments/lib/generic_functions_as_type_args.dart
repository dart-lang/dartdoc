// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests for verifying generic functions as type arguments.
library generic_function_type_args;

late List<T Function<T>(T)> idFunctions;
late S Function<S extends T Function<T>(T)>(S) ff;

typedef F = T Function<T>(T);

class C<T> {
  final T value;
  const C(this.value);
}

T f<T>(T value) => value;

extension E<T> on T {
  T get extensionValue => this;
}

// A generic function type can be a type parameter bound.

// For a type alias:
typedef FB<T extends F> = S Function<S extends T>(S);

// For a class:
class CB<T extends FB<F>> {
  final T function;
  const CB(this.function);
}

// For a function:
T fb<T extends F>(T value) => value;

extension EB<T extends F> on T {
  T get boundExtensionValue => this;

  // Any function type has a `call` of its own type?
  T get boundCall => this.call;
}

// Can be used as arguments to metadata too.
@C<F>(f)
@CB<FB<F>>(fb)
void main() {}
