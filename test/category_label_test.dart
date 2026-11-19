// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CategoryLabelTest);
  });
}

/// Tests that a category's `displayName`, which is free text from
/// `dartdoc_options.yaml`, is escaped wherever it is written into HTML.
@reflectiveTest
class CategoryLabelTest extends DartdocTestBase {
  @override
  String get libraryName => 'categories';

  /// A display name which contains every character with a meaning in HTML
  /// text or in a double-quoted attribute.
  static const displayName = 'Odd & "weird" <names>';

  Future<Class> bootPackageWithCategory({bool documented = true}) async {
    var library = await bootPackageWithLibrary('''
/// {@category odd}
class C {}
''', extraFiles: [
      d.file('dartdoc_options.yaml', '''
dartdoc:
  categories:
    odd:
      displayName: '$displayName'
${documented ? "      markdown: doc/odd.md" : ''}
'''),
      if (documented) d.file('doc/odd.md', '# Odd\n'),
    ]);
    return library.classes.named('C');
  }

  void test_displayName_isEscapedInLabel() async {
    var c = await bootPackageWithCategory();
    var category = c.categories.single;

    expect(category.name, displayName);
    expect(
      category.categoryLabel,
      '<span class="category odd-&amp;-&quot;weird&quot;-&lt;names&gt; cp-0 '
      'linked" title="This is part of the '
      'Odd &amp; &quot;weird&quot; &lt;names&gt; topic.">'
      '<a href="${placeholder}topics/odd-topic.html">'
      'Odd&nbsp;&amp;&nbsp;&quot;weird&quot;&nbsp;&lt;names&gt;</a></span>',
    );
  }

  void test_displayName_isEscapedInUnlinkedLabel() async {
    var c = await bootPackageWithCategory(documented: false);
    var category = c.categories.single;

    expect(category.isDocumented, isFalse);
    expect(category.linkedName,
        'Odd&nbsp;&amp;&nbsp;&quot;weird&quot;&nbsp;&lt;names&gt;');
    expect(category.categoryLabel, isNot(contains('<names>')));
  }
}
