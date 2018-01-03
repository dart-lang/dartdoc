// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model.dart';
import 'package:tuple/tuple.dart';

import 'config.dart';
import 'logging.dart';

class PackageWarningHelpText {
  final String warningName;
  final String shortHelp;
  final List<String> longHelp;
  final PackageWarning warning;

  const PackageWarningHelpText(this.warning, this.warningName, this.shortHelp,
      [List<String> longHelp])
      : this.longHelp = longHelp ?? const [];
}

/// Provides description text and command line flags for warnings.
/// TODO(jcollins-g): Actually use this for command line flags.
final Map<PackageWarning, PackageWarningHelpText> packageWarningText = const {
  PackageWarning.ambiguousDocReference: const PackageWarningHelpText(
      PackageWarning.ambiguousDocReference,
      "ambiguous-doc-reference",
      "A comment reference could refer to two or more different objects"),
  PackageWarning.ambiguousReexport: const PackageWarningHelpText(
      PackageWarning.ambiguousReexport,
      "ambiguous-reexport",
      "A symbol is exported from private to public in more than one library and dartdoc can not determine which one is canonical",
      const [
        "Use {@canonicalFor @@name@@} in the desired library's documentation to resolve",
        "the ambiguity and/or override dartdoc's decision, or structure your package ",
        "so the reexport is less ambiguous.  The symbol will still be referenced in ",
        "all candidates -- this only controls the location where it will be written ",
        "and which library will be displayed in navigation for the relevant pages.",
        "The flag --ambiguous-reexport-scorer-min-confidence allows you to set the",
        "threshold at which this warning will appear."
      ]),
  PackageWarning.ignoredCanonicalFor: const PackageWarningHelpText(
      PackageWarning.ignoredCanonicalFor,
      "ignored-canonical-for",
      "A @canonicalFor tag refers to a library which this symbol can not be canonical for"),
  PackageWarning.noCanonicalFound: const PackageWarningHelpText(
      PackageWarning.noCanonicalFound,
      "no-canonical-found",
      "A symbol is part of the public interface for this package, but no library documented with this package documents it so dartdoc can not link to it"),
  PackageWarning.noLibraryLevelDocs: const PackageWarningHelpText(
      PackageWarning.noLibraryLevelDocs,
      "no-library-level-docs",
      "There are no library level docs for this library"),
  PackageWarning.categoryOrderGivesMissingPackageName: const PackageWarningHelpText(
      PackageWarning.categoryOrderGivesMissingPackageName,
      "category-order-gives-missing-package-name",
      "The category-order flag on the command line was given the name of a nonexistent package"),
  PackageWarning.unresolvedDocReference: const PackageWarningHelpText(
      PackageWarning.unresolvedDocReference,
      "unresolved-doc-reference",
      "A comment reference could not be found in parameters, enclosing class, enclosing library, or at the top level of any documented library with the package"),
  PackageWarning.brokenLink: const PackageWarningHelpText(
      PackageWarning.brokenLink,
      "brokenLink",
      "Dartdoc generated a link to a non-existent file"),
  PackageWarning.unknownMacro: const PackageWarningHelpText(
      PackageWarning.unknownMacro,
      "unknownMacro",
      "A comment reference contains an unknown macro"),
  PackageWarning.orphanedFile: const PackageWarningHelpText(
      PackageWarning.orphanedFile,
      "orphanedFile",
      "Dartdoc generated files that are unreachable from the index"),
  PackageWarning.unknownFile: const PackageWarningHelpText(
      PackageWarning.unknownFile,
      "unknownFile",
      "A leftover file exists in the tree that dartdoc did not write in this pass"),
  PackageWarning.missingFromSearchIndex: const PackageWarningHelpText(
      PackageWarning.missingFromSearchIndex,
      "missingFromSearchIndex",
      "A file generated by dartdoc is not present in the generated index.json"),
  PackageWarning.typeAsHtml: const PackageWarningHelpText(
      PackageWarning.typeAsHtml,
      "typeAsHtml",
      "Use of <> in a comment for type parameters is being treated as HTML by markdown"),
};

/// Something that package warnings can be called on.
abstract class Warnable implements Canonicalization {
  void warn(PackageWarning warning,
      {String message, Iterable<Locatable> referredFrom});
  Warnable get enclosingElement;
}

/// Something that can be located for warning purposes.
abstract class Locatable {
  String get fullyQualifiedName;
  String get href;
  List<Locatable> get documentationFrom;
  Element get element;
  String get elementLocation;
  Tuple2<int, int> get lineAndColumn;

  Set<String> get locationPieces {
    return new Set.from(element.location
        .toString()
        .split(locationSplitter)
        .where((s) => s.isNotEmpty));
  }
}

// The kinds of warnings that can be displayed when documenting a package.
enum PackageWarning {
  ambiguousDocReference,
  ambiguousReexport,
  ignoredCanonicalFor,
  noCanonicalFound,
  noLibraryLevelDocs,
  categoryOrderGivesMissingPackageName,
  unresolvedDocReference,
  unknownMacro,
  brokenLink,
  orphanedFile,
  unknownFile,
  missingFromSearchIndex,
  typeAsHtml,
}

/// Warnings it is OK to skip if we can determine the warnable isn't documented.
/// In particular, this set should not include warnings around public/private
/// or canonicalization problems, because those can break the isDocumented()
/// check.
final Set<PackageWarning> skipWarningIfNotDocumentedFor = new Set()
  ..addAll([PackageWarning.unresolvedDocReference, PackageWarning.typeAsHtml]);

class PackageWarningOptions {
  // PackageWarnings must be in one of _ignoreWarnings or union(_asWarnings, _asErrors)
  final Set<PackageWarning> ignoreWarnings = new Set<PackageWarning>();
  // PackageWarnings can be in both asWarnings and asErrors, latter takes precedence
  final Set<PackageWarning> asWarnings = new Set<PackageWarning>();
  final Set<PackageWarning> asErrors = new Set<PackageWarning>();

  bool autoFlush = true;

  PackageWarningOptions() {
    asWarnings.addAll(PackageWarning.values);
    ignore(PackageWarning.typeAsHtml);
  }

  void _assertInvariantsOk() {
    assert(asWarnings
        .union(asErrors)
        .union(ignoreWarnings)
        .containsAll(PackageWarning.values.toSet()));
    assert(asWarnings.union(asErrors).intersection(ignoreWarnings).isEmpty);
  }

  void ignore(PackageWarning kind) {
    _assertInvariantsOk();
    asWarnings.remove(kind);
    asErrors.remove(kind);
    ignoreWarnings.add(kind);
    _assertInvariantsOk();
  }

  void warn(PackageWarning kind) {
    _assertInvariantsOk();
    ignoreWarnings.remove(kind);
    asWarnings.add(kind);
    asErrors.remove(kind);
    _assertInvariantsOk();
  }

  void error(PackageWarning kind) {
    _assertInvariantsOk();
    ignoreWarnings.remove(kind);
    asWarnings.add(kind);
    asErrors.add(kind);
    _assertInvariantsOk();
  }
}

class PackageWarningCounter {
  final _countedWarnings =
      new Map<Element, Set<Tuple2<PackageWarning, String>>>();
  final _warningCounts = new Map<PackageWarning, int>();
  final PackageWarningOptions options;

  final _items = <Jsonable>[];

  PackageWarningCounter(this.options);

  /// Flush to stderr, but only if [options.autoFlush] is true.
  ///
  /// We keep a buffer because under certain conditions (--auto-include-dependencies)
  /// warnings here might be duplicated across multiple Package constructions.
  void maybeFlush() {
    if (options.autoFlush) {
      for (var item in _items) {
        logWarning(item);
      }
      _items.clear();
    }
  }

  /// Actually write out the warning.  Assumes it is already counted with add.
  void _writeWarning(PackageWarning kind, String name, String fullMessage) {
    if (options.ignoreWarnings.contains(kind)) {
      return;
    }
    String type;
    if (options.asErrors.contains(kind)) {
      type = "error";
    } else if (options.asWarnings.contains(kind)) {
      type = "warning";
    }
    if (type != null) {
      var entry = "  $type: $fullMessage";
      if (_warningCounts[kind] == 1 &&
          config.verboseWarnings &&
          packageWarningText[kind].longHelp.isNotEmpty) {
        // First time we've seen this warning.  Give a little extra info.
        final String separator = '\n            ';
        final String nameSub = r'@@name@@';
        String verboseOut =
            '$separator${packageWarningText[kind].longHelp.join(separator)}'
                .replaceAll(nameSub, name);
        entry = '$entry$verboseOut';
      }
      assert(entry == entry.trimRight());
      _items.add(new _JsonWarning(type, kind, fullMessage, entry));
    }
    maybeFlush();
  }

  /// Returns true if we've already warned for this.
  bool hasWarning(Warnable element, PackageWarning kind, String message) {
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    if (_countedWarnings.containsKey(element?.element)) {
      return _countedWarnings[element?.element].contains(warningData);
    }
    return false;
  }

  /// Adds the warning to the counter, and writes out the fullMessage string
  /// if configured to do so.
  void addWarning(Warnable element, PackageWarning kind, String message,
      String fullMessage) {
    assert(!hasWarning(element, kind, message));
    Tuple2<PackageWarning, String> warningData = new Tuple2(kind, message);
    _warningCounts.putIfAbsent(kind, () => 0);
    _warningCounts[kind] += 1;
    _countedWarnings.putIfAbsent(element?.element, () => new Set());
    _countedWarnings[element?.element].add(warningData);
    _writeWarning(kind, element?.fullyQualifiedName, fullMessage);
  }

  int get errorCount {
    return _warningCounts.keys
        .map((w) => options.asErrors.contains(w) ? _warningCounts[w] : 0)
        .fold(0, (a, b) => a + b);
  }

  int get warningCount {
    return _warningCounts.keys
        .map((w) =>
            options.asWarnings.contains(w) && !options.asErrors.contains(w)
                ? _warningCounts[w]
                : 0)
        .fold(0, (a, b) => a + b);
  }

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
        'kind': packageWarningText[kind].warningName,
        'message': message,
        'text': text
      };
}
