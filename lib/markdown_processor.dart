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
        CompilationUnitElement,
        ClassMemberElement,
        TopLevelVariableElement,
        ParameterElement,
        PropertyAccessorElement;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

import 'src/html_utils.dart' show htmlEscape;
import 'src/model.dart';

final List<md.InlineSyntax> _markdown_syntaxes = [new _InlineCodeSyntax()];

// We don't emit warnings currently: #572.
const bool _emitWarning = false;

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
    // this would be linkedElement.linkedName, but link bodies are slightly
    // different for doc references. sigh.
    return '<a class="${linkedElement.isDeprecated ? 'deprecated' : ''}" href="${linkedElement.href}">$reference</a>';
  } else {
    if (_emitWarning) {
      print("  warning: unresolved doc reference '$reference' (in $element)");
    }
    return '<code>$reference</code>';
  }
}

// TODO: this is in the wrong place
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

  bool get hasMoreThanOneLineDocs => _asHtmlDocument.body.children.length > 1;

  void _processDocsAsMarkdown() {
    String tempHtml = renderMarkdownToHtml(raw, element);
    _asHtmlDocument = parse(tempHtml);
    _asHtmlDocument.querySelectorAll('script').forEach((s) => s.remove());
    _asHtmlDocument.querySelectorAll('pre').forEach((e) {
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
      if ((node as AnnotatedNode).documentationComment != null) {
        return (node as AnnotatedNode).documentationComment.references;
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

  if (refElement is PropertyAccessorElement &&
      refElement.enclosingElement is CompilationUnitElement) {
    // yay we found an accessor that wraps a const, but we really
    // want the top-level field itself
    refElement = (refElement as PropertyAccessorElement).variable;
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
    return new ModelElement.from(refElement, refLibrary);
  }
  return null;
}
