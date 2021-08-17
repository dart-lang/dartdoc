// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

@Timeout.factor(4)
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'builder_test_base.dart';

void main() {
  InMemoryAssetWriter writer;

  Future<LibraryElement> resolveGeneratedLibrary() async {
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var writtenStrings = writer.assets
        .map((id, content) => MapEntry(id.toString(), utf8.decode(content)));
    return await resolveSources(writtenStrings,
        (Resolver resolver) => resolver.libraryFor(rendererAsset));
  }

  setUp(() {
    writer = InMemoryAssetWriter();
  });

  test('builds renderers from multiple annotations', () async {
    await testMustachioBuilder(
      writer,
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
    var renderersLibrary = await resolveGeneratedLibrary();

    expect(renderersLibrary.getTopLevelFunction('renderFoo'), isNotNull);
    expect(renderersLibrary.getTopLevelFunction('renderBar'), isNotNull);
    expect(
        renderersLibrary.getTopLevelFunction('_renderFoo_partial_foo_header_0'),
        isNotNull);
  }, timeout: Timeout.factor(2));

  test('builds a public API render function', () async {
    await testMustachioBuilder(writer, '''
class Foo<T> {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
library foo;
import 'package:mustachio/annotations.dart';
''');
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]);
    expect(
        generatedContent, contains('String renderFoo<T>(_i1.Foo<T> context0)'));
  });

  test('builds a private render function for a partial', () async {
    await testMustachioBuilder(
      writer,
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
    expect(
        generatedContent,
        contains(
            'String _renderFoo_partial_foo_header_0<T>(_i1.Foo<T> context0)'));
  });

  test('builds a renderer for a generic, bounded type', () async {
    await testMustachioBuilder(writer, '''
class Foo<T extends num> {}
class Bar {}
class Baz {}
''');
    var renderersLibrary = await resolveGeneratedLibrary();

    var fooRenderFunction = renderersLibrary.getTopLevelFunction('renderFoo');
    expect(fooRenderFunction.typeParameters, hasLength(1));
    var fBound = fooRenderFunction.typeParameters.single.bound;
    expect(fBound.getDisplayString(withNullability: false), equals('num'));
  });
}
