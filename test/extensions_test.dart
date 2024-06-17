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

  void test_referenceToExtension() async {
    var library = await bootPackageWithLibrary('''
extension Ex on int {}

/// Text [Ex].
var f() {}
''');

    expect(
      library.functions.named('f').documentationAsHtml,
      contains('<a href="$linkPrefix/Ex.html">Ex</a>'),
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

    expect(
      library.functions.named('f').documentationAsHtml,
      contains('<a href="$linkPrefix/Ex/m.html">Ex.m</a>'),
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
    var reference = getMatchingLinkElement(referenceText, fFunction)
        .commentReferable as ModelElement;
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
