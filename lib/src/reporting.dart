// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library reporting;

import 'config.dart';
import 'dart:io';

void warning(String message) {
  // TODO: Could handle fatal warnings here, or print to stderr, or remember
  // that we had at least one warning, and exit with non-null exit code in this case.
  if (config != null && config.showWarnings) {
    stderr.writeln("warning: ${message}");
  }
}
