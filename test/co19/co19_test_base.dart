// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../documentation_comment_test_base.dart';

@reflectiveTest
class Co19TestBase extends DocumentationCommentTestBase {
  @override
  String get libraryName => 'co19';

  @override
  String get packageName => 'co19';

  void expectDocComment(dynamic matcher) {
    expect(libraryModel.documentation, matcher);
  }
}
