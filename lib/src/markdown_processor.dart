// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert Markdown comments to HTML.
library;

import 'dart:convert';
import 'dart:math';

import 'package:dartdoc/src/comment_references/model_comment_reference.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/runtime_stats.dart';
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
  'wbr',
];

final RegExp _nonHtml =
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
  const md.AlertBlockSyntax(),
  const md.FencedCodeBlockSyntax(),
  const md.HeaderWithIdSyntax(),
  const md.SetextHeaderWithIdSyntax(),
  const md.TableSyntax(),
];

// Remove these schemas from the display text for hyperlinks.
final RegExp _hideSchemas = RegExp('^(http|https)://');

/// Returns false if [referable] is an unnamed [Constructor], or if it is
/// shadowing another type of element, or is a parameter of one of the above.
bool _rejectUnnamedAndShadowingConstructors(Referable? referable) {
  if (referable is Constructor) {
    if (referable.isUnnamedConstructor) return false;
    if (referable.enclosingElement
        .referenceChildren[referable.name.split('.').last] is! Constructor) {
      return false;
    }
  }
  return true;
}

/// Returns false unless [referable] represents a callable object.
///
/// Allows constructors but does not require them.
bool _requireCallable(Referable? referable) =>
    referable is ModelElement && referable.isCallable;

MatchingLinkResult _getMatchingLinkElement(
    String referenceText, Warnable element) {
  var commentReference = ModelCommentReference(referenceText);

  var filter = commentReference.hasCallableHint
      // Trailing parens indicate we are looking for a callable.
      ? _requireCallable
      // Without hints, reject unnamed constructors and their parameters to
      // force resolution to the class.
      : _rejectUnnamedAndShadowingConstructors;

  var lookupResult =
      element.referenceBy(commentReference.referenceBy, filter: filter);

  // TODO(jcollins-g): Consider prioritizing analyzer resolution before custom.
  return MatchingLinkResult(lookupResult);
}

/// Creates a [MatchingLinkResult] for [referenceText], the text of a doc
/// comment reference found in the doc comment attached to [element].
@visibleForTesting
MatchingLinkResult getMatchingLinkElement(
    String referenceText, Warnable element) {
  var result = _getMatchingLinkElement(referenceText, element);
  runtimeStats.totalReferences++;
  if (result.referable != null) {
    runtimeStats.resolvedReferences++;
  }
  return result;
}

/// Maximum number of characters to display before a suspected generic.
const maxPriorContext = 20;

/// Maximum number of characters to display after the beginning of a suspected
/// generic.
const maxPostContext = 30;

final RegExp _allBeforeFirstNewline = RegExp(r'^.*\n', multiLine: true);
final RegExp _allAfterLastNewline = RegExp(r'\n.*$', multiLine: true);

/// Warns about generics outside square brackets.
///
/// Generics should be wrapped in `[]`, to avoid handling them as HTML tags
// (like, [Apple<int>]).
void showWarningsForGenericsOutsideSquareBracketsBlocks(
    String text, Warnable element) {
  // Skip this if not warned for performance and for dart-lang/sdk#46419.
  if (element.config.packageWarningOptions
          .warningModes[PackageWarning.typeAsHtml] ==
      PackageWarningMode.ignore) {
    return;
  }

  for (var position in findFreeHangingGenericsPositions(text)) {
    var priorContext =
        text.substring(max(position - maxPriorContext, 0), position);
    var postContext =
        text.substring(position, min(position + maxPostContext, text.length));
    priorContext = priorContext.replaceAll(_allBeforeFirstNewline, '');
    postContext = postContext.replaceAll(_allAfterLastNewline, '');
    var errorMessage = '$priorContext$postContext';
    // TODO(jcollins-g):  allow for more specific error location inside comments
    element.warn(PackageWarning.typeAsHtml, message: errorMessage);
  }
}

@visibleForTesting
Iterable<int> findFreeHangingGenericsPositions(String string) sync* {
  var currentPosition = 0;
  var squareBracketsDepth = 0;
  while (true) {
    final nextOpenBracket = string.indexOf('[', currentPosition);
    final nextCloseBracket = string.indexOf(']', currentPosition);
    final nextNonHtmlTag = string.indexOf(_nonHtml, currentPosition);
    final nextPositions = [nextOpenBracket, nextCloseBracket, nextNonHtmlTag]
        .where((p) => p != -1);

    if (nextPositions.isEmpty) {
      break;
    }

    currentPosition = nextPositions.reduce(min);
    if (nextOpenBracket == currentPosition) {
      squareBracketsDepth += 1;
    } else if (nextCloseBracket == currentPosition) {
      squareBracketsDepth = max(squareBracketsDepth - 1, 0);
    } else if (nextNonHtmlTag == currentPosition) {
      if (squareBracketsDepth == 0) {
        yield currentPosition;
      }
    }
    currentPosition++;
  }
}

class MarkdownDocument extends md.Document {
  /// Creates a document which resolves comment references as stemming from
  /// [element].
  factory MarkdownDocument.withElementLinkResolver(Warnable element) {
    return MarkdownDocument._(
      inlineSyntaxes: _markdownSyntaxes,
      blockSyntaxes: _markdownBlockSyntaxes,
      linkResolver: (String name, [String? _]) => _makeLinkNode(name, element),
    );
  }

  MarkdownDocument._({
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.linkResolver,
  });

  /// Parses markdown text, collecting the first [md.Node] or all of them
  /// if [processFullText] is `true`.
  List<md.Node> parseMarkdownText(String text,
      {required bool processFullText}) {
    var lines =
        LineSplitter.split(text).map(md.Line.new).toList(growable: false);
    var nodes =
        md.BlockParser(lines, this).parseLines().toList(growable: false);
    if (!processFullText && nodes.isNotEmpty) {
      nodes = [nodes.first];
    }
    _parseInlineContent(nodes);
    return nodes;
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
        _parseInlineContent(node.children!);
      }
    }
  }

  /// A link resolver which resolves [referenceText] as stemming from [element].
  static md.Node? _makeLinkNode(String referenceText, Warnable element) {
    if (referenceText.isEmpty) {
      return null;
    }
    var result = getMatchingLinkElement(referenceText, element);
    var textContent = _htmlEscape.convert(referenceText);
    var linkedElement = result.referable;
    if (linkedElement != null) {
      // If the element has a separate name to use in documentation, prefer it.
      if (linkedElement.documentedName case var name?) {
        textContent = name;
      }

      if (linkedElement.href case var href?) {
        var anchor = md.Element.text('a', textContent);
        if (linkedElement is ModelElement && linkedElement.isDeprecated) {
          anchor.attributes['class'] = 'deprecated';
        }
        anchor.attributes['href'] = href;
        return anchor;
      } else {
        // Otherwise this would be `linkedElement.linkedName`, but link bodies
        // are slightly different for doc references.
        return md.Element.text('code', textContent);
      }
    } else {
      // Avoid claiming documentation is inherited when it comes from the
      // current element.
      var referredFrom = {
        if (element is ModelElement) ...element.documentationFrom
      }..remove(element);
      element.warn(PackageWarning.unresolvedDocReference,
          message: referenceText, referredFrom: referredFrom);
      return md.Element.text('code', textContent);
    }
  }
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.text('code', _htmlEscape.convert(match[1]!));
    parser.addNode(element);
    return true;
  }
}

class _AutolinkWithoutScheme extends md.AutolinkSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var url = match[1]!;
    var text = _htmlEscape.convert(url).replaceFirst(_hideSchemas, '');
    var anchor = md.Element.text('a', text);
    anchor.attributes['href'] = url;
    parser.addNode(anchor);

    return true;
  }
}
