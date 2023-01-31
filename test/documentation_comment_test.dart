// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart' as utils;

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DocumentationCommentTest);
  });
}

@reflectiveTest
class DocumentationCommentTest extends DartdocTestBase {
  @override
  String get libraryName => 'my_library';

  Matcher hasInvalidParameterWarning(String message) =>
      _HasWarning(PackageWarning.invalidParameter, message);

  Matcher hasMissingExampleWarning(String message) =>
      _HasWarning(PackageWarning.missingExampleFile, message);

  late Folder projectRoot;
  late PackageGraph packageGraph;
  late ModelElement libraryModel;

  void expectNoWarnings() {
    expect(packageGraph.packageWarningCounter.hasWarnings, isFalse);
    expect(packageGraph.packageWarningCounter.countedWarnings, isEmpty);
  }

  @override
  Future<void> setUp() async {
    await super.setUp();

    projectRoot = utils.writePackage(
        'my_package', resourceProvider, packageConfigProvider);
    projectRoot
        .getChildAssumingFile('dartdoc_options.yaml')
        .writeAsStringSync('''
      dartdoc:
        warnings:
          - missing-code-block-language
      ''');

    projectRoot
        .getChildAssumingFolder('lib')
        .getChildAssumingFile('a.dart')
        .writeAsStringSync('''
/// Documentation comment.
int x = 1;
''');

    var optionSet = DartdocOptionRoot.fromOptionGenerators(
        'dartdoc', [createDartdocOptions], packageMetaProvider);
    optionSet.parseArguments([]);
    packageGraph = await utils.bootBasicPackage(
        projectRoot.path, packageMetaProvider, packageConfigProvider,
        additionalArguments: []);
    libraryModel = packageGraph.defaultPackage.libraries.first;
  }

  void test_removesTripleSlashes() async {
    var doc = await libraryModel.processComment('''
/// Text.
/// More text.
''');

    expect(doc, equals('''
Text.
More text.'''));
  }

  void test_removesSpaceAfterTripleSlashes() async {
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
  }

  void test_leavesBlankLines() async {
    var doc = await libraryModel.processComment('''
/// Text.
///
/// More text.
''');

    expect(doc, equals('''
Text.

More text.'''));
  }

  void test_unknownDirective() async {
    await libraryModel.processComment('''
/// Text.
///
/// {@marco name}
''');
    expect(
        packageGraph.packageWarningCounter.hasWarning(
            libraryModel, PackageWarning.unknownDirective, "'marco'"),
        isTrue);
  }

  void test_directiveWithWrongCase() async {
    await libraryModel.processComment('''
/// Text.
///
/// {@youTube url}
''');
    expect(
        packageGraph.packageWarningCounter.hasWarning(libraryModel,
            PackageWarning.unknownDirective, "'youTube' (use lowercase)"),
        isTrue);
  }

  void test_processesAanimationDirective() async {
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
  }

  void test_rendersUnnamedAnimation() async {
    var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
''');

    expectNoWarnings();
    expect(doc, contains('<video id="animation_1"'));
  }

  void test_rendersNamedAnimation() async {
    var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=namedAnimation}
''');

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimation_outOfOrder() async {
    var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 id=namedAnimation http://host/path/to/video.mp4}
''');

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimationWithDoubleQuotes() async {
    var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id="namedAnimation"}
''');

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimationWithSingleQuotes() async {
    var doc = await libraryModel.processComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id='namedAnimation'}
''');

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersMultipleAnimationsUsingUniqueIds() async {
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
  }

  void test_animationDirectiveHasFewerThanThreeArguments() async {
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
  }

  void test_animationDirectiveHasMoreThanFourArguments() async {
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
  }

  void test_animationDirectiveHasNonUniqueIdentifier() async {
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
        hasInvalidParameterWarning('An animation has a non-unique identifier, '
            '"barHerderAnimation". Animation identifiers must be unique.'));
  }

  void test_animationDirectiveHasAnInvalidIdentifier() async {
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
  }

  void test_animationDirectiveHasMalformedWidth() async {
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
  }

  void test_animationDirectiveHasMalformedHeight() async {
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
  }

  void test_animationDirectiveHasUnknownParameter() async {
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
  }

  void test_animationDirectiveUsesDeprecatedSyntax() async {
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
  }

  void test_processesTemplateDirective() async {
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
  }

  void test_processesLeadingTemplateDirective() async {
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
  }

  void test_processesTrailingTemplateDirective() async {
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
  }

  void test_processesTemplateDirectiveWithoutBlankLineFollowing() async {
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
  }

  void test_allowsWhitespaceAroundTemplateDirectiveName() async {
    var doc = await libraryModel.processComment('''
/// {@template    abc    }
/// Template text.
/// {@endtemplate}
''');

    expectNoWarnings();
    expect(doc, equals('{@macro abc}'));
  }

  void test_processesExampleDirectiveWithFile() async {
    projectRoot.getChildAssumingFile('abc.md').writeAsStringSync('''
```plaintext
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

```plaintext
Code snippet
```


End text.'''));
  }

  void test_processesExampleDirectiveWithRegion() async {
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
  }

  void test_addsLanguageToProcessedExampleWithExtensionAndNoLang() async {
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
  }

  void test_addsLanguageToProcessedExampleWithLangAndAnExtension() async {
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
  }

  void
      test_addsLanguageToProcessedExampleDirectiveWithLangAndNoExtension() async {
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
  }

  void test_processesExampleDirectiveWithFileNotFound() async {
    var doc = await libraryModel.processComment('''
/// {@example abc}
''');

    var abcPath = resourceProvider.pathContext.canonicalize(
        resourceProvider.pathContext.join(projectRoot.path, 'abc.md'));
    var libPathInWarning = resourceProvider.pathContext.join('lib', 'a.dart');
    expect(libraryModel,
        hasMissingExampleWarning('$abcPath; path listed at $libPathInWarning'));
    // When the example path is invalid, the directive should be left in-place.
    expect(doc, equals('{@example abc}'));
  }

  void test_processesExampleDirectiveWithDirectoriesNotFound() async {
    var doc = await libraryModel.processComment('''
/// {@example abc/def/ghi}
''');
    var abcPath = resourceProvider.pathContext.canonicalize(resourceProvider
        .pathContext
        .join(projectRoot.path, 'abc', 'def', 'ghi.md'));
    var libPathInWarning = resourceProvider.pathContext.join('lib', 'a.dart');
    expect(libraryModel,
        hasMissingExampleWarning('$abcPath; path listed at $libPathInWarning'));
    // When the example path is invalid, the directive should be left in-place.
    expect(doc, equals('{@example abc/def/ghi}'));
  }

  void test_processesExampleDirectiveWithRegionNotFound() async {
    var doc = await libraryModel.processComment('''
/// {@example region=r abc}
''');
    var abcPath = resourceProvider.pathContext.canonicalize(
        resourceProvider.pathContext.join(projectRoot.path, 'abc-r.md'));
    var libPathInWarning = resourceProvider.pathContext.join('lib', 'a.dart');
    expect(libraryModel,
        hasMissingExampleWarning('$abcPath; path listed at $libPathInWarning'));
    // When the example path is invalid, the directive should be left in-place.
    expect(doc, equals('{@example region=r abc}'));
  }

  void test_leavesInjectHtmlDirectiveUnprocessedWhenDisabled() async {
    var doc = await libraryModel.processComment('''
/// Text.
///
/// {@inject-html}<script></script>{@end-inject-html}
''');

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@inject-html}<script></script>{@end-inject-html}'''));
  }

  void test_leavesToolUnprocessedWhenDisabled() async {
    var doc = await libraryModel.processComment('''
/// Text.
///
/// {@tool date}{@end-tool}
''');

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@tool date}{@end-tool}'''));
  }

  void test_processesInjectHtmlDirectiveWhenEnabled() async {
    packageGraph = await utils.bootBasicPackage(
        projectRoot.path, packageMetaProvider, packageConfigProvider,
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
  }

  void test_processesYoutubeDirective() async {
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
      matches(
        RegExp(
          '^Text.\n\n+'
          r'<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0\?rel=0".*</iframe>\s*\n\n+'
          r'End text.$',
          multiLine: true,
          dotAll: true,
        ),
      ),
    );
  }

  void test_processesLeadingYoutubeDirective() async {
    var doc = await libraryModel.processComment('''
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');

    expectNoWarnings();
    expect(
      doc,
      matches(
        RegExp(
          r'<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0\?rel=0".*</iframe>\s*\n\n+'
          r'End text.$',
          multiLine: true,
          dotAll: true,
        ),
      ),
    );
  }

  void test_processesTrailingYoutubeDirective() async {
    var doc = await libraryModel.processComment('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
''');

    expectNoWarnings();
    expect(
      doc,
      matches(
        RegExp(
          '^Text.\n\n+'
          r'<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0\?rel=0".*</iframe>\s*$',
          multiLine: true,
          dotAll: true,
        ),
      ),
    );
  }

  void test_youtubeDirectiveHasLessThanThreeArguments() async {
    await libraryModel.processComment(
        '/// {@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning('Invalid @youtube directive, '
            '"{@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
            'YouTube directives must be of the form '
            '"{@youtube WIDTH HEIGHT URL}"'));
  }

  void test_youtubeDirectiveHasMoreThanThreeArguments() async {
    await libraryModel.processComment(
        '/// {@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning('Invalid @youtube directive, '
            '"{@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
            'YouTube directives must be of the form '
            '"{@youtube WIDTH HEIGHT URL}"'));
  }

  void test_youtubeDirectiveHasMalformedWidth() async {
    await libraryModel.processComment(
        '/// {@youtube 100px 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning(
            'A @youtube directive has an invalid width, "100px". '
            'The width must be a positive integer.'));
  }

  void test_youtubeDirectiveHasNegativeWidth() async {
    await libraryModel.processComment(
        '/// {@youtube -100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning(
            'The {@youtube ...} directive was called with invalid '
            'parameters. FormatException: Could not find an option with '
            'short name "-1".'));
  }

  void test_youtubeDirectiveHasMalformedHeight() async {
    await libraryModel.processComment(
        '/// {@youtube 100 200px https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning(
            'A @youtube directive has an invalid height, "200px". The height '
            'must be a positive integer.'));
  }

  void test_youtubeDirectiveHasNegativeHeight() async {
    await libraryModel.processComment(
        '/// {@youtube 100 -200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning(
            'The {@youtube ...} directive was called with invalid '
            'parameters. FormatException: Could not find an option with '
            'short name "-2".'));
  }

  void test_youtubeDirectiveHasInvalidUrl() async {
    await libraryModel.processComment(
        '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
        libraryModel,
        hasInvalidParameterWarning('A @youtube directive has an invalid URL: '
            '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0". Supported '
            'YouTube URLs have the following format: '
            'https://www.youtube.com/watch?v=oHg5SJYRHA0.'));
  }

  void test_youtubeDirectiveHasUrlWithExtraQueryParameters() async {
    await libraryModel.processComment(
        '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1}');

    expect(
        libraryModel,
        hasInvalidParameterWarning('A @youtube directive has an invalid URL: '
            '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1". '
            'Supported YouTube URLs have the following format: '
            'https://www.youtube.com/watch?v=oHg5SJYRHA0.'));
  }

  void test_fencedCodeBlockDoesNotSpecifyLanguage() async {
    await libraryModel.processComment('''
/// ```
/// void main() {}
/// ```
''');

    expect(
        packageGraph.packageWarningCounter.hasWarning(
            libraryModel,
            PackageWarning.missingCodeBlockLanguage,
            'A fenced code block in Markdown should have a language specified'),
        isTrue);
  }

  void test_squigglyFencedCodeBlockDoesNotSpecifyLanguage() async {
    await libraryModel.processComment('''
/// ~~~
/// void main() {}
/// ~~~
''');

    expect(
        packageGraph.packageWarningCounter.hasWarning(
            libraryModel,
            PackageWarning.missingCodeBlockLanguage,
            'A fenced code block in Markdown should have a language specified'),
        isTrue);
  }

  void test_fencedCodeBlockDoesSpecifyLanguage() async {
    await libraryModel.processComment('''
/// ```dart
/// void main() {}
/// ```
''');

    expect(
        packageGraph.packageWarningCounter.hasWarning(
            libraryModel,
            PackageWarning.missingCodeBlockLanguage,
            'A fenced code block in Markdown should have a language specified'),
        isFalse);
  }

  void test_fencedBlockIsNotClosed() async {
    await libraryModel.processComment('''
/// ```
/// A not closed fenced code block
''');

    expect(
        packageGraph.packageWarningCounter.hasWarning(
            libraryModel,
            PackageWarning.missingCodeBlockLanguage,
            'A fenced code block in Markdown should have a language specified'),
        isFalse);
  }
  //}, onPlatform: {
  //  'windows': Skip('These tests do not work on Windows (#2446)')
  //});

// TODO(srawlins): More unit tests: @example with `config.examplePathPrefix`,
// @tool.
}

class _HasWarning extends Matcher {
  final PackageWarning kind;

  final String message;

  _HasWarning(this.kind, this.message);

  @override
  bool matches(Object? actual, Map<Object?, Object?> matchState) {
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
  Description describeMismatch(Object? actual, Description mismatchDescription,
      Map<Object?, Object?> matchState, bool verbose) {
    if (actual is ModelElement) {
      var warnings = actual
          .packageGraph.packageWarningCounter.countedWarnings[actual.element];
      return mismatchDescription.add('has warnings: $warnings');
    } else {
      return mismatchDescription.add('is a ${actual.runtimeType}');
    }
  }
}
