// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' show DartType;
import 'package:collection/collection.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/model/privacy.dart';

/// Something that has a name.
mixin Nameable implements Privacy {
  String get name;

  /// A qualified name, mostly for use in the web search functionality, and for
  /// warnings printed in the terminal; not for display use in rendered HTML.
  String get fullyQualifiedName => name;

  /// The name to use as text in the rendered documentation.
  String get displayName => name;

  /// The name to use in breadcrumbs in the rendered documentation.
  String get breadcrumbName => name;

  @override
  bool get isPublic => name.isNotEmpty && !name.startsWith('_');

  @override
  String toString() => name;

  PackageGraph get packageGraph;

  /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.for_], see its documentation.
  ModelElement getModelFor(
    Element element,
    Library library, {
    Container? enclosingContainer,
  }) =>
      ModelElement.for_(
        element,
        library,
        packageGraph,
        enclosingContainer: enclosingContainer,
      );

  /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.forElement], see its
  /// documentation.
  ModelElement getModelForElement(Element element) =>
      ModelElement.forElement(element, packageGraph);

  /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.forPropertyInducingElement], see
  /// its documentation.
  // TODO(srawlins): Most callers seem to determine `getter` and `setter`
  // immediately before calling this method, and I imagine could instead just
  // call `getModelFor`.
  ModelElement getModelForPropertyInducingElement(
    PropertyInducingElement element,
    Library library, {
    required Accessor? getter,
    required Accessor? setter,
    Container? enclosingContainer,
  }) =>
      ModelElement.forPropertyInducingElement(
        element,
        library,
        packageGraph,
        getter: getter,
        setter: setter,
        enclosingContainer: enclosingContainer,
      );

  /// Returns the [ElementType] for [type], instantiating it if needed.
  ElementType getTypeFor(DartType type, Library library) =>
      ElementType.for_(type, library, packageGraph);
}

/// Compares [a] with [b] by name.
int byName(Nameable a, Nameable b) {
  if (a is Library && b is Library) {
    return compareAsciiLowerCaseNatural(a.displayName, b.displayName);
  }

  var stringCompare = compareAsciiLowerCaseNatural(a.name, b.name);
  if (stringCompare != 0) {
    return stringCompare;
  }

  return a.hashCode.compareTo(b.hashCode);
}
