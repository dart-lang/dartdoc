// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'template_test_base.dart';

void main() async {
  defineReflectiveSuite(() {
    defineReflectiveTests(DeprecatedLibraryTest);
  });
}

@reflectiveTest
class DeprecatedLibraryTest extends TemplateTestBase {
  @override
  String get packageName => 'deprecated_library_test';

  @override
  String get libraryName => 'deprecated_lib';

  void test_deprecatedLibrary_memberPagesHaveBannerAndMetadata() async {
    await createPackageWithLibrary('''
@Deprecated(
  'Use package:web instead. See https://dart.dev/go/package-web.',
)
library;

class C {
  C();
  int p = 0;
  void m() {}
}

enum E { a }
mixin M {}
extension Ext on C {}
extension type ET(int value) {}
void f() {}
typedef T = void Function();
final int v = 1;
''');

    var libraryHtml = readLines(['lib', 'index.html']).join('\n');
    expect(
      libraryHtml,
      contains('<title>lib library (deprecated) - Dart API</title>'),
    );
    expect(
      libraryHtml,
      contains(
        '<meta name="description" content="Deprecated. Use package:web '
        'instead. See https:&#47;&#47;dart.dev&#47;go&#47;package-web. '
        'lib library API docs',
      ),
    );
    expect(libraryHtml, isNot(contains('markdown-alert-warning')));

    for (var pathParts in [
      ['lib', 'C-class.html'],
      ['lib', 'C', 'C.html'],
      ['lib', 'C', 'm.html'],
      ['lib', 'C', 'p.html'],
      ['lib', 'E.html'],
      ['lib', 'M-mixin.html'],
      ['lib', 'Ext.html'],
      ['lib', 'ET-extension-type.html'],
      ['lib', 'f.html'],
      ['lib', 'T.html'],
      ['lib', 'v.html'],
    ]) {
      var html = readLines(pathParts).join('\n');
      expect(html, contains('(deprecated) - '), reason: pathParts.join('/'));
      expect(
        html,
        contains(
          '<meta name="description" content="Deprecated. Use package:web '
          'instead. See https:&#47;&#47;dart.dev&#47;go&#47;package-web. ',
        ),
        reason: pathParts.join('/'),
      );
      expect(
        html,
        contains('<div class="markdown-alert markdown-alert-warning">'),
        reason: pathParts.join('/'),
      );
      expect(
        html,
        contains('<p class="markdown-alert-title">Deprecated</p>'),
        reason: pathParts.join('/'),
      );
      expect(
        html,
        contains(
          'Use package:web instead. See '
          '<a href="https://dart.dev/go/package-web">'
          'https://dart.dev/go/package-web</a>.',
        ),
        reason: pathParts.join('/'),
      );
    }
  }

  void test_deprecatedLibrary_bareDeprecatedOmitsNextRelease() async {
    await createPackageWithLibrary('''
@deprecated
library;

class C {}
''');

    var classHtml = readLines(['lib', 'C-class.html']).join('\n');
    expect(
      classHtml,
      contains('<div class="markdown-alert markdown-alert-warning">'),
    );
    expect(
      classHtml,
      contains(
          'The <a class="deprecated" href="../lib/">lib</a> library is deprecated.</p>'),
    );
    expect(classHtml, isNot(contains('next release')));
    expect(
      classHtml,
      contains(
        '<meta name="description" content="Deprecated. API docs for the C '
        'class from the lib library',
      ),
    );
  }

  void test_deprecatedLibrary_escapesHtmlAndLinkifiesQueryUrl() async {
    await createPackageWithLibrary('''
@Deprecated('Use <Foo> & "bar". See https://example.com/?a=1&b=2.')
library;

class C {}
''');

    var classHtml = readLines(['lib', 'C-class.html']).join('\n');
    expect(
      classHtml,
      contains(
        'Use &lt;Foo&gt; &amp; &quot;bar&quot;. See '
        '<a href="https://example.com/?a=1&amp;b=2">'
        'https://example.com/?a=1&amp;b=2</a>.',
      ),
    );
  }

  void test_nonDeprecatedLibrary_noBannerOrDeprecatedMetadata() async {
    await createPackageWithLibrary('''
library;

class C {}
''');

    var classHtml = readLines(['lib', 'C-class.html']).join('\n');
    expect(classHtml, isNot(contains('markdown-alert-warning')));
    expect(classHtml, isNot(contains('(deprecated)')));
    expect(classHtml, isNot(contains('content="Deprecated.')));
  }

  void
      test_deprecatedClassInActiveLibrary_metadataWithoutLibraryBanner() async {
    await createPackageWithLibrary('''
library;

@Deprecated('Use D instead.')
class C {}
''');

    var classHtml = readLines(['lib', 'C-class.html']).join('\n');
    expect(classHtml, isNot(contains('markdown-alert-warning')));
    expect(
      classHtml,
      contains('<title>C class (deprecated) - lib library - Dart API</title>'),
    );
    expect(
      classHtml,
      contains(
        '<meta name="description" content="Deprecated. Use D instead. '
        'API docs for the C class',
      ),
    );
  }

  void test_deprecatedMetaDescription_appendsPeriodWhenMissing() async {
    await createPackageWithLibrary('''
library;

@Deprecated('Use D instead')
class C {}
''');

    var classHtml = readLines(['lib', 'C-class.html']).join('\n');
    expect(
      classHtml,
      contains(
        '<meta name="description" content="Deprecated. Use D instead. '
        'API docs for the C class',
      ),
    );
  }
}
