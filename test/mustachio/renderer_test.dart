import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'foo.dart';
import 'foo.renderers.dart';

void main() {
  /*late*/ MemoryResourceProvider resourceProvider;

  /*late*/ p.Context pathContext;

  File getFile(String path) => resourceProvider
      .getFile(pathContext.canonicalize(resourceProvider.convertPath(path)));

  setUp(() {
    resourceProvider = MemoryResourceProvider();
    pathContext = resourceProvider.pathContext;
  });

  test('property map contains all public getters', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap.keys, hasLength(7));
    expect(propertyMap['b1'], isNotNull);
    expect(propertyMap['s1'], isNotNull);
    expect(propertyMap['l1'], isNotNull);
    expect(propertyMap['baz'], isNotNull);
    expect(propertyMap['p1'], isNotNull);
    expect(propertyMap['hashCode'], isNotNull);
    expect(propertyMap['runtimeType'], isNotNull);
  });

  test('property map contains valid bool Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['b1'].getValue, isNotNull);
    expect(propertyMap['b1'].renderVariable, isNotNull);
    expect(propertyMap['b1'].getBool, isNotNull);
    expect(propertyMap['b1'].renderIterable, isNull);
    expect(propertyMap['b1'].isNullValue, isNull);
    expect(propertyMap['b1'].renderValue, isNull);
  });

  test('property map contains valid Iterable Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['l1'].getValue, isNotNull);
    expect(propertyMap['l1'].renderVariable, isNotNull);
    expect(propertyMap['l1'].getBool, isNull);
    expect(propertyMap['l1'].renderIterable, isNotNull);
    expect(propertyMap['l1'].isNullValue, isNull);
    expect(propertyMap['l1'].renderValue, isNull);
  });

  test('property map contains valid non-bool, non-Iterable Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['s1'].getValue, isNotNull);
    expect(propertyMap['s1'].renderVariable, isNotNull);
    expect(propertyMap['s1'].getBool, isNull);
    expect(propertyMap['s1'].renderIterable, isNull);
    expect(propertyMap['s1'].isNullValue, isNotNull);
    expect(propertyMap['s1'].renderValue, isNotNull);
  });

  test('Property returns a field value by name', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..s1 = 'hello';
    expect(propertyMap['s1'].getValue(foo), equals('hello'));
  });

  test('Property returns a bool field value by name', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..b1 = true;
    expect(propertyMap['b1'].getBool(foo), isTrue);
  });

  test('isNullValue returns true when a value is null', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..s1 = null;
    expect(propertyMap['s1'].isNullValue(foo), isTrue);
  });

  test('isNullValue returns false when a value is not null', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..s1 = 'hello';
    expect(propertyMap['s1'].isNullValue(foo), isFalse);
  });

  test('Property returns false for a null bool field value', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..b1 = null;
    expect(propertyMap['b1'].getBool(foo), isFalse);
  });

  test('Renderer renders a non-bool variable node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{s1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, fooTemplate), equals('Text hello'));
  });

  test('Renderer renders a bool variable node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{b1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, fooTemplate), equals('Text true'));
  });

  test('Renderer renders an Iterable variable node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{l1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('Text [1, 2, 3]'));
  });

  test('Renderer renders a conditional section node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#b1}}Section{{/b1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, fooTemplate), equals('Text Section'));
  });

  test('Renderer renders a false conditional section node as blank', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#b1}}Section{{/b1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..b1 = false;
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted conditional section node as empty',
      () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^b1}}Section{{/b1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted false conditional section node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^b1}}Section{{/b1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..b1 = false;
    expect(renderFoo(foo, fooTemplate), equals('Text Section'));
  });

  test('Renderer renders a repeated section node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#l1}}Num {{.}}, {{/l1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders a repeated section node with a multi-name key',
      () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo.l1}}Num {{.}}, {{/foo.l1}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = (Foo()..l1 = [1, 2, 3]);
    expect(renderBar(bar, barTemplate), equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders an empty repeated section node as blank', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#l1}}Num {{.}}, {{/l1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..l1 = [];
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an empty inverted repeated section node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^l1}}Empty{{/l1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..l1 = [];
    expect(renderFoo(foo, fooTemplate), equals('Text Empty'));
  });

  test('Renderer renders an inverted repeated section node as blank', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^l1}}Empty{{/l1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders a value section node', () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}Foo: {{s1}}{{/foo}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Foo: hello'));
  });

  test('Renderer renders a null value section node as blank', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#s1}}"{{.}}" ({{length}}){{/s1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..s1 = null;
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted value section node as blank', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^s1}}Section{{/s1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted null value section node', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^s1}}Section{{/s1}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..s1 = null;
    expect(renderFoo(foo, fooTemplate), equals('Text Section'));
  });

  test('Renderer resolves variable inside a value section', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}{{s1}}{{/foo}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves variable from outer context inside a value section',
      () async {
    var barTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}{{s2}}{{/foo}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, barTemplate), equals('Text goodbye'));
  });

  test('Renderer resolves variable with key with multiple names', () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{foo.s1}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, barTemplate), equals('Text hello'));
  });

  test('Renderer resolves variable with properties not in @Renderer', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{p1.p2.s}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..p1 = (Property1()..p2 = (Property2()..s = 'hello'));
    expect(renderFoo(foo, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves variable with mixin properties not in @Renderer',
      () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{p1.p2.p3.s}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()
      ..p1 = (Property1()..p2 = (Property2()..p3 = (Property3()..s = 'hello')));
    expect(renderFoo(foo, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with two names', () async {
    var barTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}{{foo.s1}}{{/foo}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, barTemplate), equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with three names', () async {
    var bazTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#bar}}{{bar.foo.s1}}{{/bar}}');
    var bazTemplate = await Template.parse(bazTemplateFile);
    var baz = Baz()..bar = (Bar()..foo = (Foo()..s1 = 'hello'));
    expect(renderBaz(baz, bazTemplate), equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with more than three names',
      () async {
    var bazTemplateFile = getFile('/project/baz.mustache')
      ..writeAsStringSync('Text {{#bar}}{{bar.foo.baz.bar.foo.s1}}{{/bar}}');
    var baz = Baz()..bar = (Bar()..foo = (Foo()..s1 = 'hello'));
    var bazTemplate = await Template.parse(bazTemplateFile);
    baz.bar.foo.baz = baz;
    expect(renderBaz(baz, bazTemplate), equals('Text hello'));
  });

  test('Renderer renders a partial in the same directory', () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s1}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Renderer renders a partial in a different directory', () async {
    var barTemplateFile = getFile('/project/src/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>../foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s1}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Renderer renders a partial in an absolute directory', () async {
    var fooTemplateFile = getFile('/project/foo.mustache');
    fooTemplateFile.writeAsStringSync('Partial {{s1}}');
    var barTemplateFile = getFile('/project/src/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>${fooTemplateFile.path}}}{{/foo}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Renderer renders a partial with context chain', () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s2}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, barTemplate), equals('Text Partial goodbye'));
  });

  test('Renderer renders a partial which refers to other partials', () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text, {{#foo}}{{>foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache')
        .writeAsStringSync('p1, {{#l1}}{{>foo_l1.mustache}}{{/l1}}');
    getFile('/project/foo_l1.mustache').writeAsStringSync('p2 {{.}}, ');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()
      ..foo = (Foo()
        ..s1 = 'hello'
        ..l1 = [1, 2, 3]);
    expect(renderBar(bar, barTemplate), equals('Text, p1, p2 1, p2 2, p2 3, '));
  });

  test('Renderer renders a partial with a heterogeneous context chain',
      () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Line 1 {{#foo}}{{>baz.mustache}}{{/foo}}\n'
          'Line 2 {{>baz.mustache}}');
    getFile('/project/baz.mustache')
        .writeAsStringSync('Partial {{#l1}}Section {{.}}{{/l1}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var baz = Baz();
    var bar = Bar()
      ..foo = (Foo()
        ..baz = baz
        ..l1 = [1, 2, 3])
      ..baz = baz
      ..l1 = true;
    // This is a wild consequence of Mustache's dynamic rendering concepts.
    // The `baz.mustache` partial refers to a variable, "l1", which does not
    // exist on the Baz class, so variable resolution walks up the context
    // chain. In the first line, this finds `Foo.l1`, and renders a repeated
    // section for the `l1` List. In the second line, this finds `Bar.l1`, and
    // renders the conditional section, which doesn't push a context, so
    // `{{.}}` renders `Bar.toString()`.
    expect(
        renderBar(bar, barTemplate),
        equals('Line 1 Partial Section 1Section 2Section 3\n'
            'Line 2 Partial Section Instance of \'Bar\''));
  });

  test('Renderer renders a partial using a custom partial renderer', () async {
    Future<File> partialResolver(String path) async {
      var partialPath = pathContext.isAbsolute(path)
          ? '_$path.mustache'
          : pathContext.join('/project', '_$path.mustache');
      return getFile(partialPath);
    }

    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>foo}}{{/foo}}');
    getFile('/project/_foo.mustache').writeAsStringSync('Partial {{s1}}');
    var barTemplate =
        await Template.parse(barTemplateFile, partialResolver: partialResolver);
    var bar = Bar()..foo = (Foo()..s1 = 'hello');

    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Parser removes whitespace preceding a Section tag on its own line',
      () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('''
<ol>
  {{#l1}}
  <li>Num {{.}}</li>
  {{/l1}}
</ol>
''');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('''
<ol>
  <li>Num 1</li>
  <li>Num 2</li>
  <li>Num 3</li>
</ol>
'''));
  });

  test('Parser does not remove whitespace preceding a non-Section tag',
      () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('''
Hello
{{ #b1 }}
{{ s1 }}
{{ /b1 }}
''');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo()
      ..b1 = true
      ..s1 = 'World';
    expect(renderFoo(foo, fooTemplate), equals('''
Hello
World
'''));
  });

  test('Renderer throws when it cannot resolve a variable key', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{s2}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo();
    expect(
        () => renderFoo(foo, fooTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 8 of ${fooTemplateFile.path}: Failed to resolve 's2' as a property on any types in the context chain: Foo
  ╷
1 │ Text {{s2}}
  │        ^^
'''))));
  });

  test('Renderer throws when it cannot resolve a section key', () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#s2}}Section{{/s2}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo();
    expect(
        () => renderFoo(foo, fooTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 9 of ${fooTemplateFile.path}: Failed to resolve 's2' as a property on any types in the current context
  ╷
1 │ Text {{#s2}}Section{{/s2}}
  │         ^^
'''))));
  });

  test('Renderer throws when it cannot resolve a multi-name variable key',
      () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{foo.x}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = Foo();
    expect(
        () => renderBar(bar, barTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains("Failed to resolve 'x' on Foo while resolving [x] as a "
                'property chain on any types in the context chain: Bar, after '
                "first resolving 'foo' to a property on Bar"))));
  });

  test('Renderer throws when it cannot resolve a multi-name section key',
      () async {
    var barTemplateFile = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{foo.x}}');
    var barTemplate = await Template.parse(barTemplateFile);
    var bar = Bar()..foo = Foo();
    expect(
        () => renderBar(bar, barTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains("Failed to resolve 'x' on Foo while resolving [x] as a "
                'property chain on any types in the context chain: Bar, after '
                "first resolving 'foo' to a property on Bar"))));
  });

  test('Renderer throws when it cannot resolve a key with a SimpleRenderer',
      () async {
    var fooTemplateFile = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{s1.length}}');
    var fooTemplate = await Template.parse(fooTemplateFile);
    var foo = Foo();
    expect(
        () => renderFoo(foo, fooTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains('Failed to resolve [length] property chain on String'))));
  });

  test('Template parser throws when it cannot read a template', () async {
    var barTemplateFile = getFile('/project/src/bar.mustache');
    expect(
        () async => await Template.parse(barTemplateFile),
        throwsA(const TypeMatcher<FileSystemException>().having(
            (e) => e.message,
            'message',
            contains('"${barTemplateFile.path}" does not exist.'))));
  });

  test('Template parser throws when it cannot read a partial', () async {
    var barTemplateFile = getFile('/project/src/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>missing.mustache}}{{/foo}}');
    var missingTemplateFile = getFile('/project/src/missing.mustache');
    expect(
        () async => await Template.parse(barTemplateFile),
        throwsA(const TypeMatcher<MustachioResolutionError>()
            .having((e) => e.message, 'message', contains('''
line 1, column 14 of ${barTemplateFile.path}: FileSystemException (File "${missingTemplateFile.path}" does not exist.) when reading partial:
  ╷
1 │ Text {{#foo}}{{>missing.mustache}}{{/foo}}
  │              ^^^^^^^^^^^^^^^^^^^^^
'''))));
  });
}
