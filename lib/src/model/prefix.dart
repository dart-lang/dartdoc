// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

/// Represents a [PrefixElement] for dartdoc.
///
/// Like [Parameter], it doesn't have doc pages, but participates in lookups.
/// Forwards to its referenced library if referred to directly.
class Prefix extends ModelElement with HasLibrary, HasNoPage {
  @override
  final PrefixElement element;

  /// [library] is the library the prefix is defined in, not the [Library]
  /// referred to by the [PrefixElement].
  Prefix(this.element, Library super.library, super.packageGraph);

  @override
  bool get isCanonical => false;

  /// The library this prefix refers to, or `null` if the prefix doesn't map to
  /// exactly one library.
  ///
  /// The prefix can come from a regular import or from a doc import. A prefix
  /// shared by several imports is ambiguous as a library reference; the
  /// analyzer reports it as `ambiguous_comment_reference`.
  late final Library? associatedLibrary = switch (element.scopeLibraries) {
    [var single] => getModelForElement(single) as Library,
    _ => null,
  };

  @override
  Library? get canonicalModelElement => associatedLibrary?.canonicalLibrary;

  @override
  Scope get scope => element.scope;

  @override
  ModelElement get enclosingElement => library;

  @override
  String? get href => canonicalModelElement?.href;

  @override
  Kind get kind => Kind.prefix;

  @override
  Map<String, Referable> get referenceChildren => {};

  @override
  Iterable<Referable> get referenceParents => [library];
}
