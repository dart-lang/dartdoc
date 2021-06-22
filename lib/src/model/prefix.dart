// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/library.dart';

import '../../dartdoc.dart';

/// Represents a [PrefixElement] for dartdoc.
///
/// Like [Parameter], it doesn't have doc pages, but participates in lookups.
class Prefix extends ModelElement implements EnclosedElement {
  /// [library] is the library the prefix is defined in, not the [Library]
  /// referred to by the [PrefixElement].
  Prefix(PrefixElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  bool get isCanonical => false;

  Library get associatedLibrary => ModelElement.fromElement(element.reference.parent.parent.element, packageGraph);

  @override
  Library get canonicalModelElement => associatedLibrary.canonicalLibrary;

  @override
  Scope get scope => element.scope;

  @override
  PrefixElementImpl get element => super.element;

  @override
  ModelElement get enclosingElement => library;

  @override
  String get filePath =>
      throw UnimplementedError('prefixes have no generated files in dartdoc');

  @override
  String get href => null;

  @override
  String get kind => 'prefix';

  @override
  Map<String, CommentReferable> get referenceChildren => {};

  @override
  Iterable<CommentReferable> get referenceParents => [definingLibrary];
}
