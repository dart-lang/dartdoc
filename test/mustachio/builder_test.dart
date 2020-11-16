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

TypeMatcher<List<int>> _containsNoneOf(Object a, [Object b]) {
  return decodedMatches(b != null
      ? allOf(isNot(contains(a)), isNot(contains(b)))
      : allOf(isNot(contains(a))));
}

void main() {
  test('builds a renderer for a class which extends Object', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'foo.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

class Foo {}
''',
    }, outputs: {
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
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'foo.html.mustache')
@Renderer(#renderBar, Context<Bar>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

class Foo {}
class Bar {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          // The requested 'renderFoo' function
          'String renderFoo(Foo context, List<MustachioNode> ast)',
          // The renderer class for Foo
          'class _Renderer_Foo extends RendererBase<Foo>',
          // The requested 'renderBar' function
          'String renderBar(Bar context, List<MustachioNode> ast)',
          // The renderer class for Bar
          'class _Renderer_Bar extends RendererBase<Bar>')
    });
  });

  test('builds a renderer for a class which extends another class', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

class FooBase {}

class Foo extends FooBase {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          'String _render_FooBase(FooBase context, List<MustachioNode> ast)',
          'class _Renderer_FooBase extends RendererBase<FooBase>')
    });
  });

  test('builds a renderer for a generic type', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

class Foo<T> {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          // The requested 'renderFoo' function
          'String renderFoo<T>(Foo<T> context, List<MustachioNode> ast)',
          // The renderer class for Foo
          'class _Renderer_Foo<T> extends RendererBase<Foo<T>>')
    });
  });

  test('builds a renderer for a type found in a getter', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

abstract class Foo {
  Bar get bar;
}

class Bar {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          // The render function for Bar
          'String _render_Bar(Bar context, List<MustachioNode> ast)',
          // The renderer class for Bar
          'class _Renderer_Bar extends RendererBase<Bar>')
    });
  });

  test('skips a type found in a static or private getter', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

class Foo {
  static Bar get bar1 => Bar();
  Bar get _bar2 => Bar();
}

class Bar {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsNoneOf(
          // No render function for Bar
          'String _render_Bar',
          // No renderer class for Bar
          'class _Renderer_Bar extends RendererBase<Bar>')
    });
  });

  test('skips a type found in a setter or method', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

abstract class Foo {
  void set bar1(Bar b);
  Bar bar2(Bar b);
}

class Bar {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsNoneOf(
          // No render function for Bar
          'String _render_Bar',
          // No renderer class for Bar
          'class _Renderer_Bar extends RendererBase<Bar>')
    });
  });

  test('builds a renderer for a generic, bounded type', () async {
    await testBuilder(mustachioBuilder(BuilderOptions({})), {
      ..._annotationsAsset,
      'foo|lib/foo.dart': '''
@Renderer(#renderFoo, Context<Foo>(), 'bar.html.mustache')
library foo;
import 'package:mustachio/annotations.dart';

class Foo<T extends num> {}
''',
    }, outputs: {
      'foo|lib/foo.renderers.dart': _containsAllOf(
          // The requested 'renderFoo' function
          'String renderFoo<T extends num>(Foo<T> context, List<MustachioNode> ast)',
          // The renderer class for Foo
          '''
class _Renderer_Foo<T extends num> extends RendererBase<Foo<T>> {
  _Renderer_Foo(Foo<T> context) : super(context);
}
''',
          // The render function for num, found in Foo's type parameter bound
          'String _render_num(num context, List<MustachioNode> ast)',
          // The renderer class for num
          'class _Renderer_num extends RendererBase<num>')
    });
  });
}
