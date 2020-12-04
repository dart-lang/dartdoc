import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import '../../tool/mustachio/builder.dart';

const _annotationsAsset = {
  'mustachio|lib/annotations.dart': '''
class Renderer {
  final Symbol name;

  final Context context;

  const Renderer(this.name, this.context);
}

class Context<T> {
  const Context();
}
'''
};

const _libraryFrontMatter = '''
@Renderer(#renderFoo, Context<Foo>())
library foo;
import 'package:mustachio/annotations.dart';
''';

void main() {
  InMemoryAssetWriter writer;

  Future<LibraryElement> resolveGeneratedLibrary(
      InMemoryAssetWriter writer) async {
    var rendererAsset = AssetId.parse('foo|lib/foo.renderers.dart');
    var writtenStrings = writer.assets
        .map((id, content) => MapEntry(id.toString(), utf8.decode(content)));
    return await resolveSources(writtenStrings,
        (Resolver resolver) => resolver.libraryFor(rendererAsset));
  }

  Future<void> testMustachioBuilder(String sourceLibraryContent,
      {String libraryFrontMatter = _libraryFrontMatter,
      Map<String, Object> outputs}) async {
    sourceLibraryContent = '''
$libraryFrontMatter
$sourceLibraryContent
''';
    await testBuilder(
      mustachioBuilder(BuilderOptions({})),
      {
        ..._annotationsAsset,
        'foo|lib/foo.dart': sourceLibraryContent,
      },
      outputs: outputs,
      writer: writer,
    );
  }

  setUp(() {
    writer = InMemoryAssetWriter();
  });

  group('builds a renderer class', () {
    LibraryElement renderersLibrary;
    String generatedContent;

    // Builders are fairly expensive (about 4 seconds per `testBuilder` call),
    // so this [setUpAll] saves significant time over [setUp].
    setUpAll(() async {
      writer = InMemoryAssetWriter();
      await testMustachioBuilder('''
abstract class FooBase {
  Bar get bar;
}
class Foo extends FooBase {
  String s1 = "s1";
  bool b1 = false;
  List<int> l1 = [1, 2, 3];
}
class Bar {}
''');
      renderersLibrary = await resolveGeneratedLibrary(writer);
      var rendererAsset = AssetId.parse('foo|lib/foo.renderers.dart');
      generatedContent = utf8.decode(writer.assets[rendererAsset]);
    });

    test('for a class which implicitly extends Object', () {
      // The render function for Foo
      expect(
          generatedContent,
          contains(
              'String _render_FooBase(FooBase context, List<MustachioNode> ast,'));
      // The renderer class for Foo
      expect(generatedContent,
          contains('class _Renderer_FooBase extends RendererBase<FooBase>'));
    });

    test('for Object', () {
      // The render function for Object
      expect(
          generatedContent,
          contains(
              'String _render_Object(Object context, List<MustachioNode> ast,'));
      // The renderer class for Object
      expect(generatedContent,
          contains('class _Renderer_Object extends RendererBase<Object> {'));
    });

    test('for a class which is extended by a rendered class', () {
      expect(
          renderersLibrary.getTopLevelFunction('_render_FooBase'), isNotNull);
      expect(renderersLibrary.getType('_Renderer_FooBase'), isNotNull);
    });

    test('for a type found in a getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Bar'), isNotNull);
      expect(renderersLibrary.getType('_Renderer_Bar'), isNotNull);
    });

    test('with a property map', () {
      expect(
          generatedContent,
          contains(
              'static Map<String, Property<CT_>> propertyMap<CT_ extends Foo>() => {'));
    });

    test('with a property map which references the superclass', () {
      expect(generatedContent,
          contains('..._Renderer_FooBase.propertyMap<CT_>(),'));
    });

    test('with a property map with a bool property', () {
      expect(generatedContent, contains('''
        'b1': Property(
          getValue: (CT_ c) => c.b1,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.b1 == true,
        ),
'''));
    });

    test('with a property map with an Iterable property', () {
      expect(generatedContent, contains('''
        'l1': Property(
          getValue: (CT_ c) => c.l1,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.l1?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.l1) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
'''));
    });

    test('with a property map with a non-bool, non-Iterable property', () {
      expect(generatedContent, contains('''
        's1': Property(
          getValue: (CT_ c) => c.s1,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.s1 == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.s1, ast, parent: r);
          },
        ),
'''));
    });
  });

  test('builds renderers from multiple annotations', () async {
    await testMustachioBuilder('''
class Foo {}
class Bar {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>())
@Renderer(#renderBar, Context<Bar>())
library foo;
import 'package:mustachio/annotations.dart';
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('renderFoo'), isNotNull);
    expect(renderersLibrary.getTopLevelFunction('renderBar'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_Foo'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_Bar'), isNotNull);
  });

  group('builds a renderer class for a generic type', () {
    String generatedContent;

    // Builders are fairly expensive (about 4 seconds per `testBuilder` call),
    // so this [setUpAll] saves significant time over [setUp].
    setUpAll(() async {
      writer = InMemoryAssetWriter();
      await testMustachioBuilder('''
class FooBase<T> {}
class Foo<T> extends FooBase<T> {}
class BarBase<T> {}
class Bar<T> extends BarBase<int> {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>())
@Renderer(#renderBar, Context<Bar>())
library foo;
import 'package:mustachio/annotations.dart';
''');
      var rendererAsset = AssetId.parse('foo|lib/foo.renderers.dart');
      generatedContent = utf8.decode(writer.assets[rendererAsset]);
    });

    test('with a corresponding render function', () async {
      expect(
          generatedContent,
          contains(
              'String renderFoo<T>(Foo<T> context, List<MustachioNode> ast,'));
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
    await testMustachioBuilder('''
class Foo<T extends num> {}
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    var fooRenderFunction = renderersLibrary.getTopLevelFunction('renderFoo');
    expect(fooRenderFunction.typeParameters, hasLength(1));
    var fBound = fooRenderFunction.typeParameters.single.bound;
    expect(fBound.getDisplayString(withNullability: false), equals('num'));

    var fooRendererClass = renderersLibrary.getType('_Renderer_Foo');
    expect(fooRendererClass.typeParameters, hasLength(1));
    var cBound = fooRenderFunction.typeParameters.single.bound;
    expect(cBound.getDisplayString(withNullability: false), equals('num'));

    expect(renderersLibrary.getTopLevelFunction('_render_num'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_num'), isNotNull);
  });

  group('does not generate a renderer', () {
    LibraryElement renderersLibrary;

    setUpAll(() async {
      writer = InMemoryAssetWriter();
      await testMustachioBuilder('''
class Foo {
  static Static get static1 => Bar();
  Private get _private1 => Bar();
  void set setter1(Setter s);
  Method method1(Method m);
}
class Static {}
class Private {}
class Setter {}
class Method {}
''');
      renderersLibrary = await resolveGeneratedLibrary(writer);
    });

    test('found in a static getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Static'), isNull);
      expect(renderersLibrary.getType('_Renderer_Static'), isNull);
    });

    test('found in a private getter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Private'), isNull);
      expect(renderersLibrary.getType('_Renderer_Private'), isNull);
    });

    test('found in a setter', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Setter'), isNull);
      expect(renderersLibrary.getType('_Renderer_Setter'), isNull);
    });

    test('found in a method', () {
      expect(renderersLibrary.getTopLevelFunction('_render_Method'), isNull);
      expect(renderersLibrary.getType('_Renderer_Method'), isNull);
    });
  });
}

extension on LibraryElement {
  FunctionElement getTopLevelFunction(String name) => topLevelElements
      .whereType<FunctionElement>()
      .firstWhere((element) => element.name == name, orElse: () => null);
}
