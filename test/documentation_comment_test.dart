// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'documentation_comment_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DocumentationCommentTest);
  });
}

@reflectiveTest
class DocumentationCommentTest extends DocumentationCommentTestBase {
  void test_removesTripleSlashes() async {
    await writePackageWithCommentedLibrary('''
/// Text.
/// More text.
''');
    var doc = libraryModel.documentation;

    expect(doc, equals('''
Text.
More text.'''));
  }

  void test_removesSpaceAfterTripleSlashes() async {
    await writePackageWithCommentedLibrary('''
///  Text.
///    More text.
''');
    var doc = libraryModel.documentation;

    // TODO(srawlins): Actually, the three spaces before 'More' is perhaps not
    // the best fit. Should it only be two, to match the indent from the first
    // line's "Text"?
    expect(doc, equals('''
Text.
   More text.'''));
  }

  void test_leavesBlankLines() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// More text.
''');
    var doc = libraryModel.documentation;

    expect(doc, equals('''
Text.

More text.'''));
  }

  void test_processesAnimationDirective() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    var doc = libraryModel.documentation;

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
    await writePackageWithCommentedLibrary('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, contains('<video id="animation_1"'));
  }

  void test_rendersNamedAnimation() async {
    await writePackageWithCommentedLibrary('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=namedAnimation}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimation_outOfOrder() async {
    await writePackageWithCommentedLibrary('''
/// First line.
///
/// {@animation 100 200 id=namedAnimation http://host/path/to/video.mp4}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimationWithDoubleQuotes() async {
    await writePackageWithCommentedLibrary('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id="namedAnimation"}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersNamedAnimationWithSingleQuotes() async {
    await writePackageWithCommentedLibrary('''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id='namedAnimation'}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, contains('<video id="namedAnimation"'));
  }

  void test_rendersMultipleAnimationsUsingUniqueIds() async {
    await writePackageWithCommentedLibraries([
      (
        'a.dart',
        '''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
/// {@animation 100 200 http://host/path/to/video2.mp4}
''',
      ),
      // A second element with unnamed animations requires unique IDs as well.
      (
        'b.dart',
        '''
/// First line.
///
/// {@animation 100 200 http://host/path/to/video.mp4}
/// {@animation 100 200 http://host/path/to/video2.mp4}
''',
      ),
    ]);
    var docA = await libraryModel.processComment();
    var docB = packageGraph.defaultPackage.libraries[1].documentation;

    expectNoWarnings();
    expect(docA, contains('<video id="animation_3"'));
    expect(docA, contains('<video id="animation_4"'));
    expect(docB, contains('<video id="animation_1"'));
    expect(docB, contains('<video id="animation_2"'));
  }

  void test_docImport() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// @docImport 'dart:async' as async;
///
/// End text.
''');
    var doc = libraryModel.documentation;

    expect(doc, equals('''
Text.



End text.'''));
  }

  void test_docImport_onlyLine() async {
    await writePackageWithCommentedLibrary('''
/// @docImport 'dart:async' as async;
''');
    var doc = libraryModel.documentation;

    expect(doc, equals(''));
  }

  void test_docImport_onlyLine_moreWhitespace() async {
    await writePackageWithCommentedLibrary('''
///   @docImport   'dart:async'   as   async;
''');
    var doc = libraryModel.documentation;

    expect(doc, equals(''));
  }

  void test_docImport_consecutiveLines() async {
    await writePackageWithCommentedLibrary('''
/// @docImport 'dart:async' as async;
/// @docImport 'dart:isolate' as isolate;
/// @docImport 'dart:math' as math;
''');
    var doc = libraryModel.documentation;

    expect(doc, equals(''));
  }

  void test_docImport_multipleLines() async {
    await writePackageWithCommentedLibrary('''
/// One.
/// @docImport 'dart:async' as async;
/// Two.
/// @docImport 'dart:isolate' as isolate;
/// Three.
''');
    var doc = libraryModel.documentation;

    expect(doc, equals('''
One.

Two.

Three.'''));
  }

  void test_docImport_precedingText() async {
    await writePackageWithCommentedLibrary('''
// Copyright such-and-such.

/// @docImport 'dart:async' as async;
''');
    var doc = libraryModel.documentation;

    expect(doc, equals(''));
  }

  void test_animationDirectiveHasFewerThanThreeArguments() async {
    await writePackageWithCommentedLibrary('''
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
          'HEIGHT URL [id=ID]}"'),
    );
  }

  void test_animationDirectiveHasMoreThanFourArguments() async {
    await writePackageWithCommentedLibrary('''
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
          'HEIGHT URL [id=ID]}"'),
    );
  }

  void test_animationDirectiveHasNonUniqueIdentifier() async {
    await writePackageWithCommentedLibrary('''
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
          '"barHerderAnimation". Animation identifiers must be unique.'),
    );
  }

  void test_animationDirectiveHasAnInvalidIdentifier() async {
    await writePackageWithCommentedLibrary('''
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
          'must not begin with a number.'),
    );
  }

  void test_animationDirectiveHasMalformedWidth() async {
    await writePackageWithCommentedLibrary('''
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
          '"100px". The width must be an integer.'),
    );
  }

  void test_animationDirectiveHasMalformedHeight() async {
    await writePackageWithCommentedLibrary('''
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
          '"200px". The height must be an integer.'),
    );
  }

  void test_animationDirectiveHasUnknownParameter() async {
    await writePackageWithCommentedLibrary('''
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
          'parameters. FormatException: Could not find an option named'),
    );
  }

  void test_processesTemplateDirective() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
///
/// End text.
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@macro abc}

End text.'''));
  }

  void test_processesLeadingTemplateDirective() async {
    await writePackageWithCommentedLibrary('''
/// {@template abc}
/// Template text.
/// {@endtemplate}
///
/// End text.
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
{@macro abc}

End text.'''));
  }

  void test_processesTrailingTemplateDirective() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@macro abc}'''));
  }

  void test_processesTemplateDirectiveWithoutBlankLineFollowing() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
/// End text.
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@macro abc}
End text.'''));
  }

  void test_allowsWhitespaceAroundTemplateDirectiveName() async {
    await writePackageWithCommentedLibrary('''
/// {@template    abc    }
/// Template text.
/// {@endtemplate}
''');
    var doc = await libraryModel.processComment();

    expectNoWarnings();
    expect(doc, equals('{@macro abc}'));
  }

  void test_leavesInjectHtmlDirectiveUnprocessedWhenDisabled() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@inject-html}<script></script>{@end-inject-html}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@inject-html}<script></script>{@end-inject-html}'''));
  }

  void test_leavesToolUnprocessedWhenDisabled() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@tool date}{@end-tool}
''');
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, equals('''
Text.

{@tool date}{@end-tool}'''));
  }

  void test_processesInjectHtmlDirectiveWhenEnabled() async {
    await writePackageWithCommentedLibrary(
      additionalArguments: ['--inject-html'],
      '''
/// Text.
///
/// {@inject-html}<script></script>{@end-inject-html}
''',
    );
    libraryModel = packageGraph.defaultPackage.libraries.first;
    var doc = libraryModel.documentation;

    expectNoWarnings();
    expect(doc, equals('''
Text.


<dartdoc-html>6829def5ec06d211fa90fe69a58213ae901f3ee4</dartdoc-html>
'''));
  }

  void test_processesYoutubeDirective() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');
    var doc = libraryModel.documentation;

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
    await writePackageWithCommentedLibrary('''
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');
    var doc = libraryModel.documentation;

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
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
''');
    var doc = libraryModel.documentation;

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
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning('Invalid @youtube directive, '
          '"{@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
          'YouTube directives must be of the form '
          '"{@youtube WIDTH HEIGHT URL}"'),
    );
  }

  void test_youtubeDirectiveHasMoreThanThreeArguments() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning('Invalid @youtube directive, '
          '"{@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
          'YouTube directives must be of the form '
          '"{@youtube WIDTH HEIGHT URL}"'),
    );
  }

  void test_youtubeDirectiveHasMalformedWidth() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100px 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning(
          'A @youtube directive has an invalid width, "100px". '
          'The width must be a positive integer.'),
    );
  }

  void test_youtubeDirectiveHasNegativeWidth() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube -100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning(
          'The {@youtube ...} directive was called with invalid '
          'parameters. FormatException: Could not find an option with '
          'short name "-1".'),
    );
  }

  void test_youtubeDirectiveHasMalformedHeight() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100 200px https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning(
          'A @youtube directive has an invalid height, "200px". The height '
          'must be a positive integer.'),
    );
  }

  void test_youtubeDirectiveHasNegativeHeight() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100 -200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning(
          'The {@youtube ...} directive was called with invalid '
          'parameters. FormatException: Could not find an option with '
          'short name "-2".'),
    );
  }

  void test_youtubeDirectiveHasInvalidUrl() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0}');

    expect(
      libraryModel,
      hasInvalidParameterWarning('A @youtube directive has an invalid URL: '
          '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0". Supported '
          'YouTube URLs have the following format: '
          'https://www.youtube.com/watch?v=oHg5SJYRHA0.'),
    );
  }

  void test_youtubeDirectiveHasUrlWithExtraQueryParameters() async {
    await writePackageWithCommentedLibrary(
        '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1}');

    expect(
      libraryModel,
      hasInvalidParameterWarning('A @youtube directive has an invalid URL: '
          '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1". '
          'Supported YouTube URLs have the following format: '
          'https://www.youtube.com/watch?v=oHg5SJYRHA0.'),
    );
  }

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
