// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'documentation_comment_test_base.dart';
import 'src/utils.dart' as utils;

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ExampleDirectiveTest);
  });
}

@reflectiveTest
class ExampleDirectiveTest extends DocumentationCommentTestBase {
  Future<void> _bootPackage(String comment,
      {Map<String, String> files = const {},
      String libraryPath = 'lib/a.dart'}) async {
    projectRoot = utils.writePackage(packageName, resourceProvider);
    var pathContext = resourceProvider.pathContext;
    for (var entry in files.entries) {
      var pathParts = pathContext.split(entry.key);
      var currentFolder = projectRoot;
      for (var i = 0; i < pathParts.length - 1; i++) {
        if (pathParts[i] == '' || pathParts[i] == pathContext.separator) {
          continue;
        }
        currentFolder = currentFolder.getChildAssumingFolder(pathParts[i]);
      }
      currentFolder
          .getChildAssumingFile(pathParts.last)
          .writeAsStringSync(entry.value);
    }

    var pathParts = pathContext.split(libraryPath);
    var currentFolder = projectRoot;
    for (var i = 0; i < pathParts.length - 1; i++) {
      if (pathParts[i] == '' || pathParts[i] == pathContext.separator) {
        continue;
      }
      currentFolder = currentFolder.getChildAssumingFolder(pathParts[i]);
    }
    currentFolder
        .getChildAssumingFile(pathParts.last)
        .writeAsStringSync('$comment\nlibrary;');

    packageGraph =
        await utils.bootBasicPackage(projectRoot.path, packageMetaProvider);

    libraryModel = packageGraph.defaultPackage.libraries.firstWhere((l) =>
        pathContext
            .normalize(l.sourceFileName)
            .endsWith(pathContext.normalize(libraryPath)));
  }

  void test_processesExampleDirective() async {
    await _bootPackage('''
/// Text.
///
/// {@example /examples/hello.dart}
///
/// End text.
''', files: {
      'examples/hello.dart': 'void main() => print("hello");',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
Text.


```dart
void main() => print("hello");
```


End text.'''));
  }

  void test_processesExampleDirective_noExtension_noLang() async {
    await _bootPackage('''
/// {@example /examples/hello}
''', files: {
      'examples/hello': 'hello world',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''

```
hello world
```
'''));
  }

  void test_processesExampleDirective_withLang() async {
    await _bootPackage('''
/// {@example /examples/hello.txt lang=text}
''', files: {
      'examples/hello.txt': 'hello world',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''

```text
hello world
```
'''));
  }

  void test_processesExampleDirective_withIndentKeep() async {
    await _bootPackage('''
/// {@example /examples/hello.dart indent=keep}
''', files: {
      'examples/hello.dart': '  void main() {\n    print("hello");\n  }',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''

```dart
  void main() {
    print("hello");
  }
```
'''));
  }

  void test_processesExampleDirective_inline_ignored() async {
    await _bootPackage('''
/// This is an inline {@example /examples/hello.dart} directive.
''', files: {
      'examples/hello.dart': 'void main() => print("hello");',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    // It should NOT be replaced because it's not on its own line.
    expect(doc, equals('''
This is an inline {@example /examples/hello.dart} directive.'''));
  }

  void test_processesExampleDirective_withIndentStrip() async {
    await _bootPackage('''
/// {@example /examples/hello.dart indent=strip}
''', files: {
      'examples/hello.dart': '  void main() {\n    print("hello");\n  }',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''

```dart
void main() {
  print("hello");
}
```
'''));
  }

  void test_processesExampleDirective_withIndentStrip_mixedWhitespace() async {
    await _bootPackage('''
/// {@example /examples/hello.dart indent=strip}
''', files: {
      'examples/hello.dart': '  space\n\ttab\n  space',
    });

    var doc = await libraryModel.processComment();

    expect(
      libraryModel,
      hasWarning(PackageWarning.invalidParameter,
          'Example contains tabs in indentation. Indentation stripping disabled to avoid incorrect formatting.'),
    );
    expect(doc, equals('''

```dart
  space
\ttab
  space
```
'''));
  }

  void test_exampleDirective_missingFile() async {
    await _bootPackage('''
/// {@example /examples/non_existent.dart}
''');

    await libraryModel.processComment();

    expect(
      libraryModel,
      hasWarning(
          PackageWarning.missingExampleFile, '/examples/non_existent.dart'),
    );
  }

  void test_exampleDirective_missingFilePath() async {
    await _bootPackage('''
/// {@example}
''');

    await libraryModel.processComment();

    expect(
      libraryModel,
      hasWarning(PackageWarning.invalidParameter,
          'Must specify a file path for the @example directive.'),
    );
  }
}
