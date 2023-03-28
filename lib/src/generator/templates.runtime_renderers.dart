// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, deprecated_member_use_from_same_package
// ignore_for_file: non_constant_identifier_names, unnecessary_string_escapes
// ignore_for_file: unused_import
// ignore_for_file: use_super_parameters
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/warnings.dart';
import 'templates.dart';

void _render_Accessor(Accessor context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Accessor(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Accessor extends RendererBase<Accessor> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Accessor>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'definingCombo': Property(
                  getValue: (CT_ c) => c.definingCombo,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty = _Renderer_GetterSetterCombo.propertyMap()
                        .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as GetterSetterCombo,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.definingCombo, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['GetterSetterCombo']!);
                  },
                ),
                'documentationComment': Property(
                  getValue: (CT_ c) => c.documentationComment,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.documentationComment, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PropertyAccessorElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['PropertyAccessorElement']!);
                  },
                ),
                'enclosingCombo': Property(
                  getValue: (CT_ c) => c.enclosingCombo,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty = _Renderer_GetterSetterCombo.propertyMap()
                        .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as GetterSetterCombo,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.enclosingCombo, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['GetterSetterCombo']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasDocumentationComment': Property(
                  getValue: (CT_ c) => c.hasDocumentationComment,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentationComment == true,
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'isGetter': Property(
                  getValue: (CT_ c) => c.isGetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isGetter == true,
                ),
                'isSetter': Property(
                  getValue: (CT_ c) => c.isSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSetter == true,
                ),
                'isSynthetic': Property(
                  getValue: (CT_ c) => c.isSynthetic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSynthetic == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Callable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Callable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Callable(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'namePart': Property(
                  getValue: (CT_ c) => c.namePart,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.namePart, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'originalMember': Property(
                  getValue: (CT_ c) => c.originalMember,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ExecutableMember'),
                  isNullValue: (CT_ c) => c.originalMember == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.originalMember, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ExecutableMember']!);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'sourceCode': Property(
                  getValue: (CT_ c) => c.sourceCode,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceCode, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Accessor(Accessor context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Accessor>? getProperty(String key) {
    if (propertyMap<Accessor>().containsKey(key)) {
      return propertyMap<Accessor>()[key];
    } else {
      return null;
    }
  }
}

void _render_Annotation(Annotation context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Annotation(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Annotation extends RendererBase<Annotation> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Annotation>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Feature.propertyMap<CT_>(),
                ..._Renderer_ModelBuilder.propertyMap<CT_>(),
                'annotation': Property(
                  getValue: (CT_ c) => c.annotation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ElementAnnotation'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.annotation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ElementAnnotation']!);
                  },
                ),
                'cssClassName': Property(
                  getValue: (CT_ c) => c.cssClassName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.cssClassName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hashCode': Property(
                  getValue: (CT_ c) => c.hashCode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.hashCode, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedNameWithParameters': Property(
                  getValue: (CT_ c) => c.linkedNameWithParameters,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedNameWithParameters, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
                'parameterText': Property(
                  getValue: (CT_ c) => c.parameterText,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.parameterText, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Annotation(Annotation context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Annotation>? getProperty(String key) {
    if (propertyMap<Annotation>().containsKey(key)) {
      return propertyMap<Annotation>()[key];
    } else {
      return null;
    }
  }
}

void _render_Callable(Callable context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Callable(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Callable extends RendererBase<Callable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Callable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, sink, parent: r));
                  },
                ),
                'returnType': Property(
                  getValue: (CT_ c) => c.returnType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.returnType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'type': Property(
                  getValue: (CT_ c) => c.type,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FunctionType'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.type, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['FunctionType']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Callable(Callable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Callable>? getProperty(String key) {
    if (propertyMap<Callable>().containsKey(key)) {
      return propertyMap<Callable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Canonicalization extends RendererBase<Canonicalization> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends Canonicalization>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'canonicalLibrary': Property(
                  getValue: (CT_ c) => c.canonicalLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.canonicalLibrary!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.locationPieces.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Canonicalization(Canonicalization context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Canonicalization>? getProperty(String key) {
    if (propertyMap<Canonicalization>().containsKey(key)) {
      return propertyMap<Canonicalization>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Categorization extends RendererBase<Categorization> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Categorization>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'categories': Property(
                  getValue: (CT_ c) => c.categories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.categories.map((e) =>
                        _render_Category(e, ast, r.template, sink, parent: r));
                  },
                ),
                'categoryNames': Property(
                  getValue: (CT_ c) => c.categoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  isNullValue: (CT_ c) => c.categoryNames == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.categoryNames, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['List']!);
                  },
                ),
                'displayedCategories': Property(
                  getValue: (CT_ c) => c.displayedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.displayedCategories.map((e) =>
                        _render_Category(e, ast, r.template, sink, parent: r));
                  },
                ),
                'hasCategorization': Property(
                  getValue: (CT_ c) => c.hasCategorization,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasCategorization == true,
                ),
                'hasCategoryNames': Property(
                  getValue: (CT_ c) => c.hasCategoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasCategoryNames == true,
                ),
                'hasImage': Property(
                  getValue: (CT_ c) => c.hasImage,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasImage == true,
                ),
                'hasSamples': Property(
                  getValue: (CT_ c) => c.hasSamples,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasSamples == true,
                ),
                'hasSubCategoryNames': Property(
                  getValue: (CT_ c) => c.hasSubCategoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasSubCategoryNames == true,
                ),
                'image': Property(
                  getValue: (CT_ c) => c.image,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.image == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.image!, ast, r.template, sink, parent: r);
                  },
                ),
                'samples': Property(
                  getValue: (CT_ c) => c.samples,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.samples == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.samples!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'subCategoryNames': Property(
                  getValue: (CT_ c) => c.subCategoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  isNullValue: (CT_ c) => c.subCategoryNames == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.subCategoryNames, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['List']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Categorization(Categorization context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Categorization>? getProperty(String key) {
    if (propertyMap<Categorization>().containsKey(key)) {
      return propertyMap<Categorization>()[key];
    } else {
      return null;
    }
  }
}

void _render_Category(Category context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Category(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Category extends RendererBase<Category> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Category>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Nameable.propertyMap<CT_>(),
                ..._Renderer_Warnable.propertyMap<CT_>(),
                ..._Renderer_CommentReferable.propertyMap<CT_>(),
                ..._Renderer_Locatable.propertyMap<CT_>(),
                ..._Renderer_Canonicalization.propertyMap<CT_>(),
                ..._Renderer_MarkdownFileDocumentation.propertyMap<CT_>(),
                ..._Renderer_LibraryContainer.propertyMap<CT_>(),
                ..._Renderer_TopLevelContainer.propertyMap<CT_>(),
                ..._Renderer_Indexable.propertyMap<CT_>(),
                ..._Renderer_ModelBuilder.propertyMap<CT_>(),
                'canonicalLibrary': Property(
                  getValue: (CT_ c) => c.canonicalLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.canonicalLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'categoryDefinition': Property(
                  getValue: (CT_ c) => c.categoryDefinition,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CategoryDefinition'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.categoryDefinition, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CategoryDefinition']!);
                  },
                ),
                'categoryIndex': Property(
                  getValue: (CT_ c) => c.categoryIndex,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.categoryIndex, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'categoryLabel': Property(
                  getValue: (CT_ c) => c.categoryLabel,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.categoryLabel, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'classes': Property(
                  getValue: (CT_ c) => c.classes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.classes.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.config, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DartdocOptionContext']!);
                  },
                ),
                'constants': Property(
                  getValue: (CT_ c) => c.constants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constants.map((e) => _render_TopLevelVariable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'containerOrder': Property(
                  getValue: (CT_ c) => c.containerOrder,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.containerOrder.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'documentationFile': Property(
                  getValue: (CT_ c) => c.documentationFile,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'File'),
                  isNullValue: (CT_ c) => c.documentationFile == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.documentationFile, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['File']!);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Locatable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentationFrom.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Locatable']!));
                  },
                ),
                'documentedWhere': Property(
                  getValue: (CT_ c) => c.documentedWhere,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DocumentLocation'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.documentedWhere, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DocumentLocation']!);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'enclosingName': Property(
                  getValue: (CT_ c) => c.enclosingName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.enclosingName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'enums': Property(
                  getValue: (CT_ c) => c.enums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Enum>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.enums.map((e) =>
                        _render_Enum(e, ast, r.template, sink, parent: r));
                  },
                ),
                'exceptions': Property(
                  getValue: (CT_ c) => c.exceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.exceptions.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'extensions': Property(
                  getValue: (CT_ c) => c.extensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.extensions.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'functions': Property(
                  getValue: (CT_ c) => c.functions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelFunction>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.functions.map((e) => _render_ModelFunction(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'isDocumented': Property(
                  getValue: (CT_ c) => c.isDocumented,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDocumented == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'mixins': Property(
                  getValue: (CT_ c) => c.mixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Mixin>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.mixins.map((e) =>
                        _render_Mixin(e, ast, r.template, sink, parent: r));
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'package': Property(
                  getValue: (CT_ c) => c.package,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.package, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
                'properties': Property(
                  getValue: (CT_ c) => c.properties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.properties.map((e) => _render_TopLevelVariable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'sortKey': Property(
                  getValue: (CT_ c) => c.sortKey,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sortKey, ast, r.template, sink, parent: r);
                  },
                ),
                'typedefs': Property(
                  getValue: (CT_ c) => c.typedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Typedef>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typedefs.map((e) =>
                        _render_Typedef(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Category(Category context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Category>? getProperty(String key) {
    if (propertyMap<Category>().containsKey(key)) {
      return propertyMap<Category>()[key];
    } else {
      return null;
    }
  }
}

String renderCategory(CategoryTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_CategoryTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_CategoryTemplateData(CategoryTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_CategoryTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_CategoryTemplateData
    extends RendererBase<CategoryTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends CategoryTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Category, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<Category, CT_>(),
                'category': Property(
                  getValue: (CT_ c) => c.category,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Category.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Category,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Category(c.category, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Category.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Category,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Category(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_CategoryTemplateData(CategoryTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<CategoryTemplateData>? getProperty(String key) {
    if (propertyMap<CategoryTemplateData>().containsKey(key)) {
      return propertyMap<CategoryTemplateData>()[key];
    } else {
      return null;
    }
  }
}

void _render_Class(
    Class context, List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Class(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Class extends RendererBase<Class> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Class>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_InheritingContainer.propertyMap<CT_>(),
                ..._Renderer_Constructable.propertyMap<CT_>(),
                ..._Renderer_TypeImplementing.propertyMap<CT_>(),
                ..._Renderer_MixedInTypes.propertyMap<CT_>(),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allModelElements.map((e) => _render_ModelElement(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ClassElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['ClassElement']!);
                  },
                ),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'inheritanceChain': Property(
                  getValue: (CT_ c) => c.inheritanceChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritanceChain.map((e) =>
                        _render_InheritingContainer(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'isAbstract': Property(
                  getValue: (CT_ c) => c.isAbstract,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAbstract == true,
                ),
                'isBase': Property(
                  getValue: (CT_ c) => c.isBase,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isBase == true,
                ),
                'isErrorOrException': Property(
                  getValue: (CT_ c) => c.isErrorOrException,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isErrorOrException == true,
                ),
                'isFinal': Property(
                  getValue: (CT_ c) => c.isFinal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFinal == true,
                ),
                'isInterface': Property(
                  getValue: (CT_ c) => c.isInterface,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInterface == true,
                ),
                'isMixinClass': Property(
                  getValue: (CT_ c) => c.isMixinClass,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isMixinClass == true,
                ),
                'isSealed': Property(
                  getValue: (CT_ c) => c.isSealed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSealed == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'relationshipsClass': Property(
                  getValue: (CT_ c) => c.relationshipsClass,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.relationshipsClass, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Class(Class context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Class>? getProperty(String key) {
    if (propertyMap<Class>().containsKey(key)) {
      return propertyMap<Class>()[key];
    } else {
      return null;
    }
  }
}

String renderClass(ClassTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_ClassTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_ClassTemplateData(ClassTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_ClassTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ClassTemplateData extends RendererBase<ClassTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ClassTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_InheritingContainerTemplateData.propertyMap<Class,
                    CT_>(),
                'clazz': Property(
                  getValue: (CT_ c) => c.clazz,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Class.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Class,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Class(c.clazz, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ClassTemplateData(ClassTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ClassTemplateData>? getProperty(String key) {
    if (propertyMap<ClassTemplateData>().containsKey(key)) {
      return propertyMap<ClassTemplateData>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_CommentReferable extends RendererBase<CommentReferable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends CommentReferable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceGrandparentOverrides': Property(
                  getValue: (CT_ c) => c.referenceGrandparentOverrides,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  isNullValue: (CT_ c) =>
                      c.referenceGrandparentOverrides == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(
                        c.referenceGrandparentOverrides, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Iterable']!);
                  },
                ),
                'referenceName': Property(
                  getValue: (CT_ c) => c.referenceName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.referenceName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'scope': Property(
                  getValue: (CT_ c) => c.scope,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Scope'),
                  isNullValue: (CT_ c) => c.scope == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.scope, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Scope']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_CommentReferable(CommentReferable context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<CommentReferable>? getProperty(String key) {
    if (propertyMap<CommentReferable>().containsKey(key)) {
      return propertyMap<CommentReferable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Constructable extends RendererBase<Constructable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Constructable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'constructors': Property(
                  getValue: (CT_ c) => c.constructors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Constructor>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constructors.map((e) => _render_Constructor(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'hasPublicConstructors': Property(
                  getValue: (CT_ c) => c.hasPublicConstructors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicConstructors == true,
                ),
                'publicConstructorsSorted': Property(
                  getValue: (CT_ c) => c.publicConstructorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Constructor>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicConstructorsSorted.map((e) =>
                        _render_Constructor(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Constructable(Constructable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Constructable>? getProperty(String key) {
    if (propertyMap<Constructable>().containsKey(key)) {
      return propertyMap<Constructable>()[key];
    } else {
      return null;
    }
  }
}

void _render_Constructor(Constructor context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Constructor(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Constructor extends RendererBase<Constructor> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Constructor>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                ..._Renderer_ContainerMember.propertyMap<CT_>(),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ConstructorElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ConstructorElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullKind': Property(
                  getValue: (CT_ c) => c.fullKind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullKind, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'isConst': Property(
                  getValue: (CT_ c) => c.isConst,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isConst == true,
                ),
                'isDefaultConstructor': Property(
                  getValue: (CT_ c) => c.isDefaultConstructor,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDefaultConstructor == true,
                ),
                'isFactory': Property(
                  getValue: (CT_ c) => c.isFactory,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFactory == true,
                ),
                'isUnnamedConstructor': Property(
                  getValue: (CT_ c) => c.isUnnamedConstructor,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isUnnamedConstructor == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Callable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Callable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Callable(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'nameWithGenerics': Property(
                  getValue: (CT_ c) => c.nameWithGenerics,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nameWithGenerics, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceName': Property(
                  getValue: (CT_ c) => c.referenceName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.referenceName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'shortName': Property(
                  getValue: (CT_ c) => c.shortName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.shortName == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.shortName!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Constructor(Constructor context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Constructor>? getProperty(String key) {
    if (propertyMap<Constructor>().containsKey(key)) {
      return propertyMap<Constructor>()[key];
    } else {
      return null;
    }
  }
}

String renderConstructor(ConstructorTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_ConstructorTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_ConstructorTemplateData(ConstructorTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_ConstructorTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ConstructorTemplateData
    extends RendererBase<ConstructorTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ConstructorTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Constructor, CT_>(),
                ..._Renderer_TwoDirectoriesDown.propertyMap<Constructor, CT_>(),
                'constructable': Property(
                  getValue: (CT_ c) => c.constructable,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Constructable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Constructable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.constructable, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['Constructable']!);
                  },
                ),
                'constructor': Property(
                  getValue: (CT_ c) => c.constructor,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Constructor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Constructor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Constructor(c.constructor, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'container': Property(
                  getValue: (CT_ c) => c.container,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.container, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, sink, parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Constructor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Constructor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Constructor(c.self, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sidebarForContainer': Property(
                  getValue: (CT_ c) => c.sidebarForContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ConstructorTemplateData(ConstructorTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ConstructorTemplateData>? getProperty(String key) {
    if (propertyMap<ConstructorTemplateData>().containsKey(key)) {
      return propertyMap<ConstructorTemplateData>()[key];
    } else {
      return null;
    }
  }
}

void _render_Container(Container context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Container(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Container extends RendererBase<Container> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Container>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                'allCanonicalModelElements': Property(
                  getValue: (CT_ c) => c.allCanonicalModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allCanonicalModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'allElements': Property(
                  getValue: (CT_ c) => c.allElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Element>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allElements.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!));
                  },
                ),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allModelElements.map((e) => _render_ModelElement(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'constantFields': Property(
                  getValue: (CT_ c) => c.constantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constantFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'declaredFields': Property(
                  getValue: (CT_ c) => c.declaredFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'declaredMethods': Property(
                  getValue: (CT_ c) => c.declaredMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'declaredOperators': Property(
                  getValue: (CT_ c) => c.declaredOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredOperators.map((e) =>
                        _render_Operator(e, ast, r.template, sink, parent: r));
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasInstanceFields': Property(
                  getValue: (CT_ c) => c.hasInstanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasInstanceFields == true,
                ),
                'hasParameters': Property(
                  getValue: (CT_ c) => c.hasParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasParameters == true,
                ),
                'hasPublicConstantFields': Property(
                  getValue: (CT_ c) => c.hasPublicConstantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicConstantFields == true,
                ),
                'hasPublicConstructors': Property(
                  getValue: (CT_ c) => c.hasPublicConstructors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicConstructors == true,
                ),
                'hasPublicEnumValues': Property(
                  getValue: (CT_ c) => c.hasPublicEnumValues,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicEnumValues == true,
                ),
                'hasPublicInstanceFields': Property(
                  getValue: (CT_ c) => c.hasPublicInstanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInstanceFields == true,
                ),
                'hasPublicInstanceMethods': Property(
                  getValue: (CT_ c) => c.hasPublicInstanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInstanceMethods == true,
                ),
                'hasPublicInstanceOperators': Property(
                  getValue: (CT_ c) => c.hasPublicInstanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInstanceOperators == true,
                ),
                'hasPublicStaticFields': Property(
                  getValue: (CT_ c) => c.hasPublicStaticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicStaticFields == true,
                ),
                'hasPublicStaticMethods': Property(
                  getValue: (CT_ c) => c.hasPublicStaticMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicStaticMethods == true,
                ),
                'hasPublicVariableStaticFields': Property(
                  getValue: (CT_ c) => c.hasPublicVariableStaticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicVariableStaticFields == true,
                ),
                'instanceAccessors': Property(
                  getValue: (CT_ c) => c.instanceAccessors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Accessor>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceAccessors.map((e) =>
                        _render_Accessor(e, ast, r.template, sink, parent: r));
                  },
                ),
                'instanceFields': Property(
                  getValue: (CT_ c) => c.instanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'instanceMethods': Property(
                  getValue: (CT_ c) => c.instanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'instanceOperators': Property(
                  getValue: (CT_ c) => c.instanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceOperators.map((e) =>
                        _render_Operator(e, ast, r.template, sink, parent: r));
                  },
                ),
                'isClass': Property(
                  getValue: (CT_ c) => c.isClass,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isClass == true,
                ),
                'isClassOrEnum': Property(
                  getValue: (CT_ c) => c.isClassOrEnum,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isClassOrEnum == true,
                ),
                'isClassOrEnumOrExtension': Property(
                  getValue: (CT_ c) => c.isClassOrEnumOrExtension,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isClassOrEnumOrExtension == true,
                ),
                'isEnum': Property(
                  getValue: (CT_ c) => c.isEnum,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isEnum == true,
                ),
                'isExtension': Property(
                  getValue: (CT_ c) => c.isExtension,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isExtension == true,
                ),
                'isMixin': Property(
                  getValue: (CT_ c) => c.isMixin,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isMixin == true,
                ),
                'publicConstantFields': Property(
                  getValue: (CT_ c) => c.publicConstantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicConstantFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicConstantFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicConstantFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicConstantFieldsSorted.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicConstructorsSorted': Property(
                  getValue: (CT_ c) => c.publicConstructorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Constructor>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicConstructorsSorted.map((e) =>
                        _render_Constructor(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicEnumValues': Property(
                  getValue: (CT_ c) => c.publicEnumValues,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicEnumValues.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInheritedInstanceFields': Property(
                  getValue: (CT_ c) => c.publicInheritedInstanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.publicInheritedInstanceFields == true,
                ),
                'publicInheritedInstanceMethods': Property(
                  getValue: (CT_ c) => c.publicInheritedInstanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.publicInheritedInstanceMethods == true,
                ),
                'publicInheritedInstanceOperators': Property(
                  getValue: (CT_ c) => c.publicInheritedInstanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) =>
                      c.publicInheritedInstanceOperators == true,
                ),
                'publicInstanceFields': Property(
                  getValue: (CT_ c) => c.publicInstanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInstanceFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInstanceFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicInstanceFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInstanceFieldsSorted.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInstanceMethods': Property(
                  getValue: (CT_ c) => c.publicInstanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInstanceMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInstanceMethodsSorted': Property(
                  getValue: (CT_ c) => c.publicInstanceMethodsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInstanceMethodsSorted.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInstanceOperators': Property(
                  getValue: (CT_ c) => c.publicInstanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInstanceOperators.map((e) =>
                        _render_Operator(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInstanceOperatorsSorted': Property(
                  getValue: (CT_ c) => c.publicInstanceOperatorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Operator>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInstanceOperatorsSorted.map((e) =>
                        _render_Operator(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicStaticFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicStaticFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicStaticFieldsSorted.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicStaticMethodsSorted': Property(
                  getValue: (CT_ c) => c.publicStaticMethodsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicStaticMethodsSorted.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicVariableStaticFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicVariableStaticFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicVariableStaticFieldsSorted.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'relationshipsClass': Property(
                  getValue: (CT_ c) => c.relationshipsClass,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.relationshipsClass, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'scope': Property(
                  getValue: (CT_ c) => c.scope,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Scope'),
                  isNullValue: (CT_ c) => c.scope == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.scope, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Scope']!);
                  },
                ),
                'staticAccessors': Property(
                  getValue: (CT_ c) => c.staticAccessors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Accessor>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.staticAccessors.map((e) =>
                        _render_Accessor(e, ast, r.template, sink, parent: r));
                  },
                ),
                'staticFields': Property(
                  getValue: (CT_ c) => c.staticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.staticFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'staticMethods': Property(
                  getValue: (CT_ c) => c.staticMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.staticMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'variableStaticFields': Property(
                  getValue: (CT_ c) => c.variableStaticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.variableStaticFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Container(Container context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Container>? getProperty(String key) {
    if (propertyMap<Container>().containsKey(key)) {
      return propertyMap<Container>()[key];
    } else {
      return null;
    }
  }
}

void _render_ContainerAccessor(ContainerAccessor context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_ContainerAccessor(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ContainerAccessor extends RendererBase<ContainerAccessor> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ContainerAccessor>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Accessor.propertyMap<CT_>(),
                ..._Renderer_ContainerMember.propertyMap<CT_>(),
                ..._Renderer_Inheritable.propertyMap<CT_>(),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'isCovariant': Property(
                  getValue: (CT_ c) => c.isCovariant,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCovariant == true,
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'overriddenElement': Property(
                  getValue: (CT_ c) => c.overriddenElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty = _Renderer_ContainerAccessor.propertyMap()
                        .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ContainerAccessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ContainerAccessor(
                        c.overriddenElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ContainerAccessor(ContainerAccessor context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ContainerAccessor>? getProperty(String key) {
    if (propertyMap<ContainerAccessor>().containsKey(key)) {
      return propertyMap<ContainerAccessor>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_ContainerMember extends RendererBase<ContainerMember> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ContainerMember>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'canonicalEnclosingContainer': Property(
                  getValue: (CT_ c) => c.canonicalEnclosingContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalEnclosingContainer == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(
                        c.canonicalEnclosingContainer!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'definingEnclosingContainer': Property(
                  getValue: (CT_ c) => c.definingEnclosingContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(
                        c.definingEnclosingContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.features.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Feature']!));
                  },
                ),
                'isExtended': Property(
                  getValue: (CT_ c) => c.isExtended,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isExtended == true,
                ),
                'referenceGrandparentOverrides': Property(
                  getValue: (CT_ c) => c.referenceGrandparentOverrides,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Library>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceGrandparentOverrides.map((e) =>
                        _render_Library(e, ast, r.template, sink, parent: r));
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Container>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) =>
                        _render_Container(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ContainerMember(ContainerMember context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ContainerMember>? getProperty(String key) {
    if (propertyMap<ContainerMember>().containsKey(key)) {
      return propertyMap<ContainerMember>()[key];
    } else {
      return null;
    }
  }
}

void _render_DefinedElementType(DefinedElementType context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_DefinedElementType(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_DefinedElementType extends RendererBase<DefinedElementType> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends DefinedElementType>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ElementType.propertyMap<CT_>(),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'instantiatedType': Property(
                  getValue: (CT_ c) => c.instantiatedType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'DartType'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.instantiatedType, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['DartType']!);
                  },
                ),
                'isParameterType': Property(
                  getValue: (CT_ c) => c.isParameterType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isParameterType == true,
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
                'modelElement': Property(
                  getValue: (CT_ c) => c.modelElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(c.modelElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceGrandparentOverrides': Property(
                  getValue: (CT_ c) => c.referenceGrandparentOverrides,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  isNullValue: (CT_ c) =>
                      c.referenceGrandparentOverrides == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(
                        c.referenceGrandparentOverrides, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Iterable']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'typeArguments': Property(
                  getValue: (CT_ c) => c.typeArguments,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeArguments.map((e) => _render_ElementType(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_DefinedElementType(DefinedElementType context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<DefinedElementType>? getProperty(String key) {
    if (propertyMap<DefinedElementType>().containsKey(key)) {
      return propertyMap<DefinedElementType>()[key];
    } else {
      return null;
    }
  }
}

void _render_Documentable(Documentable context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Documentable(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Documentable extends RendererBase<Documentable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Documentable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Nameable.propertyMap<CT_>(),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.config, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DartdocOptionContext']!);
                  },
                ),
                'documentation': Property(
                  getValue: (CT_ c) => c.documentation,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentation!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationAsHtml': Property(
                  getValue: (CT_ c) => c.documentationAsHtml,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentationAsHtml, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasDocumentation': Property(
                  getValue: (CT_ c) => c.hasDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentation == true,
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isDocumented': Property(
                  getValue: (CT_ c) => c.isDocumented,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDocumented == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'oneLineDoc': Property(
                  getValue: (CT_ c) => c.oneLineDoc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.oneLineDoc, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Documentable(Documentable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Documentable>? getProperty(String key) {
    if (propertyMap<Documentable>().containsKey(key)) {
      return propertyMap<Documentable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_DocumentationComment
    extends RendererBase<DocumentationComment> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends DocumentationComment>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'documentationAsHtml': Property(
                  getValue: (CT_ c) => c.documentationAsHtml,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentationAsHtml, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationComment': Property(
                  getValue: (CT_ c) => c.documentationComment,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.documentationComment, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DocumentationComment>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentationFrom.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DocumentationComment']!));
                  },
                ),
                'documentationLocal': Property(
                  getValue: (CT_ c) => c.documentationLocal,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentationLocal, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'elementDocumentation': Property(
                  getValue: (CT_ c) => c.elementDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Documentation'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.elementDocumentation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['Documentation']!);
                  },
                ),
                'fullyQualifiedNameWithoutLibrary': Property(
                  getValue: (CT_ c) => c.fullyQualifiedNameWithoutLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) =>
                      c.fullyQualifiedNameWithoutLibrary == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedNameWithoutLibrary!, ast,
                        r.template, sink,
                        parent: r);
                  },
                ),
                'hasDocumentationComment': Property(
                  getValue: (CT_ c) => c.hasDocumentationComment,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentationComment == true,
                ),
                'hasNodoc': Property(
                  getValue: (CT_ c) => c.hasNodoc,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasNodoc == true,
                ),
                'modelElementRenderer': Property(
                  getValue: (CT_ c) => c.modelElementRenderer,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ModelElementRenderer'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.modelElementRenderer, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ModelElementRenderer']!);
                  },
                ),
                'needsPrecache': Property(
                  getValue: (CT_ c) => c.needsPrecache,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.needsPrecache == true,
                ),
                'pathContext': Property(
                  getValue: (CT_ c) => c.pathContext,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Context'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.pathContext, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Context']!);
                  },
                ),
                'sourceFileName': Property(
                  getValue: (CT_ c) => c.sourceFileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceFileName == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceFileName!, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_DocumentationComment(DocumentationComment context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<DocumentationComment>? getProperty(String key) {
    if (propertyMap<DocumentationComment>().containsKey(key)) {
      return propertyMap<DocumentationComment>()[key];
    } else {
      return null;
    }
  }
}

void _render_ElementType(ElementType context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_ElementType(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ElementType extends RendererBase<ElementType> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends ElementType>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Privacy.propertyMap<CT_>(),
                ..._Renderer_CommentReferable.propertyMap<CT_>(),
                ..._Renderer_Nameable.propertyMap<CT_>(),
                ..._Renderer_ModelBuilder.propertyMap<CT_>(),
                'canHaveParameters': Property(
                  getValue: (CT_ c) => c.canHaveParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.canHaveParameters == true,
                ),
                'instantiatedType': Property(
                  getValue: (CT_ c) => c.instantiatedType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'DartType'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.instantiatedType, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['DartType']!);
                  },
                ),
                'isTypedef': Property(
                  getValue: (CT_ c) => c.isTypedef,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isTypedef == true,
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'nameWithGenerics': Property(
                  getValue: (CT_ c) => c.nameWithGenerics,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nameWithGenerics, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'nullabilitySuffix': Property(
                  getValue: (CT_ c) => c.nullabilitySuffix,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nullabilitySuffix, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
                'type': Property(
                  getValue: (CT_ c) => c.type,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'DartType'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.type, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['DartType']!);
                  },
                ),
                'typeArguments': Property(
                  getValue: (CT_ c) => c.typeArguments,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeArguments.map((e) => _render_ElementType(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'typeElement': Property(
                  getValue: (CT_ c) => c.typeElement,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeDefiningElement'),
                  isNullValue: (CT_ c) => c.typeElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.typeElement, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['TypeDefiningElement']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ElementType(ElementType context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ElementType>? getProperty(String key) {
    if (propertyMap<ElementType>().containsKey(key)) {
      return propertyMap<ElementType>()[key];
    } else {
      return null;
    }
  }
}

void _render_Enum(
    Enum context, List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Enum(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Enum extends RendererBase<Enum> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Enum>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_InheritingContainer.propertyMap<CT_>(),
                ..._Renderer_Constructable.propertyMap<CT_>(),
                ..._Renderer_TypeImplementing.propertyMap<CT_>(),
                ..._Renderer_MixedInTypes.propertyMap<CT_>(),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allModelElements.map((e) => _render_ModelElement(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'constantFields': Property(
                  getValue: (CT_ c) => c.constantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constantFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'EnumElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['EnumElement']!);
                  },
                ),
                'hasPublicEnumValues': Property(
                  getValue: (CT_ c) => c.hasPublicEnumValues,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicEnumValues == true,
                ),
                'inheritanceChain': Property(
                  getValue: (CT_ c) => c.inheritanceChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritanceChain.map((e) =>
                        _render_InheritingContainer(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'isAbstract': Property(
                  getValue: (CT_ c) => c.isAbstract,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAbstract == true,
                ),
                'isBase': Property(
                  getValue: (CT_ c) => c.isBase,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isBase == true,
                ),
                'isInterface': Property(
                  getValue: (CT_ c) => c.isInterface,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInterface == true,
                ),
                'isMixinClass': Property(
                  getValue: (CT_ c) => c.isMixinClass,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isMixinClass == true,
                ),
                'isSealed': Property(
                  getValue: (CT_ c) => c.isSealed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSealed == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'publicEnumValues': Property(
                  getValue: (CT_ c) => c.publicEnumValues,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicEnumValues.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'relationshipsClass': Property(
                  getValue: (CT_ c) => c.relationshipsClass,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.relationshipsClass, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Enum(Enum context, RendererBase<Object>? parent, Template template,
      StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Enum>? getProperty(String key) {
    if (propertyMap<Enum>().containsKey(key)) {
      return propertyMap<Enum>()[key];
    } else {
      return null;
    }
  }
}

String renderEnum(EnumTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_EnumTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_EnumTemplateData(EnumTemplateData context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_EnumTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_EnumTemplateData extends RendererBase<EnumTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>>
      propertyMap<CT_ extends EnumTemplateData>() =>
          _propertyMapCache.putIfAbsent(
              CT_,
              () => {
                    ..._Renderer_InheritingContainerTemplateData.propertyMap<
                        Enum, CT_>(),
                    'eNum': Property(
                      getValue: (CT_ c) => c.eNum,
                      renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) {
                        if (remainingNames.isEmpty) {
                          return self.getValue(c).toString();
                        }
                        var name = remainingNames.first;
                        var nextProperty =
                            _Renderer_Enum.propertyMap().getValue(name);
                        return nextProperty.renderVariable(
                            self.getValue(c) as Enum,
                            nextProperty,
                            [...remainingNames.skip(1)]);
                      },
                      isNullValue: (CT_ c) => false,
                      renderValue: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        _render_Enum(c.eNum, ast, r.template, sink, parent: r);
                      },
                    ),
                    'self': Property(
                      getValue: (CT_ c) => c.self,
                      renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) {
                        if (remainingNames.isEmpty) {
                          return self.getValue(c).toString();
                        }
                        var name = remainingNames.first;
                        var nextProperty =
                            _Renderer_Enum.propertyMap().getValue(name);
                        return nextProperty.renderVariable(
                            self.getValue(c) as Enum,
                            nextProperty,
                            [...remainingNames.skip(1)]);
                      },
                      isNullValue: (CT_ c) => false,
                      renderValue: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        _render_Enum(c.self, ast, r.template, sink, parent: r);
                      },
                    ),
                  }) as Map<String, Property<CT_>>;

  _Renderer_EnumTemplateData(EnumTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<EnumTemplateData>? getProperty(String key) {
    if (propertyMap<EnumTemplateData>().containsKey(key)) {
      return propertyMap<EnumTemplateData>()[key];
    } else {
      return null;
    }
  }
}

void _render_Extension(Extension context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Extension(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Extension extends RendererBase<Extension> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Extension>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Container.propertyMap<CT_>(),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allModelElements.map((e) => _render_ModelElement(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'alwaysApplies': Property(
                  getValue: (CT_ c) => c.alwaysApplies,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.alwaysApplies == true,
                ),
                'declaredFields': Property(
                  getValue: (CT_ c) => c.declaredFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'declaredMethods': Property(
                  getValue: (CT_ c) => c.declaredMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ExtensionElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ExtensionElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'extendedType': Property(
                  getValue: (CT_ c) => c.extendedType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.extendedType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'relationshipsClass': Property(
                  getValue: (CT_ c) => c.relationshipsClass,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.relationshipsClass, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Extension(Extension context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Extension>? getProperty(String key) {
    if (propertyMap<Extension>().containsKey(key)) {
      return propertyMap<Extension>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_ExtensionTarget extends RendererBase<ExtensionTarget> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ExtensionTarget>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'hasModifiers': Property(
                  getValue: (CT_ c) => c.hasModifiers,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasModifiers == true,
                ),
                'hasPotentiallyApplicableExtensions': Property(
                  getValue: (CT_ c) => c.hasPotentiallyApplicableExtensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) =>
                      c.hasPotentiallyApplicableExtensions == true,
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'potentiallyApplicableExtensions': Property(
                  getValue: (CT_ c) => c.potentiallyApplicableExtensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.potentiallyApplicableExtensions.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
                'potentiallyApplicableExtensionsSorted': Property(
                  getValue: (CT_ c) => c.potentiallyApplicableExtensionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.potentiallyApplicableExtensionsSorted.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ExtensionTarget(ExtensionTarget context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ExtensionTarget>? getProperty(String key) {
    if (propertyMap<ExtensionTarget>().containsKey(key)) {
      return propertyMap<ExtensionTarget>()[key];
    } else {
      return null;
    }
  }
}

String renderExtension<T extends Extension>(
    ExtensionTemplateData<T> context, Template template) {
  var buffer = StringBuffer();
  _render_ExtensionTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_ExtensionTemplateData<T extends Extension>(
    ExtensionTemplateData<T> context,
    List<MustachioNode> ast,
    Template template,
    StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_ExtensionTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ExtensionTemplateData<T extends Extension>
    extends RendererBase<ExtensionTemplateData<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<T extends Extension,
          CT_ extends ExtensionTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<T, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<T, CT_>(),
                'container': Property(
                  getValue: (CT_ c) => c.container,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.container, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'extension': Property(
                  getValue: (CT_ c) => c.extension,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Extension.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Extension,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Extension(c.extension, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Extension.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Extension,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Extension(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'sidebarForContainer': Property(
                  getValue: (CT_ c) => c.sidebarForContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sidebarForLibrary': Property(
                  getValue: (CT_ c) => c.sidebarForLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ExtensionTemplateData(ExtensionTemplateData<T> context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ExtensionTemplateData<T>>? getProperty(String key) {
    if (propertyMap<T, ExtensionTemplateData<T>>().containsKey(key)) {
      return propertyMap<T, ExtensionTemplateData<T>>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Feature extends RendererBase<Feature> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Feature>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'cssClassName': Property(
                  getValue: (CT_ c) => c.cssClassName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.cssClassName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'featurePrefix': Property(
                  getValue: (CT_ c) => c.featurePrefix,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.featurePrefix, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedNameWithParameters': Property(
                  getValue: (CT_ c) => c.linkedNameWithParameters,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedNameWithParameters, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'sortGroup': Property(
                  getValue: (CT_ c) => c.sortGroup,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.sortGroup, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Feature(Feature context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Feature>? getProperty(String key) {
    if (propertyMap<Feature>().containsKey(key)) {
      return propertyMap<Feature>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_FeatureSet extends RendererBase<FeatureSet> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends FeatureSet>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'displayedLanguageFeatures': Property(
                  getValue: (CT_ c) => c.displayedLanguageFeatures,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<LanguageFeature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.displayedLanguageFeatures.map((e) =>
                        _render_LanguageFeature(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'hasFeatureSet': Property(
                  getValue: (CT_ c) => c.hasFeatureSet,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasFeatureSet == true,
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_FeatureSet(FeatureSet context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<FeatureSet>? getProperty(String key) {
    if (propertyMap<FeatureSet>().containsKey(key)) {
      return propertyMap<FeatureSet>()[key];
    } else {
      return null;
    }
  }
}

void _render_Field(
    Field context, List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Field(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Field extends RendererBase<Field> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Field>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_GetterSetterCombo.propertyMap<CT_>(),
                ..._Renderer_ContainerMember.propertyMap<CT_>(),
                ..._Renderer_Inheritable.propertyMap<CT_>(),
                'documentation': Property(
                  getValue: (CT_ c) => c.documentation,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentation, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FieldElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['FieldElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.features.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Feature']!));
                  },
                ),
                'field': Property(
                  getValue: (CT_ c) => c.field,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FieldElement'),
                  isNullValue: (CT_ c) => c.field == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.field, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['FieldElement']!);
                  },
                ),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullkind': Property(
                  getValue: (CT_ c) => c.fullkind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullkind, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'getter': Property(
                  getValue: (CT_ c) => c.getter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty = _Renderer_ContainerAccessor.propertyMap()
                        .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ContainerAccessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.getter == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ContainerAccessor(c.getter!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isConst': Property(
                  getValue: (CT_ c) => c.isConst,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isConst == true,
                ),
                'isCovariant': Property(
                  getValue: (CT_ c) => c.isCovariant,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCovariant == true,
                ),
                'isFinal': Property(
                  getValue: (CT_ c) => c.isFinal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFinal == true,
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'isLate': Property(
                  getValue: (CT_ c) => c.isLate,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isLate == true,
                ),
                'isStatic': Property(
                  getValue: (CT_ c) => c.isStatic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isStatic == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'overriddenElement': Property(
                  getValue: (CT_ c) => c.overriddenElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Inheritable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Inheritable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.overriddenElement, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Inheritable']!);
                  },
                ),
                'setter': Property(
                  getValue: (CT_ c) => c.setter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty = _Renderer_ContainerAccessor.propertyMap()
                        .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ContainerAccessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.setter == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ContainerAccessor(c.setter!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sourceCode': Property(
                  getValue: (CT_ c) => c.sourceCode,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceCode, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Field(Field context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Field>? getProperty(String key) {
    if (propertyMap<Field>().containsKey(key)) {
      return propertyMap<Field>()[key];
    } else {
      return null;
    }
  }
}

String renderFunction(FunctionTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_FunctionTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_FunctionTemplateData(FunctionTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_FunctionTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_FunctionTemplateData
    extends RendererBase<FunctionTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends FunctionTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<ModelFunction, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<ModelFunction, CT_>(),
                'function': Property(
                  getValue: (CT_ c) => c.function,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelFunction.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelFunction,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelFunction(c.function, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelFunction.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelFunction,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelFunction(c.self, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sidebarForLibrary': Property(
                  getValue: (CT_ c) => c.sidebarForLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_FunctionTemplateData(FunctionTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<FunctionTemplateData>? getProperty(String key) {
    if (propertyMap<FunctionTemplateData>().containsKey(key)) {
      return propertyMap<FunctionTemplateData>()[key];
    } else {
      return null;
    }
  }
}

void _render_FunctionTypedef(FunctionTypedef context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_FunctionTypedef(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_FunctionTypedef extends RendererBase<FunctionTypedef> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends FunctionTypedef>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Typedef.propertyMap<CT_>(),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Callable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Callable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Callable(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_FunctionTypedef(FunctionTypedef context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<FunctionTypedef>? getProperty(String key) {
    if (propertyMap<FunctionTypedef>().containsKey(key)) {
      return propertyMap<FunctionTypedef>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_GetterSetterCombo extends RendererBase<GetterSetterCombo> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends GetterSetterCombo>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'allAccessors': Property(
                  getValue: (CT_ c) => c.allAccessors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Accessor>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allAccessors.map((e) =>
                        _render_Accessor(e, ast, r.template, sink, parent: r));
                  },
                ),
                'annotations': Property(
                  getValue: (CT_ c) => c.annotations,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Annotation>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.annotations.map((e) => _render_Annotation(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'arrow': Property(
                  getValue: (CT_ c) => c.arrow,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.arrow, ast, r.template, sink, parent: r);
                  },
                ),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'constantInitializer': Property(
                  getValue: (CT_ c) => c.constantInitializer,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Expression'),
                  isNullValue: (CT_ c) => c.constantInitializer == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.constantInitializer, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Expression']!);
                  },
                ),
                'constantValue': Property(
                  getValue: (CT_ c) => c.constantValue,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.constantValue, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'constantValueBase': Property(
                  getValue: (CT_ c) => c.constantValueBase,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.constantValueBase, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'constantValueTruncated': Property(
                  getValue: (CT_ c) => c.constantValueTruncated,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.constantValueTruncated, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationComment': Property(
                  getValue: (CT_ c) => c.documentationComment,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.documentationComment, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DocumentationComment>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentationFrom.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DocumentationComment']!));
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'getter': Property(
                  getValue: (CT_ c) => c.getter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Accessor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Accessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.getter == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Accessor(c.getter!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'getterSetterBothAvailable': Property(
                  getValue: (CT_ c) => c.getterSetterBothAvailable,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.getterSetterBothAvailable == true,
                ),
                'hasAccessorsWithDocs': Property(
                  getValue: (CT_ c) => c.hasAccessorsWithDocs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasAccessorsWithDocs == true,
                ),
                'hasConstantValueForDisplay': Property(
                  getValue: (CT_ c) => c.hasConstantValueForDisplay,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasConstantValueForDisplay == true,
                ),
                'hasDocumentationComment': Property(
                  getValue: (CT_ c) => c.hasDocumentationComment,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentationComment == true,
                ),
                'hasExplicitGetter': Property(
                  getValue: (CT_ c) => c.hasExplicitGetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasExplicitGetter == true,
                ),
                'hasExplicitSetter': Property(
                  getValue: (CT_ c) => c.hasExplicitSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasExplicitSetter == true,
                ),
                'hasGetter': Property(
                  getValue: (CT_ c) => c.hasGetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasGetter == true,
                ),
                'hasGetterOrSetter': Property(
                  getValue: (CT_ c) => c.hasGetterOrSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasGetterOrSetter == true,
                ),
                'hasNoGetterSetter': Property(
                  getValue: (CT_ c) => c.hasNoGetterSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasNoGetterSetter == true,
                ),
                'hasParameters': Property(
                  getValue: (CT_ c) => c.hasParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasParameters == true,
                ),
                'hasPublicGetter': Property(
                  getValue: (CT_ c) => c.hasPublicGetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicGetter == true,
                ),
                'hasPublicGetterNoSetter': Property(
                  getValue: (CT_ c) => c.hasPublicGetterNoSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicGetterNoSetter == true,
                ),
                'hasPublicSetter': Property(
                  getValue: (CT_ c) => c.hasPublicSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicSetter == true,
                ),
                'hasSetter': Property(
                  getValue: (CT_ c) => c.hasSetter,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasSetter == true,
                ),
                'isCallable': Property(
                  getValue: (CT_ c) => c.isCallable,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCallable == true,
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
                'linkedParamsNoMetadata': Property(
                  getValue: (CT_ c) => c.linkedParamsNoMetadata,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedParamsNoMetadata == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedParamsNoMetadata!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'oneLineDoc': Property(
                  getValue: (CT_ c) => c.oneLineDoc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.oneLineDoc, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, sink, parent: r));
                  },
                ),
                'readOnly': Property(
                  getValue: (CT_ c) => c.readOnly,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.readOnly == true,
                ),
                'readWrite': Property(
                  getValue: (CT_ c) => c.readWrite,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.readWrite == true,
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'setter': Property(
                  getValue: (CT_ c) => c.setter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Accessor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Accessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.setter == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Accessor(c.setter!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'writeOnly': Property(
                  getValue: (CT_ c) => c.writeOnly,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.writeOnly == true,
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_GetterSetterCombo(GetterSetterCombo context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<GetterSetterCombo>? getProperty(String key) {
    if (propertyMap<GetterSetterCombo>().containsKey(key)) {
      return propertyMap<GetterSetterCombo>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_HasNoPage extends RendererBase<HasNoPage> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends HasNoPage>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_HasNoPage(HasNoPage context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<HasNoPage>? getProperty(String key) {
    if (propertyMap<HasNoPage>().containsKey(key)) {
      return propertyMap<HasNoPage>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Indexable extends RendererBase<Indexable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Indexable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'overriddenDepth': Property(
                  getValue: (CT_ c) => c.overriddenDepth,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => c.overriddenDepth == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.overriddenDepth, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Indexable(Indexable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Indexable>? getProperty(String key) {
    if (propertyMap<Indexable>().containsKey(key)) {
      return propertyMap<Indexable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Inheritable extends RendererBase<Inheritable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Inheritable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'canonicalLibrary': Property(
                  getValue: (CT_ c) => c.canonicalLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.canonicalLibrary!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'canonicalModelElement': Property(
                  getValue: (CT_ c) => c.canonicalModelElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalModelElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.canonicalModelElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.features.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Feature']!));
                  },
                ),
                'inheritance': Property(
                  getValue: (CT_ c) => c.inheritance,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritance.map((e) => _render_InheritingContainer(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'isCovariant': Property(
                  getValue: (CT_ c) => c.isCovariant,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCovariant == true,
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'isOverride': Property(
                  getValue: (CT_ c) => c.isOverride,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isOverride == true,
                ),
                'overriddenDepth': Property(
                  getValue: (CT_ c) => c.overriddenDepth,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.overriddenDepth, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'overriddenElement': Property(
                  getValue: (CT_ c) => c.overriddenElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Inheritable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Inheritable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.overriddenElement, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Inheritable']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Inheritable(Inheritable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Inheritable>? getProperty(String key) {
    if (propertyMap<Inheritable>().containsKey(key)) {
      return propertyMap<Inheritable>()[key];
    } else {
      return null;
    }
  }
}

void _render_InheritingContainer(InheritingContainer context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_InheritingContainer(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_InheritingContainer extends RendererBase<InheritingContainer> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends InheritingContainer>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Container.propertyMap<CT_>(),
                ..._Renderer_ExtensionTarget.propertyMap<CT_>(),
                'allFields': Property(
                  getValue: (CT_ c) => c.allFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allModelElements.map((e) => _render_ModelElement(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'constantFields': Property(
                  getValue: (CT_ c) => c.constantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constantFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'containerModifiers': Property(
                  getValue: (CT_ c) => c.containerModifiers,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ContainerModifier>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.containerModifiers.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ContainerModifier']!));
                  },
                ),
                'declaredFields': Property(
                  getValue: (CT_ c) => c.declaredFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'declaredMethods': Property(
                  getValue: (CT_ c) => c.declaredMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.declaredMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'definingContainer': Property(
                  getValue: (CT_ c) => c.definingContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_InheritingContainer.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as InheritingContainer,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_InheritingContainer(
                        c.definingContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'InterfaceElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['InterfaceElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullkind': Property(
                  getValue: (CT_ c) => c.fullkind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullkind, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasModifiers': Property(
                  getValue: (CT_ c) => c.hasModifiers,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasModifiers == true,
                ),
                'hasPublicInheritedMethods': Property(
                  getValue: (CT_ c) => c.hasPublicInheritedMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInheritedMethods == true,
                ),
                'hasPublicSuperChainReversed': Property(
                  getValue: (CT_ c) => c.hasPublicSuperChainReversed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicSuperChainReversed == true,
                ),
                'inheritanceChain': Property(
                  getValue: (CT_ c) => c.inheritanceChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritanceChain.map((e) =>
                        _render_InheritingContainer(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'inheritedFields': Property(
                  getValue: (CT_ c) => c.inheritedFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritedFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'inheritedMethods': Property(
                  getValue: (CT_ c) => c.inheritedMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritedMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'inheritedOperators': Property(
                  getValue: (CT_ c) => c.inheritedOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Operator>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritedOperators.map((e) =>
                        _render_Operator(e, ast, r.template, sink, parent: r));
                  },
                ),
                'instanceFields': Property(
                  getValue: (CT_ c) => c.instanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'instanceMethods': Property(
                  getValue: (CT_ c) => c.instanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'instanceOperators': Property(
                  getValue: (CT_ c) => c.instanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.instanceOperators.map((e) =>
                        _render_Operator(e, ast, r.template, sink, parent: r));
                  },
                ),
                'isAbstract': Property(
                  getValue: (CT_ c) => c.isAbstract,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAbstract == true,
                ),
                'isBase': Property(
                  getValue: (CT_ c) => c.isBase,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isBase == true,
                ),
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'isFinal': Property(
                  getValue: (CT_ c) => c.isFinal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFinal == true,
                ),
                'isInterface': Property(
                  getValue: (CT_ c) => c.isInterface,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInterface == true,
                ),
                'isMixinClass': Property(
                  getValue: (CT_ c) => c.isMixinClass,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isMixinClass == true,
                ),
                'isSealed': Property(
                  getValue: (CT_ c) => c.isSealed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSealed == true,
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_DefinedElementType.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as DefinedElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_DefinedElementType(
                        c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'publicInheritedFields': Property(
                  getValue: (CT_ c) => c.publicInheritedFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInheritedFields.map((e) =>
                        _render_Field(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInheritedInstanceFields': Property(
                  getValue: (CT_ c) => c.publicInheritedInstanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.publicInheritedInstanceFields == true,
                ),
                'publicInheritedInstanceMethods': Property(
                  getValue: (CT_ c) => c.publicInheritedInstanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.publicInheritedInstanceMethods == true,
                ),
                'publicInheritedInstanceOperators': Property(
                  getValue: (CT_ c) => c.publicInheritedInstanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) =>
                      c.publicInheritedInstanceOperators == true,
                ),
                'publicInheritedMethods': Property(
                  getValue: (CT_ c) => c.publicInheritedMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInheritedMethods.map((e) =>
                        _render_Method(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicInterfaces': Property(
                  getValue: (CT_ c) => c.publicInterfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInterfaces.map((e) =>
                        _render_DefinedElementType(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicSuperChain': Property(
                  getValue: (CT_ c) => c.publicSuperChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicSuperChain.map((e) =>
                        _render_DefinedElementType(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicSuperChainReversed': Property(
                  getValue: (CT_ c) => c.publicSuperChainReversed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicSuperChainReversed.map((e) =>
                        _render_DefinedElementType(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'superChain': Property(
                  getValue: (CT_ c) => c.superChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.superChain.map((e) => _render_DefinedElementType(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'supertype': Property(
                  getValue: (CT_ c) => c.supertype,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_DefinedElementType.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as DefinedElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.supertype == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_DefinedElementType(
                        c.supertype!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_InheritingContainer(InheritingContainer context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<InheritingContainer>? getProperty(String key) {
    if (propertyMap<InheritingContainer>().containsKey(key)) {
      return propertyMap<InheritingContainer>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_InheritingContainerTemplateData<T extends InheritingContainer>
    extends RendererBase<InheritingContainerTemplateData<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<T extends InheritingContainer,
          CT_ extends InheritingContainerTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<T, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<T, CT_>(),
                'clazz': Property(
                  getValue: (CT_ c) => c.clazz,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_InheritingContainer.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as InheritingContainer,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_InheritingContainer(c.clazz, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'container': Property(
                  getValue: (CT_ c) => c.container,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.container, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_InheritingContainer.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as InheritingContainer,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_InheritingContainer(c.self, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sidebarForContainer': Property(
                  getValue: (CT_ c) => c.sidebarForContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sidebarForLibrary': Property(
                  getValue: (CT_ c) => c.sidebarForLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_InheritingContainerTemplateData(
      InheritingContainerTemplateData<T> context,
      RendererBase<Object>? parent,
      Template template,
      StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<InheritingContainerTemplateData<T>>? getProperty(String key) {
    if (propertyMap<T, InheritingContainerTemplateData<T>>().containsKey(key)) {
      return propertyMap<T, InheritingContainerTemplateData<T>>()[key];
    } else {
      return null;
    }
  }
}

void _render_LanguageFeature(LanguageFeature context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_LanguageFeature(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_LanguageFeature extends RendererBase<LanguageFeature> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends LanguageFeature>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'featureDescription': Property(
                  getValue: (CT_ c) => c.featureDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featureDescription == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.featureDescription!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'featureLabel': Property(
                  getValue: (CT_ c) => c.featureLabel,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.featureLabel, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'featureUrl': Property(
                  getValue: (CT_ c) => c.featureUrl,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featureUrl == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.featureUrl!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_LanguageFeature(LanguageFeature context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<LanguageFeature>? getProperty(String key) {
    if (propertyMap<LanguageFeature>().containsKey(key)) {
      return propertyMap<LanguageFeature>()[key];
    } else {
      return null;
    }
  }
}

void _render_Library(Library context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Library(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Library extends RendererBase<Library> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Library>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                ..._Renderer_TopLevelContainer.propertyMap<CT_>(),
                'allClasses': Property(
                  getValue: (CT_ c) => c.allClasses,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allClasses.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelElement>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allModelElements.map((e) => _render_ModelElement(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'canonicalFor': Property(
                  getValue: (CT_ c) => c.canonicalFor,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.canonicalFor.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'classes': Property(
                  getValue: (CT_ c) => c.classes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.classes.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'compilationUnitElement': Property(
                  getValue: (CT_ c) => c.compilationUnitElement,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CompilationUnitElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(
                        c.compilationUnitElement, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CompilationUnitElement']!);
                  },
                ),
                'constants': Property(
                  getValue: (CT_ c) => c.constants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constants.map((e) => _render_TopLevelVariable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'dirName': Property(
                  getValue: (CT_ c) => c.dirName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.dirName, ast, r.template, sink, parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'LibraryElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['LibraryElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'enums': Property(
                  getValue: (CT_ c) => c.enums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Enum>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.enums.map((e) =>
                        _render_Enum(e, ast, r.template, sink, parent: r));
                  },
                ),
                'exceptions': Property(
                  getValue: (CT_ c) => c.exceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.exceptions.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'extensions': Property(
                  getValue: (CT_ c) => c.extensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.extensions.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'functions': Property(
                  getValue: (CT_ c) => c.functions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelFunction>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.functions.map((e) => _render_ModelFunction(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'inheritanceManager': Property(
                  getValue: (CT_ c) => c.inheritanceManager,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'InheritanceManager3'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.inheritanceManager, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['InheritanceManager3']!);
                  },
                ),
                'isAnonymous': Property(
                  getValue: (CT_ c) => c.isAnonymous,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAnonymous == true,
                ),
                'isInSdk': Property(
                  getValue: (CT_ c) => c.isInSdk,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInSdk == true,
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'mixins': Property(
                  getValue: (CT_ c) => c.mixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Mixin>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.mixins.map((e) =>
                        _render_Mixin(e, ast, r.template, sink, parent: r));
                  },
                ),
                'modelElementsMap': Property(
                  getValue: (CT_ c) => c.modelElementsMap,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames,
                          'HashMap<Element, Set<ModelElement>>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.modelElementsMap, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['HashMap']!);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'nameFromPath': Property(
                  getValue: (CT_ c) => c.nameFromPath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nameFromPath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'package': Property(
                  getValue: (CT_ c) => c.package,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.package, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageMeta': Property(
                  getValue: (CT_ c) => c.packageMeta,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageMeta'),
                  isNullValue: (CT_ c) => c.packageMeta == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageMeta, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageMeta']!);
                  },
                ),
                'packageName': Property(
                  getValue: (CT_ c) => c.packageName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.packageName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'prefixToLibrary': Property(
                  getValue: (CT_ c) => c.prefixToLibrary,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, Set<Library>>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.prefixToLibrary, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'properties': Property(
                  getValue: (CT_ c) => c.properties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.properties.map((e) => _render_TopLevelVariable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'scope': Property(
                  getValue: (CT_ c) => c.scope,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Scope'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.scope, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Scope']!);
                  },
                ),
                'sdkLib': Property(
                  getValue: (CT_ c) => c.sdkLib,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'SdkLibrary'),
                  isNullValue: (CT_ c) => c.sdkLib == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.sdkLib, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['SdkLibrary']!);
                  },
                ),
                'typeSystem': Property(
                  getValue: (CT_ c) => c.typeSystem,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeSystem'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.typeSystem, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['TypeSystem']!);
                  },
                ),
                'typedefs': Property(
                  getValue: (CT_ c) => c.typedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Typedef>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typedefs.map((e) =>
                        _render_Typedef(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Library(Library context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Library>? getProperty(String key) {
    if (propertyMap<Library>().containsKey(key)) {
      return propertyMap<Library>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_LibraryContainer extends RendererBase<LibraryContainer> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends LibraryContainer>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'containerOrder': Property(
                  getValue: (CT_ c) => c.containerOrder,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.containerOrder.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'enclosingName': Property(
                  getValue: (CT_ c) => c.enclosingName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.enclosingName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasPublicLibraries': Property(
                  getValue: (CT_ c) => c.hasPublicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicLibraries == true,
                ),
                'isSdk': Property(
                  getValue: (CT_ c) => c.isSdk,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSdk == true,
                ),
                'libraries': Property(
                  getValue: (CT_ c) => c.libraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Library>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.libraries.map((e) =>
                        _render_Library(e, ast, r.template, sink, parent: r));
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
                'publicLibraries': Property(
                  getValue: (CT_ c) => c.publicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Library>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicLibraries.map((e) =>
                        _render_Library(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicLibrariesSorted': Property(
                  getValue: (CT_ c) => c.publicLibrariesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Library>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicLibrariesSorted.map((e) =>
                        _render_Library(e, ast, r.template, sink, parent: r));
                  },
                ),
                'sortKey': Property(
                  getValue: (CT_ c) => c.sortKey,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sortKey, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_LibraryContainer(LibraryContainer context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<LibraryContainer>? getProperty(String key) {
    if (propertyMap<LibraryContainer>().containsKey(key)) {
      return propertyMap<LibraryContainer>()[key];
    } else {
      return null;
    }
  }
}

String renderLibrary(LibraryTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_LibraryTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_LibraryTemplateData(LibraryTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_LibraryTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_LibraryTemplateData extends RendererBase<LibraryTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends LibraryTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Library, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<Library, CT_>(),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'sidebarForLibrary': Property(
                  getValue: (CT_ c) => c.sidebarForLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_LibraryTemplateData(LibraryTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<LibraryTemplateData>? getProperty(String key) {
    if (propertyMap<LibraryTemplateData>().containsKey(key)) {
      return propertyMap<LibraryTemplateData>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Locatable extends RendererBase<Locatable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Locatable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Locatable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentationFrom.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Locatable']!));
                  },
                ),
                'documentationIsLocal': Property(
                  getValue: (CT_ c) => c.documentationIsLocal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.documentationIsLocal == true,
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'location': Property(
                  getValue: (CT_ c) => c.location,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.location, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Locatable(Locatable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Locatable>? getProperty(String key) {
    if (propertyMap<Locatable>().containsKey(key)) {
      return propertyMap<Locatable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_MarkdownFileDocumentation
    extends RendererBase<MarkdownFileDocumentation> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends MarkdownFileDocumentation>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'documentation': Property(
                  getValue: (CT_ c) => c.documentation,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentation, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationAsHtml': Property(
                  getValue: (CT_ c) => c.documentationAsHtml,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentationAsHtml, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationFile': Property(
                  getValue: (CT_ c) => c.documentationFile,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'File'),
                  isNullValue: (CT_ c) => c.documentationFile == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.documentationFile, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['File']!);
                  },
                ),
                'documentedWhere': Property(
                  getValue: (CT_ c) => c.documentedWhere,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DocumentLocation'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.documentedWhere, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DocumentLocation']!);
                  },
                ),
                'hasDocumentation': Property(
                  getValue: (CT_ c) => c.hasDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentation == true,
                ),
                'isDocumented': Property(
                  getValue: (CT_ c) => c.isDocumented,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDocumented == true,
                ),
                'location': Property(
                  getValue: (CT_ c) => c.location,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.location, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.locationPieces.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'oneLineDoc': Property(
                  getValue: (CT_ c) => c.oneLineDoc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.oneLineDoc, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_MarkdownFileDocumentation(MarkdownFileDocumentation context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<MarkdownFileDocumentation>? getProperty(String key) {
    if (propertyMap<MarkdownFileDocumentation>().containsKey(key)) {
      return propertyMap<MarkdownFileDocumentation>()[key];
    } else {
      return null;
    }
  }
}

void _render_Method(
    Method context, List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Method(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Method extends RendererBase<Method> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Method>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_ContainerMember.propertyMap<CT_>(),
                ..._Renderer_Inheritable.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'MethodElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['MethodElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.features.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Feature']!));
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullkind': Property(
                  getValue: (CT_ c) => c.fullkind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullkind, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isCovariant': Property(
                  getValue: (CT_ c) => c.isCovariant,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCovariant == true,
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'isOperator': Property(
                  getValue: (CT_ c) => c.isOperator,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isOperator == true,
                ),
                'isStatic': Property(
                  getValue: (CT_ c) => c.isStatic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isStatic == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Callable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Callable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Callable(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'originalMember': Property(
                  getValue: (CT_ c) => c.originalMember,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ExecutableMember'),
                  isNullValue: (CT_ c) => c.originalMember == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.originalMember, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ExecutableMember']!);
                  },
                ),
                'overriddenElement': Property(
                  getValue: (CT_ c) => c.overriddenElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Method.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Method,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Method(c.overriddenElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Method(Method context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Method>? getProperty(String key) {
    if (propertyMap<Method>().containsKey(key)) {
      return propertyMap<Method>()[key];
    } else {
      return null;
    }
  }
}

String renderMethod(MethodTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_MethodTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_MethodTemplateData(MethodTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_MethodTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_MethodTemplateData extends RendererBase<MethodTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends MethodTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Method, CT_>(),
                ..._Renderer_TwoDirectoriesDown.propertyMap<Method, CT_>(),
                'container': Property(
                  getValue: (CT_ c) => c.container,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.container, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'method': Property(
                  getValue: (CT_ c) => c.method,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Method.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Method,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Method(c.method, ast, r.template, sink, parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, sink, parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Method.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Method,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Method(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'sidebarForContainer': Property(
                  getValue: (CT_ c) => c.sidebarForContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_MethodTemplateData(MethodTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<MethodTemplateData>? getProperty(String key) {
    if (propertyMap<MethodTemplateData>().containsKey(key)) {
      return propertyMap<MethodTemplateData>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_MixedInTypes extends RendererBase<MixedInTypes> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends MixedInTypes>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'hasModifiers': Property(
                  getValue: (CT_ c) => c.hasModifiers,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasModifiers == true,
                ),
                'hasPublicMixedInTypes': Property(
                  getValue: (CT_ c) => c.hasPublicMixedInTypes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicMixedInTypes == true,
                ),
                'mixedInTypes': Property(
                  getValue: (CT_ c) => c.mixedInTypes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.mixedInTypes.map((e) => _render_DefinedElementType(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'publicMixedInTypes': Property(
                  getValue: (CT_ c) => c.publicMixedInTypes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicMixedInTypes.map((e) =>
                        _render_DefinedElementType(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_MixedInTypes(MixedInTypes context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<MixedInTypes>? getProperty(String key) {
    if (propertyMap<MixedInTypes>().containsKey(key)) {
      return propertyMap<MixedInTypes>()[key];
    } else {
      return null;
    }
  }
}

void _render_Mixin(
    Mixin context, List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Mixin(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Mixin extends RendererBase<Mixin> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Mixin>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_InheritingContainer.propertyMap<CT_>(),
                ..._Renderer_TypeImplementing.propertyMap<CT_>(),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'MixinElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['MixinElement']!);
                  },
                ),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasModifiers': Property(
                  getValue: (CT_ c) => c.hasModifiers,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasModifiers == true,
                ),
                'hasPublicSuperclassConstraints': Property(
                  getValue: (CT_ c) => c.hasPublicSuperclassConstraints,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicSuperclassConstraints == true,
                ),
                'inheritanceChain': Property(
                  getValue: (CT_ c) => c.inheritanceChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.inheritanceChain.map((e) =>
                        _render_InheritingContainer(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'isAbstract': Property(
                  getValue: (CT_ c) => c.isAbstract,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAbstract == true,
                ),
                'isBase': Property(
                  getValue: (CT_ c) => c.isBase,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isBase == true,
                ),
                'isFinal': Property(
                  getValue: (CT_ c) => c.isFinal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFinal == true,
                ),
                'isInterface': Property(
                  getValue: (CT_ c) => c.isInterface,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInterface == true,
                ),
                'isMixinClass': Property(
                  getValue: (CT_ c) => c.isMixinClass,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isMixinClass == true,
                ),
                'isSealed': Property(
                  getValue: (CT_ c) => c.isSealed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSealed == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'publicSuperclassConstraints': Property(
                  getValue: (CT_ c) => c.publicSuperclassConstraints,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames,
                          'Iterable<ParameterizedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicSuperclassConstraints.map((e) =>
                        _render_ParameterizedElementType(
                            e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'relationshipsClass': Property(
                  getValue: (CT_ c) => c.relationshipsClass,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.relationshipsClass, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'superclassConstraints': Property(
                  getValue: (CT_ c) => c.superclassConstraints,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ParameterizedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.superclassConstraints.map((e) =>
                        _render_ParameterizedElementType(
                            e, ast, r.template, sink,
                            parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Mixin(Mixin context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Mixin>? getProperty(String key) {
    if (propertyMap<Mixin>().containsKey(key)) {
      return propertyMap<Mixin>()[key];
    } else {
      return null;
    }
  }
}

String renderMixin(MixinTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_MixinTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_MixinTemplateData(MixinTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_MixinTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_MixinTemplateData extends RendererBase<MixinTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends MixinTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_InheritingContainerTemplateData.propertyMap<Mixin,
                    CT_>(),
                'mixin': Property(
                  getValue: (CT_ c) => c.mixin,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Mixin.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Mixin,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Mixin(c.mixin, ast, r.template, sink, parent: r);
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Mixin.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Mixin,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Mixin(c.self, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_MixinTemplateData(MixinTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<MixinTemplateData>? getProperty(String key) {
    if (propertyMap<MixinTemplateData>().containsKey(key)) {
      return propertyMap<MixinTemplateData>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_ModelBuilder extends RendererBase<ModelBuilder> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends ModelBuilder>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'modelBuilder': Property(
                  getValue: (CT_ c) => c.modelBuilder,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ModelObjectBuilder'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.modelBuilder, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ModelObjectBuilder']!);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ModelBuilder(ModelBuilder context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ModelBuilder>? getProperty(String key) {
    if (propertyMap<ModelBuilder>().containsKey(key)) {
      return propertyMap<ModelBuilder>()[key];
    } else {
      return null;
    }
  }
}

void _render_ModelElement(ModelElement context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_ModelElement(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ModelElement extends RendererBase<ModelElement> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends ModelElement>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Canonicalization.propertyMap<CT_>(),
                ..._Renderer_CommentReferable.propertyMap<CT_>(),
                ..._Renderer_Privacy.propertyMap<CT_>(),
                ..._Renderer_Warnable.propertyMap<CT_>(),
                ..._Renderer_Locatable.propertyMap<CT_>(),
                ..._Renderer_Nameable.propertyMap<CT_>(),
                ..._Renderer_SourceCodeMixin.propertyMap<CT_>(),
                ..._Renderer_Indexable.propertyMap<CT_>(),
                ..._Renderer_FeatureSet.propertyMap<CT_>(),
                ..._Renderer_DocumentationComment.propertyMap<CT_>(),
                ..._Renderer_ModelBuilder.propertyMap<CT_>(),
                'annotations': Property(
                  getValue: (CT_ c) => c.annotations,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Annotation>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.annotations.map((e) => _render_Annotation(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'canonicalLibrary': Property(
                  getValue: (CT_ c) => c.canonicalLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.canonicalLibrary!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'canonicalModelElement': Property(
                  getValue: (CT_ c) => c.canonicalModelElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalModelElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.canonicalModelElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'compilationUnitElement': Property(
                  getValue: (CT_ c) => c.compilationUnitElement,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CompilationUnitElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(
                        c.compilationUnitElement, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CompilationUnitElement']!);
                  },
                ),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.config, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DartdocOptionContext']!);
                  },
                ),
                'definingLibrary': Property(
                  getValue: (CT_ c) => c.definingLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.definingLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'displayedCategories': Property(
                  getValue: (CT_ c) => c.displayedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.displayedCategories.map((e) =>
                        _render_Category(e!, ast, r.template, sink, parent: r));
                  },
                ),
                'documentation': Property(
                  getValue: (CT_ c) => c.documentation,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentation, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'exportedInLibraries': Property(
                  getValue: (CT_ c) => c.exportedInLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Library>'),
                  isNullValue: (CT_ c) => c.exportedInLibraries == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.exportedInLibraries, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Set']!);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.features.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Feature']!));
                  },
                ),
                'featuresAsString': Property(
                  getValue: (CT_ c) => c.featuresAsString,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.featuresAsString, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fileType': Property(
                  getValue: (CT_ c) => c.fileType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullyQualifiedNameWithoutLibrary': Property(
                  getValue: (CT_ c) => c.fullyQualifiedNameWithoutLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedNameWithoutLibrary, ast,
                        r.template, sink,
                        parent: r);
                  },
                ),
                'hasAnnotations': Property(
                  getValue: (CT_ c) => c.hasAnnotations,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasAnnotations == true,
                ),
                'hasCategoryNames': Property(
                  getValue: (CT_ c) => c.hasCategoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasCategoryNames == true,
                ),
                'hasDocumentation': Property(
                  getValue: (CT_ c) => c.hasDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentation == true,
                ),
                'hasFeatures': Property(
                  getValue: (CT_ c) => c.hasFeatures,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasFeatures == true,
                ),
                'hasParameters': Property(
                  getValue: (CT_ c) => c.hasParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasParameters == true,
                ),
                'hasSourceHref': Property(
                  getValue: (CT_ c) => c.hasSourceHref,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasSourceHref == true,
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'htmlId': Property(
                  getValue: (CT_ c) => c.htmlId,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.htmlId, ast, r.template, sink, parent: r);
                  },
                ),
                'isAsynchronous': Property(
                  getValue: (CT_ c) => c.isAsynchronous,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAsynchronous == true,
                ),
                'isCallable': Property(
                  getValue: (CT_ c) => c.isCallable,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCallable == true,
                ),
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'isConst': Property(
                  getValue: (CT_ c) => c.isConst,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isConst == true,
                ),
                'isDeprecated': Property(
                  getValue: (CT_ c) => c.isDeprecated,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDeprecated == true,
                ),
                'isDocumented': Property(
                  getValue: (CT_ c) => c.isDocumented,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDocumented == true,
                ),
                'isEnumValue': Property(
                  getValue: (CT_ c) => c.isEnumValue,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isEnumValue == true,
                ),
                'isExecutable': Property(
                  getValue: (CT_ c) => c.isExecutable,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isExecutable == true,
                ),
                'isFinal': Property(
                  getValue: (CT_ c) => c.isFinal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFinal == true,
                ),
                'isLate': Property(
                  getValue: (CT_ c) => c.isLate,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isLate == true,
                ),
                'isLocalElement': Property(
                  getValue: (CT_ c) => c.isLocalElement,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isLocalElement == true,
                ),
                'isPropertyAccessor': Property(
                  getValue: (CT_ c) => c.isPropertyAccessor,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPropertyAccessor == true,
                ),
                'isPropertyInducer': Property(
                  getValue: (CT_ c) => c.isPropertyInducer,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPropertyInducer == true,
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
                'isPublicAndPackageDocumented': Property(
                  getValue: (CT_ c) => c.isPublicAndPackageDocumented,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublicAndPackageDocumented == true,
                ),
                'isStatic': Property(
                  getValue: (CT_ c) => c.isStatic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isStatic == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedObjectType': Property(
                  getValue: (CT_ c) => c.linkedObjectType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedObjectType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedParams': Property(
                  getValue: (CT_ c) => c.linkedParams,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedParams, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedParamsLines': Property(
                  getValue: (CT_ c) => c.linkedParamsLines,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedParamsLines, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedParamsNoMetadata': Property(
                  getValue: (CT_ c) => c.linkedParamsNoMetadata,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedParamsNoMetadata == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedParamsNoMetadata!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'linkedParamsNoMetadataOrNames': Property(
                  getValue: (CT_ c) => c.linkedParamsNoMetadataOrNames,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedParamsNoMetadataOrNames, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'location': Property(
                  getValue: (CT_ c) => c.location,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.location, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.locationPieces.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'modelNode': Property(
                  getValue: (CT_ c) => c.modelNode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'ModelNode'),
                  isNullValue: (CT_ c) => c.modelNode == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.modelNode, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['ModelNode']!);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'oneLineDoc': Property(
                  getValue: (CT_ c) => c.oneLineDoc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.oneLineDoc, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'originalMember': Property(
                  getValue: (CT_ c) => c.originalMember,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Member'),
                  isNullValue: (CT_ c) => c.originalMember == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.originalMember, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Member']!);
                  },
                ),
                'package': Property(
                  getValue: (CT_ c) => c.package,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.package, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, sink, parent: r));
                  },
                ),
                'pathContext': Property(
                  getValue: (CT_ c) => c.pathContext,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Context'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.pathContext, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Context']!);
                  },
                ),
                'sourceCode': Property(
                  getValue: (CT_ c) => c.sourceCode,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceCode, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sourceFileName': Property(
                  getValue: (CT_ c) => c.sourceFileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceFileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sourceHref': Property(
                  getValue: (CT_ c) => c.sourceHref,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceHref, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ModelElement(ModelElement context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ModelElement>? getProperty(String key) {
    if (propertyMap<ModelElement>().containsKey(key)) {
      return propertyMap<ModelElement>()[key];
    } else {
      return null;
    }
  }
}

void _render_ModelFunction(ModelFunction context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_ModelFunction(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ModelFunction extends RendererBase<ModelFunction> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends ModelFunction>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelFunctionTyped.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FunctionElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['FunctionElement']!);
                  },
                ),
                'isAsynchronous': Property(
                  getValue: (CT_ c) => c.isAsynchronous,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAsynchronous == true,
                ),
                'isStatic': Property(
                  getValue: (CT_ c) => c.isStatic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isStatic == true,
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ModelFunction(ModelFunction context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ModelFunction>? getProperty(String key) {
    if (propertyMap<ModelFunction>().containsKey(key)) {
      return propertyMap<ModelFunction>()[key];
    } else {
      return null;
    }
  }
}

void _render_ModelFunctionTyped(ModelFunctionTyped context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_ModelFunctionTyped(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ModelFunctionTyped extends RendererBase<ModelFunctionTyped> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ModelFunctionTyped>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FunctionTypedElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['FunctionTypedElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Callable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Callable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Callable(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_ModelFunctionTyped(ModelFunctionTyped context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ModelFunctionTyped>? getProperty(String key) {
    if (propertyMap<ModelFunctionTyped>().containsKey(key)) {
      return propertyMap<ModelFunctionTyped>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Nameable extends RendererBase<Nameable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Nameable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'namePart': Property(
                  getValue: (CT_ c) => c.namePart,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.namePart, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'namePieces': Property(
                  getValue: (CT_ c) => c.namePieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.namePieces.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Nameable(Nameable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Nameable>? getProperty(String key) {
    if (propertyMap<Nameable>().containsKey(key)) {
      return propertyMap<Nameable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Object extends RendererBase<Object> {
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
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.hashCode, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Object(Object context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Object>? getProperty(String key) {
    if (propertyMap<Object>().containsKey(key)) {
      return propertyMap<Object>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_OneDirectoryDown<T extends Documentable>
    extends RendererBase<OneDirectoryDown<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>>
      propertyMap<T extends Documentable, CT_ extends OneDirectoryDown>() =>
          _propertyMapCache.putIfAbsent(
              CT_,
              () => {
                    'htmlBase': Property(
                      getValue: (CT_ c) => c.htmlBase,
                      renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) {
                        if (remainingNames.isEmpty) {
                          return self.getValue(c).toString();
                        }
                        var name = remainingNames.first;
                        var nextProperty =
                            _Renderer_String.propertyMap().getValue(name);
                        return nextProperty.renderVariable(
                            self.getValue(c) as String,
                            nextProperty,
                            [...remainingNames.skip(1)]);
                      },
                      isNullValue: (CT_ c) => false,
                      renderValue: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        _render_String(c.htmlBase, ast, r.template, sink,
                            parent: r);
                      },
                    ),
                  }) as Map<String, Property<CT_>>;

  _Renderer_OneDirectoryDown(OneDirectoryDown<T> context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<OneDirectoryDown<T>>? getProperty(String key) {
    if (propertyMap<T, OneDirectoryDown<T>>().containsKey(key)) {
      return propertyMap<T, OneDirectoryDown<T>>()[key];
    } else {
      return null;
    }
  }
}

void _render_Operator(Operator context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Operator(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Operator extends RendererBase<Operator> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Operator>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Method.propertyMap<CT_>(),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'isOperator': Property(
                  getValue: (CT_ c) => c.isOperator,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isOperator == true,
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'referenceName': Property(
                  getValue: (CT_ c) => c.referenceName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.referenceName, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Operator(Operator context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Operator>? getProperty(String key) {
    if (propertyMap<Operator>().containsKey(key)) {
      return propertyMap<Operator>()[key];
    } else {
      return null;
    }
  }
}

void _render_Package(Package context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Package(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Package extends RendererBase<Package> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Package>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_LibraryContainer.propertyMap<CT_>(),
                ..._Renderer_Nameable.propertyMap<CT_>(),
                ..._Renderer_Locatable.propertyMap<CT_>(),
                ..._Renderer_Canonicalization.propertyMap<CT_>(),
                ..._Renderer_Warnable.propertyMap<CT_>(),
                ..._Renderer_CommentReferable.propertyMap<CT_>(),
                ..._Renderer_ModelBuilder.propertyMap<CT_>(),
                'allLibraries': Property(
                  getValue: (CT_ c) => c.allLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Library>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.allLibraries.map((e) =>
                        _render_Library(e, ast, r.template, sink, parent: r));
                  },
                ),
                'baseHref': Property(
                  getValue: (CT_ c) => c.baseHref,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.baseHref, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'canonicalLibrary': Property(
                  getValue: (CT_ c) => c.canonicalLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.canonicalLibrary!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'categories': Property(
                  getValue: (CT_ c) => c.categories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.categories.map((e) =>
                        _render_Category(e, ast, r.template, sink, parent: r));
                  },
                ),
                'categoriesWithPublicLibraries': Property(
                  getValue: (CT_ c) => c.categoriesWithPublicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.categoriesWithPublicLibraries.map((e) =>
                        _render_Category(e, ast, r.template, sink, parent: r));
                  },
                ),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.config, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DartdocOptionContext']!);
                  },
                ),
                'containerOrder': Property(
                  getValue: (CT_ c) => c.containerOrder,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.containerOrder.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'defaultCategory': Property(
                  getValue: (CT_ c) => c.defaultCategory,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Category.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Category,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Category(c.defaultCategory, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentation': Property(
                  getValue: (CT_ c) => c.documentation,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentation!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationAsHtml': Property(
                  getValue: (CT_ c) => c.documentationAsHtml,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentationAsHtml, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Locatable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentationFrom.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Locatable']!));
                  },
                ),
                'documentedCategories': Property(
                  getValue: (CT_ c) => c.documentedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentedCategories.map((e) =>
                        _render_Category(e, ast, r.template, sink, parent: r));
                  },
                ),
                'documentedCategoriesSorted': Property(
                  getValue: (CT_ c) => c.documentedCategoriesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.documentedCategoriesSorted.map((e) =>
                        _render_Category(e, ast, r.template, sink, parent: r));
                  },
                ),
                'documentedWhere': Property(
                  getValue: (CT_ c) => c.documentedWhere,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DocumentLocation'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.documentedWhere, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['DocumentLocation']!);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'enclosingName': Property(
                  getValue: (CT_ c) => c.enclosingName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.enclosingName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fileType': Property(
                  getValue: (CT_ c) => c.fileType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'fullyQualifiedName': Property(
                  getValue: (CT_ c) => c.fullyQualifiedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fullyQualifiedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasCategories': Property(
                  getValue: (CT_ c) => c.hasCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasCategories == true,
                ),
                'hasDocumentation': Property(
                  getValue: (CT_ c) => c.hasDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentation == true,
                ),
                'hasDocumentedCategories': Property(
                  getValue: (CT_ c) => c.hasDocumentedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentedCategories == true,
                ),
                'hasHomepage': Property(
                  getValue: (CT_ c) => c.hasHomepage,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasHomepage == true,
                ),
                'homepage': Property(
                  getValue: (CT_ c) => c.homepage,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.homepage, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href, ast, r.template, sink, parent: r);
                  },
                ),
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'isDocumented': Property(
                  getValue: (CT_ c) => c.isDocumented,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isDocumented == true,
                ),
                'isFirstPackage': Property(
                  getValue: (CT_ c) => c.isFirstPackage,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFirstPackage == true,
                ),
                'isLocal': Property(
                  getValue: (CT_ c) => c.isLocal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isLocal == true,
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
                'isSdk': Property(
                  getValue: (CT_ c) => c.isSdk,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isSdk == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'location': Property(
                  getValue: (CT_ c) => c.location,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.location, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.locationPieces.map((e) =>
                        _render_String(e, ast, r.template, sink, parent: r));
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'nameToCategory': Property(
                  getValue: (CT_ c) => c.nameToCategory,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, Category>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.nameToCategory, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'oneLineDoc': Property(
                  getValue: (CT_ c) => c.oneLineDoc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.oneLineDoc, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'package': Property(
                  getValue: (CT_ c) => c.package,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.package, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageGraph, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageGraph']!);
                  },
                ),
                'packageMeta': Property(
                  getValue: (CT_ c) => c.packageMeta,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageMeta'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.packageMeta, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['PackageMeta']!);
                  },
                ),
                'packagePath': Property(
                  getValue: (CT_ c) => c.packagePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.packagePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'publicLibraries': Property(
                  getValue: (CT_ c) => c.publicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Library>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicLibraries.map((e) =>
                        _render_Library(e, ast, r.template, sink, parent: r));
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceName': Property(
                  getValue: (CT_ c) => c.referenceName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.referenceName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'toolInvocationIndex': Property(
                  getValue: (CT_ c) => c.toolInvocationIndex,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.toolInvocationIndex, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'usedAnimationIdsByHref': Property(
                  getValue: (CT_ c) => c.usedAnimationIdsByHref,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, Set<String>>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(
                        c.usedAnimationIdsByHref, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'version': Property(
                  getValue: (CT_ c) => c.version,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.version, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Package(Package context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Package>? getProperty(String key) {
    if (propertyMap<Package>().containsKey(key)) {
      return propertyMap<Package>()[key];
    } else {
      return null;
    }
  }
}

String renderSearchPage(PackageTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_PackageTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_PackageTemplateData(PackageTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_PackageTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_PackageTemplateData extends RendererBase<PackageTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends PackageTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Package, CT_>(),
                'bareHref': Property(
                  getValue: (CT_ c) => c.bareHref,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.bareHref, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasHomepage': Property(
                  getValue: (CT_ c) => c.hasHomepage,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasHomepage == true,
                ),
                'homepage': Property(
                  getValue: (CT_ c) => c.homepage,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.homepage, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'htmlBase': Property(
                  getValue: (CT_ c) => c.htmlBase,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.htmlBase, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'includeVersion': Property(
                  getValue: (CT_ c) => c.includeVersion,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.includeVersion == true,
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'package': Property(
                  getValue: (CT_ c) => c.package,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.package, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_PackageTemplateData(PackageTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<PackageTemplateData>? getProperty(String key) {
    if (propertyMap<PackageTemplateData>().containsKey(key)) {
      return propertyMap<PackageTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderIndex(PackageTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_PackageTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

String renderError(PackageTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_PackageTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_Parameter(Parameter context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Parameter(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Parameter extends RendererBase<Parameter> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Parameter>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_HasNoPage.propertyMap<CT_>(),
                'defaultValue': Property(
                  getValue: (CT_ c) => c.defaultValue,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.defaultValue == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.defaultValue!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ParameterElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ParameterElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasDefaultValue': Property(
                  getValue: (CT_ c) => c.hasDefaultValue,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDefaultValue == true,
                ),
                'hashCode': Property(
                  getValue: (CT_ c) => c.hashCode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.hashCode, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'htmlId': Property(
                  getValue: (CT_ c) => c.htmlId,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.htmlId, ast, r.template, sink, parent: r);
                  },
                ),
                'isCovariant': Property(
                  getValue: (CT_ c) => c.isCovariant,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCovariant == true,
                ),
                'isNamed': Property(
                  getValue: (CT_ c) => c.isNamed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isNamed == true,
                ),
                'isOptionalPositional': Property(
                  getValue: (CT_ c) => c.isOptionalPositional,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isOptionalPositional == true,
                ),
                'isRequiredNamed': Property(
                  getValue: (CT_ c) => c.isRequiredNamed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isRequiredNamed == true,
                ),
                'isRequiredPositional': Property(
                  getValue: (CT_ c) => c.isRequiredPositional,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isRequiredPositional == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'originalMember': Property(
                  getValue: (CT_ c) => c.originalMember,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ParameterMember'),
                  isNullValue: (CT_ c) => c.originalMember == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.originalMember, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['ParameterMember']!);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Parameter(Parameter context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Parameter>? getProperty(String key) {
    if (propertyMap<Parameter>().containsKey(key)) {
      return propertyMap<Parameter>()[key];
    } else {
      return null;
    }
  }
}

void _render_ParameterizedElementType(ParameterizedElementType context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_ParameterizedElementType(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_ParameterizedElementType
    extends RendererBase<ParameterizedElementType> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>>
      propertyMap<CT_ extends ParameterizedElementType>() =>
          _propertyMapCache.putIfAbsent(
              CT_,
              () => {
                    ..._Renderer_DefinedElementType.propertyMap<CT_>(),
                    ..._Renderer_Rendered.propertyMap<CT_>(),
                    'type': Property(
                      getValue: (CT_ c) => c.type,
                      renderVariable: (CT_ c, Property<CT_> self,
                              List<String> remainingNames) =>
                          self.renderSimpleVariable(
                              c, remainingNames, 'ParameterizedType'),
                      isNullValue: (CT_ c) => false,
                      renderValue: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        renderSimple(c.type, ast, r.template, sink,
                            parent: r,
                            getters: _invisibleGetters['ParameterizedType']!);
                      },
                    ),
                    'typeArguments': Property(
                      getValue: (CT_ c) => c.typeArguments,
                      renderVariable: (CT_ c, Property<CT_> self,
                              List<String> remainingNames) =>
                          self.renderSimpleVariable(
                              c, remainingNames, 'Iterable<ElementType>'),
                      renderIterable: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        return c.typeArguments.map((e) => _render_ElementType(
                            e, ast, r.template, sink,
                            parent: r));
                      },
                    ),
                  }) as Map<String, Property<CT_>>;

  _Renderer_ParameterizedElementType(ParameterizedElementType context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<ParameterizedElementType>? getProperty(String key) {
    if (propertyMap<ParameterizedElementType>().containsKey(key)) {
      return propertyMap<ParameterizedElementType>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Privacy extends RendererBase<Privacy> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Privacy>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Privacy(Privacy context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Privacy>? getProperty(String key) {
    if (propertyMap<Privacy>().containsKey(key)) {
      return propertyMap<Privacy>()[key];
    } else {
      return null;
    }
  }
}

String renderProperty(PropertyTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_PropertyTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_PropertyTemplateData(PropertyTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_PropertyTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_PropertyTemplateData
    extends RendererBase<PropertyTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends PropertyTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Field, CT_>(),
                ..._Renderer_TwoDirectoriesDown.propertyMap<Field, CT_>(),
                'container': Property(
                  getValue: (CT_ c) => c.container,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.container, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, sink, parent: r));
                  },
                ),
                'property': Property(
                  getValue: (CT_ c) => c.property,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Field.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Field,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Field(c.property, ast, r.template, sink, parent: r);
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Field.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Field,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Field(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'sidebarForContainer': Property(
                  getValue: (CT_ c) => c.sidebarForContainer,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForContainer, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_PropertyTemplateData(PropertyTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<PropertyTemplateData>? getProperty(String key) {
    if (propertyMap<PropertyTemplateData>().containsKey(key)) {
      return propertyMap<PropertyTemplateData>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Rendered extends RendererBase<Rendered> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Rendered>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'nameWithGenerics': Property(
                  getValue: (CT_ c) => c.nameWithGenerics,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nameWithGenerics, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Rendered(Rendered context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Rendered>? getProperty(String key) {
    if (propertyMap<Rendered>().containsKey(key)) {
      return propertyMap<Rendered>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_SourceCodeMixin extends RendererBase<SourceCodeMixin> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends SourceCodeMixin>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.characterLocation, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CharacterLocation']!);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'hasSourceCode': Property(
                  getValue: (CT_ c) => c.hasSourceCode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasSourceCode == true,
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'modelNode': Property(
                  getValue: (CT_ c) => c.modelNode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'ModelNode'),
                  isNullValue: (CT_ c) => c.modelNode == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.modelNode, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['ModelNode']!);
                  },
                ),
                'sourceCode': Property(
                  getValue: (CT_ c) => c.sourceCode,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sourceCode, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_SourceCodeMixin(SourceCodeMixin context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<SourceCodeMixin>? getProperty(String key) {
    if (propertyMap<SourceCodeMixin>().containsKey(key)) {
      return propertyMap<SourceCodeMixin>()[key];
    } else {
      return null;
    }
  }
}

void _render_String(
    String context, List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_String(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_String extends RendererBase<String> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends String>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'codeUnits': Property(
                  getValue: (CT_ c) => c.codeUnits,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'List<int>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.codeUnits.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!));
                  },
                ),
                'hashCode': Property(
                  getValue: (CT_ c) => c.hashCode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.hashCode, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'isEmpty': Property(
                  getValue: (CT_ c) => c.isEmpty,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isEmpty == true,
                ),
                'isNotEmpty': Property(
                  getValue: (CT_ c) => c.isNotEmpty,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isNotEmpty == true,
                ),
                'length': Property(
                  getValue: (CT_ c) => c.length,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.length, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!);
                  },
                ),
                'runes': Property(
                  getValue: (CT_ c) => c.runes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Runes'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.runes.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['int']!));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_String(String context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<String>? getProperty(String key) {
    if (propertyMap<String>().containsKey(key)) {
      return propertyMap<String>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_TemplateData<T extends Documentable>
    extends RendererBase<TemplateData<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>>
      propertyMap<T extends Documentable, CT_ extends TemplateData>() =>
          _propertyMapCache.putIfAbsent(
              CT_,
              () => {
                    ..._Renderer_TemplateDataBase.propertyMap<CT_>(),
                    'self': Property(
                      getValue: (CT_ c) => c.self,
                      renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) {
                        if (remainingNames.isEmpty) {
                          return self.getValue(c).toString();
                        }
                        var name = remainingNames.first;
                        var nextProperty =
                            _Renderer_Documentable.propertyMap().getValue(name);
                        return nextProperty.renderVariable(
                            self.getValue(c) as Documentable,
                            nextProperty,
                            [...remainingNames.skip(1)]);
                      },
                      isNullValue: (CT_ c) => false,
                      renderValue: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        _render_Documentable(c.self, ast, r.template, sink,
                            parent: r);
                      },
                    ),
                  }) as Map<String, Property<CT_>>;

  _Renderer_TemplateData(TemplateData<T> context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TemplateData<T>>? getProperty(String key) {
    if (propertyMap<T, TemplateData<T>>().containsKey(key)) {
      return propertyMap<T, TemplateData<T>>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_TemplateDataBase extends RendererBase<TemplateDataBase> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TemplateDataBase>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'bareHref': Property(
                  getValue: (CT_ c) => c.bareHref,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.bareHref, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'customFooter': Property(
                  getValue: (CT_ c) => c.customFooter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.customFooter, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'customHeader': Property(
                  getValue: (CT_ c) => c.customHeader,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.customHeader, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'customInnerFooter': Property(
                  getValue: (CT_ c) => c.customInnerFooter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.customInnerFooter, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'defaultPackage': Property(
                  getValue: (CT_ c) => c.defaultPackage,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.defaultPackage, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasFooterVersion': Property(
                  getValue: (CT_ c) => c.hasFooterVersion,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasFooterVersion == true,
                ),
                'hasHomepage': Property(
                  getValue: (CT_ c) => c.hasHomepage,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasHomepage == true,
                ),
                'homepage': Property(
                  getValue: (CT_ c) => c.homepage,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.homepage == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.homepage!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'htmlBase': Property(
                  getValue: (CT_ c) => c.htmlBase,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.htmlBase, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'htmlOptions': Property(
                  getValue: (CT_ c) => c.htmlOptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TemplateOptions'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.htmlOptions, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['TemplateOptions']!);
                  },
                ),
                'includeVersion': Property(
                  getValue: (CT_ c) => c.includeVersion,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.includeVersion == true,
                ),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'localPackages': Property(
                  getValue: (CT_ c) => c.localPackages,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Package>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.localPackages.map((e) =>
                        _render_Package(e, ast, r.template, sink, parent: r));
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, sink, parent: r));
                  },
                ),
                'parent': Property(
                  getValue: (CT_ c) => c.parent,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Documentable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Documentable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.parent == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Documentable(c.parent!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'relCanonicalPrefix': Property(
                  getValue: (CT_ c) => c.relCanonicalPrefix,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.relCanonicalPrefix!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Documentable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Documentable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Documentable(c.self, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
                'useBaseHref': Property(
                  getValue: (CT_ c) => c.useBaseHref,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.useBaseHref == true,
                ),
                'version': Property(
                  getValue: (CT_ c) => c.version,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.version, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TemplateDataBase(TemplateDataBase context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TemplateDataBase>? getProperty(String key) {
    if (propertyMap<TemplateDataBase>().containsKey(key)) {
      return propertyMap<TemplateDataBase>()[key];
    } else {
      return null;
    }
  }
}

String renderSidebarForContainer<T extends Documentable>(
    TemplateDataWithContainer<T> context, Template template) {
  var buffer = StringBuffer();
  _render_TemplateDataWithContainer(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_TemplateDataWithContainer<T extends Documentable>(
    TemplateDataWithContainer<T> context,
    List<MustachioNode> ast,
    Template template,
    StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_TemplateDataWithContainer(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_TemplateDataWithContainer<T extends Documentable>
    extends RendererBase<TemplateDataWithContainer<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<T extends Documentable,
          CT_ extends TemplateDataWithContainer>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'container': Property(
                  getValue: (CT_ c) => c.container,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Container.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Container,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Container(c.container, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TemplateDataWithContainer(TemplateDataWithContainer<T> context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TemplateDataWithContainer<T>>? getProperty(String key) {
    if (propertyMap<T, TemplateDataWithContainer<T>>().containsKey(key)) {
      return propertyMap<T, TemplateDataWithContainer<T>>()[key];
    } else {
      return null;
    }
  }
}

String renderSidebarForLibrary<T extends Documentable>(
    TemplateDataWithLibrary<T> context, Template template) {
  var buffer = StringBuffer();
  _render_TemplateDataWithLibrary(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_TemplateDataWithLibrary<T extends Documentable>(
    TemplateDataWithLibrary<T> context,
    List<MustachioNode> ast,
    Template template,
    StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_TemplateDataWithLibrary(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_TemplateDataWithLibrary<T extends Documentable>
    extends RendererBase<TemplateDataWithLibrary<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<T extends Documentable,
          CT_ extends TemplateDataWithLibrary>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TemplateDataWithLibrary(TemplateDataWithLibrary<T> context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TemplateDataWithLibrary<T>>? getProperty(String key) {
    if (propertyMap<T, TemplateDataWithLibrary<T>>().containsKey(key)) {
      return propertyMap<T, TemplateDataWithLibrary<T>>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_TopLevelContainer extends RendererBase<TopLevelContainer> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TopLevelContainer>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'classes': Property(
                  getValue: (CT_ c) => c.classes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.classes.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'constants': Property(
                  getValue: (CT_ c) => c.constants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.constants.map((e) => _render_TopLevelVariable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'enums': Property(
                  getValue: (CT_ c) => c.enums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.enums.map((e) =>
                        _render_Enum(e, ast, r.template, sink, parent: r));
                  },
                ),
                'exceptions': Property(
                  getValue: (CT_ c) => c.exceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.exceptions.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'extensions': Property(
                  getValue: (CT_ c) => c.extensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.extensions.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
                'functions': Property(
                  getValue: (CT_ c) => c.functions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunction>'),
                  isNullValue: (CT_ c) => c.functions == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.functions, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Iterable']!);
                  },
                ),
                'hasPublicClasses': Property(
                  getValue: (CT_ c) => c.hasPublicClasses,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicClasses == true,
                ),
                'hasPublicConstants': Property(
                  getValue: (CT_ c) => c.hasPublicConstants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicConstants == true,
                ),
                'hasPublicEnums': Property(
                  getValue: (CT_ c) => c.hasPublicEnums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicEnums == true,
                ),
                'hasPublicExceptions': Property(
                  getValue: (CT_ c) => c.hasPublicExceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicExceptions == true,
                ),
                'hasPublicExtensions': Property(
                  getValue: (CT_ c) => c.hasPublicExtensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicExtensions == true,
                ),
                'hasPublicFunctions': Property(
                  getValue: (CT_ c) => c.hasPublicFunctions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicFunctions == true,
                ),
                'hasPublicMixins': Property(
                  getValue: (CT_ c) => c.hasPublicMixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicMixins == true,
                ),
                'hasPublicProperties': Property(
                  getValue: (CT_ c) => c.hasPublicProperties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicProperties == true,
                ),
                'hasPublicTypedefs': Property(
                  getValue: (CT_ c) => c.hasPublicTypedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicTypedefs == true,
                ),
                'mixins': Property(
                  getValue: (CT_ c) => c.mixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Mixin>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.mixins.map((e) =>
                        _render_Mixin(e, ast, r.template, sink, parent: r));
                  },
                ),
                'properties': Property(
                  getValue: (CT_ c) => c.properties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.properties.map((e) => _render_TopLevelVariable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'publicClasses': Property(
                  getValue: (CT_ c) => c.publicClasses,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicClasses.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicClassesSorted': Property(
                  getValue: (CT_ c) => c.publicClassesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Container>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicClassesSorted.map((e) =>
                        _render_Container(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicConstants': Property(
                  getValue: (CT_ c) => c.publicConstants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicConstants.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicConstantsSorted': Property(
                  getValue: (CT_ c) => c.publicConstantsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicConstantsSorted.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicEnums': Property(
                  getValue: (CT_ c) => c.publicEnums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicEnums.map((e) =>
                        _render_Enum(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicEnumsSorted': Property(
                  getValue: (CT_ c) => c.publicEnumsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicEnumsSorted.map((e) =>
                        _render_Enum(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicExceptionsSorted': Property(
                  getValue: (CT_ c) => c.publicExceptionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicExceptionsSorted.map((e) =>
                        _render_Class(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicExtensions': Property(
                  getValue: (CT_ c) => c.publicExtensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicExtensions.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicExtensionsSorted': Property(
                  getValue: (CT_ c) => c.publicExtensionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicExtensionsSorted.map((e) =>
                        _render_Extension(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicFunctions': Property(
                  getValue: (CT_ c) => c.publicFunctions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunctionTyped>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicFunctions.map((e) =>
                        _render_ModelFunctionTyped(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicFunctionsSorted': Property(
                  getValue: (CT_ c) => c.publicFunctionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunctionTyped>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicFunctionsSorted.map((e) =>
                        _render_ModelFunctionTyped(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicMixins': Property(
                  getValue: (CT_ c) => c.publicMixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Mixin>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicMixins.map((e) =>
                        _render_Mixin(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicMixinsSorted': Property(
                  getValue: (CT_ c) => c.publicMixinsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Mixin>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicMixinsSorted.map((e) =>
                        _render_Mixin(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicProperties': Property(
                  getValue: (CT_ c) => c.publicProperties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicProperties.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicPropertiesSorted': Property(
                  getValue: (CT_ c) => c.publicPropertiesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicPropertiesSorted.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicTypedefs': Property(
                  getValue: (CT_ c) => c.publicTypedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicTypedefs.map((e) =>
                        _render_Typedef(e, ast, r.template, sink, parent: r));
                  },
                ),
                'publicTypedefsSorted': Property(
                  getValue: (CT_ c) => c.publicTypedefsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicTypedefsSorted.map((e) =>
                        _render_Typedef(e, ast, r.template, sink, parent: r));
                  },
                ),
                'typedefs': Property(
                  getValue: (CT_ c) => c.typedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typedefs.map((e) =>
                        _render_Typedef(e, ast, r.template, sink, parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TopLevelContainer(TopLevelContainer context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TopLevelContainer>? getProperty(String key) {
    if (propertyMap<TopLevelContainer>().containsKey(key)) {
      return propertyMap<TopLevelContainer>()[key];
    } else {
      return null;
    }
  }
}

String renderTopLevelProperty(
    TopLevelPropertyTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_TopLevelPropertyTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_TopLevelPropertyTemplateData(TopLevelPropertyTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer =
      _Renderer_TopLevelPropertyTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_TopLevelPropertyTemplateData
    extends RendererBase<TopLevelPropertyTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TopLevelPropertyTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<TopLevelVariable, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<TopLevelVariable,
                    CT_>(),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'property': Property(
                  getValue: (CT_ c) => c.property,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_TopLevelVariable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as TopLevelVariable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_TopLevelVariable(c.property, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_TopLevelVariable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as TopLevelVariable,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_TopLevelVariable(c.self, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'sidebarForLibrary': Property(
                  getValue: (CT_ c) => c.sidebarForLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TopLevelPropertyTemplateData(TopLevelPropertyTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TopLevelPropertyTemplateData>? getProperty(String key) {
    if (propertyMap<TopLevelPropertyTemplateData>().containsKey(key)) {
      return propertyMap<TopLevelPropertyTemplateData>()[key];
    } else {
      return null;
    }
  }
}

void _render_TopLevelVariable(TopLevelVariable context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_TopLevelVariable(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_TopLevelVariable extends RendererBase<TopLevelVariable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TopLevelVariable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_GetterSetterCombo.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                'documentation': Property(
                  getValue: (CT_ c) => c.documentation,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.documentation, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TopLevelVariableElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['TopLevelVariableElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.features.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Feature']!));
                  },
                ),
                'fileName': Property(
                  getValue: (CT_ c) => c.fileName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.fileName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'getter': Property(
                  getValue: (CT_ c) => c.getter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Accessor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Accessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.getter == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Accessor(c.getter!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isConst': Property(
                  getValue: (CT_ c) => c.isConst,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isConst == true,
                ),
                'isFinal': Property(
                  getValue: (CT_ c) => c.isFinal,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isFinal == true,
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'isLate': Property(
                  getValue: (CT_ c) => c.isLate,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isLate == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'setter': Property(
                  getValue: (CT_ c) => c.setter,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Accessor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Accessor,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.setter == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Accessor(c.setter!, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TopLevelVariable(TopLevelVariable context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TopLevelVariable>? getProperty(String key) {
    if (propertyMap<TopLevelVariable>().containsKey(key)) {
      return propertyMap<TopLevelVariable>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_TwoDirectoriesDown<T extends Documentable>
    extends RendererBase<TwoDirectoriesDown<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>>
      propertyMap<T extends Documentable, CT_ extends TwoDirectoriesDown>() =>
          _propertyMapCache.putIfAbsent(
              CT_,
              () => {
                    'htmlBase': Property(
                      getValue: (CT_ c) => c.htmlBase,
                      renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) {
                        if (remainingNames.isEmpty) {
                          return self.getValue(c).toString();
                        }
                        var name = remainingNames.first;
                        var nextProperty =
                            _Renderer_String.propertyMap().getValue(name);
                        return nextProperty.renderVariable(
                            self.getValue(c) as String,
                            nextProperty,
                            [...remainingNames.skip(1)]);
                      },
                      isNullValue: (CT_ c) => false,
                      renderValue: (CT_ c, RendererBase<CT_> r,
                          List<MustachioNode> ast, StringSink sink) {
                        _render_String(c.htmlBase, ast, r.template, sink,
                            parent: r);
                      },
                    ),
                  }) as Map<String, Property<CT_>>;

  _Renderer_TwoDirectoriesDown(TwoDirectoriesDown<T> context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TwoDirectoriesDown<T>>? getProperty(String key) {
    if (propertyMap<T, TwoDirectoriesDown<T>>().containsKey(key)) {
      return propertyMap<T, TwoDirectoriesDown<T>>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_TypeImplementing extends RendererBase<TypeImplementing> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TypeImplementing>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'directInterfaces': Property(
                  getValue: (CT_ c) => c.directInterfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.directInterfaces.map((e) =>
                        _render_DefinedElementType(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'hasModifiers': Property(
                  getValue: (CT_ c) => c.hasModifiers,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasModifiers == true,
                ),
                'hasPublicImplementors': Property(
                  getValue: (CT_ c) => c.hasPublicImplementors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicImplementors == true,
                ),
                'hasPublicInterfaces': Property(
                  getValue: (CT_ c) => c.hasPublicInterfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInterfaces == true,
                ),
                'interfaces': Property(
                  getValue: (CT_ c) => c.interfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.interfaces.map((e) => _render_DefinedElementType(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'publicImplementors': Property(
                  getValue: (CT_ c) => c.publicImplementors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicImplementors.map((e) =>
                        _render_InheritingContainer(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicImplementorsSorted': Property(
                  getValue: (CT_ c) => c.publicImplementorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<InheritingContainer>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicImplementorsSorted.map((e) =>
                        _render_InheritingContainer(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
                'publicInterfaces': Property(
                  getValue: (CT_ c) => c.publicInterfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.publicInterfaces.map((e) =>
                        _render_DefinedElementType(e, ast, r.template, sink,
                            parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TypeImplementing(TypeImplementing context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TypeImplementing>? getProperty(String key) {
    if (propertyMap<TypeImplementing>().containsKey(key)) {
      return propertyMap<TypeImplementing>()[key];
    } else {
      return null;
    }
  }
}

void _render_TypeParameter(TypeParameter context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_TypeParameter(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_TypeParameter extends RendererBase<TypeParameter> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends TypeParameter>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_HasNoPage.propertyMap<CT_>(),
                'boundType': Property(
                  getValue: (CT_ c) => c.boundType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.boundType == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.boundType!, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeParameterElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['TypeParameterElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ModelElement,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ModelElement(
                        c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasParameters': Property(
                  getValue: (CT_ c) => c.hasParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasParameters == true,
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'linkedName': Property(
                  getValue: (CT_ c) => c.linkedName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.linkedName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'name': Property(
                  getValue: (CT_ c) => c.name,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.name, ast, r.template, sink, parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceName': Property(
                  getValue: (CT_ c) => c.referenceName,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.referenceName, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TypeParameter(TypeParameter context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TypeParameter>? getProperty(String key) {
    if (propertyMap<TypeParameter>().containsKey(key)) {
      return propertyMap<TypeParameter>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_TypeParameters extends RendererBase<TypeParameters> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends TypeParameters>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'genericParameters': Property(
                  getValue: (CT_ c) => c.genericParameters,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.genericParameters, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'hasGenericParameters': Property(
                  getValue: (CT_ c) => c.hasGenericParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasGenericParameters == true,
                ),
                'linkedGenericParameters': Property(
                  getValue: (CT_ c) => c.linkedGenericParameters,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedGenericParameters, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'nameWithGenerics': Property(
                  getValue: (CT_ c) => c.nameWithGenerics,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nameWithGenerics, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'nameWithLinkedGenerics': Property(
                  getValue: (CT_ c) => c.nameWithLinkedGenerics,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.nameWithLinkedGenerics, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TypeParameters(TypeParameters context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TypeParameters>? getProperty(String key) {
    if (propertyMap<TypeParameters>().containsKey(key)) {
      return propertyMap<TypeParameters>()[key];
    } else {
      return null;
    }
  }
}

void _render_Typedef(Typedef context, List<MustachioNode> ast,
    Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_Typedef(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_Typedef extends RendererBase<Typedef> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Typedef>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                'aliasedType': Property(
                  getValue: (CT_ c) => c.aliasedType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'DartType'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.aliasedType, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['DartType']!);
                  },
                ),
                'asCallable': Property(
                  getValue: (CT_ c) => c.asCallable,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_FunctionTypedef.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as FunctionTypedef,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_FunctionTypedef(c.asCallable, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeAliasElement'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['TypeAliasElement']!);
                  },
                ),
                'enclosingElement': Property(
                  getValue: (CT_ c) => c.enclosingElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.enclosingElement, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'filePath': Property(
                  getValue: (CT_ c) => c.filePath,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.filePath, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'genericParameters': Property(
                  getValue: (CT_ c) => c.genericParameters,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.genericParameters, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'href': Property(
                  getValue: (CT_ c) => c.href,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.href!, ast, r.template, sink, parent: r);
                  },
                ),
                'isInherited': Property(
                  getValue: (CT_ c) => c.isInherited,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isInherited == true,
                ),
                'kind': Property(
                  getValue: (CT_ c) => c.kind,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.kind, ast, r.template, sink, parent: r);
                  },
                ),
                'linkedGenericParameters': Property(
                  getValue: (CT_ c) => c.linkedGenericParameters,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(
                        c.linkedGenericParameters, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'modelType': Property(
                  getValue: (CT_ c) => c.modelType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as ElementType,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_ElementType(c.modelType, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'nameWithGenerics': Property(
                  getValue: (CT_ c) => c.nameWithGenerics,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.nameWithGenerics, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'referenceChildren': Property(
                  getValue: (CT_ c) => c.referenceChildren,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, CommentReferable>'),
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.referenceChildren, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Map']!);
                  },
                ),
                'referenceParents': Property(
                  getValue: (CT_ c) => c.referenceParents,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<CommentReferable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.referenceParents.map((e) => renderSimple(
                        e, ast, r.template, sink,
                        parent: r,
                        getters: _invisibleGetters['CommentReferable']!));
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.typeParameters.map((e) => _render_TypeParameter(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Typedef(Typedef context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Typedef>? getProperty(String key) {
    if (propertyMap<Typedef>().containsKey(key)) {
      return propertyMap<Typedef>()[key];
    } else {
      return null;
    }
  }
}

String renderTypedef(TypedefTemplateData context, Template template) {
  var buffer = StringBuffer();
  _render_TypedefTemplateData(context, template.ast, template, buffer);
  return buffer.toString();
}

void _render_TypedefTemplateData(TypedefTemplateData context,
    List<MustachioNode> ast, Template template, StringSink sink,
    {RendererBase<Object>? parent}) {
  var renderer = _Renderer_TypedefTemplateData(context, parent, template, sink);
  renderer.renderBlock(ast);
}

class _Renderer_TypedefTemplateData extends RendererBase<TypedefTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TypedefTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Typedef, CT_>(),
                ..._Renderer_OneDirectoryDown.propertyMap<Typedef, CT_>(),
                'layoutTitle': Property(
                  getValue: (CT_ c) => c.layoutTitle,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.layoutTitle, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'library': Property(
                  getValue: (CT_ c) => c.library,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Library.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Library,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Library(c.library, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'metaDescription': Property(
                  getValue: (CT_ c) => c.metaDescription,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.metaDescription, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    return c.navLinks.map((e) => _render_Documentable(
                        e, ast, r.template, sink,
                        parent: r));
                  },
                ),
                'self': Property(
                  getValue: (CT_ c) => c.self,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Typedef.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Typedef,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Typedef(c.self, ast, r.template, sink, parent: r);
                  },
                ),
                'sidebarForLibrary': Property(
                  getValue: (CT_ c) => c.sidebarForLibrary,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.sidebarForLibrary, ast, r.template, sink,
                        parent: r);
                  },
                ),
                'title': Property(
                  getValue: (CT_ c) => c.title,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as String,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_String(c.title, ast, r.template, sink, parent: r);
                  },
                ),
                'typeDef': Property(
                  getValue: (CT_ c) => c.typeDef,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Typedef.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Typedef,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Typedef(c.typeDef, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_TypedefTemplateData(TypedefTemplateData context,
      RendererBase<Object>? parent, Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<TypedefTemplateData>? getProperty(String key) {
    if (propertyMap<TypedefTemplateData>().containsKey(key)) {
      return propertyMap<TypedefTemplateData>()[key];
    } else {
      return null;
    }
  }
}

class _Renderer_Warnable extends RendererBase<Warnable> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Warnable>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    renderSimple(c.element, ast, r.template, sink,
                        parent: r, getters: _invisibleGetters['Element']!);
                  },
                ),
                'package': Property(
                  getValue: (CT_ c) => c.package,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Package.propertyMap().getValue(name);
                    return nextProperty.renderVariable(
                        self.getValue(c) as Package,
                        nextProperty,
                        [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => false,
                  renderValue: (CT_ c, RendererBase<CT_> r,
                      List<MustachioNode> ast, StringSink sink) {
                    _render_Package(c.package, ast, r.template, sink,
                        parent: r);
                  },
                ),
              }) as Map<String, Property<CT_>>;

  _Renderer_Warnable(Warnable context, RendererBase<Object>? parent,
      Template template, StringSink sink)
      : super(context, parent, template, sink);

  @override
  Property<Warnable>? getProperty(String key) {
    if (propertyMap<Warnable>().containsKey(key)) {
      return propertyMap<Warnable>()[key];
    } else {
      return null;
    }
  }
}

const _invisibleGetters = {
  'CategoryDefinition': {
    'displayName',
    'documentationMarkdown',
    'hashCode',
    'name',
    'runtimeType'
  },
  'CharacterLocation': {
    'columnNumber',
    'hashCode',
    'lineNumber',
    'runtimeType'
  },
  'ClassElement': {
    'augmented',
    'hasNonFinalField',
    'hashCode',
    'isAbstract',
    'isBase',
    'isConstructable',
    'isDartCoreEnum',
    'isDartCoreObject',
    'isExhaustive',
    'isFinal',
    'isInterface',
    'isMixinApplication',
    'isMixinClass',
    'isSealed',
    'isValidMixin',
    'runtimeType',
    'superclassConstraints'
  },
  'CommentReferable': {
    'definingCommentReferable',
    'href',
    'library',
    'referenceChildren',
    'referenceGrandparentOverrides',
    'referenceName',
    'referenceParents',
    'scope'
  },
  'CompilationUnitElement': {
    'accessors',
    'classes',
    'enclosingElement',
    'enclosingElement3',
    'enums',
    'enums2',
    'extensions',
    'functions',
    'hashCode',
    'lineInfo',
    'mixins',
    'mixins2',
    'runtimeType',
    'session',
    'topLevelVariables',
    'typeAliases'
  },
  'Constructable': {
    'constructors',
    'extraReferenceChildren',
    'hasPublicConstructors',
    'publicConstructorsSorted'
  },
  'ConstructorElement': {
    'augmentation',
    'declaration',
    'displayName',
    'enclosingElement',
    'enclosingElement3',
    'hashCode',
    'isConst',
    'isDefaultConstructor',
    'isFactory',
    'isGenerative',
    'name',
    'nameEnd',
    'periodOffset',
    'redirectedConstructor',
    'returnType',
    'runtimeType'
  },
  'ContainerModifier': {
    'displayName',
    'hashCode',
    'hideIfPresent',
    'name',
    'order',
    'runtimeType'
  },
  'Context': {'current', 'hashCode', 'runtimeType', 'separator', 'style'},
  'DartType': {
    'alias',
    'element',
    'element2',
    'hashCode',
    'isBottom',
    'isDartAsyncFuture',
    'isDartAsyncFutureOr',
    'isDartAsyncStream',
    'isDartCoreBool',
    'isDartCoreDouble',
    'isDartCoreEnum',
    'isDartCoreFunction',
    'isDartCoreInt',
    'isDartCoreIterable',
    'isDartCoreList',
    'isDartCoreMap',
    'isDartCoreNull',
    'isDartCoreNum',
    'isDartCoreObject',
    'isDartCoreRecord',
    'isDartCoreSet',
    'isDartCoreString',
    'isDartCoreSymbol',
    'isDartCoreType',
    'isDynamic',
    'isVoid',
    'name',
    'nullabilitySuffix',
    'runtimeType'
  },
  'DartdocOptionContext': {
    'allowTools',
    'ambiguousReexportScorerMinConfidence',
    'autoIncludeDependencies',
    'categories',
    'categoryOrder',
    'context',
    'dropTextFrom',
    'examplePathPrefix',
    'exclude',
    'excludeFooterVersion',
    'flutterRoot',
    'format',
    'hashCode',
    'hideSdkText',
    'include',
    'includeExternal',
    'includeSource',
    'injectHtml',
    'inputDir',
    'linkToRemote',
    'linkToUrl',
    'maxFileCount',
    'maxTotalSize',
    'nodoc',
    'optionSet',
    'output',
    'packageMeta',
    'packageOrder',
    'resourceProvider',
    'runtimeType',
    'sanitizeHtml',
    'sdkDir',
    'sdkDocs',
    'showStats',
    'showUndocumentedCategories',
    'tools',
    'topLevelPackageMeta',
    'useBaseHref',
    'useCategories',
    'validateLinks'
  },
  'DocumentLocation': {'hashCode', 'index', 'runtimeType'},
  'Documentation': {'asHtml', 'asOneLiner', 'hashCode', 'runtimeType'},
  'DocumentationComment': {
    'documentationAsHtml',
    'documentationComment',
    'documentationFrom',
    'documentationLocal',
    'element',
    'elementDocumentation',
    'fullyQualifiedNameWithoutLibrary',
    'hasDocumentationComment',
    'hasNodoc',
    'modelElementRenderer',
    'needsPrecache',
    'pathContext',
    'sourceFileName'
  },
  'Element': {
    'children',
    'context',
    'declaration',
    'displayName',
    'documentationComment',
    'enclosingElement',
    'enclosingElement3',
    'hasAlwaysThrows',
    'hasDeprecated',
    'hasDoNotStore',
    'hasFactory',
    'hasInternal',
    'hasIsTest',
    'hasIsTestGroup',
    'hasJS',
    'hasLiteral',
    'hasMustBeOverridden',
    'hasMustCallSuper',
    'hasNonVirtual',
    'hasOptionalTypeArgs',
    'hasOverride',
    'hasProtected',
    'hasReopen',
    'hasRequired',
    'hasSealed',
    'hasUseResult',
    'hasVisibleForOverriding',
    'hasVisibleForTemplate',
    'hasVisibleForTesting',
    'hashCode',
    'id',
    'isPrivate',
    'isPublic',
    'isSynthetic',
    'kind',
    'library',
    'location',
    'metadata',
    'name',
    'nameLength',
    'nameOffset',
    'nonSynthetic',
    'runtimeType',
    'session',
    'sinceSdkVersion',
    'source'
  },
  'ElementAnnotation': {
    'constantEvaluationErrors',
    'element',
    'hashCode',
    'isAlwaysThrows',
    'isDeprecated',
    'isDoNotStore',
    'isFactory',
    'isImmutable',
    'isInternal',
    'isIsTest',
    'isIsTestGroup',
    'isJS',
    'isLiteral',
    'isMustBeOverridden',
    'isMustCallSuper',
    'isNonVirtual',
    'isOptionalTypeArgs',
    'isOverride',
    'isProtected',
    'isProxy',
    'isReopen',
    'isRequired',
    'isSealed',
    'isTarget',
    'isUseResult',
    'isVisibleForOverriding',
    'isVisibleForTemplate',
    'isVisibleForTesting',
    'runtimeType'
  },
  'EnumElement': {'augmented', 'hashCode', 'runtimeType'},
  'ExecutableMember': {
    'children',
    'context',
    'declaration',
    'displayName',
    'documentationComment',
    'enclosingElement',
    'enclosingElement3',
    'hasAlwaysThrows',
    'hasDeprecated',
    'hasDoNotStore',
    'hasFactory',
    'hasImplicitReturnType',
    'hasInternal',
    'hasIsTest',
    'hasIsTestGroup',
    'hasJS',
    'hasLiteral',
    'hasMustBeOverridden',
    'hasMustCallSuper',
    'hasNonVirtual',
    'hasOptionalTypeArgs',
    'hasOverride',
    'hasProtected',
    'hasReopen',
    'hasRequired',
    'hasSealed',
    'hasUseResult',
    'hasVisibleForOverriding',
    'hasVisibleForTemplate',
    'hasVisibleForTesting',
    'hashCode',
    'id',
    'isAbstract',
    'isAsynchronous',
    'isExternal',
    'isGenerator',
    'isLegacy',
    'isOperator',
    'isPrivate',
    'isPublic',
    'isSimplyBounded',
    'isStatic',
    'isSynchronous',
    'isSynthetic',
    'kind',
    'library',
    'librarySource',
    'location',
    'metadata',
    'name',
    'nameLength',
    'nameOffset',
    'nonSynthetic',
    'parameters',
    'returnType',
    'runtimeType',
    'session',
    'sinceSdkVersion',
    'substitution',
    'type',
    'typeParameters'
  },
  'Expression': {
    'hashCode',
    'inConstantContext',
    'isAssignable',
    'precedence',
    'runtimeType',
    'staticParameterElement',
    'staticType',
    'unParenthesized'
  },
  'ExtensionElement': {
    'accessors',
    'enclosingElement',
    'enclosingElement3',
    'extendedType',
    'fields',
    'hashCode',
    'methods',
    'runtimeType'
  },
  'Feature': {
    'cssClassName',
    'featurePrefix',
    'hashCode',
    'linkedName',
    'linkedNameWithParameters',
    'name',
    'runtimeType',
    'sortGroup'
  },
  'FieldElement': {
    'augmentation',
    'declaration',
    'hashCode',
    'isAbstract',
    'isCovariant',
    'isEnumConstant',
    'isExternal',
    'isPromotable',
    'isStatic',
    'runtimeType'
  },
  'File': {
    'changes',
    'hashCode',
    'lengthSync',
    'modificationStamp',
    'runtimeType'
  },
  'FunctionElement': {
    'hashCode',
    'isDartCoreIdentical',
    'isEntryPoint',
    'runtimeType'
  },
  'FunctionType': {
    'element',
    'element2',
    'hashCode',
    'namedParameterTypes',
    'normalParameterNames',
    'normalParameterTypes',
    'optionalParameterNames',
    'optionalParameterTypes',
    'parameters',
    'returnType',
    'runtimeType',
    'typeFormals'
  },
  'FunctionTypedElement': {
    'hashCode',
    'parameters',
    'returnType',
    'runtimeType',
    'type'
  },
  'GetterSetterCombo': {
    'allAccessors',
    'annotations',
    'arrow',
    'characterLocation',
    'comboFeatures',
    'constantInitializer',
    'constantValue',
    'constantValueBase',
    'constantValueTruncated',
    'documentationComment',
    'documentationFrom',
    'enclosingElement',
    'getter',
    'getterSetterBothAvailable',
    'hasAccessorsWithDocs',
    'hasConstantValueForDisplay',
    'hasDocumentationComment',
    'hasExplicitGetter',
    'hasExplicitSetter',
    'hasGetter',
    'hasGetterOrSetter',
    'hasNoGetterSetter',
    'hasParameters',
    'hasPublicGetter',
    'hasPublicGetterNoSetter',
    'hasPublicSetter',
    'hasSetter',
    'isCallable',
    'isInherited',
    'isPublic',
    'linkedParamsNoMetadata',
    'modelType',
    'oneLineDoc',
    'parameters',
    'readOnly',
    'readWrite',
    'referenceChildren',
    'setter',
    'writeOnly'
  },
  'HashMap': {'hashCode', 'runtimeType'},
  'Inheritable': {
    'canonicalLibrary',
    'canonicalModelElement',
    'features',
    'inheritance',
    'isCovariant',
    'isInherited',
    'isOverride',
    'overriddenDepth',
    'overriddenElement'
  },
  'InheritanceManager3': {'hashCode', 'runtimeType'},
  'InterfaceElement': {
    'allSupertypes',
    'hashCode',
    'runtimeType',
    'supertype',
    'thisType',
    'unnamedConstructor'
  },
  'Iterable': {
    'first',
    'hashCode',
    'isEmpty',
    'isNotEmpty',
    'iterator',
    'last',
    'length',
    'runtimeType',
    'single'
  },
  'LibraryElement': {
    'entryPoint',
    'exportNamespace',
    'exportedLibraries',
    'hashCode',
    'identifier',
    'importedLibraries',
    'isBrowserApplication',
    'isDartAsync',
    'isDartCore',
    'isInSdk',
    'loadLibraryFunction',
    'name',
    'parts',
    'parts2',
    'publicNamespace',
    'runtimeType',
    'topLevelElements',
    'units'
  },
  'List': {'hashCode', 'length', 'reversed', 'runtimeType'},
  'Locatable': {
    'documentationFrom',
    'documentationIsLocal',
    'fullyQualifiedName',
    'hashCode',
    'href',
    'location',
    'runtimeType'
  },
  'Map': {
    'entries',
    'hashCode',
    'isEmpty',
    'isNotEmpty',
    'keys',
    'length',
    'runtimeType',
    'values'
  },
  'Member': {
    'children',
    'context',
    'declaration',
    'displayName',
    'documentationComment',
    'enclosingElement',
    'enclosingElement3',
    'hasAlwaysThrows',
    'hasDeprecated',
    'hasDoNotStore',
    'hasFactory',
    'hasInternal',
    'hasIsTest',
    'hasIsTestGroup',
    'hasJS',
    'hasLiteral',
    'hasMustBeOverridden',
    'hasMustCallSuper',
    'hasNonVirtual',
    'hasOptionalTypeArgs',
    'hasOverride',
    'hasProtected',
    'hasReopen',
    'hasRequired',
    'hasSealed',
    'hasUseResult',
    'hasVisibleForOverriding',
    'hasVisibleForTemplate',
    'hasVisibleForTesting',
    'hashCode',
    'id',
    'isLegacy',
    'isPrivate',
    'isPublic',
    'isSynthetic',
    'kind',
    'library',
    'librarySource',
    'location',
    'metadata',
    'name',
    'nameLength',
    'nameOffset',
    'nonSynthetic',
    'runtimeType',
    'session',
    'sinceSdkVersion',
    'substitution'
  },
  'MethodElement': {'augmentation', 'declaration', 'hashCode', 'runtimeType'},
  'MixinElement': {
    'augmented',
    'hashCode',
    'isBase',
    'isExhaustive',
    'isFinal',
    'isInterface',
    'isSealed',
    'runtimeType',
    'superclassConstraints'
  },
  'ModelElementRenderer': {'hashCode', 'runtimeType'},
  'ModelNode': {
    'commentRefs',
    'element',
    'hashCode',
    'resourceProvider',
    'runtimeType',
    'sourceCode'
  },
  'ModelObjectBuilder': {'hashCode', 'runtimeType'},
  'PackageGraph': {
    'allCanonicalModelElements',
    'allConstructedModelElements',
    'allExtensionsAdded',
    'allHrefs',
    'allImplementorsAdded',
    'allInheritableElements',
    'allLibraries',
    'allLibrariesAdded',
    'allLocalModelElements',
    'config',
    'dartCoreObject',
    'defaultPackage',
    'defaultPackageName',
    'documentedExtensions',
    'documentedPackages',
    'extensions',
    'hasEmbedderSdk',
    'hasFooterVersion',
    'hashCode',
    'implementors',
    'inheritThrough',
    'invisibleAnnotations',
    'libraries',
    'libraryCount',
    'libraryElementReexportedBy',
    'localPackages',
    'localPublicLibraries',
    'name',
    'packageGraph',
    'packageMap',
    'packageMeta',
    'packageMetaProvider',
    'packageWarningCounter',
    'packages',
    'publicLibraries',
    'publicPackages',
    'referenceChildren',
    'referenceParents',
    'rendererFactory',
    'resourceProvider',
    'runtimeType',
    'sdk',
    'sdkLibrarySources',
    'specialClasses'
  },
  'PackageMeta': {
    'description',
    'dir',
    'hashCode',
    'homepage',
    'hostedAt',
    'isSdk',
    'isValid',
    'name',
    'pathContext',
    'repository',
    'requiresFlutter',
    'resolvedDir',
    'resourceProvider',
    'runtimeType',
    'version'
  },
  'ParameterElement': {
    'declaration',
    'defaultValueCode',
    'hasDefaultValue',
    'hashCode',
    'isCovariant',
    'isInitializingFormal',
    'isNamed',
    'isOptional',
    'isOptionalNamed',
    'isOptionalPositional',
    'isPositional',
    'isRequired',
    'isRequiredNamed',
    'isRequiredPositional',
    'isSuperFormal',
    'name',
    'parameterKind',
    'parameters',
    'runtimeType',
    'typeParameters'
  },
  'ParameterMember': {
    'children',
    'context',
    'declaration',
    'defaultValueCode',
    'displayName',
    'documentationComment',
    'enclosingElement',
    'enclosingElement3',
    'hasAlwaysThrows',
    'hasDefaultValue',
    'hasDeprecated',
    'hasDoNotStore',
    'hasFactory',
    'hasImplicitType',
    'hasInternal',
    'hasIsTest',
    'hasIsTestGroup',
    'hasJS',
    'hasLiteral',
    'hasMustBeOverridden',
    'hasMustCallSuper',
    'hasNonVirtual',
    'hasOptionalTypeArgs',
    'hasOverride',
    'hasProtected',
    'hasReopen',
    'hasRequired',
    'hasSealed',
    'hasUseResult',
    'hasVisibleForOverriding',
    'hasVisibleForTemplate',
    'hasVisibleForTesting',
    'hashCode',
    'id',
    'isConst',
    'isConstantEvaluated',
    'isCovariant',
    'isFinal',
    'isInitializingFormal',
    'isLate',
    'isLegacy',
    'isPrivate',
    'isPublic',
    'isStatic',
    'isSuperFormal',
    'isSynthetic',
    'kind',
    'library',
    'librarySource',
    'location',
    'metadata',
    'name',
    'nameLength',
    'nameOffset',
    'nonSynthetic',
    'parameterKind',
    'parameters',
    'runtimeType',
    'session',
    'sinceSdkVersion',
    'source',
    'substitution',
    'type',
    'typeParameters'
  },
  'ParameterizedType': {'hashCode', 'runtimeType', 'typeArguments'},
  'PropertyAccessorElement': {
    'augmentation',
    'correspondingGetter',
    'correspondingSetter',
    'declaration',
    'enclosingElement',
    'enclosingElement3',
    'hashCode',
    'isGetter',
    'isSetter',
    'runtimeType',
    'variable'
  },
  'Scope': {'hashCode', 'runtimeType'},
  'SdkLibrary': {
    'category',
    'hashCode',
    'isDart2JsLibrary',
    'isDocumented',
    'isImplementation',
    'isInternal',
    'isShared',
    'isVmLibrary',
    'path',
    'runtimeType',
    'shortName'
  },
  'Set': {
    'first',
    'hashCode',
    'isEmpty',
    'isNotEmpty',
    'iterator',
    'last',
    'length',
    'runtimeType',
    'single'
  },
  'TemplateOptions': {
    'customFooterContent',
    'customHeaderContent',
    'customInnerFooterText',
    'hashCode',
    'relCanonicalPrefix',
    'runtimeType',
    'toolVersion',
    'useBaseHref'
  },
  'TopLevelVariableElement': {
    'declaration',
    'hashCode',
    'isExternal',
    'runtimeType'
  },
  'TypeAliasElement': {
    'aliasedElement',
    'aliasedType',
    'enclosingElement',
    'enclosingElement3',
    'hashCode',
    'name',
    'runtimeType'
  },
  'TypeDefiningElement': {'hashCode', 'runtimeType'},
  'TypeParameterElement': {
    'bound',
    'declaration',
    'displayName',
    'hashCode',
    'name',
    'runtimeType'
  },
  'TypeSystem': {'hashCode', 'runtimeType'},
  'int': {
    'bitLength',
    'hashCode',
    'isEven',
    'isFinite',
    'isInfinite',
    'isNaN',
    'isNegative',
    'isOdd',
    'runtimeType',
    'sign'
  },
};
