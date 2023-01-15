// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MultiplyDefinedTest);
  });
}

@reflectiveTest
class MultiplyDefinedTest extends DartdocTestBase {
  @override
  String get libraryName => 'multiply_defined';

  void test_referencingAnErroneousMultiplyDefinedElement() async {
    await d.dir('lib', [
      d.file('import1.dart', 'class C {}'),
      d.file('import2.dart', 'class C {}'),
      d.file('lib.dart', '''
library $libraryName;

import 'import1.dart';
import 'import2.dart';

/// Reference to [C].
void foo(C c) {}
'''),
    ]).createInMemory(resourceProvider, packagePath);

    var packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    var library = packageGraph.libraries.named(libraryName);
    var fooFunction = library.functions.named('foo');
    expect(
      fooFunction.documentationAsHtml,
      '<p>Reference to <a href="${placeholder}import1/C-class.html">C</a>.</p>',
    );
  }
}
