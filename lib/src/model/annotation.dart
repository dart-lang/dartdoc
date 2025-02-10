// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/element/element2.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/class.dart';
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
      : super(_annotation.element2!.name3!);

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

    return '@$linkedName${const HtmlEscape().convert(parameterText)}';
  }

  @override
  String get linkedName => _annotation.element2 is PropertyAccessorElement2
      ? _packageGraph.getModelForElement(_annotation.element2!).linkedName
      // TODO(jcollins-g): consider linking to constructor instead of type?
      : _modelType.linkedName;

  late final ElementType _modelType = switch (_annotation.element2) {
    ConstructorElement2(:var returnType) =>
      _packageGraph.getTypeFor(returnType, _library),
    PropertyAccessorElement2(:var variable3?) =>
      (_packageGraph.getModelForElement(variable3) as GetterSetterCombo)
          .modelType,
    _ => throw StateError(
        'non-callable element used as annotation?: ${_annotation.element2}')
  };

  bool get isPublic {
    final modelType = _modelType;
    if (!modelType.isPublic) {
      return false;
    }
    if (modelType is! DefinedElementType) {
      return false;
    }

    var modelElement = modelType.modelElement;
    return modelElement is Class &&
        _packageGraph.isAnnotationVisible(modelElement);
  }

  @override
  bool operator ==(Object other) =>
      other is Annotation && other._annotation == _annotation;

  @override
  int get hashCode => _annotation.hashCode;

  @override
  String get cssClassName => '';
}
