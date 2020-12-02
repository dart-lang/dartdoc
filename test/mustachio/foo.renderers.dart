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
  static Map<String, Property> propertyMap() => {
        'b1': Property(
          getValue: (Object c) => (c as Foo).b1,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Foo).b1 == true,
        ),
        's1': Property(
          getValue: (Object c) => (c as Foo).s1,
          getProperties: Renderer_String.propertyMap,
        ),
        ...Renderer_Object.propertyMap(),
      };

  Renderer_Foo(Foo context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
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
  static Map<String, Property> propertyMap() => {
        'codeUnits': Property(
          getValue: (Object c) => (c as String).codeUnits,
          isEmptyIterable: (Object c) =>
              (c as String).codeUnits?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<String> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as String).codeUnits) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'hashCode': Property(
          getValue: (Object c) => (c as String).hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
        'isEmpty': Property(
          getValue: (Object c) => (c as String).isEmpty,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as String).isEmpty == true,
        ),
        'isNotEmpty': Property(
          getValue: (Object c) => (c as String).isNotEmpty,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as String).isNotEmpty == true,
        ),
        'length': Property(
          getValue: (Object c) => (c as String).length,
          getProperties: Renderer_int.propertyMap,
        ),
        'runes': Property(
          getValue: (Object c) => (c as String).runes,
          isEmptyIterable: (Object c) => (c as String).runes?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<String> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as String).runes) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ...Renderer_Object.propertyMap(),
      };

  Renderer_String(String context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
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
  static Map<String, Property> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => (c as Object).hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
      };

  Renderer_Object(Object context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
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
  static Map<String, Property> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => (c as bool).hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
        ...Renderer_Object.propertyMap(),
      };

  Renderer_bool(bool context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
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
  static Map<String, Property> propertyMap() => {
        'bitLength': Property(
          getValue: (Object c) => (c as int).bitLength,
          getProperties: Renderer_int.propertyMap,
        ),
        'isEven': Property(
          getValue: (Object c) => (c as int).isEven,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as int).isEven == true,
        ),
        'isOdd': Property(
          getValue: (Object c) => (c as int).isOdd,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as int).isOdd == true,
        ),
        'sign': Property(
          getValue: (Object c) => (c as int).sign,
          getProperties: Renderer_int.propertyMap,
        ),
        ...Renderer_num.propertyMap(),
      };

  Renderer_int(int context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
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
  static Map<String, Property> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => (c as num).hashCode,
          getProperties: Renderer_int.propertyMap,
        ),
        'isFinite': Property(
          getValue: (Object c) => (c as num).isFinite,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isFinite == true,
        ),
        'isInfinite': Property(
          getValue: (Object c) => (c as num).isInfinite,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isInfinite == true,
        ),
        'isNaN': Property(
          getValue: (Object c) => (c as num).isNaN,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isNaN == true,
        ),
        'isNegative': Property(
          getValue: (Object c) => (c as num).isNegative,
          getProperties: Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isNegative == true,
        ),
        'sign': Property(
          getValue: (Object c) => (c as num).sign,
          getProperties: Renderer_num.propertyMap,
        ),
        ...Renderer_Object.propertyMap(),
      };

  Renderer_num(num context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}
