// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:dart_style/dart_style.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// The specification of a renderer, as derived from a @Renderer annotation.
class RendererSpec {
  /// The name of the render function.
  final String _name;

  final InterfaceType _contextType;

  final Set<DartType> _visibleTypes;

  RendererSpec(this._name, this._contextType, this._visibleTypes);
}

/// Builds [specs] into a Dart library containing runtime renderers.
String buildTemplateRenderers(Set<RendererSpec> specs, Uri sourceUri,
    TypeProvider typeProvider, TypeSystem typeSystem,
    {bool rendererClassesArePublic = false}) {
  var allVisibleTypes = specs
      .map((spec) => spec._visibleTypes)
      .reduce((value, element) => value.union(element))
      .map((type) => type.element)
      .toSet();
  var raw = RuntimeRenderersBuilder(
          sourceUri, typeProvider, typeSystem, allVisibleTypes,
          rendererClassesArePublic: rendererClassesArePublic)
      ._buildTemplateRenderers(specs);
  return DartFormatter().format(raw.toString());
}

/// This class builds runtime Mustache renderers from a set of [RendererSpec]s.
class RuntimeRenderersBuilder {
  static const _contextTypeVariable = 'CT_';

  final _buffer = StringBuffer();

  /// A queue of types to process, in order to find all types for which we need
  /// to build renderers.
  final _typesToProcess = Queue<_RendererInfo>();

  /// Maps a type to the name of the render function which can render that type
  /// as a context type.
  final _typeToRenderFunctionName = <ClassElement, String>{};

  /// Maps a type to the name of the renderer class which can render that type
  /// as a context type.
  final _typeToRendererClassName = <ClassElement, String>{};

  final Uri _sourceUri;

  final TypeProvider _typeProvider;
  final TypeSystem _typeSystem;

  final Set<Element> _allVisibleElements;

  /// Whether renderer classes are public. This should only be true for testing.
  final bool _rendererClassesArePublic;

  RuntimeRenderersBuilder(this._sourceUri, this._typeProvider, this._typeSystem,
      this._allVisibleElements,
      {bool rendererClassesArePublic = false})
      : _rendererClassesArePublic = rendererClassesArePublic;

  String _buildTemplateRenderers(Set<RendererSpec> specs) {
    // TODO(srawlins): There are some private renderer functions that are
    // unused. Figure out if we can detect these statically, and then not
    // generate them.
    // TODO(srawlins): To really get the correct list of imports, we need to use
    // the code_builder package.
    _buffer.writeln('''
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
import '${p.basename(_sourceUri.path)}';
''');

    specs.forEach(_addTypesForRendererSpec);

    var builtRenderers = <ClassElement>{};

    while (_typesToProcess.isNotEmpty) {
      var info = _typesToProcess.removeFirst();

      if (info.isFullRenderer) {
        var buildOnlyPublicFunction =
            builtRenderers.contains(info._contextClass);
        _buildRenderer(info, buildOnlyPublicFunction: buildOnlyPublicFunction);
        builtRenderers.add(info._contextClass);
      }
    }

    return _buffer.toString();
  }

  /// Adds type specified in [spec] to the [_typesToProcess] queue, as well as
  /// all supertypes, and the types of all valid getters, recursively.
  void _addTypesForRendererSpec(RendererSpec spec) {
    var element = spec._contextType.element;
    var rendererInfo = _RendererInfo(element,
        public: _rendererClassesArePublic, publicApiFunctionName: spec._name);
    _typesToProcess.add(rendererInfo);
    _typeToRenderFunctionName[element] = rendererInfo._renderFunctionName;
    _typeToRendererClassName[element] = rendererInfo._rendererClassName;

    spec._contextType.accessors.forEach(_addPropertyToProcess);

    for (var mixin in spec._contextType.element.mixins) {
      _addTypeToProcess(mixin.element, isFullRenderer: true);
    }
    var superclass = spec._contextType.element.supertype;

    while (superclass != null) {
      // Any type specified with a renderer spec (`@Renderer`) is full.
      _addTypeToProcess(superclass.element, isFullRenderer: true);
      for (var mixin in superclass.element.mixins) {
        _addTypeToProcess(mixin.element, isFullRenderer: true);
      }
      superclass.accessors.forEach(_addPropertyToProcess);
      superclass = superclass.element.supertype;
    }
  }

  /// Adds the return type of [property] to the [_typesToProcess] queue, if it
  /// is a "valid" property.
  ///
  /// A "valid" property is a public, instance getter with an interface type
  /// return type. Getters annotated with @internal, @protected, or
  /// @visibleForTesting are not valid.
  void _addPropertyToProcess(PropertyAccessorElement property) {
    if (property.isPrivate || property.isStatic || property.isSetter) return;
    if (property.hasProtected || property.hasVisibleForTesting) return;
    var type = _relevantTypeFrom(property.type.returnType);
    if (type == null) return;

    var types = _typesToProcess.where((rs) => rs._contextClass == type.element);
    if (types.isNotEmpty) {
      // [type] has already been added to [_typesToProcess], and all of its
      // supertypes and properties have been visited.
      return;
    }

    _addTypeHierarchyToProcess(type,
        isFullRenderer: _isVisibleToMustache(type.element));
  }

  /// Returns an [InterfaceType] which may be relevant for generating a
  /// renderer, given a [type]:
  ///
  /// * If [type] is assignable to [Iterable<T>], returns the relevant type from
  ///   `T`.
  /// * If [type] is a [TypeParameterType] with a bound other than `dynamic`,
  ///   returns the relevant type from the bound.
  /// * If [type] is an [InterfaceType] (not assignable to [Iterable]), returns
  ///   [type].
  /// * Otherwise, returns `null`, indicating there is no relevant type.
  InterfaceType _relevantTypeFrom(DartType type) {
    if (type is InterfaceType) {
      if (_typeSystem.isAssignableTo(type, _typeProvider.iterableDynamicType)) {
        var iterableElement = _typeProvider.iterableElement;
        var iterableType = type.asInstanceOf(iterableElement);
        var innerType = iterableType.typeArguments.first;

        return _relevantTypeFrom(innerType);
      } else {
        return type;
      }
    } else if (type is TypeParameterType) {
      var bound = type.bound;
      if (bound == null || bound.isDynamic) {
        // Don't add functions for a generic type, for example
        // `List<E>.first` has type `E`, which we don't have a specific
        // renderer for.
        // TODO(srawlins): Find a solution for this. We can track all of the
        // concrete types substituted for `E` for example.
        return null;
      } else {
        return _relevantTypeFrom(bound);
      }
    } else {
      // We can do nothing with function types, etc.
      return null;
    }
  }

  /// Adds [type] to the queue of types to process, as well as related types:
  ///
  /// * its supertypes (if [type] is not a mixin),
  /// * mixed in types,
  /// * superclass constraints (if [type] a mixin),
  /// * types of relevant properties (recursively).
  void _addTypeHierarchyToProcess(InterfaceType type,
      {@required bool isFullRenderer}) {
    while (type != null) {
      _addTypeToProcess(type.element, isFullRenderer: isFullRenderer);
      if (isFullRenderer) {
        for (var accessor in type.accessors) {
          var accessorType = _relevantTypeFrom(accessor.type.returnType);
          if (accessorType == null) continue;
          _addPropertyToProcess(accessor);
        }
      }
      for (var mixin in type.element.mixins) {
        _addTypeHierarchyToProcess(mixin, isFullRenderer: isFullRenderer);
      }
      if (type.element.isMixin) {
        for (var constraint in type.element.superclassConstraints) {
          _addTypeToProcess(constraint.element, isFullRenderer: isFullRenderer);
        }
        break;
      } else {
        type = type.superclass;
      }
    }
  }

  /// Adds [type] to the [_typesToProcess] queue, if it is not already there.
  void _addTypeToProcess(ClassElement element,
      {@required bool isFullRenderer}) {
    var types = _typesToProcess.where((rs) => rs._contextClass == element);
    if (types.isEmpty) {
      var rendererInfo = _RendererInfo(element,
          isFullRenderer: isFullRenderer, public: _rendererClassesArePublic);
      _typesToProcess.add(rendererInfo);
      if (isFullRenderer) {
        _typeToRenderFunctionName[element] = rendererInfo._renderFunctionName;
        _typeToRendererClassName[element] = rendererInfo._rendererClassName;
      }
    } else {
      for (var typeToProcess in types) {
        if (isFullRenderer && !typeToProcess.isFullRenderer) {
          // This is the only case in which we update a type-to-render.
          typeToProcess.isFullRenderer = true;
          _typeToRenderFunctionName[element] =
              typeToProcess._renderFunctionName;
          _typeToRendererClassName[element] = typeToProcess._rendererClassName;
        }
      }
    }
  }

  /// Returns whether [element] or any of its supertypes are "visible" to Mustache.
  bool _isVisibleToMustache(ClassElement element) {
    if (_allVisibleElements.contains(element)) {
      return true;
    }
    if (element.supertype == null) {
      return false;
    }
    return _isVisibleToMustache(element.supertype.element);
  }

  /// Builds render functions and the renderer class for [renderer].
  ///
  /// The function and the class are each written as Dart code to [_buffer].
  ///
  /// If [renderer] also specifies a `publicApiFunctionName`, then a public API
  /// function (which renders a context object using a template file at a path,
  /// rather than an AST) is also written.
  ///
  /// If [buildOnlyPublicFunction] is true, then the private render function and
  /// renderer classes are not built, having been built for a different
  /// [_RendererInfo].
  void _buildRenderer(_RendererInfo renderer,
      {@required bool buildOnlyPublicFunction}) {
    var typeName = renderer._typeName;
    var typeWithVariables = '$typeName${renderer._typeVariablesString}';

    if (renderer.publicApiFunctionName != null) {
      _buffer.writeln('''
String ${renderer.publicApiFunctionName}${renderer._typeParametersString}(
    $typeWithVariables context, Template template) {
  return ${renderer._renderFunctionName}(context, template.ast, template);
}
''');
    }

    if (buildOnlyPublicFunction) return;

    // Write out the render function.
    _buffer.writeln('''
String ${renderer._renderFunctionName}${renderer._typeParametersString}(
    $typeWithVariables context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = ${renderer._rendererClassName}(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}
''');

    // Write out the renderer class.
    _buffer.write('''
class ${renderer._rendererClassName}${renderer._typeParametersString}
    extends RendererBase<$typeWithVariables> {
''');
    _writePropertyMap(renderer);
    // Write out the constructor.
    _buffer.writeln('''
  ${renderer._rendererClassName}(
        $typeWithVariables context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);
''');
    var propertyMapTypeArguments = renderer._typeArgumentsStringWith(typeName);
    var propertyMapName = 'propertyMap$propertyMapTypeArguments';
    // Write out `getProperty`.
    _buffer.writeln('''
  @override
  Property<$typeWithVariables> getProperty(String key) {
    if ($propertyMapName().containsKey(key)) {
      return $propertyMapName()[key];
    } else {
      return null;
    }
  }
''');
    // Close the class.
    _buffer.writeln('}');
  }

  /// Write out the property map for [renderer].
  ///
  /// For each valid property of the context type of [renderer], this maps the
  /// property's name to the property's [Property] object.
  void _writePropertyMap(_RendererInfo renderer) {
    var contextClass = renderer._contextClass;
    var generics = renderer._typeParametersStringWith(
        '$_contextTypeVariable extends ${renderer._typeName}');
    // It would be simplest if [propertyMap] were just a getter, but it must be
    // parameterized on `CT_`, so it is a static method. Due to the possibly
    // extensive amount of spreading (supertypes, mixins) and object
    // construction (lots of [Property] objects with function literals), we
    // cache the construction of each one, keyed to the `CT_` value. Each cache
    // should not have many entries, as there are probably not many values for
    // each type variable, `CT_`, typically one.
    _buffer.writeln('''
    static final Map<Type, Object> _propertyMapCache = {};
    static Map<String, Property<$_contextTypeVariable>> propertyMap$generics() =>
        _propertyMapCache.putIfAbsent($_contextTypeVariable, () => {''');
    if (contextClass.supertype != null) {
      var superclassRendererName =
          _typeToRendererClassName[contextClass.supertype.element];
      if (superclassRendererName != null) {
        var superMapName = '$superclassRendererName.propertyMap';
        var generics = _asGenerics([
          ...contextClass.supertype.typeArguments
              .map((e) => e.getDisplayString(withNullability: false)),
          _contextTypeVariable
        ]);
        _buffer.writeln('    ...$superMapName$generics(),');
      }
    }
    if (contextClass.mixins != null) {
      // Mixins are spread into the property map _after_ the super class, so
      // that they override any values which need to be overridden. Superclass
      // and mixins override from left to right, as do spreads:
      // `class C extends E with M, N` first takes members from N, then M, then
      // E. Similarly, `{...a, ...b, ...c}` will feature elements from `c` which
      // override `b` and `a`.
      for (var mixin in contextClass.mixins) {
        var mixinRendererName = _typeToRendererClassName[mixin.element];
        if (mixinRendererName != null) {
          var mixinMapName = '$mixinRendererName.propertyMap';
          var generics = _asGenerics([
            ...mixin.typeArguments
                .map((e) => e.getDisplayString(withNullability: false)),
            _contextTypeVariable
          ]);
          _buffer.writeln('    ...$mixinMapName$generics(),');
        }
      }
    }
    for (var property in [...contextClass.accessors]
      ..sort((a, b) => a.name.compareTo(b.name))) {
      var returnType = property.type.returnType;
      if (returnType is InterfaceType) {
        _writeProperty(renderer, property, returnType);
      } else if (returnType is TypeParameterType &&
          returnType.bound != null &&
          !returnType.bound.isDynamic) {
        _writeProperty(renderer, property, returnType.bound);
      }
    }
    _buffer.writeln('});');
    _buffer.writeln('');
  }

  void _writeProperty(_RendererInfo renderer, PropertyAccessorElement property,
      InterfaceType getterType) {
    if (getterType == _typeProvider.typeType) {
      // The [Type] type is the first case of a type we don't want to traverse.
      return;
    }

    if (property.isPrivate || property.isStatic || property.isSetter) return;
    if (property.hasProtected || property.hasVisibleForTesting) return;
    _buffer.writeln("'${property.name}': Property(");
    _buffer
        .writeln('getValue: ($_contextTypeVariable c) => c.${property.name},');

    var getterName = property.name;

    // Only add a `getProperties` function, which returns the property map for
    // [getterType], if [getterType] is a renderable type.
    if (_typeToRendererClassName.containsKey(getterType.element)) {
      var rendererClassName = _typeToRendererClassName[getterType.element];
      _buffer.writeln('''
renderVariable:
    ($_contextTypeVariable c, Property<$_contextTypeVariable> self, List<String> remainingNames) {
  if (remainingNames.isEmpty) {
    return self.getValue(c).toString();
  }
  var name = remainingNames.first;
  var nextProperty = $rendererClassName.propertyMap().getValue(name);
  return nextProperty.renderVariable(
      self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
},
''');
    } else {
      // [getterType] does not have a full renderer, so we just render a simple
      // variable, with no opportunity to access fields on [getterType].
      var getterTypeString =
          getterType.getDisplayString(withNullability: false);
      _buffer.writeln('''
renderVariable:
    ($_contextTypeVariable c, Property<CT_> self, List<String> remainingNames) =>
        self.renderSimpleVariable(c, remainingNames, '$getterTypeString'),
''');
    }

    if (getterType.isDartCoreBool) {
      _buffer.writeln(
          'getBool: ($_contextTypeVariable c) => c.$getterName == true,');
    } else if (_typeSystem.isAssignableTo(
        getterType, _typeProvider.iterableDynamicType)) {
      var iterableElement = _typeProvider.iterableElement;
      var iterableType = getterType.asInstanceOf(iterableElement);
      // Not sure why [iterableType] would be null... unresolved type?
      if (iterableType != null) {
        var innerType = iterableType.typeArguments.first;
        // Don't add Iterable functions for a generic type, for example
        // `List<E>.reversed` has inner type `E`, which we don't have a specific
        // renderer for.
        // TODO(srawlins): Find a solution for this. We can track all of the
        // concrete types substituted for `E` for example.
        if (innerType is! TypeParameterType) {
          var rendererName =
              _typeToRenderFunctionName[innerType.element] ?? 'renderSimple';
          _buffer.writeln('''
renderIterable:
    ($_contextTypeVariable c, RendererBase<$_contextTypeVariable> r, List<MustachioNode> ast) {
  return c.$getterName.map((e) => $rendererName(e, ast, r.template, parent: r));
},
''');
        }
      }
    } else {
      // Don't add Iterable functions for a generic type, for example
      // `List<E>.first` has type `E`, which we don't have a specific
      // renderer for.
      // TODO(srawlins): Find a solution for this. We can track all of the
      // concrete types substituted for `E` for example.
      if (getterName is! TypeParameterType) {
        var rendererName =
            _typeToRenderFunctionName[getterType.element] ?? 'renderSimple';
        _buffer.writeln('''
isNullValue: ($_contextTypeVariable c) => c.$getterName == null,

renderValue:
    ($_contextTypeVariable c, RendererBase<$_contextTypeVariable> r, List<MustachioNode> ast) {
  return $rendererName(c.$getterName, ast, r.template, parent: r);
},
''');
      }
    }
    _buffer.writeln('),');
  }
}

/// A container with the information needed to distinguish one
/// renderer-to-be-built from another.
///
/// This can be used when building a set of renderers to build (both the render
/// functions and the renderer class), and also to refer from one renderer to
/// another.
class _RendererInfo {
  final ClassElement _contextClass;

  /// The name of the top level render function.
  ///
  /// This function is public when specified in a @Renderer annotation, and
  /// private otherwise.
  final String _renderFunctionName;

  /// Whether the renderer should be a full renderer.
  ///
  /// If a render spec is not specified with @Renderer, then a class needs to be
  /// annotated with @visibleToRender in order to get a full renderer.
  /// Otherwise, the [SimpleRenderer] will be used.
  ///
  /// It may be initially determined that we only need an abbreviated, then
  /// later determined that we need a full renderer, so this field is not final.
  bool isFullRenderer;

  /// The public API function name specified with @Renderer, or null.
  String publicApiFunctionName;

  factory _RendererInfo(ClassElement contextClass,
      {bool public = false,
      bool isFullRenderer = true,
      String publicApiFunctionName}) {
    var typeBaseName = contextClass.name;
    var renderFunctionName = '_render_$typeBaseName';
    var rendererClassName =
        public ? 'Renderer_$typeBaseName' : '_Renderer_$typeBaseName';

    return _RendererInfo._(contextClass, renderFunctionName, rendererClassName,
        isFullRenderer: isFullRenderer,
        publicApiFunctionName: publicApiFunctionName);
  }

  _RendererInfo._(
      this._contextClass, this._renderFunctionName, this._rendererClassName,
      {@required this.isFullRenderer, this.publicApiFunctionName});

  String get _typeName => _contextClass.name;

  final String _rendererClassName;

  /// The type parameters of the context type, if any, as a String, including
  /// bounds and the angled brackets, otherwise a blank String.
  String get _typeParametersString {
    return _asGenerics(_contextClass.typeParameters
        .map((tp) => tp.getDisplayString(withNullability: false)));
  }

  /// The type variables of the context type, if any, as a String, including
  /// the angled brackets, otherwise a blank String.
  String get _typeVariablesString {
    return _asGenerics(_contextClass.typeParameters.map((tp) => tp.name));
  }

  /// Returns the type parameters of the context type, and [extra], as they
  /// appear in a list of generics.
  String _typeParametersStringWith(String extra) {
    return _asGenerics([
      ..._contextClass.typeParameters
          .map((tp) => tp.getDisplayString(withNullability: false)),
      extra,
    ]);
  }

  /// Returns the type arguments of the context type, and [extra], as they
  /// appear in a list of generics.
  String _typeArgumentsStringWith(String extra) {
    return _asGenerics([
      ..._contextClass.thisType.typeArguments
          .map((tp) => tp.getDisplayString(withNullability: false)),
      extra,
    ]);
  }
}

/// Returns [values] as they appear in a list of generics, with angled brackets,
/// and an empty string when [values] is empty.
String _asGenerics(Iterable<String> values) =>
    values.isEmpty ? '' : '<${values.join(', ')}>';
