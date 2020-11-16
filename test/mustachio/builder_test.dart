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

  final String templateUri;

  const Renderer(this.name, this.context, this.templateUri);
}

class Context<T> {
  const Context();
}
'''
};

const _libraryFrontMatter = '''
@Renderer(#renderFoo, Context<Foo>(), 'foo.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';
''';

TypeMatcher<List<int>> _containsAllOf(Object a,
    [Object b, Object c, Object d]) {
  if (d != null) {
    return decodedMatches(
        allOf(contains(a), contains(b), contains(c), contains(d)));
  } else if (c != null) {
    return decodedMatches(allOf(contains(a), contains(b), contains(c)));
  } else {
    return decodedMatches(
        b != null ? allOf(contains(a), contains(b)) : allOf(contains(a)));
  }
}

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

  test('builds a renderer for a class which extends Object', () async {
    await testMustachioBuilder('''
class Foo {}
''', outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          // The requested 'renderFoo' function
          '''
String renderFoo(Foo context, List<MustachioNode> ast) {
  var renderer = _Renderer_Foo(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}
''',
          // The renderer class for Foo
          '''
class _Renderer_Foo extends RendererBase<Foo> {
  _Renderer_Foo(Foo context) : super(context);
}
''',
          // The render function for Object
          '''
String _render_Object(Object context, List<MustachioNode> ast) {
  var renderer = _Renderer_Object(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}
''',
          // The renderer class for Object
          '''
class _Renderer_Object extends RendererBase<Object> {
  _Renderer_Object(Object context) : super(context);
}
''')
    });
  });

  test('builds renderers from multiple annotations', () async {
    await testMustachioBuilder('''
class Foo {}
class Bar {}
''', libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo.html.mustache')
@Renderer(#renderBar, Context<Bar>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('renderFoo'), isNotNull);
    expect(renderersLibrary.getTopLevelFunction('renderBar'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_Foo'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_Bar'), isNotNull);
  });

  test('builds a renderer for a class which is extended by a rendered class',
      () async {
    await testMustachioBuilder('''
class FooBase {}
class Foo extends FooBase {}
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('_render_FooBase'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_FooBase'), isNotNull);
  });

  test('builds a renderer for a generic type', () async {
    await testMustachioBuilder('''
class Foo<T> {}
''', outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          // The requested 'renderFoo' function
          'String renderFoo<T>(Foo<T> context, List<MustachioNode> ast)',
          // The renderer class for Foo
          'class _Renderer_Foo<T> extends RendererBase<Foo<T>>')
    });
  });

  test('builds a renderer for a type found in a getter', () async {
    await testMustachioBuilder('''
abstract class Foo {
  Bar get bar;
}
class Bar {}
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('_render_Bar'), isNotNull);
    expect(renderersLibrary.getType('_Renderer_Bar'), isNotNull);
  });

  test('skips a type found in a static or private getter', () async {
    await testMustachioBuilder('''
class Foo {
  static Bar get bar1 => Bar();
  Bar get _bar2 => Bar();
}
class Bar {}
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('_render_Bar'), isNull);
    expect(renderersLibrary.getType('_Renderer_Bar'), isNull);
  });

  test('skips a type found in a setter or method', () async {
    await testMustachioBuilder('''
abstract class Foo {
  void set bar1(Bar b);
  Bar bar2(Bar b);
}
class Bar {}
''');
    var renderersLibrary = await resolveGeneratedLibrary(writer);

    expect(renderersLibrary.getTopLevelFunction('_render_Bar'), isNull);
    expect(renderersLibrary.getType('_Renderer_Bar'), isNull);
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
}

extension on LibraryElement {
  FunctionElement getTopLevelFunction(String name) => topLevelElements
      .whereType<FunctionElement>()
      .firstWhere((element) => element.name == name, orElse: () => null);
}
