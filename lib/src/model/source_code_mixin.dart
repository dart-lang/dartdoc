// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/model/model.dart';

abstract class SourceCodeMixin implements Documentable {
  ModelNode get modelNode;

  CharacterLocation get characterLocation;

  Element get element;

  bool get hasSourceCode => config.includeSource && sourceCode.isNotEmpty;

  Library get library;

  String get sourceCode => modelNode == null ? '' : modelNode.sourceCode;
}
