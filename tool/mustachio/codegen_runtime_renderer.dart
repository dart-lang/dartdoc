// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dart_style/dart_style.dart';

/// The specification of a renderer, as derived from a @Renderer annotation.
class RendererSpec {
  /// The name of the render function.
  final String _name;

  final InterfaceType _contextType;

  RendererSpec(this._name, this._contextType);
}

/// Builds [specs] into a Dart library containing runtime renderers.
String buildTemplateRenderers(Set<RendererSpec> specs) {
  var raw = RuntimeRenderersBuilder()._buildTemplateRenderers(specs);
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

  RuntimeRenderersBuilder();

  String _buildTemplateRenderers(Set<RendererSpec> specs) {
    // TODO(srawlins): There are some private renderer functions that are
    // unused. Figure out if we can detect these statically, and then not
    // generate them.
    // TODO(srawlins): To really get the correct list of imports, we need to use
    // the code_builder package.
    _buffer.writeln('''
// ignore_for_file: camel_case_types, unused_element
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
''');

    specs.forEach(_addTypesForRendererSpec);

    while (_typesToProcess.isNotEmpty) {
      var info = _typesToProcess.removeFirst();

      _typeToRenderFunctionName[info._contextType] = info._functionName;
      _typeToRendererClassName[info._contextType] = info._rendererClassName;
      _buildRenderer(info);
    }

    return _buffer.toString();
  }

  void _addTypesForRendererSpec(RendererSpec spec) {
    var element = spec._contextType.element;
    _typesToProcess.add(_RendererInfo(element.thisType, spec._name));
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
    var typeName = type.element.name;
    var rendererName = '_render_$typeName';
    var typeToProcess = _typesToProcess
        .singleWhere((rs) => rs._contextType == type, orElse: () => null);
    if (typeToProcess == null) {
      return _typesToProcess.add(_RendererInfo(type, rendererName));
    }
  }

  /// Builds both the render function and the renderer class for [renderer].
  ///
  /// The function and the class are each written as Dart code to [_buffer].
  void _buildRenderer(_RendererInfo renderer) {
    var typeName = renderer._typeName;
    _buffer.writeln('''
String ${renderer._functionName}${renderer._typeParametersString}(
    $typeName context, List<MustachioNode> ast) {
  var renderer = ${renderer._rendererClassName}(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}
''');

    _buffer.write('''
class ${renderer._rendererClassName}${renderer._typeParametersString}
    extends RendererBase<$typeName> {
  ${renderer._rendererClassName}($typeName context) : super(context);
}
''');
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

  _RendererInfo(this._contextType, this._functionName);

  String get _typeName => _contextType.getDisplayString(withNullability: false);

  /// The name of the context type, without any type parameters, type arguments,
  /// or nullability tokens.
  String get _typeBaseName => _contextType.element.name;

  String get _rendererClassName => '_Renderer_$_typeBaseName';

  /// The type parameters of the context type, if any, as a String, including
  /// the angled brackets.
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
}
