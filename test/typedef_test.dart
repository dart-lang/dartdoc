// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  group('typedefs of function types', () {
    late Library library;

    // It is expensive (~10s) to compute a package graph, even skipping
    // unreachable Dart SDK libraries, so we set up this package once.
    setUpAll(() async {
      const libraryName = 'typedefs';
      final packageMetaProvider = testPackageMetaProvider;

      final packagePath = await d.createPackage(
        libraryName,
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

/// Line _one_.
///
/// Line _two_.
typedef Cb1 = void Function();

typedef Cb2<T> = T Function(T);

/// Not unlike [Cb2].
typedef Cb3<T> = Cb2<List<T>>;
'''),
        ],
        resourceProvider:
            packageMetaProvider.resourceProvider as MemoryResourceProvider,
      );
      final packageConfigProvider =
          getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
      packageConfigProvider.addPackageToConfigFor(
          packagePath, libraryName, Uri.file('$packagePath/'));

      final packageGraph = await bootBasicPackage(
        packagePath,
        packageMetaProvider,
        packageConfigProvider,
      );
      library = packageGraph.libraries.named(libraryName);
    });

    test('basic function typedef', () async {
      final cb1Typedef = library.typedefs.named('Cb1');

      expect(cb1Typedef.nameWithGenerics, 'Cb1');
      expect(cb1Typedef.genericParameters, '');
      expect(cb1Typedef.aliasedType, isA<FunctionType>());
      expect(cb1Typedef.documentationComment, '''
/// Line _one_.
///
/// Line _two_.''');
      expect(cb1Typedef.documentation, '''
Line _one_.

Line _two_.''');
      expect(cb1Typedef.oneLineDoc, 'Line <em>one</em>.');
      expect(cb1Typedef.documentationAsHtml, '''
<p>Line <em>one</em>.</p>
<p>Line <em>two</em>.</p>''');
    });

    test('generic function typedef', () async {
      final cb2Typedef = library.typedefs.named('Cb2');

      expect(
        cb2Typedef.nameWithGenerics,
        'Cb2&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(
        cb2Typedef.genericParameters,
        '&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(cb2Typedef.aliasedType, isA<FunctionType>());
    });

    test('generic function typedef referring to a generic typedef', () async {
      final cb3Typedef = library.typedefs.named('Cb3');

      expect(
        cb3Typedef.nameWithGenerics,
        'Cb3&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(
        cb3Typedef.genericParameters,
        '&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(cb3Typedef.aliasedType, isA<FunctionType>());

      expect(cb3Typedef.parameters, hasLength(1));

      // TODO(srawlins): Dramatically improve typedef testing.
    });

    test('typedef in a doc comment reference', () {
      final cb3Typedef = library.typedefs.named('Cb3');

      expect(cb3Typedef.isDocumented, isTrue);

      expect(cb3Typedef.documentation, 'Not unlike [Cb2].');

      expect(
        cb3Typedef.documentationAsHtml,
        '<p>Not unlike '
        '<a href="%%__HTMLBASE_dartdoc_internal__%%typedefs/Cb2.html">Cb2</a>.'
        '</p>',
      );
    });
  });

  group('typedefs of record types', skip: !recordsAllowed, () {
    late Library library;

    // It is expensive (~10s) to compute a package graph, even skipping
    // unreachable Dart SDK libraries, so we set up this package once.
    setUpAll(() async {
      const libraryName = 'typedefs';
      final packageMetaProvider = testPackageMetaProvider;

      final packagePath = await d.createPackage(
        libraryName,
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

/// Line _one_.
///
/// Line _two_.
typedef R1 = (int, String);

typedef R2<T> = (T, String);

/// Not unlike [R2].
typedef R3<T> = R2<List<T>>;
'''),
        ],
        resourceProvider:
            packageMetaProvider.resourceProvider as MemoryResourceProvider,
      );
      final packageConfigProvider =
          getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
      packageConfigProvider.addPackageToConfigFor(
          packagePath, libraryName, Uri.file('$packagePath/'));

      final packageGraph = await bootBasicPackage(
        packagePath,
        packageMetaProvider,
        packageConfigProvider,
      );
      library = packageGraph.libraries.named(libraryName);
    });

    test('basic record typedef', () async {
      final r1Typedef = library.typedefs.named('R1');

      expect(r1Typedef.nameWithGenerics, 'R1');
      expect(r1Typedef.genericParameters, '');
      expect(r1Typedef.aliasedType, isA<RecordType>());
      expect(r1Typedef.documentationComment, '''
/// Line _one_.
///
/// Line _two_.''');
      expect(r1Typedef.documentation, '''
Line _one_.

Line _two_.''');
      expect(r1Typedef.oneLineDoc, 'Line <em>one</em>.');
      expect(r1Typedef.documentationAsHtml, '''
<p>Line <em>one</em>.</p>
<p>Line <em>two</em>.</p>''');
    });

    test('generic record typedef', () async {
      final r2Typedef = library.typedefs.named('R2');

      expect(
        r2Typedef.nameWithGenerics,
        'R2&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(
        r2Typedef.genericParameters,
        '&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(r2Typedef.aliasedType, isA<RecordType>());
    });

    test('generic record typedef referring to a generic typedef', () async {
      final r3Typedef = library.typedefs.named('R3');

      expect(
        r3Typedef.nameWithGenerics,
        'R3&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(
        r3Typedef.genericParameters,
        '&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(r3Typedef.aliasedType, isA<RecordType>());
    });

    test('typedef in a doc comment reference', () {
      final r3Typedef = library.typedefs.named('R3');

      expect(r3Typedef.isDocumented, isTrue);

      expect(r3Typedef.documentation, 'Not unlike [R2].');

      expect(
        r3Typedef.documentationAsHtml,
        '<p>Not unlike '
        '<a href="%%__HTMLBASE_dartdoc_internal__%%typedefs/R2.html">R2</a>.'
        '</p>',
      );
    });
  });
}
