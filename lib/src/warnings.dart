// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/tuple.dart';


abstract class PackageWarningOptionContext implements DartdocOptionContextBase {
  bool get allowNonLocalWarnings => optionSet['allowNonLocalWarnings'].valueAt(context);
  // allowWarningsInPackages, ignoreWarningsInPackages, errors, warnings, and ignore
  // are only used indirectly via the synthetic packageWarningOptions option.
  PackageWarningOptions get packageWarningOptions => optionSet['packageWarningOptions'].valueAt(context);
  bool get verboseWarnings => optionSet['verboseWarnings'].valueAt(context);
}

Future<List<DartdocOption>> createPackageWarningOptions() async {
  return <DartdocOption>[
    new DartdocOptionArgOnly<bool>('allowNonLocalWarnings', false, negatable: true, help: 'Show warnings from packages we are not documenting locally.'),

    // Options for globally enabling/disabling all warnings and errors
    // for individual packages are command-line only.  This will allow
    // meta-packages like Flutter to control whether warnings are displayed for
    // packages they don't control.
    new DartdocOptionArgOnly<List<String>>('allowWarningsInPackages', null, help: 'Package names to display warnings for (ignore all others if set).'),
    new DartdocOptionArgOnly<List<String>>('allowErrorsInPackages', null, help: 'Package names to display errors for (ignore all others if set)'),
    new DartdocOptionArgOnly<List<String>>('ignoreWarningsInPackages', null, help: 'Package names to ignore warnings for.  Takes priority over allow-warnings-in-packages'),
    new DartdocOptionArgOnly<List<String>>('ignoreErrorsInPackages', null, help: 'Package names to ignore errors for. Takes priority over allow-errors-in-packages'),
    // Options for globally enabling/disabling warnings and errors across
    // packages.  Loaded from dartdoc_options.yaml, but command line arguments
    // will override.
    new DartdocOptionArgFile<List<String>>('errors', null, help: 'Additional warning names to force as errors.  Specify an empty list to force defaults (overriding dartdoc_options.yaml)\nDefaults:\n' +
        (packageWarningDefinitions.values
           .where((d) => d.defaultWarningMode == PackageWarningMode.error)
           .toList()..sort())
           .map((d) => '   ${d.warningName}: ${d.shortHelp}')
           .join('\n')),
    new DartdocOptionArgFile<List<String>>('ignore', null, help: 'Additional warning names to ignore.  Specify an empty list to force defaults (overriding dartdoc_options.yaml).\nDefaults:\n' +
        (packageWarningDefinitions.values
            .where((d) => d.defaultWarningMode == PackageWarningMode.ignore)
            .toList()..sort())
            .map((d) => '   ${d.warningName}: ${d.shortHelp}')
            .join('\n')),
    new DartdocOptionArgFile<List<String>>('warnings', null, help: 'Additional warning names to show as warnings (instead of error or ignore, if not warning by default).\nDefaults:\n' +
        (packageWarningDefinitions.values
            .where((d) => d.defaultWarningMode == PackageWarningMode.warn)
            .toList()..sort())
            .map((d) => '   ${d.warningName}: ${d.shortHelp}')
            .join('\n')),
    // Synthetic option uses a factory to build a PackageWarningOptions from all the above flags.
    new DartdocOptionSyntheticOnly<PackageWarningOptions>('packageWarningOptions', PackageWarningOptions.fromOptions),
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
      : this.longHelp = longHelp ?? const [], this.defaultWarningMode = defaultWarningMode ?? PackageWarningMode.warn;

  @override
  int compareTo(PackageWarningDefinition other) {
    return warningName.compareTo(other.warningName);
  }
}

/// Same as [packageWarningDefinitions], except keyed by the warning name.
final Map<String, PackageWarningDefinition> packageWarningsByName = new Map.fromEntries(packageWarningDefinitions.values.map((definition) => new MapEntry(definition.warningName, definition)));

/// Provides description text and command line flags for warnings.
/// TODO(jcollins-g): Actually use this for command line flags.
final Map<PackageWarning, PackageWarningDefinition> packageWarningDefinitions = const {
  PackageWarning.ambiguousDocReference: const PackageWarningDefinition(
      PackageWarning.ambiguousDocReference,
      "ambiguous-doc-reference",
      "A comment reference could refer to two or more different objects"),
  PackageWarning.ambiguousReexport: const PackageWarningDefinition(
      PackageWarning.ambiguousReexport,
      "ambiguous-reexport",
      "A symbol is exported from private to public in more than one library and dartdoc can not determine which one is canonical",
      longHelp: const [
        "Use {@canonicalFor @@name@@} in the desired library's documentation to resolve",
        "the ambiguity and/or override dartdoc's decision, or structure your package ",
        "so the reexport is less ambiguous.  The symbol will still be referenced in ",
        "all candidates -- this only controls the location where it will be written ",
        "and which library will be displayed in navigation for the relevant pages.",
        "The flag --ambiguous-reexport-scorer-min-confidence allows you to set the",
        "threshold at which this warning will appear."
      ]),
  PackageWarning.ignoredCanonicalFor: const PackageWarningDefinition(
      PackageWarning.ignoredCanonicalFor,
      "ignored-canonical-for",
      "A @canonicalFor tag refers to a library which this symbol can not be canonical for"),
  PackageWarning.noCanonicalFound: const PackageWarningDefinition(
      PackageWarning.noCanonicalFound,
      "no-canonical-found",
      "A symbol is part of the public interface for this package, but no library documented with this package documents it so dartdoc can not link to it"),
  PackageWarning.noLibraryLevelDocs: const PackageWarningDefinition(
      PackageWarning.noLibraryLevelDocs,
      "no-library-level-docs",
      "There are no library level docs for this library"),
  PackageWarning.packageOrderGivesMissingPackageName: const PackageWarningDefinition(
      PackageWarning.packageOrderGivesMissingPackageName,
      "category-order-gives-missing-package-name",
      "The category-order flag on the command line was given the name of a nonexistent package"),
  PackageWarning.reexportedPrivateApiAcrossPackages: const PackageWarningDefinition(
      PackageWarning.reexportedPrivateApiAcrossPackages,
      "reexported-private-api-across-packages",
      "One or more libraries reexports private API members from outside its own package"),
  PackageWarning.unresolvedDocReference: const PackageWarningDefinition(
      PackageWarning.unresolvedDocReference,
      "unresolved-doc-reference",
      "A comment reference could not be found in parameters, enclosing class, enclosing library, or at the top level of any documented library with the package"),
  PackageWarning.brokenLink: const PackageWarningDefinition(
      PackageWarning.brokenLink,
      "broken-link",
      "Dartdoc generated a link to a non-existent file"),
  PackageWarning.unknownMacro: const PackageWarningDefinition(
      PackageWarning.unknownMacro,
      "unknown-macro",
      "A comment reference contains an unknown macro"),
  PackageWarning.orphanedFile: const PackageWarningDefinition(
      PackageWarning.orphanedFile,
      "orphaned-file",
      "Dartdoc generated files that are unreachable from the index"),
  PackageWarning.unknownFile: const PackageWarningDefinition(
      PackageWarning.unknownFile,
      "unknown-file",
      "A leftover file exists in the tree that dartdoc did not write in this pass"),
  PackageWarning.missingFromSearchIndex: const PackageWarningDefinition(
      PackageWarning.missingFromSearchIndex,
      "missing-from-search-index",
      "A file generated by dartdoc is not present in the generated index.json"),
  PackageWarning.typeAsHtml: const PackageWarningDefinition(
      PackageWarning.typeAsHtml,
      "type-as-html",
      "Use of <> in a comment for type parameters is being treated as HTML by markdown",
      defaultWarningMode: PackageWarningMode.ignore),
  PackageWarning.invalidParameter: const PackageWarningDefinition(
      PackageWarning.invalidParameter,
      "invalid-parameter",
      "A parameter given to a dartdoc directive was invalid.",
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.toolError: const PackageWarningDefinition(
      PackageWarning.toolError,
      "tool-error",
      "Unable to execute external tool.",
      defaultWarningMode: PackageWarningMode.error),
  PackageWarning.deprecated: const PackageWarningDefinition(
      PackageWarning.deprecated,
      "deprecated",
      "A dartdoc directive has a deprecated format."),
  PackageWarning.unresolvedExport: const PackageWarningDefinition(
      PackageWarning.unresolvedExport,
      "unresolved-export",
      "An export refers to a URI that cannot be resolved.",
      defaultWarningMode: PackageWarningMode.error),
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

/// Something that can be located for warning purposes.
abstract class Locatable {
  String get fullyQualifiedName;
  String get href;

  List<Locatable> get documentationFrom;

  /// A string indicating the URI of this Locatable, usually derived from
  /// [Element.location].
  String get location;
}

// The kinds of warnings that can be displayed when documenting a package.
enum PackageWarning {
  ambiguousDocReference,
  ambiguousReexport,
  ignoredCanonicalFor,
  noCanonicalFound,
  noLibraryLevelDocs,
  packageOrderGivesMissingPackageName,
  reexportedPrivateApiAcrossPackages,
  unresolvedDocReference,
  unknownMacro,
  unknownHtmlFragment,
  brokenLink,
  orphanedFile,
  unknownFile,
  missingFromSearchIndex,
  typeAsHtml,
  invalidParameter,
  toolError,
  deprecated,
  unresolvedExport,
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
final Set<PackageWarning> skipWarningIfNotDocumentedFor = new Set()
  ..addAll([PackageWarning.unresolvedDocReference, PackageWarning.typeAsHtml]);

class PackageWarningOptions {
  final Map<PackageWarning, PackageWarningMode> _warningModes = {};

  PackageWarningOptions() {
    for (PackageWarningDefinition definition in packageWarningDefinitions.values) {
      switch (definition.defaultWarningMode) {
        case PackageWarningMode.warn: {
          warn(definition.kind);
        }
        break;
        case PackageWarningMode.error: {
          error(definition.kind);
        }
        break;
        case PackageWarningMode.ignore: {
          ignore(definition.kind);
        }
        break;
      }
    }
  }

  static PackageWarningOptions fromOptions(DartdocSyntheticOption<PackageWarningOptions> option, Directory dir) {
    // First, initialize defaults.
    PackageWarningOptions newOptions = PackageWarningOptions();

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
    List<String> allowWarningsInPackages = option.parent['allowWarningsInPackages'].valueAt(dir);
    List<String> allowErrorsInPackages = option.parent['allowErrorsInPackages'].valueAt(dir);
    List<String> ignoreWarningsInPackages = option.parent['ignoreWarningsInPackages'].valueAt(dir);
    List<String> ignoreErrorsInPackages = option.parent['ignoreErrorsInPackages'].valueAt(dir);
    PackageMeta packageMeta = new PackageMeta.fromDir(dir);
    if (allowWarningsInPackages != null && !allowWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    if (allowErrorsInPackages != null && !allowWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    if (ignoreWarningsInPackages != null && ignoreWarningsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    if (ignoreErrorsInPackages != null && ignoreErrorsInPackages.contains(packageMeta.name)) {
      PackageWarning.values.forEach((PackageWarning kind) => newOptions.ignore(kind));
    }
    return newOptions;
  }

  void ignore(PackageWarning kind) => _warningModes[kind] = PackageWarningMode.ignore;
  void warn(PackageWarning kind) => _warningModes[kind] = PackageWarningMode.warn;
  void error(PackageWarning kind) => _warningModes[kind] = PackageWarningMode.error;

  PackageWarningMode getMode(PackageWarning kind) => _warningModes[kind];
}

class PackageWarningCounter {
  final countedWarnings =
      new Map<Element, Set<Tuple2<PackageWarning, String>>>();
  final _items = <Jsonable>[];
  final _displayedWarningCounts = <PackageWarning, int>{};

  /// Actually write out the warning.  Assumes it is already counted with add.
  void _writeWarning(PackageWarning kind, PackageWarningMode mode, bool verboseWarnings, String name, String fullMessage) {
    if (mode == PackageWarningMode.ignore) {
      return;
    }
    String type;
    if (mode == PackageWarningMode.error) {
      type = "error";
    } else if (mode == PackageWarningMode.warn) {
      type = "warning";
    }
    if (type != null) {
      var entry = "  $type: $fullMessage";
      _displayedWarningCounts.putIfAbsent(kind, () => 0);
      _displayedWarningCounts[kind] += 1;
      if (_displayedWarningCounts[kind] == 1 &&
          verboseWarnings &&
          packageWarningDefinitions[kind].longHelp.isNotEmpty) {
        // First time we've seen this warning.  Give a little extra info.
        final String separator = '\n            ';
        final String nameSub = r'@@name@@';
        String verboseOut =
            '$separator${packageWarningDefinitions[kind].longHelp.join(separator)}'
                .replaceAll(nameSub, name);
        entry = '$entry$verboseOut';
      }
      assert(entry == entry.trimRight());
      _items.add(new _JsonWarning(type, kind, fullMessage, entry));
    }
    for (var item in _items) {
      logWarning(item);
    }
    _items.clear();
  }

  /// Returns true if we've already warned for this.
  bool hasWarning(Warnable element, PackageWarning kind, String message) {
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
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
    PackageWarningMode warningMode = element.config.packageWarningOptions.getMode(kind);
    if (!element.config.allowNonLocalWarnings && !element.package.isLocal) {
      warningMode = PackageWarningMode.ignore;
    }
    if (warningMode == PackageWarningMode.warn) warningCount += 1;
    else if (warningMode == PackageWarningMode.error) errorCount += 1;
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    countedWarnings.putIfAbsent(element?.element, () => new Set());
    countedWarnings[element?.element].add(warningData);
    _writeWarning(kind, warningMode, element.config.verboseWarnings, element?.fullyQualifiedName, fullMessage);
  }

  int errorCount = 0;
  int warningCount = 0;

  @override
  String toString() {
    String errors = '$errorCount ${errorCount == 1 ? "error" : "errors"}';
    String warnings =
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
