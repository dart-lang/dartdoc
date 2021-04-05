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
import 'templates.dart';

String renderAnnotation(Annotation context, Template template) {
  return _render_Annotation(context, template.ast, template);
}

String _render_Annotation(
    Annotation context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Annotation(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Annotation extends RendererBase<Annotation> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Annotation>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Feature.propertyMap<CT_>(),
                'annotation': Property(
                  getValue: (CT_ c) => c.annotation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ElementAnnotation'),
                  isNullValue: (CT_ c) => c.annotation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.annotation, ast, r.template,
                        parent: r);
                  },
                ),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedNameWithParameters == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.linkedNameWithParameters, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.modelType, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.parameterText == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.parameterText, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Annotation(
      Annotation context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Annotation> getProperty(String key) {
    if (propertyMap<Annotation>().containsKey(key)) {
      return propertyMap<Annotation>()[key];
    } else {
      return null;
    }
  }
}

String _render_Object(
    Object context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Object(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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

  _Renderer_Object(
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

String _render_Library(
    Library context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Library(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                'allCanonicalModelElements': Property(
                  getValue: (CT_ c) => c.allCanonicalModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allCanonicalModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
                  },
                ),
                'allClasses': Property(
                  getValue: (CT_ c) => c.allClasses,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allClasses.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
                  },
                ),
                'allOriginalModelElementNames': Property(
                  getValue: (CT_ c) => c.allOriginalModelElementNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allOriginalModelElementNames.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
                'canonicalFor': Property(
                  getValue: (CT_ c) => c.canonicalFor,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.canonicalFor.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.characterLocation, ast, r.template,
                        parent: r);
                  },
                ),
                'classes': Property(
                  getValue: (CT_ c) => c.classes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.classes.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'compilationUnitElement': Property(
                  getValue: (CT_ c) => c.compilationUnitElement,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CompilationUnitElement'),
                  isNullValue: (CT_ c) => c.compilationUnitElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(
                        c.compilationUnitElement, ast, r.template,
                        parent: r);
                  },
                ),
                'constants': Property(
                  getValue: (CT_ c) => c.constants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.constants.map((e) => _render_TopLevelVariable(
                        e, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.dirName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.dirName, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'LibraryElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
                        parent: r);
                  },
                ),
                'enums': Property(
                  getValue: (CT_ c) => c.enums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Enum>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.enums.map(
                        (e) => _render_Enum(e, ast, r.template, parent: r));
                  },
                ),
                'exceptions': Property(
                  getValue: (CT_ c) => c.exceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.exceptions.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'extensions': Property(
                  getValue: (CT_ c) => c.extensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.extensions.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
                        parent: r);
                  },
                ),
                'functions': Property(
                  getValue: (CT_ c) => c.functions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelFunction>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.functions.map((e) =>
                        _render_ModelFunction(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
                  },
                ),
                'importedExportedLibraries': Property(
                  getValue: (CT_ c) => c.importedExportedLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.importedExportedLibraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
                  },
                ),
                'inheritanceManager': Property(
                  getValue: (CT_ c) => c.inheritanceManager,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'InheritanceManager3'),
                  isNullValue: (CT_ c) => c.inheritanceManager == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.inheritanceManager, ast, r.template,
                        parent: r);
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
                'isNullSafety': Property(
                  getValue: (CT_ c) => c.isNullSafety,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isNullSafety == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
                        parent: r);
                  },
                ),
                'mixins': Property(
                  getValue: (CT_ c) => c.mixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Mixin>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.mixins.map(
                        (e) => _render_Mixin(e, ast, r.template, parent: r));
                  },
                ),
                'modelElementsMap': Property(
                  getValue: (CT_ c) => c.modelElementsMap,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames,
                          'HashMap<Element, Set<ModelElement>>'),
                  isNullValue: (CT_ c) => c.modelElementsMap == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.modelElementsMap, ast, r.template,
                        parent: r);
                  },
                ),
                'modelElementsNameMap': Property(
                  getValue: (CT_ c) => c.modelElementsNameMap,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames,
                          'HashMap<String, Set<ModelElement>>'),
                  isNullValue: (CT_ c) => c.modelElementsNameMap == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.modelElementsNameMap, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameFromPath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nameFromPath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.package == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.package, ast, r.template,
                        parent: r);
                  },
                ),
                'packageImportedExportedLibraries': Property(
                  getValue: (CT_ c) => c.packageImportedExportedLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.packageImportedExportedLibraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
                  },
                ),
                'packageMeta': Property(
                  getValue: (CT_ c) => c.packageMeta,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageMeta'),
                  isNullValue: (CT_ c) => c.packageMeta == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageMeta, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.packageName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.packageName, ast, r.template,
                        parent: r);
                  },
                ),
                'prefixToLibrary': Property(
                  getValue: (CT_ c) => c.prefixToLibrary,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, Set<Library>>'),
                  isNullValue: (CT_ c) => c.prefixToLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.prefixToLibrary, ast, r.template,
                        parent: r);
                  },
                ),
                'properties': Property(
                  getValue: (CT_ c) => c.properties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.properties.map((e) => _render_TopLevelVariable(
                        e, ast, r.template,
                        parent: r));
                  },
                ),
                'sdkLib': Property(
                  getValue: (CT_ c) => c.sdkLib,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'SdkLibrary'),
                  isNullValue: (CT_ c) => c.sdkLib == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.sdkLib, ast, r.template, parent: r);
                  },
                ),
                'typeSystem': Property(
                  getValue: (CT_ c) => c.typeSystem,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeSystem'),
                  isNullValue: (CT_ c) => c.typeSystem == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.typeSystem, ast, r.template,
                        parent: r);
                  },
                ),
                'typedefs': Property(
                  getValue: (CT_ c) => c.typedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Typedef>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typedefs.map(
                        (e) => _render_Typedef(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Library(
      Library context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Library> getProperty(String key) {
    if (propertyMap<Library>().containsKey(key)) {
      return propertyMap<Library>()[key];
    } else {
      return null;
    }
  }
}

String _render_Package(
    Package context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Package(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                'allLibraries': Property(
                  getValue: (CT_ c) => c.allLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allLibraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.baseHref == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.baseHref, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.canonicalLibrary, ast, r.template,
                        parent: r);
                  },
                ),
                'categories': Property(
                  getValue: (CT_ c) => c.categories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Category>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.categories.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
                  },
                ),
                'categoriesWithPublicLibraries': Property(
                  getValue: (CT_ c) => c.categoriesWithPublicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.categoriesWithPublicLibraries.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
                  },
                ),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => c.config == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.config, ast, r.template, parent: r);
                  },
                ),
                'containerOrder': Property(
                  getValue: (CT_ c) => c.containerOrder,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.containerOrder.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
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
                        _Renderer_LibraryContainer.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.defaultCategory == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_LibraryContainer(
                        c.defaultCategory, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentation, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentationAsHtml == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.documentationAsHtml, ast, r.template,
                        parent: r);
                  },
                ),
                'documentationFile': Property(
                  getValue: (CT_ c) => c.documentationFile,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'File'),
                  isNullValue: (CT_ c) => c.documentationFile == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.documentationFile, ast, r.template,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Locatable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentationFrom.map((e) =>
                        _render_Locatable(e, ast, r.template, parent: r));
                  },
                ),
                'documentedCategories': Property(
                  getValue: (CT_ c) => c.documentedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentedCategories.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
                  },
                ),
                'documentedCategoriesSorted': Property(
                  getValue: (CT_ c) => c.documentedCategoriesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentedCategoriesSorted.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
                  },
                ),
                'documentedWhere': Property(
                  getValue: (CT_ c) => c.documentedWhere,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DocumentLocation'),
                  isNullValue: (CT_ c) => c.documentedWhere == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.documentedWhere, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                        _Renderer_Warnable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Warnable(c.enclosingElement, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.enclosingName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
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
                'hasDocumentationFile': Property(
                  getValue: (CT_ c) => c.hasDocumentationFile,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentationFile == true,
                ),
                'hasDocumentedCategories': Property(
                  getValue: (CT_ c) => c.hasDocumentedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDocumentedCategories == true,
                ),
                'hasExtendedDocumentation': Property(
                  getValue: (CT_ c) => c.hasExtendedDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasExtendedDocumentation == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.homepage == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.homepage, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.location == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.location, ast, r.template,
                        parent: r);
                  },
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.locationPieces.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
                'nameToCategory': Property(
                  getValue: (CT_ c) => c.nameToCategory,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, Category>'),
                  isNullValue: (CT_ c) => c.nameToCategory == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.nameToCategory, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.oneLineDoc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.oneLineDoc, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.package == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.package, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageMeta, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.packagePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.packagePath, ast, r.template,
                        parent: r);
                  },
                ),
                'publicLibraries': Property(
                  getValue: (CT_ c) => c.publicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicLibraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
                  },
                ),
                'toolInvocationIndex': Property(
                  getValue: (CT_ c) => c.toolInvocationIndex,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => c.toolInvocationIndex == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.toolInvocationIndex, ast, r.template,
                        parent: r);
                  },
                ),
                'usedAnimationIdsByHref': Property(
                  getValue: (CT_ c) => c.usedAnimationIdsByHref,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, Set<String>>'),
                  isNullValue: (CT_ c) => c.usedAnimationIdsByHref == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(
                        c.usedAnimationIdsByHref, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.version == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.version, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Package(
      Package context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Package> getProperty(String key) {
    if (propertyMap<Package>().containsKey(key)) {
      return propertyMap<Package>()[key];
    } else {
      return null;
    }
  }
}

String _render_String(
    String context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_String(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.codeUnits.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
                  },
                ),
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
                  isNullValue: (CT_ c) => c.length == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.length, ast, r.template, parent: r);
                  },
                ),
                'runes': Property(
                  getValue: (CT_ c) => c.runes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Runes'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.runes.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_String(
      String context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<String> getProperty(String key) {
    if (propertyMap<String>().containsKey(key)) {
      return propertyMap<String>()[key];
    } else {
      return null;
    }
  }
}

String _render_Locatable(
    Locatable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Locatable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentationFrom.map((e) =>
                        _render_Locatable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.location == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.location, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Locatable(
      Locatable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Locatable> getProperty(String key) {
    if (propertyMap<Locatable>().containsKey(key)) {
      return propertyMap<Locatable>()[key];
    } else {
      return null;
    }
  }
}

String _render_LibraryContainer(
    LibraryContainer context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_LibraryContainer(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.containerOrder.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.enclosingName, ast, r.template,
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.libraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
                  },
                ),
                'publicLibraries': Property(
                  getValue: (CT_ c) => c.publicLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicLibraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
                  },
                ),
                'publicLibrariesSorted': Property(
                  getValue: (CT_ c) => c.publicLibrariesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicLibrariesSorted.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sortKey == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sortKey, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_LibraryContainer(
      LibraryContainer context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<LibraryContainer> getProperty(String key) {
    if (propertyMap<LibraryContainer>().containsKey(key)) {
      return propertyMap<LibraryContainer>()[key];
    } else {
      return null;
    }
  }
}

String _render_Warnable(
    Warnable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Warnable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                        _Renderer_Warnable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Warnable(c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.package == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.package, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Warnable(
      Warnable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Warnable> getProperty(String key) {
    if (propertyMap<Warnable>().containsKey(key)) {
      return propertyMap<Warnable>()[key];
    } else {
      return null;
    }
  }
}

String _render_Category(
    Category context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Category(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Category extends RendererBase<Category> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Category>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Nameable.propertyMap<CT_>(),
                ..._Renderer_Warnable.propertyMap<CT_>(),
                ..._Renderer_Locatable.propertyMap<CT_>(),
                ..._Renderer_Canonicalization.propertyMap<CT_>(),
                ..._Renderer_MarkdownFileDocumentation.propertyMap<CT_>(),
                ..._Renderer_LibraryContainer.propertyMap<CT_>(),
                ..._Renderer_TopLevelContainer.propertyMap<CT_>(),
                ..._Renderer_Indexable.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.canonicalLibrary, ast, r.template,
                        parent: r);
                  },
                ),
                'categoryDefinition': Property(
                  getValue: (CT_ c) => c.categoryDefinition,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CategoryDefinition'),
                  isNullValue: (CT_ c) => c.categoryDefinition == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.categoryDefinition, ast, r.template,
                        parent: r);
                  },
                ),
                'categoryIndex': Property(
                  getValue: (CT_ c) => c.categoryIndex,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => c.categoryIndex == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.categoryIndex, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.categoryLabel == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.categoryLabel, ast, r.template,
                        parent: r);
                  },
                ),
                'classes': Property(
                  getValue: (CT_ c) => c.classes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.classes.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => c.config == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.config, ast, r.template, parent: r);
                  },
                ),
                'constants': Property(
                  getValue: (CT_ c) => c.constants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.constants.map((e) => _render_TopLevelVariable(
                        e, ast, r.template,
                        parent: r));
                  },
                ),
                'containerOrder': Property(
                  getValue: (CT_ c) => c.containerOrder,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.containerOrder.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
                'documentationFile': Property(
                  getValue: (CT_ c) => c.documentationFile,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'File'),
                  isNullValue: (CT_ c) => c.documentationFile == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.documentationFile, ast, r.template,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Locatable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentationFrom.map((e) =>
                        _render_Locatable(e, ast, r.template, parent: r));
                  },
                ),
                'documentedWhere': Property(
                  getValue: (CT_ c) => c.documentedWhere,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DocumentLocation'),
                  isNullValue: (CT_ c) => c.documentedWhere == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.documentedWhere, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                        _Renderer_Warnable.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Warnable(c.enclosingElement, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.enclosingName, ast, r.template,
                        parent: r);
                  },
                ),
                'enums': Property(
                  getValue: (CT_ c) => c.enums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.enums.map(
                        (e) => _render_Enum(e, ast, r.template, parent: r));
                  },
                ),
                'exceptions': Property(
                  getValue: (CT_ c) => c.exceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.exceptions.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'extensions': Property(
                  getValue: (CT_ c) => c.extensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.extensions.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
                        parent: r);
                  },
                ),
                'functions': Property(
                  getValue: (CT_ c) => c.functions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunction>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.functions.map((e) =>
                        _render_ModelFunction(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
                        parent: r);
                  },
                ),
                'mixins': Property(
                  getValue: (CT_ c) => c.mixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Mixin>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.mixins.map(
                        (e) => _render_Mixin(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.package == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.package, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
                  },
                ),
                'properties': Property(
                  getValue: (CT_ c) => c.properties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.properties.map((e) => _render_TopLevelVariable(
                        e, ast, r.template,
                        parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sortKey == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sortKey, ast, r.template,
                        parent: r);
                  },
                ),
                'typedefs': Property(
                  getValue: (CT_ c) => c.typedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typedefs.map(
                        (e) => _render_Typedef(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Category(
      Category context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Category> getProperty(String key) {
    if (propertyMap<Category>().containsKey(key)) {
      return propertyMap<Category>()[key];
    } else {
      return null;
    }
  }
}

String _render_Class(Class context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Class(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Class extends RendererBase<Class> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Class>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Container.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                ..._Renderer_ExtensionTarget.propertyMap<CT_>(),
                'allCanonicalModelElements': Property(
                  getValue: (CT_ c) => c.allCanonicalModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allCanonicalModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
                  },
                ),
                'allFields': Property(
                  getValue: (CT_ c) => c.allFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
                  },
                ),
                'constantFields': Property(
                  getValue: (CT_ c) => c.constantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.constantFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'constructors': Property(
                  getValue: (CT_ c) => c.constructors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Constructor>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.constructors.map((e) =>
                        _render_Constructor(e, ast, r.template, parent: r));
                  },
                ),
                'declaredFields': Property(
                  getValue: (CT_ c) => c.declaredFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'declaredMethods': Property(
                  getValue: (CT_ c) => c.declaredMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'defaultConstructor': Property(
                  getValue: (CT_ c) => c.defaultConstructor,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Constructor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.defaultConstructor == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Constructor(
                        c.defaultConstructor, ast, r.template,
                        parent: r);
                  },
                ),
                'definingClass': Property(
                  getValue: (CT_ c) => c.definingClass,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Class.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.definingClass == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Class(c.definingClass, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ClassElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullkind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullkind, ast, r.template,
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
                'hasPublicConstructors': Property(
                  getValue: (CT_ c) => c.hasPublicConstructors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicConstructors == true,
                ),
                'hasPublicImplementors': Property(
                  getValue: (CT_ c) => c.hasPublicImplementors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicImplementors == true,
                ),
                'hasPublicInheritedMethods': Property(
                  getValue: (CT_ c) => c.hasPublicInheritedMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInheritedMethods == true,
                ),
                'hasPublicInterfaces': Property(
                  getValue: (CT_ c) => c.hasPublicInterfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicInterfaces == true,
                ),
                'hasPublicMixedInTypes': Property(
                  getValue: (CT_ c) => c.hasPublicMixedInTypes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicMixedInTypes == true,
                ),
                'hasPublicSuperChainReversed': Property(
                  getValue: (CT_ c) => c.hasPublicSuperChainReversed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicSuperChainReversed == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
                  },
                ),
                'inheritanceChain': Property(
                  getValue: (CT_ c) => c.inheritanceChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.inheritanceChain.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'inheritedFields': Property(
                  getValue: (CT_ c) => c.inheritedFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.inheritedFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'inheritedMethods': Property(
                  getValue: (CT_ c) => c.inheritedMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.inheritedMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'inheritedOperators': Property(
                  getValue: (CT_ c) => c.inheritedOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.inheritedOperators.map(
                        (e) => _render_Operator(e, ast, r.template, parent: r));
                  },
                ),
                'instanceFields': Property(
                  getValue: (CT_ c) => c.instanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'instanceMethods': Property(
                  getValue: (CT_ c) => c.instanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'instanceOperators': Property(
                  getValue: (CT_ c) => c.instanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceOperators.map(
                        (e) => _render_Operator(e, ast, r.template, parent: r));
                  },
                ),
                'interfaces': Property(
                  getValue: (CT_ c) => c.interfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.interfaces.map((e) => _render_DefinedElementType(
                        e, ast, r.template,
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
                'isCanonical': Property(
                  getValue: (CT_ c) => c.isCanonical,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isCanonical == true,
                ),
                'isErrorOrException': Property(
                  getValue: (CT_ c) => c.isErrorOrException,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isErrorOrException == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
                  },
                ),
                'mixedInTypes': Property(
                  getValue: (CT_ c) => c.mixedInTypes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.mixedInTypes.map((e) => _render_DefinedElementType(
                        e, ast, r.template,
                        parent: r));
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
                        _Renderer_DefinedElementType.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_DefinedElementType(
                        c.modelType, ast, r.template,
                        parent: r);
                  },
                ),
                'publicConstructorsSorted': Property(
                  getValue: (CT_ c) => c.publicConstructorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Constructor>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstructorsSorted.map((e) =>
                        _render_Constructor(e, ast, r.template, parent: r));
                  },
                ),
                'publicImplementors': Property(
                  getValue: (CT_ c) => c.publicImplementors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicImplementors.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'publicImplementorsSorted': Property(
                  getValue: (CT_ c) => c.publicImplementorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicImplementorsSorted.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'publicInheritedFields': Property(
                  getValue: (CT_ c) => c.publicInheritedFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInheritedFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInheritedMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'publicInterfaces': Property(
                  getValue: (CT_ c) => c.publicInterfaces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInterfaces.map((e) =>
                        _render_DefinedElementType(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicMixedInTypes': Property(
                  getValue: (CT_ c) => c.publicMixedInTypes,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicMixedInTypes.map((e) =>
                        _render_DefinedElementType(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicSuperChain': Property(
                  getValue: (CT_ c) => c.publicSuperChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicSuperChain.map((e) =>
                        _render_DefinedElementType(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicSuperChainReversed': Property(
                  getValue: (CT_ c) => c.publicSuperChainReversed,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicSuperChainReversed.map((e) =>
                        _render_DefinedElementType(e, ast, r.template,
                            parent: r));
                  },
                ),
                'superChain': Property(
                  getValue: (CT_ c) => c.superChain,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<DefinedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.superChain.map((e) => _render_DefinedElementType(
                        e, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.supertype == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_DefinedElementType(
                        c.supertype, ast, r.template,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
                'unnamedConstructor': Property(
                  getValue: (CT_ c) => c.unnamedConstructor,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Constructor.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.unnamedConstructor == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Constructor(
                        c.unnamedConstructor, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Class(Class context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Class> getProperty(String key) {
    if (propertyMap<Class>().containsKey(key)) {
      return propertyMap<Class>()[key];
    } else {
      return null;
    }
  }
}

String _render_DefinedElementType(
    DefinedElementType context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_DefinedElementType(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(c.element, ast, r.template,
                        parent: r);
                  },
                ),
                'instantiatedType': Property(
                  getValue: (CT_ c) => c.instantiatedType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'DartType'),
                  isNullValue: (CT_ c) => c.instantiatedType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.instantiatedType, ast, r.template,
                        parent: r);
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
                'isTypedef': Property(
                  getValue: (CT_ c) => c.isTypedef,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isTypedef == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, parent: r));
                  },
                ),
                'returnElement': Property(
                  getValue: (CT_ c) => c.returnElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.returnElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.returnElement, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.returnType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.returnType, ast, r.template,
                        parent: r);
                  },
                ),
                'typeArguments': Property(
                  getValue: (CT_ c) => c.typeArguments,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeArguments.map((e) =>
                        _render_ElementType(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_DefinedElementType(DefinedElementType context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<DefinedElementType> getProperty(String key) {
    if (propertyMap<DefinedElementType>().containsKey(key)) {
      return propertyMap<DefinedElementType>()[key];
    } else {
      return null;
    }
  }
}

String _render_ModelElement(
    ModelElement context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ModelElement(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_ModelElement extends RendererBase<ModelElement> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends ModelElement>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Canonicalization.propertyMap<CT_>(),
                ..._Renderer_Privacy.propertyMap<CT_>(),
                ..._Renderer_Warnable.propertyMap<CT_>(),
                ..._Renderer_Locatable.propertyMap<CT_>(),
                ..._Renderer_Nameable.propertyMap<CT_>(),
                ..._Renderer_SourceCodeMixin.propertyMap<CT_>(),
                ..._Renderer_Indexable.propertyMap<CT_>(),
                ..._Renderer_FeatureSet.propertyMap<CT_>(),
                ..._Renderer_DocumentationComment.propertyMap<CT_>(),
                'allParameters': Property(
                  getValue: (CT_ c) => c.allParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allParameters.map((e) =>
                        _render_Parameter(e, ast, r.template, parent: r));
                  },
                ),
                'annotations': Property(
                  getValue: (CT_ c) => c.annotations,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Annotation>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.annotations.map((e) =>
                        _render_Annotation(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.canonicalLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalModelElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.canonicalModelElement, ast, r.template,
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.characterLocation, ast, r.template,
                        parent: r);
                  },
                ),
                'commentRefs': Property(
                  getValue: (CT_ c) => c.commentRefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelCommentReference>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.commentRefs.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
                  },
                ),
                'compilationUnitElement': Property(
                  getValue: (CT_ c) => c.compilationUnitElement,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CompilationUnitElement'),
                  isNullValue: (CT_ c) => c.compilationUnitElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(
                        c.compilationUnitElement, ast, r.template,
                        parent: r);
                  },
                ),
                'computeDocumentationFrom': Property(
                  getValue: (CT_ c) => c.computeDocumentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.computeDocumentationFrom.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
                  },
                ),
                'config': Property(
                  getValue: (CT_ c) => c.config,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DartdocOptionContext'),
                  isNullValue: (CT_ c) => c.config == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.config, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.definingLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.definingLibrary, ast, r.template,
                        parent: r);
                  },
                ),
                'displayedCategories': Property(
                  getValue: (CT_ c) => c.displayedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.displayedCategories.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentation, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentationAsHtml == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.documentationAsHtml, ast, r.template,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentationFrom.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentationLocal == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentationLocal, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
                  },
                ),
                'exportedInLibraries': Property(
                  getValue: (CT_ c) => c.exportedInLibraries,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Library>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.exportedInLibraries.map(
                        (e) => _render_Library(e, ast, r.template, parent: r));
                  },
                ),
                'extendedDocLink': Property(
                  getValue: (CT_ c) => c.extendedDocLink,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.extendedDocLink == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.extendedDocLink, ast, r.template,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.features.map(
                        (e) => _render_Feature(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featuresAsString == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.featuresAsString, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) =>
                      c.fullyQualifiedNameWithoutLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.fullyQualifiedNameWithoutLibrary, ast, r.template,
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
                'hasExtendedDocumentation': Property(
                  getValue: (CT_ c) => c.hasExtendedDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasExtendedDocumentation == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlId == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlId, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedParams == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedParams, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedParamsLines == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedParamsLines, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedParamsNoMetadata == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.linkedParamsNoMetadata, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) =>
                      c.linkedParamsNoMetadataOrNames == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.linkedParamsNoMetadataOrNames, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.location == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.location, ast, r.template,
                        parent: r);
                  },
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.locationPieces.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
                'modelNode': Property(
                  getValue: (CT_ c) => c.modelNode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'ModelNode'),
                  isNullValue: (CT_ c) => c.modelNode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.modelNode, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.oneLineDoc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.oneLineDoc, ast, r.template,
                        parent: r);
                  },
                ),
                'originalMember': Property(
                  getValue: (CT_ c) => c.originalMember,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Member'),
                  isNullValue: (CT_ c) => c.originalMember == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.originalMember, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.package == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.package, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, parent: r));
                  },
                ),
                'pathContext': Property(
                  getValue: (CT_ c) => c.pathContext,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Context'),
                  isNullValue: (CT_ c) => c.pathContext == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.pathContext, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceCode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceCode, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceFileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceFileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceHref == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceHref, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_ModelElement(
      ModelElement context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ModelElement> getProperty(String key) {
    if (propertyMap<ModelElement>().containsKey(key)) {
      return propertyMap<ModelElement>()[key];
    } else {
      return null;
    }
  }
}

String _render_Feature(
    Feature context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Feature(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Feature extends RendererBase<Feature> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Feature>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featurePrefix == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.featurePrefix, ast, r.template,
                        parent: r);
                  },
                ),
                'isPublic': Property(
                  getValue: (CT_ c) => c.isPublic,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isPublic == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedNameWithParameters == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.linkedNameWithParameters, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
                'sortGroup': Property(
                  getValue: (CT_ c) => c.sortGroup,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => c.sortGroup == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.sortGroup, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Feature(
      Feature context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Feature> getProperty(String key) {
    if (propertyMap<Feature>().containsKey(key)) {
      return propertyMap<Feature>()[key];
    } else {
      return null;
    }
  }
}

String _render_Parameter(
    Parameter context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Parameter(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Parameter extends RendererBase<Parameter> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Parameter>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.defaultValue == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.defaultValue, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ParameterElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                  isNullValue: (CT_ c) => c.hashCode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.hashCode, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlId == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlId, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.modelType, ast, r.template,
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.originalMember, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Parameter(
      Parameter context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Parameter> getProperty(String key) {
    if (propertyMap<Parameter>().containsKey(key)) {
      return propertyMap<Parameter>()[key];
    } else {
      return null;
    }
  }
}

String _render_ElementType(
    ElementType context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ElementType(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_ElementType extends RendererBase<ElementType> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends ElementType>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Privacy.propertyMap<CT_>(),
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
                  isNullValue: (CT_ c) => c.instantiatedType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.instantiatedType, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameWithGenerics == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nameWithGenerics, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nullabilitySuffix == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nullabilitySuffix, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, parent: r));
                  },
                ),
                'returnedFrom': Property(
                  getValue: (CT_ c) => c.returnedFrom,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ElementType.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.returnedFrom == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.returnedFrom, ast, r.template,
                        parent: r);
                  },
                ),
                'type': Property(
                  getValue: (CT_ c) => c.type,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'DartType'),
                  isNullValue: (CT_ c) => c.type == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.type, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_ElementType(
      ElementType context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ElementType> getProperty(String key) {
    if (propertyMap<ElementType>().containsKey(key)) {
      return propertyMap<ElementType>()[key];
    } else {
      return null;
    }
  }
}

String _render_Privacy(
    Privacy context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Privacy(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
              });

  _Renderer_Privacy(
      Privacy context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Privacy> getProperty(String key) {
    if (propertyMap<Privacy>().containsKey(key)) {
      return propertyMap<Privacy>()[key];
    } else {
      return null;
    }
  }
}

String _render_Nameable(
    Nameable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Nameable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.namePart == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.namePart, ast, r.template,
                        parent: r);
                  },
                ),
                'namePieces': Property(
                  getValue: (CT_ c) => c.namePieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.namePieces.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Nameable(
      Nameable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Nameable> getProperty(String key) {
    if (propertyMap<Nameable>().containsKey(key)) {
      return propertyMap<Nameable>()[key];
    } else {
      return null;
    }
  }
}

String _render_SourceCodeMixin(
    SourceCodeMixin context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_SourceCodeMixin(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.characterLocation, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Element'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
                        parent: r);
                  },
                ),
                'modelNode': Property(
                  getValue: (CT_ c) => c.modelNode,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'ModelNode'),
                  isNullValue: (CT_ c) => c.modelNode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.modelNode, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceCode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceCode, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_SourceCodeMixin(
      SourceCodeMixin context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<SourceCodeMixin> getProperty(String key) {
    if (propertyMap<SourceCodeMixin>().containsKey(key)) {
      return propertyMap<SourceCodeMixin>()[key];
    } else {
      return null;
    }
  }
}

String _render_Indexable(
    Indexable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Indexable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
                  },
                ),
                'overriddenDepth': Property(
                  getValue: (CT_ c) => c.overriddenDepth,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'int'),
                  isNullValue: (CT_ c) => c.overriddenDepth == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.overriddenDepth, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Indexable(
      Indexable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Indexable> getProperty(String key) {
    if (propertyMap<Indexable>().containsKey(key)) {
      return propertyMap<Indexable>()[key];
    } else {
      return null;
    }
  }
}

String _render_FeatureSet(
    FeatureSet context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_FeatureSet(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.displayedLanguageFeatures.map((e) =>
                        _render_LanguageFeature(e, ast, r.template, parent: r));
                  },
                ),
                'hasFeatureSet': Property(
                  getValue: (CT_ c) => c.hasFeatureSet,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasFeatureSet == true,
                ),
                'isNullSafety': Property(
                  getValue: (CT_ c) => c.isNullSafety,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isNullSafety == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_FeatureSet(
      FeatureSet context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<FeatureSet> getProperty(String key) {
    if (propertyMap<FeatureSet>().containsKey(key)) {
      return propertyMap<FeatureSet>()[key];
    } else {
      return null;
    }
  }
}

String _render_LanguageFeature(
    LanguageFeature context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_LanguageFeature(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featureDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.featureDescription, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featureLabel == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.featureLabel, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.featureUrl == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.featureUrl, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_LanguageFeature(
      LanguageFeature context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<LanguageFeature> getProperty(String key) {
    if (propertyMap<LanguageFeature>().containsKey(key)) {
      return propertyMap<LanguageFeature>()[key];
    } else {
      return null;
    }
  }
}

String _render_DocumentationComment(
    DocumentationComment context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_DocumentationComment(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_DocumentationComment
    extends RendererBase<DocumentationComment> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends DocumentationComment>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentationComment == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.documentationComment, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) =>
                      c.fullyQualifiedNameWithoutLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.fullyQualifiedNameWithoutLibrary, ast, r.template,
                        parent: r);
                  },
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
                  isNullValue: (CT_ c) => c.modelElementRenderer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.modelElementRenderer, ast, r.template,
                        parent: r);
                  },
                ),
                'pathContext': Property(
                  getValue: (CT_ c) => c.pathContext,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'Context'),
                  isNullValue: (CT_ c) => c.pathContext == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.pathContext, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceFileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceFileName, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_DocumentationComment(DocumentationComment context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<DocumentationComment> getProperty(String key) {
    if (propertyMap<DocumentationComment>().containsKey(key)) {
      return propertyMap<DocumentationComment>()[key];
    } else {
      return null;
    }
  }
}

String _render_Documentable(
    Documentable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Documentable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  isNullValue: (CT_ c) => c.config == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.config, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentation, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentationAsHtml == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.documentationAsHtml, ast, r.template,
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
                'hasExtendedDocumentation': Property(
                  getValue: (CT_ c) => c.hasExtendedDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasExtendedDocumentation == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.oneLineDoc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.oneLineDoc, ast, r.template,
                        parent: r);
                  },
                ),
                'packageGraph': Property(
                  getValue: (CT_ c) => c.packageGraph,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PackageGraph'),
                  isNullValue: (CT_ c) => c.packageGraph == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.packageGraph, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Documentable(
      Documentable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Documentable> getProperty(String key) {
    if (propertyMap<Documentable>().containsKey(key)) {
      return propertyMap<Documentable>()[key];
    } else {
      return null;
    }
  }
}

String _render_Canonicalization(
    Canonicalization context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Canonicalization(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.canonicalLibrary, ast, r.template,
                        parent: r);
                  },
                ),
                'commentRefs': Property(
                  getValue: (CT_ c) => c.commentRefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelCommentReference>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.commentRefs.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.locationPieces.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Canonicalization(
      Canonicalization context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Canonicalization> getProperty(String key) {
    if (propertyMap<Canonicalization>().containsKey(key)) {
      return propertyMap<Canonicalization>()[key];
    } else {
      return null;
    }
  }
}

String _render_Constructor(
    Constructor context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Constructor(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Constructor extends RendererBase<Constructor> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Constructor>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.characterLocation, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'ConstructorElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullKind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullKind, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                        _Renderer_CallableElementTypeMixin.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_CallableElementTypeMixin(
                        c.modelType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameWithGenerics == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nameWithGenerics, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.shortName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.shortName, ast, r.template,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Constructor(
      Constructor context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Constructor> getProperty(String key) {
    if (propertyMap<Constructor>().containsKey(key)) {
      return propertyMap<Constructor>()[key];
    } else {
      return null;
    }
  }
}

String _render_TypeParameter(
    TypeParameter context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TypeParameter(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TypeParameter extends RendererBase<TypeParameter> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends TypeParameter>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.boundType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.boundType, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeParameterElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_TypeParameter(
      TypeParameter context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TypeParameter> getProperty(String key) {
    if (propertyMap<TypeParameter>().containsKey(key)) {
      return propertyMap<TypeParameter>()[key];
    } else {
      return null;
    }
  }
}

String _render_CallableElementTypeMixin(CallableElementTypeMixin context,
    List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_CallableElementTypeMixin(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_CallableElementTypeMixin
    extends RendererBase<CallableElementTypeMixin> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends CallableElementTypeMixin>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Object.propertyMap<CT_>(),
                'returnElement': Property(
                  getValue: (CT_ c) => c.returnElement,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.returnElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.returnElement, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.returnType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.returnType, ast, r.template,
                        parent: r);
                  },
                ),
                'type': Property(
                  getValue: (CT_ c) => c.type,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FunctionType'),
                  isNullValue: (CT_ c) => c.type == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.type, ast, r.template, parent: r);
                  },
                ),
                'typeArguments': Property(
                  getValue: (CT_ c) => c.typeArguments,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeArguments.map((e) =>
                        _render_ElementType(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_CallableElementTypeMixin(CallableElementTypeMixin context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<CallableElementTypeMixin> getProperty(String key) {
    if (propertyMap<CallableElementTypeMixin>().containsKey(key)) {
      return propertyMap<CallableElementTypeMixin>()[key];
    } else {
      return null;
    }
  }
}

String _render_TypeParameters(
    TypeParameters context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TypeParameters(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.genericParameters == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.genericParameters, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedGenericParameters == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.linkedGenericParameters, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameWithGenerics == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nameWithGenerics, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameWithLinkedGenerics == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.nameWithLinkedGenerics, ast, r.template,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_TypeParameters(
      TypeParameters context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TypeParameters> getProperty(String key) {
    if (propertyMap<TypeParameters>().containsKey(key)) {
      return propertyMap<TypeParameters>()[key];
    } else {
      return null;
    }
  }
}

String _render_Method(
    Method context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Method(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.characterLocation, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'MethodElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.features.map(
                        (e) => _render_Feature(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullkind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullkind, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                        _Renderer_CallableElementTypeMixin.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_CallableElementTypeMixin(
                        c.modelType, ast, r.template,
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.originalMember, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Method(c.overriddenElement, ast, r.template,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Method(
      Method context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Method> getProperty(String key) {
    if (propertyMap<Method>().containsKey(key)) {
      return propertyMap<Method>()[key];
    } else {
      return null;
    }
  }
}

String _render_ContainerMember(
    ContainerMember context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ContainerMember(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalEnclosingContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(
                        c.canonicalEnclosingContainer, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.definingEnclosingContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(
                        c.definingEnclosingContainer, ast, r.template,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.features.map(
                        (e) => _render_Feature(e, ast, r.template, parent: r));
                  },
                ),
                'isExtended': Property(
                  getValue: (CT_ c) => c.isExtended,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isExtended == true,
                ),
              });

  _Renderer_ContainerMember(
      ContainerMember context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ContainerMember> getProperty(String key) {
    if (propertyMap<ContainerMember>().containsKey(key)) {
      return propertyMap<ContainerMember>()[key];
    } else {
      return null;
    }
  }
}

String _render_Container(
    Container context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Container(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Container extends RendererBase<Container> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Container>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
                ..._Renderer_TypeParameters.propertyMap<CT_>(),
                'allElements': Property(
                  getValue: (CT_ c) => c.allElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Element>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allElements.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
                  },
                ),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
                  },
                ),
                'allModelElementsByNamePart': Property(
                  getValue: (CT_ c) => c.allModelElementsByNamePart,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Map<String, List<ModelElement>>'),
                  isNullValue: (CT_ c) => c.allModelElementsByNamePart == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(
                        c.allModelElementsByNamePart, ast, r.template,
                        parent: r);
                  },
                ),
                'constantFields': Property(
                  getValue: (CT_ c) => c.constantFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.constantFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'declaredFields': Property(
                  getValue: (CT_ c) => c.declaredFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'declaredMethods': Property(
                  getValue: (CT_ c) => c.declaredMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'declaredOperators': Property(
                  getValue: (CT_ c) => c.declaredOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredOperators.map(
                        (e) => _render_Operator(e, ast, r.template, parent: r));
                  },
                ),
                'hasInstanceFields': Property(
                  getValue: (CT_ c) => c.hasInstanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasInstanceFields == true,
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceAccessors.map(
                        (e) => _render_Accessor(e, ast, r.template, parent: r));
                  },
                ),
                'instanceFields': Property(
                  getValue: (CT_ c) => c.instanceFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'instanceMethods': Property(
                  getValue: (CT_ c) => c.instanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'instanceOperators': Property(
                  getValue: (CT_ c) => c.instanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.instanceOperators.map(
                        (e) => _render_Operator(e, ast, r.template, parent: r));
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
                'isClassOrExtension': Property(
                  getValue: (CT_ c) => c.isClassOrExtension,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isClassOrExtension == true,
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstantFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicConstantFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicConstantFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstantFieldsSorted.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicConstructorsSorted': Property(
                  getValue: (CT_ c) => c.publicConstructorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Constructor>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstructorsSorted.map((e) =>
                        _render_Constructor(e, ast, r.template, parent: r));
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInstanceFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicInstanceFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicInstanceFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInstanceFieldsSorted.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicInstanceMethods': Property(
                  getValue: (CT_ c) => c.publicInstanceMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInstanceMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'publicInstanceMethodsSorted': Property(
                  getValue: (CT_ c) => c.publicInstanceMethodsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInstanceMethodsSorted.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'publicInstanceOperators': Property(
                  getValue: (CT_ c) => c.publicInstanceOperators,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Operator>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInstanceOperators.map(
                        (e) => _render_Operator(e, ast, r.template, parent: r));
                  },
                ),
                'publicInstanceOperatorsSorted': Property(
                  getValue: (CT_ c) => c.publicInstanceOperatorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Operator>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicInstanceOperatorsSorted.map(
                        (e) => _render_Operator(e, ast, r.template, parent: r));
                  },
                ),
                'publicStaticFields': Property(
                  getValue: (CT_ c) => c.publicStaticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicStaticFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicStaticFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicStaticFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicStaticFieldsSorted.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicStaticMethods': Property(
                  getValue: (CT_ c) => c.publicStaticMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicStaticMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'publicStaticMethodsSorted': Property(
                  getValue: (CT_ c) => c.publicStaticMethodsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicStaticMethodsSorted.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'publicVariableStaticFields': Property(
                  getValue: (CT_ c) => c.publicVariableStaticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicVariableStaticFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'publicVariableStaticFieldsSorted': Property(
                  getValue: (CT_ c) => c.publicVariableStaticFieldsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicVariableStaticFieldsSorted.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'staticAccessors': Property(
                  getValue: (CT_ c) => c.staticAccessors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Accessor>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.staticAccessors.map(
                        (e) => _render_Accessor(e, ast, r.template, parent: r));
                  },
                ),
                'staticFields': Property(
                  getValue: (CT_ c) => c.staticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.staticFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'staticMethods': Property(
                  getValue: (CT_ c) => c.staticMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.staticMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
                  },
                ),
                'variableStaticFields': Property(
                  getValue: (CT_ c) => c.variableStaticFields,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Field>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.variableStaticFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Container(
      Container context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Container> getProperty(String key) {
    if (propertyMap<Container>().containsKey(key)) {
      return propertyMap<Container>()[key];
    } else {
      return null;
    }
  }
}

String _render_Operator(
    Operator context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Operator(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullyQualifiedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullyQualifiedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_Operator(
      Operator context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Operator> getProperty(String key) {
    if (propertyMap<Operator>().containsKey(key)) {
      return propertyMap<Operator>()[key];
    } else {
      return null;
    }
  }
}

String _render_Inheritable(
    Inheritable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Inheritable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.canonicalLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.canonicalLibrary, ast, r.template,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.features.map(
                        (e) => _render_Feature(e, ast, r.template, parent: r));
                  },
                ),
                'inheritance': Property(
                  getValue: (CT_ c) => c.inheritance,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.inheritance.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
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
                  isNullValue: (CT_ c) => c.overriddenDepth == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.overriddenDepth, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Inheritable(
                        c.overriddenElement, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Inheritable(
      Inheritable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Inheritable> getProperty(String key) {
    if (propertyMap<Inheritable>().containsKey(key)) {
      return propertyMap<Inheritable>()[key];
    } else {
      return null;
    }
  }
}

String _render_Field(Field context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Field(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentation, ast, r.template,
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
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.features.map(
                        (e) => _render_Feature(e, ast, r.template, parent: r));
                  },
                ),
                'field': Property(
                  getValue: (CT_ c) => c.field,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FieldElement'),
                  isNullValue: (CT_ c) => c.field == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.field, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fullkind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fullkind, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.getter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ContainerAccessor(c.getter, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Inheritable(
                        c.overriddenElement, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.setter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ContainerAccessor(c.setter, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceCode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceCode, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Field(Field context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Field> getProperty(String key) {
    if (propertyMap<Field>().containsKey(key)) {
      return propertyMap<Field>()[key];
    } else {
      return null;
    }
  }
}

String _render_ContainerAccessor(
    ContainerAccessor context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ContainerAccessor(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.overriddenElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ContainerAccessor(
                        c.overriddenElement, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_ContainerAccessor(
      ContainerAccessor context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ContainerAccessor> getProperty(String key) {
    if (propertyMap<ContainerAccessor>().containsKey(key)) {
      return propertyMap<ContainerAccessor>()[key];
    } else {
      return null;
    }
  }
}

String _render_Accessor(
    Accessor context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Accessor(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Accessor extends RendererBase<Accessor> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Accessor>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ModelElement.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.definingCombo == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_GetterSetterCombo(
                        c.definingCombo, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'PropertyAccessorElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingCombo == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_GetterSetterCombo(
                        c.enclosingCombo, ast, r.template,
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
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                        _Renderer_CallableElementTypeMixin.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_CallableElementTypeMixin(
                        c.modelType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.namePart == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.namePart, ast, r.template,
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
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.originalMember, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sourceCode == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sourceCode, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_Accessor(
      Accessor context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Accessor> getProperty(String key) {
    if (propertyMap<Accessor>().containsKey(key)) {
      return propertyMap<Accessor>()[key];
    } else {
      return null;
    }
  }
}

String _render_GetterSetterCombo(
    GetterSetterCombo context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_GetterSetterCombo(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                          c, remainingNames, 'Iterable<Accessor>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allAccessors.map(
                        (e) => _render_Accessor(e, ast, r.template, parent: r));
                  },
                ),
                'annotations': Property(
                  getValue: (CT_ c) => c.annotations,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Annotation>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.annotations.map((e) =>
                        _render_Annotation(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.arrow == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.arrow, ast, r.template, parent: r);
                  },
                ),
                'characterLocation': Property(
                  getValue: (CT_ c) => c.characterLocation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'CharacterLocation'),
                  isNullValue: (CT_ c) => c.characterLocation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.characterLocation, ast, r.template,
                        parent: r);
                  },
                ),
                'constantInitializer': Property(
                  getValue: (CT_ c) => c.constantInitializer,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Expression'),
                  isNullValue: (CT_ c) => c.constantInitializer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.constantInitializer, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.constantValue == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.constantValue, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.constantValueBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.constantValueBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.constantValueTruncated == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.constantValueTruncated, ast, r.template,
                        parent: r);
                  },
                ),
                'documentationFrom': Property(
                  getValue: (CT_ c) => c.documentationFrom,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.documentationFrom.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.getter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Accessor(c.getter, ast, r.template,
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
                'getterSetterDocumentationComment': Property(
                  getValue: (CT_ c) => c.getterSetterDocumentationComment,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) =>
                      c.getterSetterDocumentationComment == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.getterSetterDocumentationComment, ast, r.template,
                        parent: r);
                  },
                ),
                'hasAccessorsWithDocs': Property(
                  getValue: (CT_ c) => c.hasAccessorsWithDocs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasAccessorsWithDocs == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedParamsNoMetadata == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.linkedParamsNoMetadata, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.modelType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.oneLineDoc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.oneLineDoc, ast, r.template,
                        parent: r);
                  },
                ),
                'parameters': Property(
                  getValue: (CT_ c) => c.parameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Parameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.parameters.map((e) =>
                        _render_Parameter(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.setter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Accessor(c.setter, ast, r.template,
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
              });

  _Renderer_GetterSetterCombo(
      GetterSetterCombo context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<GetterSetterCombo> getProperty(String key) {
    if (propertyMap<GetterSetterCombo>().containsKey(key)) {
      return propertyMap<GetterSetterCombo>()[key];
    } else {
      return null;
    }
  }
}

String _render_Categorization(
    Categorization context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Categorization(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.categories.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
                  },
                ),
                'categoryNames': Property(
                  getValue: (CT_ c) => c.categoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.categoryNames.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
                'displayedCategories': Property(
                  getValue: (CT_ c) => c.displayedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Category>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.displayedCategories.map(
                        (e) => _render_Category(e, ast, r.template, parent: r));
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
                'hasDisplayedCategories': Property(
                  getValue: (CT_ c) => c.hasDisplayedCategories,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasDisplayedCategories == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.image == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.image, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.samples == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.samples, ast, r.template,
                        parent: r);
                  },
                ),
                'subCategoryNames': Property(
                  getValue: (CT_ c) => c.subCategoryNames,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.subCategoryNames.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Categorization(
      Categorization context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Categorization> getProperty(String key) {
    if (propertyMap<Categorization>().containsKey(key)) {
      return propertyMap<Categorization>()[key];
    } else {
      return null;
    }
  }
}

String _render_ExtensionTarget(
    ExtensionTarget context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ExtensionTarget(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.modelType, ast, r.template,
                        parent: r);
                  },
                ),
                'potentiallyApplicableExtensions': Property(
                  getValue: (CT_ c) => c.potentiallyApplicableExtensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.potentiallyApplicableExtensions.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
                  },
                ),
                'potentiallyApplicableExtensionsSorted': Property(
                  getValue: (CT_ c) => c.potentiallyApplicableExtensionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.potentiallyApplicableExtensionsSorted.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_ExtensionTarget(
      ExtensionTarget context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ExtensionTarget> getProperty(String key) {
    if (propertyMap<ExtensionTarget>().containsKey(key)) {
      return propertyMap<ExtensionTarget>()[key];
    } else {
      return null;
    }
  }
}

String _render_Extension(
    Extension context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Extension(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Extension extends RendererBase<Extension> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Extension>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Container.propertyMap<CT_>(),
                ..._Renderer_Categorization.propertyMap<CT_>(),
                'allModelElements': Property(
                  getValue: (CT_ c) => c.allModelElements,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<ModelElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.allModelElements.map((e) =>
                        _render_ModelElement(e, ast, r.template, parent: r));
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredFields.map(
                        (e) => _render_Field(e, ast, r.template, parent: r));
                  },
                ),
                'declaredMethods': Property(
                  getValue: (CT_ c) => c.declaredMethods,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Method>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.declaredMethods.map(
                        (e) => _render_Method(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.extendedType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.extendedType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
                        parent: r);
                  },
                ),
                'hasPublicConstructors': Property(
                  getValue: (CT_ c) => c.hasPublicConstructors,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasPublicConstructors == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
                'publicConstructorsSorted': Property(
                  getValue: (CT_ c) => c.publicConstructorsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Constructor>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstructorsSorted.map((e) =>
                        _render_Constructor(e, ast, r.template, parent: r));
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Extension(
      Extension context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Extension> getProperty(String key) {
    if (propertyMap<Extension>().containsKey(key)) {
      return propertyMap<Extension>()[key];
    } else {
      return null;
    }
  }
}

String _render_TopLevelVariable(
    TopLevelVariable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TopLevelVariable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentation, ast, r.template,
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
                        _Renderer_ModelElement.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
                        parent: r);
                  },
                ),
                'features': Property(
                  getValue: (CT_ c) => c.features,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<Feature>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.features.map(
                        (e) => _render_Feature(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.getter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Accessor(c.getter, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.setter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Accessor(c.setter, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_TopLevelVariable(
      TopLevelVariable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TopLevelVariable> getProperty(String key) {
    if (propertyMap<TopLevelVariable>().containsKey(key)) {
      return propertyMap<TopLevelVariable>()[key];
    } else {
      return null;
    }
  }
}

String _render_Enum(Enum context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Enum(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Enum extends RendererBase<Enum> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Enum>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Class.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_Enum(Enum context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Enum> getProperty(String key) {
    if (propertyMap<Enum>().containsKey(key)) {
      return propertyMap<Enum>()[key];
    } else {
      return null;
    }
  }
}

String _render_ModelFunction(
    ModelFunction context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ModelFunction(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
                  },
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.name == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.name, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_ModelFunction(
      ModelFunction context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ModelFunction> getProperty(String key) {
    if (propertyMap<ModelFunction>().containsKey(key)) {
      return propertyMap<ModelFunction>()[key];
    } else {
      return null;
    }
  }
}

String _render_ModelFunctionTyped(
    ModelFunctionTyped context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ModelFunctionTyped(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                        _Renderer_DefinedElementType.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_DefinedElementType(
                        c.modelType, ast, r.template,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_ModelFunctionTyped(ModelFunctionTyped context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ModelFunctionTyped> getProperty(String key) {
    if (propertyMap<ModelFunctionTyped>().containsKey(key)) {
      return propertyMap<ModelFunctionTyped>()[key];
    } else {
      return null;
    }
  }
}

String _render_Mixin(Mixin context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Mixin(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Mixin extends RendererBase<Mixin> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<CT_ extends Mixin>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Class.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.fileName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.fileName, ast, r.template,
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
                          c, remainingNames, 'List<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.inheritanceChain.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'isAbstract': Property(
                  getValue: (CT_ c) => c.isAbstract,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.isAbstract == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
                  },
                ),
                'publicSuperclassConstraints': Property(
                  getValue: (CT_ c) => c.publicSuperclassConstraints,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames,
                          'Iterable<ParameterizedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicSuperclassConstraints.map((e) =>
                        _render_ParameterizedElementType(e, ast, r.template,
                            parent: r));
                  },
                ),
                'superclassConstraints': Property(
                  getValue: (CT_ c) => c.superclassConstraints,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames,
                          'Iterable<ParameterizedElementType>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.superclassConstraints.map((e) =>
                        _render_ParameterizedElementType(e, ast, r.template,
                            parent: r));
                  },
                ),
              });

  _Renderer_Mixin(Mixin context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Mixin> getProperty(String key) {
    if (propertyMap<Mixin>().containsKey(key)) {
      return propertyMap<Mixin>()[key];
    } else {
      return null;
    }
  }
}

String _render_ParameterizedElementType(ParameterizedElementType context,
    List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ParameterizedElementType(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_ParameterizedElementType
    extends RendererBase<ParameterizedElementType> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends ParameterizedElementType>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_DefinedElementType.propertyMap<CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedName == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedName, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameWithGenerics == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nameWithGenerics, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_ParameterizedElementType(ParameterizedElementType context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ParameterizedElementType> getProperty(String key) {
    if (propertyMap<ParameterizedElementType>().containsKey(key)) {
      return propertyMap<ParameterizedElementType>()[key];
    } else {
      return null;
    }
  }
}

String _render_Typedef(
    Typedef context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Typedef(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  isNullValue: (CT_ c) => c.aliasedType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.aliasedType, ast, r.template,
                        parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.asCallable == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_FunctionTypedef(
                        c.asCallable, ast, r.template,
                        parent: r);
                  },
                ),
                'element': Property(
                  getValue: (CT_ c) => c.element,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TypeAliasElement'),
                  isNullValue: (CT_ c) => c.element == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.element, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.enclosingElement == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelElement(
                        c.enclosingElement, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.filePath == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.filePath, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.genericParameters == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.genericParameters, ast, r.template,
                        parent: r);
                  },
                ),
                'genericTypeParameters': Property(
                  getValue: (CT_ c) => c.genericTypeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameterElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.genericTypeParameters.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.href == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.href, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.kind == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.kind, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ElementType(c.modelType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.nameWithGenerics == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.nameWithGenerics, ast, r.template,
                        parent: r);
                  },
                ),
                'typeParameters': Property(
                  getValue: (CT_ c) => c.typeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameter>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typeParameters.map((e) =>
                        _render_TypeParameter(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_Typedef(
      Typedef context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Typedef> getProperty(String key) {
    if (propertyMap<Typedef>().containsKey(key)) {
      return propertyMap<Typedef>()[key];
    } else {
      return null;
    }
  }
}

String _render_FunctionTypedef(
    FunctionTypedef context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_FunctionTypedef(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_FunctionTypedef extends RendererBase<FunctionTypedef> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends FunctionTypedef>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_Typedef.propertyMap<CT_>(),
                'aliasedType': Property(
                  getValue: (CT_ c) => c.aliasedType,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'FunctionType'),
                  isNullValue: (CT_ c) => c.aliasedType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.aliasedType, ast, r.template,
                        parent: r);
                  },
                ),
                'genericTypeParameters': Property(
                  getValue: (CT_ c) => c.genericTypeParameters,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<TypeParameterElement>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.genericTypeParameters.map(
                        (e) => renderSimple(e, ast, r.template, parent: r));
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
                        _Renderer_CallableElementTypeMixin.propertyMap()
                            .getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.modelType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_CallableElementTypeMixin(
                        c.modelType, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_FunctionTypedef(
      FunctionTypedef context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<FunctionTypedef> getProperty(String key) {
    if (propertyMap<FunctionTypedef>().containsKey(key)) {
      return propertyMap<FunctionTypedef>()[key];
    } else {
      return null;
    }
  }
}

String _render_MarkdownFileDocumentation(MarkdownFileDocumentation context,
    List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_MarkdownFileDocumentation(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentation == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.documentation, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.documentationAsHtml == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.documentationAsHtml, ast, r.template,
                        parent: r);
                  },
                ),
                'documentationFile': Property(
                  getValue: (CT_ c) => c.documentationFile,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'File'),
                  isNullValue: (CT_ c) => c.documentationFile == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.documentationFile, ast, r.template,
                        parent: r);
                  },
                ),
                'documentedWhere': Property(
                  getValue: (CT_ c) => c.documentedWhere,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'DocumentLocation'),
                  isNullValue: (CT_ c) => c.documentedWhere == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.documentedWhere, ast, r.template,
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
                'hasExtendedDocumentation': Property(
                  getValue: (CT_ c) => c.hasExtendedDocumentation,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(c, remainingNames, 'bool'),
                  getBool: (CT_ c) => c.hasExtendedDocumentation == true,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.location == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.location, ast, r.template,
                        parent: r);
                  },
                ),
                'locationPieces': Property(
                  getValue: (CT_ c) => c.locationPieces,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Set<String>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.locationPieces.map(
                        (e) => _render_String(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.oneLineDoc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.oneLineDoc, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_MarkdownFileDocumentation(MarkdownFileDocumentation context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<MarkdownFileDocumentation> getProperty(String key) {
    if (propertyMap<MarkdownFileDocumentation>().containsKey(key)) {
      return propertyMap<MarkdownFileDocumentation>()[key];
    } else {
      return null;
    }
  }
}

String _render_TopLevelContainer(
    TopLevelContainer context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TopLevelContainer(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.classes.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'constants': Property(
                  getValue: (CT_ c) => c.constants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.constants.map((e) => _render_TopLevelVariable(
                        e, ast, r.template,
                        parent: r));
                  },
                ),
                'enums': Property(
                  getValue: (CT_ c) => c.enums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.enums.map(
                        (e) => _render_Enum(e, ast, r.template, parent: r));
                  },
                ),
                'exceptions': Property(
                  getValue: (CT_ c) => c.exceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.exceptions.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'extensions': Property(
                  getValue: (CT_ c) => c.extensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.extensions.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
                  },
                ),
                'functions': Property(
                  getValue: (CT_ c) => c.functions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunction>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.functions.map((e) =>
                        _render_ModelFunction(e, ast, r.template, parent: r));
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
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.mixins.map(
                        (e) => _render_Mixin(e, ast, r.template, parent: r));
                  },
                ),
                'properties': Property(
                  getValue: (CT_ c) => c.properties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.properties.map((e) => _render_TopLevelVariable(
                        e, ast, r.template,
                        parent: r));
                  },
                ),
                'publicClasses': Property(
                  getValue: (CT_ c) => c.publicClasses,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicClasses.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'publicClassesSorted': Property(
                  getValue: (CT_ c) => c.publicClassesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicClassesSorted.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'publicConstants': Property(
                  getValue: (CT_ c) => c.publicConstants,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstants.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicConstantsSorted': Property(
                  getValue: (CT_ c) => c.publicConstantsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicConstantsSorted.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicEnums': Property(
                  getValue: (CT_ c) => c.publicEnums,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicEnums.map(
                        (e) => _render_Enum(e, ast, r.template, parent: r));
                  },
                ),
                'publicEnumsSorted': Property(
                  getValue: (CT_ c) => c.publicEnumsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Enum>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicEnumsSorted.map(
                        (e) => _render_Enum(e, ast, r.template, parent: r));
                  },
                ),
                'publicExceptions': Property(
                  getValue: (CT_ c) => c.publicExceptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicExceptions.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'publicExceptionsSorted': Property(
                  getValue: (CT_ c) => c.publicExceptionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Class>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicExceptionsSorted.map(
                        (e) => _render_Class(e, ast, r.template, parent: r));
                  },
                ),
                'publicExtensions': Property(
                  getValue: (CT_ c) => c.publicExtensions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicExtensions.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
                  },
                ),
                'publicExtensionsSorted': Property(
                  getValue: (CT_ c) => c.publicExtensionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Extension>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicExtensionsSorted.map((e) =>
                        _render_Extension(e, ast, r.template, parent: r));
                  },
                ),
                'publicFunctions': Property(
                  getValue: (CT_ c) => c.publicFunctions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunctionTyped>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicFunctions.map((e) =>
                        _render_ModelFunctionTyped(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicFunctionsSorted': Property(
                  getValue: (CT_ c) => c.publicFunctionsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<ModelFunctionTyped>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicFunctionsSorted.map((e) =>
                        _render_ModelFunctionTyped(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicMixins': Property(
                  getValue: (CT_ c) => c.publicMixins,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Mixin>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicMixins.map(
                        (e) => _render_Mixin(e, ast, r.template, parent: r));
                  },
                ),
                'publicMixinsSorted': Property(
                  getValue: (CT_ c) => c.publicMixinsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Mixin>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicMixinsSorted.map(
                        (e) => _render_Mixin(e, ast, r.template, parent: r));
                  },
                ),
                'publicProperties': Property(
                  getValue: (CT_ c) => c.publicProperties,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicProperties.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicPropertiesSorted': Property(
                  getValue: (CT_ c) => c.publicPropertiesSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<TopLevelVariable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicPropertiesSorted.map((e) =>
                        _render_TopLevelVariable(e, ast, r.template,
                            parent: r));
                  },
                ),
                'publicTypedefs': Property(
                  getValue: (CT_ c) => c.publicTypedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicTypedefs.map(
                        (e) => _render_Typedef(e, ast, r.template, parent: r));
                  },
                ),
                'publicTypedefsSorted': Property(
                  getValue: (CT_ c) => c.publicTypedefsSorted,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.publicTypedefsSorted.map(
                        (e) => _render_Typedef(e, ast, r.template, parent: r));
                  },
                ),
                'typedefs': Property(
                  getValue: (CT_ c) => c.typedefs,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'Iterable<Typedef>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.typedefs.map(
                        (e) => _render_Typedef(e, ast, r.template, parent: r));
                  },
                ),
              });

  _Renderer_TopLevelContainer(
      TopLevelContainer context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TopLevelContainer> getProperty(String key) {
    if (propertyMap<TopLevelContainer>().containsKey(key)) {
      return propertyMap<TopLevelContainer>()[key];
    } else {
      return null;
    }
  }
}

String renderCategory(CategoryTemplateData context, Template template) {
  return _render_CategoryTemplateData(context, template.ast, template);
}

String _render_CategoryTemplateData(
    CategoryTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_CategoryTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.category == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Category(c.category, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Category(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_CategoryTemplateData(CategoryTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<CategoryTemplateData> getProperty(String key) {
    if (propertyMap<CategoryTemplateData>().containsKey(key)) {
      return propertyMap<CategoryTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String _render_TemplateData<T extends Documentable>(
    TemplateData<T> context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateData<T extends Documentable>
    extends RendererBase<TemplateData<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<T extends Documentable,
          CT_ extends TemplateData>() =>
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.bareHref == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.bareHref, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.customFooter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.customFooter, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.customHeader == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.customHeader, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.customInnerFooter == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.customInnerFooter, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.defaultPackage == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.defaultPackage, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.homepage == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.homepage, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
                        parent: r);
                  },
                ),
                'htmlOptions': Property(
                  getValue: (CT_ c) => c.htmlOptions,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'TemplateOptions'),
                  isNullValue: (CT_ c) => c.htmlOptions == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return renderSimple(c.htmlOptions, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
                        parent: r);
                  },
                ),
                'localPackages': Property(
                  getValue: (CT_ c) => c.localPackages,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Package>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.localPackages.map(
                        (e) => _render_Package(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.parent == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Documentable(c.parent, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.relCanonicalPrefix, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Documentable(c.self, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.version == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.version, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_TemplateData(
      TemplateData<T> context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TemplateData<T>> getProperty(String key) {
    if (propertyMap<T, TemplateData>().containsKey(key)) {
      return propertyMap<T, TemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderClass<T extends Class>(
    ClassTemplateData<T> context, Template template) {
  return _render_ClassTemplateData(context, template.ast, template);
}

String _render_ClassTemplateData<T extends Class>(
    ClassTemplateData<T> context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ClassTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_ClassTemplateData<T extends Class>
    extends RendererBase<ClassTemplateData<T>> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<T extends Class,
          CT_ extends ClassTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<T, CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.clazz == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Class(c.clazz, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.container == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(c.container, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.linkedObjectType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.linkedObjectType, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
                  },
                ),
                'objectType': Property(
                  getValue: (CT_ c) => c.objectType,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Class.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.objectType == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Class(c.objectType, ast, r.template,
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
                        _Renderer_Class.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Class(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.sidebarForContainer, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sidebarForLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_ClassTemplateData(ClassTemplateData<T> context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ClassTemplateData<T>> getProperty(String key) {
    if (propertyMap<T, ClassTemplateData>().containsKey(key)) {
      return propertyMap<T, ClassTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderConstructor(ConstructorTemplateData context, Template template) {
  return _render_ConstructorTemplateData(context, template.ast, template);
}

String _render_ConstructorTemplateData(
    ConstructorTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ConstructorTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.clazz == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Class(c.clazz, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.constructor == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Constructor(c.constructor, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.container == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(c.container, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Constructor(c.self, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.sidebarForContainer, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_ConstructorTemplateData(ConstructorTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ConstructorTemplateData> getProperty(String key) {
    if (propertyMap<ConstructorTemplateData>().containsKey(key)) {
      return propertyMap<ConstructorTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderEnum(EnumTemplateData context, Template template) {
  return _render_EnumTemplateData(context, template.ast, template);
}

String _render_EnumTemplateData(
    EnumTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_EnumTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_EnumTemplateData extends RendererBase<EnumTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends EnumTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ClassTemplateData.propertyMap<Enum, CT_>(),
                'eNum': Property(
                  getValue: (CT_ c) => c.eNum,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_Enum.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.eNum == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Enum(c.eNum, ast, r.template, parent: r);
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
                        _Renderer_Enum.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Enum(c.self, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_EnumTemplateData(
      EnumTemplateData context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<EnumTemplateData> getProperty(String key) {
    if (propertyMap<EnumTemplateData>().containsKey(key)) {
      return propertyMap<EnumTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderError(PackageTemplateData context, Template template) {
  return _render_PackageTemplateData(context, template.ast, template);
}

String _render_PackageTemplateData(
    PackageTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_PackageTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_PackageTemplateData extends RendererBase<PackageTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends PackageTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Package, CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.homepage == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.homepage, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.package == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.package, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Package(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_PackageTemplateData(PackageTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<PackageTemplateData> getProperty(String key) {
    if (propertyMap<PackageTemplateData>().containsKey(key)) {
      return propertyMap<PackageTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderExtension<T extends Extension>(
    ExtensionTemplateData<T> context, Template template) {
  return _render_ExtensionTemplateData(context, template.ast, template);
}

String _render_ExtensionTemplateData<T extends Extension>(
    ExtensionTemplateData<T> context,
    List<MustachioNode> ast,
    Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ExtensionTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.container == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(c.container, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.extension == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Extension(c.extension, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Extension(c.self, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.sidebarForContainer, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sidebarForLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_ExtensionTemplateData(ExtensionTemplateData<T> context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<ExtensionTemplateData<T>> getProperty(String key) {
    if (propertyMap<T, ExtensionTemplateData>().containsKey(key)) {
      return propertyMap<T, ExtensionTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderFunction(FunctionTemplateData context, Template template) {
  return _render_FunctionTemplateData(context, template.ast, template);
}

String _render_FunctionTemplateData(
    FunctionTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_FunctionTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.function == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelFunction(c.function, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_ModelFunction(c.self, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sidebarForLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_FunctionTemplateData(FunctionTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<FunctionTemplateData> getProperty(String key) {
    if (propertyMap<FunctionTemplateData>().containsKey(key)) {
      return propertyMap<FunctionTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderIndex(PackageTemplateData context, Template template) {
  return _render_PackageTemplateData(context, template.ast, template);
}

String renderLibrary(LibraryTemplateData context, Template template) {
  return _render_LibraryTemplateData(context, template.ast, template);
}

String _render_LibraryTemplateData(
    LibraryTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_LibraryTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_LibraryTemplateData extends RendererBase<LibraryTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends LibraryTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Library, CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sidebarForLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_LibraryTemplateData(LibraryTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<LibraryTemplateData> getProperty(String key) {
    if (propertyMap<LibraryTemplateData>().containsKey(key)) {
      return propertyMap<LibraryTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderMethod(MethodTemplateData context, Template template) {
  return _render_MethodTemplateData(context, template.ast, template);
}

String _render_MethodTemplateData(
    MethodTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_MethodTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_MethodTemplateData extends RendererBase<MethodTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends MethodTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Method, CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.container == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(c.container, ast, r.template,
                        parent: r);
                  },
                ),
                'containerDesc': Property(
                  getValue: (CT_ c) => c.containerDesc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.containerDesc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.containerDesc, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.method == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Method(c.method, ast, r.template, parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Method(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.sidebarForContainer, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_MethodTemplateData(MethodTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<MethodTemplateData> getProperty(String key) {
    if (propertyMap<MethodTemplateData>().containsKey(key)) {
      return propertyMap<MethodTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderMixin(MixinTemplateData context, Template template) {
  return _render_MixinTemplateData(context, template.ast, template);
}

String _render_MixinTemplateData(
    MixinTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_MixinTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_MixinTemplateData extends RendererBase<MixinTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends MixinTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_ClassTemplateData.propertyMap<Mixin, CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.mixin == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Mixin(c.mixin, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Mixin(c.self, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_MixinTemplateData(
      MixinTemplateData context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<MixinTemplateData> getProperty(String key) {
    if (propertyMap<MixinTemplateData>().containsKey(key)) {
      return propertyMap<MixinTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderProperty(PropertyTemplateData context, Template template) {
  return _render_PropertyTemplateData(context, template.ast, template);
}

String _render_PropertyTemplateData(
    PropertyTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_PropertyTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.container == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(c.container, ast, r.template,
                        parent: r);
                  },
                ),
                'containerDesc': Property(
                  getValue: (CT_ c) => c.containerDesc,
                  renderVariable:
                      (CT_ c, Property<CT_> self, List<String> remainingNames) {
                    if (remainingNames.isEmpty) {
                      return self.getValue(c).toString();
                    }
                    var name = remainingNames.first;
                    var nextProperty =
                        _Renderer_String.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.containerDesc == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.containerDesc, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
                  },
                ),
                'navLinksWithGenerics': Property(
                  getValue: (CT_ c) => c.navLinksWithGenerics,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Container>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinksWithGenerics.map((e) =>
                        _render_Container(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.property == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Field(c.property, ast, r.template,
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
                        _Renderer_Field.propertyMap().getValue(name);
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Field(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForContainer == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(
                        c.sidebarForContainer, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_PropertyTemplateData(PropertyTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<PropertyTemplateData> getProperty(String key) {
    if (propertyMap<PropertyTemplateData>().containsKey(key)) {
      return propertyMap<PropertyTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderSidebarForContainer<T extends Documentable>(
    TemplateDataWithContainer<T> context, Template template) {
  return _render_TemplateDataWithContainer(context, template.ast, template);
}

String _render_TemplateDataWithContainer<T extends Documentable>(
    TemplateDataWithContainer<T> context,
    List<MustachioNode> ast,
    Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TemplateDataWithContainer(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.container == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Container(c.container, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_TemplateDataWithContainer(TemplateDataWithContainer<T> context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TemplateDataWithContainer<T>> getProperty(String key) {
    if (propertyMap<T, TemplateDataWithContainer>().containsKey(key)) {
      return propertyMap<T, TemplateDataWithContainer>()[key];
    } else {
      return null;
    }
  }
}

String renderSidebarForLibrary<T extends Documentable>(
    TemplateDataWithLibrary<T> context, Template template) {
  return _render_TemplateDataWithLibrary(context, template.ast, template);
}

String _render_TemplateDataWithLibrary<T extends Documentable>(
    TemplateDataWithLibrary<T> context,
    List<MustachioNode> ast,
    Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TemplateDataWithLibrary(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_TemplateDataWithLibrary(TemplateDataWithLibrary<T> context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TemplateDataWithLibrary<T>> getProperty(String key) {
    if (propertyMap<T, TemplateDataWithLibrary>().containsKey(key)) {
      return propertyMap<T, TemplateDataWithLibrary>()[key];
    } else {
      return null;
    }
  }
}

String renderTopLevelProperty(
    TopLevelPropertyTemplateData context, Template template) {
  return _render_TopLevelPropertyTemplateData(context, template.ast, template);
}

String _render_TopLevelPropertyTemplateData(
    TopLevelPropertyTemplateData context,
    List<MustachioNode> ast,
    Template template,
    {RendererBase<Object> parent}) {
  var renderer =
      _Renderer_TopLevelPropertyTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.property == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_TopLevelVariable(c.property, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_TopLevelVariable(c.self, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sidebarForLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
                  },
                ),
              });

  _Renderer_TopLevelPropertyTemplateData(TopLevelPropertyTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TopLevelPropertyTemplateData> getProperty(String key) {
    if (propertyMap<TopLevelPropertyTemplateData>().containsKey(key)) {
      return propertyMap<TopLevelPropertyTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String renderTypedef(TypedefTemplateData context, Template template) {
  return _render_TypedefTemplateData(context, template.ast, template);
}

String _render_TypedefTemplateData(
    TypedefTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TypedefTemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TypedefTemplateData extends RendererBase<TypedefTemplateData> {
  static final Map<Type, Object> _propertyMapCache = {};
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TypedefTemplateData>() =>
      _propertyMapCache.putIfAbsent(
          CT_,
          () => {
                ..._Renderer_TemplateData.propertyMap<Typedef, CT_>(),
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.htmlBase == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.htmlBase, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.layoutTitle == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.layoutTitle, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.library == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Library(c.library, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.metaDescription == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.metaDescription, ast, r.template,
                        parent: r);
                  },
                ),
                'navLinks': Property(
                  getValue: (CT_ c) => c.navLinks,
                  renderVariable: (CT_ c, Property<CT_> self,
                          List<String> remainingNames) =>
                      self.renderSimpleVariable(
                          c, remainingNames, 'List<Documentable>'),
                  renderIterable:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return c.navLinks.map((e) =>
                        _render_Documentable(e, ast, r.template, parent: r));
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.self == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Typedef(c.self, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.sidebarForLibrary == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.sidebarForLibrary, ast, r.template,
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.title == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_String(c.title, ast, r.template, parent: r);
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
                    return nextProperty.renderVariable(self.getValue(c),
                        nextProperty, [...remainingNames.skip(1)]);
                  },
                  isNullValue: (CT_ c) => c.typeDef == null,
                  renderValue:
                      (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
                    return _render_Typedef(c.typeDef, ast, r.template,
                        parent: r);
                  },
                ),
              });

  _Renderer_TypedefTemplateData(TypedefTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TypedefTemplateData> getProperty(String key) {
    if (propertyMap<TypedefTemplateData>().containsKey(key)) {
      return propertyMap<TypedefTemplateData>()[key];
    } else {
      return null;
    }
  }
}
