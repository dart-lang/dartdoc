// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Directory;

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  _Processor processor;
  setUp(() {
    processor = _Processor(_FakeDartdocOptionContext());
    processor.href = '/project/a.dart';
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

  // TODO(srawlins): More unit tests: @example, @youtube, @animation,
  // @inject-html, @tool.
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
  String href;

  _Processor(this.config)
      : package = _FakePackage(),
        packageGraph = _MockPackageGraph() {
    throwOnMissingStub(packageGraph);
    when(packageGraph.addMacro(any, any)).thenReturn(null);
  }
}

class _FakeDirectory extends Fake implements Directory {
  @override
  final String path;

  _FakeDirectory() : path = '/project';
}

class _FakePackage extends Fake implements Package {
  @override
  final PackageMeta packageMeta;

  _FakePackage() : packageMeta = _FakePackageMeta();
}

class _FakePackageMeta extends Fake implements PackageMeta {
  @override
  final Directory dir;

  _FakePackageMeta() : dir = _FakeDirectory();
}

class _FakeDartdocOptionContext extends Fake implements DartdocOptionContext {
  @override
  final bool allowTools;

  @override
  final bool injectHtml;

  _FakeDartdocOptionContext({this.allowTools = false, this.injectHtml = false});
}

class _MockPackageGraph extends Mock implements PackageGraph {}
