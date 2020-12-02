// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
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
String buildTemplateRenderers(
    Set<RendererSpec> specs, Uri sourceUri, TypeProvider typeProvider,
    {bool rendererClassesArePublic = false}) {
  var raw = RuntimeRenderersBuilder(sourceUri, typeProvider,
          rendererClassesArePublic: rendererClassesArePublic)
      ._buildTemplateRenderers(specs);
  return DartFormatter().format(raw.toString());
}

/// This class builds runtime Mustache renderers from a set of [RendererSpec]s.
class RuntimeRenderersBuilder {
  final _buffer = StringBuffer();

  /// A queue of types to process, in order to find all types for which we need
  /// to build renderers.
  final _typesToProcess = Queue<_RendererInfo>();

  /// Maps a type to the name of the render function which can render that type
  /// as a context type.
  final _typeToRenderFunctionName = <InterfaceType, String>{};

  /// Maps a type to the name of the renderer class which can render that type
  /// as a context type.
  final _typeToRendererClassName = <InterfaceType, String>{};

  final Uri _sourceUri;

  final TypeProvider _typeProvider;

  /// Whether renderer classes are public. This should only be true for testing.
  final bool _rendererClassesArePublic;

  RuntimeRenderersBuilder(this._sourceUri, this._typeProvider,
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
    _typeToRenderFunctionName[element.thisType] = spec._name;
    _typeToRendererClassName[element.thisType] = element.name;

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
      _typeToRenderFunctionName[type] = renderFunctionName;
      _typeToRendererClassName[type] = rendererInfo._rendererClassName;
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
    var actionMapName = 'propertyMap${renderer._typeArgumentsString}';
    // Write out `getProperty`.
    _buffer.writeln('''
  @override
  Property<Object> getProperty(String key) {
    if ($actionMapName().containsKey(key)) {
      return $actionMapName()[key];
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
    _buffer.writeln('static Map<String, Property> '
        'propertyMap${renderer._typeParametersString}() => {');
    for (var property in [...type.accessors]
      ..sort((a, b) => a.name.compareTo(b.name))) {
      _writeProperty(renderer, property);
    }
    if (type.superclass != null) {
      var superclassRendererName =
          _typeToRendererClassName[type.superclass.element.thisType];
      var superMapName = '$superclassRendererName.propertyMap';
      if (type.superclass.typeArguments.isNotEmpty) {
        var superTypeArguments = type.superclass.typeArguments
            .map((e) => e.getDisplayString(withNullability: false))
            .join(', ');
        superMapName += '<$superTypeArguments>';
      }
      _buffer.writeln('    ...$superMapName(),');
    }
    _buffer.writeln('};');
    _buffer.writeln('');
  }

  void _writeProperty(
      _RendererInfo renderer, PropertyAccessorElement property) {
    var getterType = property.type.returnType;
    if (getterType == _typeProvider.typeType) {
      // The [Type] type is the first case of a type we don't want to traverse.
      return;
    }
    var typeName = renderer._typeName;

    if (property.isPrivate || property.isStatic || property.isSetter) return;
    _buffer.writeln("'${property.name}': Property(");
    _buffer
        .writeln('getValue: (Object c) => (c as $typeName).${property.name},');

    var getterName = property.name;

    // Only add a `getProperties` function, which returns the property map for
    // [getterType], if [getterType] is a renderable type.
    if (_typeToRendererClassName.containsKey(getterType)) {
      var rendererClassName = _typeToRendererClassName[getterType];
      _buffer.writeln('getProperties: $rendererClassName.propertyMap,');
    }

    if (getterType.isDartCoreBool) {
      _buffer.writeln(
          'getBool: (Object c) => (c as $typeName).$getterName == true,');
    } else {
      // TODO(srawlins): Check if type is Iterable, and add functions for such.
      // TODO(srawlins): Otherwise, add functions for plain values.
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
    var typeParamters = _contextType.element.typeParameters;
    if (typeParamters.isEmpty) {
      return '';
    } else {
      var parameterStrings = typeParamters.map((tp) {
        return tp.getDisplayString(withNullability: false);
      });
      return '<${parameterStrings.join(', ')}>';
    }
  }

  /// The type arguments, if any, of [_contextType], as a String, including the
  /// angled brackets, otherwise a blank String.
  String get _typeArgumentsString {
    if (_contextType.typeArguments.isEmpty) {
      return '';
    } else {
      var typeArguments = _contextType.typeArguments
          .map((t) => t.getDisplayString(withNullability: false));
      return '<${typeArguments.join(', ')}>';
    }
  }
}
