// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  // We can not use ExperimentalFeature.releaseVersion or even
  // ExperimentalFeature.experimentalReleaseVersion as these are set to null
  // even when partial analyzer implementations are available.
  final enhancedEnumsAllowed =
      VersionRange(min: Version.parse('2.17.0-0'), includeMin: true);

  group('enums', () {
    late Library library;

    // It is expensive (~10s) to compute a package graph, even skipping
    // unreachable Dart SDK libraries, so we set up this package once.
    setUpAll(() async {
      const libraryName = 'enums';

      await d.createPackage(
        libraryName,
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

enum E { one, two, three }
'''),
        ],
      );

      var packageGraph = await bootBasicPackage(
        d.dir(libraryName).io.path,
        pubPackageMetaProvider,
        PhysicalPackageConfigProvider(),
      );
      library = packageGraph.libraries.named(libraryName);
    });

    test('an enum is presented with a linked name', () async {
      var eEnum = library.enums.named('E');

      expect(
          eEnum.linkedName,
          equals(
              '<a href="%%__HTMLBASE_dartdoc_internal__%%enums/E.html">E</a>'));
    });
  });

  group('enhanced enums', () {
    const libraryName = 'enhanced_enums';
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
    const linkPrefix = '$placeholder$libraryName';

    late Library library;

    // It is expensive (~10s) to compute a package graph, even skipping
    // unreachable Dart SDK libraries, so we set up this package once.
    setUpAll(() async {
      await d.createPackage(
        libraryName,
        pubspec: '''
name: enhanced_enums
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
library $libraryName;

class C<T> {}

enum E<T> implements C<T> { one, two, three; }
'''),
        ],
      );

      var packageGraph = await bootBasicPackage(
        d.dir(libraryName).io.path,
        pubPackageMetaProvider,
        PhysicalPackageConfigProvider(),
      );
      library = packageGraph.libraries.named(libraryName);
    });

    test('an enum is presented with a linked name', () async {
      var eEnum = library.enums.named('E');

      expect(eEnum.linkedName, '<a href="$linkPrefix/E.html">E</a>');
    });

    test('a generic enum is presented with linked type parameters', () async {
      var eEnum = library.enums.named('E');

      expect(
        eEnum.linkedGenericParameters,
        '<span class="signature">&lt;<wbr><span class="type-parameter">T</span>&gt;</span>',
      );
    });

    test('a generic enum is presented with linked interfaces', () async {
      var eEnum = library.enums.named('E');

      expect(eEnum.interfaces, isNotEmpty);
    }, skip: true /* currently failing */);

    // TODO(srawlins): Add rendering tests.
    // * Fix interfaces test.
    // * Add tests for rendered supertypes HTML.
    // * Add tests for rendered interfaces HTML.
    // * Add tests for rendered mixins HTML.
    // * Add tests for rendered static members.
    // * Add tests for rendered fields.
    // * Add tests for rendered getters, setters, operators, methods.
    // * Add tests for rendered field pages.
    // * Add tests for rendered generic enum values.
    // * Add tests for rendered constructors.

    // TODO(srawlins): Add referencing tests (`/// [Enum.method]` etc.)
    // * Add tests for referencing enum static members.
    // * Add tests for referencing enum getters, setters, operators, methods.
    // * Add tests for referencing constructors.
  }, skip: !enhancedEnumsAllowed.allows(platformVersion));
}
