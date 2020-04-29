// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/tuple.dart';

abstract class PackageWarningOptionContext implements DartdocOptionContextBase {
  bool get allowNonLocalWarnings =>
      optionSet['allowNonLocalWarnings'].valueAt(context);

  // allowWarningsInPackages, ignoreWarningsInPackages, errors, warnings, and ignore
  // are only used indirectly via the synthetic packageWarningOptions option.
  PackageWarningOptions get packageWarningOptions =>
      optionSet['packageWarningOptions'].valueAt(context);

  bool get verboseWarnings => optionSet['verboseWarnings'].valueAt(context);
}

Future<List<DartdocOption>> createPackageWarningOptions() async {
  return <DartdocOption>[
    DartdocOptionArgOnly<bool>('allowNonLocalWarnings', false,
        negatable: true,
        help: 'Show warnings from packages we are not documenting locally.'),

    // Options for globally enabling/disabling all warnings and errors
    // for individual packages are command-line only.  This will allow
    // meta-packages like Flutter to control whether warnings are displayed for
    // packages they don't control.
    DartdocOptionArgOnly<List<String>>('allowWarningsInPackages', null,
        help:
            'Package names to display warnings for (ignore all others if set).'),
    DartdocOptionArgOnly<List<String>>('allowErrorsInPackages', null,
        help: 'Package names to display errors for (ignore all others if set)'),
    DartdocOptionArgOnly<List<String>>('ignoreWarningsInPackages', null,
        help:
            'Package names to ignore warnings for.  Takes priority over allow-warnings-in-packages'),
    DartdocOptionArgOnly<List<String>>('ignoreErrorsInPackages', null,
        help:
            'Package names to ignore errors for. Takes priority over allow-errors-in-packages'),
    // Options for globally enabling/disabling warnings and errors across
    // packages.  Loaded from dartdoc_options.yaml, but command line arguments
    // will override.
    DartdocOptionArgFile<List<String>>('errors', null,
        help:
            'Additional warning names to force as errors.  Specify an empty list to force defaults (overriding dartdoc_options.yaml)\nDefaults:\n' +
                (packageWarningDefinitions.values
                        .where((d) =>
                            d.defaultWarningMode == PackageWarningMode.error)
                        .toList()
                          ..sort())
                    .map((d) => '   ${d.warningName}: ${d.shortHelp}')
                    .join('\n')),
    DartdocOptionArgFile<List<String>>('ignore', null,
        help:
            'Additional warning names to ignore.  Specify an empty list to force defaults (overriding dartdoc_options.yaml).\nDefaults:\n' +
                (packageWarningDefinitions.values
                        .where((d) =>
                            d.defaultWarningMode == PackageWarningMode.ignore)
                        .toList()
                          ..sort())
                    .map((d) => '   ${d.warningName}: ${d.shortHelp}')
                    .join('\n')),
    DartdocOptionArgFile<List<String>>('warnings', null,
        help:
            'Additional warning names to show as warnings (instead of error or ignore, if not warning by default).\nDefaults:\n' +
                (packageWarningDefinitions.values
                        .where((d) =>
                            d.defaultWarningMode == PackageWarningMode.warn)
                        .toList()
                          ..sort())
                    .map((d) => '   ${d.warningName}: ${d.shortHelp}')
                    .join('\n')),
    // Synthetic option uses a factory to build a PackageWarningOptions from all the above flags.
    DartdocOptionSyntheticOnly<PackageWarningOptions>(
        'packageWarningOptions', PackageWarningOptions.fromOptions),
  ];
}

class PackageWarningDefinition implements Comparable<PackageWarningDefinition> {
  final String warningName;
  final String shortHelp;
  final List<String> longHelp;
  final PackageWarning kind;
  final PackageWarningMode defaultWarningMode;

  const PackageWarningDefinition(this.kind, this.warningName, this.shortHelp,
      {List<String> longHelp, PackageWarningMode defaultWarningMode})
      : longHelp = longHelp ?? const [],
        defaultWarningMode = defaultWarningMode ?? PackageWarningMode.warn;

  @override
  int compareTo(PackageWarningDefinition other) {
    return warningName.compareTo(other.warningName);
  }
}

/// Same as [packageWarningDefinitions], except keyed by the warning name.
final Map<String, PackageWarningDefinition> packageWarningsByName =
    Map.fromEntries(packageWarningDefinitions.values
        .map((definition) => MapEntry(definition.warningName, definition)));

/// Provides description text and command line flags for warnings.
/// TODO(jcollins-g): Actually use this for command line flags.
final Map<PackageWarning, PackageWarningDefinition> packageWarningDefinitions =
    const {
  PackageWarning.ambiguousDocReference: PackageWarningDefinition(
      PackageWarning.ambiguousDocReference,
      'ambiguous-doc-reference',
      'A comment reference could refer to two or more different objects'),
  PackageWarning.ambiguousReexport: PackageWarningDefinition(
      PackageWarning.ambiguousReexport,
      'ambiguous-reexport',
      'A symbol is exported from private to public in more than one library and dartdoc can not determine which one is canonical',
      longHelp: [
        "Use {@canonicalFor @@name@@} in the desired library's documentation to resolve",
        "the ambiguity and/or override dartdoc's decision, or structure your package ",
        'so the reexport is less ambiguous.  The symbol will still be referenced in ',
        'all candidates -- this only controls the location where it will be written ',
        'and which library will be displayed in navigation for the relevant pages.',
        'The flag --ambiguous-reexport-scorer-min-confidence allows you to set the',
        'threshold at which this warning will appear.'
      ]),
  PackageWarning.ignoredCanonicalFor: PackageWarningDefinition(
      PackageWarning.ignoredCanonicalFor,
      'ignored-canonical-for',
      'A @canonicalFor tag refers to a library which this symbol can not be canonical for'),
  PackageWarning.noCanonicalFound: PackageWarningDefinition(
      PackageWarning.noCanonicalFound,
      'no-canonical-found',
      'A symbol is part of the public interface for this package, but no library documented with this package documents it so dartdoc can not link to it'),
  PackageWarning.notImplemented: PackageWarningDefinition(
      PackageWarning.notImplemented,
      'not-implemented',
      'The code makes use of a feature that is not yet implemented in dartdoc'),
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
      'Dartdoc is trying to write to a duplicate filename based on the names of Dart symbols.',
      longHelp: [
        'Dartdoc generates a path and filename to write to for each symbol.',
        '@@name@@ conflicts with another symbol in the generated path, and',
        'therefore can not be written out.  Changing the name, library name, or',
        'class name (if appropriate) of one of the conflicting items can resolve',
        "the conflict.   Alternatively, use the @nodoc tag in one symbol's",
        'documentation comments to hide it.'
      ],
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.missingConstantConstructor: PackageWarningDefinition(
      PackageWarning.missingConstantConstructor,
      'missing-constant-constructor',
      'Dartdoc can not show the value of a constant because its constructor could not be resolved.',
      longHelp: [
        'To resolve a constant into its literal value, Dartdoc relies on the',
        "analyzer to resolve the constructor.  The analyzer didn't provide",
        'the constructor for @@name@@, which is usually due to an error in the',
        'code.  Use the analyzer to find missing imports.',
      ],
      // Defaults to ignore as this doesn't impact the docs severely but is
      // useful for debugging package structure.
      defaultWarningMode: PackageWarningMode.ignore),
};

/// Something that package warnings can be called on.  Optionally associated
/// with an analyzer [element].
abstract class Warnable implements Canonicalization {
  void warn(PackageWarning warning,
      {String message, Iterable<Locatable> referredFrom});

  Element get element;

  Warnable get enclosingElement;

  Package get package;
}

// The kinds of warnings that can be displayed when documenting a package.
enum PackageWarning {
  ambiguousDocReference,
  ambiguousReexport,
  ignoredCanonicalFor,
  noCanonicalFound,
  notImplemented,
  noLibraryLevelDocs,
  packageOrderGivesMissingPackageName,
  reexportedPrivateApiAcrossPackages,
  unresolvedDocReference,
  unknownMacro,
  unknownHtmlFragment,
  brokenLink,
  duplicateFile,
  orphanedFile,
  unknownFile,
  missingFromSearchIndex,
  typeAsHtml,
  invalidParameter,
  toolError,
  deprecated,
  unresolvedExport,
  missingConstantConstructor,
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
final Set<PackageWarning> skipWarningIfNotDocumentedFor = {
  PackageWarning.unresolvedDocReference,
  PackageWarning.typeAsHtml
};

class PackageWarningOptions {
  final Map<PackageWarning, PackageWarningMode> warningModes = {};

  PackageWarningOptions() {
    for (var definition in packageWarningDefinitions.values) {
      switch (definition.defaultWarningMode) {
        case PackageWarningMode.warn:
          {
            warn(definition.kind);
          }
          break;
        case PackageWarningMode.error:
          {
            error(definition.kind);
          }
          break;
        case PackageWarningMode.ignore:
          {
            ignore(definition.kind);
          }
          break;
      }
    }
  }

  /// [packageMeta] parameter is for testing.
  static PackageWarningOptions fromOptions(
      DartdocSyntheticOption<PackageWarningOptions> option, Directory dir) {
    // First, initialize defaults.
    var newOptions = PackageWarningOptions();
    var packageMeta = PackageMeta.fromDir(dir);

    // Interpret errors/warnings/ignore options.  In the event of conflict, warning overrides error and
    // ignore overrides warning.
    for (String warningName in option.parent['errors'].valueAt(dir) ?? []) {
      if (packageWarningsByName[warningName] != null) {
        newOptions.error(packageWarningsByName[warningName].kind);
      }
    }
    for (String warningName in option.parent['warnings'].valueAt(dir) ?? []) {
      if (packageWarningsByName[warningName] != null) {
        newOptions.warn(packageWarningsByName[warningName].kind);
      }
    }
    for (String warningName in option.parent['ignore'].valueAt(dir) ?? []) {
      if (packageWarningsByName[warningName] != null) {
        newOptions.ignore(packageWarningsByName[warningName].kind);
      }
    }

    // Check whether warnings are allowed at all in this package.
    List<String> allowWarningsInPackages =
        option.parent['allowWarningsInPackages'].valueAt(dir);
    List<String> allowErrorsInPackages =
        option.parent['allowErrorsInPackages'].valueAt(dir);
    List<String> ignoreWarningsInPackages =
        option.parent['ignoreWarningsInPackages'].valueAt(dir);
    List<String> ignoreErrorsInPackages =
        option.parent['ignoreErrorsInPackages'].valueAt(dir);
    if (allowWarningsInPackages != null &&
        !allowWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values
          .forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    if (allowErrorsInPackages != null &&
        !allowWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values
          .forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    if (ignoreWarningsInPackages != null &&
        ignoreWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values
          .forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    if (ignoreErrorsInPackages != null &&
        ignoreErrorsInPackages.contains(packageMeta.name)) {
      PackageWarning.values
          .forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    return newOptions;
  }

  void ignore(PackageWarning kind) =>
      warningModes[kind] = PackageWarningMode.ignore;

  void warn(PackageWarning kind) =>
      warningModes[kind] = PackageWarningMode.warn;

  void error(PackageWarning kind) =>
      warningModes[kind] = PackageWarningMode.error;

  PackageWarningMode getMode(PackageWarning kind) => warningModes[kind];
}

class PackageWarningCounter {
  final countedWarnings = <Element, Set<Tuple2<PackageWarning, String>>>{};
  final _items = <Jsonable>[];
  final _displayedWarningCounts = <PackageWarning, int>{};
  final PackageGraph packageGraph;

  PackageWarningCounter(this.packageGraph);

  /// Actually write out the warning.  Assumes it is already counted with add.
  void _writeWarning(PackageWarning kind, PackageWarningMode mode,
      bool verboseWarnings, String name, String fullMessage) {
    if (mode == PackageWarningMode.ignore) {
      return;
    }
    String type;
    if (mode == PackageWarningMode.error) {
      type = 'error';
    } else if (mode == PackageWarningMode.warn) {
      type = 'warning';
    }
    if (type != null) {
      var entry = '  $type: $fullMessage';
      _displayedWarningCounts.putIfAbsent(kind, () => 0);
      _displayedWarningCounts[kind] += 1;
      if (_displayedWarningCounts[kind] == 1 &&
          verboseWarnings &&
          packageWarningDefinitions[kind].longHelp.isNotEmpty) {
        // First time we've seen this warning.  Give a little extra info.
        final separator = '\n            ';
        final nameSub = r'@@name@@';
        var verboseOut =
            '$separator${packageWarningDefinitions[kind].longHelp.join(separator)}'
                .replaceAll(nameSub, name);
        entry = '$entry$verboseOut';
      }
      assert(entry == entry.trimRight());
      _items.add(_JsonWarning(type, kind, fullMessage, entry));
    }
    for (var item in _items) {
      logWarning(item);
    }
    _items.clear();
  }

  /// Returns true if we've already warned for this.
  bool hasWarning(Warnable element, PackageWarning kind, String message) {
    var warningData = Tuple2<PackageWarning, String>(kind, message);
    if (countedWarnings.containsKey(element?.element)) {
      return countedWarnings[element?.element].contains(warningData);
    }
    return false;
  }

  /// Adds the warning to the counter, and writes out the fullMessage string
  /// if configured to do so.
  void addWarning(Warnable element, PackageWarning kind, String message,
      String fullMessage) {
    assert(!hasWarning(element, kind, message));
    // TODO(jcollins-g): Make addWarning not accept nulls for element.
    PackageWarningOptionContext config =
        element?.config ?? packageGraph.defaultPackage.config;
    var warningMode = config.packageWarningOptions.getMode(kind);
    if (!config.allowNonLocalWarnings &&
        element != null &&
        !element.package.isLocal) {
      warningMode = PackageWarningMode.ignore;
    }
    if (warningMode == PackageWarningMode.warn) {
      warningCount += 1;
    } else if (warningMode == PackageWarningMode.error) {
      errorCount += 1;
    }
    var warningData = Tuple2<PackageWarning, String>(kind, message);
    countedWarnings.putIfAbsent(element?.element, () => {});
    countedWarnings[element?.element].add(warningData);
    _writeWarning(kind, warningMode, config.verboseWarnings,
        element?.fullyQualifiedName, fullMessage);
  }

  int errorCount = 0;
  int warningCount = 0;

  @override
  String toString() {
    var errors = '$errorCount ${errorCount == 1 ? "error" : "errors"}';
    var warnings =
        '$warningCount ${warningCount == 1 ? "warning" : "warnings"}';
    return [errors, warnings].join(', ');
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
        'kind': packageWarningDefinitions[kind].warningName,
        'message': message,
        'text': text
      };
}
