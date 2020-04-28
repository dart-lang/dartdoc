// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/tuple.dart';
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

abstract class DocumentationRenderer {
  Tuple2<String, String> render(List<md.Node> nodes, bool processFullDocs);
}

class DocumentationRendererHtml extends DocumentationRenderer {
  @override
  Tuple2<String, String> render(List<md.Node> nodes, bool processFullDocs) {
    if (nodes.isEmpty) {
      return Tuple2('', '');
    }
    var rawHtml = md.HtmlRenderer().render(nodes);
    var asHtmlDocument = parse(rawHtml);
    for (var s in asHtmlDocument.querySelectorAll('script')) {
      s.remove();
    }
    for (var pre in asHtmlDocument.querySelectorAll('pre')) {
      if (pre.children.isNotEmpty &&
          pre.children.length != 1 &&
          pre.children.first.localName != 'code') {
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
    String asHtml;
    String asOneLiner;

    if (processFullDocs) {
      // `trim` fixes issue with line ending differences between mac and windows.
      asHtml = asHtmlDocument.body.innerHtml?.trim();
    }
    asOneLiner = asHtmlDocument.body.children.isEmpty
        ? ''
        : asHtmlDocument.body.children.first.innerHtml;

    return Tuple2(asHtml, asOneLiner);
  }
}
