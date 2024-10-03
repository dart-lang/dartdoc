// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('!windows')
@Timeout.factor(2)
library;

import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../src/test_descriptor_utils.dart';
import 'builder_test_base.dart';
import 'foo.aot_renderers_for_html.dart' as generated;
import 'foo.dart';

void main() {
  final sdk = path.dirname(path.dirname(Platform.resolvedExecutable));
  final fooCode = '''
class FooBase<T extends Object> {
  T? baz;
}

class Foo extends FooBase<Baz> {
  String? s1 = '';
  bool b1 = false;
  List<int> l1 = [];
  @override
  Baz? baz;
  Property1? p1;
}

class Bar {
  Foo? foo;
  String? s2;
  Baz? baz;
  bool? l1;
}

class Baz {
  Bar? bar;
}

class Property1 {
  Property2? p2;
}

class Property2 with Mixin1 {
  String? s;
}

mixin Mixin1 {
  Property3? p3;
}

class Property3 {
  String? s;
}
''';
  late Directory tempDir;
  late File renderScript;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dartdoc');
    renderScript = File(path.join(tempDir.path, 'render.dart'));
  });

  Future<void> write(
    Iterable<DirectoryDescriptor> Function() additionalAssets,
    String mainCode,
  ) async {
    await testMustachioBuilder(
      fooCode,
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
@Renderer(#renderBaz, Context<Baz>(), 'baz')
library foo;
import 'annotations.dart';
''',
      additionalAssets: additionalAssets,
    );
    var generatedContent = await File(
            '${d.sandbox}/foo_package/lib/foo.aot_renderers_for_html.dart')
        .readAsString();
    generatedContent = generatedContent.replaceFirst(
        "import 'foo.dart';", "import 'package:foo/foo.dart';");
    renderScript.writeAsStringSync('''
import 'dart:io';

$generatedContent

$mainCode
''');
    var packageConfig = PackageConfig([
      Package(
        'foo',
        Uri.directory(tempDir.path),
        packageUriRoot: Uri.directory(path.join(tempDir.path, 'lib')),
        languageVersion: LanguageVersion(2, 12),
      )
    ]);
    var dartToolDir = Directory(path.join(tempDir.path, '.dart_tool'))
      ..createSync();
    File(path.join(dartToolDir.path, 'package_config.json'))
        .writeAsStringSync(json.encode(PackageConfig.toJson(packageConfig)));
    var fooLibDir = Directory(path.join(tempDir.path, 'lib'))..createSync();
    File(path.join(fooLibDir.path, 'foo.dart')).writeAsStringSync(fooCode);
  }

  Future<String> renderFoo(
    Iterable<DirectoryDescriptor> Function() additionalAssets,
    String fooInstanceCode,
  ) async {
    await write(additionalAssets, '''
void main() {
  stdout.write(renderFoo($fooInstanceCode));
}
''');
    var result = Process.runSync('$sdk/bin/dart', [renderScript.path]);
    expect(result.stderr, isEmpty);
    return result.stdout as String;
  }

  Future<String> renderBar(
    Iterable<DirectoryDescriptor> Function() additionalAssets,
    String barInstanceCode,
  ) async {
    await write(additionalAssets, '''
void main() =>
  stdout.write(renderBar($barInstanceCode));
''');
    var result = Process.runSync('$sdk/bin/dart', [renderScript.path]);
    expect(result.stderr, isEmpty);
    return result.stdout as String;
  }

  Future<String> renderBaz(
    Iterable<DirectoryDescriptor> Function() additionalAssets,
    String bazInstanceCode,
  ) async {
    await write(additionalAssets, '''
void main() {
  var baz = $bazInstanceCode;
  stdout.write(renderBaz(baz));
}
''');
    var result = Process.runSync('$sdk/bin/dart', [renderScript.path]);
    expect(result.stderr, isEmpty);
    return result.stdout as String;
  }

  test('Renderer renders a non-bool variable node', () async {
    var foo = Foo()
      ..s1 = 'hello'
      ..b1 = false
      ..l1 = [1, 2, 3];
    var rendered = generated.renderFoo(foo);
    expect(rendered, equals('''
<div>
    <div class="partial">
    l1: [1, 2, 3]
</div>
    s1: hello
    b1? no
    l1:item: 1item: 2item: 3
    baz:baz is null
</div>'''));
  });

  test('Renderer renders a non-bool variable node, escaped', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates', [d.file('foo.html', 'Text {{s1}}')]),
      ],
      'Foo()..s1 = "<p>hello</p>"',
    );
    expect(output, equals('Text &lt;p&gt;hello&lt;&#47;p&gt;'));
  });

  test('Renderer renders a non-bool variable node, not escaped', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates', [d.file('foo.html', 'Text {{{s1}}}')]),
      ],
      'Foo()..s1 = "<p>hello</p>"',
    );
    expect(output, equals('Text <p>hello</p>'));
  });

  test('Renderer renders a bool variable node', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates', [d.file('foo.html', 'Text {{b1}}')]),
      ],
      'Foo()..b1 = true',
    );
    expect(output, equals('Text true'));
  });

  test('Renderer renders an Iterable variable node', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates', [d.file('foo.html', 'Text {{l1}}')]),
      ],
      'Foo()..l1 = [1, 2, 3]',
    );
    expect(output, equals('Text [1, 2, 3]'));
  });

  test('Renderer renders a conditional section node', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{#b1}}Section{{/b1}}')]),
      ],
      'Foo()..b1 = true',
    );
    expect(output, equals('Text Section'));
  });

  test('Renderer renders a conditional section node as blank', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{#b1}}Section{{/b1}}')]),
      ],
      'Foo()..b1 = false',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders a false conditional section node as blank', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{#b1}}Section{{/b1}}')]),
      ],
      'Foo()..b1 = false',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted conditional section node as empty',
      () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{^b1}}Section{{/b1}}')]),
      ],
      'Foo()..b1 = true',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted false conditional section node', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{^b1}}Section{{/b1}}')]),
      ],
      'Foo()..b1 = false',
    );
    expect(output, equals('Text Section'));
  });

  test('Renderer renders a repeated section node', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{#l1}}Num {{.}}, {{/l1}}')]),
      ],
      'Foo()..l1 = [1, 2, 3]',
    );
    expect(output, equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders a repeated section node with a multi-name key',
      () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates',
            [d.file('bar.html', 'Text {{#foo.l1}}Num {{.}}, {{/foo.l1}}')]),
      ],
      'Bar()..foo = (Foo()..l1 = [1, 2, 3])',
    );
    expect(output, equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders an empty repeated section node as blank', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{#l1}}Num {{.}}, {{/l1}}')]),
      ],
      'Foo()..l1 = []',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders an empty inverted repeated section node', () async {
    var output = await renderFoo(
      () => [
        d.dir(
            'lib/templates', [d.file('foo.html', 'Text {{^l1}}Empty{{/l1}}')]),
      ],
      'Foo()..l1 = []',
    );
    expect(output, equals('Text Empty'));
  });

  test('Renderer renders an inverted repeated section node as blank', () async {
    var output = await renderFoo(
      () => [
        d.dir(
            'lib/templates', [d.file('foo.html', 'Text {{^l1}}Empty{{/l1}}')]),
      ],
      'Foo()..l1 = [1, 2, 3]',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders a value section node', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates',
            [d.file('bar.html', 'Text {{#foo}}Foo: {{s1}}{{/foo}}')]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")',
    );
    expect(output, equals('Text Foo: hello'));
  });

  test('Renderer renders a value section node keyed lower in the stack',
      () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates',
            [d.file('bar.html', 'Text {{#foo}}One {{#s2}}Two{{/s2}}{{/foo}}')]),
      ],
      'Bar()..foo = Foo()..s2 = "hello"',
    );
    expect(output, equals('Text One Two'));
  });

  test('Renderer renders a null value section node as blank', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{#s1}}"{{.}}" ({{length}}){{/s1}}')]),
      ],
      'Foo()..s1 = null',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted value section node as blank', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{^s1}}Section{{/s1}}')]),
      ],
      'Foo()..s1 = "hello"',
    );
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted null value section node', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates',
            [d.file('foo.html', 'Text {{^s1}}Section{{/s1}}')]),
      ],
      'Foo()..s1 = null',
    );
    expect(output, equals('Text Section'));
  });

  test('Renderer resolves variable inside a value section', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates',
            [d.file('bar.html', 'Text {{#foo}}{{s1}}{{/foo}}')]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves variable from outer context inside a value section',
      () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates',
            [d.file('bar.html', 'Text {{#foo}}{{s2}}{{/foo}}')]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")..s2 = "goodbye"',
    );
    expect(output, equals('Text goodbye'));
  });

  test('Renderer resolves variable with key with multiple names', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates', [d.file('bar.html', 'Text {{foo.s1}}')]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")..s2 = "goodbye"',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves variable with properties not in @Renderer', () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates', [d.file('foo.html', 'Text {{p1.p2.s}}')]),
      ],
      'Foo()..p1 = (Property1()..p2 = (Property2()..s = "hello"))',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves variable with mixin properties not in @Renderer',
      () async {
    var output = await renderFoo(
      () => [
        d.dir('lib/templates', [d.file('foo.html', 'Text {{p1.p2.p3.s}}')]),
      ],
      'Foo()'
      '..p1 = (Property1()'
      '..p2 = (Property2()..p3 = (Property3()..s = "hello")))',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with two names', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates',
            [d.file('bar.html', 'Text {{#foo}}{{foo.s1}}{{/foo}}')]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")..s2 = "goodbye"',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with three names', () async {
    var output = await renderBaz(
      () => [
        d.dir('lib/templates',
            [d.file('baz.html', 'Text {{#bar}}{{bar.foo.s1}}{{/bar}}')]),
      ],
      'Baz()..bar = (Bar()..foo = (Foo()..s1 = "hello"))',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with more than three names',
      () async {
    var output = await renderBaz(
      () => [
        d.dir('lib/templates', [
          d.file('baz.html', 'Text {{#bar}}{{bar.foo.baz.bar.foo.s1}}{{/bar}}')
        ]),
      ],
      'Baz()..bar = (Bar()..foo = (Foo()..s1 = "hello"));'
      'baz.bar!.foo!.baz = baz',
    );
    expect(output, equals('Text hello'));
  });

  test('Renderer renders a partial in the same directory', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates', [
          d.file('bar.html', 'Text {{#foo}}{{>foo.mustache}}{{/foo}}'),
          d.file('_foo.mustache.html', 'Partial {{s1}}'),
        ]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")',
    );
    expect(output, equals('Text Partial hello'));
  });

  test('Renderer renders a partial in a different directory', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates', [
          d.dir('dir', [
            d.file('_foo.mustache.html', 'Partial {{s1}}'),
          ]),
          d.file('bar.html', 'Text {{#foo}}{{>dir/foo.mustache}}{{/foo}}'),
        ]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")',
    );
    expect(output, equals('Text Partial hello'));
  });

  test('Renderer renders a partial in an absolute directory', () async {
    // TODO(srawlins): See if we can get this functionality working.
  });

  test('Renderer renders a partial with context chain', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates', [
          d.file('bar.html', 'Text {{#foo}}{{>foo.mustache}}{{/foo}}'),
          d.file('_foo.mustache.html', 'Partial {{s2}}'),
        ]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello")..s2 = "goodbye"',
    );
    expect(output, equals('Text Partial goodbye'));
  });

  test('Renderer renders a partial which refers to other partials', () async {
    var output = await renderBar(
      () => [
        d.dir('lib/templates', [
          d.file('bar.html', 'Text, {{#foo}}{{>foo.mustache}}{{/foo}}'),
          d.file(
              '_foo.mustache.html', 'p1, {{#l1}}{{>foo_l1.mustache}}{{/l1}}'),
          d.file('_foo_l1.mustache.html', 'p2 {{.}}, '),
        ]),
      ],
      'Bar()..foo = (Foo()..s1 = "hello"..l1 = [1, 2, 3])',
    );
    expect(output, equals('Text, p1, p2 1, p2 2, p2 3, '));
  });

  test('Renderer renders a partial with a heterogeneous context chain',
      () async {
    // TODO(srawlins): To get this concept to work (see associated test in
    // `runtime_renderer_render_test.dart`), we'd need to restructure partial
    // render functions to accept a stack (List) instead of multiple parameters.
  });

  test('Renderer renders a partial using a custom partial renderer', () async {
    // TODO(srawlins): Implement this feature.
  });

  test('Renderer throws when it cannot resolve a variable key', () async {
    expect(
      () async => await renderFoo(
        () => [
          d.dir('lib/templates', [d.file('foo.html', 'Text {{s2}}')]),
        ],
        'Foo()',
      ),
      throwsA(const TypeMatcher<MustachioResolutionException>()
          .having((e) => e.message, 'message', contains('''
line 1, column 8 of lib/templates/foo.html: Failed to resolve '[s2]' as a property on any types in the context chain: [Foo]
  ╷
1 │ Text {{s2}}
  │        ^^
  ╵'''))),
    );
  });

  test('Renderer throws when it cannot resolve a section key', () async {
    expect(
      () async => await renderFoo(
        () => [
          d.dir('lib/templates',
              [d.file('foo.html', 'Text {{#s2}}Section{{/s2}}')]),
        ],
        'Foo()',
      ),
      throwsA(const TypeMatcher<MustachioResolutionException>()
          .having((e) => e.message, 'message', contains('''
line 1, column 9 of lib/templates/foo.html: Failed to resolve '[s2]' as a property on any types in the context chain: [Foo]
  ╷
1 │ Text {{#s2}}Section{{/s2}}
  │         ^^
  ╵'''))),
    );
  });

  test('Renderer throws when it cannot resolve a multi-name variable key',
      () async {
    expect(
      () async => await renderFoo(
        () => [
          d.dir('lib/templates', [d.file('bar.html', 'Text {{foo.x}}')]),
        ],
        'Bar()..foo = Foo()',
      ),
      throwsA(const TypeMatcher<MustachioResolutionException>()
          .having((e) => e.message, 'message', contains('''
line 1, column 8 of lib/templates/bar.html: Failed to resolve 'x' on Bar while resolving [x] as a property chain on any types in the context chain: context0.foo, after first resolving 'foo' to a property on Foo?
  ╷
1 │ Text {{foo.x}}
  │        ^^^^^
  ╵'''))),
    );
  });

  test('Renderer throws when it cannot resolve a multi-name section key',
      () async {
    expect(
      () async => await renderBar(
        () => [
          d.dir('lib/templates',
              [d.file('bar.html', 'Text {{#foo.x}}Section{{/foo.x}}')]),
        ],
        'Bar()..foo = Foo()',
      ),
      throwsA(const TypeMatcher<MustachioResolutionException>()
          .having((e) => e.message, 'message', contains('''
line 1, column 13 of lib/templates/bar.html: Failed to resolve '[x]' as a property on any types in the context chain: [Foo, Bar]
  ╷
1 │ Text {{#foo.x}}Section{{/foo.x}}
  │             ^
  ╵'''))),
    );
  });

  test('Template parser throws when it cannot read a template', () async {
    // TODO(srawlins): Implement this test.
  });

  test('Template parser throws when it cannot read a partial', () async {
    expect(
      () async => await renderBar(
        () => [
          d.dir('lib/templates', [
            d.file('bar.html', 'Text {{#foo}}{{>missing.mustache}}{{/foo}}')
          ]),
        ],
        'Bar()',
      ),
      throwsA(const TypeMatcher<PathNotFoundException>()),
    );
  });
}
