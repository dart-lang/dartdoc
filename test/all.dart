// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.all_tests;

import 'css_test.dart' as css_tests;
import 'dartdoc_test.dart' as dartdoc_tests;
import 'io_utils_test.dart' as io_utils_tests;
import 'model_test.dart' as model_tests;
import 'package_utils_test.dart' as package_util_tests;
import 'template_test.dart' as template_tests;

void main() {
  css_tests.main();
  dartdoc_tests.main();
  io_utils_tests.main();
  model_tests.main();
  package_util_tests.main();
  template_tests.main();
}
