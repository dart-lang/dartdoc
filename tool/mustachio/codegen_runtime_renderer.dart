// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

/// The specification of a renderer, as derived from a @Renderer annotation.
class RendererSpec {
  /// The name of the render function.
  final String _name;

  final InterfaceType _contextType;

  RendererSpec(this._name, this._contextType);
}

/// Builds [specs] into a Dart library containing runtime renderers.
String buildTemplateRenderers(Set<RendererSpec> specs, Uri sourceUri,
    TypeProvider typeProvider, TypeSystem typeSystem,
    {bool rendererClassesArePublic = false}) {
  var raw = RuntimeRenderersBuilder(sourceUri, typeProvider, typeSystem,
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

  /// Whether renderer classes are public. This should only be true for testing.
  final bool _rendererClassesArePublic;

  RuntimeRenderersBuilder(this._sourceUri, this._typeProvider, this._typeSystem,
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

// ignore_for_file: camel_case_types, unnecessary_cast, unused_element, unused_import
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import '${p.basename(_sourceUri.path)}';
''');

    specs.forEach(_addTypesForRendererSpec);

    while (_typesToProcess.isNotEmpty) {
      var info = _typesToProcess.removeFirst();

      _buildRenderer(info);
    }

    return _buffer.toString();
  }

  void _addTypesForRendererSpec(RendererSpec spec) {
    var element = spec._contextType.element;
    _typesToProcess.add(_RendererInfo(element.thisType, spec._name,
        public: _rendererClassesArePublic));
    _typeToRenderFunctionName[element] = spec._name;
    _typeToRendererClassName[element] = element.name;

    spec._contextType.accessors.forEach(_addPropertyToProcess);
    var superclass = spec._contextType.superclass;
    while (superclass != null) {
      _addTypeToProcess(superclass.element.thisType);
      superclass.accessors.forEach(_addPropertyToProcess);
      superclass = superclass.superclass;
    }
  }

  /// Adds the return type of [property] to the [_typesToProcess] queue, if it
  /// is a "valid" property.
  ///
  /// A "valid" property is a public, instance getter with an interface type
  /// return type.
  void _addPropertyToProcess(PropertyAccessorElement property) {
    if (property.isPrivate || property.isStatic || property.isSetter) return;
    var type = property.type.returnType;
    while (type != null && type is InterfaceType) {
      _addTypeToProcess((type as InterfaceType).element.thisType);
      type = (type as InterfaceType).superclass;
    }
  }

  /// Adds [type] to the [_typesToProcess] queue, if it is not already there.
  void _addTypeToProcess(InterfaceType type) {
    if (type == _typeProvider.typeType) {
      // The [Type] type is the first case of a type we don't want to traverse.
      return;
    }
    var typeName = type.element.name;
    var renderFunctionName = '_render_$typeName';
    var typeToProcess = _typesToProcess
        .singleWhere((rs) => rs._contextType == type, orElse: () => null);
    if (typeToProcess == null) {
      var rendererInfo = _RendererInfo(type, renderFunctionName,
          public: _rendererClassesArePublic);
      _typesToProcess.add(rendererInfo);
      _typeToRenderFunctionName[type.element] = renderFunctionName;
      _typeToRendererClassName[type.element] = rendererInfo._rendererClassName;
    }
  }

  /// Builds both the render function and the renderer class for [renderer].
  ///
  /// The function and the class are each written as Dart code to [_buffer].
  void _buildRenderer(_RendererInfo renderer) {
    var typeName = renderer._typeName;

    // Write out the render function.
    _buffer.writeln('''
String ${renderer._functionName}${renderer._typeParametersString}(
    $typeName context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = ${renderer._rendererClassName}(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}
''');

    // Write out the renderer class.
    _buffer.write('''
class ${renderer._rendererClassName}${renderer._typeParametersString}
    extends RendererBase<$typeName> {
''');
    _writePropertyMap(renderer);
    // Write out the constructor.
    _buffer.writeln('''
  ${renderer._rendererClassName}($typeName context, RendererBase<Object> parent)
      : super(context, parent);
''');
    var propertyMapTypeArguments = renderer._typeArgumentsStringWith(typeName);
    var propertyMapName = 'propertyMap$propertyMapTypeArguments';
    // Write out `getProperty`.
    _buffer.writeln('''
  @override
  Property<$typeName> getProperty(String key) {
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
    var type = renderer._contextType;
    var generics = renderer._typeParametersStringWith(
        '$_contextTypeVariable extends ${renderer._typeName}');
    _buffer.writeln('static Map<String, Property<$_contextTypeVariable>> '
        'propertyMap$generics() => {');
    var interfaceTypedProperties = type.accessors
        .where((property) => property.type.returnType is InterfaceType);
    for (var property in [...interfaceTypedProperties]
      ..sort((a, b) => a.name.compareTo(b.name))) {
      _writeProperty(renderer, property);
    }
    if (type.superclass != null) {
      var superclassRendererName =
          _typeToRendererClassName[type.superclass.element];
      var superMapName = '$superclassRendererName.propertyMap';
      var generics = _asGenerics([
        ...type.superclass.typeArguments
            .map((e) => e.getDisplayString(withNullability: false)),
        _contextTypeVariable
      ]);
      _buffer.writeln('    ...$superMapName$generics(),');
    }
    _buffer.writeln('};');
    _buffer.writeln('');
  }

  void _writeProperty(
      _RendererInfo renderer, PropertyAccessorElement property) {
    var getterType = property.type.returnType as InterfaceType;
    if (getterType == _typeProvider.typeType) {
      // The [Type] type is the first case of a type we don't want to traverse.
      return;
    }

    if (property.isPrivate || property.isStatic || property.isSetter) return;
    _buffer.writeln("'${property.name}': Property(");
    _buffer
        .writeln('getValue: ($_contextTypeVariable c) => c.${property.name},');

    var getterName = property.name;

    // Only add a `getProperties` function, which returns the property map for
    // [getterType], if [getterType] is a renderable type.
    if (_typeToRendererClassName.containsKey(getterType.element)) {
      var rendererClassName = _typeToRendererClassName[getterType.element];
      _buffer.writeln('getProperties: $rendererClassName.propertyMap,');
    }

    if (getterType.isDartCoreBool) {
      _buffer.writeln(
          'getBool: ($_contextTypeVariable c) => c.$getterName == true,');
    } else if (_typeSystem.isAssignableTo(
        getterType, _typeProvider.iterableDynamicType)) {
      var iterableElement = _typeProvider.iterableElement;
      var iterableType = getterType.asInstanceOf(iterableElement);
      var innerType = iterableType.typeArguments.first;
      // Don't add Iterable functions for a generic type, for example
      // `List<E>.reversed` has inner type `E`, which we don't have a specific
      // renderer for.
      // TODO(srawlins): Find a solution for this. We can track all of the
      // concrete types substituted for `E` for example.
      if (innerType is! TypeParameterType) {
        var rendererName = _typeToRenderFunctionName[innerType.element];
        _buffer.writeln('''
isEmptyIterable: ($_contextTypeVariable c) => c.$getterName?.isEmpty ?? true,

renderIterable:
    ($_contextTypeVariable c, RendererBase<$_contextTypeVariable> r, List<MustachioNode> ast) {
  var buffer = StringBuffer();
  for (var e in c.$getterName) {
    buffer.write($rendererName(e, ast, parent: r));
  }
  return buffer.toString();
},
''');
      }
    } else {
      // Don't add Iterable functions for a generic type, for example
      // `List<E>.first` has type `E`, which we don't have a specific
      // renderer for.
      // TODO(srawlins): Find a solution for this. We can track all of the
      // concrete types substituted for `E` for example.
      if (getterName is! TypeParameterType) {
        var rendererName = _typeToRenderFunctionName[getterType.element];
        _buffer.writeln('''
isNullValue: ($_contextTypeVariable c) => c.$getterName == null,

renderValue:
    ($_contextTypeVariable c, RendererBase<$_contextTypeVariable> r, List<MustachioNode> ast) {
  return $rendererName(c.$getterName, ast, parent: r);
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
  final InterfaceType _contextType;

  /// The name of the top level render function.
  ///
  /// This function is public when specified in a @Renderer annotation, and
  /// private otherwise.
  final String _functionName;

  factory _RendererInfo(InterfaceType contextType, String functionName,
      {bool public = false}) {
    var typeBaseName = contextType.element.name;
    var rendererClassName =
        public ? 'Renderer_$typeBaseName' : '_Renderer_$typeBaseName';

    return _RendererInfo._(contextType, functionName, rendererClassName);
  }

  _RendererInfo._(
      this._contextType, this._functionName, this._rendererClassName);

  String get _typeName => _contextType.getDisplayString(withNullability: false);

  final String _rendererClassName;

  /// The type parameters of the context type, if any, as a String, including
  /// the angled brackets, otherwise a blank String.
  String get _typeParametersString {
    return _asGenerics(_contextType.element.typeParameters
        .map((tp) => tp.getDisplayString(withNullability: false)));
  }

  /// Returns the type parameters of the context type, and [extra], as they
  /// appear in a list of generics.
  String _typeParametersStringWith(String extra) {
    return _asGenerics([
      ..._contextType.element.typeParameters
          .map((tp) => tp.getDisplayString(withNullability: false)),
      extra,
    ]);
  }

  /// Returns the type parameters of the context type, and [extra], as they
  /// appear in a list of generics.
  String _typeArgumentsStringWith(String extra) {
    return _asGenerics([
      ..._contextType.typeArguments
          .map((tp) => tp.getDisplayString(withNullability: false)),
      extra,
    ]);
  }
}

/// Returns [values] as they appear in a list of generics, with angled brackets,
/// and an empty string when [values] is empty.
String _asGenerics(Iterable<String> values) =>
    values.isEmpty ? '' : '<${values.join(', ')}>';
