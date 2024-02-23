// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math' as math;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/utils.dart';

const _namePlaceholder = '@@name@@';

mixin PackageWarningOptionContext implements DartdocOptionContextBase {
  bool get allowNonLocalWarnings =>
      optionSet['allowNonLocalWarnings'].valueAt(context);

  // allowWarningsInPackages, ignoreWarningsInPackages, errors, warnings, and
  // ignore are only used indirectly via the synthetic packageWarningOptions
  // option.
  PackageWarningOptions get packageWarningOptions =>
      optionSet['packageWarningOptions'].valueAt(context);

  bool get verboseWarnings => optionSet['verboseWarnings'].valueAt(context);
}

List<DartdocOption<Object?>> createPackageWarningOptions(
  PackageMetaProvider packageMetaProvider,
) {
  var resourceProvider = packageMetaProvider.resourceProvider;
  return [
    DartdocOptionArgOnly<bool>('allowNonLocalWarnings', false, resourceProvider,
        negatable: true,
        help: 'Show warnings from packages we are not documenting locally.'),

    // Options for globally enabling/disabling all warnings and errors
    // for individual packages are command-line only.  This will allow
    // meta-packages like Flutter to control whether warnings are displayed for
    // packages they don't control.
    DartdocOptionArgOnly<List<String>?>(
        'allowWarningsInPackages', null, resourceProvider,
        splitCommas: true,
        help:
            'Package names to display warnings for (ignore all others if set)'),
    DartdocOptionArgOnly<List<String>?>(
        'allowErrorsInPackages', null, resourceProvider,
        splitCommas: true,
        help: 'Package names to display errors for (ignore all others if set)'),
    DartdocOptionArgOnly<List<String>?>(
        'ignoreWarningsInPackages', null, resourceProvider,
        splitCommas: true,
        help: 'Package names to ignore warnings for.  Takes priority over '
            'allow-warnings-in-packages'),
    DartdocOptionArgOnly<List<String>?>(
        'ignoreErrorsInPackages', null, resourceProvider,
        splitCommas: true,
        help: 'Package names to ignore errors for. Takes priority over '
            'allow-errors-in-packages'),
    // Options for globally enabling/disabling warnings and errors across
    // packages.  Loaded from dartdoc_options.yaml, but command line arguments
    // will override.
    DartdocOptionArgFile<List<String>?>('errors', null, resourceProvider,
        splitCommas: true,
        help: 'Additional warning names to force as errors. Specify an empty '
            'list to force defaults (overriding dartdoc_options.yaml)\n'
            'Defaults:\n${PackageWarningMode.error._warningsListHelpText}'),
    DartdocOptionArgFile<List<String>?>('ignore', null, resourceProvider,
        splitCommas: true,
        help: 'Additional warning names to ignore. Specify an empty list to '
            'force defaults (overriding dartdoc_options.yaml).\n'
            'Defaults:\n${PackageWarningMode.ignore._warningsListHelpText}'),
    DartdocOptionArgFile<List<String>?>('warnings', null, resourceProvider,
        splitCommas: true,
        help:
            'Additional warning names to show as warnings (instead of error or '
            'ignore, if not warning by default).\n'
            'Defaults:\n${PackageWarningMode.warn._warningsListHelpText}'),
    // Synthetic option uses a factory to build a PackageWarningOptions from all
    // the above flags.
    DartdocOptionSyntheticOnly<PackageWarningOptions>(
      'packageWarningOptions',
      (DartdocSyntheticOption<PackageWarningOptions> option, Folder dir) =>
          PackageWarningOptions.fromOptions(option, dir, packageMetaProvider),
      resourceProvider,
    ),
  ];
}

/// Something that package warnings can be reported on. Optionally associated
/// with an analyzer [element].
mixin Warnable implements CommentReferable, Documentable, Locatable {
  Element? get element;

  void warn(
    PackageWarning kind, {
    String? message,
    Iterable<Locatable> referredFrom = const [],
    Iterable<String> extendedDebug = const [],
  }) {
    packageGraph.warnOnElement(this, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }
}

/// The kinds of warnings that can be displayed when documenting a package.
enum PackageWarning implements Comparable<PackageWarning> {
  ambiguousDocReference(
    'ambiguous-doc-reference',
    'ambiguous doc reference {0}',
    shortHelp:
        'A comment reference could refer to two or more different objects',
  ),

  // Fix these warnings by adding the original library exporting the symbol with
  // `--include`, by using `--auto-include-dependencies`, or by using
  // `--exclude` to hide one of the libraries involved.
  ambiguousReexport(
    'ambiguous-reexport',
    'ambiguous reexport of {0}, canonicalization candidates: {1}',
    shortHelp:
        'A symbol is exported from private to public in more than one library '
        'and dartdoc can not determine which one is canonical',
    longHelp: "Use {@canonicalFor $_namePlaceholder} in the desired library's "
        "documentation to resolve the ambiguity and/or override dartdoc's "
        'decision, or structure your package so the reexport is less '
        'ambiguous. The symbol will still be referenced in all candidates -- '
        'this only controls the location where it will be written and which '
        'library will be displayed in navigation for the relevant pages. The '
        'flag `--ambiguous-reexport-scorer-min-confidence` allows you to set '
        'the threshold at which this warning will appear.',
  ),

  ignoredCanonicalFor(
    'ignored-canonical-for',
    "library says it is {@canonicalFor {0}} but {0} can't be canonical "
        'there',
    shortHelp:
        'A @canonicalFor tag refers to a library which this symbol can not be '
        'canonical for',
  ),

  // Fix these warnings by adding libraries with `--include`, or by using
  // `--auto-include-dependencies`.
  // TODO(jcollins-g): pipeline references through `linkedName` for error
  // messages and warn for non-public canonicalization errors.
  noCanonicalFound(
    'no-canonical-found',
    'no canonical library found for {0}, not linking',
    shortHelp:
        'A symbol is part of the public interface for this package, but no '
        'library documented with this package documents it so dartdoc cannot '
        'link to it',
  ),
  noDocumentableLibrariesInPackage(
    'no-documentable-libraries',
    '{0} has no documentable libraries',
    shortHelp:
        'The package is to be documented but has no Dart libraries to document',
    longHelp: 'Dartdoc could not find any public libraries to document in '
        "'$_namePlaceholder', but documentation was requested. This might be "
        'expected for an asset-only package, in which case, disable this '
        'warning in your dartdoc_options.yaml file.',
  ),
  noLibraryLevelDocs(
    'no-library-level-docs',
    '{0} has no library level documentation comments',
    shortHelp: 'There are no library level docs for this library',
  ),
  packageOrderGivesMissingPackageName(
    'category-order-gives-missing-package-name',
    "--package-order gives invalid package name: '{0}'",
    shortHelp:
        'The category-order flag on the command line was given the name of a '
        'nonexistent package',
  ),
  reexportedPrivateApiAcrossPackages(
    'reexported-private-api-across-packages',
    'private API of {0} is reexported by libraries in other packages: ',
    shortHelp:
        'One or more libraries reexports private API members from outside its '
        'own package',
  ),
  unresolvedDocReference(
    'unresolved-doc-reference',
    'unresolved doc reference [{0}]',
    shortHelp:
        'A comment reference could not be found in parameters, enclosing '
        'class, enclosing library, or at the top level of any documented '
        'library with the package',
    referredFromPrefix: 'in documentation inherited from',
  ),
  unknownMacro(
    'unknown-macro',
    'undefined macro [{0}]',
    shortHelp: 'A comment reference contains an unknown macro',
  ),
  unknownHtmlFragment(
    'unknown-html-fragment',
    'undefined HTML fragment identifier [{0}]',
    shortHelp:
        'Dartdoc attempted to inject an unknown block of HTML, indicating a '
        'bug in Dartdoc',
  ),
  brokenLink(
    'broken-link',
    'dartdoc generated a broken link to: {0}',
    shortHelp: 'Dartdoc generated a link to a non-existent file',
    warnablePrefix: 'to element',
    referredFromPrefix: 'linked to from',
  ),
  duplicateFile(
    'duplicate-file',
    'failed to write file at: {0}',
    shortHelp:
        'Dartdoc is trying to write to a duplicate filename based on the names '
        'of Dart symbols.',
    longHelp:
        'Dartdoc generates a path and filename to write to for each symbol. '
        "'$_namePlaceholder' conflicts with another symbol in the generated "
        'path, and therefore can not be written out.  Changing the name, '
        'library name, or class name (if appropriate) of one of the '
        'conflicting items can resolve the conflict. Alternatively, use the '
        "`@nodoc` directive in one symbol's documentation comment to hide it.",
    warnablePrefix: 'for symbol',
    referredFromPrefix: 'conflicting with file already generated by',
    defaultWarningMode: PackageWarningMode.error,
  ),
  orphanedFile(
    'orphaned-file',
    'dartdoc generated a file orphan: {0}',
    shortHelp: 'Dartdoc generated files that are unreachable from the index',
  ),
  unknownFile(
    'unknown-file',
    'dartdoc detected an unknown file in the doc tree: {0}',
    shortHelp:
        'A leftover file exists in the tree that dartdoc did not write in this '
        'pass',
  ),
  missingFromSearchIndex(
    'missing-from-search-index',
    'dartdoc generated a file not in the search index: {0}',
    shortHelp: 'A file generated by dartdoc is not present in the generated '
        'index.json file',
  ),

  // The message for this warning can contain many punctuation and other
  // symbols, so bracket with a triple quote for defense.
  typeAsHtml(
    'type-as-html',
    'generic type handled as HTML: """{0}"""',
    shortHelp:
        'Use of <> in a comment for type parameters is being treated as HTML '
        'by Markdown',
    defaultWarningMode: PackageWarningMode.ignore,
  ),
  invalidParameter(
    'invalid-parameter',
    'invalid parameter to dartdoc directive: {0}',
    shortHelp: 'A parameter given to a dartdoc directive was invalid.',
    defaultWarningMode: PackageWarningMode.error,
  ),
  toolError(
    'tool-error',
    'tool execution failed: {0}',
    shortHelp: 'Unable to execute external tool.',
    defaultWarningMode: PackageWarningMode.error,
  ),
  deprecated(
    'deprecated',
    'deprecated dartdoc usage: {0}',
    shortHelp: 'A dartdoc directive has a deprecated format.',
  ),
  unresolvedExport(
    'unresolved-export',
    'unresolved export uri: {0}',
    shortHelp: 'An export refers to a URI that cannot be resolved.',
    defaultWarningMode: PackageWarningMode.error,
  ),
  missingExampleFile(
    'missing-example-file',
    'example file not found: {0}',
    shortHelp:
        "A file which is indicated by an '{@example}' directive could not be "
        'found',
  ),
  missingCodeBlockLanguage(
    'missing-code-block-language',
    'missing code block language: {0}',
    shortHelp: 'A fenced code block is missing a specified language.',
    longHelp:
        'To enable proper syntax highlighting of Markdown code blocks, Dartdoc '
        'requires code blocks to specify the language used after the initial '
        'declaration. As an example, to specify Dart you would open the '
        'Markdown code block with ```dart or ~~~dart.',
    defaultWarningMode: PackageWarningMode.ignore,
  );

  /// The name which can be used at the command line to enable this warning.
  final String _flagName;

  /// The message template, with substitutions.
  final String _template;

  final String _warnablePrefix;

  final String _referredFromPrefix;

  final String _shortHelp;

  final String _longHelp;

  final PackageWarningMode _defaultWarningMode;

  const PackageWarning(
    this._flagName,
    this._template, {
    required String shortHelp,
    String longHelp = '',
    String warnablePrefix = 'from',
    String referredFromPrefix = 'referred to by',
    PackageWarningMode defaultWarningMode = PackageWarningMode.warn,
  })  : _shortHelp = shortHelp,
        _longHelp = longHelp,
        _warnablePrefix = warnablePrefix,
        _referredFromPrefix = referredFromPrefix,
        _defaultWarningMode = defaultWarningMode;

  static PackageWarning? _byName(String name) =>
      PackageWarning.values.firstWhereOrNull((w) => w._flagName == name);

  @override
  int compareTo(PackageWarning other) {
    return _flagName.compareTo(other._flagName);
  }

  String messageFor(List<String> messageParts) {
    var message = _template;
    for (var i = 0; i < messageParts.length; i++) {
      message = message.replaceAll('{$i}', messageParts[i]);
    }
    return message;
  }

  String messageForWarnable(Warnable warnable) =>
      '$_warnablePrefix ${warnable.safeWarnableName}: ${warnable.location}';

  String messageForReferral(Locatable referral) =>
      '$_referredFromPrefix ${referral.safeWarnableName}: ${referral.location}';
}

/// Used to declare defaults for a particular package warning.
enum PackageWarningMode {
  ignore,
  warn,
  error;

  String get _warningsListHelpText {
    return (PackageWarning.values
            .where((w) => w._defaultWarningMode == this)
            .toList(growable: false)
          ..sort())
        .map((w) => '   ${w._flagName}: ${w._shortHelp}')
        .join('\n');
  }
}

/// Warnings which are OK to skip if we can determine the warnable isn't
/// documented.
/// In particular, this set should not include warnings around public/private
/// or canonicalization problems, because those can break the `isDocumented()`
/// check.
const Set<PackageWarning> skipWarningIfNotDocumentedFor = {
  PackageWarning.unresolvedDocReference,
  PackageWarning.typeAsHtml
};

class PackageWarningOptions {
  final Map<PackageWarning, PackageWarningMode> warningModes = {};

  PackageWarningOptions() {
    for (var definition in PackageWarning.values) {
      switch (definition._defaultWarningMode) {
        case PackageWarningMode.warn:
          warn(definition);
        case PackageWarningMode.error:
          error(definition);
        case PackageWarningMode.ignore:
          ignore(definition);
      }
    }
  }

  static PackageWarningOptions fromOptions(
    DartdocSyntheticOption<PackageWarningOptions> option,
    Folder dir,
    PackageMetaProvider packageMetaProvider,
  ) {
    // First, initialize defaults.
    var newOptions = PackageWarningOptions();
    var packageMeta = packageMetaProvider.fromDir(dir)!;

    // Interpret errors/warnings/ignore options.  In the event of conflict,
    // warning overrides error and ignore overrides warning.
    var errorsForDir =
        option.parent.getValueAs<List<String>?>('errors', dir) ?? [];
    for (var warningName in errorsForDir) {
      var packageWarning = PackageWarning._byName(warningName);
      if (packageWarning != null) {
        newOptions.error(packageWarning);
      }
    }
    var warningsForDir =
        option.parent.getValueAs<List<String>?>('warnings', dir) ?? [];
    for (var warningName in warningsForDir) {
      var packageWarning = PackageWarning._byName(warningName);
      if (packageWarning != null) {
        newOptions.warn(packageWarning);
      }
    }
    var ignoredForDir =
        option.parent.getValueAs<List<String>?>('ignore', dir) ?? [];
    for (var warningName in ignoredForDir) {
      var packageWarning = PackageWarning._byName(warningName);
      if (packageWarning != null) {
        newOptions.ignore(packageWarning);
      }
    }

    // Check whether warnings are allowed at all in this package.
    var allowWarningsInPackages =
        option.parent.getValueAs<List<String>?>('allowWarningsInPackages', dir);
    var allowErrorsInPackages =
        option.parent.getValueAs<List<String>?>('allowErrorsInPackages', dir);
    var ignoreWarningsInPackages = option.parent
        .getValueAs<List<String>?>('ignoreWarningsInPackages', dir);
    var ignoreErrorsInPackages =
        option.parent.getValueAs<List<String>?>('ignoreErrorsInPackages', dir);

    void ignoreWarning(PackageWarning kind) {
      newOptions.ignore(kind);
    }

    if (allowWarningsInPackages != null &&
        !allowWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach(ignoreWarning);
    }
    if (allowErrorsInPackages != null &&
        !allowErrorsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach(ignoreWarning);
    }
    if (ignoreWarningsInPackages != null &&
        ignoreWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach(ignoreWarning);
    }
    if (ignoreErrorsInPackages != null &&
        ignoreErrorsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach(ignoreWarning);
    }
    return newOptions;
  }

  void ignore(PackageWarning kind) =>
      warningModes[kind] = PackageWarningMode.ignore;

  void warn(PackageWarning kind) =>
      warningModes[kind] = PackageWarningMode.warn;

  void error(PackageWarning kind) =>
      warningModes[kind] = PackageWarningMode.error;

  PackageWarningMode getMode(PackageWarning kind) => warningModes[kind]!;
}

class PackageWarningCounter {
  final Map<Element?, Map<PackageWarning, Set<String>>> _countedWarnings = {};
  final _items = <Jsonable>[];
  final _displayedWarningCounts = <PackageWarning, int>{};
  final PackageGraph packageGraph;

  int _errorCount = 0;

  /// The total amount of errors this package has experienced.
  int get errorCount => _errorCount;

  int _warningCount = 0;

  /// The total amount of warnings this package has experienced.
  int get warningCount => _warningCount;

  /// An unmodifiable map view of all counted warnings related by their element,
  /// warning type, and message.
  UnmodifiableMapView<Element?, Map<PackageWarning, Set<String>>>
      get countedWarnings => UnmodifiableMapView(_countedWarnings);

  PackageWarningCounter(this.packageGraph);

  /// Logs [packageWarning].
  ///
  /// Assumes it is already counted with [addWarning].
  void _writeWarning(PackageWarning packageWarning, PackageWarningMode? mode,
      bool verboseWarnings, String name, String fullMessage) {
    if (mode == PackageWarningMode.ignore) {
      return;
    }
    var type = switch (mode) {
      PackageWarningMode.error => 'error',
      PackageWarningMode.warn => 'warning',
      _ => null,
    };
    if (type != null) {
      var entry = '  $type: $fullMessage';
      var displayedWarningCount =
          _displayedWarningCounts.increment(packageWarning);
      if (displayedWarningCount == 1 &&
          verboseWarnings &&
          packageWarning._longHelp.isNotEmpty) {
        // First time we've seen this warning. Give a little extra info.
        var longHelpLines = packageWarning._longHelp
            .split('\n')
            .map((line) => line.replaceAll(_namePlaceholder, name))
            .map((line) =>
                _wrapText(line, prefix: '        ', width: _messageWidth));
        var verboseOut = longHelpLines.join('\n');
        entry = '$entry\n$verboseOut';
      }
      assert(entry == entry.trimRight());
      _items.add(_JsonWarning(type, packageWarning, fullMessage, entry));
    }
    for (var item in _items) {
      logWarning(item.toString());
    }
    _items.clear();
  }

  /// If this package has had any warnings counted.
  bool get hasWarnings => _countedWarnings.isNotEmpty;

  /// Whether we've already warned for this combination of [element], [kind],
  /// and [message].
  bool hasWarning(Warnable? element, PackageWarning kind, String message) {
    if (element == null) {
      return false;
    }
    final warning = _countedWarnings[element.element];
    if (warning != null) {
      final messages = warning[kind];
      return messages != null && messages.contains(message);
    }
    return false;
  }

  /// Adds the warning to the counter, and writes out the fullMessage string
  /// if configured to do so.
  void addWarning(Warnable? element, PackageWarning kind, String message,
      String fullMessage) {
    assert(!hasWarning(element, kind, message));
    // TODO(jcollins-g): Make addWarning not accept nulls for element.
    PackageWarningOptionContext config =
        element?.config ?? packageGraph.defaultPackage.config;
    var isLocal = element?.package.isLocal ?? true;
    var warningMode = !isLocal && !config.allowNonLocalWarnings
        ? PackageWarningMode.ignore
        : config.packageWarningOptions.getMode(kind);

    if (warningMode == PackageWarningMode.warn) {
      _warningCount += 1;
    } else if (warningMode == PackageWarningMode.error) {
      _errorCount += 1;
    }
    var elementName = element == null ? '<global>' : element.fullyQualifiedName;
    _countedWarnings
        .putIfAbsent(element?.element, () => {})
        .putIfAbsent(kind, () => {})
        .add(message);
    _writeWarning(
      kind,
      warningMode,
      config.verboseWarnings,
      elementName,
      fullMessage,
    );
  }

  @override
  String toString() {
    final errors = '$errorCount ${pluralize('error', errorCount)}';
    final warnings = '$warningCount ${pluralize('warning', warningCount)}';
    return '$errors, $warnings';
  }
}

/// Wraps [text] to the given [width], if provided.
///
/// This function is taken from the 'dartdev' package, which has tests.
String _wrapText(String text, {required int width, String prefix = ''}) {
  // For convenience, the caller specifies the line width, but effectively, we
  // subtract out the width of the prefix.
  width = width - prefix.length;
  var buffer = StringBuffer(prefix);
  var lineMaxEndIndex = width;
  var lineStartIndex = 0;

  while (true) {
    if (lineMaxEndIndex >= text.length) {
      buffer.write(text.substring(lineStartIndex, text.length));
      break;
    } else {
      var lastSpaceIndex = text.lastIndexOf(' ', lineMaxEndIndex);
      if (lastSpaceIndex == -1 || lastSpaceIndex <= lineStartIndex) {
        // No space between [lineStartIndex] and [lineMaxEndIndex]. Get the
        // _next_ space.
        lastSpaceIndex = text.indexOf(' ', lineMaxEndIndex);
        if (lastSpaceIndex == -1) {
          // No space at all after [lineStartIndex].
          lastSpaceIndex = text.length;
          buffer.write(text.substring(lineStartIndex, lastSpaceIndex));
          break;
        }
      }
      buffer.write(text.substring(lineStartIndex, lastSpaceIndex));
      buffer.writeln();
      buffer.write(prefix);
      lineStartIndex = lastSpaceIndex + 1;
    }
    lineMaxEndIndex = lineStartIndex + width;
  }
  return buffer.toString();
}

/// The width that messages in the terminal should be limited to.
///
/// If `stdout` has a terminal, use that terminal's width capped to 120
/// characters wide. Otherwise, use a width of 80.
final _messageWidth =
    stdout.hasTerminal ? math.min(stdout.terminalColumns, 120) : 80;

class _JsonWarning extends Jsonable {
  final String type;
  final PackageWarning kind;
  final String message;

  @override
  final String text;

  _JsonWarning(this.type, this.kind, this.message, this.text);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'kind': kind._flagName,
        'message': message,
        'text': text,
      };
}

extension on Map<PackageWarning, int> {
  int increment(PackageWarning kind) {
    if (this[kind] == null) {
      this[kind] = 1;
      return 1;
    } else {
      this[kind] = this[kind]! + 1;
      return this[kind]!;
    }
  }
}
