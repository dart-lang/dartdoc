// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
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
  late List<String> oneLines;
  late List<String> oneSidebarLines;
  late List<String> twoLines;
  late List<String> threeLines;

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
class Base1<E> {
  // An inherited method.
  void m2() {}

  // An inherited field.
  int get field1 => 1;
}

class Base2 {}

class Foo<E> extends Base1<E>, Base2 {}

class FooSub extends Foo<int> {}

extension type One<E>(Foo<E> it) {
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

extension type TwoWithBase<E>(Foo<E> it) implements Base1<E>, Base2 {}

extension type ThreeWithOne<E>(FooSub it3) implements One<int> {}
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
      oneLines = resourceProvider
          .readLines([packagePath, 'doc', 'lib', 'One-extension-type.html']);
      oneSidebarLines = resourceProvider.readLines(
          [packagePath, 'doc', 'lib', 'One-extension-type-sidebar.html']);
      twoLines = resourceProvider.readLines(
          [packagePath, 'doc', 'lib', 'TwoWithBase-extension-type.html']);
      threeLines = resourceProvider.readLines(
          [packagePath, 'doc', 'lib', 'ThreeWithOne-extension-type.html']);
    });

    test('page contains extension name with generics', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches(
          '<span class="kind-class">One&lt;<wbr>'
          '<span class="type-parameter">E</span>&gt;</span>',
        )
      ]);
    });

    test('page contains representation type', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<dt>on</dt>'),
        matches('<a href="../lib/Foo-class.html">Foo</a>'
            '<span class="signature">&lt;<wbr>'
            '<span class="type-parameter">E</span>&gt;</span>'),
      ]);
    });

    test('page contains class interfaces', () async {
      twoLines.expectMainContentContainsAllInOrder([
        matches('<dt>Implemented types</dt>'),
        matches('<a href="../lib/Base1-class.html">Base1</a>'
            '<span class="signature">&lt;<wbr>'
            '<span class="type-parameter">E</span>&gt;</span>'),
        matches('<a href="../lib/Base2-class.html">Base2</a>'),
      ]);
    });

    test('page contains extension type interfaces', () async {
      threeLines.expectMainContentContainsAllInOrder([
        matches('<dt>Implemented types</dt>'),
        matches('<a href="../lib/One-extension-type.html">One</a>'
            '<span class="signature">&lt;<wbr>'
            '<span class="type-parameter">int</span>&gt;</span>'),
      ]);
    });

    test('page contains constructors', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Constructors</h2>'),
        matches('<a href="../lib/One/One.html">One</a>'),
        matches('<a href="../lib/One/One.named.html">'
            'One.named</a>'),
        matches('A named constructor.'),
      ]);
    });

    test('page contains static methods', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Static Methods</h2>'),
        matches('<a href="../lib/One/s1.html">s1</a>'),
        matches('A static method.'),
      ]);
    });

    test('page contains static fields', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Static Properties</h2>'),
        matches('<a href="../lib/One/sf1.html">sf1</a>'),
        matches('A static field.'),
      ]);
    });

    test('page contains static getter/setter pairs', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Static Properties</h2>'),
        matches('<a href="../lib/One/gs1.html">gs1</a>'),
        matches('A static getter.'),
      ]);
    });

    test(
      'page contains (static) constants',
      // TODO(srawlins): Implement.
      skip: true,
      () async {
        oneLines.expectMainContentContainsAllInOrder([
          matches('<h2>Constants</h2>'),
          matches('<a href="../lib/One/c1-constant.html">c1</a>'),
          matches('A constant.'),
        ]);
      },
    );

    test('page contains representation field', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Properties</h2>'),
        matches('<a href="../lib/One/it.html">it</a>'),
        matches('An operator.'),
      ]);
    });

    test('page contains inherited representation field', () async {
      threeLines.expectMainContentContainsAllInOrder([
        matches('<h2>Properties</h2>'),
        matches('<a href="../lib/One/it.html">it</a>'),
      ]);
    });

    test('page contains inherited getters', () async {
      twoLines.expectMainContentContainsAllInOrder([
        matches('<h2>Properties</h2>'),
        matches('<a href="../lib/Base1/field1.html">field1</a>'),
      ]);
    });

    test('page contains instance methods', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Methods</h2>'),
        matches('<dt id="m1" class="callable">'),
        matches('<a href="../lib/One/m1.html">m1</a>'),
        matches('An instance method.'),
      ]);
    });

    test('page contains methods inherited from a class super-interface',
        () async {
      twoLines.expectMainContentContainsAllInOrder([
        matches('<h2>Methods</h2>'),
        matches('<dt id="m2" class="callable inherited">'),
        matches('<a href="../lib/Base1/m2.html">m2</a>'),
      ]);
    });

    test(
        'page contains methods inherited from an extension type '
        'super-interface', () async {
      threeLines.expectMainContentContainsAllInOrder([
        matches('<h2>Methods</h2>'),
        matches('<dt id="m1" class="callable inherited">'),
        matches('<a href="../lib/One/m1.html">m1</a>'),
      ]);
    });

    test('page contains operators', () async {
      oneLines.expectMainContentContainsAllInOrder([
        matches('<h2>Operators</h2>'),
        matches('<a href="../lib/One/operator_greater.html">operator ></a>'),
        matches('An operator.'),
      ]);
    });

    test('page contains inherited operators', () async {
      threeLines.expectMainContentContainsAllInOrder([
        matches('<h2>Operators</h2>'),
        matches('<a href="../lib/One/operator_greater.html">operator ></a>'),
        matches('An operator.'),
      ]);
    });

    test('sidebar contains methods', () async {
      expect(
        oneSidebarLines,
        containsAllInOrder([
          matches(
            '<a href="../lib/One-extension-type.html#instance-methods">'
            'Methods</a>',
          ),
          matches('<a href="../lib/One/m1.html">m1</a>'),
        ]),
      );
    });

    test('sidebar contains operators', () async {
      expect(
        oneSidebarLines,
        containsAllInOrder([
          matches(
            '<a href="../lib/One-extension-type.html#operators">'
            'Operators</a>',
          ),
          matches(
            '<a href="../lib/One/operator_greater.html">operator ></a>',
          ),
        ]),
      );
    });

    test('sidebar contains static properties', () async {
      expect(
        oneSidebarLines,
        containsAllInOrder([
          matches(
              '<a href="../lib/One-extension-type.html#static-properties">Static properties</a>'),
          matches('<a href="../lib/One/gs1.html">gs1</a>'),
          matches('<a href="../lib/One/sf1.html">sf1</a>'),
        ]),
      );
    });

    test('sidebar contains static methods', () async {
      expect(
        oneSidebarLines,
        containsAllInOrder([
          matches(
              '<a href="../lib/One-extension-type.html#static-methods">Static methods</a>'),
          matches('<a href="../lib/One/s1.html">s1</a>'),
        ]),
      );
    });
  });
}

extension on MemoryResourceProvider {
  List<String> readLines(List<String> pathParts) =>
      getFile(path.joinAll(pathParts)).readAsStringSync().split('\n');
}
