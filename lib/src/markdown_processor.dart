// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart'
    show
        LibraryElement,
        Element,
        ConstructorElement,
        ClassElement,
        ParameterElement,
        PropertyAccessorElement;
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

import 'config.dart';
import 'model.dart';

const bool _emitWarning = false;

// We don't emit warnings currently: #572.
const List<String> _oneLinerSkipTags = const ["code", "pre"];

final List<md.InlineSyntax> _regularSyntaxes = [
  new _InlineCodeSyntax(),
  new _AutolinkWithoutScheme()
];
final List<md.InlineSyntax> _crossdartSyntaxes = [new _InlineCodeSyntax()];

List<md.InlineSyntax> get markdownSyntaxes =>
    config.addCrossdart ? _crossdartSyntaxes : _regularSyntaxes;

// Remove these schemas from the display text for hyperlinks.
final RegExp _hide_schemes = new RegExp('^(http|https)://');

// TODO: this is in the wrong place
NodeList<CommentReference> _getCommentRefs(ModelElement modelElement) {
  if (modelElement == null) return null;
  if (modelElement.documentation == null && modelElement.canOverride()) {
    var melement = modelElement.overriddenElement;
    if (melement != null &&
        melement.element.computeNode() != null &&
        melement.element.computeNode() is AnnotatedNode) {
      var docComment = (melement.element.computeNode() as AnnotatedNode)
          .documentationComment;
      if (docComment != null) return docComment.references;
      return null;
    }
  }
  if (modelElement.element.computeNode() is AnnotatedNode) {
    if ((modelElement.element.computeNode() as AnnotatedNode)
            .documentationComment !=
        null) {
      return (modelElement.element.computeNode() as AnnotatedNode)
          .documentationComment
          .references;
    }
  } else if (modelElement.element is LibraryElement) {
    // handle anonymous libraries
    if (modelElement.element.computeNode() == null ||
        modelElement.element.computeNode().parent == null) {
      return null;
    }
    var node = modelElement.element.computeNode().parent.parent;
    if (node is AnnotatedNode) {
      if (node.documentationComment != null) {
        return node.documentationComment.references;
      }
    }
  }
  return null;
}

/// Returns null if element is a parameter.
ModelElement _getMatchingLinkElement(
    String codeRef, ModelElement element, List<CommentReference> commentRefs,
    {bool isConstructor: false}) {
  if (commentRefs == null) return null;

  Element refElement;
  bool isEnum = false;

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

  // Did not find an element in scope
  if (refElement == null) return null;

  if (refElement is PropertyAccessorElement) {
    // yay we found an accessor that wraps a const, but we really
    // want the top-level field itself
    refElement = (refElement as PropertyAccessorElement).variable;
    if (refElement.enclosingElement is ClassElement &&
        (refElement.enclosingElement as ClassElement).isEnum) {
      isEnum = true;
    }
  }

  if (refElement is ParameterElement) return null;

  // bug! this can fail to find the right library name if the element's name
  // we're looking for is the same as a name that comes in from an imported
  // library.
  //
  // Don't search through all libraries in the package, actually search
  // in the current scope.
  Library refLibrary =
      element.package.findLibraryFor(refElement, scopedTo: element);

  if (refLibrary != null) {
    // Is there a way to pull this from a registry of known elements?
    // Seems like we're creating too many objects this way.
    if (isEnum) {
      return new EnumField(refElement, refLibrary);
    }
    return new ModelElement.from(refElement, refLibrary);
  }
  return null;
}

String _linkDocReference(String reference, ModelElement element,
    NodeList<CommentReference> commentRefs) {
  ModelElement linkedElement;
  // support for [new Constructor] and [new Class.namedCtr]
  var refs = reference.split(' ');
  if (refs.length == 2 && refs.first == 'new') {
    linkedElement = _getMatchingLinkElement(refs[1], element, commentRefs,
        isConstructor: true);
  } else {
    linkedElement = _getMatchingLinkElement(reference, element, commentRefs);
  }
  if (linkedElement != null) {
    var classContent = '';
    if (linkedElement.isDeprecated) {
      classContent = 'class="deprecated" ';
    }
    // this would be linkedElement.linkedName, but link bodies are slightly
    // different for doc references. sigh.
    return '<a ${classContent}href="${linkedElement.href}">$reference</a>';
  } else {
    if (_emitWarning) {
      print("  warning: unresolved doc reference '$reference' (in $element)");
    }
    return '<code>${HTML_ESCAPE.convert(reference)}</code>';
  }
}

String _renderMarkdownToHtml(String text, [ModelElement element]) {
  md.Node _linkResolver(String name) {
    NodeList<CommentReference> commentRefs = _getCommentRefs(element);
    return new md.Text(_linkDocReference(name, element, commentRefs));
  }

  return md.markdownToHtml(text,
      inlineSyntaxes: markdownSyntaxes, linkResolver: _linkResolver);
}

class Documentation {
  final String raw;
  final String asHtml;
  final String asOneLiner;

  factory Documentation(String markdown) {
    String tempHtml = _renderMarkdownToHtml(markdown);
    return new Documentation._internal(markdown, tempHtml);
  }

  factory Documentation.forElement(ModelElement element) {
    String tempHtml = _renderMarkdownToHtml(element.documentation, element);
    return new Documentation._internal(element.documentation, tempHtml);
  }

  Documentation._(this.raw, this.asHtml, this.asOneLiner);

  factory Documentation._internal(String markdown, String rawHtml) {
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

      bool specifiesLanguage = pre.classes.isNotEmpty;
      pre.classes.add('prettyprint');
      // Assume the user intended Dart if there are no other classes present.
      if (!specifiesLanguage) pre.classes.add('language-dart');
    }

    // `trim` fixes issue with line ending differences between mac and windows.
    var asHtml = asHtmlDocument.body.innerHtml?.trim();
    var asOneLiner = asHtmlDocument.body.children.isEmpty
        ? ''
        : asHtmlDocument.body.children.first.innerHtml;
    if (!asOneLiner.startsWith('<p>')) {
      asOneLiner = '<p>$asOneLiner</p>';
    }
    return new Documentation._(markdown, asHtml, asOneLiner);
  }
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = new md.Element.text('code', HTML_ESCAPE.convert(match[1]));
    parser.addNode(element);
    return true;
  }
}

class _AutolinkWithoutScheme extends md.AutolinkSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var url = match[1];
    var text = md.escapeHtml(url).replaceFirst(_hide_schemes, '');
    var anchor = new md.Element.text('a', text);
    anchor.attributes['href'] = url;
    parser.addNode(anchor);

    return true;
  }
}
