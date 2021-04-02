// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, deprecated_member_use_from_same_package
// ignore_for_file: unnecessary_cast, unused_element, unused_import, non_constant_identifier_names
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:dartdoc/src/warnings.dart';
import 'foo.dart';

String renderFoo(Foo context, Template template) {
  return _render_Foo(context, template.ast, template);
}

String _render_Foo(Foo context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Foo(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Foo extends RendererBase<Foo> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Foo>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ...Renderer_FooBase.propertyMap<Baz, CT_>(),
                'b1': Property(
                  getValue: (CT_ c) => c.b1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.b1 == true,
                ),
                'baz': Property(
                  getValue: (CT_ c) => c.baz,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Baz.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.baz == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Baz(c.baz, ast, r.template, parent: r);
                  },
                ),
                'l1': Property(
                  getValue: (CT_ c) => c.l1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'List<int>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.l1.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
                  },
                ),
                'p1': Property(
                  getValue: (CT_ c) => c.p1,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Property1.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.p1 == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Property1(c.p1, ast, r.template, parent: r);
                  },
                ),
                's1': Property(
                  getValue: (CT_ c) => c.s1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'String'),
                  isNullValue: (CT_ c) => c.s1 == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.s1, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Foo(Foo context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Foo> getProperty(String key) {
    if (propertyMap<Foo>().containsKey(key)) {
      return propertyMap<Foo>()[key];
    } else {
      return null;
    }
  }
}

String _render_Object(
    Object context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Object(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Object extends RendererBase<Object> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Object>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'hashCode': Property(
                  getValue: (CT_ c) => c.hashCode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => c.hashCode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.hashCode, ast, r.template, parent: r);
                  },
                ),
                'runtimeType': Property(
                  getValue: (CT_ c) => c.runtimeType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Type'),
                  isNullValue: (CT_ c) => c.runtimeType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.runtimeType, ast, r.template,
                        parent: r);
                  },
                ),
              });

  Renderer_Object(
      Object context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap<Object>().containsKey(key)) {
      return propertyMap<Object>()[key];
    } else {
      return null;
    }
  }
}

String _render_Property1(
    Property1 context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Property1(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Property1 extends RendererBase<Property1> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Property1>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ...Renderer_Object.propertyMap<CT_>(),
                'p2': Property(
                  getValue: (CT_ c) => c.p2,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Property2.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.p2 == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Property2(c.p2, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Property1(
      Property1 context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Property1> getProperty(String key) {
    if (propertyMap<Property1>().containsKey(key)) {
      return propertyMap<Property1>()[key];
    } else {
      return null;
    }
  }
}

String _render_Property2(
    Property2 context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Property2(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Property2 extends RendererBase<Property2> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Property2>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ...Renderer_Object.propertyMap<CT_>(),
                ...Renderer_Mixin1.propertyMap<CT_>(),
                's': Property(
                  getValue: (CT_ c) => c.s,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'String'),
                  isNullValue: (CT_ c) => c.s == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.s, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Property2(
      Property2 context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Property2> getProperty(String key) {
    if (propertyMap<Property2>().containsKey(key)) {
      return propertyMap<Property2>()[key];
    } else {
      return null;
    }
  }
}

String _render_Mixin1(
    Mixin1 context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Mixin1(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Mixin1 extends RendererBase<Mixin1> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Mixin1>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'p3': Property(
                  getValue: (CT_ c) => c.p3,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Property3.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.p3 == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Property3(c.p3, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Mixin1(
      Mixin1 context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Mixin1> getProperty(String key) {
    if (propertyMap<Mixin1>().containsKey(key)) {
      return propertyMap<Mixin1>()[key];
    } else {
      return null;
    }
  }
}

String _render_Property3(
    Property3 context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Property3(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Property3 extends RendererBase<Property3> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Property3>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ...Renderer_Object.propertyMap<CT_>(),
                's': Property(
                  getValue: (CT_ c) => c.s,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'String'),
                  isNullValue: (CT_ c) => c.s == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.s, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Property3(
      Property3 context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Property3> getProperty(String key) {
    if (propertyMap<Property3>().containsKey(key)) {
      return propertyMap<Property3>()[key];
    } else {
      return null;
    }
  }
}

String _render_FooBase<T extends Object>(
    FooBase<T> context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_FooBase(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_FooBase<T extends Object> extends RendererBase<FooBase<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>>
      propertyMap<T extends Object, CT_ extends FooBase>() =>
          _propertyMapCache.putIfAbsent(
              CT_,
              () => {
                    ...Renderer_Object.propertyMap<CT_>(),
                    'baz': Property(
                      getValue: (CT_ c) => c.baz,
                      renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) {
                        if (remainingNames.isEmpty) {
                          return self.getValue(c).toString();
                        }
                        var name = remainingNames.first;
                        var nextProperty =
                            Renderer_Object.propertyMap().getValue(name);
                        return nextProperty.renderVariable(self.getValue(c),
                            nextProperty, [...remainingNames.skip(1)]);
                      },
                    ),
                  });

  Renderer_FooBase(
      FooBase<T> context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<FooBase<T>> getProperty(String key) {
    if (propertyMap<T, FooBase>().containsKey(key)) {
      return propertyMap<T, FooBase>()[key];
    } else {
      return null;
    }
  }
}

String renderBar(Bar context, Template template) {
  return _render_Bar(context, template.ast, template);
}

String _render_Bar(Bar context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Bar(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Bar extends RendererBase<Bar> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Bar>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ...Renderer_Object.propertyMap<CT_>(),
                'baz': Property(
                  getValue: (CT_ c) => c.baz,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Baz.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.baz == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Baz(c.baz, ast, r.template, parent: r);
                  },
                ),
                'foo': Property(
                  getValue: (CT_ c) => c.foo,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Foo.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.foo == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Foo(c.foo, ast, r.template, parent: r);
                  },
                ),
                'l1': Property(
                  getValue: (CT_ c) => c.l1,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.l1 == true,
                ),
                's2': Property(
                  getValue: (CT_ c) => c.s2,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'String'),
                  isNullValue: (CT_ c) => c.s2 == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.s2, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Bar(Bar context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Bar> getProperty(String key) {
    if (propertyMap<Bar>().containsKey(key)) {
      return propertyMap<Bar>()[key];
    } else {
      return null;
    }
  }
}

String renderBaz(Baz context, Template template) {
  return _render_Baz(context, template.ast, template);
}

String _render_Baz(Baz context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = Renderer_Baz(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class Renderer_Baz extends RendererBase<Baz> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Baz>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ...Renderer_Object.propertyMap<CT_>(),
                'bar': Property(
                  getValue: (CT_ c) => c.bar,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        Renderer_Bar.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.bar == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Bar(c.bar, ast, r.template, parent: r);
                  },
                ),
              });

  Renderer_Baz(Baz context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Baz> getProperty(String key) {
    if (propertyMap<Baz>().containsKey(key)) {
      return propertyMap<Baz>()[key];
    } else {
      return null;
    }
  }
}
