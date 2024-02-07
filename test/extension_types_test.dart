// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (extensionTypesAllowed) {
      defineReflectiveTests(ExtensionTypesTest);
    }
  });
}

@reflectiveTest
class ExtensionTypesTest extends DartdocTestBase {
  @override
  String get libraryName => 'extension_types';

  @override
  String get sdkConstraint => '>=3.3.0 <4.0.0';

  // TODO(srawlins): Test superinterfaces, references to members which exist via
  // `implements`, references to primary constructor.

  void test_extensionTypeHasReference() async {
    var library = await bootPackageWithLibrary('''
/// Doc referring to [C].
extension type ET<T extends num>(int it) implements num {
  void m() {}
}

class C {}
''');

    expect(
      library.extensionTypes.named('ET').documentationAsHtml,
      '<p>Doc referring to '
      '<a href="${placeholder}extension_types/C-class.html">C</a>.</p>',
    );
  }

  void test_extensionTypeMemberHasReference() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  /// Doc referring to [C].
  void m() {}
}

class C {}
''');

    expect(
      library.extensionTypes
          .named('ET')
          .instanceMethods
          .named('m')
          .documentationAsHtml,
      '<p>Doc referring to '
      '<a href="${placeholder}extension_types/C-class.html">C</a>.</p>',
    );
  }

  void test_referenceToExtensionType() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  void m() {}
}

/// Doc referring to [ET].
class C {}
''');

    expect(
      library.classes.named('C').documentationAsHtml,
      '<p>Doc referring to '
      '<a href="${placeholder}extension_types/ET-extension-type.html">ET</a>.</p>',
    );
  }

  @FailingTest(reason: 'Not implemented yet')
  void test_referenceToExtensionTypeConstructor() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  ET.named(int it);
}

/// Doc referring to [ET.new] and [Et.named].
class C {}
''');

    expect(
      library.classes.named('C').documentationAsHtml,
      '<p>Doc referring to '
      '<a href="${placeholder}extension_types/ET/named.html">ET.named</a>.</p>',
    );
  }

  void test_referenceToExtensionTypeMember() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  void m() {}
}

/// Doc referring to [ET.m].
class C {}
''');

    expect(
      library.classes.named('C').documentationAsHtml,
      '<p>Doc referring to '
      '<a href="${placeholder}extension_types/ET/m.html">ET.m</a>.</p>',
    );
  }
}
