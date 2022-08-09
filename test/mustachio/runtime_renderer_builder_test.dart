// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout.factor(2)
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'builder_test_base.dart';

void main() {
  late InMemoryAssetWriter writer;

  Future<LibraryElement> resolveGeneratedLibrary() async {
    var rendererAsset = AssetId('foo', 'lib/foo.runtime_renderers.dart');
    var writtenStrings = writer.assets
        .map((id, content) => MapEntry(id.toString(), utf8.decode(content)));
    return await resolveSources(writtenStrings,
        (Resolver resolver) => resolver.libraryFor(rendererAsset));
  }

  setUp(() {
    writer = InMemoryAssetWriter();
  });

  group('builds a renderer class', () {
    late final LibraryElement renderersLibrary;
    late final String generatedContent;

    // Builders are fairly expensive (about 4 seconds per `testBuilder` call),
    // so this [setUpAll] saves significant time over [setUp].
    setUpAll(() async {
      writer = InMemoryAssetWriter();
      await testMustachioBuilder(writer, '''
abstract class FooBase2<T> {
  T get generic;
}
abstract class FooBase<T extends Baz> extends FooBase2<T> {
  Bar get bar;
}
mixin Mix<E> on FooBase<Baz> {
  String get field => 'Mix.field';
}
abstract class Foo extends FooBase with Mix<int> {
  String s1 = "s1";
  bool b1 = false;
  List<int> l1 = [1, 2, 3];
}
class Bar {}
class Baz {}
''');
      renderersLibrary = await resolveGeneratedLibrary();
      var rendererAsset = AssetId('foo', 'lib/foo.runtime_renderers.dart');
      generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    });

    test('for a class which implicitly extends Object', () {
      // The renderer class for Foo
      expect(
          generatedContent,
          contains(
              'class _Renderer_FooBase<T extends Baz> extends RendererBase<FooBase<T>>'));
    });

    test('for Object', () {
      // The renderer class for Object
      expect(generatedContent,
          contains('class _Renderer_Object extends RendererBase<Object> {'));
    });

    test('for a class which is extended by a rendered class', () {
      // No render function is necessary.
      expect(renderersLibrary.getTopLevelFunction('_render_FooBase'), isNull);
      expect(renderersLibrary.getClass('_Renderer_FooBase'), isNotNull);
    });

    test('for a class which is mixed into a rendered class', () {
      // No render function is necessary.
      expect(renderersLibrary.getTopLevelFunction('_render_Mix'), isNull);
      expect(renderersLibrary.getClass('_Renderer_Mix'), isNotNull);
    });

    test('for a type found in a getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Bar'), isNotNull);
      expect(renderersLibrary.getClass('_Renderer_Bar'), isNotNull);
    });

    test('for a generic, bounded type found in a getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Baz'), isNotNull);
      expect(renderersLibrary.getClass('_Renderer_Baz'), isNotNull);
    });

    test('with a property map', () {
      expect(
          generatedContent,
          contains(
              'static Map<String, Property<CT_>> propertyMap<CT_ extends Foo>() =>'));
    });

    test('with a property map which references the superclass', () {
      expect(generatedContent,
          contains('..._Renderer_FooBase.propertyMap<Baz, CT_>(),'));
    });

    test('with a property map which references a mixed in class', () {
      expect(generatedContent,
          contains('..._Renderer_Mix.propertyMap<int, CT_>(),'));
    });

    test('with a property map with a bool property', () {
      expect(generatedContent, contains('''
                'b1': Property(
                  getValue: (CT_ c) => c.b1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.b1 == true,
                ),
'''));
    });

    test('with a property map with an Iterable property', () {
      expect(generatedContent, contains('''
                'l1': Property(
                  getValue: (CT_ c) => c.l1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'List<int>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.l1.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!));
                  },
                ),
'''));
    });

    test(
        'with a property map with a non-bool, non-Iterable, non-nullable property',
        () {
      expect(generatedContent, contains('''
                's1': Property(
                  getValue: (CT_ c) => c.s1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'String'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.s1, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['String']!);
                  },
                ),
'''));
    });
  });

  test('builds renderers from multiple annotations', () async {
    await testMustachioBuilder(writer, '''
class Foo {
  String s1 = 'hello';
}
class Bar {}
class Baz {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
library foo;
import 'package:mustachio/annotations.dart';
''');
    var renderersLibrary = await resolveGeneratedLibrary();

    expect(renderersLibrary.getTopLevelFunction('renderFoo'), isNotNull);
    expect(renderersLibrary.getTopLevelFunction('renderBar'), isNotNull);
    expect(renderersLibrary.getClass('_Renderer_Foo'), isNotNull);
    expect(renderersLibrary.getClass('_Renderer_Bar'), isNotNull);
  });

  group('builds a renderer class for a generic type', () {
    late final String generatedContent;

    // Builders are fairly expensive (about 4 seconds per `testBuilder` call),
    // so this [setUpAll] saves significant time over [setUp].
    setUpAll(() async {
      writer = InMemoryAssetWriter();
      await testMustachioBuilder(writer, '''
class FooBase<T> {}
class Foo<T> extends FooBase<T> {
  String s1 = 'hello';
}
class BarBase<T> {}
class Bar<T> extends BarBase<int> {}
class Baz {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
library foo;
import 'package:mustachio/annotations.dart';
''');
      var rendererAsset = AssetId('foo', 'lib/foo.runtime_renderers.dart');
      generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    });

    test('with a corresponding public API function', () async {
      expect(generatedContent,
          contains('String renderFoo<T>(Foo<T> context, Template template)'));
    });

    test('with a corresponding render function', () async {
      expect(
          generatedContent,
          contains('void _render_Foo<T>(\n'
              '    Foo<T> context, List<MustachioNode> ast, Template template, StringSink sink,\n'));
    });

    test('with a generic supertype type argument', () async {
      expect(generatedContent,
          contains('class _Renderer_Foo<T> extends RendererBase<Foo<T>>'));
    });

    test(
        'with a property map which references the superclass with a type '
        'variable', () {
      expect(generatedContent,
          contains('..._Renderer_FooBase.propertyMap<T, CT_>(),'));
    });

    test(
        'with a property map which references the superclass with an interface '
        'type', () {
      expect(generatedContent,
          contains('..._Renderer_BarBase.propertyMap<int, CT_>(),'));
    });
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

    var fooRendererClass = renderersLibrary.getClass('_Renderer_Foo')!;
    expect(fooRendererClass.typeParameters, hasLength(1));
    var cBound = fooRenderFunction.typeParameters.single.bound!;
    expect(cBound.getDisplayString(withNullability: false), equals('num'));
  });

  group('does not generate a renderer', () {
    late final LibraryElement renderersLibrary;

    setUpAll(() async {
      writer = InMemoryAssetWriter();
      await testMustachioBuilder(writer, '''
abstract class Foo<T> {
  static Static get static1 => Bar();
  Private get _private1 => Bar();
  void set setter1(Setter s);
  Method method1(Method m);
  String s1 = 'hello';
}
class Bar {}
class Baz {}
class Static {}
class Private {}
class Setter {}
class Method {}
''');
      renderersLibrary = await resolveGeneratedLibrary();
    });

    test('found in a static getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Static'), isNull);
      expect(renderersLibrary.getClass('_Renderer_Static'), isNull);
    });

    test('found in a private getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Private'), isNull);
      expect(renderersLibrary.getClass('_Renderer_Private'), isNull);
    });

    test('found in a setter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Setter'), isNull);
      expect(renderersLibrary.getClass('_Renderer_Setter'), isNull);
    });

    test('found in a method', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Method'), isNull);
      expect(renderersLibrary.getClass('_Renderer_Method'), isNull);
    });

    test('for types not @visibleToMustache', () {
      expect(renderersLibrary.getTopLevelFunction('_render_String'), isNull);
      expect(renderersLibrary.getClass('_Renderer_String'), isNull);
    });
  });
}
