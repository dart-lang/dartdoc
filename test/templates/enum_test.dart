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
import '../src/utils.dart';

void main() async {
  const packageName = 'test_package';

  late String packagePath;
  late MemoryResourceProvider resourceProvider;
  late PackageMetaProvider packageMetaProvider;
  late DartdocGeneratorOptionContext context;
  late List<String> eLines;

  Future<PubPackageBuilder> createPackageBuilder({
    List<String> additionalOptions = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    context = await generatorContextFromArgv([
      '--input',
      packagePath,
      '--output',
      p.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--no-link-to-remote',
      ...additionalOptions,
    ], packageMetaProvider);

    var packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
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

  group('enhanced enums', () {
    setUpAll(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      packagePath = await d.createPackage(
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
class C<T> {}

enum E<T> implements C<T> {
  /// Doc comment for [one].
  one,

  two, three;

  /// A method.
  void m1() {}

  /// An operator.
  bool operator >(E other) => false;

  /// A field.
  int f1 = 0;

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
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await writeDartdocResources(resourceProvider);
      await (await buildDartdoc()).generateDocs();
      eLines = resourceProvider
          .getFile(p.join(packagePath, 'doc', 'lib', 'E.html'))
          .readAsStringSync()
          .split('\n');
    });

    test('enum page contains enum name with generics', () async {
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

    test('enum page contains values', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Values</h2>'),
            matches('<span class="name ">one</span>'),
            matches('<p>Doc comment for <a href="../lib/E.html">one</a>.</p>'),
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
  }, skip: !enhancedEnumsAllowed);
}
