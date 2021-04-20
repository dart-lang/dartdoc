// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/getter_setter_combo.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Represents a Dart annotation, attached to an element in the source code with
/// `@`.
class Annotation extends Feature {
  final ElementAnnotation annotation;
  final Library library;
  final PackageGraph packageGraph;

  Annotation(this.annotation, this.library, this.packageGraph)
      : super(annotation.element.name);

  String _linkedNameWithParameters;
  @override
  String get linkedNameWithParameters => _linkedNameWithParameters ??=
      packageGraph.rendererFactory.featureRenderer.renderAnnotation(this);

  /// Return the linked name of the annotation.
  @override
  String get linkedName => annotation.element is PropertyAccessorElement
      ? ModelElement.fromElement(annotation.element, packageGraph).linkedName
      // TODO(jcollins-g): consider linking to constructor instead of type?
      : modelType.linkedName;

  ElementType _modelType;
  ElementType get modelType {
    if (_modelType == null) {
      var annotatedWith = annotation.element;
      if (annotatedWith is ConstructorElement) {
        _modelType =
            ElementType.from(annotatedWith.returnType, library, packageGraph);
      } else if (annotatedWith is PropertyAccessorElement) {
        _modelType =
            (ModelElement.fromElement(annotatedWith.variable, packageGraph)
                    as GetterSetterCombo)
                .modelType;
      } else {
        assert(false,
            'non-callable element used as annotation?: ${annotation.element}');
      }
    }
    return _modelType;
  }

  String _parameterText;
  String get parameterText {
    // TODO(srawlins): Attempt to revive constructor arguments in an annotation,
    // akin to source_gen's Reviver, in order to link to inner components. For
    // example, in `@Foo(const Bar(), baz: <Baz>[Baz.one, Baz.two])`, link to
    // `Foo`, `Bar`, `Baz`, `Baz.one`, and `Baz.two`.
    if (_parameterText == null) {
      var source = annotation.toSource();
      var startIndex = source.indexOf('(');
      _parameterText =
          source.substring(startIndex == -1 ? source.length : startIndex);
    }
    return _parameterText;
  }

  @override
  bool get isPublic =>
      modelType.isPublic &&
      modelType is DefinedElementType &&
      !packageGraph.invisibleAnnotations
          .contains((modelType as DefinedElementType).modelElement);

  @override
  bool operator ==(Object other) {
    if (other is Annotation) {
      return other.annotation == annotation;
    }
    return false;
  }

  @override
  int get hashCode => annotation.hashCode;
}
