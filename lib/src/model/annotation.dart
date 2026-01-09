// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/getter_setter_combo.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Represents a Dart annotation, attached to an element in the source code with
/// `@`.
final class Annotation extends Attribute {
  final ElementAnnotation _annotation;

  final Library _library;

  final PackageGraph _packageGraph;

  Annotation(this._annotation, this._library, this._packageGraph)
      : super(_annotation.element!.name!);

  @override
  String get linkedNameWithParameters {
    var source = _annotation.toSource();
    var startIndex = source.indexOf('(');

    // TODO(srawlins): Attempt to revive constructor arguments in an annotation,
    // akin to source_gen's Reviver, in order to link to inner components. For
    // example, in `@Foo(const Bar(), baz: <Baz>[Baz.one, Baz.two])`, link to
    // `Foo`, `Bar`, `Baz`, `Baz.one`, and `Baz.two`.
    var parameterText =
        source.substring(startIndex == -1 ? source.length : startIndex);

    var escapedParameterText = const HtmlEscape().convert(parameterText);
    return '@$linkedName$_linkedTypeArguments$escapedParameterText';
  }

  @override
  String get linkedName => switch (_annotation.element) {
        PropertyAccessorElement element =>
          _packageGraph.getModelForElement(element).linkedName,
        ConstructorElement element =>
          _packageGraph.getModelForElement(element).linkedName,
        _ => _modelType.linkedName
      };

  /// The linked type argument text, with `<` and `>`, if there are any type
  /// arguments.
  String get _linkedTypeArguments {
    if (_annotation.element is PropertyAccessorElement) {
      return '';
    }

    var type = _modelType.type;
    if (type is! InterfaceType) {
      return '';
    }

    var typeArguments = type.typeArguments;
    if (typeArguments.isEmpty) {
      return '';
    }

    var buffer = StringBuffer();
    buffer.write('&lt;');
    for (var t in typeArguments) {
      buffer.write(_packageGraph.getTypeFor(t, _library).linkedName);
      if (t != typeArguments.last) {
        buffer.write(', ');
      }
    }
    buffer.write('&gt;');
    return buffer.toString();
  }

  late final ElementType _modelType = switch (_annotation.element) {
    ConstructorElement(:var returnType) =>
      _packageGraph.getTypeFor(returnType, _library),
    PropertyAccessorElement(:var variable) =>
      (_packageGraph.getModelForElement(variable) as GetterSetterCombo)
          .modelType,
    _ => throw StateError(
        'non-callable element used as annotation?: ${_annotation.element}')
  };

  // We only construct Annotations which are public, as per
  // [ModelElement.annotations].
  bool get isPublic => true;

  @override
  bool operator ==(Object other) =>
      other is Annotation && other._annotation == _annotation;

  @override
  int get hashCode => _annotation.hashCode;

  @override
  String get cssClassName => '';
}
