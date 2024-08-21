// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/generator/generator_utils.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (recordsAllowed) {
      defineReflectiveTests(SearchIndexTest);
    }
  });
}

@reflectiveTest
class SearchIndexTest extends DartdocTestBase {
  @override
  String get libraryName => 'index_json';

  /// We need the "unreachable" SDK libraries in order to include the non-"core"
  /// ones like 'dart:io'.
  @override
  bool get skipUnreachableSdkLibraries => false;

  /// Returns the JSON-decoded text of the search index which is generated with
  /// the elements from [libraryContent].
  ///
  /// Specify `actAsFlutter: true` to auto-include dependencies, and to specify
  /// a package order with "flutter" and "Dart".
  Future<List<Map<String, dynamic>>> jsonIndexForPackageWithLibrary(
    String libraryContent, {
    bool actAsFlutter = false,
  }) async {
    var library = await bootPackageWithLibrary(
      libraryContent,
      additionalArguments:
          actAsFlutter ? const ['--auto-include-dependencies'] : const [],
    );
    var libraries = [
      library,
      if (actAsFlutter)
        ...library.packageGraph.libraries
            .where((l) => l.name.startsWith('dart:')),
    ];
    // TODO(srawlins): `Library.allModelElements` is not a great fit for this
    // test, because we can only calculate the `href` properties of canonical,
    // documented elements. But this filter gets us approximately what we want.
    var elements = libraries.expand((library) => library.allModelElements
        .whereDocumentedIn(library)
        .where((e) => e is ContainerMember
            ? e.enclosingElement.canonicalLibrary != null
            : e.canonicalLibrary != null));
    var text = generateSearchIndexJson(
      elements,
      packageOrder: actAsFlutter ? const ['flutter', 'Dart'] : const [],
      pretty: false,
    );
    return (jsonDecode(text) as List).cast<Map<String, dynamic>>();
  }

  void test_class() async {
    var jsonIndex = await jsonIndexForPackageWithLibrary('''
/// A class.
class C {}
''');
    var classItem = jsonIndex.named('index_json.C');

    expect(classItem['kind'], equals(Kind.class_.index));
    expect(classItem['overriddenDepth'], equals(0));
    expect(classItem['desc'], equals('A class.'));
    expect(
      classItem['enclosedBy'],
      equals({
        'name': 'index_json',
        'kind': Kind.library.index,
        'href':
            '%%__HTMLBASE_dartdoc_internal__%%index_json/index_json-library.html',
      }),
    );
  }

  void test_library() async {
    var jsonIndex = await jsonIndexForPackageWithLibrary('''
/// A library.
library;
''');
    var libraryItem = jsonIndex.named('index_json');

    expect(libraryItem['kind'], equals(Kind.library.index));
    expect(libraryItem['overriddenDepth'], equals(0));
    // TODO(srawlins): Should not be blank.
    expect(libraryItem['desc'], equals(''));
  }

  void test_method() async {
    var jsonIndex = await jsonIndexForPackageWithLibrary('''
class C {
  /// A method.
  void m() {}
}
''');
    var methodItem = jsonIndex.named('index_json.C.m');

    expect(methodItem['kind'], equals(Kind.method.index));
    expect(methodItem['overriddenDepth'], equals(0));
    expect(methodItem['desc'], equals('A method.'));
    expect(
      methodItem['enclosedBy'],
      equals({
        'name': 'C',
        'kind': Kind.class_.index,
        'href': '%%__HTMLBASE_dartdoc_internal__%%index_json/C-class.html',
      }),
    );
  }

  void test_overriddenMethod() async {
    var jsonIndex = await jsonIndexForPackageWithLibrary('''
class C {
  void m() {}
}
class D extends C {
  /// A method.
  @override
  void m() {}
}
''');
    var methodItem = jsonIndex.named('index_json.D.m');

    expect(methodItem['kind'], equals(Kind.method.index));
    expect(methodItem['overriddenDepth'], equals(1));
    expect(methodItem['desc'], equals('A method.'));
    expect(
      methodItem['enclosedBy'],
      equals({
        'name': 'D',
        'kind': Kind.class_.index,
        'href': '%%__HTMLBASE_dartdoc_internal__%%index_json/D-class.html',
      }),
    );
  }

  void test_sdkPackageRank_core() async {
    var jsonIndex = await jsonIndexForPackageWithLibrary(
      actAsFlutter: true,
      '''
/// A library.
library;
''',
    );
    var classItem = jsonIndex.named('dart:core.List');

    expect(classItem['kind'], equals(Kind.class_.index));
    expect(classItem['packageRank'], equals(10));
  }

  void test_sdkPackageRank_nonCore() async {
    var jsonIndex = await jsonIndexForPackageWithLibrary(
      actAsFlutter: true,
      '''
/// A library.
library;
''',
    );
    var classItem = jsonIndex.named('dart:io.File');

    expect(classItem['kind'], equals(Kind.class_.index));
    expect(classItem['packageRank'], equals(15));
  }
}

extension on List<Map<String, dynamic>> {
  Map<String, dynamic> named(String qualifiedName) =>
      firstWhere((e) => e['qualifiedName'] == qualifiedName);
}
