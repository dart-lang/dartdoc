// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart' as utils;

void main() async {
  const packageName = 'test_package';

  late d.DirectoryDescriptor packageDir;

  Future<Dartdoc> buildDartdoc({
    List<String> excludeLibraries = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    final resourceProvider = pubPackageMetaProvider.resourceProvider;
    final dir = resourceProvider
        .getFolder(resourceProvider.pathContext.absolute(packageDir.io.path));
    final context = await utils.generatorContextFromArgv([
      '--input',
      dir.path,
      '--output',
      p.join(dir.path, 'doc'),
      '--sdk-dir',
      pubPackageMetaProvider.defaultSdkDir.path,
      '--exclude',
      excludeLibraries.join(','),
      '--allow-tools',
      '--no-link-to-remote',
    ]);

    return await Dartdoc.fromContext(
      context,
      PubPackageBuilder(
        context,
        pubPackageMetaProvider,
        PhysicalPackageConfigProvider(),
        skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
      ),
    );
  }

  test('favicon option copies a favicon file', () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  favicon: anicon.png
''',
      libFiles: [d.file('lib.dart', '')],
      files: [d.file('anicon.png', 'Just plain text')],
    );
    await (await buildDartdoc()).generateDocs();

    await d.dir(packageName, [
      d.dir('doc', [
        d.dir('static-assets', [d.file('favicon.png', 'Just plain text')]),
      ]),
    ]).validate();
  });

  test('header option adds content to index.html', () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  header: ['extras/header.html']
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('header.html', '<em>Header</em> things.')])
      ],
    );
    await (await buildDartdoc()).generateDocs();

    await d.dir(packageName, [
      d.dir('doc', [
        d.file('index.html', contains('<em>Header</em> things.')),
      ]),
    ]).validate();
  });

  test('footer option adds content to index.html', () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  footer: ['extras/footer.html']
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('footer.html', '<em>Footer</em> things.')])
      ],
    );
    await (await buildDartdoc()).generateDocs();

    await d.dir(packageName, [
      d.dir('doc', [
        d.file('index.html', contains('<em>Footer</em> things.')),
      ]),
    ]).validate();
  });

  test('footerText option adds text to index.html', () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  footerText: ['extras/footer.txt']
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('footer.txt', 'Just footer text')])
      ],
    );
    await (await buildDartdoc()).generateDocs();

    await d.dir(packageName, [
      d.dir('doc', [
        d.file('index.html', contains('Just footer text')),
      ]),
    ]).validate();
  });

  test('excludeFooterVersion option does not display version', () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  excludeFooterVersion: true
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('footer.txt', 'Just footer text')])
      ],
    );
    await (await buildDartdoc()).generateDocs();

    final indexContent =
        io.File(p.joinAll([packageDir.io.path, 'doc', 'index.html']))
            .readAsStringSync();
    final footerRegex =
        RegExp(r'<footer>(.*\s*?\n?)+?</footer>', multiLine: true);
    // Get footer, and check for version number.
    final match = footerRegex.firstMatch(indexContent);
    if (match == null) {
      fail('Could not find footer tag in "$indexContent"');
    }
    final version = RegExp(r'(\d+\.)?(\d+\.)?(\*|\d+)');
    expect(version.hasMatch(match.group(0)!), false, reason: indexContent);
  });

  test('examplePathPrefix option finds examples in a custom path', () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  examplePathPrefix: 'package_examples'
''',
      libFiles: [
        d.file('lib.dart', '''
/// An example in a non-default location:
///
/// {@example foo.dart}
class Foo {}
'''),
      ],
      files: [
        d.dir('package_examples', [
          d.file('foo.dart.md', '''
```
An example in an unusual dir.
```
'''),
        ]),
      ],
    );
    final results = await (await buildDartdoc()).generateDocs();
    final classFoo = results.packageGraph.allCanonicalModelElements
        .whereType<Class>()
        .firstWhere((c) => c.name == 'Foo');
    expect(classFoo.documentationAsHtml,
        contains('<code class="language-dart">An example in an unusual dir.'));
  });

  test('showUndocumentedCategories option shows undocumented categories',
      () async {
    packageDir = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  showUndocumentedCategories: true
''',
      libFiles: [
        d.file('lib.dart', '''
/// {@category SomethingUndocumented}
class Foo {}
'''),
      ],
    );
    final results = await (await buildDartdoc()).generateDocs();
    final classFoo = results.packageGraph.allCanonicalModelElements
        .whereType<Class>()
        .firstWhere((c) => c.name == 'Foo');
    expect(classFoo.displayedCategories, isNotEmpty);
  });
}
