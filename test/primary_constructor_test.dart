// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrimaryConstructorsTest);
  });
}

@reflectiveTest
class PrimaryConstructorsTest extends DartdocTestBase {
  @override
  String get libraryName => 'primary_constructors';

  // ---------------------------------------------------------------------------
  // Field Induction & Syntax
  // ---------------------------------------------------------------------------

  void test_fieldInduction_class() async {
    var library = await bootPackageWithLibrary('''
class C(var int x, final int y, int z);
class Derived(super.x) extends C;
''');

    var c = library.classes.named('C');
    expect(c.instanceFields.any((f) => f.name == 'x'), isTrue);
    expect(c.instanceFields.any((f) => f.name == 'y'), isTrue);
    expect(c.instanceFields.any((f) => f.name == 'z'), isFalse);

    // Verify 'x' is not a newly induced field in the subclass
    var derived = library.classes.named('Derived');
    expect(derived.declaredFields.any((f) => f.name == 'x'), isFalse);
    var constructor = derived.constructors.first;
    expect(constructor.parameters.any((p) => p.name == 'x'), isTrue);
  }

  void test_fieldInduction_extensionType() async {
    var library = await bootPackageWithLibrary('''
extension type Id(int value) {}
''');

    var et = library.extensionTypes.named('Id');
    expect(et.instanceFields.any((f) => f.name == 'value'), isTrue);
  }

  void test_bodyless_containers() async {
    var library = await bootPackageWithLibrary('''
class C(int x);
class const Cc(final int x);
enum E(int x) { v(1); }
mixin M;
mixin class MC();
extension Ex on int;
extension type ET(int x);
''');

    expect(library.classes.any((c) => c.name == 'C'), isTrue);
    expect(library.enums.any((e) => e.name == 'E'), isTrue);
    expect(library.mixins.any((m) => m.name == 'M'), isTrue);
    expect(library.classes.any((c) => c.name == 'MC'), isTrue);
    expect(library.extensions.any((e) => e.name == 'Ex'), isTrue);
    expect(library.extensionTypes.any((e) => e.name == 'ET'), isTrue);

    // Enum primary constructors are correctly identified as const.
    var e = library.enums.named('E');
    expect(e.constructors.first.isConst, isTrue);

    var c = library.classes.named('Cc');
    expect(c.constructors.first.isConst, isTrue);

    var m = library.classes.named('MC');
    expect(m.constructors, hasLength(1));
    expect(m.constructors.first.parameters, isEmpty);
  }

  // ---------------------------------------------------------------------------
  // Metadata Propagation (Docs & Annotations)
  // ---------------------------------------------------------------------------

  void test_metadata_propagation() async {
    var library = await bootPackageWithLibrary('''
class C(
  /// Doc for x.
  var int x,
  /// Doc for y.
  final int y,
  @deprecated
  var int z
);
''');

    var c = library.classes.named('C');
    expect(c.instanceFields.named('x').documentation, contains('Doc for x.'));
    expect(c.instanceFields.named('y').documentation, contains('Doc for y.'));
    expect(c.instanceFields.named('z').isDeprecated, isTrue);
  }

  void test_metadata_propagation_enum() async {
    var library = await bootPackageWithLibrary('''
enum Status(
  /// The [label] for this status.
  @deprecated
  final String label
) {
  active('Active');
}
''');

    var e = library.enums.named('Status');
    var field = e.instanceFields.named('label');
    expect(field.documentation, contains('The [label] for this status.'));
    expect(field.isDeprecated, isTrue);
  }

  void test_metadata_propagation_extensionType() async {
    var library = await bootPackageWithLibrary('''
extension type Id(
  /// The underlying [value].
  @deprecated
  int value
) {}
''');

    var et = library.extensionTypes.named('Id');
    var field = et.instanceFields.named('value');
    expect(field.documentation, contains('The underlying [value].'));
    expect(field.isDeprecated, isTrue);
  }
}
