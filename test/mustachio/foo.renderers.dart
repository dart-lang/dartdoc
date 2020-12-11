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
  static Map<String, Property<CT_>> propertyMap<CT_ extends Foo>() => {
        'b1': Property(
          getValue: (CT_ c) => c.b1,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  'Failed to resolve simple renderer use @visibleToMustache');
            }
          },
          getBool: (CT_ c) => c.b1 == true,
        ),
        'baz': Property(
          getValue: (CT_ c) => c.baz,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (Renderer_Baz.propertyMap().containsKey(name)) {
              var nextProperty = Renderer_Baz.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw PartialMustachioResolutionError(name, CT_);
            }
          },
          isNullValue: (CT_ c) => c.baz == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderBaz(c.baz, ast, parent: r);
          },
        ),
        'l1': Property(
          getValue: (CT_ c) => c.l1,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  'Failed to resolve simple renderer use @visibleToMustache');
            }
          },
          isEmptyIterable: (CT_ c) => c.l1?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.l1) {
              buffer.write(renderSimple(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        's1': Property(
          getValue: (CT_ c) => c.s1,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  'Failed to resolve simple renderer use @visibleToMustache');
            }
          },
          isNullValue: (CT_ c) => c.s1 == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.s1, ast, parent: r);
          },
        ),
        ...Renderer_Object.propertyMap<CT_>(),
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

String _render_Object(Object context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Object(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Object extends RendererBase<Object> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Object>() => {
        'hashCode': Property(
          getValue: (CT_ c) => c.hashCode,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  'Failed to resolve simple renderer use @visibleToMustache');
            }
          },
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.hashCode, ast, parent: r);
          },
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

String renderBar(Bar context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Bar(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Bar extends RendererBase<Bar> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Bar>() => {
        'foo': Property(
          getValue: (CT_ c) => c.foo,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (Renderer_Foo.propertyMap().containsKey(name)) {
              var nextProperty = Renderer_Foo.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw PartialMustachioResolutionError(name, CT_);
            }
          },
          isNullValue: (CT_ c) => c.foo == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderFoo(c.foo, ast, parent: r);
          },
        ),
        's2': Property(
          getValue: (CT_ c) => c.s2,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  'Failed to resolve simple renderer use @visibleToMustache');
            }
          },
          isNullValue: (CT_ c) => c.s2 == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.s2, ast, parent: r);
          },
        ),
        ...Renderer_Object.propertyMap<CT_>(),
      };

  Renderer_Bar(Bar context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Bar> getProperty(String key) {
    if (propertyMap<Bar>().containsKey(key)) {
      return propertyMap<Bar>()[key];
    } else {
      return null;
    }
  }
}

String renderBaz(Baz context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Baz(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Baz extends RendererBase<Baz> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Baz>() => {
        'bar': Property(
          getValue: (CT_ c) => c.bar,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (Renderer_Bar.propertyMap().containsKey(name)) {
              var nextProperty = Renderer_Bar.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw PartialMustachioResolutionError(name, CT_);
            }
          },
          isNullValue: (CT_ c) => c.bar == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderBar(c.bar, ast, parent: r);
          },
        ),
        ...Renderer_Object.propertyMap<CT_>(),
      };

  Renderer_Baz(Baz context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Baz> getProperty(String key) {
    if (propertyMap<Baz>().containsKey(key)) {
      return propertyMap<Baz>()[key];
    } else {
      return null;
    }
  }
}
