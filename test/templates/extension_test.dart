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
import '../src/utils.dart';

void main() async {
  const packageName = 'test_package';

  late String packagePath;
  late MemoryResourceProvider resourceProvider;
  late PackageMetaProvider packageMetaProvider;
  late List<String> eLines;
  late List<String> eRightSidebarLines;

  Dartdoc buildDartdoc() {
    var context = generatorContextFromArgv([
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
    var packageBuilder = PubPackageBuilder(
      context,
      packageMetaProvider,
      packageConfigProvider,
      skipUnreachableSdkLibraries: true,
    );
    return Dartdoc.fromContext(context, packageBuilder);
  }

  group('extensions', () {
    setUpAll(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      packagePath = await d.createPackage(
        packageName,
        libFiles: [
          d.file('lib.dart', '''
/// Extended by [E].
class C<T> {}

/// Comment on extension.
extension E<T> on C<T> {
  /// A method.
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
      var dartdoc = buildDartdoc();
      await dartdoc.generateDocs();
      eLines = resourceProvider
          .getFile(path.join(packagePath, 'doc', 'lib', 'E.html'))
          .readAsStringSync()
          .split('\n');
      eRightSidebarLines = resourceProvider
          .getFile(
              path.join(packagePath, 'doc', 'lib', 'E-extension-sidebar.html'))
          .readAsStringSync()
          .split('\n');
    });

    test('extension page contains extension name with generics', () async {
      // TODO(srawlins): Use expectMainContentContainsAllInOrder throughout.
      expect(
          eLines,
          containsAllInOrder([
            matches('<span class="kind-class">E&lt;<wbr>'
                '<span class="type-parameter">T</span>&gt;</span> extension'),
          ]));
    });

    test('extension page contains extended types', () async {
      expect(
        eLines,
        containsAllInOrder([
          matches('<dt>on</dt>'),
          matches('<a href="../lib/C-class.html">C</a>'
              '<span class="signature">&lt;<wbr>'
              '<span class="type-parameter">T</span>&gt;</span>'),
        ]),
      );
    });

    test('extension page contains static methods', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Static Methods</h2>'),
            matches('<a href="../lib/E/s1.html">s1</a>'),
            matches('A static method.'),
          ]));
    });

    test('extension page contains static fields', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Static Properties</h2>'),
            matches('<a href="../lib/E/sf1.html">sf1</a>'),
            matches('A static field.'),
          ]));
    });

    test('extension page contains static getter/setter pairs', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Static Properties</h2>'),
            matches('<a href="../lib/E/gs1.html">gs1</a>'),
            matches('A static getter.'),
          ]));
    });

    test('extension page contains (static) constants', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Constants</h2>'),
            matches('<a href="../lib/E/c1-constant.html">c1</a>'),
            matches('A constant.'),
          ]));
    });

    test('extension page contains instance operators', () async {
      expect(
          eLines,
          containsAllInOrder([
            matches('<h2>Operators</h2>'),
            matches('<a href="../lib/E/operator_greater.html">operator ></a>'),
            matches('An operator.'),
          ]));
    });

    test('extension page contains source link', () async {
      expect(
        eLines,
        containsAllInOrder([
          matches('<a title="View source code" class="source-link" '
              'href="https://github.com/dart-lang/TEST_PKG/lib/lib.dart#L5">'
              '<span class="material-symbols-outlined">description</span></a>'),
        ]),
      );
    });

    test('extension sidebar contains methods', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches('<a href="lib/E.html#instance-methods">Methods</a>'),
          matches('<a href="lib/E/m1.html">m1</a>'),
        ]),
      );
    });

    test('extension sidebar contains operators', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches('<a href="lib/E.html#operators">Operators</a>'),
          matches('<a href="lib/E/operator_greater.html">operator ></a>'),
        ]),
      );
    });

    test('extension sidebar contains static properties', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches(
              '<a href="lib/E.html#static-properties">Static properties</a>'),
          matches('<a href="lib/E/gs1.html">gs1</a>'),
          matches('<a href="lib/E/sf1.html">sf1</a>'),
        ]),
      );
    });

    test('extension sidebar contains static methods', () async {
      expect(
        eRightSidebarLines,
        containsAllInOrder([
          matches('<a href="lib/E.html#static-methods">Static methods</a>'),
          matches('<a href="lib/E/s1.html">s1</a>'),
        ]),
      );
    });
  });
}
