// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

class NeverType extends ModelElement with HasNoPage {
  @override
  final Element2 element;

  NeverType(this.element, PackageGraph packageGraph)
      : super(Library.sentinel, packageGraph);

  /// `Never` is not a real object, and so we can't document it, so there
  /// can be nothing canonical for it.
  @override
  ModelElement? get canonicalModelElement => null;

  @override
  ModelElement? get enclosingElement => null;

  /// The `Never` type has no hyperlink.
  @override
  String? get href => null;

  @override
  Kind get kind => Kind.never;

  @override
  String get linkedName => 'Never';

  @override
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  Iterable<CommentReferable> get referenceParents => const [];
}
