// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
// ignore: implementation_imports
import 'package:analyzer/src/utilities/extensions/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

class Dynamic extends ModelElement with HasNoPage {
  @override
   // ignore: analyzer_use_new_elements
   Element get element => element2.asElement!;

   @override
   final Element2 element2;

  Dynamic(this.element2, PackageGraph packageGraph)
      : super(Library.sentinel, packageGraph);

  UndefinedElementType get modelType =>
      throw UnimplementedError('(${element2.runtimeType}) $element2');

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
  Kind get kind => Kind.dynamic;

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
