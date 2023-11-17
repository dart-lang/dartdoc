// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart' as utils;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OptionsTest);
  });
}

@reflectiveTest
class OptionsTest extends DartdocTestBase {
  @override
  String get libraryName => 'options';

  static const packageName = 'test_package';

  Future<void> createPackage(
    String name, {
    String? dartdocOptions,
    List<d.Descriptor> libFiles = const [],
    List<d.Descriptor> files = const [],
  }) async {
    packagePath = await d.createPackage(
      packageName,
      dartdocOptions: dartdocOptions,
      libFiles: libFiles,
      files: files,
      resourceProvider: resourceProvider,
    );
    await utils.writeDartdocResources(resourceProvider);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));
  }

  void test_faviconOptionCopiesFaviconFile() async {
    await createPackage(
      packageName,
      dartdocOptions: '''
dartdoc:
  favicon: anicon.png
''',
      libFiles: [d.file('lib.dart', '')],
      files: [d.file('anicon.png', 'Just plain text')],
    );
    await (await buildDartdoc(
      additionalArguments: [
        '--auto-include-dependencies',
        '--no-link-to-remote',
      ],
    ))
        .generateDocs();

    final faviconContent = resourceProvider
        .getFile(
            path.joinAll([packagePath, 'doc', 'static-assets', 'favicon.png']))
        .readAsStringSync();
    expect(faviconContent, contains('Just plain text'));
  }

  void test_headerOptionAddsContentToIndexFile() async {
    await createPackage(
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

    final indexContent = resourceProvider
        .getFile(path.joinAll([packagePath, 'doc', 'index.html']))
        .readAsStringSync();
    expect(indexContent, contains('<em>Header</em> things.'));
  }

  void test_footerOptionAddsContentToIndexFile() async {
    await createPackage(
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

    final indexContent = resourceProvider
        .getFile(path.joinAll([packagePath, 'doc', 'index.html']))
        .readAsStringSync();
    expect(indexContent, contains('<em>Footer</em> things.'));
  }

  void test_footerTextOptionAddsTextToIndexFile() async {
    await createPackage(
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

    final indexContent = resourceProvider
        .getFile(path.joinAll([packagePath, 'doc', 'index.html']))
        .readAsStringSync();
    expect(indexContent, contains('Just footer text'));
  }

  void test_excludeFooterVersionOptionDoesNotDisplayVersion() async {
    await createPackage(
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

    final indexContent = resourceProvider
        .getFile(path.joinAll([packagePath, 'doc', 'index.html']))
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
  }

  void test_examplePathPrefixOptionFindsExamplesInACustomPath() async {
    await createPackage(
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
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final classFoo = packageGraph.allLocalModelElements
        .where((e) => e.isCanonical)
        .whereType<Class>()
        .firstWhere((c) => c.name == 'Foo');
    expect(classFoo.documentationAsHtml,
        contains('<code class="language-dart">An example in an unusual dir.'));
  }

  void test_formatEqualMdOptionGeneratesMarkdownFiles() async {
    await createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    await (await buildDartdoc(additionalArguments: ['--format', 'md']))
        .generateDocsBase();
    final indexContent = resourceProvider
        .getFile(
            path.joinAll([packagePath, 'doc', 'library_1', 'Foo-class.md']))
        .readAsStringSync();
    expect(indexContent, contains('# Foo class'));
  }

  void test_formatEqualsBadOptionResultsInDartdocFailure() async {
    await createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    expect(
        () => buildDartdoc(additionalArguments: ['--format', 'bad']),
        throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
            'message', startsWith('Unsupported output format'))));
  }

  void test_includeOptionCanBeSpecifiedInOptionsFile() async {
    await createPackage(
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
    );
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    expect(packageGraph.localPublicLibraries.map((l) => l.name),
        orderedEquals(['library_1', 'library_2']));
  }

  void test_includeCommandLineOptionOverridesOptionsFileOption() async {
    await createPackage(
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
    );
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
      additionalArguments: ['--include', 'library_3'],
    );
    expect(packageGraph.localPublicLibraries.map((l) => l.name),
        orderedEquals(['library_3']));
  }

  void test_excludeCommandLineOptionOverridesOptionsFileOption() async {
    await createPackage(
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
    );
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
      additionalArguments: ['--exclude', 'library_1'],
    );
    expect(packageGraph.localPublicLibraries.map((l) => l.name),
        orderedEquals(['library_2']));
  }

  void
      test_showUndocumentedCategoriesOptionShowsUndocumentedCategories() async {
    await createPackage(
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
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final classFoo = packageGraph.allLocalModelElements
        .where((e) => e.isCanonical)
        .whereType<Class>()
        .firstWhere((c) => c.name == 'Foo');
    expect(classFoo.displayedCategories, isNotEmpty);
  }

  void test_categoryOrderOrdersCategories() async {
    await createPackage(
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
    );
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final package = packageGraph.packages
        .firstWhere((element) => element.name == packageName);
    expect(package.documentedCategoriesSorted.map((c) => c.name),
        equals(['Three', 'One', 'Two']));
  }

  void test_categoriesNotIncludedInCategoryOrderAreOrderedAtTheEnd() async {
    await createPackage(
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
    );
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final package = packageGraph.packages
        .firstWhere((element) => element.name == packageName);
    expect(package.documentedCategoriesSorted.map((c) => c.name),
        equals(['Two', 'One', 'Four', 'Three']));
  }

  void test_categoriesAreOnlyTrackedWhenUsed() async {
    await createPackage(
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
    );
    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final package = packageGraph.packages
        .firstWhere((element) => element.name == packageName);
    expect(
        package.documentedCategoriesSorted.map((c) => c.name), equals(['One']));
  }

  void
      test_templatesDirOptionReferencingANonExistentDirectoryResultsInDartdocFailure() async {
    await createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    expect(
        () => buildDartdoc(additionalArguments: ['--templates-dir', 'bad']),
        throwsA(const TypeMatcher<DartdocFailure>().having(
          (f) => f.message,
          'message',
          startsWith(
              'Argument --templates-dir, set to bad, resolves to missing path'),
        )));
  }

  void test_templatesDirOptionSpecifiesTheTemplatesToUse() async {
    await createPackage(
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
    );
    var customTemplatesDir = path.join(packagePath, 'templates');
    var dartdoc = await buildDartdoc(
        additionalArguments: ['--templates-dir', customTemplatesDir]);
    await dartdoc.generateDocsBase();
    final indexContent = resourceProvider
        .getFile(
            path.joinAll([packagePath, 'doc', 'library_1', 'Foo-class.html']))
        .readAsStringSync();
    expect(indexContent, contains('CLASS FILE'));
  }

  void
      test_templatesDirOptionReferencingAnEmptyDirectoryResultsInDartdocFailure() async {
    await createPackage(
      packageName,
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    var customTemplatesDir = resourceProvider
        .newFolder(resourceProvider.pathContext
            .canonicalize(resourceProvider.convertPath('/custom_templates')))
        .path;
    expect(
        () => buildDartdoc(
            additionalArguments: ['--templates-dir', customTemplatesDir]),
        throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
            'message', startsWith('Missing required template file'))));
  }

  void test_limitFilesCreated_maxFileCountIsReached() async {
    await createPackage(
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
    );
    final dartdoc =
        await buildDartdoc(additionalArguments: ['--max-file-count', '2']);
    await expectLater(
        dartdoc.generateDocs,
        throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
            'message', startsWith('Maximum file count reached: '))));
  }

  void test_limitFilesCreated_maxFileCountIsNotReached() async {
    await createPackage(
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
    );
    final dartdoc =
        await buildDartdoc(additionalArguments: ['--max-file-count', '2000']);
    await dartdoc.generateDocs();
  }

  void test_limitFilesCreated_maxTotalSizeIsReached() async {
    await createPackage(
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
    );
    final dartdoc =
        await buildDartdoc(additionalArguments: ['--max-total-size', '15000']);
    await expectLater(
        dartdoc.generateDocs,
        throwsA(const TypeMatcher<DartdocFailure>().having((f) => f.message,
            'message', startsWith('Maximum total size reached: '))));
  }

  void test_limitFilesCreated_maxTotalSizeIsNotReached() async {
    await createPackage(
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
    );
    final dartdoc = await buildDartdoc(
        additionalArguments: ['--max-total-size', '15000000']);
    await dartdoc.generateDocs();
  }
}
