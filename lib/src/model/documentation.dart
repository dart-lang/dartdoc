// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/documentation_renderer.dart';
import 'package:dartdoc/src/tuple.dart';
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
      assert(_hasExtendedDocs == parseResult.item2);
    }
    _hasExtendedDocs = parseResult.item2;

    var renderResult = _renderer.render(parseResult.item1, processAllDocs);

    if (processAllDocs) {
      _asHtml = renderResult.item1;
    }
    _asOneLiner ??= renderResult.item2;
  }

  /// Returns a tuple of List<md.Node> and hasExtendedDocs
  Tuple2<List<md.Node>, bool> _parseDocumentation(bool processFullDocs) {
    if (!_element.hasDocumentation) {
      return Tuple2([], false);
    }
    var text = _element.documentation;
    showWarningsForGenericsOutsideSquareBracketsBlocks(text, _element);
    var document =
        MarkdownDocument.withElementLinkResolver(_element, commentRefs);
    return document.parseMarkdownText(text, processFullDocs);
  }

  DocumentationRenderer get _renderer =>
      _element.packageGraph.rendererFactory.documentationRenderer;
}
