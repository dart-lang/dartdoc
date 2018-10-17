// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Used by tests as an "external tool" that always fails. Has no other useful purpose.

import 'dart:io';

void main(List<String> argList) {
  exit(1);
}
