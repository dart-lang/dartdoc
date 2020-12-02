import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:test/test.dart';
import 'foo.dart';
import 'foo.renderers.dart';

void main() {
  test('property map contains all public getters', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap.keys, hasLength(3));
    expect(propertyMap['b1'], isNotNull);
    expect(propertyMap['s1'], isNotNull);
    expect(propertyMap['hashCode'], isNotNull);
  });

  test('property map contains valid bool Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['b1'].getValue, isNotNull);
    expect(propertyMap['b1'].getProperties, isNotNull);
    expect(propertyMap['b1'].getBool, isNotNull);
  });

  test('property map contains valid non-bool Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    expect(propertyMap['s1'].getValue, isNotNull);
    expect(propertyMap['s1'].getProperties, isNotNull);
    expect(propertyMap['s1'].getBool, isNull);
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
}
