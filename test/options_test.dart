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

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart' as utils;

void main() async {
  const packageName = 'test_package';

  late String packagePath;
  late MemoryResourceProvider resourceProvider;
  late PackageMetaProvider packageMetaProvider;
  late DartdocGeneratorOptionContext context;

  setUp(() {
    packageMetaProvider = utils.testPackageMetaProvider;
    resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;
  });

  Future<PubPackageBuilder> createPackageBuilder({
    List<String> excludeLibraries = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    //final dir = resourceProvider.pathContext.absolute(packagePath);
    context = await utils.generatorContextFromArgv([
      '--input',
      packagePath,
      '--output',
      p.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--exclude',
      excludeLibraries.join(','),
      '--allow-tools',
      '--no-link-to-remote',
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
    List<String> excludeLibraries = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    final packageBuilder = await createPackageBuilder(
      excludeLibraries: excludeLibraries,
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
    return await Dartdoc.fromContext(
      context,
      packageBuilder,
    );
  }

  test('favicon option copies a favicon file', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  favicon: anicon.png
''',
      libFiles: [d.file('lib.dart', '')],
      files: [d.file('anicon.png', 'Just plain text')],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    await (await buildDartdoc()).generateDocs();

    final faviconContent = resourceProvider
        .getFile(
            p.joinAll([packagePath, 'doc', 'static-assets', 'favicon.png']))
        .readAsStringSync();
    expect(faviconContent, contains('Just plain text'));
  });

  test('header option adds content to index.html', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  header: ['extras/header.html']
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('header.html', '<em>Header</em> things.')])
      ],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    await (await buildDartdoc()).generateDocs();

    final indexContent = resourceProvider
        .getFile(p.joinAll([packagePath, 'doc', 'index.html']))
        .readAsStringSync();
    expect(indexContent, contains('<em>Header</em> things.'));
  });

  test('footer option adds content to index.html', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  footer: ['extras/footer.html']
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('footer.html', '<em>Footer</em> things.')])
      ],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    await (await buildDartdoc()).generateDocs();

    final indexContent = resourceProvider
        .getFile(p.joinAll([packagePath, 'doc', 'index.html']))
        .readAsStringSync();
    expect(indexContent, contains('<em>Footer</em> things.'));
  });

  test('footerText option adds text to index.html', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  footerText: ['extras/footer.txt']
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('footer.txt', 'Just footer text')])
      ],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    await (await buildDartdoc()).generateDocs();

    final indexContent = resourceProvider
        .getFile(p.joinAll([packagePath, 'doc', 'index.html']))
        .readAsStringSync();
    expect(indexContent, contains('Just footer text'));
  });

  test('excludeFooterVersion option does not display version', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  excludeFooterVersion: true
''',
      libFiles: [d.file('lib.dart', '')],
      files: [
        d.dir('extras', [d.file('footer.txt', 'Just footer text')])
      ],
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    await (await buildDartdoc()).generateDocs();

    final indexContent = resourceProvider
        .getFile(p.joinAll([packagePath, 'doc', 'index.html']))
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
    packagePath = await d.createPackage(
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
      resourceProvider: resourceProvider,
    );
    final packageGraph =
        await (await createPackageBuilder()).buildPackageGraph();
    final classFoo = packageGraph.allCanonicalModelElements
        .whereType<Class>()
        .firstWhere((c) => c.name == 'Foo');
    expect(classFoo.documentationAsHtml,
        contains('<code class="language-dart">An example in an unusual dir.'));
  });

  test('showUndocumentedCategories option shows undocumented categories',
      () async {
    packagePath = await d.createPackage(
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
      resourceProvider: resourceProvider,
    );
    final packageGraph =
        await (await createPackageBuilder()).buildPackageGraph();
    final classFoo = packageGraph.allCanonicalModelElements
        .whereType<Class>()
        .firstWhere((c) => c.name == 'Foo');
    expect(classFoo.displayedCategories, isNotEmpty);
  });

  test('categoryOrder orders categories', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  categories:
    One:
      markdown: One.md
    Two:
      markdown: Two.md
    Three:
      markdown: Three.md
  categoryOrder: ["Three", "One", "Two"]
''',
      libFiles: [
        d.file('lib.dart', '''
library 'lib1';

/// {@category One}
class C1

/// {@category Two}
class C2

/// {@category Three}
class C3
'''),
      ],
      files: [
        d.file('One.md', ''),
        d.file('Two.md', ''),
        d.file('Three.md', ''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageGraph =
        await (await createPackageBuilder()).buildPackageGraph();
    final package = packageGraph.packages
        .firstWhere((element) => element.name == packageName);
    expect(package.documentedCategoriesSorted.map((c) => c.name),
        equals(['Three', 'One', 'Two']));
  });

  test('categories not included in categoryOrder are ordered at the end',
      () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  categories:
    Three:
      markdown: Three.md
    One:
      markdown: One.md
    Two:
      markdown: Two.md
    Four:
      markdown: Four.md
  categoryOrder: ["Two", "One"]
''',
      libFiles: [
        d.file('lib.dart', '''
library 'lib1';

/// {@category Three}
class C3

/// {@category One}
class C1

/// {@category Two}
class C2

/// {@category Four}
class C4
'''),
      ],
      files: [
        d.file('One.md', ''),
        d.file('Two.md', ''),
        d.file('Three.md', ''),
        d.file('Four.md', ''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageGraph =
        await (await createPackageBuilder()).buildPackageGraph();
    final package = packageGraph.packages
        .firstWhere((element) => element.name == packageName);
    expect(package.documentedCategoriesSorted.map((c) => c.name),
        equals(['Two', 'One', 'Four', 'Three']));
  });

  test('categories are only tracked when used', () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  categories:
    One:
      markdown: One.md
    Two:
      markdown: Two.md
''',
      libFiles: [
        d.file('lib.dart', '''
library 'lib1';

/// {@category One}
class C1
'''),
      ],
      files: [
        d.file('One.md', ''),
        d.file('Two.md', ''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageGraph =
        await (await createPackageBuilder()).buildPackageGraph();
    final package = packageGraph.packages
        .firstWhere((element) => element.name == packageName);
    expect(
        package.documentedCategoriesSorted.map((c) => c.name), equals(['One']));
  });
}
