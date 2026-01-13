// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart' as utils;

void main() async {
  const packageName = 'test_package';

  late String packagePath;
  late MemoryResourceProvider resourceProvider;
  late PackageMetaProvider packageMetaProvider;
  late List<String> topicOneLines;
  late List<String> indexPageLines;

  Dartdoc buildDartdoc() {
    var context = utils.generatorContextFromArgv([
      '--input',
      packagePath,
      '--output',
      path.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--no-link-to-remote',
    ], packageMetaProvider);

    var packageBuilder = PubPackageBuilder(
      context,
      packageMetaProvider,
      skipUnreachableSdkLibraries: true,
    );
    return Dartdoc.fromContext(context, packageBuilder);
  }

  setUpAll(() async {
    packageMetaProvider = utils.testPackageMetaProvider;
    resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;
    packagePath = await d.createPackage(
      packageName,
      pubspec: '''
name: categories
version: 0.0.1
environment:
  sdk: '>=3.3.0-0 <4.0.0'
''',
      analysisOptions: '''
analyzer:
  enable-experiment:
    - inline-class
''',
      dartdocOptions: '''
dartdoc:
  categories:
    cat1:
      markdown: one.md
      displayName: One
    Documented:
      markdown: documented.md  
''',
      libFiles: [
        d.file('lib.dart', '''
/// A class.
/// {@category cat1}
class C1 {}

/// A constant.
/// {@category cat1}
const c1 = 1;

/// An enum.
/// {@category cat1}
enum E1 { one, two }

/// A function.
/// {@category cat1}
void F1() {}

/// A mixin.
/// {@category cat1}
mixin M1 {}

/// A property.
/// {@category cat1}
var p1 = 1;

/// A typedef.
/// {@category cat1}
typedef T1 = void Function();

/// A typedef.
/// {@category cat1}
// TODO(srawlins): Properly unit-test "typedef pointing to typedef".
typedef T2 = T1;

/// An extension.
/// {@category cat1}
extension Ex on int {}

/// An extension type.
/// {@category cat1}
extension type ExType(int it) {}
'''),
        d.file('other.dart', '''
/// {@category Documented}
library;

export 'lib.dart' show C1, E1;
'''),
      ],
      files: [
        d.file('one.md', ''),
        d.file('documented.md', 'First line.\n\nSecond line.'),
      ],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    var dartdoc = buildDartdoc();
    await dartdoc.generateDocs();
    topicOneLines = resourceProvider
        .getFile(path.join(packagePath, 'doc', 'topics', 'cat1-topic.html'))
        .readAsStringSync()
        .split('\n');
    indexPageLines = resourceProvider
        .getFile(path.join(packagePath, 'doc', 'index.html'))
        .readAsStringSync()
        .split('\n');
  });

  test('redirect category file created', () async {
    final redirectContent = resourceProvider
        .getFile(path.join(packagePath, 'doc', 'topics', 'One-topic.html'))
        .readAsStringSync();

    expect(redirectContent, contains('<meta http-equiv="refresh" content="0;'));
  });

  test('page links to classes annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Classes</h2>'),
      matches('<a href="../lib/C1-class.html">C1</a>'),
      matches('A class.'),
    ]);
  });

  test('page links to constants annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Constants</h2>'),
      matches('<a href="../lib/c1-constant.html">c1</a>'),
      matches('A constant.'),
    ]);
  });

  test('page links to enums annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Enums</h2>'),
      matches('<a href="../lib/E1.html">E1</a>'),
      matches('An enum.'),
    ]);
  });

  test('page links to extensions annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Extensions</h2>'),
      matches('<a href="../lib/Ex.html">Ex</a>'),
      matches('An extension.'),
    ]);
  });

  test('page links to functions annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Functions</h2>'),
      matches('<a href="../lib/F1.html">F1</a>'),
      matches('A function.'),
    ]);
  });

  test('page links to mixins annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Mixins</h2>'),
      matches('<a href="../lib/M1-mixin.html">M1</a>'),
      matches('A mixin.'),
    ]);
  });

  test('page links to properties annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<a href="../lib/p1.html">p1</a>'),
      matches('A property.'),
    ]);
  });

  test('page links to typedefs annotated with category', () async {
    topicOneLines.expectMainContentContainsAllInOrder([
      matches('<h2>Typedefs</h2>'),
      matches('<a href="../lib/T1.html">T1</a>'),
      matches('A typedef.'),
    ]);
  });

  test('sidebar contains classes', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#classes">Classes</a>'),
        matches('<a href="../lib/C1-class.html">C1</a>'),
      ]),
    );
  });

  test('classes are not duplicated', () async {
    expect(
      topicOneLines
          .where((l) => l.contains('<a href="../lib/C1-class.html">C1</a>')),
      // Once in the sidebar and once in the main body
      hasLength(2),
    );
  });

  test('sidebar contains enums', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#enums">Enums</a>'),
        matches('<a href="../lib/E1.html">E1</a>'),
      ]),
    );
  });

  test('enums are not duplicated', () async {
    expect(
      topicOneLines.where((l) => l.contains('<a href="../lib/E1.html">E1</a>')),
      // Once in the sidebar and once in the main body
      hasLength(2),
    );
  });

  test('sidebar contains mixins', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#mixins">Mixins</a>'),
        matches('<a href="../lib/M1-mixin.html">M1</a>'),
      ]),
    );
  });

  test('sidebar contains constants', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#constants">Constants</a>'),
        matches('<a href="../lib/c1-constant.html">c1</a>'),
      ]),
    );
  });

  test('sidebar contains properties', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches(
            '<a href="../topics/cat1-topic.html#properties">Properties</a>'),
        matches('<a href="../lib/p1.html">p1</a>'),
      ]),
    );
  });

  test('sidebar contains functions', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#functions">Functions</a>'),
        matches('<a href="../lib/F1.html">F1</a>'),
      ]),
    );
  });

  test('sidebar contains typedefs', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#typedefs">Typedefs</a>'),
        matches('<a href="../lib/T1.html">T1</a>'),
      ]),
    );
  });

  test('sidebar contains extensions', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches(
            '<a href="../topics/cat1-topic.html#extensions">Extensions</a>'),
        matches('<a href="../lib/Ex.html">Ex</a>'),
      ]),
    );
  });

  test('sidebar contains extension types', () async {
    expect(
      topicOneLines,
      containsAllInOrder([
        matches('<div id="dartdoc-sidebar-right" '),
        matches('<a href="../topics/cat1-topic.html#extension-types">'
            'Extension Types</a>'),
        matches('<a href="../lib/ExType-extension-type.html">ExType</a>'),
      ]),
    );
  });

  test('index page includes topics and their one liner description', () {
    indexPageLines.expectMainContentContainsAllInOrder([
      equalsIgnoringWhitespace('<h3>Documented</h3>'),
      equalsIgnoringWhitespace('<p>First line.</p>'),
    ]);
  });
}
