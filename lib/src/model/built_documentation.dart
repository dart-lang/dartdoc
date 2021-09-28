// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/documentation_comment.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/utils.dart';
/*
final RegExp _needsPrecacheRegExp = RegExp(r'{@(template|tool|inject-html)');

class BuiltDocumentation {

  final DocumentationComment modelElement;

  BuiltDocumentation(this.modelElement);

  @deprecated
  String buildDocumentationAddition(String docs) => docs ??= '';

  String _rawDocs;
  String _documentationLocal;
  /// Returns the documentation for this literal element unless
  /// [config.dropTextFrom] indicates it should not be returned.  Macro
  /// definitions are stripped, but macros themselves are not injected.  This
  /// is a two stage process to avoid ordering problems.
  String get documentationLocal => _documentationLocal ??= () {
    assert(_rawDocs == null,
    'reentrant calls to _buildDocumentation* not allowed');
    // Do not use the sync method if we need to evaluate tools or templates.
    assert(!modelElement.isCanonical ||
        !_needsPrecacheRegExp.hasMatch(modelElement.documentationComment ?? ''));
    if (modelElement.config.dropTextFrom.contains(modelElement.element.library.name)) {
      _rawDocs = '';
    } else {
      _rawDocs = _processCommentWithoutTools(modelElement.documentationComment ?? '');
    }
    _rawDocs = buildDocumentationAddition(_rawDocs);
    return _rawDocs;
  } ();

  /// Process a [documentationComment], performing various actions based on
  /// `{@}`-style directives, except `{@tool}`, returning the processed result.
  String _processCommentWithoutTools(String documentationComment) {
    var docs = stripComments(documentationComment);
    if (!docs.contains('{@')) {
      _analyzeCodeBlocks(docs);
      return docs;
    }
    docs = _injectExamples(docs);
    docs = _injectYouTube(docs);
    docs = _injectAnimations(docs);

    _analyzeCodeBlocks(docs);

    // TODO(srawlins): Processing templates here causes #2281. But leaving them
    // unprocessed causes #2272.
    docs = _stripHtmlAndAddToIndex(docs);
    return docs;
  }
}
*/
