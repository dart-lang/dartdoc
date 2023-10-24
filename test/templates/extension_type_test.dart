// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

void main() async {
  const packageName = 'test_package';

  late String packagePath;
  late MemoryResourceProvider resourceProvider;
  late PackageMetaProvider packageMetaProvider;
  late DartdocGeneratorOptionContext context;
  late List<String> eLines;
  late List<String> eRightSidebarLines;

  Future<PubPackageBuilder> createPackageBuilder() async {
    context = await generatorContextFromArgv([
      '--input',
      packagePath,
      '--output',
      path.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--no-link-to-remote',
    ], packageMetaProvider);

    var packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));
    return PubPackageBuilder(
      context,
      packageMetaProvider,
      packageConfigProvider,
      skipUnreachableSdkLibraries: true,
    );
  }

  Future<Dartdoc> buildDartdoc() async {
    final packageBuilder = await createPackageBuilder();
    return await Dartdoc.fromContext(context, packageBuilder);
  }

  group('extension types', () {
    setUpAll(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      packagePath = await d.createPackage(
        packageName,
        pubspec: '''
name: extension_types
version: 0.0.1
environment:
  sdk: '>=3.3.0-0 <4.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - inline-class
''',
        libFiles: [
          d.file('lib.dart', '''
extension type FooET<E>(Foo<E> e) {
  /// A named constructor.
  MyIterable.named(Foo<E> e);

  /// An instance method.
  void m1() {}

  /// An operator.
  bool operator >(E other) => false;

  /// A static method.
  static void s1() {}

  /// A constant.
  static const c1 = 1;

  /// A static field.
  static final int sf1 = 2;

  /// A static getter.
  static int get gs1 => 3;

  /// A static setter.
  static void set gs1(int value) {}
}

class Foo<E> {}
'''),
        ],
        dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://github.com/dart-lang/TEST_PKG/%f%#L%l%'
''',
        resourceProvider: resourceProvider,
      );
      await writeDartdocResources(resourceProvider);
      await (await buildDartdoc()).generateDocs();
      eLines = resourceProvider
          .getFile(
              path.join(packagePath, 'doc', 'lib', 'FooET-extension-type.html'))
          .readAsStringSync()
          .split('\n');
      eRightSidebarLines = resourceProvider
          .getFile(path.join(
              packagePath, 'doc', 'lib', 'FooET-extension-type-sidebar.html'))
          .readAsStringSync()
          .split('\n');
    });

    test('page contains extension name with generics', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches(
          '<span class="kind-class">FooET&lt;<wbr>'
          '<span class="type-parameter">E</span>&gt;</span>',
        )
      ]);
    });

    test('page contains extended type', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<dt>on</dt>'),
        matches('<a href="../lib/Foo-class.html">Foo</a>'
            '<span class="signature">&lt;<wbr>'
            '<span class="type-parameter">E</span>&gt;</span>'),
      ]);
    });

    test('page contains constructors', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<h2>Constructors</h2>'),
        matches('<a href="../lib/FooET/FooET.html">FooET</a>'),
        matches('<a href="../lib/FooET/FooET.named.html">'
            'FooET.named</a>'),
        matches('A named constructor.'),
      ]);
    });

    test('page contains static methods', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<h2>Static Methods</h2>'),
        matches('<a href="../lib/FooET/s1.html">s1</a>'),
        matches('A static method.'),
      ]);
    });

    test('page contains static fields', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<h2>Static Properties</h2>'),
        matches('<a href="../lib/FooET/sf1.html">sf1</a>'),
        matches('A static field.'),
      ]);
    });

    test('page contains static getter/setter pairs', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<h2>Static Properties</h2>'),
        matches('<a href="../lib/FooET/gs1.html">gs1</a>'),
        matches('A static getter.'),
      ]);
    });

    test(
      'page contains (static) constants',
      // TODO(srawlins): Implement.
      skip: true,
      () async {
        eLines.expectMainContentContainsAllInOrder([
          matches('<h2>Constants</h2>'),
          matches('<a href="../lib/FooET/c1-constant.html">c1</a>'),
          matches('A constant.'),
        ]);
      },
    );

    test('page contains instance operators', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<h2>Operators</h2>'),
        matches('<a href="../lib/FooET/operator_greater.html">operator ></a>'),
        matches('An operator.'),
      ]);
    });

    test('sidebar contains methods', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches(
            '<a href="../lib/FooET-extension-type.html#instance-methods">'
            'Methods</a>',
          ),
          matches('<a href="../lib/FooET/m1.html">m1</a>'),
        ]),
      );
    });

    test('sidebar contains operators', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches(
            '<a href="../lib/FooET-extension-type.html#operators">'
            'Operators</a>',
          ),
          matches(
            '<a href="../lib/FooET/operator_greater.html">operator ></a>',
          ),
        ]),
      );
    });

    test('sidebar contains static properties', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches(
              '<a href="../lib/FooET-extension-type.html#static-properties">Static properties</a>'),
          matches('<a href="../lib/FooET/gs1.html">gs1</a>'),
          matches('<a href="../lib/FooET/sf1.html">sf1</a>'),
        ]),
      );
    });

    test('sidebar contains static methods', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches(
              '<a href="../lib/FooET-extension-type.html#static-methods">Static methods</a>'),
          matches('<a href="../lib/FooET/s1.html">s1</a>'),
        ]),
      );
    });
  });
}
