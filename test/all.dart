// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.all_tests;

import 'dartdoc_test.dart' as dartdoc_tests;
import 'html_generator_test.dart' as html_generator_tests;
import 'html_printer_test.dart' as html_printer_test;
import 'io_utils_test.dart' as io_utils_tests;
import 'model_test.dart' as model_tests;
import 'package_meta_test.dart' as package_meta_tests;
import 'template_test.dart' as template_tests;

void main() {
  dartdoc_tests.main();
  html_generator_tests.main();
  html_printer_test.main();
  io_utils_tests.main();
  model_tests.main();
  package_meta_tests.main();
  template_tests.main();
}
