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

  late Folder projectRoot;
  late PackageGraph packageGraph;
  late ModelElement libraryModel;

  void expectNoWarnings() {
    expect(packageGraph.packageWarningCounter.countedWarnings, isEmpty);
    expect(packageGraph.packageWarningCounter.hasWarnings, isFalse);
  }

  Future<void> writeLibraryWithComment(String comment) async {
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
$comment
library;
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
    await writeLibraryWithComment('''
/// Text.
/// More text.
''');
    var doc = await libraryModel.processComment();

    expect(doc, equals('''
Text.
More text.'''));
  }

  void test_removesSpaceAfterTripleSlashes() async {
    await writeLibraryWithComment('''
///  Text.
///    More text.
''');
    var doc = await libraryModel.processComment();

    // TODO(srawlins): Actually, the three spaces before 'More' is perhaps not
    // the best fit. Should it only be two, to match the indent from the first
    // line's "Text"?
    expect(doc, equals('''
Text.
   More text.'''));
  }

  void test_leavesBlankLines() async {
    await writeLibraryWithComment('''
/// Text.
///
/// More text.
''');
    var doc = await libraryModel.processComment();

    expect(doc, equals('''
Text.

More text.'''));
  }

  void test_processesAnimationDirective() async {
    await writeLibraryWithComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
Text.


<div style="position: relative;">
  <div id="barHerderAnimation_play_button_"
       onclick="var barHerderAnimation = document.getElementById('barHerderAnimation');
                if (barHerderAnimation.paused) {
                  barHerderAnimation.play();
                  this.style.display = 'none';
                } else {
                  barHerderAnimation.pause();
                  this.style.display = 'block';
                }"
       style="position:absolute;
              width:100px;
              height:200px;
              z-index:100000;
              background-position: center;
              background-repeat: no-repeat;
              background-image: url(static-assets/play_button.svg);">
  </div>
  <video id="barHerderAnimation"
         style="width:100px; height:200px;"
         onclick="var barHerderAnimation_play_button_ = document.getElementById('barHerderAnimation_play_button_');
                  if (this.paused) {
                    this.play();
                    barHerderAnimation_play_button_.style.display = 'none';
                  } else {
                    this.pause();
                    barHerderAnimation_play_button_.style.display = 'block';
                  }" loop>
    <source src="http://host/path/to/video.mp4" type="video/mp4"/>
  </video>
</div>



End text.'''));
  }

  void test_rendersUnnamedAnimation() async {
    await writeLibraryWithComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, contains('<video id="animation_1"'));
  }

  void test_rendersNamedAnimation() async {
    await writeLibraryWithComment('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=namedAnimation}
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimation_outOfOrder() async {
    await writeLibraryWithComment('''
/// First line.
///
/// {@animation 100 200 id=namedAnimation http://host/path/to/video.mp4}
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  /*void test_rendersNamedAnimationWithDoubleQuotes() async {
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
  }*/

  void solo_test_docImport() async {
    await writeLibraryWithComment('''
/// Text.
///
/// @docImport 'dart:async' as async;
///
/// End text.
''');
    var doc = await libraryModel.processComment();

    expect(doc, contains('<video id="animation_4"'));
  }

  /*void test_animationDirectiveHasFewerThanThreeArguments() async {
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
  }*/

  Matcher hasDeprecatedWarning(String message) =>
      _HasWarning(PackageWarning.deprecated, message);

  Matcher hasInvalidParameterWarning(String message) =>
      _HasWarning(PackageWarning.invalidParameter, message);

// TODO(srawlins): More unit tests: @tool.
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
      if (warnings == null) {
        return mismatchDescription.add('has no warnings');
      }
      if (warnings.length == 1) {
        var kind = warnings.keys.first;
        return mismatchDescription
            .add('has one $kind warnings: ${warnings[kind]}');
      }

      return mismatchDescription.add('has warnings: $warnings');
    }

    return mismatchDescription.add('is a ${actual.runtimeType}');
  }
}
