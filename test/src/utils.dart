// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:io';

final Directory testPackageDir = new Directory('test_package');
final Directory testPackageBadDir = new Directory('test_package_bad');

void delete(Directory dir) {
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}
