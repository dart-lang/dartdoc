// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

void main() async {
  const packageName = 'test_package';

  late List<String> eLines;
  late List<String> enumWithDefaultConstructorLines;

  group('enhanced enums', skip: !enhancedEnumsAllowed, () {
    setUpAll(() async {
      final packageMetaProvider = testPackageMetaProvider;
      final resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      final packagePath = await d.createPackage(
        packageName,
        pubspec: '''
name: enums
version: 0.0.1
environment:
  sdk: '>=2.17.0-0 <3.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - enhanced-enums
''',
        libFiles: [
          d.file('lib.dart', '''
class C<T> {
  const C(String m);
}

mixin M<T> {}

@C('message')
enum E<T> with M<T> implements C<T> {
  /// Doc comment for [one].
  one<int>.named(1),

  @deprecated
  two<double>.named(2.0),
  three<num>.named(3);

  const E.named(T i);

  /// A method.
  void m1() {}

  /// An operator.
  bool operator >(E other) => false;

  /// A field.
  final int f1 = 0;

  /// An instance getter.
  int get ig1 => 1;

  /// An instance setter.
  set is1(int value) {}

  /// A static method.
  static void s1() {}

  /// A constant.
  static const c1 = 1;

  /// A static field.
  static final int sf1 = 2;

  /// A static getter.
  static int get gs1 => 3;

  /// A static setter.
  static set gs1(int value) {}
}

enum EnumWithDefaultConstructor {
  /// Doc comment for [four].
  four,

  /// Doc comment for [five].
  five,

  /// Doc comment for [six].
  six;
}
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await writeDartdocResources(resourceProvider);
      final context = await generatorContextFromArgv([
        '--input',
        packagePath,
        '--output',
        p.join(packagePath, 'doc'),
        '--sdk-dir',
        packageMetaProvider.defaultSdkDir.path,
        '--no-link-to-remote',
      ], packageMetaProvider);

      var packageConfigProvider =
          getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
      packageConfigProvider.addPackageToConfigFor(
          packagePath, packageName, Uri.file('$packagePath/'));
      final packageBuilder = PubPackageBuilder(
        context,
        packageMetaProvider,
        packageConfigProvider,
        skipUnreachableSdkLibraries: true,
      );
      await (await Dartdoc.fromContext(context, packageBuilder)).generateDocs();
      eLines = resourceProvider
          .getFile(p.join(packagePath, 'doc', 'lib', 'E.html'))
          .readAsStringSync()
          .split('\n');
      enumWithDefaultConstructorLines = resourceProvider
          .getFile(p.join(
              packagePath, 'doc', 'lib', 'EnumWithDefaultConstructor.html'))
          .readAsStringSync()
          .split('\n');
    });

    test('enum page contains enum name with generics', () async {
      // TODO(srawlins): Use expectMainContentContainsAllInOrder throughout.
      expect(
          eLines,
          containsAllInOrder([
            matches('<span class="kind-enum">E&lt;<wbr>'
                '<span class="type-parameter">T</span>&gt;</span>'),
          ]));
    });

    test('enum page contains implemented types', () async {
      expect(
        eLines,
        containsAllInOrder([
          matches('<dt>Implemented types</dt>'),
          matches('<a href="../lib/C-class.html">C</a>'
              '<span class="signature">&lt;<wbr>'
              '<span class="type-parameter">T</span>&gt;</span>'),
        ]),
      );
    });

    test('enum page contains mixed-in types', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<dt>Mixed in types</dt>'),
            matches('<a href="../lib/M-mixin.html">M</a>'
                '<span class="signature">&lt;<wbr>'
                '<span class="type-parameter">T</span>&gt;</span>'),
          ]));
    });

    test('enum page contains annotations', () async {
      eLines.expectMainContentContainsAllInOrder([
        matches('<dt>Annotations</dt>'),
        matches('<ul class="annotation-list eNum-relationships">'),
        matches(
            r'<li>@<a href="../lib/C-class.html">C</a>\(&#39;message&#39;\)</li>'),
        matches('</ul>'),
      ]);
    });

    test('enum page contains values', () async {
      expect(
        eLines,
        containsAllInOrder([
          matches('<h2>Values</h2>'),
          matches('<span class="name ">one</span>'),
          matches('<p>Doc comment for <a href="../lib/E.html">one</a>.</p>'),
          matches(
              r'<span class="signature"><code>E&lt;int&gt;.named\(1\)</code></span>'),
        ]),
      );
    });

    test('enum page contains classic values', () async {
      expect(
        enumWithDefaultConstructorLines,
        containsAllInOrder([
          matches('<h2>Values</h2>'),
          matches('<span class="name ">four</span>'),
          matches(
              '<p>Doc comment for <a href="../lib/EnumWithDefaultConstructor.html">six</a>.</p>'),
        ]),
      );
      expect(
        enumWithDefaultConstructorLines.join('\n'),
        isNot(contains(
            '<span class="signature"><code>EnumWithDefaultConstructor')),
      );
    });

    test('enum page contains values with deprecated annotation', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Values</h2>'),
            matches('<span class="name deprecated">two</span>'),
          ]));
    });

    test("enum page contains the 'values' constant", () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Constants</h2>'),
            matches('<a href="../lib/E/values-constant.html">values</a>'),
            matches(
                'A constant List of the values in this enum, in order of their declaration.'),
          ]));
    });

    test('enum page contains hashCode property', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Properties</h2>'),
            matches('<a href="../lib/C/hashCode.html">hashCode</a>'),
          ]));
    });

    test('enum page contains index property', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Properties</h2>'),
            matches('<a href="../lib/E/index.html">index</a>'),
            matches('The integer index of this enum value.'),
          ]));
    });

    test('enum page contains other properties', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Properties</h2>'),
            matches('<a href="../lib/E/f1.html">f1</a>'),
            matches('A field.'),
          ]));
    });

    test('enum page contains instance getters', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Properties</h2>'),
            matches('<a href="../lib/E/ig1.html">ig1</a>'),
            matches('An instance getter.'),
            matches('<span class="feature">read-only</span>'),
          ]));
    });

    test('enum page contains instance setters', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Properties</h2>'),
            matches('<a href="../lib/E/is1.html">is1</a>'),
            matches('An instance setter.'),
            matches('<span class="feature">write-only</span>'),
          ]));
    });

    test('enum page contains instance methods', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Methods</h2>'),
            matches('<a href="../lib/E/m1.html">m1</a>'),
            matches('A method.'),
          ]));
    });

    test('enum page contains static methods', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Static Methods</h2>'),
            matches('<a href="../lib/E/s1.html">s1</a>'),
            matches('A static method.'),
          ]));
    });

    test('enum page contains static fields', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Static Properties</h2>'),
            matches('<a href="../lib/E/sf1.html">sf1</a>'),
            matches('A static field.'),
          ]));
    });

    test('enum page contains static getter/setter pairs', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Static Properties</h2>'),
            matches('<a href="../lib/E/gs1.html">gs1</a>'),
            matches('A static getter.'),
          ]));
    });

    test('enum page contains (static) constants', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Constants</h2>'),
            matches('<a href="../lib/E/c1-constant.html">c1</a>'),
            matches('A constant.'),
          ]));
    });

    test('enum page contains instance operators', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Operators</h2>'),
            matches('<a href="../lib/E/operator_greater.html">operator ></a>'),
            matches('An operator.'),
          ]));
    });

    test('enum sidebar contains default constructors', () async {
      expect(
          enumWithDefaultConstructorLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches(
                '<a href="../lib/EnumWithDefaultConstructor.html#constructors">Constructors</a>'),
            matches(
                '<a href="../lib/EnumWithDefaultConstructor/EnumWithDefaultConstructor.html">EnumWithDefaultConstructor</a>'),
          ]));
    });

    test('enum sidebar contains explicit constructors', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches('<a href="../lib/E.html#constructors">Constructors</a>'),
            matches('<a href="../lib/E/E.named.html">named</a>'),
          ]));
    });

    test('enum sidebar contains values', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches('<a href="../lib/E.html#values">Values</a>'),
            matches('<li><a href="../lib/E.html#one">one</a></li>'),
          ]));
    });

    test('enum sidebar contains properties', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches(
                '<a href="../lib/E.html#instance-properties">Properties</a>'),
            matches('<a href="../lib/E/f1.html">f1</a>'),
            matches('<a href="../lib/E/index.html">index</a>'),
          ]));
    });

    test('enum sidebar contains methods', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches('<a href="../lib/E.html#instance-methods">Methods</a>'),
            matches('<a href="../lib/E/m1.html">m1</a>'),
          ]));
    });

    test('enum sidebar contains operators', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches('<a href="../lib/E.html#operators">Operators</a>'),
            matches('<a href="../lib/E/operator_greater.html">operator ></a>'),
          ]));
    });

    test('enum sidebar contains static properties', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches(
                '<a href="../lib/E.html#static-properties">Static properties</a>'),
            matches('<a href="../lib/E/gs1.html">gs1</a>'),
            matches('<a href="../lib/E/sf1.html">sf1</a>'),
          ]));
    });

    test('enum sidebar contains static methods', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches(
                '<a href="../lib/E.html#static-methods">Static methods</a>'),
            matches('<a href="../lib/E/s1.html">s1</a>'),
          ]));
    });

    test('enum sidebar contains constants', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<div id="dartdoc-sidebar-right"'),
            matches('<a href="../lib/E.html#constants">Constants</a>'),
            matches('<a href="../lib/E/c1-constant.html">c1</a>'),
            matches('<a href="../lib/E/values-constant.html">values</a>'),
          ]));
    });

    // TODO(srawlins): Add rendering tests.
    // * Add tests for rendered supertype (Enum) HTML.
  });
}
