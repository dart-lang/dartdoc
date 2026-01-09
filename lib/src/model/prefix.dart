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

  // TODO(jcollins-g): consider connecting PrefixElement to the imported library
  // in analyzer?
  late final Library associatedLibrary =
      getModelForElement(_importedLibraryElement) as Library;

  LibraryElement get _importedLibraryElement {
    final importLists =
        library.element.fragments.map((fragment) => fragment.libraryImports);
    var libraryImport = importLists
        .expand((import) => import)
        .firstWhere((i) => i.prefix?.element == element);
    var importedLibrary = libraryImport.importedLibrary;
    if (importedLibrary == null) {
      var message = 'Unexpected null LibraryElement2 for imported library at '
          '${library.element.firstFragment.source.uri}, at offset '
          '${libraryImport.importKeywordOffset}';
      var directiveUri = libraryImport.uri;
      if (directiveUri is DirectiveUriWithRelativeUriString) {
        message += 'for import URI: "${directiveUri.relativeUriString}"';
      }
      throw StateError(message);
    }
    return importedLibrary;
  }

  @override
  Library? get canonicalModelElement => associatedLibrary.canonicalLibrary;

  @override
  Scope get scope => element.scope;

  @override
  ModelElement get enclosingElement => library;

  @override
  String? get href => canonicalModelElement?.href;

  @override
  Kind get kind => Kind.prefix;

  @override
  Map<String, Nameable> get referenceChildren => {};

  @override
  Iterable<Nameable> get referenceParents => [library];
}
