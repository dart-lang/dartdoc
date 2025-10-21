// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// The static element associated with this type, where documentable, and
  /// `null` otherwise.
  ///
  /// For example, the documentable element of [DynamicType] is `null`, as there
  /// is no documentation for `dynamic` which we can link to.
  Element? get documentableElement {
    final self = this;
    return switch (self) {
      InterfaceType() => self.element,
      NeverType() => self.element,
      TypeParameterType() => self.element,
      _ => null
    };
  }
}
