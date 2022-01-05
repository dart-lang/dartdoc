// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'builder_test_base.dart';
import 'foo.aot_renderers_for_html.dart' as generated;
import 'foo.dart';

void main() {
  final sdk = p.dirname(p.dirname(Platform.resolvedExecutable));
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
  late InMemoryAssetWriter writer;
  late Directory tempDir;
  late File renderScript;

  setUp(() {
    writer = InMemoryAssetWriter();
    tempDir = Directory.systemTemp.createTempSync('dartdoc');
    renderScript = File(p.join(tempDir.path, 'render.dart'));
  });

  Future<void> write(
      Map<String, String> additionalAssets, String mainCode) async {
    await testMustachioBuilder(
      writer,
      fooCode,
      libraryFrontMatter: '''
@Renderer(#renderFoo, Context<Foo>(), 'foo')
@Renderer(#renderBar, Context<Bar>(), 'bar')
@Renderer(#renderBaz, Context<Baz>(), 'baz')
library foo;
import 'package:mustachio/annotations.dart';
''',
      additionalAssets: additionalAssets,
    );
    var rendererAsset = AssetId('foo', 'lib/foo.aot_renderers_for_html.dart');
    var generatedContent = utf8.decode(writer.assets[rendererAsset]!);
    renderScript.writeAsStringSync('''
import 'dart:io';

$generatedContent

$mainCode
''');
    var packageConfig = PackageConfig([
      Package(
        'foo',
        Uri.directory(tempDir.path),
        packageUriRoot: Uri.directory(p.join(tempDir.path, 'lib')),
        languageVersion: LanguageVersion(2, 12),
      )
    ]);
    var dartToolDir = Directory(p.join(tempDir.path, '.dart_tool'))
      ..createSync();
    File(p.join(dartToolDir.path, 'package_config.json'))
        .writeAsStringSync(json.encode(PackageConfig.toJson(packageConfig)));
    var fooLibDir = Directory(p.join(tempDir.path, 'lib'))..createSync();
    File(p.join(fooLibDir.path, 'foo.dart')).writeAsStringSync(fooCode);
  }

  Future<String> renderFoo(
      Map<String, String> additionalAssets, String fooInstanceCode) async {
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
      Map<String, String> additionalAssets, String barInstanceCode) async {
    await write(additionalAssets, '''
void main() =>
  stdout.write(renderBar($barInstanceCode));
''');
    var result = Process.runSync('$sdk/bin/dart', [renderScript.path]);
    expect(result.stderr, isEmpty);
    return result.stdout as String;
  }

  Future<String> renderBaz(
      Map<String, String> additionalAssets, String bazInstanceCode) async {
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
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{s1}}',
    }, '_i1.Foo()..s1 = "<p>hello</p>"');
    expect(output, equals('Text &lt;p&gt;hello&lt;&#47;p&gt;'));
  });

  test('Renderer renders a non-bool variable node, not escaped', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{{s1}}}',
    }, '_i1.Foo()..s1 = "<p>hello</p>"');
    expect(output, equals('Text <p>hello</p>'));
  });

  test('Renderer renders a bool variable node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{b1}}',
    }, '_i1.Foo()..b1 = true');
    expect(output, equals('Text true'));
  });

  test('Renderer renders an Iterable variable node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{l1}}',
    }, '_i1.Foo()..l1 = [1, 2, 3]');
    expect(output, equals('Text [1, 2, 3]'));
  });

  test('Renderer renders a conditional section node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{#b1}}Section{{/b1}}',
    }, '_i1.Foo()..b1 = true');
    expect(output, equals('Text Section'));
  });

  test('Renderer renders a conditional section node as blank', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{#b1}}Section{{/b1}}',
    }, '_i1.Foo()..b1 = false');
    expect(output, equals('Text '));
  });

  test('Renderer renders a false conditional section node as blank', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{#b1}}Section{{/b1}}',
    }, '_i1.Foo()..b1 = false');
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted conditional section node as empty',
      () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{^b1}}Section{{/b1}}',
    }, '_i1.Foo()..b1 = true');
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted false conditional section node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{^b1}}Section{{/b1}}',
    }, '_i1.Foo()..b1 = false');
    expect(output, equals('Text Section'));
  });

  test('Renderer renders a repeated section node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{#l1}}Num {{.}}, {{/l1}}',
    }, '_i1.Foo()..l1 = [1, 2, 3]');
    expect(output, equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders a repeated section node with a multi-name key',
      () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html':
          'Text {{#foo.l1}}Num {{.}}, {{/foo.l1}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..l1 = [1, 2, 3])');
    expect(output, equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders an empty repeated section node as blank', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{#l1}}Num {{.}}, {{/l1}}',
    }, '_i1.Foo()..l1 = []');
    expect(output, equals('Text '));
  });

  test('Renderer renders an empty inverted repeated section node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{^l1}}Empty{{/l1}}',
    }, '_i1.Foo()..l1 = []');
    expect(output, equals('Text Empty'));
  });

  test('Renderer renders an inverted repeated section node as blank', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{^l1}}Empty{{/l1}}',
    }, '_i1.Foo()..l1 = [1, 2, 3]');
    expect(output, equals('Text '));
  });

  test('Renderer renders a value section node', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html': 'Text {{#foo}}Foo: {{s1}}{{/foo}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")');
    expect(output, equals('Text Foo: hello'));
  });

  test('Renderer renders a value section node keyed lower in the stack',
      () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html':
          'Text {{#foo}}One {{#s2}}Two{{/s2}}{{/foo}}',
    }, '_i1.Bar()..foo = _i1.Foo()..s2 = "hello"');
    expect(output, equals('Text One Two'));
  });

  test('Renderer renders a null value section node as blank', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html':
          'Text {{#s1}}"{{.}}" ({{length}}){{/s1}}',
    }, '_i1.Foo()..s1 = null');
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted value section node as blank', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{^s1}}Section{{/s1}}',
    }, '_i1.Foo()..s1 = "hello"');
    expect(output, equals('Text '));
  });

  test('Renderer renders an inverted null value section node', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{^s1}}Section{{/s1}}',
    }, '_i1.Foo()..s1 = null');
    expect(output, equals('Text Section'));
  });

  test('Renderer resolves variable inside a value section', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html': 'Text {{#foo}}{{s1}}{{/foo}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")');
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves variable from outer context inside a value section',
      () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html': 'Text {{#foo}}{{s2}}{{/foo}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")..s2 = "goodbye"');
    expect(output, equals('Text goodbye'));
  });

  test('Renderer resolves variable with key with multiple names', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html': 'Text {{foo.s1}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")..s2 = "goodbye"');
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves variable with properties not in @Renderer', () async {
    var output = await renderFoo({
      'foo|lib/templates/html/foo.html': 'Text {{p1.p2.s}}',
    }, '_i1.Foo()..p1 = (_i1.Property1()..p2 = (_i1.Property2()..s = "hello"))');
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves variable with mixin properties not in @Renderer',
      () async {
    var output = await renderFoo(
        {
          'foo|lib/templates/html/foo.html': 'Text {{p1.p2.p3.s}}',
        },
        '_i1.Foo()'
        '..p1 = (_i1.Property1()'
        '..p2 = (_i1.Property2()..p3 = (_i1.Property3()..s = "hello")))');
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with two names', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html': 'Text {{#foo}}{{foo.s1}}{{/foo}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")..s2 = "goodbye"');
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with three names', () async {
    var output = await renderBaz({
      'foo|lib/templates/html/baz.html': 'Text {{#bar}}{{bar.foo.s1}}{{/bar}}',
    }, '_i1.Baz()..bar = (_i1.Bar()..foo = (_i1.Foo()..s1 = "hello"))');
    expect(output, equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with more than three names',
      () async {
    var output = await renderBaz(
        {
          'foo|lib/templates/html/baz.html':
              'Text {{#bar}}{{bar.foo.baz.bar.foo.s1}}{{/bar}}',
        },
        '_i1.Baz()..bar = (_i1.Bar()..foo = (_i1.Foo()..s1 = "hello"));'
        'baz.bar!.foo!.baz = baz');
    expect(output, equals('Text hello'));
  });

  test('Renderer renders a partial in the same directory', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html':
          'Text {{#foo}}{{>foo.mustache}}{{/foo}}',
      'foo|lib/templates/html/_foo.mustache.html': 'Partial {{s1}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")');
    expect(output, equals('Text Partial hello'));
  });

  test('Renderer renders a partial in a different directory', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html':
          'Text {{#foo}}{{>../foo.mustache}}{{/foo}}',
      'foo|lib/templates/_foo.mustache.html': 'Partial {{s1}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")');
    expect(output, equals('Text Partial hello'));
  });

  test('Renderer renders a partial in an absolute directory', () async {
    // TODO(srawlins): See if we can get this functionality working.
  });

  test('Renderer renders a partial with context chain', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html':
          'Text {{#foo}}{{>foo.mustache}}{{/foo}}',
      'foo|lib/templates/html/_foo.mustache.html': 'Partial {{s2}}',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello")..s2 = "goodbye"');
    expect(output, equals('Text Partial goodbye'));
  });

  test('Renderer renders a partial which refers to other partials', () async {
    var output = await renderBar({
      'foo|lib/templates/html/bar.html':
          'Text, {{#foo}}{{>foo.mustache}}{{/foo}}',
      'foo|lib/templates/html/_foo.mustache.html':
          'p1, {{#l1}}{{>foo_l1.mustache}}{{/l1}}',
      'foo|lib/templates/html/_foo_l1.mustache.html': 'p2 {{.}}, ',
    }, '_i1.Bar()..foo = (_i1.Foo()..s1 = "hello"..l1 = [1, 2, 3])');
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
        () async => await renderFoo({
              'foo|lib/templates/html/foo.html': 'Text {{s2}}',
            }, '_i1.Foo()'),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 8 of package:foo/templates/html/foo.html: Failed to resolve '[s2]' as a property on any types in the context chain: [Foo]
  ╷
1 │ Text {{s2}}
  │        ^^
  ╵'''))));
  });

  test('Renderer throws when it cannot resolve a section key', () async {
    expect(
        () async => await renderFoo({
              'foo|lib/templates/html/foo.html': 'Text {{#s2}}Section{{/s2}}',
            }, '_i1.Foo()'),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 9 of package:foo/templates/html/foo.html: Failed to resolve '[s2]' as a property on any types in the context chain: [Foo]
  ╷
1 │ Text {{#s2}}Section{{/s2}}
  │         ^^
  ╵'''))));
  });

  test('Renderer throws when it cannot resolve a multi-name variable key',
      () async {
    expect(
        () async => await renderBar({
              'foo|lib/templates/html/bar.html': 'Text {{foo.x}}',
            }, '_i1.Bar()..foo = _i1.Foo()'),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 8 of package:foo/templates/html/bar.html: Failed to resolve 'x' on Bar while resolving [x] as a property chain on any types in the context chain: context0.foo, after first resolving 'foo' to a property on Foo?
  ╷
1 │ Text {{foo.x}}
  │        ^^^^^
  ╵'''))));
  });

  test('Renderer throws when it cannot resolve a multi-name section key',
      () async {
    expect(
        () async => await renderBar({
              'foo|lib/templates/html/bar.html':
                  'Text {{#foo.x}}Section{{/foo.x}}',
            }, '_i1.Bar()..foo = _i1.Foo()'),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 13 of package:foo/templates/html/bar.html: Failed to resolve '[x]' as a property on any types in the context chain: [Foo, Bar]
  ╷
1 │ Text {{#foo.x}}Section{{/foo.x}}
  │             ^
  ╵'''))));
  });

  test('Template parser throws when it cannot read a template', () async {
    // TODO(srawlins): Implement this test.
  });

  test('Template parser throws when it cannot read a partial', () async {
    expect(
        () async => await renderBar({
              'foo|lib/templates/html/bar.html':
                  'Text {{#foo}}{{>missing.mustache}}{{/foo}}',
            }, '_i1.Bar()'),
        throwsA(const TypeMatcher<AssetNotFoundException>()));
  });
}
