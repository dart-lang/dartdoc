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

    for (var MapEntry(key: path, value: content) in files.entries) {
      _writeFile(path, content);
    }

    _writeFile(libraryPath, '$comment\nlibrary;');

    packageGraph =
        await utils.bootBasicPackage(projectRoot.path, packageMetaProvider);

    var expectedPath =
        pathContext.normalize(pathContext.join(projectRoot.path, libraryPath));
    libraryModel = packageGraph.defaultPackage.libraries.firstWhere(
        (l) => pathContext.normalize(l.sourceFileName) == expectedPath);
  }

  void _writeFile(String path, String content) {
    var pathParts = path.split('/');
    var currentFolder = projectRoot;
    for (var i = 0; i < pathParts.length - 1; i++) {
      if (pathParts[i].isEmpty) continue;
      currentFolder = currentFolder.getFolder(pathParts[i]);
    }
    currentFolder.getFile(pathParts.last).writeAsStringSync(content);
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
```'''));
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
```'''));
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
```'''));
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
```'''));
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
          'Example contains non-space whitespace in indentation. Indentation stripping disabled to avoid incorrect formatting.'),
    );
    expect(doc, equals('''
```dart
  space
\ttab
  space
```'''));
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

  void test_exampleDirective_extraPositionalArguments() async {
    await _bootPackage('''
/// {@example /examples/hello.dart extra1 extra2}
''', files: {
      'examples/hello.dart': 'void main() {}',
    });

    await libraryModel.processComment();

    expect(
      libraryModel,
      hasWarning(
          PackageWarning.invalidParameter,
          'The {@example} directive only takes one positional argument (the file path). '
          'Ignoring extra arguments: extra1 extra2'),
    );
  }

  void test_processesExampleDirective_region_noRegionSpecified() async {
    await _bootPackage('''
/// {@example /examples/hello.dart}
''', files: {
      'examples/hello.dart': '''
// #region main
void main() {
  // #region hello
  print('hello world');
  // #endregion hello
  exit(0); // force exit! #hide
}
// #endregion main
''',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    // Verify that no markers are stripped when embedding the entire file.
    expect(doc, equals('''
```dart
// #region main
void main() {
  // #region hello
  print('hello world');
  // #endregion hello
  exit(0); // force exit! #hide
}
// #endregion main
```'''));
  }

  void test_processesExampleDirective_region_extractsOuterRegion() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#main}
    ''', files: {
      'examples/hello.dart': '''
// #region main
void main() {
  // #region hello
  print('hello world');
  // #endregion hello
  exit(0); // force exit! #hide
}
// #endregion main
''',
    });
    var doc = await libraryModel.processComment();

    expectNoWarnings();
// Verify it extracts the outer region and strips the nested markers and hidden
// lines.
    expect(doc, equals('''
```dart
void main() {
  print('hello world');
}
```'''));
  }

  void test_processesExampleDirective_region_extractsNestedRegion() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#hello}
    ''', files: {
      'examples/hello.dart': '''
// #region main
void main() {
  // #region hello
  print('hello world');
  // #endregion hello
  exit(0); // force exit! #hide
}
// #endregion main
''',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
// Default indentation stripping should remove the 2 spaces from the extracted
// block.
    expect(doc, equals('''
```dart
print('hello world');
```'''));
  }

  void test_processesExampleDirective_region_multipleSequentialRegions() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#first} 
    /// 
    /// {@example /examples/hello.dart#second}
    ''', files: {
      'examples/hello.dart': '''
// #region first 
int a = 1; 
// #endregion first 
// #region second 
int b = 2; 
// #endregion second ''',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
```dart
int a = 1; 
```

```dart
int b = 2; 
```'''));
  }

  void test_processesExampleDirective_region_notFound() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#non_existent_region} ''', files: {
      'examples/hello.dart': '''
  // #region main 
  void main() {} 
  // #endregion main ''',
    });

    var doc = await libraryModel.processComment();
    expect(
      libraryModel,
      hasWarning(
        PackageWarning.missingExampleRegion,
        '/examples/hello.dart#non_existent_region',
      ),
    );

    expect(doc, equals(''));
  }

  void test_processesExampleDirective_region_emptyFragment() async {
    await _bootPackage('''
/// {@example /examples/hello.dart#}
''', files: {
      'examples/hello.dart': '''
// #region main
void main() {
  // #region hello
  print('hello world');
  // #endregion hello
  exit(0); // force exit! #hide
}
// #endregion main
''',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    // Verify that an empty fragment is treated identically to no fragment at
    // all, embedding the entire file without stripping any markers.
    expect(doc, equals('''
```dart
// #region main
void main() {
  // #region hello
  print('hello world');
  // #endregion hello
  exit(0); // force exit! #hide
}
// #endregion main
```'''));
  }

  void test_processesExampleDirective_region_empty() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#empty_target} ''', files: {
      'examples/hello.dart': '''
          // #region main 
          void main() {} 
          // #endregion main 
          // #region empty_target
          // #endregion empty_target''',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('```dart\n```'));
  }

  void test_processesExampleDirective_region_unmatchedEndRegion() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#main} ''', files: {
      'examples/hello.dart': '''
// #region main
void main() {} 
// #endregion 
void f(){}
// #endregion 
''',
    });

    var doc = await libraryModel.processComment();

    expect(
      libraryModel,
      hasWarning(
        PackageWarning.invalidParameter,
        'Found #endregion without a matching #region in /examples/hello.dart at line 5.',
      ),
    );

    // Verify that the parser used best effort to extract the first closed
    // region and ignored the trailing code and extra marker.
    expect(doc, equals('''
```dart
void main() {} 
```'''));
  }

  void test_processesExampleDirective_region_unclosedRegion() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#main} ''', files: {
      'examples/hello.dart': '''
// #region main
void main() {
  // #region nested
  print('hello');
  // #endregion nested
// End of file reached without closing the main tag''',
    });

    var doc = await libraryModel.processComment();

    expect(
      libraryModel,
      hasWarning(
        PackageWarning.invalidParameter,
        'Unclosed #region(s) found in /examples/hello.dart: main',
      ),
    );

    // Verify that the parser used best effort to extract everything
    // from the opening tag to the end of the file, skipping the nested marker.
    expect(doc, equals('''
```dart
void main() {
  print('hello');
// End of file reached without closing the main tag
```'''));
  }

  void test_processesExampleDirective_region_languageAgnosticMarkers() async {
    await _bootPackage('''
    /// {@example /examples/hello.dart#main} ''', files: {
      'examples/hello.dart': '''
#region main
void main() {
  <!-- #region nested -->
  print('hello HTML!');
  <!-- #endregion -->

  var sql = "-- #hide";
  var python = "# #region python_style";
  var pythonEnd = "# #endregion";
}
#endregion main''',
    });

    var doc = await libraryModel.processComment();

    expectNoWarnings();
    // Verify that markers are stripped regardless of the comment style
    // (or lack thereof) preceding them, making them language-agnostic.
    expect(doc, equals('''
```dart
void main() {
  print('hello HTML!');

}
```'''));
  }
}
