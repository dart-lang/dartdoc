// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion A reference in a doc comment (e.g., `[name]`) can link to any
/// Dart element that is visible from the Dart scope of the documented element.
/// ...
/// This includes:
/// ...
/// - Classes (e.g., `[MyClass]`)
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ReferenceableClassesTest);
  });
}

/// Verifies that classes are referenceable elements, i.e. that a reference
/// `[C]` in a doc comment is resolved to the class `C` and rendered as a link
/// to the documentation page of the class.
@reflectiveTest
class ReferenceableClassesTest extends Co19TestBase {
  String get _linkToC => '<a href="$linkPrefix/C-class.html">C</a>';

  /// Check that a class can be referenced from the doc comment of a library.
  void test_fromLibrary() async {
    var library = await bootLibrary('''
/// Reference to [C].
library co19;

class C {}
''');
    expect(library.documentationAsHtml, '<p>Reference to $_linkToC.</p>');
  }

  /// Check that a class can be referenced from its own doc comment.
  void test_fromItself() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [C].
class C {}
''');
    expect(library.classes.named('C').documentationAsHtml,
        '<p>Reference to $_linkToC.</p>');
  }

  /// Check that a class can be referenced from the doc comments of other
  /// class-like top-level declarations.
  void test_fromClassLikeDeclarations() async {
    var library = await bootPackageWithLibrary('''
class C {}

/// Reference to [C].
class A {}

/// Reference to [C].
mixin M {}

/// Reference to [C].
mixin class MC {}

/// Reference to [C].
enum E { e0 }

/// Reference to [C].
extension Ext on int {}

/// Reference to [C].
extension type ET(int _) {}
''');
    var expected = '<p>Reference to $_linkToC.</p>';
    expect(library.classes.named('A').documentationAsHtml, expected);
    expect(library.mixins.named('M').documentationAsHtml, expected);
    expect(library.classes.named('MC').documentationAsHtml, expected);
    expect(library.enums.named('E').documentationAsHtml, expected);
    expect(library.extensions.named('Ext').documentationAsHtml, expected);
    expect(library.extensionTypes.named('ET').documentationAsHtml, expected);
  }

  /// Check that a class can be referenced from the doc comments of typedefs.
  void test_fromTypedefs() async {
    var library = await bootPackageWithLibrary('''
class C {}

/// Reference to [C].
typedef T1 = C;

/// Reference to [C].
typedef T2 = void Function(int);

/// Reference to [C].
typedef T3 = (int, {String s});
''');
    var expected = '<p>Reference to $_linkToC.</p>';
    expect(library.typedefs.named('T1').documentationAsHtml, expected);
    expect(library.typedefs.named('T2').documentationAsHtml, expected);
    expect(library.typedefs.named('T3').documentationAsHtml, expected);
  }

  /// Check that a class can be referenced from the doc comment of an old-style
  /// function type alias.
  void test_fromOldStyleTypedef() async {
    var library = await bootPackageWithLibrary('''
class C {}

/// Reference to [C].
typedef void T(int x);
''', libraryPreamble: '// @dart=3.15');
    expect(library.typedefs.named('T').documentationAsHtml,
        '<p>Reference to $_linkToC.</p>');
  }

  /// Check that a class can be referenced from the doc comments of top-level
  /// functions, variables, getters and setters.
  void test_fromTopLevelMembers() async {
    var library = await bootPackageWithLibrary('''
class C {}

/// Reference to [C].
void f() {}

/// Reference to [C].
int v = 0;

/// Reference to [C].
const c = 0;

/// Reference to [C].
int get g => 0;

/// Reference to [C].
set s(int _) {}
''');
    var expected = '<p>Reference to $_linkToC.</p>';
    expect(library.functions.named('f').documentationAsHtml, expected);
    expect(library.properties.named('v').documentationAsHtml, expected);
    expect(library.constants.named('c').documentationAsHtml, expected);
    expect(library.properties.named('g').documentationAsHtml, expected);
    expect(library.properties.named('s').documentationAsHtml, expected);
  }

  /// Check that a class can be referenced from the doc comments of members of
  /// a class.
  void test_fromClassMembers() async {
    var library = await bootPackageWithLibrary('''
class C {}

class A {
  /// Reference to [C].
  A();

  /// Reference to [C].
  A.named();

  /// Reference to [C].
  factory A.f() => A();

  /// Reference to [C].
  int instanceField = 0;

  /// Reference to [C].
  static int staticField = 0;

  /// Reference to [C].
  void instanceMethod() {}

  /// Reference to [C].
  static void staticMethod() {}

  /// Reference to [C].
  int operator +(int other) => other;

  /// Reference to [C].
  int get getter => 0;

  /// Reference to [C].
  set setter(int _) {}
}
''');
    var expected = '<p>Reference to $_linkToC.</p>';
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

  /// Check that a class can be referenced from the doc comments of members of
  /// a mixin, an enum, an extension and an extension type.
  void test_fromOtherMembers() async {
    var library = await bootPackageWithLibrary('''
class C {}

mixin M {
  /// Reference to [C].
  void m() {}
}

enum E {
  /// Reference to [C].
  e0;

  /// Reference to [C].
  void m() {}
}

extension Ext on int {
  /// Reference to [C].
  void m() {}
}

extension type ET(int _) {
  /// Reference to [C].
  ET.named(this._);

  /// Reference to [C].
  void m() {}
}
''');
    var expected = '<p>Reference to $_linkToC.</p>';
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

  /// Check that a class can be referenced from the doc comments of body parts
  /// of primary constructors of a class, a mixin class, an enum and an
  /// extension type.
  void test_fromPrimaryConstructorBody() async {
    var library = await bootPackageWithLibrary('''
class C {}

class A(int x) {
  /// Reference to [C].
  this;
}

class B.named(int x) {
  /// Reference to [C].
  this : assert(x > 0);
}

mixin class D() {
  /// Reference to [C].
  this;
}

enum E(final int x) {
  e0(1);

  /// Reference to [C].
  this;
}

extension type ET(int x) {
  /// Reference to [C].
  this;
}
''');
    var expected = '<p>Reference to $_linkToC.</p>';
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

  /// Check that a class can be referenced before its declaration in the
  /// library.
  void test_forwardReference() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [C].
void f() {}

class C {}
''');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to $_linkToC.</p>');
  }

  /// Check that classes with class modifiers can be referenced.
  void test_classModifiers() async {
    var library = await bootPackageWithLibrary('''
abstract class C1 {}
base class C2 {}
final class C3 {}
interface class C4 {}
sealed class C5 {}
abstract base class C6 {}
abstract final class C7 {}
abstract interface class C8 {}
mixin class C9 {}
base mixin class C10 {}
abstract mixin class C11 {}
abstract base mixin class C12 {}

/// [C1], [C2], [C3], [C4], [C5], [C6], [C7], [C8], [C9], [C10], [C11], [C12].
void f() {}
''');
    var links = [
      for (var i = 1; i <= 12; i++)
        '<a href="$linkPrefix/C$i-class.html">C$i</a>'
    ];
    expect(library.functions.named('f').documentationAsHtml,
        '<p>${links.join(', ')}.</p>');
  }

  /// Check that a generic class can be referenced by its name.
  void test_genericClass() async {
    var library = await bootPackageWithLibrary('''
class C<T extends num, R> {}

/// Reference to [C].
void f() {}
''');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to $_linkToC.</p>');
  }

  /// Check that a class declared in the `dart:core` library can be referenced.
  void test_dartCoreClass() async {
    var library = await bootPackageWithLibrary('''
/// Reference to [Object] and [String].
void f() {}
''');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="$dartCoreUrlPrefix/Object-class.html">Object</a> and '
        '<a href="$dartCoreUrlPrefix/String-class.html">String</a>.</p>');
  }

  /// Check that a class declared in an imported library can be referenced.
  void test_importedClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

class C {}
'''),
      d.file('lib/co19.dart', '''
library co19;

import 'other.dart';

/// Reference to [C].
void f(C c) {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to <a href="${placeholder}other/C-class.html">C</a>.</p>');
  }

  /// Check that a class declared in a library imported with a prefix can be
  /// referenced by a qualified name.
  void test_prefixedImportedClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

class C {}
'''),
      d.file('lib/co19.dart', '''
library co19;

import 'other.dart' as p;

/// Reference to [p.C].
void f(p.C c) {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/C-class.html">p.C</a>.</p>');
  }

  /// Check that a class declared in a library imported with `@docImport` can
  /// be referenced.
  void test_docImportedClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

class C {}
'''),
      d.file('lib/co19.dart', '''
/// @docImport 'other.dart';
library co19;

/// Reference to [C].
void f() {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(library.functions.named('f').documentationAsHtml,
        '<p>Reference to <a href="${placeholder}other/C-class.html">C</a>.</p>');
  }

  /// Check that a class declared in a library imported with a prefixed
  /// `@docImport` can be referenced by a qualified name.
  void test_prefixedDocImportedClass() async {
    var graph = await bootPackageFromFiles([
      d.file('lib/other.dart', '''
library other;

class C {}
'''),
      d.file('lib/co19.dart', '''
/// @docImport 'other.dart' as p;
library co19;

/// Reference to [p.C].
void f() {}
'''),
    ]);
    var library = graph.libraries.named('co19');
    expect(
        library.functions.named('f').documentationAsHtml,
        '<p>Reference to '
        '<a href="${placeholder}other/C-class.html">p.C</a>.</p>');
  }
}
