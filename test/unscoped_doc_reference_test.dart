// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnscopedDocReferenceTest);
  });
}

/// Tests for [PackageWarning.unscopedDocReference], which is reported when
/// dartdoc resolves a doc comment reference that the analyzer does not.
@reflectiveTest
class UnscopedDocReferenceTest extends DartdocTestBase {
  @override
  String get libraryName => 'unscoped';

  bool _hasUnscopedWarning(Warnable warnable, String reference) =>
      warnable.packageGraph.packageWarningCounter
          .hasWarning(warnable, PackageWarning.unscopedDocReference, reference);

  void test_isIgnoredByDefault() async {
    var library = await bootPackageWithLibrary('int x = 0;');
    expect(
      library.config.packageWarningOptions
          .getMode(PackageWarning.unscopedDocReference),
      PackageWarningMode.ignore,
    );
  }

  void test_notImported_warns() async {
    var library = await bootPackageWithLibrary(
      '''
/// Text [Other].
int x = 0;
''',
      extraFiles: [d.file('lib/other.dart', 'class Other {}')],
    );
    var x = library.properties.named('x');
    // Dartdoc still links the reference through its package-wide lookup.
    expect(x.documentationAsHtml, contains('<a href='));
    expect(_hasUnscopedWarning(x, 'Other'), isTrue);
  }

  void test_parameterOfOtherMember_warns() async {
    var library = await bootPackageWithLibrary('''
/// Text [value].
class C {
  void m(int value) {}
}
''');
    var c = library.classes.named('C');
    expect(c.documentationAsHtml, isNotEmpty);
    expect(_hasUnscopedWarning(c, 'value'), isTrue);
  }

  void test_inScope_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
class Other {}

/// Text [Other].
int x = 0;
''');
    var x = library.properties.named('x');
    expect(x.documentationAsHtml, contains('<a href='));
    expect(_hasUnscopedWarning(x, 'Other'), isFalse);
  }

  void test_docImported_doesNotWarn() async {
    var library = await bootPackageWithLibrary(
      '''
/// Text [Other].
int x = 0;
''',
      libraryPreamble: "/// @docImport 'other.dart';",
      extraFiles: [d.file('lib/other.dart', 'class Other {}')],
    );
    var x = library.properties.named('x');
    expect(x.documentationAsHtml, contains('<a href='));
    expect(_hasUnscopedWarning(x, 'Other'), isFalse);
  }

  void test_unresolved_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
/// Text [Nothing].
int x = 0;
''');
    var x = library.properties.named('x');
    expect(x.documentationAsHtml, isNotEmpty);
    expect(_hasUnscopedWarning(x, 'Nothing'), isFalse);
    expect(
      x.packageGraph.packageWarningCounter
          .hasWarning(x, PackageWarning.unresolvedDocReference, 'Nothing'),
      isTrue,
    );
  }

  void test_docImportPrefix_doesNotWarn() async {
    var library = await bootPackageWithLibrary(
      '''
/// Text [async] and [async.Future].
int x = 0;
''',
      libraryPreamble: "/// @docImport 'dart:async' as async;",
      additionalArguments: ['--link-to-remote'],
    );
    var x = library.properties.named('x');
    expect(x.documentationAsHtml, contains('<a href='));
    // The analyzer resolves both the bare prefix and the prefixed name.
    expect(_hasUnscopedWarning(x, 'async'), isFalse);
  }

  static const _inheritedLibrary = '''
class A {
  /// Text [Other].
  void m() {}
}

class B extends A {
  @override
  void m() {}
}
''';

  void test_inheritedDocumentation_warns() async {
    var library = await bootPackageWithLibrary(
      _inheritedLibrary,
      extraFiles: [d.file('lib/other.dart', 'class Other {}')],
    );
    var bM = library.classes.named('B').instanceMethods.named('m');
    // `B.m` has no comment of its own; it shows `A.m`'s, in which the analyzer
    // could not resolve `[Other]`.
    expect(bM.documentationAsHtml, contains('<a href='));
    expect(_hasUnscopedWarning(bM, 'Other'), isTrue);
  }
}
