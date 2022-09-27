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
  group('typedefs', () {
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

    test('basic typedef', () async {
      final cb1Typedef = library.typedefs.named('Cb1');

      expect(cb1Typedef.nameWithGenerics, 'Cb1');
      expect(cb1Typedef.genericParameters, '');
      expect(cb1Typedef.aliasedType is FunctionType, isTrue);
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

    test('generic typedef', () async {
      final cb2Typedef = library.typedefs.named('Cb2');

      expect(
        cb2Typedef.nameWithGenerics,
        'Cb2&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(
        cb2Typedef.genericParameters,
        '&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(cb2Typedef.aliasedType is FunctionType, isTrue);
    });

    test('generic typedef referring to a generic typedef', () async {
      final cb3Typedef = library.typedefs.named('Cb3');

      expect(
        cb3Typedef.nameWithGenerics,
        'Cb3&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(
        cb3Typedef.genericParameters,
        '&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
      expect(cb3Typedef.aliasedType is FunctionType, isTrue);

      expect(cb3Typedef.parameters, hasLength(1));

      // TODO(srawlins): Dramatically improve typedef testing.
    });
  });
}
