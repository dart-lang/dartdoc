// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
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

  Future<void> createPackage({
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
    await writeDartdocResources(resourceProvider);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));
  }

  void test_faviconOption_copiesFaviconFile() async {
    await createPackage(
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
      ],
    ))
        .generateDocs();

    final faviconContent = resourceProvider
        .getFile(
            path.joinAll([packagePath, 'doc', 'static-assets', 'favicon.png']))
        .readAsStringSync();
    expect(faviconContent, contains('Just plain text'));
  }

  void test_headerOption_addsContentToIndexFile() async {
    await createPackage(
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

  void test_footerOption_addsContentToIndexFile() async {
    await createPackage(
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

  void test_footerTextOption_addsTextToIndexFile() async {
    await createPackage(
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

  void test_excludeFooterVersionOption_doesNotDisplayVersion() async {
    await createPackage(
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

  void test_includeOption_canBeSpecifiedInOptionsFile() async {
    await createPackage(
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

  void test_includeCommandLineOption_overridesOptionsFileOption() async {
    await createPackage(
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

  void test_excludeCommandLineOption_overridesOptionsFileOption() async {
    await createPackage(
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
      test_showUndocumentedCategoriesOption_showsUndocumentedCategories() async {
    await createPackage(
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
    final classFoo =
        packageGraph.localPackages.first.libraries.first.classes.named('Foo');
    expect(classFoo.displayedCategories, isNotEmpty);
  }

  void test_categoryOrderOption_ordersCategories() async {
    await createPackage(
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

  void test_categoriesNotIncludedInCategoryOrder_areOrderedAtTheEnd() async {
    await createPackage(
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
      test_templatesDirOption_referencingANonExistentDirectory_resultsInDartdocFailure() async {
    await createPackage(
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

  void test_templatesDirOption_specifiesTheTemplatesToUse() async {
    await createPackage(
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
      test_templatesDirOptionReferencingAnEmptyDirectory_resultsInDartdocFailure() async {
    await createPackage(
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

  void test_emptyPackage() async {
    await createPackage();
    await (await buildDartdoc()).generateDocs();

    expect(outBuffer, isEmpty);
    expect(
      errBuffer.toString(),
      matches('warning: package:test_package has no documentable libraries'),
    );
  }

  void test_helpOption_resultsInPrintedHelp() async {
    startLogging(
      isJson: false,
      isQuiet: false,
      showProgress: false,
      outSink: outBuffer,
      errSink: errBuffer,
    );
    parseOptions(packageMetaProvider, ['--help']);

    expect(
      outBuffer.toString().split('\n'),
      containsAll([
        'Generate HTML documentation for Dart libraries.',
        matches('^-h, --help[ ]+Show command help.')
      ]),
    );
    expect(errBuffer.toString(), isEmpty);
  }

  void test_quietOption_resultsInNoProgressOrOtherLogging() async {
    await createPackage(
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    final dartdoc = await buildDartdoc(additionalArguments: [
      '--quiet',
    ]);
    await dartdoc.generateDocs();

    // With the `--quiet` option, nothing should be printed to stdout, and only
    // warnings should be printed to stderr.
    expect(outBuffer, isEmpty);
    expect(errBuffer.toString(), matches(RegExp(r'''
  warning: library_1 has no library level documentation comments
    from library_1: \(.*lib/library_1.dart:1:9\)
Found 1 warning and 0 errors.
''')));
  }

  void test_noGenerateDocsOption_resultsInNoLoggingAndNoGeneratedDocs() async {
    await createPackage(
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    final dartdoc = await buildDartdoc(additionalArguments: [
      '--no-generate-docs',
    ]);
    await dartdoc.generateDocs();

    // With the `--no-generate-docs` option, nothing should be printed to
    // stdout, and only warnings should be printed to stderr.
    expect(outBuffer, isEmpty);
    expect(errBuffer.toString(), matches(RegExp(r'''
  warning: library_1 has no library level documentation comments
    from library_1: \(.*lib/library_1.dart:1:9\)
Found 1 warning and 0 errors.
''')));

    final outputDirectory = resourceProvider.getFolder(
      path.join(packagePath, 'doc', 'api'),
    );
    expect(outputDirectory.exists, isFalse);
  }

  void test_jsonOption_resultsInJsonOutput() async {
    await createPackage(
      libFiles: [
        d.file('library_1.dart', '''
library library_1;
class Foo {}
'''),
      ],
    );
    await writeDartdocResources(resourceProvider);
    final dartdoc = await buildDartdoc(useJson: true);
    await dartdoc.generateDocs();

    expect(
      outBuffer.toString().split('\n'),
      contains('{"level":"WARNING","message":"Found 1 warning and 0 errors."}'),
    );
    expect(errBuffer, isEmpty);
  }

  void test_nonExistentOption_resultsInFatalError() async {
    expect(
      () => generatorContextFromArgv([
        '--nonexistent',
      ], packageMetaProvider),
      throwsA(isA<ArgParserException>().having(
        (e) => e.toString(),
        'toString',
        contains('Could not find an option named "nonexistent".'),
      )),
    );
  }

  void test_nonExistentInputPath_resultsInFatalError() async {
    expect(
      () => generatorContextFromArgv([
        '--input',
        'non-existent',
      ], packageMetaProvider),
      throwsA(isA<DartdocFileMissing>().having(
        (e) => e.message,
        'message',
        contains(
          'Argument --input, set to non-existent, resolves to missing path:',
        ),
      )),
    );
  }

  void test_limitFilesCreated_maxFileCountIsReached() async {
    await createPackage(
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

  void test_versionOption_resultsInPrintedVersion() async {
    startLogging(
      isJson: false,
      isQuiet: false,
      showProgress: false,
      outSink: outBuffer,
      errSink: errBuffer,
    );
    parseOptions(packageMetaProvider, ['--version']);

    expect(outBuffer.toString(), matches(r'dartdoc version: \d+.\d+.\d+'));
  }
}
