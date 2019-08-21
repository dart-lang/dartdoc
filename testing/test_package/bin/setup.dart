// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is a sample setup "tool" used to test external tool integration into
// dartdoc. It has no practical purpose other than that.

import 'dart:io';

void main(List<String> args) {
  assert(args.isNotEmpty);
  // Just touch the file given on the command line.
  File setupFile = File(args[0])..createSync(recursive: true);
  setupFile.writeAsStringSync('setup');
  exit(0);
}
