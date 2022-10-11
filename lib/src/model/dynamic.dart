// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class Dynamic extends ModelElement with HasNoPage {
  @override
  final Element element;

  Dynamic(this.element, PackageGraph packageGraph)
      : super(Library.sentinel, packageGraph);

  UndefinedElementType get modelType =>
      throw UnimplementedError('(${element.runtimeType}) $element');

  /// `dynamic` is not a real object, and so we can't document it, so there
  /// can be nothing canonical for it.
  @override
  ModelElement? get canonicalModelElement => null;

  @override
  ModelElement? get enclosingElement => null;

  /// `dynamic` has no hyperlink.
  @override
  String? get href => null;

  @override
  String get kind => 'dynamic';

  @override
  String get linkedName => 'dynamic';

  @override
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  Iterable<CommentReferable> get referenceParents => const [];

  @override
  bool operator ==(Object other) => other is Dynamic;

  @override
  int get hashCode => 31415;
}
