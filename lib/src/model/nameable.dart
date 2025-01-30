// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: analyzer_use_new_elements

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart' show DartType;
// ignore: implementation_imports
import 'package:analyzer/src/utilities/extensions/element.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';

/// Something that has a name.
mixin Nameable {
  String get name;

  /// A "fully" qualified name, used for things like for warnings printed in the
  /// terminal; not for display use in rendered HTML.
  ///
  /// "Fully" means the name is qualified through the library. For example, a
  /// method named 'baz' in a class named 'Bar' in a library named 'foo' has a
  /// fully qualified name of 'foo.Bar.baz'.
  ///
  /// As dartdoc can document multiple packages at once, note that such
  /// qualifying names may not be unique across all documented packages.
  String get fullyQualifiedName => name;

  /// The name to use as text in the rendered documentation.
  String get displayName => name;

  /// The name to use in breadcrumbs in the rendered documentation.
  String get breadcrumbName => name;

  /// Whether this is "package-public."
  ///
  /// A "package-public" element satisfies the following requirements:
  /// * is not documented with the `@nodoc` directive,
  /// * for a library, adheres to the documentation for [Library.isPublic],
  /// * for a library member, is in a _public_ library's exported namespace, and
  ///   is not privately named, nor an unnamed extension,
  /// * for a container (class, enum, extension, extension type, mixin) member,
  ///   is in a _public_ container, and is not privately named.
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
  /// A convenience method for [ModelElement.for_], see its documentation.
  ModelElement getModelFor2(
    Element2 element,
    Library library, {
    Container? enclosingContainer,
  }) =>
      ModelElement.for_(
        element.asElement!,
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
  /// A convenience method for [ModelElement.forElement], see its
  /// documentation.
  ModelElement getModelForElement2(Element2 element) =>
      ModelElement.forElement(element.asElement!, packageGraph);

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

      /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.forPropertyInducingElement], see
  /// its documentation.
  // TODO(srawlins): Most callers seem to determine `getter` and `setter`
  // immediately before calling this method, and I imagine could instead just
  // call `getModelFor`.
  ModelElement getModelForPropertyInducingElement2(
    PropertyInducingElement2 element,
    Library library, {
    required Accessor? getter,
    required Accessor? setter,
    Container? enclosingContainer,
  }) =>
      ModelElement.forPropertyInducingElement(
        element.asElement as PropertyInducingElement,
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
