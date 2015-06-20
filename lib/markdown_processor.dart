// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library markdown_processor;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart'
    show
        LibraryElement,
        ConstructorElement,
        ClassMemberElement,
        PropertyAccessorElement;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

import 'src/html_utils.dart' show htmlEscape;
import 'src/model.dart';

const _leftChar = '[';
const _rightChar = ']';

final List<md.InlineSyntax> _markdown_syntaxes = [new _InlineCodeSyntax()];

String renderMarkdownToHtml(String text, [ModelElement element]) {
  // TODO: `renderMarkdownToHtml` is never called with an element arg.
  // TODO(keertip): use this for the one liner.
  md.Node _linkResolver(String name) {
    NodeList<CommentReference> commentRefs = _getCommentRefs(element);
    if (commentRefs == null || commentRefs.isEmpty) {
      return new md.Text('[$name]');
    }
    // support for [new Constructor] and [new Class.namedCtr]
    var link;
    var refs = name.split(' ');
    if (refs.length == 2 && refs.first == 'new') {
      link =
          _getMatchingLink(refs[1], element, commentRefs, isConstructor: true);
    } else {
      link = _getMatchingLink(name, element, commentRefs);
    }
    if (link != null) {
      return new md.Text('<a href="$link">$name</a>');
    }
    return new md.Text('$name');
  }

  return md.markdownToHtml(text,
      inlineSyntaxes: _markdown_syntaxes, linkResolver: _linkResolver);
}

String processDocsAsMarkdown(ModelElement element) {
  if (element == null || element.documentation == null) return '';
  String html = renderMarkdownToHtml(element.documentation, element);
  Document doc = parse(html);
  doc.querySelectorAll('script').forEach((s) => s.remove());
  doc.querySelectorAll('pre > code').forEach((e) {
    e.classes.addAll(['prettyprint', 'lang-dart']);
  });
  return doc.body.innerHtml;
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = new md.Element.text('code', htmlEscape(match[1]));
    var c = element.attributes.putIfAbsent("class", () => "");
    c = (c.isEmpty ? "" : " ") + "prettyprint";
    element.attributes["class"] = c;
    parser.addNode(element);
    return true;
  }
}

const List<String> _oneLinerSkipTags = const ["code", "pre"];

String oneLinerWithoutReferences(String text) {
  if (text == null) return '';
  // Parse with Markdown, but only care about the first block or paragraph.
  Iterable<String> lines = text.replaceAll('\r\n', '\n').split('\n');
  md.Document document = new md.Document(inlineSyntaxes: _markdown_syntaxes);
  document.parseRefLinks(lines);
  List blocks = document.parseLines(lines);

  while (blocks.isNotEmpty &&
      ((blocks.first is md.Element &&
              _oneLinerSkipTags.contains(blocks.first.tag)) ||
          (blocks.first is md.Text && blocks.first.text.isEmpty))) {
    blocks.removeAt(0);
  }

  if (blocks.isEmpty) return '';

  String firstPara = new PlainTextRenderer().render([blocks.first]);
  if (firstPara.length > 200) {
    firstPara = firstPara.substring(0, 200) + '...';
  }

  return firstPara.trim();
}

String oneLiner(ModelElement element) {
  if (element == null ||
      element.documentation == null ||
      element.documentation.isEmpty) return '';

  return _resolveDocReferences(
      oneLinerWithoutReferences(element.documentation), element).trim();
}

class PlainTextRenderer implements md.NodeVisitor {
  static final _BLOCK_TAGS =
      new RegExp('blockquote|h1|h2|h3|h4|h5|h6|hr|p|pre');

  StringBuffer _buffer;

  String render(List<md.Node> nodes) {
    _buffer = new StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }

    return _buffer.toString();
  }

  @override
  void visitText(md.Text text) {
    _buffer.write(text.text);
  }

  @override
  bool visitElementBefore(md.Element element) {
    // do nothing
    return true;
  }

  @override
  void visitElementAfter(md.Element element) {
    // Hackish. Separate block-level elements with newlines.
    if (!_buffer.isEmpty && _BLOCK_TAGS.firstMatch(element.tag) != null) {
      _buffer.write('\n\n');
    }
  }
}

String _replaceAllLinks(ModelElement element, String str,
    List<CommentReference> commentRefs, String findMatchingLink(
        String input, ModelElement element, List<CommentReference> commentRefs,
        {bool isConstructor})) {
  int lastWritten = 0;
  int index = str.indexOf(_leftChar);
  StringBuffer buf = new StringBuffer();

  while (index != -1) {
    int end = str.indexOf(_rightChar, index + 1);
    if (end != -1) {
      if (index - lastWritten > 0) {
        buf.write(str.substring(lastWritten, index));
      }
      String codeRef = str.substring(index + _leftChar.length, end);
      if (codeRef != null) {
        var link;
        // support for [new Constructor] and [new Class.namedCtr]
        var refs = codeRef.split(' ');
        if (refs.length == 2 && refs.first == 'new') {
          link = findMatchingLink(refs[1], element, commentRefs,
              isConstructor: true);
        } else {
          link = findMatchingLink(codeRef, element, commentRefs);
        }
        if (link != null) {
          buf.write('<a href="$link">$codeRef</a>');
        } else {
          print("WARNING: $element contains unknown doc reference [$codeRef]");
          buf.write(codeRef);
        }
      }
      lastWritten = end + _rightChar.length;
    } else {
      break;
    }
    index = str.indexOf(_leftChar, end + 1);
  }
  if (lastWritten < str.length) {
    buf.write(str.substring(lastWritten, str.length));
  }
  return buf.toString();
}

String _resolveDocReferences(String docsAfterMarkdown, ModelElement element) {
  NodeList<CommentReference> commentRefs = _getCommentRefs(element);
  if (commentRefs == null || commentRefs.isEmpty) {
    return docsAfterMarkdown;
  }

  return _replaceAllLinks(
      element, docsAfterMarkdown, commentRefs, _getMatchingLink);
}

NodeList<CommentReference> _getCommentRefs(ModelElement modelElement) {
  if (modelElement == null) return null;
  if (modelElement.documentation == null && modelElement.canOverride()) {
    var melement = modelElement.overriddenElement;
    if (melement != null &&
        melement.element.node != null &&
        melement.element.node is AnnotatedNode) {
      var docComment =
          (melement.element.node as AnnotatedNode).documentationComment;
      if (docComment != null) return docComment.references;
      return null;
    }
  }
  if (modelElement.element.node is AnnotatedNode) {
    if ((modelElement.element.node as AnnotatedNode).documentationComment !=
        null) {
      return (modelElement.element.node as AnnotatedNode).documentationComment.references;
    }
  } else if (modelElement.element is LibraryElement) {
    // handle anonymous libraries
    if (modelElement.element.node == null ||
        modelElement.element.node.parent == null) {
      return null;
    }
    var node = modelElement.element.node.parent.parent;
    if (node is AnnotatedNode) {
      if ((node as AnnotatedNode).documentationComment != null) {
        return (node as AnnotatedNode).documentationComment.references;
      }
    }
  }
  return null;
}

String _getMatchingLink(
    String codeRef, ModelElement element, List<CommentReference> commentRefs,
    {bool isConstructor: false}) {
  var refElement;

  for (CommentReference ref in commentRefs) {
    if (ref.identifier.name == codeRef) {
      var isConstrElement = ref.identifier.staticElement is ConstructorElement;
      if (isConstructor && isConstrElement ||
          !isConstructor && !isConstrElement) {
        refElement = ref.identifier.staticElement;
        break;
      }
    }
  }
  if (refElement == null) {
    return null;
  }
  var refLibrary;
  try {
    var e = refElement is ClassMemberElement ||
            refElement is PropertyAccessorElement
        ? refElement.enclosingElement
        : refElement;
    refLibrary =
        element.package.libraries.firstWhere((lib) => lib.hasInNamespace(e));
  } on StateError {}
  if (refLibrary != null) {
    var e = new ModelElement.from(refElement, refLibrary);
    return e.href;
  }
  return null;
}
