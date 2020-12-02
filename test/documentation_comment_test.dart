// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  MemoryResourceProvider resourceProvider;
  PackageMetaProvider packageMetaProvider;
  FakePackageConfigProvider packageConfigProvider;
  MockSdk mockSdk;
  Folder sdkFolder;
  Folder projectRoot;
  String projectPath;
  var packageName = 'my_package';
  PackageGraph packageGraph;
  ModelElement libraryModel;

  Matcher hasInvalidParameterWarning(String message) =>
      _HasWarning(PackageWarning.invalidParameter, message);

  Matcher hasMissingExampleWarning(String message) =>
      _HasWarning(PackageWarning.missingExampleFile, message);

  void expectNoWarnings() =>
      expect(packageGraph.packageWarningCounter.countedWarnings, isEmpty);

  group('documentation_comment tests', () {
    setUp(() async {
      resourceProvider = MemoryResourceProvider();
      mockSdk = MockSdk(resourceProvider: resourceProvider);
      sdkFolder = utils.writeMockSdkFiles(mockSdk);

      packageMetaProvider = PackageMetaProvider(
        PubPackageMeta.fromElement,
        PubPackageMeta.fromFilename,
        PubPackageMeta.fromDir,
        resourceProvider,
        sdkFolder,
        defaultSdk: mockSdk,
      );
      var optionSet = await DartdocOptionSet.fromOptionGenerators(
          'dartdoc', [createDartdocOptions], packageMetaProvider);
      optionSet.parseArguments([]);
      packageConfigProvider = FakePackageConfigProvider();
      // To build the package graph, we always ask package_config for a
      // [PackageConfig] for the SDK directory. Put a dummy entry in.
      packageConfigProvider.addPackageToConfigFor(
          sdkFolder.path, 'analyzer', Uri.file('/sdk/pkg/analyzer/'));

      projectRoot = utils.writePackage(
          packageName, resourceProvider, packageConfigProvider);
      projectPath = projectRoot.path;
      projectRoot
          .getChildAssumingFolder('lib')
          .getChildAssumingFile('a.dart')
          .writeAsStringSync('''
/// Documentation comment.
int x;
''');
      packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: []);
      libraryModel = packageGraph.defaultPackage.libraries.first;
    });

    test('removes triple slashes', () async {
      var doc = await libraryModel.processComment('''
/// Text.
/// More text.
''');

      expect(doc, equals('''
Text.
More text.'''));
    });

    test('removes space after triple slashes', () async {
      var doc = await libraryModel.processComment('''
///  Text.
///    More text.
''');

      // TODO(srawlins): Actually, the three spaces before 'More' is perhaps not
      // the best fit. Should it only be two, to match the indent from the first
      // line's "Text"?
      expect(doc, equals('''
Text.
   More text.'''));
    });

    test('leaves blank lines', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// More text.
''');

      expect(doc, equals('''
Text.

More text.'''));
    });

    test('warns when an unknown directive is parsed', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@marco name}
''');
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              libraryModel, PackageWarning.unknownDirective, "'marco'"),
          isTrue);
    });

    test('warns when a directive with wrong case is parsed', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@youTube url}
''');
      expect(
          packageGraph.packageWarningCounter.hasWarning(libraryModel,
              PackageWarning.unknownDirective, "'youTube' (use lowercase)"),
          isTrue);
    });

    test('processes @animation', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');

      expectNoWarnings();
      var rendered = libraryModel.modelElementRenderer.renderAnimation(
          'barHerderAnimation',
          100,
          200,
          Uri.parse('http://host/path/to/video.mp4'),
          'barHerderAnimation_play_button_');
      expect(doc, equals('''
Text.

$rendered

End text.'''));
    });

    test('renders an unnamed @animation', () async {
      var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="animation_1"'));
    });

    test('renders a named @animation', () async {
      var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=namedAnimation}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="namedAnimation"'));
    });

    test('renders a named @animation, out-of-order', () async {
      var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 id=namedAnimation http://host/path/to/video.mp4}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="namedAnimation"'));
    });

    test('renders a named @animation with double quotes', () async {
      var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id="namedAnimation"}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="namedAnimation"'));
    });

    test('renders a named @animation with single quotes', () async {
      var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id='namedAnimation'}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="namedAnimation"'));
    });

    test('renders multiple @animation using unique IDs', () async {
      var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
/// {@animation 100 200 http://host/path/to/video2.mp4}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="animation_1"'));
      expect(doc, contains('<video id="animation_2"'));

      // A second element with unnamed animations requires unique IDs as well.
      doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
/// {@animation 100 200 http://host/path/to/video2.mp4}
''');

      expectNoWarnings();
      expect(doc, contains('<video id="animation_3"'));
      expect(doc, contains('<video id="animation_4"'));
    });

    test('warns when @animation has fewer than 3 arguments', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'Invalid @animation directive, "{@animation 100 '
              'http://host/path/to/video.mp4 id=barHerderAnimation}"\n'
              'Animation directives must be of the form "{@animation WIDTH '
              'HEIGHT URL [id=ID]}"'));
    });

    test('warns when @animation has more than 4 arguments', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200 300 400 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'Invalid @animation directive, "{@animation 100 200 300 400 '
              'http://host/path/to/video.mp4 id=barHerderAnimation}"\n'
              'Animation directives must be of the form "{@animation WIDTH '
              'HEIGHT URL [id=ID]}"'));
    });

    test('warns when @animation has more than 4 arguments', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200 300 400 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'Invalid @animation directive, "{@animation 100 200 300 400 '
              'http://host/path/to/video.mp4 id=barHerderAnimation}"\n'
              'Animation directives must be of the form "{@animation WIDTH '
              'HEIGHT URL [id=ID]}"'));
    });

    test('warns when @animation has a non-unique identifier', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=barHerderAnimation}
/// {@animation 100 200 http://host/path/to/video.mpg id=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'An animation has a non-unique identifier, '
              '"barHerderAnimation". Animation identifiers must be unique.'));
    });

    test('warns when @animation has an invalid identifier', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=not-valid}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'An animation has an invalid identifier, "not-valid". The '
              'identifier can only contain letters, numbers and underscores, and '
              'must not begin with a number.'));
    });

    test('warns when @animation has a malformed width', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100px 200 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'An animation has an invalid width (barHerderAnimation), '
              '"100px". The width must be an integer.'));
    });

    test('warns when @animation has a malformed height', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200px http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'An animation has an invalid height (barHerderAnimation), '
              '"200px". The height must be an integer.'));
    });

    test('warns when @animation has an unknown parameter', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 name=barHerderAnimation}
///
/// End text.
''');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'The {@animation ...} directive was called with invalid '
              'parameters. FormatException: Could not find an option named '
              '"name".'));
    });

    test('warns when @animation uses the deprecated syntax', () async {
      await libraryModel.processComment('''
/// Text.
///
/// {@animation barHerderAnimation 100 200 http://host/path/to/video.mp4}
///
/// End text.
''');

      expect(
          packageGraph.packageWarningCounter.hasWarning(
              libraryModel,
              PackageWarning.deprecated,
              'Deprecated form of @animation directive, "{@animation '
              'barHerderAnimation 100 200 http://host/path/to/video.mp4}"\n'
              'Animation directives are now of the form "{@animation WIDTH '
              'HEIGHT URL [id=ID]}" (id is an optional parameter)'),
          isTrue);
    });

    test('processes @template', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
///
/// End text.
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

{@macro abc}

End text.'''));
    });

    test('processes leading @template', () async {
      var doc = await libraryModel.processComment('''
/// {@template abc}
/// Template text.
/// {@endtemplate}
///
/// End text.
''');

      expectNoWarnings();
      expect(doc, equals('''
{@macro abc}

End text.'''));
    });

    test('processes trailing @template', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

{@macro abc}'''));
    });

    test('processes @template w/o blank line following', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
/// End text.
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

{@macro abc}
End text.'''));
    });

    test('allows whitespace around @template name', () async {
      var doc = await libraryModel.processComment('''
/// {@template    abc    }
/// Template text.
/// {@endtemplate}
''');

      expectNoWarnings();
      expect(doc, equals('{@macro abc}'));
    });

    test('processes @example with file', () async {
      projectRoot.getChildAssumingFile('abc.md').writeAsStringSync('''
```
Code snippet
```
''');
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@example abc}
///
/// End text.
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

```
Code snippet
```


End text.'''));
    });

    test('processes @example with a region', () async {
      projectRoot
          .getChildAssumingFile('abc-r.md')
          .writeAsStringSync('Markdown text.');
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@example region=r abc}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

Markdown text.'''));
    });

    test('adds language to processed @example with an extension and no lang',
        () async {
      projectRoot.getChildAssumingFile('abc.html.md').writeAsStringSync('''
```
Code snippet
```
''');
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@example abc.html}
///
/// End text.
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

```html
Code snippet
```


End text.'''));
    });

    test('adds language to processed @example with a lang and an extension',
        () async {
      projectRoot.getChildAssumingFile('abc.html.md').writeAsStringSync('''
```
Code snippet
```
''');
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@example abc.html lang=html}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

```html
Code snippet
```
'''));
    });

    test('adds language to processed @example with a lang and no extension',
        () async {
      projectRoot.getChildAssumingFile('abc.md').writeAsStringSync('''
```
Code snippet
```
''');
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@example abc lang=html}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

```html
Code snippet
```
'''));
    });

    test('processes @example with file, not found', () async {
      var doc = await libraryModel.processComment('''
/// {@example abc}
''');

      var abcPath = resourceProvider.pathContext.canonicalize(
          resourceProvider.pathContext.join(projectRoot.path, 'abc.md'));
      var libPathInWarning = resourceProvider.pathContext.join('lib', 'a.dart');
      expect(
          libraryModel,
          hasMissingExampleWarning(
              '$abcPath; path listed at $libPathInWarning'));
      // When the example path is invalid, the directive should be left in-place.
      expect(doc, equals('{@example abc}'));
    });

    test('processes @example with directories, not found', () async {
      var doc = await libraryModel.processComment('''
/// {@example abc/def/ghi}
''');
      var abcPath = resourceProvider.pathContext.canonicalize(resourceProvider
          .pathContext
          .join(projectRoot.path, 'abc', 'def', 'ghi.md'));
      var libPathInWarning = resourceProvider.pathContext.join('lib', 'a.dart');
      expect(
          libraryModel,
          hasMissingExampleWarning(
              '$abcPath; path listed at $libPathInWarning'));
      // When the example path is invalid, the directive should be left in-place.
      expect(doc, equals('{@example abc/def/ghi}'));
    });

    test('processes @example with a region, not found', () async {
      var doc = await libraryModel.processComment('''
/// {@example region=r abc}
''');
      var abcPath = resourceProvider.pathContext.canonicalize(
          resourceProvider.pathContext.join(projectRoot.path, 'abc-r.md'));
      var libPathInWarning = resourceProvider.pathContext.join('lib', 'a.dart');
      expect(
          libraryModel,
          hasMissingExampleWarning(
              '$abcPath; path listed at $libPathInWarning'));
      // When the example path is invalid, the directive should be left in-place.
      expect(doc, equals('{@example region=r abc}'));
    });

    test('leaves @inject-html unprocessed when disabled', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@inject-html}<script></script>{@end-inject-html}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

{@inject-html}<script></script>{@end-inject-html}'''));
    });

    test('leaves @tool unprocessed when disabled', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@tool date}{@end-tool}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.

{@tool date}{@end-tool}'''));
    });

    test('processes @inject-html when enabled', () async {
      packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: ['--inject-html']);
      libraryModel = packageGraph.defaultPackage.libraries.first;
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@inject-html}<script></script>{@end-inject-html}
''');

      expectNoWarnings();
      expect(doc, equals('''
Text.


<dartdoc-html>6829def5ec06d211fa90fe69a58213ae901f3ee4</dartdoc-html>
'''));
    });

    test('processes @youtube', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');

      expectNoWarnings();
      expect(
          doc,
          matches(RegExp(
              '^Text.\n\n+'
              r'<p style="position: relative;\s+padding-top: 200.00%;">\s*'
              r'<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0\?rel=0".*</iframe>\s*'
              '</p>\n\n+'
              r'End text.$',
              multiLine: true,
              dotAll: true)));
    });

    test('processes leading @youtube', () async {
      var doc = await libraryModel.processComment('''
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');

      expectNoWarnings();
      expect(
          doc,
          matches(RegExp(
              r'^<p style="position: relative;\s+padding-top: 200.00%;">\s*'
              r'<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0\?rel=0".*</iframe>\s*'
              '</p>\n\n+'
              r'End text.$',
              multiLine: true,
              dotAll: true)));
    });

    test('processes trailing @youtube', () async {
      var doc = await libraryModel.processComment('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
''');

      expectNoWarnings();
      expect(
          doc,
          matches(RegExp(
              '^Text.\n\n+'
              r'<p style="position: relative;\s+padding-top: 200.00%;">\s*'
              r'<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0\?rel=0".*</iframe>\s*'
              r'</p>$',
              multiLine: true,
              dotAll: true)));
    });

    test('warns when @youtube has less than 3 arguments', () async {
      await libraryModel.processComment(
          '/// {@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning('Invalid @youtube directive, '
              '"{@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
              'YouTube directives must be of the form '
              '"{@youtube WIDTH HEIGHT URL}"'));
    });

    test('warns when @youtube has more than 3 arguments', () async {
      await libraryModel.processComment(
          '/// {@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning('Invalid @youtube directive, '
              '"{@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
              'YouTube directives must be of the form '
              '"{@youtube WIDTH HEIGHT URL}"'));
    });

    test('warns when @youtube has a malformed width', () async {
      await libraryModel.processComment(
          '/// {@youtube 100px 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'A @youtube directive has an invalid width, "100px". '
              'The width must be a positive integer.'));
    });

    test('warns when @youtube has a negative width', () async {
      await libraryModel.processComment(
          '/// {@youtube -100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'The {@youtube ...} directive was called with invalid '
              'parameters. FormatException: Could not find an option with '
              'short name "-1".'));
    });

    test('warns when @youtube has a malformed height', () async {
      await libraryModel.processComment(
          '/// {@youtube 100 200px https://www.youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'A @youtube directive has an invalid height, "200px". The height '
              'must be a positive integer.'));
    });

    test('warns when @youtube has a negative height', () async {
      await libraryModel.processComment(
          '/// {@youtube 100 -200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning(
              'The {@youtube ...} directive was called with invalid '
              'parameters. FormatException: Could not find an option with '
              'short name "-2".'));
    });

    test('warns when @youtube has an invalid URL', () async {
      await libraryModel.processComment(
          '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0}');

      expect(
          libraryModel,
          hasInvalidParameterWarning('A @youtube directive has an invalid URL: '
              '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0". Supported '
              'YouTube URLs have the following format: '
              'https://www.youtube.com/watch?v=oHg5SJYRHA0.'));
    });

    test('warns when @youtube has a URL with extra query parameters', () async {
      await libraryModel.processComment(
          '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1}');

      expect(
          libraryModel,
          hasInvalidParameterWarning('A @youtube directive has an invalid URL: '
              '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1". '
              'Supported YouTube URLs have the following format: '
              'https://www.youtube.com/watch?v=oHg5SJYRHA0.'));
    });
  }, onPlatform: {
    'windows': Skip('These tests do not work on Windows (#2446)')
  });

// TODO(srawlins): More unit tests: @example with `config.examplePathPrefix`,
// @tool.
}

class _HasWarning extends Matcher {
  final PackageWarning kind;

  final String message;

  _HasWarning(this.kind, this.message);

  @override
  bool matches(dynamic actual, Map<Object, Object> matchState) {
    if (actual is ModelElement) {
      return actual.packageGraph.packageWarningCounter
          .hasWarning(actual, kind, message);
    } else {
      return false;
    }
  }

  @override
  Description describe(Description description) =>
      description.add('Library to be warned with $kind and message:\n$message');

  @override
  Description describeMismatch(dynamic actual, Description mismatchDescription,
      Map<Object, Object> matchState, bool verbose) {
    if (actual is ModelElement) {
      var warnings = actual
          .packageGraph.packageWarningCounter.countedWarnings[actual.element];
      return mismatchDescription.add('has warnings: $warnings');
    } else {
      return mismatchDescription.add('is a ${actual.runtimeType}');
    }
  }
}
