// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/search.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SearchTest);
  });
}

@reflectiveTest
class SearchTest {
  List<Map<String, Object?>> get searchIndex => _toJson([
        {'qualifiedName': 'foo', 'type': 'library', 'packageName': 'foo'},
        {'qualifiedName': 'foo.Foo', 'type': 'class', 'packageName': 'foo'},
        {'qualifiedName': 'foo.Bar', 'type': 'class', 'packageName': 'foo'},
        {'qualifiedName': 'foo.Bart', 'type': 'class', 'packageName': 'foo'},
        {
          'qualifiedName': 'foo.HelloFoo',
          'type': 'class',
          'packageName': 'foo',
        },
        {
          'qualifiedName': 'bar.Bar.foo',
          'type': 'method',
          'packageName': 'foo',
        },
        {
          'qualifiedName': 'foo.Foo.method',
          'type': 'method',
          'packageName': 'foo',
        },
        {
          'qualifiedName': 'foo.Bar.method',
          'type': 'method',
          'overriddenDepth': 1,
          'packageName': 'foo',
        },
        {
          'qualifiedName': 'foo.Baz.method',
          'type': 'method',
          'overriddenDepth': 2,
          'packageName': 'foo',
        },
        {'qualifiedName': 'FOO', 'type': 'library', 'packageName': 'foo2'},
        {'qualifiedName': 'foo.FOO', 'type': 'class', 'packageName': 'foo2'},
      ]);

  List<String> matchNames(
    String query, {
    List<String> packageOrder = const [],
  }) {
    final indexList = searchIndex.map(IndexItem.fromMap).toList();
    final index = Index(packageOrder, indexList);
    return index.find(query).map((e) => e.qualifiedName).toList();
  }

  void test_doesNotMatchOnlyOneCharacter() {
    expect(
      matchNames('f'),
      isEmpty,
    );
  }

  void test_excludesNotMatches() {
    expect(
      matchNames('bar'),
      allOf(
        isNot(contains(['foo'])),
        isNot(contains(['foo.Foo'])),
      ),
    );
  }

  void test_matchesAgainstLowercaseMatch() {
    expect(
      matchNames('foo.foo'),
      contains('foo.Foo'),
    );
  }

  void test_matchesAgainstLowercaseQuery() {
    expect(
      matchNames('FOO'),
      contains('foo'),
    );
  }

  void test_matchesPrefixBeforeContains() {
    expect(
      matchNames('Fo'),
      containsAllInOrder(['foo.Foo', 'foo.HelloFoo']),
    );
  }

  void test_matchesQualifiedName() {
    expect(
      matchNames('foo.bar'),
      contains('foo.Bar'),
    );
  }

  void test_prefersExactMatch() {
    expect(
      matchNames('Bar'),
      containsAllInOrder(['foo.Bar', 'foo.Bart']),
    );
  }

  void test_prefersHigherPackages() {
    expect(
      matchNames('foo', packageOrder: ['foo2', 'foo']),
      containsAllInOrder(['FOO', 'foo.FOO', 'foo', 'foo.Foo']),
    );
  }

  void test_prefersNonOverrides() {
    expect(
      matchNames('method'),
      containsAllInOrder(
        ['foo.Foo.method', 'foo.Bar.method', 'foo.Baz.method'],
      ),
    );
  }

  void test_prefersOuterScopes() {
    expect(
      matchNames('foo'),
      containsAllInOrder(['foo', 'foo.Foo', 'bar.Bar.foo']),
    );
  }

  List<Map<String, Object?>> _toJson(List<Map<String, Object?>> list) {
    for (var item in list) {
      item['name'] ??= (item['qualifiedName']! as String).split('.').last;
      item['href'] ??= 'UNUSED';
      item['packageName'] ??= 'UNUSED';
      item['desc'] ??= 'UNUSED.';
      item['overriddenDepth'] ??= 0;
    }
    return list;
  }
}
