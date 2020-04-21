// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';

class NeverType extends ModelElement {
  NeverType(Element element, PackageGraph packageGraph)
      : super(element, null, packageGraph, null);

  /// `Never` is not a real object, and so we can't document it, so there
  /// can be nothing canonical for it.
  @override
  ModelElement get canonicalModelElement => null;

  @override
  ModelElement get enclosingElement => throw UnsupportedError('');

  /// And similiarly, even if someone references it directly it can have
  /// no hyperlink.
  @override
  String get href => null;

  @override
  String get kind => 'Never';

  @override
  String get linkedName => 'Never';

  @override
  String get filePath => null;
}
