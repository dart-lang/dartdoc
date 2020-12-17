import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:test/test.dart';
import 'foo.dart';
import 'foo.renderers.dart';

void main() {
  MemoryResourceProvider resourceProvider;

  File getFile(String path) =>
      resourceProvider.getFile(resourceProvider.convertPath(path));

  setUp(() {
    resourceProvider = MemoryResourceProvider();
  });

  test('property map contains all public getters', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap.keys, hasLength(5));
    expect(propertyMap['b1'], isNotNull);
    expect(propertyMap['s1'], isNotNull);
    expect(propertyMap['l1'], isNotNull);
    expect(propertyMap['baz'], isNotNull);
    expect(propertyMap['hashCode'], isNotNull);
  });

  test('property map contains valid bool Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['b1'].getValue, isNotNull);
    expect(propertyMap['b1'].renderVariable, isNotNull);
    expect(propertyMap['b1'].getBool, isNotNull);
    expect(propertyMap['b1'].isEmptyIterable, isNull);
    expect(propertyMap['b1'].renderIterable, isNull);
    expect(propertyMap['b1'].isNullValue, isNull);
    expect(propertyMap['b1'].renderValue, isNull);
  });

  test('property map contains valid Iterable Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['l1'].getValue, isNotNull);
    expect(propertyMap['l1'].renderVariable, isNotNull);
    expect(propertyMap['l1'].getBool, isNull);
    expect(propertyMap['l1'].isEmptyIterable, isNotNull);
    expect(propertyMap['l1'].renderIterable, isNotNull);
    expect(propertyMap['l1'].isNullValue, isNull);
    expect(propertyMap['l1'].renderValue, isNull);
  });

  test('property map contains valid non-bool, non-Iterable Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['s1'].getValue, isNotNull);
    expect(propertyMap['s1'].renderVariable, isNotNull);
    expect(propertyMap['s1'].getBool, isNull);
    expect(propertyMap['s1'].isEmptyIterable, isNull);
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

  test('isEmptyIterable returns true when an Iterable value is empty', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..l1 = [];
    expect(propertyMap['l1'].isEmptyIterable(foo), isTrue);
  });

  test('isEmptyIterable returns false when an Iterable value is not empty', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..l1 = [1, 2, 3];
    expect(propertyMap['l1'].isEmptyIterable(foo), isFalse);
  });

  test('isEmptyIterable returns true when an Iterable value is null', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var foo = Foo()..l1 = null;
    expect(propertyMap['l1'].isEmptyIterable(foo), isTrue);
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

  test('Renderer renders a non-bool variable node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{s1}}');
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, fooTemplate), equals('Text hello'));
  });

  test('Renderer renders a bool variable node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{b1}}');
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, fooTemplate), equals('Text true'));
  });

  test('Renderer renders an Iterable variable node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{l1}}');
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('Text [1, 2, 3]'));
  });

  test('Renderer renders a conditional section node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#b1}}Section{{/b1}}');
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, fooTemplate), equals('Text Section'));
  });

  test('Renderer renders a false conditional section node as blank', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#b1}}Section{{/b1}}');
    var foo = Foo()..b1 = false;
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted conditional section node as empty', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^b1}}Section{{/b1}}');
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted false conditional section node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^b1}}Section{{/b1}}');
    var foo = Foo()..b1 = false;
    expect(renderFoo(foo, fooTemplate), equals('Text Section'));
  });

  test('Renderer renders a repeated section node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#l1}}Num {{.}}, {{/l1}}');
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders an empty repeated section node as blank', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#l1}}Num {{.}}, {{/l1}}');
    var foo = Foo()..l1 = [];
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an empty inverted repeated section node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^l1}}Empty{{/l1}}');
    var foo = Foo()..l1 = [];
    expect(renderFoo(foo, fooTemplate), equals('Text Empty'));
  });

  test('Renderer renders an inverted repeated section node as blank', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^l1}}Empty{{/l1}}');
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders a value section node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}Foo: {{s1}}{{/foo}}');
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, fooTemplate), equals('Text Foo: hello'));
  });

  test('Renderer renders a null value section node as blank', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#s1}}"{{.}}" ({{length}}){{/s1}}');
    var foo = Foo()..s1 = null;
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted value section node as blank', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^s1}}Section{{/s1}}');
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, fooTemplate), equals('Text '));
  });

  test('Renderer renders an inverted null value section node', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{^s1}}Section{{/s1}}');
    var foo = Foo()..s1 = null;
    expect(renderFoo(foo, fooTemplate), equals('Text Section'));
  });

  test('Renderer resolves variable inside a value section', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}{{s1}}{{/foo}}');
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves variable from outer context inside a value section',
      () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}{{s2}}{{/foo}}');
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, fooTemplate), equals('Text goodbye'));
  });

  test('Renderer resolves variable with key with multiple names', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{foo.s1}}');
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with two names', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#foo}}{{foo.s1}}{{/foo}}');
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with three names', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#bar}}{{bar.foo.s1}}{{/bar}}');
    var baz = Baz()..bar = (Bar()..foo = (Foo()..s1 = 'hello'));
    expect(renderBaz(baz, fooTemplate), equals('Text hello'));
  });

  test('Renderer resolves outer variable with key with more than three names',
      () {
    var bazTemplate = getFile('/project/baz.mustache')
      ..writeAsStringSync('Text {{#bar}}{{bar.foo.baz.bar.foo.s1}}{{/bar}}');
    var baz = Baz()..bar = (Bar()..foo = (Foo()..s1 = 'hello'));
    baz.bar.foo.baz = baz;
    expect(renderBaz(baz, bazTemplate), equals('Text hello'));
  });

  test('Renderer renders a partial in the same directory', () {
    var barTemplate = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s1}}');
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Renderer renders a partial in a different directory', () {
    var barTemplate = getFile('/project/src/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>../foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s1}}');
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Renderer renders a partial in an absolute directory', () {
    var partialPath = resourceProvider.convertPath('/project/foo.mustache');
    var barTemplate = getFile('/project/src/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>$partialPath}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s1}}');
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(renderBar(bar, barTemplate), equals('Text Partial hello'));
  });

  test('Renderer renders a partial with context chain', () {
    var barTemplate = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{#foo}}{{>foo.mustache}}{{/foo}}');
    getFile('/project/foo.mustache').writeAsStringSync('Partial {{s2}}');
    var bar = Bar()
      ..foo = (Foo()..s1 = 'hello')
      ..s2 = 'goodbye';
    expect(renderBar(bar, barTemplate), equals('Text Partial goodbye'));
  });

  test('Renderer renders a partial with a heterogeneous context chain', () {
    var barTemplate = getFile('/project/bar.mustache')
      ..writeAsStringSync('Line 1 {{#foo}}{{>baz.mustache}}{{/foo}}\n'
          'Line 2 {{>baz.mustache}}');
    getFile('/project/baz.mustache')
        .writeAsStringSync('Partial {{#l1}}Section {{.}}{{/l1}}');
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

  test('Renderer throws when it cannot resolve a variable key', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{s2}}');
    var foo = Foo();
    expect(
        () => renderFoo(foo, fooTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains('Failed to resolve s2 as a property on any types in the '
                'context chain: Foo'))));
  });

  test('Renderer throws when it cannot resolve a section key', () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{#s2}}Section{{/s2}}');
    var foo = Foo();
    expect(
        () => renderFoo(foo, fooTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains('Failed to resolve s2 as a property on any types in the '
                'current context'))));
  });

  test('Renderer throws when it cannot resolve a multi-name variable key', () {
    var barTemplate = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{foo.x}}');
    var bar = Bar()..foo = Foo();
    expect(
        () => renderBar(bar, barTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains("Failed to resolve 'x' on Bar while resolving (x) as a "
                'property chain on any types in the context chain: Bar, after '
                "first resolving 'foo' to a property on Bar"))));
  });

  test('Renderer throws when it cannot resolve a multi-name section key', () {
    var barTemplate = getFile('/project/bar.mustache')
      ..writeAsStringSync('Text {{foo.x}}');
    var bar = Bar()..foo = Foo();
    expect(
        () => renderBar(bar, barTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains("Failed to resolve 'x' on Bar while resolving (x) as a "
                'property chain on any types in the context chain: Bar, after '
                "first resolving 'foo' to a property on Bar"))));
  });

  test('Renderer throws when it cannot resolve a key with a SimpleRenderer',
      () {
    var fooTemplate = getFile('/project/foo.mustache')
      ..writeAsStringSync('Text {{s1.length}}');
    var foo = Foo();
    expect(
        () => renderFoo(foo, fooTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains('Failed to resolve [length] property chain on String'))));
  });

  test('Renderer throws when it cannot read a template', () {
    var templatePath =
        resourceProvider.convertPath('/project/src/bar.mustache');
    var barTemplate = getFile(templatePath);
    expect(
        () => renderBar(Bar(), barTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains('FileSystemException when reading template '
                '"$templatePath"'))));
  });

  test('Renderer throws when it cannot read a partial', () {
    var templatePath =
        resourceProvider.convertPath('/project/src/bar.mustache');
    var barTemplate = getFile(templatePath)
      ..writeAsStringSync('Text {{#foo}}{{>missing.mustache}}{{/foo}}');
    var bar = Bar()..foo = (Foo()..s1 = 'hello');
    expect(
        () => renderBar(bar, barTemplate),
        throwsA(const TypeMatcher<MustachioResolutionError>().having(
            (e) => e.message,
            'message',
            contains(
                'FileSystemException when reading partial "missing.mustache" '
                'found in template "$templatePath"'))));
  });
}
