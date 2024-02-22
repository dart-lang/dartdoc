// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/class.dart';
import 'package:dartdoc/src/model/getter_setter_combo.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Represents a Dart annotation, attached to an element in the source code with
/// `@`.
class Annotation extends Attribute {
  final ElementAnnotation annotation;
  final Library library;

  final PackageGraph packageGraph;

  Annotation(this.annotation, this.library, this.packageGraph)
      : super(annotation.element!.name!);

  @override
  late final String linkedNameWithParameters =
      '@$linkedName${HtmlEscape().convert(parameterText)}';

  @override
  String get linkedName => annotation.element is PropertyAccessorElement
      ? packageGraph.getModelForElement(annotation.element!).linkedName
      // TODO(jcollins-g): consider linking to constructor instead of type?
      : modelType.linkedName;

  late final ElementType modelType = switch (annotation.element) {
    ConstructorElement(:var returnType) =>
      packageGraph.getTypeFor(returnType, library),
    PropertyAccessorElement(:var variable) =>
      (packageGraph.getModelForElement(variable) as GetterSetterCombo)
          .modelType,
    _ => throw StateError(
        'non-callable element used as annotation?: ${annotation.element}')
  };

  // TODO(srawlins): Attempt to revive constructor arguments in an annotation,
  // akin to source_gen's Reviver, in order to link to inner components. For
  // example, in `@Foo(const Bar(), baz: <Baz>[Baz.one, Baz.two])`, link to
  // `Foo`, `Bar`, `Baz`, `Baz.one`, and `Baz.two`.
  /// The textual representation of the argument(s) supplied to the annotation.
  String get parameterText {
    var source = annotation.toSource();
    var startIndex = source.indexOf('(');
    return source.substring(startIndex == -1 ? source.length : startIndex);
  }

  @override
  bool get isPublic {
    final modelType = this.modelType;
    if (!modelType.isPublic) {
      return false;
    }
    if (modelType is! DefinedElementType) {
      return false;
    }

    var modelElement = modelType.modelElement;
    return modelElement is Class &&
        packageGraph.isAnnotationVisible(modelElement);
  }

  @override
  bool operator ==(Object other) =>
      other is Annotation && other.annotation == annotation;

  @override
  int get hashCode => annotation.hashCode;

  @override
  String get cssClassName => '';
}
