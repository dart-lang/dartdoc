// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Documentation processor for VitePress output.
///
/// Takes a [ModelElement]'s `documentation` getter (pre-HTML markdown with
/// bracket references intact), resolves `{@inject-html}` placeholders and
/// cross-references via the markdown parser, and serializes the result back
/// to clean markdown suitable for VitePress rendering.
library;

import 'package:dartdoc/src/comment_references/model_comment_reference.dart';
import 'package:dartdoc/src/generator/vitepress_paths.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:markdown/markdown.dart' as md;

/// Regular expression matching `<dartdoc-html>HEXDIGEST</dartdoc-html>`
/// placeholders inserted by the `{@inject-html}` directive processing.
///
/// These placeholders are present in the `documentation` getter and must be
/// resolved BEFORE markdown parsing so the injected HTML passes through
/// the markdown parser as raw HTML content.
final _htmlInjectPattern = RegExp(r'<dartdoc-html>([a-f0-9]+)</dartdoc-html>');

/// Regular expression matching the `htmlBasePlaceholder` that may appear in
/// documentation strings. This is dartdoc's internal placeholder for the
/// HTML base path, which is irrelevant for VitePress output.
final _htmlBasePlaceholder =
    RegExp(r'%%__HTMLBASE_dartdoc_internal__%%', multiLine: true);

/// Inline syntaxes used for parsing documentation markdown.
///
/// These match the syntaxes used by dartdoc's own `MarkdownDocument`,
/// ensuring consistent parsing behavior.
final List<md.InlineSyntax> _inlineSyntaxes = [
  _InlineCodeSyntax(),
  md.InlineHtmlSyntax(),
  md.StrikethroughSyntax(),
  md.AutolinkExtensionSyntax(),
];

/// Block syntaxes used for parsing documentation markdown.
final List<md.BlockSyntax> _blockSyntaxes = [
  const md.AlertBlockSyntax(),
  const md.FencedCodeBlockSyntax(),
  const md.HeaderWithIdSyntax(),
  const md.SetextHeaderWithIdSyntax(),
  const md.TableSyntax(),
];

/// Returns `false` if [referable] is an unnamed [Constructor], or if it is
/// shadowing another type of element, or is a parameter of one of the above.
///
/// This mirrors the filter logic in `markdown_processor.dart`.
bool _rejectUnnamedAndShadowingConstructors(CommentReferable? referable) {
  if (referable is Constructor) {
    if (referable.isUnnamedConstructor) return false;
    if (referable.enclosingElement
        .referenceChildren[referable.name.split('.').last] is! Constructor) {
      return false;
    }
  }
  return true;
}

/// Returns `false` unless [referable] represents a callable object.
bool _requireCallable(CommentReferable? referable) =>
    referable is ModelElement && referable.isCallable;

/// Resolves a bracket reference [referenceText] against [element]'s scope.
///
/// This replicates the logic from `markdown_processor.dart`'s
/// `getMatchingLinkElement()` function without calling the `@visibleForTesting`
/// annotated function directly. Uses the same comment reference parsing and
/// lookup mechanism.
MatchingLinkResult _resolveReference(
    String referenceText, ModelElement element) {
  var commentReference = ModelCommentReference(referenceText);

  var filter = commentReference.hasCallableHint
      ? _requireCallable
      : _rejectUnnamedAndShadowingConstructors;

  var lookupResult =
      element.referenceBy(commentReference.referenceBy, filter: filter);

  var result = MatchingLinkResult(lookupResult);
  runtimeStats.totalReferences++;
  if (result.commentReferable != null) {
    runtimeStats.resolvedReferences++;
  }
  return result;
}

/// Inline syntax for dartdoc's `[: code :]` notation.
///
/// Converts `[: code :]` to markdown inline code (`` `code` ``).
/// This mirrors dartdoc's `_InlineCodeSyntax` from `markdown_processor.dart`,
/// but produces markdown backtick-wrapped code instead of HTML `<code>` elements.
class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Text('`${match[1]!.trim()}`'));
    return true;
  }
}

/// Processes documentation text from [ModelElement]s for VitePress output.
///
/// The processor performs these steps:
/// 1. Reads the `documentation` getter (pre-HTML markdown with bracket refs)
/// 2. Resolves `{@inject-html}` placeholders via [PackageGraph.getHtmlFragment]
/// 3. Replaces `<p>` joiners with `\n\n` (safety net for multi-source docs)
/// 4. Parses through the markdown parser with a custom `linkResolver` to
///    resolve `[ClassName]` bracket references into VitePress-compatible links
/// 5. Serializes the resolved AST back to markdown via [MarkdownRenderer]
class VitePressDocProcessor {
  /// The package graph, used for resolving `{@inject-html}` fragments.
  final PackageGraph packageGraph;

  /// The path resolver, used for computing VitePress URLs for cross-references.
  final VitePressPathResolver paths;

  VitePressDocProcessor(this.packageGraph, this.paths);

  // ---------------------------------------------------------------------------
  // Pre-compiled patterns for sanitizeHtml.
  // ---------------------------------------------------------------------------
  static final _scriptOpenClose = RegExp(
      r'<\s*script\b[^>]*>[\s\S]*?<\s*/\s*script\s*>',
      caseSensitive: false);
  static final _scriptSelfClose =
      RegExp(r'<\s*script\b[^>]*/\s*>', caseSensitive: false);
  static final _styleOpenClose = RegExp(
      r'<\s*style\b[^>]*>[\s\S]*?<\s*/\s*style\s*>',
      caseSensitive: false);
  static final _baseTag =
      RegExp(r'<\s*base\b[^>]*/?\s*>', caseSensitive: false);
  static final _metaTag =
      RegExp(r'<\s*meta\b[^>]*/?\s*>', caseSensitive: false);
  static final _linkTag =
      RegExp(r'<\s*link\b[^>]*/?\s*>', caseSensitive: false);
  static final _iframeTag = RegExp(
      r'<\s*iframe\b[^>]*>[\s\S]*?<\s*/\s*iframe\s*>',
      caseSensitive: false);
  static final _iframeSrcAttr =
      RegExp(r"""src\s*=\s*["']([^"']*)["']""", caseSensitive: false);
  static final _javascriptUrl =
      RegExp(r'''(href|src)\s*=\s*["']?\s*javascript:''', caseSensitive: false);
  static final _dataUrl =
      RegExp(r'''(href|src)\s*=\s*["']?\s*data:''', caseSensitive: false);
  static final _eventHandler = RegExp(
      r'''\s+on\w+\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]+)''',
      caseSensitive: false);
  static final _dangerousEmbedOpenClose = {
    for (final tag in ['embed', 'object', 'applet', 'form', 'svg'])
      tag: RegExp('<\\s*$tag\\b[^>]*>[\\s\\S]*?<\\s*/\\s*$tag\\s*>',
          caseSensitive: false),
  };
  static final _dangerousEmbedSelfClose = {
    for (final tag in ['embed', 'object', 'applet', 'form', 'svg'])
      tag: RegExp('<\\s*$tag\\b[^>]*/\\s*>', caseSensitive: false),
  };

  // Pre-compiled pattern for extractOneLineDoc.
  static final _blankLine = RegExp(r'\n\s*\n');

  /// Processes the full documentation for [element], resolving cross-references
  /// and `{@inject-html}` placeholders.
  ///
  /// Returns clean markdown with:
  /// - All `[ClassName]` bracket references resolved to `[ClassName](url)`
  /// - All `<dartdoc-html>` placeholders replaced with actual HTML content
  /// - HTML from `{@youtube}`, `{@animation}` directives passed through
  String processDocumentation(ModelElement element) {
    var text = element.documentation;
    if (text.isEmpty) return '';

    text = _preprocess(text);
    return _resolveReferences(text, element);
  }

  /// Extracts the first paragraph from documentation as a one-line description.
  ///
  /// Used for library overview tables where only a brief description is needed.
  /// Processes the full documentation through [processDocumentation] first to
  /// resolve `[ClassName]` bracket references into proper markdown links, then
  /// extracts the first paragraph and collapses it to a single line.
  ///
  /// If the documentation is empty, returns an empty string.
  String extractOneLineDoc(ModelElement element) {
    final doc = element.documentation;
    if (doc.isEmpty) return '';

    // Process through the full pipeline to resolve bracket references.
    final processed = processDocumentation(element);
    if (processed.isEmpty) return '';

    // Take the first paragraph (up to the first blank line or end of text).
    final firstPara = processed.split(_blankLine).first.trim();

    // Collapse to a single line by replacing newlines with spaces.
    return firstPara.replaceAll('\n', ' ');
  }

  /// Processes raw documentation text that is not attached to a [ModelElement].
  ///
  /// Runs pre-processing (inject-html resolution, placeholder stripping) but
  /// does NOT resolve bracket references since there is no element context.
  /// Used for [Category] docs and other non-ModelElement documentation.
  String processRawDocumentation(String? text) {
    if (text == null || text.isEmpty) return '';
    return _preprocess(text);
  }

  /// Pre-processes raw documentation text before markdown parsing.
  ///
  /// Performs three transformations in order:
  /// 1. Resolves `<dartdoc-html>` placeholders to actual HTML fragments
  /// 2. Strips `htmlBasePlaceholder` strings (irrelevant for VitePress)
  /// 3. Replaces `<p>` joiners with double newlines (safety net)
  String _preprocess(String text) {
    // Step 1: Resolve {@inject-html} placeholders BEFORE markdown parsing.
    // The `documentation` getter contains `<dartdoc-html>HEXDIGEST</dartdoc-html>`
    // placeholders. We resolve them to actual HTML content so the markdown
    // parser sees them as raw HTML and passes them through.
    text = text.replaceAllMapped(
      _htmlInjectPattern,
      (m) => packageGraph.getHtmlFragment(m[1]!) ?? '',
    );

    // Step 2: Strip htmlBasePlaceholder -- it's an internal dartdoc artifact
    // that has no meaning in VitePress output.
    text = text.replaceAll(_htmlBasePlaceholder, '');

    // Step 3: Replace `<p>` joiners with double newlines.
    // The `documentation` getter joins multiple documentation sources with `<p>`.
    // In practice this never fires (confirmed dead code), but we handle it
    // as a safety net.
    text = text.replaceAll('<p>', '\n\n');

    return text;
  }

  /// Resolves bracket references in [text] by parsing it through the markdown
  /// parser with a custom `linkResolver`, then serializing the AST back to
  /// markdown.
  ///
  /// This approach correctly handles all edge cases:
  /// - `[operator []]` -- nested brackets
  /// - `` `code with [brackets]` `` -- inline code (not resolved)
  /// - ```` ```dart\n[list]\n``` ```` -- code fences (not resolved)
  /// - `[text](url)` -- existing links (preserved)
  /// - `[a] and [b]` -- multiple refs per line
  String _resolveReferences(String text, ModelElement element) {
    final document = md.Document(
      blockSyntaxes: _blockSyntaxes,
      inlineSyntaxes: _inlineSyntaxes,
      // `encodeHtml: false` is critical so that HTML from {@youtube},
      // {@inject-html}, etc. is NOT escaped to `&lt;`/`&gt;`.
      encodeHtml: false,
      linkResolver: (String name, [String? title]) =>
          _resolveLinkReference(name, element),
    );

    final nodes = document.parse(text);
    final rendered = MarkdownRenderer().render(nodes);
    return sanitizeHtml(rendered);
  }

  /// Strips dangerous HTML constructs from rendered documentation.
  ///
  /// Since `encodeHtml: false` is required for `{@youtube}` and
  /// `{@inject-html}` directives, raw HTML from doc comments passes through
  /// unescaped. This method removes:
  /// - Null bytes (bypass prevention)
  /// - `<script>` and `<style>` tags and their content
  /// - Dangerous embed elements (`<embed>`, `<object>`, `<applet>`, `<form>`)
  /// - `<iframe>` tags that are NOT YouTube embeds
  /// - `javascript:` URLs in href/src attributes
  /// - Inline event handlers (`on*=`)
  static String sanitizeHtml(String html) {
    // 1. Remove null bytes (bypass prevention).
    html = html.replaceAll('\x00', '');

    // 2. Remove <script> tags (handle whitespace in tag name: `< script>`).
    html = html.replaceAll(_scriptOpenClose, '');
    html = html.replaceAll(_scriptSelfClose, '');

    // 3. Remove <style> tags.
    html = html.replaceAll(_styleOpenClose, '');

    // 4. Remove dangerous embed elements.
    for (final tag in ['embed', 'object', 'applet', 'form', 'svg']) {
      html = html.replaceAll(_dangerousEmbedOpenClose[tag]!, '');
      html = html.replaceAll(_dangerousEmbedSelfClose[tag]!, '');
    }

    // 4b. Remove <base> tags (can hijack page base URL).
    html = html.replaceAll(_baseTag, '');

    // 4c. Remove <meta> tags (can redirect via http-equiv="refresh").
    html = html.replaceAll(_metaTag, '');

    // 4d. Remove <link> tags (can load external CSS for exfiltration).
    html = html.replaceAll(_linkTag, '');

    // 5. Remove <iframe> tags that are NOT YouTube/YouTube-nocookie embeds.
    //    Check the src attribute specifically to prevent bypass via other
    //    attributes (e.g. title="youtube.com").
    html = html.replaceAllMapped(
      _iframeTag,
      (match) {
        final tag = match.group(0)!;
        final srcMatch = _iframeSrcAttr.firstMatch(tag);
        if (srcMatch != null) {
          final src = srcMatch.group(1)!;
          if (src.contains('youtube.com') ||
              src.contains('youtube-nocookie.com')) {
            return tag; // Keep YouTube embeds.
          }
        }
        return ''; // Remove all other iframes.
      },
    );

    // 6. Remove javascript: URLs (use replaceAllMapped for backreference).
    html = html.replaceAllMapped(
      _javascriptUrl,
      (match) => '${match[1]}="',
    );

    // 6b. Remove data: URIs in href/src (can embed HTML/JS).
    html = html.replaceAllMapped(
      _dataUrl,
      (match) => '${match[1]}="',
    );

    // 7. Remove inline event handlers (on*="...", on*='...', on*=value).
    html = html.replaceAll(_eventHandler, '');

    // 8. Escape Vue template interpolation (VitePress renders md as Vue SFC).
    html = html.replaceAll('{{', r'\{\{');
    html = html.replaceAll('}}', r'\}\}');

    return html;
  }

  /// Resolves a single bracket reference `[referenceText]` found in a doc
  /// comment attached to [element].
  ///
  /// Uses the same resolution logic as dartdoc's `getMatchingLinkElement`
  /// function. For local elements, maps to VitePress URLs via
  /// [VitePressPathResolver]. For external elements (SDK, pub packages),
  /// delegates to the model's built-in [CommentReferable.href] which
  /// already computes correct remote URLs via [Package.baseHref] and the
  /// `linkToUrl`/`linkToRemote` options (matching the original dartdoc
  /// behavior in `_makeLinkNode`).
  ///
  /// Returns an `md.Element('a', ...)` with the resolved href, or `null`
  /// if the reference cannot be resolved (the markdown parser will render it
  /// as plain text).
  md.Node? _resolveLinkReference(String referenceText, ModelElement element) {
    if (referenceText.isEmpty) return null;

    final result = _resolveReference(referenceText, element);
    final linkedElement = result.commentReferable;

    if (linkedElement != null) {
      if (linkedElement is Documentable) {
        final documentable = linkedElement as Documentable;

        // Escape angle brackets in link text so VitePress/Vue doesn't
        // interpret generic type parameters (e.g. `<Object>`) as HTML
        // component tags.
        final safeText = _escapeLinkText(referenceText);

        // Always try VitePress path first. This handles both local elements
        // AND re-exported elements whose canonical library is in the local
        // package (e.g., `Binder` defined in `modularity_contracts` but
        // re-exported via `modularity_core`).
        final url = paths.linkFor(documentable);
        if (url != null) {
          final anchor = md.Element('a', [md.Text(safeText)]);
          anchor.attributes['href'] = url;
          return anchor;
        }

        // Fallback for truly external elements (SDK, pub packages): use
        // the model's built-in href which computes remote URLs via
        // Package.baseHref.
        if (linkedElement.href case var href?) {
          // Strip the htmlBasePlaceholder that dartdoc injects for local
          // packages. For external packages this is a no-op since their
          // href contains a full remote URL.
          href = href.replaceAll(_htmlBasePlaceholder, '');
          if (href.isNotEmpty) {
            final anchor = md.Element('a', [md.Text(safeText)]);
            anchor.attributes['href'] = href;
            return anchor;
          }
        }
      }

      // For non-Documentable referables or elements without URLs, render
      // as inline code.
      return md.Element.text('code', referenceText);
    }

    // Reference not resolved -- render as inline code, matching dartdoc's
    // behavior for unresolved references.
    return md.Element.text('code', referenceText);
  }

  /// Escapes `<` and `>` in link display text to prevent VitePress/Vue
  /// from interpreting generic type parameters as HTML tags.
  ///
  /// For example, `DiagnosticsProperty<Object>` becomes
  /// `DiagnosticsProperty\<Object\>` which renders correctly in markdown
  /// without triggering Vue's template compiler.
  static String _escapeLinkText(String text) {
    if (!text.contains('<')) return text;
    return text.replaceAll('<', r'\<').replaceAll('>', r'\>');
  }
}

/// Serializes a markdown AST (list of [md.Node]s) back to markdown text.
///
/// This renderer walks the AST produced by the `markdown` package's parser
/// and produces clean markdown output. It handles all common markdown
/// constructs including headings, paragraphs, emphasis, links, code blocks,
/// lists, blockquotes, and tables.
///
/// **Important:** The `markdown` v7 package uses only [md.Element] (with a
/// `tag` string property) and [md.Text] nodes. There are NO named classes
/// like `Emph`, `Strong`, or `Link`.
class MarkdownRenderer implements md.NodeVisitor {
  final StringBuffer _buffer = StringBuffer();

  /// Tracks the number of consecutive trailing newline characters in [_buffer].
  ///
  /// This avoids calling `_buffer.toString()` (which copies the entire buffer)
  /// just to check whether the buffer ends with `\n` or `\n\n`. Updated by
  /// [_writeToBuffer] and [_writelnToBuffer].
  int _trailingNewlines = 0;

  /// Stack of elements currently being visited, used for context-dependent
  /// rendering (e.g., detecting `<pre><code>` for fenced code blocks).
  final List<md.Element> _elementStack = [];

  /// Tracks the current ordered list index for proper numbering.
  /// Uses a stack to support nested ordered lists without overwriting
  /// the parent counter.
  final List<int> _orderedListStack = [];

  /// Tracks the current nesting depth of lists (ul and ol).
  /// Used to compute indentation for nested list items and code blocks.
  int _listDepth = 0;

  /// Tracks the current nesting depth of blockquotes.
  /// Used to compute the correct `> ` prefix for nested blockquotes.
  int _blockquoteDepth = 0;

  /// Whether we are currently inside a `<pre><code>` block (fenced code).
  /// Content inside should NOT be escaped.
  bool _inCodeBlock = false;

  /// Whether we are currently inside an inline `<code>` element.
  /// Content inside should NOT be escaped.
  bool _inInlineCode = false;

  /// Collects table rows during table rendering.
  final List<List<String>> _tableRows = [];

  /// Collects cells for the current table row.
  List<String>? _currentRowCells;

  /// Buffer for collecting cell content during table rendering.
  StringBuffer? _cellBuffer;

  /// Collects header alignments for table separator rendering.
  final List<String?> _tableAlignments = [];

  /// Renders a list of AST [nodes] to markdown text.
  String render(List<md.Node> nodes) {
    for (final node in nodes) {
      node.accept(this);
    }
    return _buffer.toString().trimRight();
  }

  /// Matches generic type parameter patterns like `<Object>`, `<T>`,
  /// `<DiagnosticsNode>`, `<Key, Value>` but NOT HTML tags like `<iframe>`,
  /// `</div>`, or Vue components.
  ///
  /// Pattern: `<` followed by an uppercase letter, then word chars and
  /// optional nested generics/commas, closed by `>`.
  static final _genericTypePattern = RegExp(
    r'<([A-Z]\w*(?:\s*,\s*[A-Z]\w*)*(?:<[^>]*>)?)>',
  );

  @override
  void visitText(md.Text text) {
    var content = text.textContent;

    // Escape generic type parameters in non-code contexts to prevent
    // VitePress/Vue from interpreting them as HTML component tags.
    //
    // Only targets patterns like `<Object>`, `<T>`, `<Key, Value>` --
    // these start with an uppercase letter (Dart naming convention).
    // HTML tags (`<iframe>`, `</div>`) and Vue components are left alone.
    //
    // Code blocks and inline code are exempt (rendered verbatim).
    if (!_inCodeBlock && !_inInlineCode && content.contains('<')) {
      content = content.replaceAllMapped(
        _genericTypePattern,
        (m) => r'\<' '${m[1]}' r'\>',
      );
    }

    if (_cellBuffer != null) {
      _cellBuffer!.write(content);
      return;
    }
    _writeToBuffer(content);
  }

  @override
  bool visitElementBefore(md.Element element) {
    _elementStack.add(element);

    switch (element.tag) {
      // Block-level elements: headings
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        _ensureBlankLine();
        final level = int.parse(element.tag.substring(1));
        _writeToBuffer('${'#' * level} ');
        return true;

      case 'p':
        if (_isInsideBlockquote()) {
          // Paragraphs inside blockquotes: prefix with `> ` if not the first.
          if (_isNotFirstChild(element)) {
            _writelnToBuffer();
            _writeToBuffer('> ' * _blockquoteDepth);
          }
        } else if (_isInsideListItem()) {
          // Paragraphs inside list items: separate with blank line if not first.
          if (_isNotFirstChild(element)) {
            _writelnToBuffer();
          }
        } else {
          _ensureBlankLine();
        }
        return true;

      case 'blockquote':
        _blockquoteDepth++;
        _ensureBlankLine();
        _writeToBuffer('> ' * _blockquoteDepth);
        return true;

      case 'pre':
        _ensureBlankLine();
        // Check if this is a fenced code block (pre > code).
        if (_hasSingleCodeChild(element)) {
          _inCodeBlock = true;
          final codeChild = element.children!.first as md.Element;
          final language = _extractLanguage(codeChild);
          final codeIndent = _listDepth > 0 ? '  ' * _listDepth : '';
          _writelnToBuffer('$codeIndent```$language');
          _renderCodeBlockContent(codeChild, indent: codeIndent);
          _writelnToBuffer();
          _writeToBuffer('$codeIndent```');
          _inCodeBlock = false;
          return false; // Don't visit children -- we already handled them.
        }
        // Non-code pre block -- just pass through content.
        return true;

      case 'code':
        if (_inCodeBlock) {
          // Already handled by the `pre` case above.
          return true;
        }
        _inInlineCode = true;
        _writeToTarget('`');
        return true;

      case 'em':
        _writeToTarget('*');
        return true;

      case 'strong':
        _writeToTarget('**');
        return true;

      case 'del':
        _writeToTarget('~~');
        return true;

      case 'a':
        // Links: `[text](href)`
        _writeToTarget('[');
        return true;

      case 'img':
        // Images: `![alt](src)`
        final alt = element.attributes['alt'] ?? '';
        final src = element.attributes['src'] ?? '';
        final title = element.attributes['title'];
        if (title != null) {
          _writeToTarget('![$alt]($src "$title")');
        } else {
          _writeToTarget('![$alt]($src)');
        }
        return false; // Self-closing, no children.

      case 'br':
        _writeToTarget('  \n');
        return false;

      case 'hr':
        _ensureBlankLine();
        _writeToBuffer('---');
        return false;

      case 'ul':
        if (!_isInsideListItem()) {
          _ensureBlankLine();
        }
        _listDepth++;
        return true;

      case 'ol':
        _orderedListStack.add(0);
        if (!_isInsideListItem()) {
          _ensureBlankLine();
        }
        _listDepth++;
        return true;

      case 'li':
        final indent = '  ' * (_listDepth - 1);
        final parentTag = _parentTag();
        if (parentTag == 'ol') {
          _orderedListStack.last++;
          _writeToBuffer('$indent${_orderedListStack.last}. ');
        } else {
          _writeToBuffer('$indent- ');
        }
        return true;

      // Table elements
      case 'table':
        _tableRows.clear();
        _tableAlignments.clear();
        _ensureBlankLine();
        return true;

      case 'thead' || 'tbody':
        return true;

      case 'tr':
        _currentRowCells = [];
        return true;

      case 'th' || 'td':
        _cellBuffer = StringBuffer();
        // Track alignment from header cells.
        if (element.tag == 'th') {
          _tableAlignments.add(element.attributes['style']);
        }
        return true;

      default:
        // Unknown or raw HTML elements -- pass through as HTML.
        _writeToTarget(_openTag(element));
        return true;
    }
  }

  @override
  void visitElementAfter(md.Element element) {
    _elementStack.removeLast();

    switch (element.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        // Add generated ID as custom heading ID if present.
        if (element.generatedId != null) {
          _writeToBuffer(' {#${element.generatedId}}');
        }
        _writelnToBuffer();

      case 'p':
        if (_isInsideBlockquote()) {
          _writelnToBuffer();
        } else if (_isInsideListItem()) {
          _writelnToBuffer();
        } else {
          _writelnToBuffer();
          _writelnToBuffer();
        }

      case 'blockquote':
        _blockquoteDepth--;
        // Ensure trailing newline after blockquote.
        if (_trailingNewlines < 1) {
          _writelnToBuffer();
        }

      case 'code':
        if (!_inCodeBlock) {
          _inInlineCode = false;
          _writeToTarget('`');
        }

      case 'em':
        _writeToTarget('*');

      case 'strong':
        _writeToTarget('**');

      case 'del':
        _writeToTarget('~~');

      case 'a':
        final href = element.attributes['href'] ?? '';
        final title = element.attributes['title'];
        if (title != null) {
          _writeToTarget(']($href "$title")');
        } else {
          _writeToTarget(']($href)');
        }

      case 'li':
        if (_trailingNewlines < 1) {
          _writelnToBuffer();
        }

      case 'ul':
        _listDepth--;

      case 'ol':
        _listDepth--;
        _orderedListStack.removeLast();

      case 'tr':
        if (_currentRowCells != null) {
          _tableRows.add(_currentRowCells!);
          _currentRowCells = null;
        }

      case 'th' || 'td':
        if (_cellBuffer != null && _currentRowCells != null) {
          _currentRowCells!.add(_cellBuffer!.toString().trim());
          _cellBuffer = null;
        }

      case 'table':
        _renderTable();

      case 'thead' || 'tbody':
        break;

      default:
        // Close unknown/raw HTML tags.
        if (element.children != null) {
          _writeToTarget('</${element.tag}>');
          // Add a newline after block-level HTML elements so adjacent blocks
          // (e.g. consecutive <div> alert containers) are separated properly.
          if (_cellBuffer == null && _isBlockLevelTag(element.tag)) {
            _writelnToBuffer();
          }
        }
    }
  }

  /// Block-level HTML tags that need newline separation in markdown output.
  static const _blockLevelTags = {
    'div',
    'section',
    'article',
    'aside',
    'header',
    'footer',
    'nav',
    'main',
    'figure',
    'figcaption',
    'details',
    'summary',
    'dialog',
    'address',
  };

  /// Whether [tag] is a block-level HTML element.
  static bool _isBlockLevelTag(String tag) =>
      _blockLevelTags.contains(tag.toLowerCase());

  // ---------------------------------------------------------------------------
  // Helper methods
  // ---------------------------------------------------------------------------

  /// Writes [text] to the main buffer and updates [_trailingNewlines].
  ///
  /// All writes to [_buffer] should go through this method (or
  /// [_writelnToBuffer]) so that the trailing-newline counter stays in sync.
  void _writeToBuffer(String text) {
    _buffer.write(text);
    _updateTrailingNewlines(text);
  }

  /// Writes [text] followed by a newline to the main buffer and updates
  /// [_trailingNewlines].
  void _writelnToBuffer([String text = '']) {
    _buffer.writeln(text);
    if (text.isEmpty) {
      // writeln('') writes just '\n'.
      _trailingNewlines++;
    } else {
      // writeln(text) writes text + '\n', so exactly 1 trailing newline.
      _trailingNewlines = 1;
    }
  }

  /// Updates [_trailingNewlines] based on the characters at the end of [text].
  void _updateTrailingNewlines(String text) {
    if (text.isEmpty) return;
    // Count trailing '\n' characters from the end of text.
    var count = 0;
    for (var i = text.length - 1; i >= 0 && text.codeUnitAt(i) == 0x0A; i--) {
      count++;
    }
    if (count == text.length) {
      // The entire text is newlines — add to existing count.
      _trailingNewlines += count;
    } else {
      // Text contains non-newline characters, so reset and count from end.
      _trailingNewlines = count;
    }
  }

  /// Writes [text] to either the cell buffer (if inside a table cell) or
  /// the main buffer.
  void _writeToTarget(String text) {
    if (_cellBuffer != null) {
      _cellBuffer!.write(text);
    } else {
      _writeToBuffer(text);
    }
  }

  /// Ensures the buffer ends with a blank line (two newlines) for block
  /// element separation. Does nothing if the buffer is empty.
  void _ensureBlankLine() {
    if (_buffer.isEmpty) return;
    if (_trailingNewlines >= 2) return;
    if (_trailingNewlines == 1) {
      _writelnToBuffer();
    } else {
      _writelnToBuffer();
      _writelnToBuffer();
    }
  }

  /// Returns the tag of the parent element, or `null` if at the top level.
  String? _parentTag() {
    if (_elementStack.length < 2) return null;
    return _elementStack[_elementStack.length - 2].tag;
  }

  /// Returns `true` if we are currently inside a `blockquote` element.
  bool _isInsideBlockquote() {
    for (var i = _elementStack.length - 2; i >= 0; i--) {
      if (_elementStack[i].tag == 'blockquote') return true;
    }
    return false;
  }

  /// Returns `true` if we are currently inside a `li` element.
  bool _isInsideListItem() {
    for (var i = _elementStack.length - 2; i >= 0; i--) {
      if (_elementStack[i].tag == 'li') return true;
    }
    return false;
  }

  /// Returns `true` if [element] is not the first child of its parent.
  bool _isNotFirstChild(md.Element element) {
    if (_elementStack.length < 2) return false;
    final parent = _elementStack[_elementStack.length - 2];
    final children = parent.children;
    if (children == null || children.isEmpty) return false;
    return !identical(children.first, element);
  }

  /// Returns `true` if [element] is a `<pre>` containing exactly one
  /// `<code>` child element.
  bool _hasSingleCodeChild(md.Element element) {
    final children = element.children;
    if (children == null || children.length != 1) return false;
    final child = children.first;
    return child is md.Element && child.tag == 'code';
  }

  /// Extracts the language identifier from a fenced code block's `<code>`
  /// element, typically stored in the `class` attribute as `language-<name>`.
  String _extractLanguage(md.Element codeElement) {
    final className = codeElement.attributes['class'] ?? '';
    if (className.startsWith('language-')) {
      return className.substring('language-'.length);
    }
    return '';
  }

  /// Renders the text content of a fenced code block's `<code>` element.
  ///
  /// Code block content is rendered verbatim (no escaping). When [indent] is
  /// provided (non-empty), each line of the code block is prefixed with it,
  /// which is necessary for code blocks inside list items.
  void _renderCodeBlockContent(md.Element codeElement, {String indent = ''}) {
    final content = codeElement.textContent;
    // Remove trailing newline if present (the closing ``` will add its own).
    final trimmed = content.endsWith('\n')
        ? content.substring(0, content.length - 1)
        : content;
    if (indent.isNotEmpty) {
      final lines = trimmed.split('\n');
      _writeToBuffer(lines.map((line) => '$indent$line').join('\n'));
    } else {
      _writeToBuffer(trimmed);
    }
  }

  /// Constructs an HTML opening tag string for unknown/pass-through elements.
  String _openTag(md.Element element) {
    final sb = StringBuffer('<${element.tag}');
    for (final entry in element.attributes.entries) {
      final escaped = entry.value
          .replaceAll('&', '&amp;')
          .replaceAll('"', '&quot;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      sb.write(' ${entry.key}="$escaped"');
    }
    if (element.isEmpty) {
      sb.write(' />');
    } else {
      sb.write('>');
    }
    return sb.toString();
  }

  /// Renders the collected table data as a markdown table.
  void _renderTable() {
    if (_tableRows.isEmpty) return;

    final headerRow = _tableRows.first;
    final columnCount = headerRow.length;

    // Render header row.
    _writeToBuffer('| ');
    _writeToBuffer(headerRow.join(' | '));
    _writelnToBuffer(' |');

    // Render separator row with alignment.
    _writeToBuffer('|');
    for (var i = 0; i < columnCount; i++) {
      final alignment =
          i < _tableAlignments.length ? _tableAlignments[i] : null;
      if (alignment != null && alignment.contains('text-align: center')) {
        _writeToBuffer(':---:|');
      } else if (alignment != null && alignment.contains('text-align: right')) {
        _writeToBuffer('---:|');
      } else if (alignment != null && alignment.contains('text-align: left')) {
        _writeToBuffer(':---|');
      } else {
        _writeToBuffer('---|');
      }
    }
    _writelnToBuffer();

    // Render body rows (skip header row).
    for (var r = 1; r < _tableRows.length; r++) {
      final row = _tableRows[r];
      _writeToBuffer('| ');
      // Pad row to match column count if needed.
      final paddedRow = List<String>.generate(
        columnCount,
        (i) => i < row.length ? row[i] : '',
      );
      _writeToBuffer(paddedRow.join(' | '));
      _writelnToBuffer(' |');
    }
  }
}
