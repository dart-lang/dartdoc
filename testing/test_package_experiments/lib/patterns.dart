// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exercise some pattern features within Dartdoc.
library patterns;

typedef TypedefName<T, U> = (T, U);

TypedefName<T, U> recordGenerator<T, U>(T a, U b) => (a, b);

var a, b = recordGenerator<int, double>(5, 6.5);

var c, d = (12, recordGenerator<int, String>(7, 'hello'));
