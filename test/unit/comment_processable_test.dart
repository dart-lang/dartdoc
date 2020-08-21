// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

final _projectRoot = p.join('/', 'project');
final _aLibPath = p.join(_projectRoot, 'a.dart');

void main() {
  _Processor processor;
  setUp(() {
    processor = _Processor(_FakeDartdocOptionContext());
    processor.href = _aLibPath;
  });

  test('removes triple slashes', () async {
    var doc = await processor.processComment('''
/// Text.
/// More text.
''');
    expect(doc, equals('''
Text.
More text.'''));
  });

  test('removes space after triple slashes', () async {
    var doc = await processor.processComment('''
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
    var doc = await processor.processComment('''
/// Text.
///
/// More text.
''');
    expect(doc, equals('''
Text.

More text.'''));
  });

  test('processes @animation', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    expect(doc, equals('''
Text.

<!-- render -->

End text.'''));
  });

  test('warns when @animation has fewer than 3 arguments', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'Invalid @animation directive, "{@animation 100 '
                'http://host/path/to/video.mp4 id=barHerderAnimation}"\n'
                'Animation directives must be of the form "{@animation WIDTH '
                'HEIGHT URL [id=ID]}"'))
        .called(1);
  });

  test('warns when @animation has more than 4 arguments', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 200 300 400 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message:
                'Invalid @animation directive, "{@animation 100 200 300 400 '
                'http://host/path/to/video.mp4 id=barHerderAnimation}"\n'
                'Animation directives must be of the form "{@animation WIDTH '
                'HEIGHT URL [id=ID]}"'))
        .called(1);
  });

  test('warns when @animation has more than 4 arguments', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 200 300 400 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message:
                'Invalid @animation directive, "{@animation 100 200 300 400 '
                'http://host/path/to/video.mp4 id=barHerderAnimation}"\n'
                'Animation directives must be of the form "{@animation WIDTH '
                'HEIGHT URL [id=ID]}"'))
        .called(1);
  });

  test('warns when @animation has a non-unique identifier', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=barHerderAnimation}
/// {@animation 100 200 http://host/path/to/video.mpg id=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'An animation has a non-unique identifier, '
                '"barHerderAnimation". Animation identifiers must be unique.'))
        .called(1);
  });

  test('warns when @animation has an invalid identifier', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 id=not-valid}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'An animation has an invalid identifier, "not-valid". The '
                'identifier can only contain letters, numbers and underscores, and '
                'must not begin with a number.'))
        .called(1);
  });

  test('warns when @animation has a malformed width', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100px 200 http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'An animation has an invalid width (barHerderAnimation), '
                '"100px". The width must be an integer.'))
        .called(1);
  });

  test('warns when @animation has a malformed height', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 200px http://host/path/to/video.mp4 id=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'An animation has an invalid height (barHerderAnimation), '
                '"200px". The height must be an integer.'))
        .called(1);
  });

  test('warns when @animation has an unknown parameter', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation 100 200 http://host/path/to/video.mp4 name=barHerderAnimation}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'The {@animation ...} directive was called with invalid '
                'parameters. FormatException: Could not find an option named '
                '"name".'))
        .called(1);
  });

  test('warns when @animation uses the deprecated syntax', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment('''
/// Text.
///
/// {@animation barHerderAnimation 100 200 http://host/path/to/video.mp4}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.deprecated,
            message: 'Deprecated form of @animation directive, "{@animation '
                'barHerderAnimation 100 200 http://host/path/to/video.mp4}"\n'
                'Animation directives are now of the form "{@animation WIDTH '
                'HEIGHT URL [id=ID]}" (id is an optional parameter)'))
        .called(1);
  });

  test('processes @template', () async {
    var doc = await processor.processComment('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
///
/// End text.
''');
    expect(doc, equals('''
Text.

{@macro abc}

End text.'''));
    verify(processor.packageGraph.addMacro('abc', 'Template text.')).called(1);
  });

  test('processes leading @template', () async {
    var doc = await processor.processComment('''
/// {@template abc}
/// Template text.
/// {@endtemplate}
///
/// End text.
''');
    expect(doc, equals('''
{@macro abc}

End text.'''));
    verify(processor.packageGraph.addMacro('abc', 'Template text.')).called(1);
  });

  test('processes trailing @template', () async {
    var doc = await processor.processComment('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
''');
    expect(doc, equals('''
Text.

{@macro abc}'''));
    verify(processor.packageGraph.addMacro('abc', 'Template text.')).called(1);
  });

  test('processes @template w/o blank line following', () async {
    var doc = await processor.processComment('''
/// Text.
///
/// {@template abc}
/// Template text.
/// {@endtemplate}
/// End text.
''');
    expect(doc, equals('''
Text.

{@macro abc}
End text.'''));
    verify(processor.packageGraph.addMacro('abc', 'Template text.')).called(1);
  });

  test('allows whitespace around @template name', () async {
    var doc = await processor.processComment('''
/// {@template    abc    }
/// Template text.
/// {@endtemplate}
''');
    expect(doc, equals('''
{@macro abc}'''));
    verify(processor.packageGraph.addMacro('abc', 'Template text.')).called(1);
  });

  test('processes @example with file-not-found', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// Text.
///
/// {@example abc}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.missingExampleFile,
            message:
                '${p.canonicalize(p.join(_projectRoot, 'abc.md'))}; path listed at a.dart'))
        .called(1);
    // When the example path is invalid, the directive should be left in-place.
    expect(doc, equals('''
Text.

{@example abc}

End text.'''));
  });

  test('processes @example with directories', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// Text.
///
/// {@example abc/def/ghi}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.missingExampleFile,
            message:
                '${p.join(_projectRoot, 'abc', 'def', 'ghi.md')}; path listed at a.dart'))
        .called(1);
    // When the example path is invalid, the directive should be left in-place.
    expect(doc, equals('''
Text.

{@example abc/def/ghi}

End text.'''));
  });

  test('processes @example with a region', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// Text.
///
/// {@example region=r abc}
///
/// End text.
''');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.missingExampleFile,
            message:
                '${p.join(_projectRoot, 'abc-r.md')}; path listed at a.dart'))
        .called(1);
    // When the example path is invalid, the directive should be left in-place.
    expect(doc, equals('''
Text.

{@example region=r abc}

End text.'''));
  });

  // TODO(srawlins): Test @example `lang=` and successful file resolution when
  // we abstract the file system.

  test('processes @youtube', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');
    expect(doc, equals('''
Text.

<!-- render -->

End text.'''));
  });

  test('processes leading @youtube', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
///
/// End text.
''');
    expect(doc, equals('''
<!-- render -->

End text.'''));
  });

  test('processes trailing @youtube', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    var doc = await processor.processComment('''
/// Text.
///
/// {@youtube 100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}
''');
    expect(doc, equals('''
Text.

<!-- render -->'''));
  });

  test('warns when @youtube has less than 3 arguments', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'Invalid @youtube directive, '
                '"{@youtube 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
                'YouTube directives must be of the form '
                '"{@youtube WIDTH HEIGHT URL}"'))
        .called(1);
  });

  test('warns when @youtube has more than 3 arguments', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'Invalid @youtube directive, '
                '"{@youtube 100 200 300 https://www.youtube.com/watch?v=oHg5SJYRHA0}"\n'
                'YouTube directives must be of the form '
                '"{@youtube WIDTH HEIGHT URL}"'))
        .called(1);
  });

  test('warns when @youtube has a malformed width', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100px 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph
            .warnOnElement(processor, PackageWarning.invalidParameter,
                message: 'A @youtube directive has an invalid width, "100px". '
                    'The width must be a positive integer.'))
        .called(1);
  });

  test('warns when @youtube has a negative width', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube -100 200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'The {@youtube ...} directive was called with invalid '
                'parameters. FormatException: Could not find an option with '
                'short name "-1".'))
        .called(1);
  });

  test('warns when @youtube has a malformed height', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100 200px https://www.youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph
            .warnOnElement(processor, PackageWarning.invalidParameter,
                message: 'A @youtube directive has an invalid height, "200px". '
                    'The height must be a positive integer.'))
        .called(1);
  });

  test('warns when @youtube has a negative height', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100 -200 https://www.youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'The {@youtube ...} directive was called with invalid '
                'parameters. FormatException: Could not find an option with '
                'short name "-2".'))
        .called(1);
  });

  test('warns when @youtube has an invalid URL', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0}');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid URL: '
                '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0". Supported '
                'YouTube URLs have the following format: '
                'https://www.youtube.com/watch?v=oHg5SJYRHA0.'))
        .called(1);
  });

  test('warns when @youtube has a URL with extra query parameters', () async {
    processor.element = _FakeElement(source: _FakeSource(fullName: _aLibPath));
    await processor.processComment(
        '/// {@youtube 100 200 https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1}');
    verify(processor.packageGraph.warnOnElement(
            processor, PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid URL: '
                '"https://www.not-youtube.com/watch?v=oHg5SJYRHA0&a=1". Supported '
                'YouTube URLs have the following format: '
                'https://www.youtube.com/watch?v=oHg5SJYRHA0.'))
        .called(1);
  });

  // TODO(srawlins): More unit tests: @inject-html, @tool.
}

/// In order to mix in [CommentProcessable], we must first implement
/// the super-class constraints.
abstract class __Processor extends Fake
    implements Documentable, Warnable, Locatable, SourceCodeMixin {}

/// A simple comment processor for testing [CommentProcessable].
class _Processor extends __Processor with CommentProcessable {
  @override
  final _FakeDartdocOptionContext config;

  @override
  final _FakePackage package;

  @override
  final _MockPackageGraph packageGraph;

  @override
  final _MockModelElementRenderer modelElementRenderer;

  @override
  String href;

  @override
  Element element;

  _Processor(this.config)
      : package = _FakePackage(),
        packageGraph = _MockPackageGraph(),
        modelElementRenderer = _MockModelElementRenderer() {
    throwOnMissingStub(packageGraph);
    when(packageGraph.addMacro(any, any)).thenReturn(null);
    when(packageGraph.warnOnElement(this, any, message: anyNamed('message')))
        .thenReturn(null);
    when(modelElementRenderer.renderYoutubeUrl(any, any))
        .thenReturn('<!-- render -->');
    when(modelElementRenderer.renderAnimation(any, any, any, any, any))
        .thenReturn('<!-- render -->');
    when(packageGraph.resourceProvider).thenReturn(MemoryResourceProvider());
  }

  @override
  void warn(PackageWarning warning,
          {String message, Iterable<Locatable> referredFrom}) =>
      packageGraph.warnOnElement(this, warning,
          message: message, referredFrom: referredFrom);
}

class _FakeFolder extends Fake implements Folder {
  @override
  final String path;

  _FakeFolder() : path = _projectRoot;
}

class _MockModelElementRenderer extends Mock implements ModelElementRenderer {}

class _FakePackage extends Fake implements Package {
  @override
  final PackageMeta packageMeta;

  @override
  final Map<String, Set<String>> usedAnimationIdsByHref = {};

  _FakePackage() : packageMeta = _FakePackageMeta();
}

class _FakePackageMeta extends Fake implements PackageMeta {
  @override
  final Folder dir;

  _FakePackageMeta() : dir = _FakeFolder();
}

class _FakeElement extends Fake implements Element {
  @override
  final Source source;

  _FakeElement({this.source});
}

class _FakeSource extends Fake implements Source {
  @override
  final String fullName;

  _FakeSource({this.fullName});
}

class _FakeDartdocOptionContext extends Fake implements DartdocOptionContext {
  @override
  final bool allowTools;

  @override
  final bool injectHtml;

  @override
  final String examplePathPrefix = null;

  _FakeDartdocOptionContext({this.allowTools = false, this.injectHtml = false});
}

class _MockPackageGraph extends Mock implements PackageGraph {}
