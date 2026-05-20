// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrimaryConstructorTest);
  });
}

@reflectiveTest
class PrimaryConstructorTest extends DartdocTestBase {
  @override
  final libraryName = 'primary_constructors';

  void test_DocsOnParameters() async {
    var library = await bootPackageWithLibrary('''
      class B {
        B(int _);
      }

      /// The class.
      class const C<T>.name(
        @deprecated
        T param1,
        /// The second parameter.
        @deprecated
        final int field2,
        @deprecated
        super.param3,
        /// The fourth parameter.
        @deprecated
        this.field4,
      ) extends B {
        final int field4;
        /// The constructor.
        @deprecated
        this;
      }
    ''');
    var cClass = library.classes.named('C');
    expect(cClass.hasDocumentation, true);
    expect(cClass.documentation, 'The class.');

    var constructor = cClass.constructors.named('C.name');
    expect(constructor.hasDocumentation, true);
    expect(constructor.documentation, 'The constructor.');

    expect(constructor.hasAnnotations, true);
    expect(
      constructor.annotations.single.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );

    var param1 = constructor.parameters.named('param1');
    expect(param1.hasDocumentation, false);
    expect(param1.hasAnnotations, true);
    expect(
      param1.annotations.single.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );

    var param2 = constructor.parameters.named('field2');
    expect(param2.hasDocumentation, true); // Even though parameters don't.
    expect(param2.hasAnnotations, true);
    expect(
      param2.annotations.single.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );

    var param3 = constructor.parameters.named('param3');
    expect(param3.hasDocumentation, false);
    expect(param3.hasAnnotations, true);
    expect(
      param3.annotations.single.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );

    var param4 = constructor.parameters.named('field4');
    expect(param4.hasDocumentation, true); // Even though parameters don't.
    expect(param4.hasAnnotations, true);
    expect(
      param4.annotations.single.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );

    var field2 = cClass.instanceFields.named('field2');
    expect(field2.hasAnnotations, true); // Apparently inherits annotation.
    expect(
      field2.annotations.single.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );
    expect(field2.hasDocumentation, true); // Gets annotation from parameter.
    expect(field2.documentation, 'The second parameter.');

    var field4 = cClass.instanceFields.named('field4');
    expect(field4.hasAnnotations,
        false); // Does not get annotation from parameter.
    expect(field4.hasDocumentation, false);
  }
}
