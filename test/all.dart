// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.all_tests;

import 'compare_output_test.dart' as compare_output_tests;
import 'dartdoc_test.dart' as dartdoc_tests;
import 'html_generator_test.dart' as html_generator_tests;
import 'io_utils_test.dart' as io_utils_tests;
import 'model_test.dart' as model_tests;
import 'model_utils_test.dart' as model_utils_tests;
import 'package_meta_test.dart' as package_meta_tests;
import 'resource_loader_test.dart' as resource_loader_tests;
import 'template_test.dart' as template_tests;
import 'markdown_processor_test.dart' as markdown_processor_tests;

void main() {
  compare_output_tests.main();
  dartdoc_tests.main();
  html_generator_tests.main();
  io_utils_tests.main();
  model_tests.main();
  model_utils_tests.main();
  package_meta_tests.main();
  resource_loader_tests.main();
  template_tests.main();
  markdown_processor_tests.main();
}
