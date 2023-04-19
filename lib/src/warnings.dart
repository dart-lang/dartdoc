// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';

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
        help:
            'Additional warning names to force as errors.  Specify an empty list to force defaults (overriding dartdoc_options.yaml)\nDefaults:\n${_warningsListHelpText(PackageWarningMode.error)}'),
    DartdocOptionArgFile<List<String>?>('ignore', null, resourceProvider,
        splitCommas: true,
        help:
            'Additional warning names to ignore.  Specify an empty list to force defaults (overriding dartdoc_options.yaml).\nDefaults:\n${_warningsListHelpText(PackageWarningMode.ignore)}'),
    DartdocOptionArgFile<List<String>?>('warnings', null, resourceProvider,
        splitCommas: true,
        help:
            'Additional warning names to show as warnings (instead of error or ignore, if not warning by default).\nDefaults:\n${_warningsListHelpText(PackageWarningMode.warn)}'),
    // Synthetic option uses a factory to build a PackageWarningOptions from all the above flags.
    DartdocOptionSyntheticOnly<PackageWarningOptions>(
      'packageWarningOptions',
      (DartdocSyntheticOption<PackageWarningOptions> option, Folder dir) =>
          PackageWarningOptions.fromOptions(option, dir, packageMetaProvider),
      resourceProvider,
    ),
  ];
}

String _warningsListHelpText(PackageWarningMode mode) {
  return (packageWarningDefinitions.values
          .where((d) => d.defaultWarningMode == mode)
          .toList(growable: false)
        ..sort())
      .map((d) => '   ${d.warningName}: ${d.shortHelp}')
      .join('\n');
}

class PackageWarningDefinition implements Comparable<PackageWarningDefinition> {
  final String warningName;
  final String shortHelp;
  final List<String> longHelp;
  final PackageWarning kind;
  final PackageWarningMode defaultWarningMode;

  const PackageWarningDefinition(
    this.kind,
    this.warningName,
    this.shortHelp, {
    this.longHelp = const [],
    this.defaultWarningMode = PackageWarningMode.warn,
  });

  @override
  int compareTo(PackageWarningDefinition other) {
    return warningName.compareTo(other.warningName);
  }
}

/// Same as [packageWarningDefinitions], except keyed by the warning name.
final Map<String, PackageWarningDefinition> packageWarningsByName = {
  for (final definition in packageWarningDefinitions.values)
    definition.warningName: definition
};

/// Provides description text and command line flags for warnings.
/// TODO(jcollins-g): Actually use this for command line flags.
const Map<PackageWarning, PackageWarningDefinition> packageWarningDefinitions =
    {
  PackageWarning.ambiguousDocReference: PackageWarningDefinition(
      PackageWarning.ambiguousDocReference,
      'ambiguous-doc-reference',
      'A comment reference could refer to two or more different objects'),
  PackageWarning.ambiguousReexport: PackageWarningDefinition(
      PackageWarning.ambiguousReexport,
      'ambiguous-reexport',
      'A symbol is exported from private to public in more than one library '
          'and dartdoc can not determine which one is canonical',
      longHelp: [
        "Use {@canonicalFor $_namePlaceholder} in the desired library's",
        "documentation to resolve the ambiguity and/or override dartdoc's",
        'decision, or structure your package so the reexport is less',
        'ambiguous.  The symbol will still be referenced in all candidates --',
        'this only controls the location where it will be written and which',
        'library will be displayed in navigation for the relevant pages. The',
        'flag --ambiguous-reexport-scorer-min-confidence allows you to set the',
        'threshold at which this warning will appear.'
      ]),
  PackageWarning.ignoredCanonicalFor: PackageWarningDefinition(
      PackageWarning.ignoredCanonicalFor,
      'ignored-canonical-for',
      'A @canonicalFor tag refers to a library which this symbol can not be '
          'canonical for'),
  PackageWarning.noCanonicalFound: PackageWarningDefinition(
      PackageWarning.noCanonicalFound,
      'no-canonical-found',
      'A symbol is part of the public interface for this package, but no '
          'library documented with this package documents it so dartdoc can '
          'not link to it'),
  PackageWarning.noDefiningLibraryFound: PackageWarningDefinition(
      PackageWarning.noDefiningLibraryFound,
      'no-defining-library-found',
      'The defining library for an element could not be found; the library may '
          'be imported or exported with a non-standard URI',
      longHelp: [
        'For non-canonicalized import or export paths, dartdoc can sometimes lose ',
        'track of the defining library for an element.  If this happens, canonicalization',
        'will assume that reexported elements are defined somewhere it deems "reasonable", ',
        'defaulting first to the enclosing context\'s definingLibrary if available, ',
        'or the library is is visible in.  This can lead to confusing documentation ',
        'structure that implies duplicate code where none exists.',
        '',
        'To correct this, canonicalize all paths in the import or export chain',
        'making this symbol visible.',
        '',
        "For example: 'change  `import 'package:dartdoc/src/model/../model/extension_target.dart';`",
        "to  `import 'package:dartdoc/src/model/extension_target.dart';`",
        "or `import 'src/../src/foo.dart';`",
        "to `import 'src/foo.dart';",
        "or `import 'package:dartdoc//lib//foo.dart';",
        "to `import 'package:dartdoc/lib/foo.dart';",
      ],
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.notImplemented: PackageWarningDefinition(
      PackageWarning.notImplemented,
      'not-implemented',
      'The code makes use of a feature that is not yet implemented in dartdoc'),
  PackageWarning.noDocumentableLibrariesInPackage: PackageWarningDefinition(
    PackageWarning.noDocumentableLibrariesInPackage,
    'no-documentable-libraries',
    'The package is to be documented but has no Dart libraries to document',
    longHelp: [
      'Dartdoc could not find any public libraries to document in',
      '$_namePlaceholder, but documentation was requested.  This might be',
      'expected for an asset only package, in which case, disable this',
      'warning in your dartdoc_options.yaml file.',
    ],
  ),
  PackageWarning.noLibraryLevelDocs: PackageWarningDefinition(
      PackageWarning.noLibraryLevelDocs,
      'no-library-level-docs',
      'There are no library level docs for this library'),
  PackageWarning.packageOrderGivesMissingPackageName: PackageWarningDefinition(
      PackageWarning.packageOrderGivesMissingPackageName,
      'category-order-gives-missing-package-name',
      'The category-order flag on the command line was given the name of a nonexistent package'),
  PackageWarning.reexportedPrivateApiAcrossPackages: PackageWarningDefinition(
      PackageWarning.reexportedPrivateApiAcrossPackages,
      'reexported-private-api-across-packages',
      'One or more libraries reexports private API members from outside its own package'),
  PackageWarning.unresolvedDocReference: PackageWarningDefinition(
      PackageWarning.unresolvedDocReference,
      'unresolved-doc-reference',
      'A comment reference could not be found in parameters, enclosing class, enclosing library, or at the top level of any documented library with the package'),
  PackageWarning.brokenLink: PackageWarningDefinition(PackageWarning.brokenLink,
      'broken-link', 'Dartdoc generated a link to a non-existent file'),
  PackageWarning.unknownDirective: PackageWarningDefinition(
      PackageWarning.unknownDirective,
      'unknown-directive',
      'A comment contains an unknown directive'),
  PackageWarning.unknownMacro: PackageWarningDefinition(
      PackageWarning.unknownMacro,
      'unknown-macro',
      'A comment reference contains an unknown macro'),
  PackageWarning.orphanedFile: PackageWarningDefinition(
      PackageWarning.orphanedFile,
      'orphaned-file',
      'Dartdoc generated files that are unreachable from the index'),
  PackageWarning.unknownFile: PackageWarningDefinition(
      PackageWarning.unknownFile,
      'unknown-file',
      'A leftover file exists in the tree that dartdoc did not write in this pass'),
  PackageWarning.missingFromSearchIndex: PackageWarningDefinition(
      PackageWarning.missingFromSearchIndex,
      'missing-from-search-index',
      'A file generated by dartdoc is not present in the generated index.json'),
  PackageWarning.typeAsHtml: PackageWarningDefinition(
      PackageWarning.typeAsHtml,
      'type-as-html',
      'Use of <> in a comment for type parameters is being treated as HTML by markdown',
      defaultWarningMode: PackageWarningMode.ignore),
  PackageWarning.invalidParameter: PackageWarningDefinition(
      PackageWarning.invalidParameter,
      'invalid-parameter',
      'A parameter given to a dartdoc directive was invalid.',
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.toolError: PackageWarningDefinition(PackageWarning.toolError,
      'tool-error', 'Unable to execute external tool.',
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.deprecated: PackageWarningDefinition(PackageWarning.deprecated,
      'deprecated', 'A dartdoc directive has a deprecated format.'),
  PackageWarning.unresolvedExport: PackageWarningDefinition(
      PackageWarning.unresolvedExport,
      'unresolved-export',
      'An export refers to a URI that cannot be resolved.',
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.duplicateFile: PackageWarningDefinition(
      PackageWarning.duplicateFile,
      'duplicate-file',
      'Dartdoc is trying to write to a duplicate filename based on the names '
          'of Dart symbols.',
      longHelp: [
        'Dartdoc generates a path and filename to write to for each symbol.',
        '$_namePlaceholder conflicts with another symbol in the generated',
        'path, and therefore can not be written out.  Changing the name,',
        'library name, or class name (if appropriate) of one of the',
        'conflicting items can resolve the conflict.   Alternatively, use the',
        "@nodoc tag in one symbol's documentation comments to hide it."
      ],
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.missingConstantConstructor: PackageWarningDefinition(
      PackageWarning.missingConstantConstructor,
      'missing-constant-constructor',
      'Dartdoc can not show the value of a constant because its constructor could not be resolved.',
      longHelp: [
        'To resolve a constant into its literal value, Dartdoc relies on the',
        "analyzer to resolve the constructor.  The analyzer didn't provide",
        'the constructor for $_namePlaceholder, which is usually due to an',
        'error in the code.  Use the analyzer to find missing imports.',
      ],
      // Defaults to ignore as this doesn't impact the docs severely but is
      // useful for debugging package structure.
      defaultWarningMode: PackageWarningMode.ignore),
  PackageWarning.missingCodeBlockLanguage: PackageWarningDefinition(
      PackageWarning.missingCodeBlockLanguage,
      'missing-code-block-language',
      'A fenced code block is missing a specified language.',
      longHelp: [
        'To enable proper syntax highlighting of Markdown code blocks,',
        'Dartdoc requires code blocks to specify the language used after',
        'the initial declaration.  As an example, to specify Dart you would',
        'specify ```dart or ~~~dart.'
      ],
      defaultWarningMode: PackageWarningMode.ignore),
};

/// Something that package warnings can be called on.  Optionally associated
/// with an analyzer [element].
mixin Warnable implements Canonicalization, CommentReferable {
  Element? get element;

  Package get package;

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

// The kinds of warnings that can be displayed when documenting a package.
enum PackageWarning {
  ambiguousDocReference('ambiguous doc reference {0}'),

  // Fix these warnings by adding the original library exporting the symbol with
  // `--include`, by using `--auto-include-dependencies`, or by using
  // `--exclude` to hide one of the libraries involved.
  ambiguousReexport(
      'ambiguous reexport of {0}, canonicalization candidates: {1}'),
  ignoredCanonicalFor(
      "library says it is {@canonicalFor {0}} but {0} can't be canonical "
      'there'),

  // Fix these warnings by adding libraries with `--include`, or by using
  // `--auto-include-dependencies`.
  // TODO(jcollins-g): pipeline references through `linkedName` for error
  // messages and warn for non-public canonicalization errors.
  noCanonicalFound('no canonical library found for {0}, not linking'),
  noDefiningLibraryFound('could not find the defining library for {0}; the '
      'library may be imported or exported with a non-standard URI'),
  notImplemented('{0}'),
  noDocumentableLibrariesInPackage('{0} has no documentable libraries'),
  noLibraryLevelDocs('{0} has no library level documentation comments'),
  packageOrderGivesMissingPackageName(
      "--package-order gives invalid package name: '{0}'"),
  reexportedPrivateApiAcrossPackages(
      'private API of {0} is reexported by libraries in other packages: '),
  unresolvedDocReference('unresolved doc reference [{0}]',
      referredFromPrefix: 'in documentation inherited from'),
  unknownDirective('undefined directive: {0}'),
  unknownMacro('undefined macro [{0}]'),
  unknownHtmlFragment('undefined HTML fragment identifier [{0}]'),
  brokenLink('dartdoc generated a broken link to: {0}',
      warnablePrefix: 'to element', referredFromPrefix: 'linked to from'),
  duplicateFile('failed to write file at: {0}',
      warnablePrefix: 'for symbol',
      referredFromPrefix: 'conflicting with file already generated by'),
  orphanedFile('dartdoc generated a file orphan: {0}'),
  unknownFile('dartdoc detected an unknown file in the doc tree: {0}'),
  missingFromSearchIndex(
      'dartdoc generated a file not in the search index: {0}'),

  // The message for this warning can contain many punctuation and other
  // symbols, so bracket with a triple quote for defense.
  typeAsHtml('generic type handled as HTML: """{0}"""'),
  invalidParameter('invalid parameter to dartdoc directive: {0}'),
  toolError('tool execution failed: {0}'),
  deprecated('deprecated dartdoc usage: {0}'),
  unresolvedExport('unresolved export uri: {0}'),
  missingConstantConstructor('constant constructor missing: {0}'),
  missingExampleFile('example file not found: {0}'),
  missingCodeBlockLanguage('missing code block language: {0}');

  final String template;

  final String warnablePrefix;

  final String referredFromPrefix;

  const PackageWarning(
    this.template, {
    this.warnablePrefix = 'from',
    this.referredFromPrefix = 'referred to by',
  });

  String messageFor(List<String> messageParts) {
    var message = template;
    for (var i = 0; i < messageParts.length; i++) {
      message = message.replaceAll('{$i}', messageParts[i]);
    }
    return message;
  }

  String messageForWarnable(Warnable warnable) =>
      '$warnablePrefix ${warnable.safeWarnableName}: ${warnable.location}';

  String messageForReferral(Locatable referral) =>
      '$referredFromPrefix ${referral.safeWarnableName}: ${referral.location}';
}

/// Used to declare defaults for a particular package warning.
enum PackageWarningMode {
  ignore,
  warn,
  error,
}

/// Warnings it is OK to skip if we can determine the warnable isn't documented.
/// In particular, this set should not include warnings around public/private
/// or canonicalization problems, because those can break the isDocumented()
/// check.
const Set<PackageWarning> skipWarningIfNotDocumentedFor = {
  PackageWarning.unresolvedDocReference,
  PackageWarning.typeAsHtml
};

class PackageWarningOptions {
  final Map<PackageWarning, PackageWarningMode> warningModes = {};

  PackageWarningOptions() {
    for (var definition in packageWarningDefinitions.values) {
      switch (definition.defaultWarningMode) {
        case PackageWarningMode.warn:
          warn(definition.kind);
          break;
        case PackageWarningMode.error:
          error(definition.kind);
          break;
        case PackageWarningMode.ignore:
          ignore(definition.kind);
          break;
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
      var packageWarnings = packageWarningsByName[warningName];
      if (packageWarnings != null) {
        newOptions.error(packageWarnings.kind);
      }
    }
    var warningsForDir =
        option.parent.getValueAs<List<String>?>('warnings', dir) ?? [];
    for (var warningName in warningsForDir) {
      var packageWarnings = packageWarningsByName[warningName];
      if (packageWarnings != null) {
        newOptions.warn(packageWarnings.kind);
      }
    }
    var ignoredForDir =
        option.parent.getValueAs<List<String>?>('ignore', dir) ?? [];
    for (var warningName in ignoredForDir) {
      var packageWarnings = packageWarningsByName[warningName];
      if (packageWarnings != null) {
        newOptions.ignore(packageWarnings.kind);
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

  PackageWarningMode? getMode(PackageWarning kind) => warningModes[kind];
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

  /// Actually write out the warning.
  ///
  /// Assumes it is already counted with [addWarning].
  void _writeWarning(PackageWarning kind, PackageWarningMode? mode,
      bool verboseWarnings, String name, String fullMessage) {
    if (mode == PackageWarningMode.ignore) {
      return;
    }
    String? type;
    if (mode == PackageWarningMode.error) {
      type = 'error';
    } else if (mode == PackageWarningMode.warn) {
      type = 'warning';
    }
    if (type != null) {
      var entry = '  $type: $fullMessage';
      var displayedWarningCount = _displayedWarningCounts.increment(kind);
      var packageWarningDefinition = packageWarningDefinitions[kind]!;
      if (displayedWarningCount == 1 &&
          verboseWarnings &&
          packageWarningDefinition.longHelp.isNotEmpty) {
        // First time we've seen this warning.  Give a little extra info.
        final separator = '\n            ';
        var verboseOut =
            '$separator${packageWarningDefinition.longHelp.join(separator)}'
                .replaceAll(_namePlaceholder, name);
        entry = '$entry$verboseOut';
      }
      assert(entry == entry.trimRight());
      _items.add(_JsonWarning(type, kind, fullMessage, entry));
    }
    for (var item in _items) {
      logWarning(item.toString());
    }
    _items.clear();
  }

  /// If this package has had any warnings counted.
  bool get hasWarnings => _countedWarnings.isNotEmpty;

  /// Returns `true` if we've already warned for this
  /// combination of [element], [kind], and [message].
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
    PackageWarningMode? warningMode;
    var isLocal = element?.package.isLocal ?? true;
    if (!config.allowNonLocalWarnings && !isLocal) {
      warningMode = PackageWarningMode.ignore;
    } else {
      warningMode = config.packageWarningOptions.getMode(kind);
    }
    if (warningMode == PackageWarningMode.warn) {
      _warningCount += 1;
    } else if (warningMode == PackageWarningMode.error) {
      _errorCount += 1;
    }
    if (element != null) {
      _countedWarnings
          .putIfAbsent(element.element, () => {})
          .putIfAbsent(kind, () => {})
          .add(message);
      _writeWarning(kind, warningMode, config.verboseWarnings,
          element.fullyQualifiedName, fullMessage);
    }
  }

  @override
  String toString() {
    final errors = '$errorCount ${errorCount == 1 ? "error" : "errors"}';
    final warnings =
        '$warningCount ${warningCount == 1 ? "warning" : "warnings"}';
    return '$errors, $warnings';
  }
}

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
        'kind': packageWarningDefinitions[kind]!.warningName,
        'message': message,
        'text': text
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
