// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:markdown/markdown.dart' as md;

class Documentation {
  final Warnable _warnable;

  Documentation.forElement(this._warnable);

  /// The documentation text, rendered with the appropriate
  /// [DocumentationRenderer].
  String? _asHtml;

  /// The first sentence of the documentation text, rendered with the
  /// appropriate [DocumentationRenderer].
  String? _asOneLiner;

  bool _fullTextRendered = false;

  String get asHtml {
    if (_fullTextRendered) {
      return _asHtml!;
    }

    _renderDocumentation(storeFullText: true);
    return _asHtml!;
  }

  String get asOneLiner {
    if (_asOneLiner != null) {
      return _asOneLiner!;
    }
    _renderDocumentation(storeFullText: _warnable.isCanonical);
    return _asOneLiner!;
  }

  void _renderDocumentation({required bool storeFullText}) {
    if (storeFullText && _fullTextRendered) return;
    if (!storeFullText && _asOneLiner != null) return;

    var parseResult = _parseDocumentation(processFullText: storeFullText);

    var renderResult = _renderer.render(parseResult,
        processFullDocs: storeFullText,
        sanitizeHtml: _warnable.config.sanitizeHtml);

    if (storeFullText) {
      _asHtml = renderResult.asHtml;
      _fullTextRendered = true;
    }
    _asOneLiner = renderResult.asOneLiner;
  }

  List<md.Node> _parseDocumentation({required bool processFullText}) {
    final text = _warnable.documentation;
    if (text == null || text.isEmpty) {
      return const [];
    }
    showWarningsForGenericsOutsideSquareBracketsBlocks(text, _warnable);
    var document = MarkdownDocument.withElementLinkResolver(_warnable);
    return document.parseMarkdownText(text, processFullText: processFullText);
  }

  DocumentationRenderer get _renderer => const DocumentationRendererHtml();
}
