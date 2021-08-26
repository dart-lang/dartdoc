// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'dart:convert';
import 'dart:math';

import 'package:dartdoc/src/comment_references/model_comment_reference.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

const _validHtmlTags = [
  'a',
  'abbr',
  'address',
  'area',
  'article',
  'aside',
  'audio',
  'b',
  'bdi',
  'bdo',
  'blockquote',
  'br',
  'button',
  'canvas',
  'caption',
  'cite',
  'code',
  'col',
  'colgroup',
  'data',
  'datalist',
  'dd',
  'del',
  'dfn',
  'div',
  'dl',
  'dt',
  'em',
  'fieldset',
  'figcaption',
  'figure',
  'footer',
  'form',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'hr',
  'i',
  'iframe',
  'img',
  'input',
  'ins',
  'kbd',
  'keygen',
  'label',
  'legend',
  'li',
  'link',
  'main',
  'map',
  'mark',
  'meta',
  'meter',
  'nav',
  'noscript',
  'object',
  'ol',
  'optgroup',
  'option',
  'output',
  'p',
  'param',
  'pre',
  'progress',
  'q',
  's',
  'samp',
  'script',
  'section',
  'select',
  'small',
  'source',
  'span',
  'strong',
  'style',
  'sub',
  'sup',
  'table',
  'tbody',
  'td',
  'template',
  'textarea',
  'tfoot',
  'th',
  'thead',
  'time',
  'title',
  'tr',
  'track',
  'u',
  'ul',
  'var',
  'video',
  'wbr'
];

final RegExp _nonHTML =
    RegExp("</?(?!(${_validHtmlTags.join("|")})[> ])\\w+[> ]");

final HtmlEscape _htmlEscape = const HtmlEscape(HtmlEscapeMode.element);

final List<md.InlineSyntax> _markdownSyntaxes = [
  _InlineCodeSyntax(),
  _AutolinkWithoutScheme(),
  md.InlineHtmlSyntax(),
  md.StrikethroughSyntax(),
  md.AutolinkExtensionSyntax(),
];

final List<md.BlockSyntax> _markdownBlockSyntaxes = [
  const md.FencedCodeBlockSyntax(),
  const md.HeaderWithIdSyntax(),
  const md.SetextHeaderWithIdSyntax(),
  const md.TableSyntax(),
];

// Remove these schemas from the display text for hyperlinks.
final RegExp _hideSchemes = RegExp('^(http|https)://');

class _IterableBlockParser extends md.BlockParser {
  _IterableBlockParser(List<String> lines, md.Document document)
      : super(lines, document);

  Iterable<md.Node> parseLinesGenerator() sync* {
    while (!isDone) {
      for (var syntax in blockSyntaxes) {
        if (syntax.canParse(this)) {
          var block = syntax.parse(this);
          if (block != null) yield (block);
          break;
        }
      }
    }
  }
}

/// Return false if the passed [referable] is a default [Constructor],
/// or if it is shadowing another type of element, or is a parameter of
/// one of the above.
bool _rejectDefaultAndShadowingConstructors(CommentReferable referable) {
  if (referable is Constructor) {
    if (referable.name == referable.enclosingElement.name) {
      return false;
    }
    if (referable.enclosingElement
        .referenceChildren[referable.name.split('.').last] is! Constructor) {
      return false;
    }
  }
  return true;
}

/// Return false unless the passed [referable] represents a callable object.
/// Allows constructors but does not require them.
bool _requireCallable(CommentReferable referable) =>
    referable is ModelElement && referable.isCallable;

/// Return false unless the passed [referable] represents a constructor.
bool _requireConstructor(CommentReferable referable) =>
    referable is Constructor;

/// Implements _getMatchingLinkElement via [CommentReferable.referenceBy].
MatchingLinkResult _getMatchingLinkElementCommentReferable(
    String codeRef, Warnable warnable) {
  var commentReference =
      warnable.commentRefs[codeRef] ?? ModelCommentReference.synthetic(codeRef);

  bool Function(CommentReferable) filter;
  bool Function(CommentReferable) allowTree;

  // Constructor references are pretty ambiguous by nature since they are
  // declared with the same name as the class they are constructing, and even
  // if they don't use field-formal parameters, sometimes have parameters
  // named the same as members.
  // Maybe clean this up with inspiration from constructor tear-off syntax?
  if (commentReference.allowDefaultConstructor) {
    // Neither reject, nor require, a default constructor in the event
    // the comment reference structure implies one.  (We can not require it
    // in case a library name is the same as a member class name and the class
    // is the intended lookup).   For example, [FooClass.FooClass] structurally
    // "looks like" a default constructor, so we should allow it here.
    filter = commentReference.hasCallableHint ? _requireCallable : null;
  } else if (commentReference.hasConstructorHint &&
      commentReference.hasCallableHint) {
    // This takes precedence over the callable hint if both are present --
    // pick a constructor if and only constructor if we see `new`.
    filter = _requireConstructor;
  } else if (commentReference.hasCallableHint) {
    // Trailing parens indicate we are looking for a callable.
    filter = _requireCallable;
  } else {
    // Without hints, reject default constructors and their parameters to force
    // resolution to the class.
    filter = _rejectDefaultAndShadowingConstructors;

    if (!commentReference.allowDefaultConstructorParameter) {
      allowTree = _rejectDefaultAndShadowingConstructors;
    }
  }

  var lookupResult = warnable.referenceBy(commentReference.referenceBy,
      allowTree: allowTree, filter: filter);

  // TODO(jcollins-g): Consider prioritizing analyzer resolution before custom.
  return MatchingLinkResult(lookupResult);
}

md.Node _makeLinkNode(String codeRef, Warnable warnable) {
  var result = getMatchingLinkElement(warnable, codeRef);
  var textContent = _htmlEscape.convert(codeRef);
  var linkedElement = result.commentReferable;
  if (linkedElement != null) {
    if (linkedElement.href != null) {
      var anchor = md.Element.text('a', textContent);
      if (linkedElement is ModelElement && linkedElement.isDeprecated) {
        anchor.attributes['class'] = 'deprecated';
      }
      anchor.attributes['href'] = linkedElement.href;
      return anchor;
    }
    // else this would be linkedElement.linkedName, but link bodies are slightly
    // different for doc references, so fall out.
  } else {
    if (result.warn) {
      // Avoid claiming documentation is inherited when it comes from the
      // current element.
      warnable.warn(PackageWarning.unresolvedDocReference,
          message: codeRef,
          referredFrom: warnable.documentationIsLocal
              ? null
              : warnable.documentationFrom);
    }
  }

  return md.Element.text('code', textContent);
}

@visibleForTesting
MatchingLinkResult getMatchingLinkElement(Warnable warnable, String codeRef) {
  var result = _getMatchingLinkElementCommentReferable(codeRef, warnable);
  markdownStats.totalReferences++;
  if (result.commentReferable != null) markdownStats.resolvedReferences++;
  return result;
}

// Maximum number of characters to display before a suspected generic.
const maxPriorContext = 20;
// Maximum number of characters to display after the beginning of a suspected generic.
const maxPostContext = 30;

final RegExp allBeforeFirstNewline = RegExp(r'^.*\n', multiLine: true);
final RegExp allAfterLastNewline = RegExp(r'\n.*$', multiLine: true);

// Generics should be wrapped into `[]` blocks, to avoid handling them as HTML tags
// (like, [Apple<int>]). @Hixie asked for a warning when there's something, that looks
// like a non HTML tag (a generic?) outside of a `[]` block.
// https://github.com/dart-lang/dartdoc/issues/1250#issuecomment-269257942
void showWarningsForGenericsOutsideSquareBracketsBlocks(
    String text, Warnable element) {
  // Skip this if not warned for performance and for dart-lang/sdk#46419.
  if (element.config.packageWarningOptions
          .warningModes[PackageWarning.typeAsHtml] !=
      PackageWarningMode.ignore) {
    for (var position in findFreeHangingGenericsPositions(text)) {
      var priorContext =
          '${text.substring(max(position - maxPriorContext, 0), position)}';
      var postContext =
          '${text.substring(position, min(position + maxPostContext, text.length))}';
      priorContext = priorContext.replaceAll(allBeforeFirstNewline, '');
      postContext = postContext.replaceAll(allAfterLastNewline, '');
      var errorMessage = '$priorContext$postContext';
      // TODO(jcollins-g):  allow for more specific error location inside comments
      element.warn(PackageWarning.typeAsHtml, message: errorMessage);
    }
  }
}

Iterable<int> findFreeHangingGenericsPositions(String string) sync* {
  var currentPosition = 0;
  var squareBracketsDepth = 0;
  while (true) {
    final nextOpenBracket = string.indexOf('[', currentPosition);
    final nextCloseBracket = string.indexOf(']', currentPosition);
    final nextNonHTMLTag = string.indexOf(_nonHTML, currentPosition);
    final nextPositions = [nextOpenBracket, nextCloseBracket, nextNonHTMLTag]
        .where((p) => p != -1);

    if (nextPositions.isEmpty) {
      break;
    }

    currentPosition = nextPositions.reduce(min);
    if (nextOpenBracket == currentPosition) {
      squareBracketsDepth += 1;
    } else if (nextCloseBracket == currentPosition) {
      squareBracketsDepth = max(squareBracketsDepth - 1, 0);
    } else if (nextNonHTMLTag == currentPosition) {
      if (squareBracketsDepth == 0) {
        yield currentPosition;
      }
    }
    currentPosition++;
  }
}

class MarkdownDocument extends md.Document {
  factory MarkdownDocument.withElementLinkResolver(Canonicalization element) {
    md.Node /*?*/ linkResolver(String name, [String /*?*/ _]) {
      if (name.isEmpty) {
        return null;
      }
      return _makeLinkNode(name, element);
    }

    return MarkdownDocument(
        inlineSyntaxes: _markdownSyntaxes,
        blockSyntaxes: _markdownBlockSyntaxes,
        linkResolver: linkResolver);
  }

  MarkdownDocument(
      {Iterable<md.BlockSyntax> blockSyntaxes,
      Iterable<md.InlineSyntax> inlineSyntaxes,
      md.ExtensionSet extensionSet,
      md.Resolver linkResolver,
      md.Resolver imageLinkResolver})
      : super(
            blockSyntaxes: blockSyntaxes,
            inlineSyntaxes: inlineSyntaxes,
            extensionSet: extensionSet,
            linkResolver: linkResolver,
            imageLinkResolver: imageLinkResolver);

  /// Parses markdown text, collecting the first [md.Node] or all of them
  /// if [processFullText] is `true`. If more than one node is present,
  /// then [DocumentationParseResult.hasExtendedDocs] will be set to `true`.
  DocumentationParseResult parseMarkdownText(
      String text, bool processFullText) {
    var hasExtendedContent = false;
    var lines = LineSplitter.split(text).toList();
    md.Node firstNode;
    var nodes = <md.Node>[];
    for (var node in _IterableBlockParser(lines, this).parseLinesGenerator()) {
      if (firstNode != null) {
        hasExtendedContent = true;
        if (!processFullText) break;
      }
      firstNode ??= node;
      nodes.add(node);
    }
    _parseInlineContent(nodes);
    return DocumentationParseResult(nodes, hasExtendedContent);
  }

  // From package:markdown/src/document.dart
  // TODO(jcollins-g): consider making this a public method in markdown package
  void _parseInlineContent(List<md.Node> nodes) {
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node is md.UnparsedContent) {
        var inlineNodes = md.InlineParser(node.textContent, this).parse();
        nodes.removeAt(i);
        nodes.insertAll(i, inlineNodes);
        i += inlineNodes.length - 1;
      } else if (node is md.Element && node.children != null) {
        _parseInlineContent(node.children);
      }
    }
  }
}

class DocumentationParseResult {
  static const empty = DocumentationParseResult([], false);

  final List<md.Node> nodes;
  final bool hasExtendedDocs;

  const DocumentationParseResult(this.nodes, this.hasExtendedDocs);
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.text('code', _htmlEscape.convert(match[1] /*!*/));
    parser.addNode(element);
    return true;
  }
}

class _AutolinkWithoutScheme extends md.AutolinkSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var url = match[1] /*!*/;
    var text = _htmlEscape.convert(url).replaceFirst(_hideSchemes, '');
    var anchor = md.Element.text('a', text);
    anchor.attributes['href'] = url;
    parser.addNode(anchor);

    return true;
  }
}
