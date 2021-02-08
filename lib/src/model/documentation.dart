// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:markdown/markdown.dart' as md;

class Documentation {
  final Canonicalization _element;

  Documentation.forElement(this._element);

  bool _hasExtendedDocs;

  bool get hasExtendedDocs {
    if (_hasExtendedDocs == null) {
      _renderDocumentation(_element.isCanonical && _asHtml == null);
    }
    return _hasExtendedDocs;
  }

  String _asHtml;

  String get asHtml {
    if (_asHtml == null) {
      assert(_asOneLiner == null || _element.isCanonical);
      _renderDocumentation(true);
    }
    return _asHtml;
  }

  String _asOneLiner;

  String get asOneLiner {
    if (_asOneLiner == null) {
      assert(_asHtml == null);
      _renderDocumentation(_element.isCanonical);
    }
    return _asOneLiner;
  }

  List<ModelCommentReference> get commentRefs => _element.commentRefs;

  void _renderDocumentation(bool processAllDocs) {
    var parseResult = _parseDocumentation(processAllDocs);
    if (_hasExtendedDocs != null) {
      assert(_hasExtendedDocs == parseResult.hasExtendedDocs);
    }
    _hasExtendedDocs = parseResult.hasExtendedDocs;

    var renderResult = _renderer.render(parseResult.nodes, processAllDocs);

    if (processAllDocs) {
      _asHtml = renderResult.asHtml;
    }
    _asOneLiner ??= renderResult.asOneLiner;
  }

  /// Parses the documentation, collecting the first [md.Node] or all of them
  /// if [processFullDocs] is `true`. If more than one node is present,
  /// then [DocumentationParseResult.hasExtendedDocs] will be set to `true`.
  DocumentationParseResult _parseDocumentation(bool processFullDocs) {
    final text = _element.documentation;
    if (text == null || text.isEmpty) {
      return DocumentationParseResult.empty;
    }
    showWarningsForGenericsOutsideSquareBracketsBlocks(text, _element);
    var document =
        MarkdownDocument.withElementLinkResolver(_element, commentRefs);
    return document.parseMarkdownText(text, processFullDocs);
  }

  DocumentationRenderer get _renderer =>
      _element.packageGraph.rendererFactory.documentationRenderer;
}
