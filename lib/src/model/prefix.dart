// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

/// Represents a [PrefixElement] for dartdoc.
///
/// Like [Parameter], it doesn't have doc pages, but participates in lookups.
/// Forwards to its referenced library if referred to directly.
class Prefix extends ModelElement with HasNoPage implements EnclosedElement {
  @override
  final PrefixElement element;

  /// [library] is the library the prefix is defined in, not the [Library]
  /// referred to by the [PrefixElement].
  Prefix(this.element, super.library, super.packageGraph);

  @override
  bool get isCanonical => false;

  // TODO(jcollins-g): consider connecting PrefixElement to the imported library
  // in analyzer?
  late final Library associatedLibrary = modelBuilder.fromElement(library
      .element.libraryImports
      .firstWhere((i) => i.prefix?.element == element)
      .importedLibrary!) as Library;

  @override
  Library? get canonicalModelElement => associatedLibrary.canonicalLibrary;

  @override
  Scope get scope => element.scope;

  @override
  ModelElement get enclosingElement => library;

  @override
  String? get href => canonicalModelElement?.href;

  @override
  String get kind => 'prefix';

  @override
  Map<String, CommentReferable> get referenceChildren => {};

  @override
  Iterable<CommentReferable> get referenceParents => [definingLibrary];
}
