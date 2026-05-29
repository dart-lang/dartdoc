// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model_element.dart';
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
class Derived(super.x, super.y, super.z) extends C;
''');

    var c = library.classes.named('C');
    expect(c.declaredFields.map((f) => f.name), unorderedEquals(['x', 'y']));

    // Verify 'x' is not a newly induced field in the subclass
    var derived = library.classes.named('Derived');
    expect(derived.declaredFields.any((f) => f.name == 'x'), isFalse);
    var constructor = derived.constructors.first;
    expect(constructor.parameters.any((p) => p.name == 'x'), isTrue);
  }

  void test_fieldInduction_optionalPositional() async {
    var library = await bootPackageWithLibrary('''
class C([var int x = 1]);
''');

    var c = library.classes.named('C');
    var constructor = c.constructors.first;

    expect(c.instanceFields.any((f) => f.name == 'x'), isTrue);

    var paramX = constructor.parameters.firstWhere((p) => p.name == 'x');

    expect(paramX.isOptionalPositional, isTrue);
    expect(paramX.defaultValue, equals('1'));
  }

  void test_fieldInduction_named() async {
    var library = await bootPackageWithLibrary('''
class C({final int y = 2});
''');

    var c = library.classes.named('C');
    var constructor = c.constructors.first;

    expect(c.instanceFields.any((f) => f.name == 'y'), isTrue);

    var paramY = constructor.parameters.firstWhere((p) => p.name == 'y');

    expect(paramY.isNamed, isTrue);
    expect(paramY.defaultValue, equals('2'));
  }

  void test_fieldInduction_typeParameters() async {
    var library = await bootPackageWithLibrary('''
class Box<T>(var T value);
''');

    var box = library.classes.named('Box');
    var field = box.instanceFields.named('value');

    expect(field, isNotNull);
    expect(field.modelType.name, equals('T'));
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
    expect(c.constructors.first.parameters.named('z').isDeprecated, isTrue);
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

  // ---------------------------------------------------------------------------
  // Comment References
  // ---------------------------------------------------------------------------

  @FailingTest(
      reason: 'dartdoc currently resolves primary constructor parameters '
          'from class-level comments')
  void test_metadata_commentReference_nonDeclaring() async {
    var library = await bootPackageWithLibrary('''
/// Points to [x].
class C(int x);
''');
    var c = library.classes.named('C');

    var result = referenceLookup(c, 'x').referable;

    // A class-level comment starts at the class member scope. Since 'x' does
    // not induce a field, it is not a class member and should fail to resolve.
    expect(result, isNull);
  }

  void test_metadata_commentReference_declaring() async {
    var library = await bootPackageWithLibrary('''
/// Points to [x].
class C(var int x);
''');
    var c = library.classes.named('C');
    var xField = c.instanceFields.named('x');

    var result = referenceLookup(c, 'x').referable as ModelElement;

    // TODO(zarah): Update this when Dartdoc's scope resolution aligns with the
    // Dart Documentation Comment Specification, which states that property
    // references should resolve to the conceptual property (the field) rather
    // than the getter.
    // expect(result.element, equals(xField.element));

    // Dartdoc currently prefers resolving to the getter for properties in
    // scope.
    expect(result.element, equals(xField.getter!.element));
  }

  @FailingTest(
      reason: 'dartdoc currently resolves primary constructor parameters from '
          'class-level comments')
  void test_metadata_commentReference_super_nonDeclaring() async {
    var library = await bootPackageWithLibrary('''
class Base(int x);
/// Points to [x].
class Derived(super.x) extends Base;
''');
    var derived = library.classes.named('Derived');

    var result = referenceLookup(derived, 'x').referable;

    // 'super.x' does not induce a field, so it is not in the class member
    // scope.
    expect(result, isNull);
  }

  void test_metadata_commentReference_super_declaring() async {
    var library = await bootPackageWithLibrary('''
class Base(var int x);
/// Points to [x].
class Derived(super.x) extends Base;
''');
    var derived = library.classes.named('Derived');
    var baseClass = library.classes.named('Base');
    var xField = baseClass.instanceFields.named('x');

    var result = referenceLookup(derived, 'x').referable as ModelElement;

    // TODO(zarah): Update this when Dartdoc's scope resolution aligns with the
    // Dart Documentation Comment Specification, which states that property
    // references should resolve to the conceptual property (the field) rather
    // than the getter.
    // expect(result.element, equals(xField.element));

    // Dartdoc currently prefers resolving to the getter for properties in
    // scope.
    expect(result.element, equals(xField.getter!.element));
  }

  // ---------------------------------------------------------------------------
  // Private Named Parameters
  // ---------------------------------------------------------------------------

  void test_privateNamedParameter_becomesPublic() async {
    var library = await bootPackageWithLibrary(
      '''
class C({
     /// Points to [_name].
    required var String _name
});
''',
      libraryPreamble: '// @dart=3.12',
    );

    var c = library.classes.named('C');

    var field = c.instanceFields.named('_name');
    expect(field.isPublic, isFalse);

    var constructor = c.constructors.first;
    var parameter = constructor.parameters.first;
    expect(parameter.documentedName, equals('name')); // Parameter is public

    var result = referenceLookup(c, '_name').referable as ModelElement;
    expect(result.element, equals(field.element));
  }

  // ---------------------------------------------------------------------------
  // Primary Constructor Body (this block)
  // ---------------------------------------------------------------------------

  void test_primaryConstructorBody_documentation() async {
    var library = await bootPackageWithLibrary('''
class C(int x) {
  /// Docs for the primary constructor.
  this;
}
''');

    var c = library.classes.named('C');
    var constructor = c.constructors.first;

    expect(constructor.documentation,
        contains('Docs for the primary constructor.'));
  }

  void test_primaryConstructorBody_commentReference() async {
    var library = await bootPackageWithLibrary('''
class C(int x) {
  /// Points to [x].
  this;
}
''');

    var c = library.classes.named('C');
    var constructor = c.constructors.first;
    var xParam = constructor.parameters.first;

    var result = referenceLookup(constructor, 'x').referable as ModelElement;
    expect(result.element, equals(xParam.element));
  }

  // ---------------------------------------------------------------------------
  // Abbreviated Constructors
  // ---------------------------------------------------------------------------

  void test_secondaryConstructors_new() async {
    var library = await bootPackageWithLibrary('''
class MyClass {
  const new();
  new name();
  new redir(): this.name();
}
''');

    var c = library.classes.named('MyClass');
    expect(
      c.constructors.map((cons) => cons.name),
      unorderedEquals([
        'MyClass.new',
        'MyClass.name',
        'MyClass.redir',
      ]),
    );
  }

  void test_secondaryConstructors_factory() async {
    var library = await bootPackageWithLibrary(
      '''
class MyClass {
  const new();
  factory fact() => .new();
  const factory redirFact() = MyClass;
}
''',
      libraryPreamble: '// @dart=3.12',
    );

    var c = library.classes.named('MyClass');
    expect(
      c.constructors.map((cons) => cons.name),
      unorderedEquals(['MyClass.new', 'MyClass.fact', 'MyClass.redirFact']),
    );
  }
}
