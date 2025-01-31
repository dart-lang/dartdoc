// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/model/model.dart';

mixin SourceCode implements Documentable {
  ModelNode? get modelNode;

  CharacterLocation? get characterLocation;

  bool get hasSourceCode => config.includeSource && sourceCode.isNotEmpty;

  Library? get library;

  String get sourceCode {
    var modelNode = this.modelNode;
    return modelNode == null ? '' : modelNode.sourceCode;
  }
}
