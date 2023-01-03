// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart' as utils;

// TODO(srawlins): Migrate to test_reflective_loader tests.

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
    List<String> additionalOptions = const [],
    bool skipUnreachableSdkLibraries = true,
  }) async {
    context = await utils.generatorContextFromArgv([
      '--input',
      packagePath,
      '--output',
      p.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--allow-tools',
      '--no-link-to-remote',
      ...additionalOptions,
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

  test("'format=md' option generates markdown files", () async {
    packagePath = await d.createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    await (await buildDartdoc(additionalOptions: ['--format', 'md']))
        .generateDocsBase();
    final indexContent = resourceProvider
        .getFile(p.joinAll([packagePath, 'doc', 'library_1', 'Foo-class.md']))
        .readAsStringSync();
    expect(indexContent, contains('# Foo class'));
  });

  test("'format=bad' option results in DartdocFailure", () async {
    packagePath = await d.createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    expect(
        () => buildDartdoc(additionalOptions: ['--format', 'bad']),
        throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
            'message', startsWith('Unsupported output format'))));
  });

  test("'include' option can be specified in options file", () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  include: ["library_1", "library_2"]
''',
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
        d.file('library_2.dart', '''
library library_2;
class Bar {}
'''),
        d.file('library_3.dart', '''
library library_3;
class Baz {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageGraph =
        await (await createPackageBuilder()).buildPackageGraph();
    expect(packageGraph.localPublicLibraries.map((l) => l.name),
        orderedEquals(['library_1', 'library_2']));
  });

  test("'include' command line option overrides options file option", () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  include: ["library_1", "library_2"]
''',
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
        d.file('library_2.dart', '''
library library_2;
class Bar {}
'''),
        d.file('library_3.dart', '''
library library_3;
class Baz {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageGraph = await (await createPackageBuilder(
      additionalOptions: ['--include', 'library_3'],
    ))
        .buildPackageGraph();
    expect(packageGraph.localPublicLibraries.map((l) => l.name),
        orderedEquals(['library_3']));
  });

  test("'exclude' command line option overrides options file option", () async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  include: ["library_1", "library_2"]
''',
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
        d.file('library_2.dart', '''
library library_2;
class Bar {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageGraph = await (await createPackageBuilder(
      additionalOptions: ['--exclude', 'library_1'],
    ))
        .buildPackageGraph();
    expect(packageGraph.localPublicLibraries.map((l) => l.name),
        orderedEquals(['library_2']));
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
      markdown: one.md
    Two:
      markdown: two.md
    Three:
      markdown: three.md
  categoryOrder: ["Three", "One", "Two"]
''',
      libFiles: [
        d.file('lib.dart', '''
library 'lib1';

/// {@category One}
class C1 {}

/// {@category Two}
class C2 {}

/// {@category Three}
class C3 {}
'''),
      ],
      files: [
        d.file('one.md', ''),
        d.file('two.md', ''),
        d.file('three.md', ''),
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
      markdown: three.md
    One:
      markdown: one.md
    Two:
      markdown: two.md
    Four:
      markdown: four.md
  categoryOrder: ["Two", "One"]
''',
      libFiles: [
        d.file('lib.dart', '''
library 'lib1';

/// {@category Three}
class C3 {}

/// {@category One}
class C1 {}

/// {@category Two}
class C2 {}

/// {@category Four}
class C4 {}
'''),
      ],
      files: [
        d.file('one.md', ''),
        d.file('two.md', ''),
        d.file('three.md', ''),
        d.file('four.md', ''),
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
      markdown: one.md
    Two:
      markdown: two.md
''',
      libFiles: [
        d.file('lib.dart', '''
library 'lib1';

/// {@category One}
class C1 {}
'''),
      ],
      files: [
        d.file('one.md', ''),
        d.file('two.md', ''),
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

  test(
      "'templates-dir' option referencing a non-existent directory results in "
      'DartdocFailure', () async {
    packagePath = await d.createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    expect(
        () => buildDartdoc(additionalOptions: ['--templates-dir', 'bad']),
        throwsA(const TypeMatcher<DartdocFailure>().having(
          (f) => f.message,
          'message',
          startsWith(
              'Argument --templates-dir, set to bad, resolves to missing path'),
        )));
  });

  test("'templates-dir' option specifies the templates to use", () async {
    packagePath = await d.createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
      files: [
        d.dir('templates', [
          d.file('_sidebar_for_container.html', 'EMPTY'),
          d.file('_sidebar_for_library.html', 'EMPTY'),
          d.file('404error.html', 'EMPTY'),
          d.file('category.html', 'EMPTY'),
          d.file('class.html', 'CLASS FILE'),
          d.file('constructor.html', 'EMPTY'),
          d.file('enum.html', 'EMPTY'),
          d.file('extension.html', 'EMPTY'),
          d.file('function.html', 'EMPTY'),
          d.file('index.html', 'EMPTY'),
          d.file('library.html', 'EMPTY'),
          d.file('method.html', 'EMPTY'),
          d.file('mixin.html', 'EMPTY'),
          d.file('property.html', 'EMPTY'),
          d.file('top_level_property.html', 'EMPTY'),
          d.file('typedef.html', 'EMPTY'),
          d.file('search.html', 'EMPTY'),
        ]),
      ],
      resourceProvider: resourceProvider,
    );
    var customTemplatesDir = p.join(packagePath, 'templates');
    await utils.writeDartdocResources(resourceProvider);
    var dartdoc = await buildDartdoc(
        additionalOptions: ['--templates-dir', customTemplatesDir]);
    await dartdoc.generateDocsBase();
    final indexContent = resourceProvider
        .getFile(p.joinAll([packagePath, 'doc', 'library_1', 'Foo-class.html']))
        .readAsStringSync();
    expect(indexContent, contains('CLASS FILE'));
  });

  test(
      "'templates-dir' option referencing an empty directory results in "
      'DartdocFailure', () async {
    packagePath = await d.createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
      resourceProvider: resourceProvider,
    );
    var customTemplatesDir = resourceProvider
        .newFolder(resourceProvider.pathContext
            .canonicalize(resourceProvider.convertPath('/custom_templates')))
        .path;
    expect(
        () => buildDartdoc(
            additionalOptions: ['--templates-dir', customTemplatesDir]),
        throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
            'message', startsWith('Missing required template file'))));
  });

  group('limit files created', () {
    test('maxFileCount is reached', () async {
      packagePath = await d.createPackage(
        packageName,
        libFiles: [
          d.file('library_1.dart', '''
library library_1;
class Foo {
  void x() {}
  void y() {}
}
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await utils.writeDartdocResources(resourceProvider);
      final dartdoc =
          await buildDartdoc(additionalOptions: ['--max-file-count', '2']);
      await expectLater(
          dartdoc.generateDocs,
          throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
              'message', startsWith('Maximum file count reached: '))));
    });

    test('maxFileCount is not reached', () async {
      packagePath = await d.createPackage(
        packageName,
        libFiles: [
          d.file('library_1.dart', '''
library library_1;
class Foo {
  void x() {}
  void y() {}
}
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await utils.writeDartdocResources(resourceProvider);
      final dartdoc =
          await buildDartdoc(additionalOptions: ['--max-file-count', '2000']);
      await dartdoc.generateDocs();
    });

    test('maxTotalSize is reached', () async {
      packagePath = await d.createPackage(
        packageName,
        libFiles: [
          d.file('library_1.dart', '''
library library_1;
class Foo {
  void x() {}
  void y() {}
}
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await utils.writeDartdocResources(resourceProvider);
      final dartdoc =
          await buildDartdoc(additionalOptions: ['--max-total-size', '15000']);
      await expectLater(
          dartdoc.generateDocs,
          throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
              'message', startsWith('Maximum total size reached: '))));
    });

    test('maxTotalSize is not reached', () async {
      packagePath = await d.createPackage(
        packageName,
        libFiles: [
          d.file('library_1.dart', '''
library library_1;
class Foo {
  void x() {}
  void y() {}
}
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await utils.writeDartdocResources(resourceProvider);
      final dartdoc = await buildDartdoc(
          additionalOptions: ['--max-total-size', '15000000']);
      await dartdoc.generateDocs();
    });
  });
}
