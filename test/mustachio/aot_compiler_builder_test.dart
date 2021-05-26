// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout.factor(4)
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import '../../tool/mustachio/builder.dart';
import 'builder_test_base.dart';

void main() {
  InMemoryAssetWriter writer;

  Future<LibraryElement> resolveGeneratedLibrary(
      InMemoryAssetWriter writer) async {
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var writtenStrings = writer.assets
        .map((id, content) => MapEntry(id.toString(), utf8.decode(content)));
    return await resolveSources(writtenStrings,
        (Resolver resolver) => resolver.libraryFor(rendererAsset));
  }

  Future<void> testMustachioBuilder(
    String sourceLibraryContent, {
    String libraryFrontMatter = libraryFrontMatter,
    Map<String, String> additionalAssets,
  }) async {
    sourceLibraryContent = '''
$libraryFrontMatter
$sourceLibraryContent
''';
    await testBuilder(
      mustachioBuilder(BuilderOptions({})),
      {
        ...annotationsAsset,
        'foo|lib/foo.dart': sourceLibraryContent,
        'foo|lib/templates/html/foo.html': 'EMPTY',
        'foo|lib/templates/md/foo.md': 'EMPTY',
        'foo|lib/templates/html/bar.html': 'EMPTY',
        'foo|lib/templates/md/bar.md': 'EMPTY',
        ...?additionalAssets,
      },
      writer: writer,
    );
  }

  setUp(() {
    writer = InMemoryAssetWriter();
  });

  test('builds renderers from multiple annotations', () async {
    await testMustachioBuilder(
      '''
class Foo {}
class Bar {}
class Baz {}
''',
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
library foo;
import 'package:mustachio/annotations.dart';
''',
      additionalAssets: {
        'foo|lib/templates/html/foo.html': '{{ >foo_header }}',
        'foo|lib/templates/html/_foo_header.html': 'EMPTY',
      },
    );
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('renderFoo'), isNotNull);
    expect(renderersLibrary.getTopLevelFunction('renderBar'), isNotNull);
    expect(
        renderersLibrary.getTopLevelFunction('_renderFoo_partial_foo_header_0'),
        isNotNull);
  });

  test('builds a public API render function', () async {
    writer = InMemoryAssetWriter();
    await testMustachioBuilder('''
class Foo<T> {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
library foo;
import 'package:mustachio/annotations.dart';
''');
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]);
    expect(generatedContent, contains('String renderFoo<T>(Foo<T> context0)'));
  });

  test('builds a private render function for a partial', () async {
    writer = InMemoryAssetWriter();
    await testMustachioBuilder(
      '''
class Foo<T> {}
''',
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
library foo;
import 'package:mustachio/annotations.dart';
''',
      additionalAssets: {
        'foo|lib/templates/html/foo.html': '{{ >foo_header }}',
        'foo|lib/templates/html/_foo_header.html': 'EMPTY',
      },
    );
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]);
    expect(generatedContent,
        contains('String _renderFoo_partial_foo_header_0<T>(Foo<T> context0)'));
  });

  test('builds a renderer for a generic, bounded type', () async {
    await testMustachioBuilder('''
class Foo<T extends num> {}
class Bar {}
class Baz {}
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    var fooRenderFunction = renderersLibrary.getTopLevelFunction('renderFoo');
    expect(fooRenderFunction.typeParameters, hasLength(1));
    var fBound = fooRenderFunction.typeParameters.single.bound;
    expect(fBound.getDisplayString(withNullability: false), equals('num'));
  });
}
