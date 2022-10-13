// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';

abstract class ModelObjectBuilder
    implements ModelElementBuilder, ElementTypeBuilder {}

abstract class ModelElementBuilder {
  ModelElement from(Element e, Library library,
      {Container? enclosingContainer});

  ModelElement fromElement(Element e);

  ModelElement fromPropertyInducingElement(Element e, Library l,
      {required Accessor? getter,
      required Accessor? setter,
      Container enclosingContainer});
}

abstract class ElementTypeBuilder {
  ElementType typeFrom(DartType f, Library library);
}

abstract class ModelBuilderInterface {
  /// Override implementations in unit tests to avoid requiring literal
  /// [ModelElement]s.
  ModelObjectBuilder get modelBuilder;
}

class ModelObjectBuilderImpl extends ModelObjectBuilder
    with ModelElementBuilderImpl, ElementTypeBuilderImpl {
  @override
  final PackageGraph packageGraph;

  ModelObjectBuilderImpl(this.packageGraph);
}

/// Default implementation of [ModelBuilderInterface], requiring a
/// [PackageGraph].
mixin ModelBuilder implements ModelBuilderInterface {
  PackageGraph get packageGraph;

  @override
  late final ModelObjectBuilder modelBuilder =
      ModelObjectBuilderImpl(packageGraph);
}
