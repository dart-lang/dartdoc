// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart'
    show
        LibraryElement,
        Element,
        ConstructorElement,
        ClassMemberElement,
        PropertyAccessorElement;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

import 'src/html_utils.dart' show htmlEscape;
import 'src/model.dart';

import 'dart:developer';

const _leftChar = '[';
const _rightChar = ']';

final List<md.InlineSyntax> _markdown_syntaxes = [new _InlineCodeSyntax()];

// We don't emit warnings currently: #572.
const bool _emitWarning = false;

String _linkDocReference(String reference, ModelElement element,
    NodeList<CommentReference> commentRefs) {
  String link;
  // support for [new Constructor] and [new Class.namedCtr]
  var refs = reference.split(' ');
  if (refs.length == 2 && refs.first == 'new') {
    link = _getMatchingLink(refs[1], element, commentRefs, isConstructor: true);
  } else {
    link = _getMatchingLink(reference, element, commentRefs);
  }
  if (link != null && link.isNotEmpty) {
    return '<a href="$link">$reference</a>';
  } else {
    if (_emitWarning) {
      print("  warning: unresolved doc reference '$reference' (in $element)");
    }
    return '<code>$reference</code>';
  }
}

class Documentation {
  final ModelElement element;
  String _asHtml;
  String _asOneLiner;
  Document _asHtmlDocument;

  Documentation(this.element) {
    _processDocsAsMarkdown();
  }

  String get raw => this.element.documentation;

  String get asHtml => _asHtml;

  Document get asHtmlDocument => _asHtmlDocument;

  String get asOneLiner => _asOneLiner;

  void _processDocsAsMarkdown() {
    String tempHtml = renderMarkdownToHtml(raw, element);
    _asHtmlDocument = parse(tempHtml);
    _asHtmlDocument.querySelectorAll('script').forEach((s) => s.remove());
    _asHtmlDocument.querySelectorAll('code').forEach((e) {
      e.classes.addAll(['prettyprint', 'lang-dart']);
    });
    _asHtml = _asHtmlDocument.body.innerHtml;

    if (_asHtmlDocument.body.children.isEmpty) {
      _asOneLiner = '';
    } else {
      _asOneLiner = _asHtmlDocument.body.children.first.innerHtml;
    }
  }
}

String renderMarkdownToHtml(String text, [ModelElement element]) {
  md.Node _linkResolver(String name) {
    NodeList<CommentReference> commentRefs = _getCommentRefs(element);
    return new md.Text(_linkDocReference(name, element, commentRefs));
  }

  return md.markdownToHtml(text,
      inlineSyntaxes: _markdown_syntaxes, linkResolver: _linkResolver);
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

/// Returns null if element is a parameter.
String _getMatchingLink(
    String codeRef, ModelElement element, List<CommentReference> commentRefs,
    {bool isConstructor: false}) {
  if (commentRefs == null) return null;

  Element refElement;

  for (CommentReference ref in commentRefs) {
    if (ref.identifier.name == codeRef) {
      bool isConstrElement = ref.identifier.staticElement is ConstructorElement;
      if (isConstructor && isConstrElement ||
          !isConstructor && !isConstrElement) {
        refElement = ref.identifier.staticElement;
        break;
      }
    }
  }

  if (refElement == null) return null;

  Library refLibrary;
  var e = refElement is ClassMemberElement ||
          refElement is PropertyAccessorElement
      ? refElement.enclosingElement
      : refElement;

  // If e is a ParameterElement, it's
  // never going to be in a library. So refLibrary is going to be null.
  refLibrary = element.package.libraries.firstWhere(
      (lib) => lib.hasInNamespace(e), orElse: () => null);
  if (refLibrary != null) {
    // Is there a way to pull this from a registry of known elements?
    // Seems like we're creating too many objects this way.
    return new ModelElement.from(refElement, refLibrary).href;
  }
  return null;
}
