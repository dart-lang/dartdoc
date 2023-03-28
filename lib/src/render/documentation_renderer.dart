// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parseFragment;

import 'package:markdown/markdown.dart' as md;

abstract class DocumentationRenderer {
  DocumentationRenderResult render(
    List<md.Node> nodes, {
    required bool processFullDocs,
    required bool sanitizeHtml,
  });
}

class DocumentationRendererHtml implements DocumentationRenderer {
  const DocumentationRendererHtml();

  @override
  DocumentationRenderResult render(
    List<md.Node> nodes, {
    required bool processFullDocs,
    required bool sanitizeHtml,
  }) {
    if (nodes.isEmpty) {
      return DocumentationRenderResult.empty;
    }

    var rawHtml = md.HtmlRenderer().render(nodes);
    var asHtmlFragment = parseFragment(rawHtml);

    for (var pre in asHtmlFragment.querySelectorAll('pre')) {
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

    if (sanitizeHtml) {
      _sanitize(asHtmlFragment);
    }

    var asHtml = '';

    if (processFullDocs) {
      // `trim` fixes an issue with line ending differences between Mac and
      // Windows.
      asHtml = asHtmlFragment.outerHtml.trim();
    }
    var asOneLiner = asHtmlFragment.children.isEmpty
        ? ''
        : asHtmlFragment.children.first.innerHtml;

    return DocumentationRenderResult(asHtml: asHtml, asOneLiner: asOneLiner);
  }
}

class DocumentationRenderResult {
  static const empty = DocumentationRenderResult(asHtml: '', asOneLiner: '');

  final String asHtml;
  final String asOneLiner;

  const DocumentationRenderResult(
      {required this.asHtml, required this.asOneLiner});
}

bool _allowClassName(String className) =>
    className == 'deprecated' || className.startsWith('language-');

Iterable<String> _addLinkRel(String uriString) {
  final uri = Uri.tryParse(uriString);
  if (uri != null && uri.host.isNotEmpty) {
    // TODO(jonasfj): Consider allowing non-ugc links for trusted sites.
    return const ['ugc'];
  }
  return const [];
}

void _sanitize(dom.Node node) {
  if (node is dom.Element) {
    final tagName = node.localName!.toUpperCase();
    if (!_allowedElements.contains(tagName)) {
      node.remove();
      return;
    }
    node.attributes.removeWhere((k, v) {
      final attrName = k.toString();
      if (attrName == 'class') {
        node.classes.removeWhere((cn) => !_allowClassName(cn));
        return node.classes.isEmpty;
      }
      return !_isAttributeAllowed(tagName, attrName, v);
    });
    if (tagName == 'A') {
      final href = node.attributes['href'];
      if (href != null) {
        final rels = _addLinkRel(href);
        if (rels.isNotEmpty) {
          node.attributes['rel'] = rels.join(' ');
        }
      }
    }
  }
  if (node.hasChildNodes()) {
    // doing it in reverse order, because we could otherwise skip one, when a
    // node is removed...
    for (var i = node.nodes.length - 1; i >= 0; i--) {
      _sanitize(node.nodes[i]);
    }
  }
}

bool _isAttributeAllowed(String tagName, String attrName, String value) {
  if (_alwaysAllowedAttributes.contains(attrName)) return true;

  // Special validators for special attributes on special tags (href/src/cite)
  final attributeValidators = _elementAttributeValidators[tagName];
  if (attributeValidators == null) {
    return false;
  }

  final validator = attributeValidators[attrName];
  if (validator == null) {
    return false;
  }

  return validator(value);
}

// Inspired by the set of HTML tags allowed in GFM.
final _allowedElements = <String>{
  'H1',
  'H2',
  'H3',
  'H4',
  'H5',
  'H6',
  'H7',
  'H8',
  'BR',
  'B',
  'I',
  'STRONG',
  'EM',
  'A',
  'PRE',
  'CODE',
  'IMG',
  'TT',
  'DIV',
  'INS',
  'DEL',
  'SUP',
  'SUB',
  'P',
  'OL',
  'UL',
  'TABLE',
  'THEAD',
  'TBODY',
  'TFOOT',
  'BLOCKQUOTE',
  'DL',
  'DT',
  'DD',
  'KBD',
  'Q',
  'SAMP',
  'VAR',
  'HR',
  'RUBY',
  'RT',
  'RP',
  'LI',
  'TR',
  'TD',
  'TH',
  'S',
  'STRIKE',
  'SUMMARY',
  'DETAILS',
  'CAPTION',
  'FIGURE',
  'FIGCAPTION',
  'ABBR',
  'BDO',
  'CITE',
  'DFN',
  'MARK',
  'SMALL',
  'SPAN',
  'TIME',
  'WBR',
};

// Inspired by the set of HTML attributes allowed in GFM.
final _alwaysAllowedAttributes = <String>{
  'abbr',
  'accept',
  'accept-charset',
  'accesskey',
  'action',
  'align',
  'alt',
  'aria-describedby',
  'aria-hidden',
  'aria-label',
  'aria-labelledby',
  'axis',
  'border',
  'cellpadding',
  'cellspacing',
  'char',
  'charoff',
  'charset',
  'checked',
  'clear',
  'cols',
  'colspan',
  'color',
  'compact',
  'coords',
  'datetime',
  'dir',
  'disabled',
  'enctype',
  'for',
  'frame',
  'headers',
  'height',
  'hreflang',
  'hspace',
  'ismap',
  'label',
  'lang',
  'maxlength',
  'media',
  'method',
  'multiple',
  'name',
  'nohref',
  'noshade',
  'nowrap',
  'open',
  'prompt',
  'readonly',
  'rel',
  'rev',
  'rows',
  'rowspan',
  'rules',
  'scope',
  'selected',
  'shape',
  'size',
  'span',
  'start',
  'summary',
  'tabindex',
  'target',
  'title',
  'type',
  'usemap',
  'valign',
  'value',
  'vspace',
  'width',
  'itemprop',
};

bool _alwaysAllowed(String _) => true;

bool _validLink(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.isScheme('https') ||
        uri.isScheme('http') ||
        uri.isScheme('mailto') ||
        !uri.hasScheme;
  } on FormatException {
    return false;
  }
}

bool _validUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.isScheme('https') || uri.isScheme('http') || !uri.hasScheme;
  } on FormatException {
    return false;
  }
}

final _citeAttributeValidator = <String, bool Function(String)>{
  'cite': _validUrl,
};

/// Allow the `id` attribute for `h1`, `h2`, ... `h6`.
final _headingAttributeValidator = <String, bool Function(String)>{
  'id': (id) {
    // This id property is generated by package:markdown in:
    // https://github.com/dart-lang/markdown/blob/ecbffa9bf9109d490b9388e9cb1f2bb801aee63c/lib/src/block_syntaxes/block_syntax.dart#L57-L63

    // Cannot contain anything but a-z0-9_-
    if (id.contains(RegExp('[^a-z0-9_-]'))) {
      return false;
    }
    return true;
  },
};

final _elementAttributeValidators =
    <String, Map<String, bool Function(String)>>{
  'A': {
    'href': _validLink,
  },
  'IMG': {
    'src': _validUrl,
    'longdesc': _validUrl,
  },
  'DIV': {
    'itemscope': _alwaysAllowed,
    'itemtype': _alwaysAllowed,
  },
  'BLOCKQUOTE': _citeAttributeValidator,
  'DEL': _citeAttributeValidator,
  'INS': _citeAttributeValidator,
  'Q': _citeAttributeValidator,
  'H1': _headingAttributeValidator,
  'H2': _headingAttributeValidator,
  'H3': _headingAttributeValidator,
  'H4': _headingAttributeValidator,
  'H5': _headingAttributeValidator,
  'H6': _headingAttributeValidator,
  'H7': _headingAttributeValidator,
  'H8': _headingAttributeValidator,
};
