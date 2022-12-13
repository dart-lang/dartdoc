// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart' as utils;

void main() async {
  const packageName = 'test_package';

  late String packagePath;
  late MemoryResourceProvider resourceProvider;
  late PackageMetaProvider packageMetaProvider;
  late DartdocGeneratorOptionContext context;
  late List<String> topicOneLines;

  setUp(() {});

  Future<PubPackageBuilder> createPackageBuilder({
    List<String> additionalOptions = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    context = await utils.generatorContextFromArgv([
      '--input',
      packagePath,
      '--output',
      p.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--no-link-to-remote',
      ...additionalOptions,
    ], packageMetaProvider);

    var packageConfigProvider = utils
        .getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));
    return PubPackageBuilder(
      context,
      packageMetaProvider,
      packageConfigProvider,
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
  }

  Future<Dartdoc> buildDartdoc({
    List<String> additionalOptions = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    final packageBuilder = await createPackageBuilder(
      additionalOptions: additionalOptions,
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
    return await Dartdoc.fromContext(
      context,
      packageBuilder,
    );
  }

  setUpAll(() async {
    packageMetaProvider = utils.testPackageMetaProvider;
    resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  categories:
    One:
      markdown: one.md
''',
      libFiles: [
        d.file('lib.dart', '''
/// A class.
/// {@category One}
class C1 {}

/// A constant.
/// {@category One}
const c1 = 1;

/// An enum.
/// {@category One}
enum E1 { one, two }

/// An extension.
/// {@category One}
extension Ex on int {}

/// A function.
/// {@category One}
void F1() {}

/// A mixin.
/// {@category One}
mixin M1 {}

/// A property.
/// {@category One}
var p1 = 1;

/// A typedef.
/// {@category One}
typedef T1 = void Function();

/// A typedef.
/// {@category One}
// TODO(srawlins): Properly unit-test "typedef pointing to typedef".
typedef T2 = T1;
'''),
      ],
      files: [
        d.file('one.md', ''),
      ],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    await (await buildDartdoc()).generateDocs();
    topicOneLines = resourceProvider
        .getFile(p.join(packagePath, 'doc', 'topics', 'One-topic.html'))
        .readAsStringSync()
        .split('\n');
  });

  test('category page links to classes annotated with category', () async {
    // TODO(srawlins): Use expectMainContentContainsAllInOrder throughout.
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Classes</h2>'),
          matches('<a href="../lib/C1-class.html">C1</a>'),
          matches('A class.'),
        ]));
  });

  test('category page links to constants annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Constants</h2>'),
          matches('<a href="../lib/c1-constant.html">c1</a>'),
          matches('A constant.'),
        ]));
  });

  test('category page links to enums annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Enums</h2>'),
          matches('<a href="../lib/E1.html">E1</a>'),
          matches('An enum.'),
        ]));
  });

  test('category page links to extensions annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Extensions</h2>'),
          matches('<a href="../lib/Ex.html">Ex</a>'),
          matches('An extension.'),
        ]));
  });

  test('category page links to functions annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Functions</h2>'),
          matches('<a href="../lib/F1.html">F1</a>'),
          matches('A function.'),
        ]));
  });

  test('category page links to mixins annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Mixins</h2>'),
          matches('<a href="../lib/M1-mixin.html">M1</a>'),
          matches('A mixin.'),
        ]));
  });

  test('category page links to properties annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Properties</h2>'),
          matches('<a href="../lib/p1.html">p1</a>'),
          matches('A property.'),
        ]));
  });

  test('category page links to typedefs annotated with category', () async {
    expect(
        topicOneLines,
        containsAllInOrder([
          matches('<h2>Typedefs</h2>'),
          matches('<a href="../lib/T1.html">T1</a>'),
          matches('A typedef.'),
        ]));
  });
}
