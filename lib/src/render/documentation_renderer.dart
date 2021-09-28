// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

abstract class DocumentationRenderer {
  DocumentationRenderResult render(
    List<md.Node> nodes, {
    required bool processFullDocs,
  });
}

class DocumentationRendererHtml implements DocumentationRenderer {
  const DocumentationRendererHtml();

  @override
  DocumentationRenderResult render(
    List<md.Node> nodes, {
    required bool processFullDocs,
  }) {
    if (nodes.isEmpty) {
      return DocumentationRenderResult.empty;
    }
    var rawHtml = md.HtmlRenderer().render(nodes);
    var asHtmlDocument = parse(rawHtml);
    for (var s in asHtmlDocument.querySelectorAll('script')) {
      s.remove();
    }
    for (var pre in asHtmlDocument.querySelectorAll('pre')) {
      if (pre.children.length > 1 && pre.children.first.localName != 'code') {
        continue;
      }

      if (pre.children.isNotEmpty && pre.children.first.localName == 'code') {
        var code = pre.children.first;
        pre.classes
            .addAll(code.classes.where((name) => name.startsWith('language-')));
      }

      var specifiesLanguage = pre.classes.isNotEmpty;
      // Assume the user intended Dart if there are no other classes present.
      if (!specifiesLanguage) pre.classes.add('language-dart');
    }
    var asHtml = '';

    if (processFullDocs) {
      // `trim` fixes an issue with line ending differences between Mac and
      // Windows.
      asHtml = (asHtmlDocument.body?.innerHtml ?? '').trim();
    }
    var children = asHtmlDocument.body?.children ?? [];
    var asOneLiner = children.isEmpty
        ? ''
        : children.first.innerHtml;

    return DocumentationRenderResult(asHtml: asHtml, asOneLiner: asOneLiner);
  }
}

class DocumentationRenderResult {
  static const empty = DocumentationRenderResult(asHtml: '', asOneLiner: '');

  final String /*?*/ asHtml;
  final String asOneLiner;

  const DocumentationRenderResult(
      {required this.asHtml, required this.asOneLiner});
}
