// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/getter_setter_combo.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Represents a Dart annotation, attached to an element in the source code with
/// `@`.
class Annotation extends Feature with ModelBuilder {
  final ElementAnnotation annotation;
  final Library library;

  @override
  final PackageGraph packageGraph;

  Annotation(this.annotation, this.library, this.packageGraph)
      : super(annotation.element!.name!);

  @override
  late final String linkedNameWithParameters =
      packageGraph.rendererFactory.featureRenderer.renderAnnotation(this);

  @override
  String get linkedName => annotation.element is PropertyAccessorElement
      ? modelBuilder.fromElement(annotation.element!).linkedName
      // TODO(jcollins-g): consider linking to constructor instead of type?
      : modelType.linkedName;

  late final ElementType modelType = () {
    var annotatedWith = annotation.element;
    if (annotatedWith is ConstructorElement) {
      return modelBuilder.typeFrom(annotatedWith.returnType, library);
    } else if (annotatedWith is PropertyAccessorElement) {
      return (modelBuilder.fromElement(annotatedWith.variable)
              as GetterSetterCombo)
          .modelType;
    } else {
      throw StateError(
          'non-callable element used as annotation?: ${annotation.element}');
    }
  }();

  // TODO(srawlins): Attempt to revive constructor arguments in an annotation,
  // akin to source_gen's Reviver, in order to link to inner components. For
  // example, in `@Foo(const Bar(), baz: <Baz>[Baz.one, Baz.two])`, link to
  // `Foo`, `Bar`, `Baz`, `Baz.one`, and `Baz.two`.
  /// The textual representation of the argument(s) supplied to the annotation.
  late final String parameterText = () {
    var source = annotation.toSource();
    var startIndex = source.indexOf('(');
    return source.substring(startIndex == -1 ? source.length : startIndex);
  }();

  @override
  bool get isPublic =>
      modelType.isPublic &&
      modelType is DefinedElementType &&
      !packageGraph.invisibleAnnotations
          .contains((modelType as DefinedElementType).modelElement);

  @override
  bool operator ==(Object other) =>
      other is Annotation && other.annotation == annotation;

  @override
  int get hashCode => annotation.hashCode;

  @override
  String get cssClassName => '';
}
