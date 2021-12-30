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
