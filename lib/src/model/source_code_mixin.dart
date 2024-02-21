// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/model/model.dart';

mixin SourceCode implements Documentable {
  ModelNode? get modelNode;

  CharacterLocation? get characterLocation;

  Element? get element;

  bool get hasSourceCode =>
      config.includeSource && !element.isAugmentation && sourceCode.isNotEmpty;

  Library? get library;

  String get sourceCode {
    var modelNode = this.modelNode;
    return modelNode == null ? '' : modelNode.sourceCode;
  }
}

extension on Element? {
  /// Whether `this` is an augmentation method or property.
  ///
  /// This property should only be referenced for elements whose source code we
  /// may wish to refer to.
  bool get isAugmentation {
    final self = this;
    return switch (self) {
      ExecutableElement() => self.augmentationTarget != null,
      PropertyInducingElement() => self.augmentationTarget != null,
      _ => false,
    };
  }
}
