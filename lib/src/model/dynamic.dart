// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class Dynamic extends ModelElement {
  Dynamic(Element element, PackageGraph packageGraph)
      : super(element, null, packageGraph);

  UndefinedElementType get modelType =>
      throw UnimplementedError('(${element.runtimeType}) $element');

  /// [dynamic] is not a real object, and so we can't document it, so there
  /// can be nothing canonical for it.
  @override
  ModelElement get canonicalModelElement => null;

  @override
  ModelElement get enclosingElement => null;

  /// And similarly, even if someone references it directly it can have
  /// no hyperlink.
  @override
  String get href => null;

  @override
  String get kind => 'dynamic';

  @override
  String get linkedName => 'dynamic';

  @override
  String get filePath => null;

  @override
  Map<String, CommentReferable> get referenceChildren => {};

  @override
  Iterable<CommentReferable> get referenceParents => [];

  @override
  bool operator ==(Object other) => other is Dynamic;

  @override
  int get hashCode => 31415;
}
