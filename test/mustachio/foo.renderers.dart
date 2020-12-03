// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, unnecessary_cast, unused_element, unused_import
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'foo.dart';

String renderFoo(Foo context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Foo(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Foo extends RendererBase<Foo> {
  static Map<String, Property<X_>> propertyMap<X_ extends Foo>() => {
        'b1': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.b1,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.b1 == true,
        ),
        'l1': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.l1,
          isEmptyIterable: (X_ c) => c.l1?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.l1) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        's1': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.s1,
          getProperties: Renderer_String.propertyMap,
        ),
        ...Renderer_Object.propertyMap<X_>(),
      };

  Renderer_Foo(Foo context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Foo> getProperty(String key) {
    if (propertyMap<Foo>().containsKey(key)) {
      return propertyMap<Foo>()[key];
    } else {
      return null;
    }
  }
}

String _render_String(String context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_String(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_String extends RendererBase<String> {
  static Map<String, Property<X_>> propertyMap<X_ extends String>() => {
        'codeUnits': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.codeUnits,
          isEmptyIterable: (X_ c) => c.codeUnits?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.codeUnits) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'hashCode': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
        'isEmpty': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isEmpty,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isEmpty == true,
        ),
        'isNotEmpty': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isNotEmpty,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isNotEmpty == true,
        ),
        'length': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.length,
          getProperties: Renderer_int.propertyMap,
        ),
        'runes': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.runes,
          isEmptyIterable: (X_ c) => c.runes?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.runes) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ...Renderer_Object.propertyMap<X_>(),
      };

  Renderer_String(String context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<String> getProperty(String key) {
    if (propertyMap<String>().containsKey(key)) {
      return propertyMap<String>()[key];
    } else {
      return null;
    }
  }
}

String _render_Object(Object context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Object(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Object extends RendererBase<Object> {
  static Map<String, Property<X_>> propertyMap<X_ extends Object>() => {
        'hashCode': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
      };

  Renderer_Object(Object context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap<Object>().containsKey(key)) {
      return propertyMap<Object>()[key];
    } else {
      return null;
    }
  }
}

String _render_bool(bool context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_bool(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_bool extends RendererBase<bool> {
  static Map<String, Property<X_>> propertyMap<X_ extends bool>() => {
        'hashCode': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
        ...Renderer_Object.propertyMap<X_>(),
      };

  Renderer_bool(bool context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<bool> getProperty(String key) {
    if (propertyMap<bool>().containsKey(key)) {
      return propertyMap<bool>()[key];
    } else {
      return null;
    }
  }
}

String _render_List<E>(List<E> context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_List(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_List<E> extends RendererBase<List<E>> {
  static Map<String, Property<X_>> propertyMap<E, X_ extends List<E>>() => {
        'length': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.length,
          getProperties: Renderer_int.propertyMap,
        ),
        'reversed': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.reversed,
        ),
        ...Renderer_Object.propertyMap<X_>(),
      };

  Renderer_List(List<E> context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<List<E>> getProperty(String key) {
    if (propertyMap<E, List<E>>().containsKey(key)) {
      return propertyMap<E, List<E>>()[key];
    } else {
      return null;
    }
  }
}

String _render_int(int context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_int(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_int extends RendererBase<int> {
  static Map<String, Property<X_>> propertyMap<X_ extends int>() => {
        'bitLength': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.bitLength,
          getProperties: Renderer_int.propertyMap,
        ),
        'isEven': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isEven,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isEven == true,
        ),
        'isOdd': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isOdd,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isOdd == true,
        ),
        'sign': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.sign,
          getProperties: Renderer_int.propertyMap,
        ),
        ...Renderer_num.propertyMap<X_>(),
      };

  Renderer_int(int context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<int> getProperty(String key) {
    if (propertyMap<int>().containsKey(key)) {
      return propertyMap<int>()[key];
    } else {
      return null;
    }
  }
}

String _render_num(num context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_num(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_num extends RendererBase<num> {
  static Map<String, Property<X_>> propertyMap<X_ extends num>() => {
        'hashCode': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
        'isFinite': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isFinite,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isFinite == true,
        ),
        'isInfinite': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isInfinite,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isInfinite == true,
        ),
        'isNaN': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isNaN,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isNaN == true,
        ),
        'isNegative': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.isNegative,
          getProperties: Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isNegative == true,
        ),
        'sign': Property(
          // (Foo*, String, Object, bool, List<E>, int, num)
          getValue: (X_ c) => c.sign,
          getProperties: Renderer_num.propertyMap,
        ),
        ...Renderer_Object.propertyMap<X_>(),
      };

  Renderer_num(num context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<num> getProperty(String key) {
    if (propertyMap<num>().containsKey(key)) {
      return propertyMap<num>()[key];
    } else {
      return null;
    }
  }
}
