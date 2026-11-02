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
    defineReflectiveTests(DocReferenceTargetDiffersTest);
  });
}

/// Tests for [PackageWarning.docReferenceTargetDiffers], which is reported
/// when dartdoc and the analyzer resolve a doc comment reference to different
/// elements.
@reflectiveTest
class DocReferenceTargetDiffersTest extends DartdocTestBase {
  @override
  String get libraryName => 'target';

  bool _hasDiffersWarning(Warnable warnable, String reference) =>
      warnable.packageGraph.packageWarningCounter.hasWarning(
          warnable, PackageWarning.docReferenceTargetDiffers, reference);

  void test_isIgnoredByDefault() async {
    var library = await bootPackageWithLibrary('int x = 0;');
    expect(
      library.config.packageWarningOptions
          .getMode(PackageWarning.docReferenceTargetDiffers),
      PackageWarningMode.ignore,
    );
  }

  void test_inheritedDocumentation_staticShadowing_warns() async {
    var library = await bootPackageWithLibrary('''
class A {
  static void parse() {}

  /// Processes data by invoking [parse].
  void process() {}
}

class B extends A {
  // Unrelated to A.parse; it only happens to share the name.
  static void parse() {}

  @override
  void process() {}
}
''');
    var bProcess = library.classes.named('B').instanceMethods.named('process');
    // Dartdoc re-resolves the inherited comment in `B`, linking `B.parse`; the
    // analyzer resolved `[parse]` where the comment was written, to `A.parse`.
    expect(bProcess.documentationAsHtml, contains('B/parse.html'));
    expect(_hasDiffersWarning(bProcess, '[parse] links to target.B.parse'),
        isTrue);
    expect(_hasDiffersWarning(bProcess, 'A.parse'), isTrue);
    // At the definition site both agree.
    var aProcess = library.classes.named('A').instanceMethods.named('process');
    expect(_hasDiffersWarning(aProcess, 'parse'), isFalse);
  }

  void test_inheritedDocumentation_overriddenMember_warns() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// See [other].
  void m() {}

  void other() {}
}

class B extends A {
  @override
  void m() {}

  @override
  void other() {}
}
''');
    var bM = library.classes.named('B').instanceMethods.named('m');
    expect(bM.documentationAsHtml, contains('B/other.html'));
    expect(_hasDiffersWarning(bM, '[other] links to target.B.other'), isTrue);
  }

  void test_inheritedDocumentation_inheritedMember_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// See [other].
  void m() {}

  void other() {}
}

class B extends A {
  @override
  void m() {}
}
''');
    var bM = library.classes.named('B').instanceMethods.named('m');
    // `B.other` is inherited, not overridden, so it is the same element as
    // `A.other`.
    expect(bM.documentationAsHtml, contains('other.html'));
    expect(_hasDiffersWarning(bM, 'other'), isFalse);
  }

  void test_sameTarget_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
class Other {}

/// Text [Other].
int x = 0;
''');
    var x = library.properties.named('x');
    expect(x.documentationAsHtml, contains('<a href='));
    expect(_hasDiffersWarning(x, 'Other'), isFalse);
  }

  void test_fieldAndGetter_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
class C {
  int field = 0;

  int get getter => 0;

  /// Text [field] and [getter].
  void m() {}
}
''');
    var m = library.classes.named('C').instanceMethods.named('m');
    // The analyzer resolves `[field]` to the implicit getter; dartdoc links
    // the field. Both are normalized to the same element.
    expect(m.documentationAsHtml, contains('field.html'));
    expect(m.documentationAsHtml, contains('getter.html'));
    expect(_hasDiffersWarning(m, 'field'), isFalse);
    expect(_hasDiffersWarning(m, 'getter'), isFalse);
  }

  void test_inheritedDocumentation_inheritedGetter_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
class A {
  int get getter => 0;

  /// Text [getter].
  void m() {}
}

class B extends A {
  @override
  void m() {}
}
''');
    var bM = library.classes.named('B').instanceMethods.named('m');
    // Rendered in `B`, the inherited comment is re-resolved through the
    // children of `B`, linking the synthetic field of the inherited getter;
    // the analyzer resolved `[getter]` to the getter itself.
    expect(bM.documentationAsHtml, contains('getter.html'));
    expect(_hasDiffersWarning(bM, 'getter'), isFalse);
  }

  void test_memberOfGenericSupertype_doesNotWarn() async {
    var library = await bootPackageWithLibrary('''
class Base<T> {
  T get value => throw '';

  void run() {}
}

/// Text [value] and [run].
class Sub extends Base<int> {}
''');
    var sub = library.classes.named('Sub');
    // The analyzer resolves members inherited from `Base<int>` to substituted
    // copies of the declarations in `Base<T>`; dartdoc links the declarations.
    expect(sub.documentationAsHtml, contains('value.html'));
    expect(sub.documentationAsHtml, contains('run.html'));
    expect(_hasDiffersWarning(sub, 'value'), isFalse);
    expect(_hasDiffersWarning(sub, 'run'), isFalse);
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
    // The analyzer resolves `[async]` to the prefix, dartdoc links the
    // library; both are normalized to the library.
    expect(x.documentationAsHtml, contains('<a href='));
    expect(_hasDiffersWarning(x, 'async'), isFalse);
  }

  void test_unscoped_doesNotWarn() async {
    var library = await bootPackageWithLibrary(
      '''
/// Text [Other].
int x = 0;
''',
      extraFiles: [d.file('lib/other.dart', 'class Other {}')],
    );
    var x = library.properties.named('x');
    // The analyzer did not resolve the reference at all; that is the
    // `unscoped-doc-reference` case, not this one.
    expect(x.documentationAsHtml, contains('<a href='));
    expect(_hasDiffersWarning(x, 'Other'), isFalse);
    expect(
      x.packageGraph.packageWarningCounter
          .hasWarning(x, PackageWarning.unscopedDocReference, 'Other'),
      isTrue,
    );
  }
}
