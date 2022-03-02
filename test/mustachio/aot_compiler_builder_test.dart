// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout.factor(4)
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'builder_test_base.dart';

void main() {
  late InMemoryAssetWriter writer;

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
class Foo {
  String s1 = 'hello';
}
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
class Foo<T> {
  String s1 = 'hello';
}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
library foo;
import 'package:mustachio/annotations.dart';
''');
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    expect(
        generatedContent, contains('String renderFoo<T>(_i1.Foo<T> context0)'));
  });

  test('builds a private render function for a partial', () async {
    await testMustachioBuilder(
      writer,
      '''
class Foo<T> {
  String s1 = 'hello';
}
''',
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
library foo;
import 'package:mustachio/annotations.dart';
''',
      additionalAssets: {
        'foo|lib/templates/html/foo.html': '{{ >foo_header }}',
        'foo|lib/templates/html/_foo_header.html': 's1 is {{ s1 }}',
      },
    );
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    expect(
        generatedContent,
        contains(
            'String _renderFoo_partial_foo_header_0<T>(_i1.Foo<T> context0)'));
  });

  test('builds a renderer for a generic, bounded type', () async {
    await testMustachioBuilder(writer, '''
class Foo<T extends num> {
  String s1 = 'hello';
}
class Bar {}
class Baz {}
''');
    var renderersLibrary = await resolveGeneratedLibrary();

    var fooRenderFunction = renderersLibrary.getTopLevelFunction('renderFoo')!;
    expect(fooRenderFunction.typeParameters, hasLength(1));
    var fBound = fooRenderFunction.typeParameters.single.bound!;
    expect(fBound.getDisplayString(withNullability: false), equals('num'));
  });

  test('deduplicates partials which share context type LUB', () async {
    await testMustachioBuilder(
      writer,
      '''
abstract class Base {
  String get s1;
}

class Foo implements Base {
  @override
  String s1 = 'F';
}

class Bar implements Base {
  @override
  String s1 = 'B';
}
''',
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
library foo;
import 'package:mustachio/annotations.dart';
''',
      additionalAssets: {
        'foo|lib/templates/html/foo.html': '{{ >base }}',
        'foo|lib/templates/html/bar.html': '{{ >base }}',
        'foo|lib/templates/html/_base.html': 's1 is {{ s1 }}',
      },
    );
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    expect(
      generatedContent,
      contains('String _renderFoo_partial_base_0(_i1.Foo context0) =>\n'
          '    _deduplicated_lib_templates_html__base_html(context0);\n'),
    );
    expect(
      generatedContent,
      contains('String _renderBar_partial_base_0(_i1.Bar context0) =>\n'
          '    _deduplicated_lib_templates_html__base_html(context0);\n'),
    );
    expect(
      generatedContent,
      contains('String _deduplicated_lib_templates_html__base_html('),
    );
  });

  test('does not deduplicate partials when attempting to do so throws',
      () async {
    await testMustachioBuilder(
      writer,
      '''
abstract class Base {}

class Foo implements Base {
  // Not part of the interface of [Base].
  String s1 = 'F';
}

class Bar implements Base {
  // Not part of the interface of [Base].
  String s1 = 'B';
}
''',
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
library foo;
import 'package:mustachio/annotations.dart';
''',
      additionalAssets: {
        'foo|lib/templates/html/foo.html': '{{ >base }}',
        'foo|lib/templates/html/bar.html': '{{ >base }}',
        'foo|lib/templates/html/_base.html': 's1 is {{ s1 }}',
      },
    );
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    expect(
      generatedContent,
      contains('String _renderFoo_partial_base_0(_i1.Foo context0) {'),
    );
    expect(
      generatedContent,
      contains('String _renderBar_partial_base_0(_i1.Bar context0) {'),
    );
  });
}
