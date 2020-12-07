import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:test/test.dart';
import 'foo.dart';
import 'foo.renderers.dart';

void main() {
  test('property map contains all public getters', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap.keys, hasLength(4));
    expect(propertyMap['b1'], isNotNull);
    expect(propertyMap['s1'], isNotNull);
    expect(propertyMap['l1'], isNotNull);
    expect(propertyMap['hashCode'], isNotNull);
  });

  test('property map contains valid bool Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['b1'].getValue, isNotNull);
    expect(propertyMap['b1'].getProperties, isNotNull);
    expect(propertyMap['b1'].getBool, isNotNull);
    expect(propertyMap['b1'].isEmptyIterable, isNull);
    expect(propertyMap['b1'].renderIterable, isNull);
    expect(propertyMap['b1'].isNullValue, isNull);
    expect(propertyMap['b1'].renderValue, isNull);
  });

  test('property map contains valid Iterable Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['l1'].getValue, isNotNull);
    expect(propertyMap['l1'].getProperties, isNotNull);
    expect(propertyMap['l1'].getBool, isNull);
    expect(propertyMap['l1'].isEmptyIterable, isNotNull);
    expect(propertyMap['l1'].renderIterable, isNotNull);
    expect(propertyMap['l1'].isNullValue, isNull);
    expect(propertyMap['l1'].renderValue, isNull);
  });

  test('property map contains valid non-bool, non-Iterable Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['s1'].getValue, isNotNull);
    expect(propertyMap['s1'].getProperties, isNotNull);
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
    var parser = MustachioParser('Text {{s1}}');
    var ast = parser.parse();
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, ast), equals('Text hello'));
  });

  test('Renderer renders a bool variable node', () {
    var parser = MustachioParser('Text {{b1}}');
    var ast = parser.parse();
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, ast), equals('Text true'));
  });

  test('Renderer renders an Iterable variable node', () {
    var parser = MustachioParser('Text {{l1}}');
    var ast = parser.parse();
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, ast), equals('Text [1, 2, 3]'));
  });

  test('Renderer renders a conditional section node', () {
    var parser = MustachioParser('Text {{#b1}}Section{{/b1}}');
    var ast = parser.parse();
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, ast), equals('Text Section'));
  });

  test('Renderer renders a false conditional section node as blank', () {
    var parser = MustachioParser('Text {{#b1}}Section{{/b1}}');
    var ast = parser.parse();
    var foo = Foo()..b1 = false;
    expect(renderFoo(foo, ast), equals('Text '));
  });

  test('Renderer renders an inverted conditional section node as empty', () {
    var parser = MustachioParser('Text {{^b1}}Section{{/b1}}');
    var ast = parser.parse();
    var foo = Foo()..b1 = true;
    expect(renderFoo(foo, ast), equals('Text '));
  });

  test('Renderer renders an inverted false conditional section node', () {
    var parser = MustachioParser('Text {{^b1}}Section{{/b1}}');
    var ast = parser.parse();
    var foo = Foo()..b1 = false;
    expect(renderFoo(foo, ast), equals('Text Section'));
  });

  test('Renderer renders a repeated section node', () {
    var parser = MustachioParser('Text {{#l1}}Num {{.}}, {{/l1}}');
    var ast = parser.parse();
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, ast), equals('Text Num 1, Num 2, Num 3, '));
  });

  test('Renderer renders an empty repeated section node as blank', () {
    var parser = MustachioParser('Text {{#l1}}Num {{.}}, {{/l1}}');
    var ast = parser.parse();
    var foo = Foo()..l1 = [];
    expect(renderFoo(foo, ast), equals('Text '));
  });

  test('Renderer renders an empty inverted repeated section node', () {
    var parser = MustachioParser('Text {{^l1}}Empty{{/l1}}');
    var ast = parser.parse();
    var foo = Foo()..l1 = [];
    expect(renderFoo(foo, ast), equals('Text Empty'));
  });

  test('Renderer renders an inverted repeated section node as blank', () {
    var parser = MustachioParser('Text {{^l1}}Empty{{/l1}}');
    var ast = parser.parse();
    var foo = Foo()..l1 = [1, 2, 3];
    expect(renderFoo(foo, ast), equals('Text '));
  });

  test('Renderer renders a value section node', () {
    var parser = MustachioParser('Text {{#s1}}"{{.}}" ({{length}}){{/s1}}');
    var ast = parser.parse();
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, ast), equals('Text "hello" (5)'));
  });

  test('Renderer renders a null value section node as blank', () {
    var parser = MustachioParser('Text {{#s1}}"{{.}}" ({{length}}){{/s1}}');
    var ast = parser.parse();
    var foo = Foo()..s1 = null;
    expect(renderFoo(foo, ast), equals('Text '));
  });

  test('Renderer renders an inverted value section node as blank', () {
    var parser = MustachioParser('Text {{^s1}}Section{{/s1}}');
    var ast = parser.parse();
    var foo = Foo()..s1 = 'hello';
    expect(renderFoo(foo, ast), equals('Text '));
  });

  test('Renderer renders an inverted null value section node', () {
    var parser = MustachioParser('Text {{^s1}}Section{{/s1}}');
    var ast = parser.parse();
    var foo = Foo()..s1 = null;
    expect(renderFoo(foo, ast), equals('Text Section'));
  });

  test('Renderer throws when it cannot resolve a variable key', () {
    var parser = MustachioParser('Text {{s2}}');
    var ast = parser.parse();
    var foo = Foo();
    expect(() => renderFoo(foo, ast),
        throwsA(const TypeMatcher<MustachioResolutionError>()));
  });

  test('Renderer throws when it cannot resolve a section key', () {
    var parser = MustachioParser('Text {{#s2}}Section{{/s2}}');
    var ast = parser.parse();
    var foo = Foo();
    expect(() => renderFoo(foo, ast),
        throwsA(const TypeMatcher<MustachioResolutionError>()));
  });

  test('Renderer throws when it cannot resolve a multi-name variable key', () {
    var parser = MustachioParser('Text {{s1.len}}');
    var ast = parser.parse();
    var foo = Foo();
    expect(() => renderFoo(foo, ast),
        throwsA(const TypeMatcher<MustachioResolutionError>()));
  });

  test('Renderer throws when it cannot resolve a multi-name section key', () {
    var parser = MustachioParser('Text {{s1.len}}');
    var ast = parser.parse();
    var foo = Foo();
    expect(() => renderFoo(foo, ast),
        throwsA(const TypeMatcher<MustachioResolutionError>()));
  });
}
