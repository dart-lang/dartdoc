// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: analyzer_use_new_elements

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// The static element associataed with this type, where documentable, and
  /// `null` otherwise.
  ///
  /// For example, the documentable element of [DynamicType] is `null`, as there
  /// is no documentation for `dynamic` which we can link to.
  TypeDefiningElement? get documentableElement {
    final self = this;
    return switch (self) {
      InterfaceType() => self.element,
      NeverType() => self.element as TypeDefiningElement,
      TypeParameterType() => self.element,
      _ => null
    };
  }

  /// The static element associataed with this type, where documentable, and
  /// `null` otherwise.
  ///
  /// For example, the documentable element of [DynamicType] is `null`, as there
  /// is no documentation for `dynamic` which we can link to.
  TypeDefiningElement2? get documentableElement2 {
    final self = this;
    return switch (self) {
      InterfaceType() => self.element3,
      NeverType() => self.element3 as TypeDefiningElement2,
      TypeParameterType() => self.element3,
      _ => null
    };
  }
}
