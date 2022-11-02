// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// Returns the 'element' for this type, which is sometimes `null`.
  TypeDefiningElement? get element {
    final self = this;
    if (self is InterfaceType) {
      return self.element;
    } else if (self is NeverType) {
      return self.element as TypeDefiningElement;
    } else if (self is TypeParameterType) {
      return self.element;
    } else {
      // Remaining cases like `DynamicType`, `FunctionType`, `RecordType`, and
      // `VoidType`.
      return null;
    }
  }
}
