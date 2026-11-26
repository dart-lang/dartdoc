// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion A reference in a doc comment (e.g., `[name]`) can link to any
/// Dart element that is visible from the Dart scope of the documented element.
/// ...
/// This includes:
/// ...
/// - Classes (e.g., `[MyClass]`)
/// - Mixins (e.g., `[MyMixin]`)
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ReferenceableMixinClassesTest);
  });
}

/// Verifies that mixin classes are referenceable elements, i.e. that a
/// reference `[MC]` in a doc comment is resolved to the mixin class `MC` and
/// rendered as a link to the documentation page of the mixin class.
@reflectiveTest
class ReferenceableMixinClassesTest extends Co19TestBase {
  String get _linkToMC => '<a href="$linkPrefix/MC-class.html">MC</a>';

  /// Check that a mixin class can be referenced from the doc comment of a
  /// library.
  void test_fromLibrary() async {
    var library = await bootLibrary('''
/// Reference to [MC].
library co19;

mixin class MC {}
''');
    expect(library.documentationAsHtml, '<p>Reference to $_linkToMC.</p>');
  }

  /// Check that a mixin class can be referenced from its own doc comment.
  void test_fromItself() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [MC].
mixin class MC {}
''');
    expect(library.classes.named('MC').documentationAsHtml,
        '<p>Reference to $_linkToMC.</p>');
  }

  /// Check that a mixin class can be referenced from the doc comments of other
  /// class-like top-level declarations.
  void test_fromClassLikeDeclarations() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

/// Reference to [MC].
class A {}

/// Reference to [MC].
mixin M {}

/// Reference to [MC].
mixin class MC1 {}

/// Reference to [MC].
enum E { e0 }

/// Reference to [MC].
extension Ext on int {}

/// Reference to [MC].
extension type ET(int _) {}
''');
    var expected = '<p>Reference to $_linkToMC.</p>';
    expect(library.classes.named('A').documentationAsHtml, expected);
    expect(library.mixins.named('M').documentationAsHtml, expected);
    expect(library.classes.named('MC1').documentationAsHtml, expected);
    expect(library.enums.named('E').documentationAsHtml, expected);
    expect(library.extensions.named('Ext').documentationAsHtml, expected);
    expect(library.extensionTypes.named('ET').documentationAsHtml, expected);
  }

  /// Check that a mixin class can be referenced from the doc comments of
  /// typedefs.
  void test_fromTypedefs() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

/// Reference to [MC].
typedef T1 = MC;

/// Reference to [MC].
typedef T2 = void Function(int);

/// Reference to [MC].
typedef T3 = (int, {String s});
''');
    var expected = '<p>Reference to $_linkToMC.</p>';
    expect(library.typedefs.named('T1').documentationAsHtml, expected);
    expect(library.typedefs.named('T2').documentationAsHtml, expected);
    expect(library.typedefs.named('T3').documentationAsHtml, expected);
  }

  /// Check that a mixin class can be referenced from the doc comment of an
  /// old-style function type alias.
  void test_fromOldStyleTypedef() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

/// Reference to [MC].
typedef void T(int x);
''', libraryPreamble: '// @dart=3.15');
    expect(library.typedefs.named('T').documentationAsHtml,
        '<p>Reference to $_linkToMC.</p>');
  }

  /// Check that a mixin class can be referenced from the doc comments of
  /// top-level functions, variables, getters and setters.
  void test_fromTopLevelMembers() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

/// Reference to [MC].
void f() {}

/// Reference to [MC].
int v = 0;

/// Reference to [MC].
const c = 0;

/// Reference to [MC].
int get g => 0;

/// Reference to [MC].
set s(int _) {}
''');
    var expected = '<p>Reference to $_linkToMC.</p>';
    expect(library.functions.named('f').documentationAsHtml, expected);
    expect(library.properties.named('v').documentationAsHtml, expected);
    expect(library.constants.named('c').documentationAsHtml, expected);
    expect(library.properties.named('g').documentationAsHtml, expected);
    expect(library.properties.named('s').documentationAsHtml, expected);
  }

  /// Check that a mixin class can be referenced from the doc comments of
  /// members of a class.
  void test_fromClassMembers() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

class A {
  /// Reference to [MC].
  A();

  /// Reference to [MC].
  A.named();

  /// Reference to [MC].
  factory A.f() => A();

  /// Reference to [MC].
  int instanceField = 0;

  /// Reference to [MC].
  static int staticField = 0;

  /// Reference to [MC].
  void instanceMethod() {}

  /// Reference to [MC].
  static void staticMethod() {}

  /// Reference to [MC].
  int operator +(int other) => other;

  /// Reference to [MC].
  int get getter => 0;

  /// Reference to [MC].
  set setter(int _) {}
}
''');
    var expected = '<p>Reference to $_linkToMC.</p>';
    var a = library.classes.named('A');
    expect(a.constructors.named('A.new').documentationAsHtml, expected);
    expect(a.constructors.named('A.named').documentationAsHtml, expected);
    expect(a.constructors.named('A.f').documentationAsHtml, expected);
    expect(
        a.instanceFields.named('instanceField').documentationAsHtml, expected);
    expect(a.staticFields.named('staticField').documentationAsHtml, expected);
    expect(a.instanceMethods.named('instanceMethod').documentationAsHtml,
        expected);
    expect(a.staticMethods.named('staticMethod').documentationAsHtml, expected);
    expect(
        a.instanceOperators.named('operator +').documentationAsHtml, expected);
    expect(a.instanceFields.named('getter').documentationAsHtml, expected);
    expect(a.instanceFields.named('setter').documentationAsHtml, expected);
  }

  /// Check that a mixin class can be referenced from the doc comments of
  /// members of a mixin, an enum, an extension and an extension type.
  void test_fromOtherMembers() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

mixin M {
  /// Reference to [MC].
  void m() {}
}

enum E {
  /// Reference to [MC].
  e0;

  /// Reference to [MC].
  void m() {}
}

extension Ext on int {
  /// Reference to [MC].
  void m() {}
}

extension type ET(int _) {
  /// Reference to [MC].
  ET.named(this._);

  /// Reference to [MC].
  void m() {}
}
''');
    var expected = '<p>Reference to $_linkToMC.</p>';
    expect(
        library.mixins
            .named('M')
            .instanceMethods
            .named('m')
            .documentationAsHtml,
        expected);
    var e = library.enums.named('E');
    expect(e.publicEnumValues.named('e0').documentationAsHtml, expected);
    expect(e.instanceMethods.named('m').documentationAsHtml, expected);
    expect(
        library.extensions
            .named('Ext')
            .instanceMethods
            .named('m')
            .documentationAsHtml,
        expected);
    var et = library.extensionTypes.named('ET');
    expect(et.constructors.named('ET.named').documentationAsHtml, expected);
    expect(et.instanceMethods.named('m').documentationAsHtml, expected);
  }

  /// Check that a mixin class can be referenced from the doc comments of body
  /// parts of primary constructors of a class, a mixin class, an enum and an
  /// extension type.
  void test_fromPrimaryConstructorBody() async {
    var library = await bootPackageWithLibrary('''
mixin class MC {}

class A(int x) {
  /// Reference to [MC].
  this;
}

class B.named(int x) {
  /// Reference to [MC].
  this : assert(x > 0);
}

mixin class D() {
  /// Reference to [MC].
  this;
}

enum E(final int x) {
  e0(1);

  /// Reference to [MC].
  this;
}

extension type ET(int x) {
  /// Reference to [MC].
  this;
}
''');
    var expected = '<p>Reference to $_linkToMC.</p>';
    expect(
        library.classes
            .named('A')
            .constructors
            .named('A.new')
            .documentationAsHtml,
        expected);
    expect(
        library.classes
            .named('B')
            .constructors
            .named('B.named')
            .documentationAsHtml,
        expected);
    expect(
        library.classes
            .named('D')
            .constructors
            .named('D.new')
            .documentationAsHtml,
        expected);
    expect(
        library.enums
            .named('E')
            .constructors
            .named('E.new')
            .documentationAsHtml,
        expected);
    expect(
        library.extensionTypes
            .named('ET')
            .constructors
            .named('ET.new')
            .documentationAsHtml,
        expected);
  }

  /// Check that a mixin class can be referenced before its declaration in the
  /// library.
  void test_forwardReference() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [MC].
void f() {}

mixin class MC {}
''');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to $_linkToMC.</p>');
  }

  /// Check that mixin classes with class modifiers can be referenced.
  void test_mixinClassModifiers() async {
    var library = await bootPackageWithLibrary('''
mixin class MC1 {}
base mixin class MC2 {}
abstract mixin class MC3 {}
abstract base mixin class MC4 {}

/// [MC1], [MC2], [MC3], [MC4].
void f() {}
''');
    var links = [
      for (var i = 1; i <= 4; i++)
        '<a href="$linkPrefix/MC$i-class.html">MC$i</a>'
    ];
    expect(library.functions.named('f').documentationAsHtml,
        '<p>${links.join(', ')}.</p>');
  }

  /// Check that a generic mixin class can be referenced by its name.
  void test_genericMixinClass() async {
    var library = await bootPackageWithLibrary('''
mixin class MC<T extends num, R> {}

/// Reference to [MC].
void f() {}
''');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to $_linkToMC.</p>');
  }

  /// Check that a mixin class declared in the `dart:core` library can be
  /// referenced.
  void test_dartCoreMixinClass() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [Iterable].
void f() {}
''');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="$dartCoreUrlPrefix/Iterable-class.html">Iterable</a>.</p>');
  }

  /// Check that a mixin class declared in an imported library can be
  /// referenced.
  void test_importedMixinClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin class MC {}
'''),
      d.file('lib/co19.dart', '''
library co19;

import 'other.dart';

/// Reference to [MC].
void f(MC mc) {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/MC-class.html">MC</a>.</p>');
  }

  /// Check that a mixin class declared in a library imported with a prefix can
  /// be referenced by a qualified name.
  void test_prefixedImportedMixinClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin class MC {}
'''),
      d.file('lib/co19.dart', '''
library co19;

import 'other.dart' as p;

/// Reference to [p.MC].
void f(p.MC mc) {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/MC-class.html">p.MC</a>.</p>');
  }

  /// Check that a mixin class declared in a library imported with `@docImport`
  /// can be referenced.
  void test_docImportedMixinClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin class MC {}
'''),
      d.file('lib/co19.dart', '''
/// @docImport 'other.dart';
library co19;

/// Reference to [MC].
void f() {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/MC-class.html">MC</a>.</p>');
  }

  /// Check that a mixin class declared in a library imported with a prefixed
  /// `@docImport` can be referenced by a qualified name.
  void test_prefixedDocImportedMixinClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin class MC {}
'''),
      d.file('lib/co19.dart', '''
/// @docImport 'other.dart' as p;
library co19;

/// Reference to [p.MC].
void f() {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/MC-class.html">p.MC</a>.</p>');
  }
}
