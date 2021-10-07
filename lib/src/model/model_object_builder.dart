// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:meta/meta.dart';

abstract class ModelObjectBuilder {
  ModelElement from(Element e, Library library, {Container enclosingContainer});

  ModelElement fromElement(Element e);

  ModelElement fromPropertyInducingElement(Element e, Library l,
      {Container enclosingContainer,
      @required Accessor getter,
      @required Accessor setter});
}

abstract class ModelBuilderInterface {
  /// Override implementations in unit tests to avoid requiring literal
  /// [ModelElement]s.
  ModelObjectBuilder get modelBuilder;
}

/// Default implementation of the ModelBuilderInterface, requiring a
/// [PackageGraph].
mixin ModelBuilder implements ModelBuilderInterface {
  PackageGraph get packageGraph;

  ModelObjectBuilder _modelBuilder;
  @override
  ModelObjectBuilder get modelBuilder =>
      _modelBuilder ??= ModelElementBuilderImpl(packageGraph);
}
