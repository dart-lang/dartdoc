// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ExtensionMethodsTest);
    defineReflectiveTests(ExtensionMethodsExportTest);
  });
}

@reflectiveTest
class ExtensionMethodsTest extends DartdocTestBase {
  @override
  String get libraryName => 'extension_methods';

  void test_applicability_extensionOnClass_couldApplyToSameClass() async {
    var library = await bootPackageWithLibrary('''
class C {}
extension Ex on C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isTrue);
  }

  void test_applicability_extensionOnClass_couldApplyToDifferentClass() async {
    var library = await bootPackageWithLibrary('''
class C {}
extension Ex on int {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isFalse);
  }

  void test_applicability_extensionOnClass_couldApplyToSubclass() async {
    var library = await bootPackageWithLibrary('''
class C {}
class D extends C {}
extension Ex on C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('D')), isTrue);
  }

  void test_applicability_extensionOnClass_couldApplyToInstantiation() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}
extension Ex on C<int> {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isTrue);
  }

  void
      test_applicability_extensionOnClass_couldApplyToSubclassInstantiation() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}
class D<T> extends C<T> {}
extension Ex on C<int> {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('D')), isTrue);
  }

  void
      test_applicability_extensionOnClass_couldApplyToSubclassInstantiation2() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}
class D extends C<String> {}
extension Ex on C<int> {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('D')), isFalse);
  }

  void test_applicability_extensionOnObject_couldApplyToClass() async {
    var library = await bootPackageWithLibrary('''
extension Ex on Object {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isTrue);
  }

  void test_applicability_extensionOnObject_couldApplyToMixin() async {
    var library = await bootPackageWithLibrary('''
extension Ex on Object {}
mixin M {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.mixins.named('M')), isTrue);
  }

  void test_applicability_extensionOnDynamic_couldApplyToClass() async {
    var library = await bootPackageWithLibrary('''
extension Ex on dynamic {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isTrue);
  }

  void test_applicability_extensionOnDynamic_alwaysApplies() async {
    var library = await bootPackageWithLibrary('''
extension Ex on dynamic {}
''');
    expect(library.extensions.named('Ex').alwaysApplies, isTrue);
  }

  void test_applicability_extensionOnVoid_couldApplyToClass() async {
    var library = await bootPackageWithLibrary('''
extension Ex on void {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isTrue);
  }

  void test_applicability_extensionOnNull_couldApplyToClass() async {
    var library = await bootPackageWithLibrary('''
extension Ex on Null {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isFalse);
  }

  void test_applicability_extensionOnTypeVariable_couldApplyToClass() async {
    var library = await bootPackageWithLibrary('''
extension Ex<T> on T {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isTrue);
  }

  void test_applicability_extensionOnTypeVariable_alwaysApplies() async {
    var library = await bootPackageWithLibrary('''
extension Ex<T> on T {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.alwaysApplies, isTrue);
  }

  void
      test_applicability_extensionOnTypeVariableWithBound_couldApplyToSubtypeOfBound() async {
    var library = await bootPackageWithLibrary('''
class C {}
class D extends C {}
extension Ex<T extends C> on T {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('D')), isTrue);
  }

  void
      test_applicability_extensionOnTypeVariableWithBound_couldApplyToUnrelated() async {
    var library = await bootPackageWithLibrary('''
extension Ex<T extends num> on T {}
class C {}
''');
    var ex = library.extensions.named('Ex');
    expect(ex.couldApplyTo(library.classes.named('C')), isFalse);
  }

  void test_referenceToExtension() async {
    var library = await bootPackageWithLibrary('''
extension Ex on int {}

/// Text [Ex].
var f() {}
''');

    var f = library.functions.named('f');
    expect(f.fullyQualifiedName, 'extension_methods.f');
    expect(
      f.documentationAsHtml,
      contains('<a href="$linkPrefix/Ex.html">Ex</a>'),
    );
  }

  void test_referenceToMissingElement_onExtensionMember() async {
    var library = await bootPackageWithLibrary('''
extension E on int {
  /// Text [NotFound] text.
  int get f => 7;
}
''');

    var f = library.extensions.first.instanceFields.first;
    expect(f.fullyQualifiedName, 'extension_methods.E.f');
    // We are primarily testing that dartdoc does not crash when trying to
    // resolve an unknown reference, from the position of an extension member.
    expect(
      f.documentationAsHtml,
      contains('<p>Text <code>NotFound</code> text.</p>'),
    );
  }

  void test_referenceToExtensionMethod() async {
    var library = await bootPackageWithLibrary('''
extension Ex on int {
  void m() {}
}

/// Text [Ex.m].
var f() {}
''');

    var f = library.functions.named('f');
    expect(f.fullyQualifiedName, 'extension_methods.f');
    expect(
      f.documentationAsHtml,
      contains('<a href="$linkPrefix/Ex/m.html">Ex.m</a>'),
    );
  }

  void test_referenceToExtensionGetter() async {
    var library = await bootPackageWithLibrary('''
extension Ex on int {
  bool get b => true;
}

/// Text [Ex.b].
var f() {}
''');

    var f = library.functions.named('f');
    expect(f.fullyQualifiedName, 'extension_methods.f');
    expect(
      f.documentationAsHtml,
      contains('<a href="$linkPrefix/Ex/b.html">Ex.b</a>'),
    );
  }

  void test_referenceToExtensionSetter() async {
    var library = await bootPackageWithLibrary('''
extension Ex on int {
  set b(int value) {}
}

/// Text [Ex.b].
var f() {}
''');

    var f = library.functions.named('f');
    expect(f.fullyQualifiedName, 'extension_methods.f');
    expect(
      f.documentationAsHtml,
      contains('<a href="$linkPrefix/Ex/b.html">Ex.b</a>'),
    );
  }

  // TODO(srawlins): Test everything else about extensions.
}

@reflectiveTest
class ExtensionMethodsExportTest extends DartdocTestBase {
  @override
  String get libraryName => 'extension_methods';

  late Package package;

  /// Verifies that comment reference text, [referenceText] attached to the
  /// function, `f`, is resolved to [expected], and links to [href].
  void expectReferenceValidFromF(
      String referenceText, ModelElement expected, String href) {
    var fFunction = package.functions.named('f');
    var reference = getMatchingLinkElement(referenceText, fFunction).nameable
        as ModelElement;
    expect(identical(reference.canonicalModelElement, expected), isTrue,
        reason: '$expected (${expected.hashCode}) is not '
            '${reference.canonicalModelElement} '
            '(${reference.canonicalModelElement.hashCode})');
    expect(expected.isCanonical, isTrue);
    expect(expected.href, endsWith(href));
  }

  /// Sets up a package with three files:
  ///
  /// * a private file containing a class, `C`, an extension on that class, `E`,
  ///   `E`, and a method in that extension, `m`.
  /// * A public file that exports some members of the private file. The content
  ///   of this file is specified with [exportingLibraryContent].
  /// * Another public file which is completely unrelated to the first two (no
  ///   imports or exports linking them), which contains a function, `f`.
  Future<void> setupWith(String exportingLibraryContent) async {
    var packageGraph = await bootPackageFromFiles([
      d.dir('lib', [
        d.dir('src', [
          d.file('lib.dart', '''
class C {}
extension Ex on C {
  void m() {}
}
'''),
        ]),
        d.file('one.dart', exportingLibraryContent),
        d.file('two.dart', '''
/// Comment.
var f() {}
'''),
      ])
    ]);
    package = packageGraph.defaultPackage;
  }

  void test_reexportWithShow() async {
    await setupWith("export 'src/lib.dart' show C, Ex;");

    var ex = package.extensions.named('Ex');
    var m = ex.instanceMethods.named('m');
    expectReferenceValidFromF('Ex', ex, '%one/Ex.html');
    expectReferenceValidFromF('Ex.m', m, '%one/Ex/m.html');
  }

  void test_reexportWithHide() async {
    await setupWith("export 'src/lib.dart' hide A;");

    var ex = package.extensions.named('Ex');
    var m = ex.instanceMethods.named('m');
    expectReferenceValidFromF('Ex', ex, '%one/Ex.html');
    expectReferenceValidFromF('Ex.m', m, '%one/Ex/m.html');
  }

  void test_reexportFull() async {
    await setupWith("export 'src/lib.dart';");

    var ex = package.extensions.named('Ex');
    var m = ex.instanceMethods.named('m');
    expectReferenceValidFromF('Ex', ex, '%one/Ex.html');
    expectReferenceValidFromF('Ex.m', m, '%one/Ex/m.html');
  }
}
