// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (classModifiersAllowed) {
      defineReflectiveTests(ExtensionTypesTest);
    }
  });
}

@reflectiveTest
class ExtensionTypesTest extends DartdocTestBase {
  @override
  List<String> get experiments => ['extension-types'];

  @override
  String get libraryName => 'extension_types';

  @override
  String get sdkConstraint => '>=3.2.0 <4.0.0';

  void test_extensionTypeExists() async {
    await bootPackageWithLibrary('''
extension type ET(int it) {
  void m() {}
}
''');

    // No crash.
  }

  void test_extensionTypeHasReference() async {
    await bootPackageWithLibrary('''
/// Doc referring to [C].
extension type ET(int it) {
  void m() {}
}

class C {}
''');

    // No crash.
  }

  void test_referenceToExtensionType() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  void m() {}
}

/// Doc referring to [ET].
class C {}
''');

    // TODO(srawlins): Resolve `[ET]`.
    expect(library.classes.named('C').documentation, 'Doc referring to [ET].');
  }

  void test_referenceToExtensionTypeMember() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  void m() {}
}

/// Doc referring to [ET.m].
class C {}
''');

    // TODO(srawlins): Resolve `[ET.m]`.
    expect(
        library.classes.named('C').documentation, 'Doc referring to [ET.m].');
  }
}
