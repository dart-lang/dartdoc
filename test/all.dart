// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.all_tests;

import 'css_test.dart' as css_tests;
import 'dartdoc_test.dart' as dartdoc_tests;
import 'model_test.dart' as model_tests;
import 'package_utils_test.dart' as package_util_tests;
import 'template_test.dart' as template_tests;


main() {
  css_tests.tests();
  dartdoc_tests.tests();
  model_tests.tests();
  package_util_tests.tests();
  template_tests.tests();
}
