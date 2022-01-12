// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library named_arguments_anywhere;

class C {
  const C(int a, int b, {required int c, required int d});
}

const p = C(1, 2, c: 3, d: 4);

const q = C(1, c: 2, 3, d: 4);

const r = C(c: 1, d: 2, 3, 4);
