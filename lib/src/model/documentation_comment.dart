import 'package:args/args.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;

final _templatePattern = RegExp(
    r'[ ]*{@template\s+(.+?)}([\s\S]+?){@endtemplate}[ ]*(\n?)',
    multiLine: true);
final _htmlPattern = RegExp(
    r'[ ]*{@inject-html\s*}([\s\S]+?){@end-inject-html}[ ]*\n?',
    multiLine: true);

/// Matches all tool directives (even some invalid ones). This is so
/// we can give good error messages if the directive is malformed, instead of
/// just silently emitting it as-is.
final _basicToolPattern = RegExp(
    r'[ ]*{@tool\s+([^}]+)}\n?([\s\S]+?)\n?{@end-tool}[ ]*\n?',
    multiLine: true);

final _examplePattern = RegExp(r'{@example\s+([^}]+)}');

/// Features for processing directives in a documentation comment.
///
/// [processCommentWithoutTools] and [processComment] are the primary
/// entrypoints.
mixin DocumentationComment
    on Documentable, Warnable, Locatable, SourceCodeMixin {
  /// The documentation comment on the Element may be null, so memoization
  /// cannot rely on the null-ness of [_documentationComment], it must be
  /// more explicit.
  bool _documentationCommentComputed = false;
  String _documentationComment;

  String get documentationComment {
    if (_documentationCommentComputed == false) {
      _documentationComment = computeDocumentationComment();
      _documentationCommentComputed = true;
    }
    return _documentationComment;
  }

  /// Implement to derive the raw documentation comment string from the
  /// analyzer.
  String computeDocumentationComment();

  /// Returns true if the raw documentation comment has a nodoc indication.
  bool get hasNodoc {
    if (documentationComment != null &&
        (documentationComment.contains('@nodoc') ||
            documentationComment.contains('<nodoc>'))) {
      return true;
    }
    return packageGraph.configSetsNodocFor(element.source.fullName);
  }

  /// Process a [documentationComment], performing various actions based on
  /// `{@}`-style directives, except `{@tool}`, returning the processed result.
  String processCommentWithoutTools(String documentationComment) {
    var docs = stripComments(documentationComment);
    if (!docs.contains('{@')) {
      return docs;
    }
    docs = _injectExamples(docs);
    docs = _injectYouTube(docs);
    docs = _injectAnimations(docs);
    // TODO(srawlins): Processing templates here causes #2281. But leaving them
    // unprocessed causes #2272.
    docs = _stripHtmlAndAddToIndex(docs);
    return docs;
  }

  /// Process [documentationComment], performing various actions based on
  /// `{@}`-style directives, returning the processed result.
  Future<String> processComment(String documentationComment) async {
    var docs = stripComments(documentationComment);
    // Must evaluate tools first, in case they insert any other directives.
    docs = await _evaluateTools(docs);
    docs = processCommentDirectives(docs);
    return docs;
  }

  String processCommentDirectives(String docs) {
    // The vast, vast majority of doc comments have no directives.
    if (!docs.contains('{@')) {
      return docs;
    }
    _checkForUnknownDirectives(docs);
    docs = _injectExamples(docs);
    docs = _injectYouTube(docs);
    docs = _injectAnimations(docs);
    docs = _stripMacroTemplatesAndAddToIndex(docs);
    docs = _stripHtmlAndAddToIndex(docs);
    return docs;
  }

  String get sourceFileName;

  String get fullyQualifiedNameWithoutLibrary;

  path.Context get pathContext;

  ModelElementRenderer get modelElementRenderer;

  static const _allDirectiveNames = [
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

    // Categorization directives, parsed elsewhere:
    'api',
    'canonicalFor',
    'category',
    'image',
    'samples',
    'subCategory',

    // Common Dart annotations which may decorate named parameters:
    'deprecated',
    'required',
  ];

  static final _nameBreak = RegExp('[\\s}]');

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
        if (_allDirectiveNames.contains(name.toLowerCase())) {
          warn(PackageWarning.unknownDirective,
              message: "'$name' (use lowercase)");
        } else {
          warn(PackageWarning.unknownDirective, message: "'$name'");
        }
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
  ///     # Prefixes the given input with "## "
  ///     # Path is relative to project root.
  ///     prefix: "bin/prefix.dart"
  ///     # Prints the date
  ///     date: "/bin/date"
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
      var args = _splitUpQuotedArgs(basicMatch[1]).toList();
      // Tool name must come first.
      if (args.isEmpty) {
        warn(PackageWarning.toolError,
            message: 'Must specify a tool to execute for the @tool directive.');
        return Future.value('');
      }
      // Count the number of invocations of tools in this dartdoc block,
      // so that tools can differentiate different blocks from each other.
      invocationIndex++;
      return await config.tools.runner.run(
          args,
          (String message) async =>
              warn(PackageWarning.toolError, message: message),
          content: basicMatch[2],
          environment: {
            'SOURCE_LINE': characterLocation?.lineNumber.toString(),
            'SOURCE_COLUMN': characterLocation?.columnNumber.toString(),
            'SOURCE_PATH':
                (sourceFileName == null || package?.packagePath == null)
                    ? null
                    : path.relative(sourceFileName, from: package.packagePath),
            'PACKAGE_PATH': package?.packagePath,
            'PACKAGE_NAME': package?.name,
            'LIBRARY_NAME': library?.fullyQualifiedName,
            'ELEMENT_NAME': fullyQualifiedNameWithoutLibrary,
            'INVOCATION_INDEX': invocationIndex.toString(),
            'PACKAGE_INVOCATION_INDEX':
                (package.toolInvocationIndex++).toString(),
          }..removeWhere((key, value) => value == null));
    });
  }

  /// Replace &#123;@example ...&#125; in API comments with the content of named file.
  ///
  /// Syntax:
  ///
  ///     &#123;@example PATH [region=NAME] [lang=NAME]&#125;
  ///
  /// If PATH is `dir/file.ext` and region is `r` then we'll look for the file
  /// named `dir/file-r.ext.md`, relative to the project root directory of the
  /// project for which the docs are being generated.
  ///
  /// Examples: (escaped in this comment to show literal values in dartdoc's
  ///            dartdoc)
  ///
  ///     &#123;@example examples/angular/quickstart/web/main.dart&#125;
  ///     &#123;@example abc/def/xyz_component.dart region=template lang=html&#125;
  ///
  String _injectExamples(String rawdocs) {
    final dirPath = package.packageMeta.dir.path;
    return rawdocs.replaceAllMapped(_examplePattern, (match) {
      var args = _getExampleArgs(match[1]);
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      var lang =
          args['lang'] ?? path.extension(args['src']).replaceFirst('.', '');

      var replacement = match[0]; // default to fully matched string.

      var fragmentFile = packageGraph.resourceProvider.getFile(
          pathContext.canonicalize(pathContext.join(dirPath, args['file'])));
      if (fragmentFile.exists) {
        replacement = fragmentFile.readAsStringSync();
        if (lang.isNotEmpty) {
          replacement = replacement.replaceFirst('```', '```$lang');
        }
      } else {
        var filePath = element.source.fullName.substring(dirPath.length + 1);

        // TODO(srawlins): If a file exists at the location without the
        // appended 'md' extension, note this.
        warn(PackageWarning.missingExampleFile,
            message: '${fragmentFile.path}; path listed at $filePath');
      }
      return replacement;
    });
  }

  /// An argument parser used in [_getExampleArgs] to parse an `{@example}`
  /// directive.
  static final ArgParser _exampleArgParser = ArgParser()
    ..addOption('lang')
    ..addOption('region');

  /// Helper for [_injectExamples] used to process `@example` arguments.
  ///
  /// Returns a map of arguments. The first unnamed argument will have key
  /// 'src'. The computed file path, constructed from 'src' and 'region' will
  /// have key 'file'.
  Map<String, String> _getExampleArgs(String argsAsString) {
    var results = _parseArgs(argsAsString, _exampleArgParser, 'example');
    if (results == null) {
      return null;
    }

    // Extract PATH and fix the path separators.
    var src = results.rest.isEmpty
        ? ''
        : results.rest.first.replaceAll('/', pathContext.separator);
    var args = <String, String>{
      'src': src,
      'lang': results['lang'],
      'region': results['region'] ?? '',
    };

    // Compute 'file' from region and src.
    final fragExtension = '.md';
    var file = src + fragExtension;
    var region = args['region'] ?? '';
    if (region.isNotEmpty) {
      var dir = path.dirname(src);
      var basename = path.basenameWithoutExtension(src);
      var ext = path.extension(src);
      file = path.join(dir, '$basename-$region$ext$fragExtension');
    }
    args['file'] = config.examplePathPrefix == null
        ? file
        : path.join(config.examplePathPrefix, file);
    return args;
  }

  /// Matches all youtube directives (even some invalid ones). This is so
  /// we can give good error messages if the directive is malformed, instead of
  /// just silently emitting it as-is.
  static final _basicYouTubePattern = RegExp(r'''{@youtube\s+([^}]+)}''');

  /// Matches YouTube IDs from supported YouTube URLs.
  static final _validYouTubeUrlPattern =
      RegExp('https://www\.youtube\.com/watch\\?v=([^&]+)\$');

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
      var args = _parseArgs(basicMatch[1], _youTubeArgParser, 'youtube');
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
      var youTubeId = url.group(url.groupCount);
      var aspectRatio = (height / width * 100).toStringAsFixed(2);

      return modelElementRenderer.renderYoutubeUrl(youTubeId, aspectRatio);
    });
  }

  /// Matches all animation directives (even some invalid ones). This is so
  /// we can give good error messages if the directive is malformed, instead of
  /// just silently emitting it as-is.
  final _basicAnimationPattern = RegExp(r'''{@animation\s+([^}]+)}''');

  /// Matches valid javascript identifiers.
  final _validIdPattern = RegExp(r'^[a-zA-Z_]\w*$');

  /// An argument parser used in [_injectAnimations] to parse a `{@animation}`
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
      while (package.usedAnimationIdsByHref[href].contains(id)) {
        animationIdCount++;
        id = '$base$animationIdCount';
      }
      return id;
    }

    return rawDocs.replaceAllMapped(_basicAnimationPattern, (basicMatch) {
      // Make sure we have a set to keep track of used IDs for this href.
      package.usedAnimationIdsByHref[href] ??= {};

      var args = _parseArgs(basicMatch[1], _animationArgParser, 'animation');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      final positionalArgs = args.rest.sublist(0);
      String uniqueId;
      var wasDeprecated = false;
      if (positionalArgs.length == 4) {
        // Supports the original form of the animation tag for backward
        // compatibility.
        uniqueId = positionalArgs.removeAt(0);
        wasDeprecated = true;
      } else if (positionalArgs.length == 3) {
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
      if (package.usedAnimationIdsByHref[href].contains(uniqueId)) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has a non-unique identifier, "$uniqueId". '
                'Animation identifiers must be unique.');
        return '';
      }
      package.usedAnimationIdsByHref[href].add(uniqueId);

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

      // Only warn about deprecation if some other warning didn't occur.
      if (wasDeprecated) {
        warn(PackageWarning.deprecated,
            message:
                'Deprecated form of @animation directive, "${basicMatch[0]}"\n'
                'Animation directives are now of the form "{@animation '
                'WIDTH HEIGHT URL [id=ID]}" (id is an optional '
                'parameter)');
      }

      return modelElementRenderer.renderAnimation(
          uniqueId, width, height, movieUrl, overlayId);
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
      var name = match[1].trim();
      var content = match[2].trim();
      var trailingNewline = match[3];
      packageGraph.addMacro(name, content);
      return '{@macro $name}$trailingNewline';
    });
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
      var fragment = match[1];
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
  ArgResults _parseArgs(
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
      replaced..write(prefix)..write(await replace(match));
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
      r'''(["'])((?:\\{2})*|(?:.*?[^\\](?:\\{2})*))\2|''' // with quotes.
      r'([^ ]+))'); // without quotes.

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
      if (convertToArgs && match[1] != null && !match[1].startsWith('-')) {
        option = '--';
      }
      if (match[2] != null) {
        // This arg has quotes, so strip them.
        return '$option${match[1] ?? ''}${match[3] ?? ''}${match[4] ?? ''}';
      }
      return '$option${match[0]}';
    });
  }
}
