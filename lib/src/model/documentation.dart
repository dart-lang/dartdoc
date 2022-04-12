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

  String? _asHtml;

  String? get asHtml {
    if (_asHtml == null) {
      assert(_asOneLiner == null || _element.isCanonical);
      _renderDocumentation(true);
    }
    return _asHtml;
  }

  String? _asOneLiner;

  String? get asOneLiner {
    if (_asOneLiner == null) {
      assert(_asHtml == null);
      _renderDocumentation(_element.isCanonical);
    }
    return _asOneLiner;
  }

  void _renderDocumentation(bool processFullDocs) {
    var parseResult = _parseDocumentation(processFullDocs);

    var renderResult = _renderer.render(parseResult,
        processFullDocs: processFullDocs,
        sanitizeHtml: _element.config.sanitizeHtml);

    if (processFullDocs) {
      _asHtml = renderResult.asHtml;
    }
    _asOneLiner ??= renderResult.asOneLiner;
  }

  List<md.Node> _parseDocumentation(bool processFullDocs) {
    final text = _element.documentation;
    if (text == null || text.isEmpty) {
      return const [];
    }
    showWarningsForGenericsOutsideSquareBracketsBlocks(
        text, _element as Warnable);
    var document =
        MarkdownDocument.withElementLinkResolver(_element as Warnable);
    return document.parseMarkdownText(text, processFullDocs);
  }

  DocumentationRenderer get _renderer =>
      _element.packageGraph.rendererFactory.documentationRenderer;
}
