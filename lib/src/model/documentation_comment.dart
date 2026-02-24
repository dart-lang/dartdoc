// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'package:dartdoc/src/model/package_graph.dart';
library;

import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:args/args.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dartdoc/src/model/category.dart';
import 'package:dartdoc/src/model/documentation.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/source_code_mixin.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;

final _templatePattern =
    RegExp(r'[ ]*\{@template\s+([^\s}].*?)\}([^]+?)\{@endtemplate\}[ ]*(\n?)');
final _htmlPattern =
    RegExp(r'[ ]*\{@inject-html\s*\}([^]+?)\{@end-inject-html\}[ ]*\n?');

/// Matches all tool directives (even some invalid ones). This is so
/// we can give good error messages if the directive is malformed, instead of
/// just silently emitting it as-is.
final _basicToolPattern =
    RegExp(r'[ ]*{@tool\s+([^\s}][^}]*)}\n?([^]+?)\n?{@end-tool}[ ]*\n?');

final _macroRegExp = RegExp(r'{@macro\s+([^\s}][^}]*)}');

final _htmlInjectRegExp = RegExp(r'<dartdoc-html>([a-f0-9]+)</dartdoc-html>');

final _lineEndingRegExp = RegExp(r'\r\n?');

final _exampleRegExp = RegExp(
  r'^[ \t]*\{@example(?:[ \t]+([^}\r\n]*))?\}[ \t]*$',
  multiLine: true,
);

/// Features for processing directives in a documentation comment.
///
/// [_processCommentWithoutTools] and [processComment] are the primary
/// entrypoints.
mixin DocumentationComment implements Warnable, SourceCode {
  @override
  Element get element;

  @override
  late final String documentationAsHtml =
      _injectHtmlFragments(_elementDocumentation.asHtml);

  String get oneLineDoc => _elementDocumentation.asOneLiner;

  late final Documentation _elementDocumentation =
      Documentation.forElement(this);

  /// The rawest form of [element]'s documentation comment, if there is one,
  /// including comment delimiters like `///`, `//`, `/*`, `*/`, or `null` if
  /// there is no documentation comment.
  String? get documentationComment => element.documentationComment;

  /// Whether [element] has a documentation comment.
  bool get hasDocumentationComment => element.documentationComment != null;

  /// Whether the raw documentation comment is considered to be 'nodoc', an
  /// attribute indicating that any documentation should not be included in
  /// dartdoc's generated output.
  ///
  /// An element is considered to be 'nodoc' if any of the following are true:
  /// * the element has no documentation comment,
  /// * the documentation comment contains the `@nodoc` dartdoc directive.
  bool get hasNodoc => documentationComment?.contains('@nodoc') ?? false;

  /// Processes a [documentationComment], performing various actions based on
  /// `{@}`-style directives (except tool directives), returning the processed
  /// result.
  String _processCommentWithoutTools() {
    if (documentationComment case var comment?) {
      // We must first strip the comment of directives like `@docImport`, since
      // the offsets are for the source text.
      var docs = _stripDocImports(comment);
      docs = stripCommentDelimiters(docs);
      // TODO(srawlins): Processing templates here causes #2281. But leaving
      // them unprocessed causes #2272.
      return _processCommentDirectives(docs, processMacros: false);
    }
    return '';
  }

  /// Process [documentationComment], performing various actions based on
  /// `{@}`-style directives, returning the processed result.
  @visibleForTesting
  Future<String> processComment() async {
    if (documentationComment case var comment?) {
      // We must first strip the comment of directives like `@docImport`, since
      // the offsets are for the source text.
      var docs = _stripDocImports(comment);
      docs = stripCommentDelimiters(docs);
      // Then we evaluate tools, in case they insert any other directives that
      // would need to be processed by `processCommentDirectives`.
      docs = await _evaluateTools(docs);
      return _processCommentDirectives(docs);
    }
    return '';
  }

  String _processCommentDirectives(String docs, {bool processMacros = true}) {
    // The vast, vast majority of doc comments have no directives.
    if (docs.contains('{@')) {
      _checkForUnknownDirectives(docs);
      docs = _injectExamples(docs);
      docs = _injectYouTube(docs);
      docs = _injectAnimations(docs);
      if (processMacros) {
        docs = _stripMacroTemplatesAndAddToIndex(docs);
      }
      docs = _stripHtmlAndAddToIndex(docs);
    }
    docs = _stripAndSetCategories(docs);
    return _stripCanonicalFor(docs);
  }

  /// Parse `{@category ...}` and related information in API comments, stripping
  /// out that information from the given comments and returning the stripped
  /// version.
  String _stripAndSetCategories(String rawDocs) {
    _ensureInitialCategorization();
    final parsed = parseCategorization(rawDocs);
    _categoryNamesSet.addAll(parsed.categories);
    _subCategoryNamesSet.addAll(parsed.subCategories);
    return rawDocs.replaceAll(_categoryRegExp, '');
  }

  @visibleForTesting
  ({List<String> categories, List<String> subCategories}) parseCategorization(
      String docs) {
    Set<String>? categorySet;
    Set<String>? subCategorySet;

    for (var match in _categoryRegExp.allMatches(docs)) {
      switch (match[1]) {
        case 'category':
          (categorySet ??= {}).add(match[2]!.trim());
        case 'subCategory':
          (subCategorySet ??= {}).add(match[2]!.trim());
      }
    }

    return (
      categories: categorySet == null
          ? const []
          : (categorySet.toList(growable: false)..sort()),
      subCategories: subCategorySet == null
          ? const []
          : (subCategorySet.toList(growable: false)..sort()),
    );
  }

  final Set<String> _categoryNamesSet = {};
  final Set<String> _subCategoryNamesSet = {};
  bool _initialCategorizationDone = false;

  void _ensureInitialCategorization() {
    if (_initialCategorizationDone) return;
    _initialCategorizationDone = true;
    if (documentationComment case var comment?) {
      final parsed = parseCategorization(
          stripCommentDelimiters(_stripDocImports(comment)));
      _categoryNamesSet.addAll(parsed.categories);
      _subCategoryNamesSet.addAll(parsed.subCategories);
    }
  }

  String? get sourceFileName;

  /// The name of this element, qualified with any enclosing element(s), up to
  /// but not including an enclosing library.
  @visibleForOverriding
  String get qualifiedName;

  p.Context get pathContext;

  static const _allDirectiveNames = {
    'animation',
    'end-inject-html',
    'end-tool',
    'endtemplate',
    'example',
    'macro',
    'inject-html',
    'template',
    'tool',
    'youtube',

    // Other directives, parsed by `model/directives/*.dart`:
    'canonicalFor',
    'category',
    'subCategory',

    // Common Dart annotations which may decorate named parameters:
    'deprecated',
    'required',
  };

  static final _nameBreak = RegExp(r'[\s}]');

  // TODO(srawlins): Implement more checks; see
  // https://github.com/dart-lang/dartdoc/issues/1814.
  void _checkForUnknownDirectives(String docs) {
    var index = 0;
    while (true) {
      var nameStartIndex = docs.indexOf('{@', index);
      if (nameStartIndex == -1) return;
      var nameEndIndex = docs.indexOf(_nameBreak, nameStartIndex + 2);
      if (nameEndIndex == -1) return;
      var name = docs.substring(nameStartIndex + 2, nameEndIndex);
      if (!_allDirectiveNames.contains(name)) {
        // Ignore unknown directive name; the analyzer now reports this
        // natively.
      }
      // TODO(srawlins): Replace all `replaceAllMapped` usage within this file,
      // running regex after regex over [docs], with simple calls here. This has
      // interactivity / order-of-operations consequences, so take care.
      index = nameEndIndex;
    }
  }

  /// Replace &#123;@tool ...&#125&#123;@end-tool&#125; in API comments with the
  /// output of an external tool.
  ///
  /// Looks for tools invocations, looks up their bound executables in the
  /// options, and executes them with the source comment material as input,
  /// returning the output of the tool. If a named tool isn't configured in the
  /// options file, then it will not be executed, and dartdoc will quit with an
  /// error.
  ///
  /// Tool command line arguments are passed to the tool, with the token
  /// `$INPUT` replaced with the absolute path to a temporary file containing
  /// the content for the tool to read and produce output from. If the tool
  /// doesn't need any input, then no `$INPUT` is needed.
  ///
  /// Nested tool directives will not be evaluated, but tools may generate other
  /// directives in their output and those will be evaluated.
  ///
  /// Syntax:
  ///
  ///     &#123;@tool TOOL [Tool arguments]&#125;
  ///     Content to send to tool.
  ///     &#123;@end-tool&#125;
  ///
  /// Examples:
  ///
  /// In `dart_options.yaml`:
  ///
  /// ```yaml
  /// dartdoc:
  ///   tools:
  ///     prefix:
  ///       # Path is relative to project root.
  ///       command: ["bin/prefix.dart"]
  ///       description: "Prefixes the given input with '##'."
  ///       compile_args: ["--no-sound-null-safety"]
  ///     date:
  ///       command: ["/bin/date"]
  ///       description: "Prints the date"
  /// ```
  ///
  /// In code:
  ///
  /// _This:_
  ///
  ///     &#123;@tool prefix $INPUT&#125;
  ///     Content to send to tool.
  ///     &#123;@end-tool&#125;
  ///     &#123;@tool date --iso-8601=minutes --utc&#125;
  ///     &#123;@end-tool&#125;
  ///
  /// _Produces:_
  ///
  /// ## Content to send to tool.
  /// 2018-09-18T21:15+00:00
  Future<String> _evaluateTools(String rawDocs) async {
    if (!config.allowTools) {
      return rawDocs;
    }
    var invocationIndex = 0;
    return await _replaceAllMappedAsync(rawDocs, _basicToolPattern,
        (basicMatch) async {
      final args = _splitUpQuotedArgs(basicMatch[1]!);
      // Tool name must come first.
      if (args.isEmpty) {
        warn(PackageWarning.toolError,
            message: 'Must specify a tool to execute for the @tool directive.');
        return Future.value('');
      }
      // Count the number of invocations of tools in this dartdoc block,
      // so that tools can differentiate different blocks from each other.
      invocationIndex++;
      return await config.tools.runner.run(args.toList(),
          content: basicMatch[2]!, toolErrorCallback: (String message) async {
        warn(PackageWarning.toolError, message: message);
      }, environment: _toolsEnvironment(invocationIndex: invocationIndex));
    });
  }

  /// The environment variables to use when running a tool.
  Map<String, String> _toolsEnvironment({required int invocationIndex}) {
    var self = this;
    var library = self is ModelElement
        ? (self.canonicalLibrary ?? this.library)
        : this.library;
    var env = {
      'SOURCE_LINE': characterLocation?.lineNumber.toString(),
      'SOURCE_COLUMN': characterLocation?.columnNumber.toString(),
      if (sourceFileName case var sourceFileName?)
        'SOURCE_PATH':
            pathContext.relative(sourceFileName, from: package.packagePath),
      'PACKAGE_PATH': package.packagePath,
      'PACKAGE_NAME': package.name,
      'LIBRARY_NAME': library?.fullyQualifiedName,
      'ELEMENT_NAME': qualifiedName,
      'INVOCATION_INDEX': invocationIndex.toString(),
      'PACKAGE_INVOCATION_INDEX': (package.toolInvocationIndex++).toString(),
    };
    return (env..removeWhere((key, value) => value == null))
        .cast<String, String>();
  }

  /// Replace &#123;@example ...&#125; in API comments with a fenced code block
  /// containing the contents of the specified file.
  ///
  /// This is a block-level directive and must appear on its own line.
  ///
  /// Syntax:
  ///
  ///     &#123;@example <path> [lang=LANGUAGE] [indent=keep|strip]&#125;
  ///
  /// The `path` is resolved relative to the current file's path, using the
  /// package's root as the root path;
  /// see [resolveExamplePath] for details.
  ///
  /// The file content is processed as follows:
  /// - Line endings are normalized to `\n`.
  /// - If `indent` is `strip` (the default), common indentation is removed from
  ///   all lines. Whitespace-only lines are ignored for calculation and
  ///   normalized to empty lines.
  /// - If `indent` is `keep`, the indentation is left as-is.
  /// - If any line has non-space characters in its indentation and `indent` is
  ///   `strip`, a warning is issued and indentation stripping is skipped to
  ///   prevent broken formatting.
  ///
  /// The `lang` parameter specifies the language for the fenced code block. If
  /// not provided, it defaults to the file extension of `path`.
  ///
  /// Example:
  ///
  ///     &#123;@example /examples/my_example.dart&#125;
  ///     &#123;@example ../subdir/utils.dart lang=dart indent=strip&#125;
  ///     &#123;@example ../subdir/utils.dart indent=keep&#125;
  String _injectExamples(String rawDocs) {
    return rawDocs.replaceAllMapped(_exampleRegExp, (match) {
      var argsAsString = match[1];
      if (argsAsString == null) {
        warn(PackageWarning.invalidParameter,
            message: 'Must specify a file path for the @example directive.');
        return '';
      }
      var args = _parseArgs(argsAsString, _exampleArgParser, 'example');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      if (args.rest.isEmpty) {
        warn(PackageWarning.invalidParameter,
            message: 'Must specify a file path for the @example directive.');
        return '';
      }

      if (args.rest.length > 1) {
        warn(PackageWarning.invalidParameter,
            message:
                'The {@example} directive only takes one positional argument (the file path). '
                'Ignoring extra arguments: ${args.rest.skip(1).join(" ")}');
      }

      var filepath = args.rest.first;
      // TODO(zarah): Add support for regions (#region, #endregion).

      var resolvedPath = resolveExamplePath(
        filepath,
        packagePath: package.packagePath,
        sourceFilePath: sourceFileName,
        pathContext: pathContext,
        warn: warn,
      );
      if (resolvedPath == null) return '';

      var file = packageGraph.resourceProvider.getFile(resolvedPath);
      if (!file.exists) {
        warn(PackageWarning.missingExampleFile, message: filepath);
        return '';
      }

      var extension = pathContext
          .extension(resolvedPath)
          .replaceFirst('.', '')
          .toLowerCase();
      var language = args['lang'] ?? extension;
      var indent = args['indent'] ?? 'strip';

      var content = file.readAsStringSync();
      // Normalize line endings to \n.
      content = content.replaceAll(_lineEndingRegExp, '\n');

      if (indent == 'strip') {
        content = _stripIndentation(content, warn);
      }

      // Ensure the content ends with exactly one newline before the closing fence.
      var trailing = content.endsWith('\n') ? '' : '\n';

      return '\n```$language\n$content$trailing```\n';
    });
  }

  /// Resolves the given [exampleFilePath] as a URI reference relative to the current
  /// package root.
  ///
  /// The [exampleFilePath] is resolved as follows:
  /// - If it starts with a leading `/`, it is resolved relative to the package
  ///   root.
  /// - Otherwise, it is resolved relative to the file containing the
  ///   documentation comment (rooted at the package root).
  /// - Resolution follows URI reference rules, ensuring that `..` segments
  ///   stop at the package root and never escape it.
  /// - [exampleFilePath] must be a valid URI path (using `/` as separator), and can
  ///   include URI-encoded characters (like `%20` for spaces).
  /// - Absolute URIs (e.g. starting with `https:`) are not supported.
  ///
  /// Returns the absolute path of the resolved file, or `null` if
  /// [exampleFilePath] is not a valid URI reference or has an unsupported scheme.
  ///
  /// The [packagePath] is the file system path of the root of the current package,
  /// in the form used by [pathContext].
  ///
  /// The [sourceFilePath] is the file system path of the file containing the example
  /// link in the form used by [pathContext].
  /// If provided, it must be within the package root given by [packagePath].
  /// If absent, the [exampleFilePath] is resolved relative to the package root.
  ///
  @visibleForTesting
  static String? resolveExamplePath(
    String exampleFilePath, {
    required String packagePath,
    required String? sourceFilePath,
    required p.Context pathContext,
    required void Function(PackageWarning, {String? message}) warn,
  }) {
    assert(sourceFilePath == null ||
        pathContext.isWithin(packagePath, sourceFilePath));

    // Resolve the path as a URI reference.
    // 1. Get the relative path of the current file from the package root.
    var relativePath = sourceFilePath != null
        ? pathContext.relative(sourceFilePath, from: packagePath)
        : '';

    // 2. Convert to a URI, rooted at the file system root.
    // We explicitly join with [pathContext.separator] to create an
    // absolute-like path (e.g., "\lib\src\foo.dart" on Windows), which [toUri]
    // converts to a file URI (potentially including a drive letter,
    // e.g., "file:///C:/lib/...").
    var baseUri = pathContext
        .toUri(pathContext.join(pathContext.separator, relativePath));

    // 3. Resolve using [Uri.resolveUri].
    // [exampleFilePath] is interpreted as a URI reference.
    String resolvedPath;
    try {
      var exampleFileUri = Uri.parse(exampleFilePath);
      if (exampleFileUri.hasScheme || exampleFileUri.hasAuthority) {
        warn(PackageWarning.invalidParameter,
            message:
                '@example path "$exampleFilePath" must be a local file path. '
                'Schemes and authorities are not allowed.');
        return null;
      }
      var resolvedUri = baseUri.resolveUri(exampleFileUri);

      // 4. Convert back to a package-relative file path.
      // [fromUri] returns an absolute path (e.g., "C:\lib\example.dart").
      // We calculate the path relative to the file system root ([separator])
      // to strip any drive letters or root prefixes, ensuring we can safely
      // join it back to [packagePath].
      var relativeToRoot = pathContext.relative(
        pathContext.fromUri(resolvedUri),
        from: pathContext.separator,
      );

      resolvedPath = pathContext.join(packagePath, relativeToRoot);
    } on FormatException catch (e) {
      warn(PackageWarning.invalidParameter,
          message:
              'Invalid path for @example directive ($exampleFilePath): ${e.message}');
      return null;
    }

    resolvedPath = pathContext.normalize(resolvedPath);

    // Security check: theoretically unreachable due to Uri resolution clamping,
    // but kept as a safeguard against future refactoring bugs.
    if (!pathContext.isWithin(packagePath, resolvedPath) &&
        !pathContext.equals(packagePath, resolvedPath)) {
      warn(PackageWarning.invalidParameter,
          message:
              'Example file $exampleFilePath must be within the package root ($packagePath).');
      return null;
    }

    return resolvedPath;
  }

  /// Strips the common indentation from [content].
  ///
  /// Whitespace-only lines are ignored when calculating the common indentation
  /// and are normalized to empty strings in the output.
  ///
  /// If any line has non-space characters in its indentation, a warning is issued
  /// and the original [content] is returned.
  static String _stripIndentation(
      String content, void Function(PackageWarning, {String? message}) warn) {
    var lines = LineSplitter.split(content).toList();
    if (lines.isEmpty) return content;

    int? minIndent;
    var anyWhitespaceLineChanged = false;
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      var trimmed = line.trimLeft();
      if (trimmed.isEmpty) {
        // Normalization: Clear whitespace-only lines so they don't count for indent.
        if (line.isNotEmpty) {
          lines[i] = '';
          anyWhitespaceLineChanged = true;
        }
        continue;
      }

      var indentLength = line.length - trimmed.length;
      var indentation = line.substring(0, indentLength);

      for (var j = 0; j < indentLength; j++) {
        if (indentation.codeUnitAt(j) != 0x20) {
          warn(PackageWarning.invalidParameter,
              message:
                  'Example contains non-space whitespace in indentation. Indentation stripping '
                  'disabled to avoid incorrect formatting.');
          return content;
        }
      }

      if (minIndent == null || indentLength < minIndent) {
        minIndent = indentLength;
      }
    }

    if (minIndent == null || minIndent == 0) {
      return anyWhitespaceLineChanged ? lines.join('\n') : content;
    }

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.isNotEmpty) lines[i] = line.substring(minIndent);
    }
    return lines.join('\n');
  }

  static final _exampleArgParser = ArgParser()
    ..addOption('lang')
    ..addOption('indent', allowed: ['keep', 'strip'], defaultsTo: 'strip');

  /// Matches all youtube directives (even some invalid ones). This is so
  /// we can give good error messages if the directive is malformed, instead of
  /// just silently emitting it as-is.
  static final _basicYouTubePattern = RegExp(r'{@youtube\s+([^\s}][^}]*)}');

  /// Matches YouTube IDs from supported YouTube URLs.
  static final _validYouTubeUrlPattern =
      RegExp(r'https://www\.youtube\.com/watch\?v=([^&]+)$');

  /// An argument parser used in [_injectYouTube] to parse a `{@youtube}`
  /// directive.
  static final _youTubeArgParser = ArgParser();

  /// Replace &#123;@youtube ...&#125; in API comments with some HTML to embed
  /// a YouTube video.
  ///
  /// Syntax:
  ///
  ///     &#123;@youtube WIDTH HEIGHT URL&#125;
  ///
  /// Example:
  ///
  ///     &#123;@youtube 560 315 https://www.youtube.com/watch?v=oHg5SJYRHA0&#125;
  ///
  /// Which will embed a YouTube player into the page that plays the specified
  /// video.
  ///
  /// The width and height must be positive integers specifying the dimensions
  /// of the video in pixels. The height and width are used to calculate the
  /// aspect ratio of the video; the video is always rendered to take up all
  /// available horizontal space to accommodate different screen sizes on
  /// desktop and mobile.
  ///
  /// The video URL must have the following format:
  /// https://www.youtube.com/watch?v=oHg5SJYRHA0. This format can usually be
  /// found in the address bar of the browser when viewing a YouTube video.
  String _injectYouTube(String rawDocs) {
    return rawDocs.replaceAllMapped(_basicYouTubePattern, (basicMatch) {
      var args = _parseArgs(basicMatch[1]!, _youTubeArgParser, 'youtube');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      var positionalArgs = args.rest.sublist(0);
      if (positionalArgs.length != 3) {
        warn(PackageWarning.invalidParameter,
            message: 'Invalid @youtube directive, "${basicMatch[0]}"\n'
                'YouTube directives must be of the form "{@youtube WIDTH '
                'HEIGHT URL}"');
        return '';
      }

      var width = int.tryParse(positionalArgs[0]);
      if (width == null || width <= 0) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid width, '
                '"${positionalArgs[0]}". The width must be a positive '
                'integer.');
        return '';
      }

      var height = int.tryParse(positionalArgs[1]);
      if (height == null || height <= 0) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid height, '
                '"${positionalArgs[1]}". The height must be a positive '
                'integer.');
        return '';
      }

      var url = _validYouTubeUrlPattern.firstMatch(positionalArgs[2]);
      if (url == null) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid URL: '
                '"${positionalArgs[2]}". Supported YouTube URLs have the '
                'following format: '
                'https://www.youtube.com/watch?v=oHg5SJYRHA0.');
        return '';
      }
      var youTubeId = url.group(url.groupCount)!;

      // Blank lines before and after, and no indenting at the beginning and end
      // is needed so that Markdown doesn't confuse this with code, so be
      // careful of whitespace here.
      return '''

<iframe src="https://www.youtube.com/embed/$youTubeId?rel=0" 
        title="YouTube video player" 
        frameborder="0" 
        allow="accelerometer; 
               autoplay; 
               clipboard-write; 
               encrypted-media; 
               gyroscope; 
               picture-in-picture" 
        allowfullscreen="" 
        style="max-width: ${width}px;
               max-height: ${height}px;
               width: 100%;
               height: 100%;
               aspect-ratio: $width / $height;">
</iframe>

'''; // Must end at start of line, or following inline text will be indented.
    });
  }

  /// Matches all animation directives (even some invalid ones). This is so we
  /// can give good error messages if the directive is malformed, instead of
  /// just silently emitting it as-is.
  static final _basicAnimationPattern = RegExp(r'{@animation\s+([^\s}][^}]*)}');

  /// Matches valid JavaScript identifiers.
  static final _validIdPattern = RegExp(r'^[a-zA-Z_]\w*$');

  /// An argument parser used in [_injectAnimations] to parse an `{@animation}`
  /// directive.
  static final _animationArgParser = ArgParser()..addOption('id');

  /// Replace &#123;@animation ...&#125; in API comments with some HTML to
  /// manage an MPEG 4 video as an animation.
  ///
  /// Syntax:
  ///
  ///     &#123;@animation WIDTH HEIGHT URL [id=ID]&#125;
  ///
  /// Example:
  ///
  ///     &#123;@animation 300 300 https://example.com/path/to/video.mp4 id="my_video"&#125;
  ///
  /// Which will render the HTML necessary for embedding a simple click-to-play
  /// HTML5 video player with no controls that has an HTML id of "my_video".
  ///
  /// The optional ID should be a unique id that is a valid JavaScript
  /// identifier, and will be used as the id for the video tag. If no ID is
  /// supplied, then a unique identifier (starting with "animation_") will be
  /// generated.
  ///
  /// The width and height must be integers specifying the dimensions of the
  /// video file in pixels.
  String _injectAnimations(String rawDocs) {
    String getUniqueId(String base) {
      var animationIdCount = 1;
      var id = '$base$animationIdCount';
      // We check for duplicate IDs so that we make sure not to collide with
      // user-supplied ids on the same page.
      while (package.usedAnimationIdsByHref[href]!.contains(id)) {
        animationIdCount++;
        id = '$base$animationIdCount';
      }
      return id;
    }

    return rawDocs.replaceAllMapped(_basicAnimationPattern, (basicMatch) {
      // Make sure we have a set to keep track of used IDs for this href.
      package.usedAnimationIdsByHref[href] ??= {};

      var args = _parseArgs(basicMatch[1]!, _animationArgParser, 'animation');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      final positionalArgs = args.rest.sublist(0);
      String uniqueId;
      if (positionalArgs.length == 3) {
        uniqueId = args['id'] ?? getUniqueId('animation_');
      } else {
        warn(PackageWarning.invalidParameter,
            message: 'Invalid @animation directive, "${basicMatch[0]}"\n'
                'Animation directives must be of the form "{@animation WIDTH '
                'HEIGHT URL [id=ID]}"');
        return '';
      }

      if (!_validIdPattern.hasMatch(uniqueId)) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has an invalid identifier, "$uniqueId". The '
                'identifier can only contain letters, numbers and underscores, '
                'and must not begin with a number.');
        return '';
      }
      if (package.usedAnimationIdsByHref[href]!.contains(uniqueId)) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has a non-unique identifier, "$uniqueId". '
                'Animation identifiers must be unique.');
        return '';
      }
      package.usedAnimationIdsByHref[href]!.add(uniqueId);

      int width;
      try {
        width = int.parse(positionalArgs[0]);
      } on FormatException {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has an invalid width ($uniqueId), '
                '"${positionalArgs[0]}". The width must be an integer.');
        return '';
      }

      int height;
      try {
        height = int.parse(positionalArgs[1]);
      } on FormatException {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has an invalid height ($uniqueId), '
                '"${positionalArgs[1]}". The height must be an integer.');
        return '';
      }

      Uri movieUrl;
      try {
        movieUrl = Uri.parse(positionalArgs[2]);
      } on FormatException catch (e) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation URL could not be parsed ($uniqueId): '
                '${positionalArgs[2]}\n$e');
        return '';
      }
      var overlayId = '${uniqueId}_play_button_';

      return '''

<div style="position: relative;">
  <div id="$overlayId"
       onclick="var $uniqueId = document.getElementById('$uniqueId');
                if ($uniqueId.paused) {
                  $uniqueId.play();
                  this.style.display = 'none';
                } else {
                  $uniqueId.pause();
                  this.style.display = 'block';
                }"
       style="position:absolute;
              width:${width}px;
              height:${height}px;
              z-index:100000;
              background-position: center;
              background-repeat: no-repeat;
              background-image: url(static-assets/play_button.svg);">
  </div>
  <video id="$uniqueId"
         style="width:${width}px; height:${height}px;"
         onclick="var $overlayId = document.getElementById('$overlayId');
                  if (this.paused) {
                    this.play();
                    $overlayId.style.display = 'none';
                  } else {
                    this.pause();
                    $overlayId.style.display = 'block';
                  }" loop>
    <source src="$movieUrl" type="video/mp4"/>
  </video>
</div>

'''; // Must end at start of line, or following inline text will be indented.
    });
  }

  /// Parse and remove &#123;@template ...&#125; in API comments and store them
  /// in the index on the package.
  ///
  /// Syntax:
  ///
  ///     &#123;@template NAME&#125;
  ///     The contents of the macro
  ///     &#123;@endtemplate&#125;
  ///
  String _stripMacroTemplatesAndAddToIndex(String rawDocs) {
    return rawDocs.replaceAllMapped(_templatePattern, (match) {
      var name = match[1]!.trim();
      var content = match[2]!.trim();
      var trailingNewline = match[3];
      packageGraph.addMacro(name, content);
      return '{@macro $name}$trailingNewline';
    });
  }

  String _stripDocImports(String content) {
    if (modelNode?.commentData case var commentData?) {
      var commentOffset = commentData.offset;
      var buffer = StringBuffer();
      if (commentData.docImports.isEmpty) return content;
      var firstDocImport = commentData.docImports.first;
      buffer.write(content.substring(0, firstDocImport.offset - commentOffset));
      var offset = firstDocImport.end - commentOffset;
      for (var docImport in commentData.docImports.skip(1)) {
        buffer
            .write(content.substring(offset, docImport.offset - commentOffset));
        offset = docImport.end - commentOffset;
      }
      if (offset < content.length) {
        // Write from the end of the last doc-import to the end of the comment.
        buffer.write(content.substring(offset));
      }
      return buffer.toString();
    } else {
      return content;
    }
  }

  /// Parse and remove &#123;@inject-html ...&#125; in API comments and store
  /// them in the index on the package, replacing them with a SHA1 hash of the
  /// contents, where the HTML will be re-injected after Markdown processing of
  /// the rest of the text is complete.
  ///
  /// Syntax:
  ///
  ///     &#123;@inject-html&#125;
  ///     <p>The HTML to inject.</p>
  ///     &#123;@end-inject-html&#125;
  ///
  String _stripHtmlAndAddToIndex(String rawDocs) {
    if (!config.injectHtml) return rawDocs;
    return rawDocs.replaceAllMapped(_htmlPattern, (match) {
      var fragment = match[1]!;
      var digest = crypto.sha1.convert(fragment.codeUnits).toString();
      packageGraph.addHtmlFragment(digest, fragment);
      // The newlines are so that Markdown will pass this through without
      // touching it.
      return '\n<dartdoc-html>$digest</dartdoc-html>\n';
    });
  }

  /// Helper to process arguments given as a (possibly quoted) string.
  ///
  /// First, this will split the given [argsAsString] into separate arguments
  /// with [_splitUpQuotedArgs] it then parses the resulting argument list
  /// normally with [argParser] and returns the result.
  ArgResults? _parseArgs(
      String argsAsString, ArgParser argParser, String directiveName) {
    var args = _splitUpQuotedArgs(argsAsString, convertToArgs: true);
    try {
      return argParser.parse(args);
    } on ArgParserException catch (e) {
      warn(PackageWarning.invalidParameter,
          message: 'The {@$directiveName ...} directive was called with '
              'invalid parameters. $e');
      return null;
    }
  }

  static Future<String> _replaceAllMappedAsync(String string, Pattern exp,
      Future<String> Function(Match match) replace) async {
    var replaced = StringBuffer();
    var currentIndex = 0;
    for (var match in exp.allMatches(string)) {
      var prefix = match.input.substring(currentIndex, match.start);
      currentIndex = match.end;
      replaced
        ..write(prefix)
        ..write(await replace(match));
    }
    replaced.write(string.substring(currentIndex));
    return replaced.toString();
  }

  /// Regexp to take care of splitting arguments, and handling the quotes
  /// around arguments, if any.
  ///
  /// Match group 1 is the "foo=" (or "--foo=") part of the option, if any.
  /// Match group 2 contains the quote character used (which is discarded).
  /// Match group 3 is a quoted arg, if any, without the quotes.
  /// Match group 4 is the unquoted arg, if any.
  static final RegExp _argPattern = RegExp(r'([a-zA-Z\-_0-9]+=)?' // option name
      r'(?:' // Start a new non-capture group for the two possibilities.
      r'''(["'])((?:[^\\\r\n]|\\.)*?)\2|''' // with quotes.
      r'(\S+))'); // without quotes.

  /// Helper to process arguments given as a (possibly quoted) string.
  ///
  /// First, this will split the given [argsAsString] into separate arguments,
  /// taking any quoting (either ' or " are accepted) into account, including
  /// handling backslash-escaped quotes.
  ///
  /// Then, it will prepend "--" to any args that start with an identifier
  /// followed by an equals sign, allowing the argument parser to treat any
  /// "foo=bar" argument as "--foo=bar". It does handle quoted args like
  /// "foo='bar baz'" too, returning just bar (without quotes) for the foo
  /// value.
  static Iterable<String> _splitUpQuotedArgs(String argsAsString,
      {bool convertToArgs = false}) {
    final Iterable<Match> matches = _argPattern.allMatches(argsAsString);
    // Remove quotes around args, and if [convertToArgs] is true, then for any
    // args that look like assignments (start with valid option names followed
    // by an equals sign), add a "--" in front so that they parse as options.
    return matches.map<String>((Match match) {
      var option = '';
      if (convertToArgs && match[1] != null && !match[1]!.startsWith('-')) {
        option = '--';
      }
      if (match[2] != null) {
        // This arg has quotes, so strip them.
        return '$option${match[1] ?? ''}${match[3] ?? ''}${match[4] ?? ''}';
      }
      return '$option${match[0]}';
    });
  }

  /// The documentation for this element.
  ///
  /// Macro definitions are stripped, but macros themselves are not injected.
  /// This is a two stage process to avoid ordering problems.
  String get documentationLocal =>
      _documentationLocal ??= _processCommentWithoutTools();

  String? _documentationLocal;

  /// Unconditionally precache local documentation.
  ///
  /// Use only in factory for [PackageGraph].
  Future<void> precacheLocalDocs() async {
    assert(_documentationLocal == null,
        'reentrant calls to _buildDocumentation* not allowed');
    _documentationLocal = await processComment();
  }

  /// Removes `{@canonicalFor}` from [docs] and checks that they're valid.
  ///
  /// Example:
  ///
  /// `/// {@canonicalFor libname.ClassName}`
  String _stripCanonicalFor(String docs) {
    if (this is Library) {
      docs = docs.replaceAll(_canonicalForRegExp, '');

      (this as Library).checkCanonicalForIsValid();
    }

    return docs;
  }

  /// Replace `<dartdoc-html>[digest]</dartdoc-html>` in API comments with
  /// the contents of the HTML fragment earlier defined by the
  /// &#123;@inject-html&#125; directive. The `[digest]` is a SHA1 of the
  /// contents of the HTML fragment, automatically generated upon parsing the
  /// &#123;@inject-html&#125; directive.
  ///
  /// This markup is generated and inserted by [_stripHtmlAndAddToIndex] when it
  /// removes the HTML fragment in preparation for markdown processing. It isn't
  /// meant to be used at a user level.
  ///
  /// Example:
  ///
  /// You place the fragment in a dartdoc comment:
  ///
  ///     Some comments
  ///     &#123;@inject-html&#125;
  ///     &lt;p&gt;[HTML contents!]&lt;/p&gt;
  ///     &#123;@endtemplate&#125;
  ///     More comments
  ///
  /// and [_stripHtmlAndAddToIndex] will replace your HTML fragment with this:
  ///
  ///     Some comments
  ///     &lt;dartdoc-html&gt;4cc02f877240bf69855b4c7291aba8a16e5acce0&lt;/dartdoc-html&gt;
  ///     More comments
  ///
  /// Which will render in the final HTML output as:
  ///
  ///     Some comments
  ///     &lt;p&gt;[HTML contents!]&lt;/p&gt;
  ///     More comments
  ///
  /// And the HTML fragment will not have been processed or changed by Markdown,
  /// but just injected verbatim.
  String _injectHtmlFragments(String rawDocs) {
    if (!config.injectHtml) return rawDocs;

    return rawDocs.replaceAllMapped(_htmlInjectRegExp, (match) {
      var fragment = packageGraph.getHtmlFragment(match[1]);
      if (fragment == null) {
        warn(PackageWarning.unknownHtmlFragment, message: match[1]);
        return '';
      }
      return fragment;
    });
  }

  /// Replace &#123;@macro ...&#125; in API comments with the contents of the macro
  ///
  /// Syntax:
  ///
  ///     &#123;@macro NAME&#125;
  ///
  /// Example:
  ///
  /// You define the template in any comment for a documentable entity like:
  ///
  ///     &#123;@template foo&#125;
  ///     Foo contents!
  ///     &#123;@endtemplate&#125;
  ///
  /// and them somewhere use it like this:
  ///
  ///     Some comments
  ///     &#123;@macro foo&#125;
  ///     More comments
  ///
  /// Which will render
  ///
  ///     Some comments
  ///     Foo contents!
  ///     More comments
  ///
  String injectMacros(String rawDocs) {
    return rawDocs.replaceAllMapped(_macroRegExp, (match) {
      final macroName = match[1]!;
      var macro = packageGraph.getMacro(macroName);
      if (macro == null) {
        warn(PackageWarning.unknownMacro, message: macroName);
      }
      macro = _processCommentDirectives(macro ?? '');
      return macro;
    });
  }

  static final RegExp _categoryRegExp =
      RegExp(r'[ ]*{@(category|subCategory) (.+?)}[ ]*\n?', multiLine: true);

  /// A set of strings containing all declared subcategories for this element.
  List<String> get subCategoryNames {
    _ensureInitialCategorization();
    return _subCategoryNamesSet.toList()..sort();
  }

  bool get hasCategoryNames => categoryNames.isNotEmpty;

  /// A set of strings containing all declared categories for this element.
  List<String> get categoryNames {
    _ensureInitialCategorization();
    return _categoryNamesSet.toList()..sort();
  }

  @visibleForTesting
  List<Category> get categories =>
      [...categoryNames.map((n) => package.nameToCategory[n]).nonNulls]..sort();

  Iterable<Category> get displayedCategories {
    if (config.showUndocumentedCategories) return categories;
    return categories.where((c) => c.isDocumented);
  }

  /// True if categories or subcategories were parsed.
  bool get hasCategorization {
    _ensureInitialCategorization();
    return _categoryNamesSet.isNotEmpty || _subCategoryNamesSet.isNotEmpty;
  }

  /// The set of libraries which this [Library] is canonical for.
  late final Set<String> canonicalFor = {
    if (documentationComment case var comment?)
      for (var match in _canonicalForRegExp.allMatches(comment))
        match.group(1)!,
  };

  static final _canonicalForRegExp =
      RegExp(r'[ ]*{@canonicalFor\s([^}]+)}[ ]*\n?');
}
