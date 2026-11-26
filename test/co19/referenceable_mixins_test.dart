// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion A reference in a doc comment (e.g., `[name]`) can link to any
/// Dart element that is visible from the Dart scope of the documented element.
/// ...
/// This includes:
/// ...
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
    defineReflectiveTests(ReferenceableMixinsTest);
  });
}

/// Verifies that mixins are referenceable elements, i.e. that a reference `[M]`
/// in a doc comment is resolved to the mixin `M` and rendered as a link to the
/// documentation page of the mixin.
@reflectiveTest
class ReferenceableMixinsTest extends Co19TestBase {
  String get _linkToM => '<a href="$linkPrefix/M-mixin.html">M</a>';

  /// Check that a mixin can be referenced from the doc comment of a library.
  void test_fromLibrary() async {
    var library = await bootLibrary('''
/// Reference to [M].
library co19;

mixin M {}
''');
    expect(library.documentationAsHtml, '<p>Reference to $_linkToM.</p>');
  }

  /// Check that a mixin can be referenced from its own doc comment.
  void test_fromItself() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [M].
mixin M {}
''');
    expect(library.mixins.named('M').documentationAsHtml,
        '<p>Reference to $_linkToM.</p>');
  }

  /// Check that a mixin can be referenced from the doc comments of other
  /// class-like top-level declarations.
  void test_fromClassLikeDeclarations() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

/// Reference to [M].
class A {}

/// Reference to [M].
mixin M1 {}

/// Reference to [M].
mixin class MC {}

/// Reference to [M].
enum E { e0 }

/// Reference to [M].
extension Ext on int {}

/// Reference to [M].
extension type ET(int _) {}
''');
    var expected = '<p>Reference to $_linkToM.</p>';
    expect(library.classes.named('A').documentationAsHtml, expected);
    expect(library.mixins.named('M1').documentationAsHtml, expected);
    expect(library.classes.named('MC').documentationAsHtml, expected);
    expect(library.enums.named('E').documentationAsHtml, expected);
    expect(library.extensions.named('Ext').documentationAsHtml, expected);
    expect(library.extensionTypes.named('ET').documentationAsHtml, expected);
  }

  /// Check that a mixin can be referenced from the doc comments of typedefs.
  void test_fromTypedefs() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

/// Reference to [M].
typedef T1 = M;

/// Reference to [M].
typedef T2 = void Function(int);

/// Reference to [M].
typedef T3 = (int, {String s});
''');
    var expected = '<p>Reference to $_linkToM.</p>';
    expect(library.typedefs.named('T1').documentationAsHtml, expected);
    expect(library.typedefs.named('T2').documentationAsHtml, expected);
    expect(library.typedefs.named('T3').documentationAsHtml, expected);
  }

  /// Check that a mixin can be referenced from the doc comment of an old-style
  /// function type alias.
  void test_fromOldStyleTypedef() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

/// Reference to [M].
typedef void T(int x);
''', libraryPreamble: '// @dart=3.15');
    expect(library.typedefs.named('T').documentationAsHtml,
        '<p>Reference to $_linkToM.</p>');
  }

  /// Check that a mixin can be referenced from the doc comments of top-level
  /// functions, variables, getters and setters.
  void test_fromTopLevelMembers() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

/// Reference to [M].
void f() {}

/// Reference to [M].
int v = 0;

/// Reference to [M].
const c = 0;

/// Reference to [M].
int get g => 0;

/// Reference to [M].
set s(int _) {}
''');
    var expected = '<p>Reference to $_linkToM.</p>';
    expect(library.functions.named('f').documentationAsHtml, expected);
    expect(library.properties.named('v').documentationAsHtml, expected);
    expect(library.constants.named('c').documentationAsHtml, expected);
    expect(library.properties.named('g').documentationAsHtml, expected);
    expect(library.properties.named('s').documentationAsHtml, expected);
  }

  /// Check that a mixin can be referenced from the doc comments of members of a
  /// class.
  void test_fromClassMembers() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

class A {
  /// Reference to [M].
  A();

  /// Reference to [M].
  A.named();

  /// Reference to [M].
  factory A.f() => A();

  /// Reference to [M].
  int instanceField = 0;

  /// Reference to [M].
  static int staticField = 0;

  /// Reference to [M].
  void instanceMethod() {}

  /// Reference to [M].
  static void staticMethod() {}

  /// Reference to [M].
  int operator +(int other) => other;

  /// Reference to [M].
  int get getter => 0;

  /// Reference to [M].
  set setter(int _) {}
}
''');
    var expected = '<p>Reference to $_linkToM.</p>';
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

  /// Check that a mixin can be referenced from the doc comments of members of a
  /// mixin, an enum, an extension and an extension type.
  void test_fromOtherMembers() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

mixin M1 {
  /// Reference to [M].
  void m() {}
}

enum E {
  /// Reference to [M].
  e0;

  /// Reference to [M].
  void m() {}
}

extension Ext on int {
  /// Reference to [M].
  void m() {}
}

extension type ET(int _) {
  /// Reference to [M].
  ET.named(this._);

  /// Reference to [M].
  void m() {}
}
''');
    var expected = '<p>Reference to $_linkToM.</p>';
    expect(
        library.mixins
            .named('M1')
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

  /// Check that a mixin can be referenced from the doc comments of body parts
  /// of primary constructors of a class, a mixin class, an enum and an
  /// extension type.
  void test_fromPrimaryConstructorBody() async {
    var library = await bootPackageWithLibrary('''
mixin M {}

class A(int x) {
  /// Reference to [M].
  this;
}

class B.named(int x) {
  /// Reference to [M].
  this : assert(x > 0);
}

mixin class D() {
  /// Reference to [M].
  this;
}

enum E(final int x) {
  e0(1);

  /// Reference to [M].
  this;
}

extension type ET(int x) {
  /// Reference to [M].
  this;
}
''');
    var expected = '<p>Reference to $_linkToM.</p>';
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

  /// Check that a mixin can be referenced before its declaration in the
  /// library.
  void test_forwardReference() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [M].
void f() {}

mixin M {}
''');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to $_linkToM.</p>');
  }

  /// Check that mixins with the `base` modifier and with `on` and `implements`
  /// clauses can be referenced.
  void test_mixinModifiersAndClauses() async {
    var library = await bootPackageWithLibrary('''
class A {}

mixin M1 {}
base mixin M2 {}
mixin M3 on A {}
mixin M4 implements A {}
base mixin M5 on A implements Comparable<A> {}

/// [M1], [M2], [M3], [M4], [M5].
void f() {}
''');
    var links = [
      for (var i = 1; i <= 5; i++)
        '<a href="$linkPrefix/M$i-mixin.html">M$i</a>'
    ];
    expect(library.functions.named('f').documentationAsHtml,
        '<p>${links.join(', ')}.</p>');
  }

  /// Check that a generic mixin can be referenced by its name.
  void test_genericMixin() async {
    var library = await bootPackageWithLibrary('''
mixin M<T extends num, R> {}

/// Reference to [M].
void f() {}
''');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to $_linkToM.</p>');
  }

  /// Check that a mixin declared in an imported library can be referenced.
  void test_importedMixin() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin M {}
'''),
      d.file('lib/co19.dart', '''
library co19;

import 'other.dart';

/// Reference to [M].
void f(M m) {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/M-mixin.html">M</a>.</p>');
  }

  /// Check that a mixin declared in a library imported with a prefix can be
  /// referenced by a qualified name.
  void test_prefixedImportedMixin() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin M {}
'''),
      d.file('lib/co19.dart', '''
library co19;

import 'other.dart' as p;

/// Reference to [p.M].
void f(p.M m) {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/M-mixin.html">p.M</a>.</p>');
  }

  /// Check that a mixin declared in a library imported with `@docImport` can be
  /// referenced.
  void test_docImportedMixin() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin M {}
'''),
      d.file('lib/co19.dart', '''
/// @docImport 'other.dart';
library co19;

/// Reference to [M].
void f() {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/M-mixin.html">M</a>.</p>');
  }

  /// Check that a mixin declared in a library imported with a prefixed
  /// `@docImport` can be referenced by a qualified name.
  void test_prefixedDocImportedMixin() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

mixin M {}
'''),
      d.file('lib/co19.dart', '''
/// @docImport 'other.dart' as p;
library co19;

/// Reference to [p.M].
void f() {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/M-mixin.html">p.M</a>.</p>');
  }
}
