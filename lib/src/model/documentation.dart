// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:markdown/markdown.dart' as md;

class Documentation {
  final Canonicalization _element;

  Documentation.forElement(this._element);

  /// The documentation text, rendered with the appropriate
  /// [DocumentationRenderer].
  late final String _asHtml;

  /// The first sentence of the documentation text, rendered with the
  /// appropriate [DocumentationRenderer].
  late final String _asOneLiner;

  /// A guard against re-computing [_asHtml].
  bool _hasHtmlBeenRendered = false;

  /// A guard against re-computing [_asHOneLiner].
  bool _hasOneLinerBeenRendered = false;

  String get asHtml {
    if (_hasHtmlBeenRendered) {
      return _asHtml;
    }
    if (_hasOneLinerBeenRendered) {
      // Since [_asHtml] and [_asOneLiner] _could_ have been set in
      // [asOneLiner], we guard here against setting [asOneLiner] but not
      // setting [asHtml] (unless [_element] is not canonical). It's an awkward
      // situation where one public getter might set both fields, but might only
      // set one. We have this awkward check to make sure we set both fields if
      // we'll need both fields.
      assert(_element.isCanonical);
      return _asHtml;
    }

    _renderDocumentation(storeFullText: true);
    _hasHtmlBeenRendered = true;
    return _asHtml;
  }

  String get asOneLiner {
    if (_hasOneLinerBeenRendered || _hasHtmlBeenRendered) {
      return _asOneLiner;
    }
    _renderDocumentation(storeFullText: _element.isCanonical);
    _hasOneLinerBeenRendered = true;
    return _asOneLiner;
  }

  void _renderDocumentation({required bool storeFullText}) {
    var parseResult = _parseDocumentation(processFullText: storeFullText);

    var renderResult = _renderer.render(parseResult,
        processFullDocs: storeFullText,
        sanitizeHtml: _element.config.sanitizeHtml);

    if (storeFullText) {
      _asHtml = renderResult.asHtml;
    }
    _asOneLiner = renderResult.asOneLiner;
  }

  List<md.Node> _parseDocumentation({required bool processFullText}) {
    final text = _element.documentation;
    if (text == null || text.isEmpty) {
      return const [];
    }
    showWarningsForGenericsOutsideSquareBracketsBlocks(
        text, _element as Warnable);
    var document =
        MarkdownDocument.withElementLinkResolver(_element as Warnable);
    return document.parseMarkdownText(text, processFullText: processFullText);
  }

  DocumentationRenderer get _renderer =>
      _element.packageGraph.rendererFactory.documentationRenderer;
}
