// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';

const int _separatorChar = 0x3B;

/// Searches [PackageGraph.libraryExports] for a public, documented library
/// which exports this [ModelElement], ideally in its library's package.
Library? canonicalLibraryCandidate(ModelElement modelElement) {
  var libraryElement = modelElement.element.library;
  if (libraryElement == null) return null;
  var libraryExports = modelElement.packageGraph.libraryExports[libraryElement];
  var candidateList = {
    ...?libraryExports,
    if (modelElement.library case var library?) library,
  };
  if (candidateList.isEmpty) {
    return null;
  }

  // Since we're looking for a library, go up in the tree until we find it.
  var topLevelElement = modelElement.element;
  while (topLevelElement.enclosingElement is! LibraryElement &&
      topLevelElement.enclosingElement != null) {
    topLevelElement = topLevelElement.enclosingElement!;
  }
  var topLevelElementName = topLevelElement.name;
  if (topLevelElementName == null) {
    // Any member of an unnamed extension is not public, and has no
    // canonical library.
    return null;
  }

  final candidateLibraries = candidateList.where((l) {
    if (!l.isPublic) return false;
    if (l.package.documentedWhere == DocumentLocation.missing) return false;
    if (modelElement is Library) return true;
    if (l.name == modelElement.library?.name) return true;
    var lookup = l.element.exportNamespace.definedNames2[topLevelElementName];
    var lookupElement =
        lookup is PropertyAccessorElement ? lookup.variable : lookup;
    var targetElement = topLevelElement is PropertyAccessorElement
        ? topLevelElement.variable
        : topLevelElement;
    return targetElement == lookupElement;
  }).toList(growable: true);

  if (candidateLibraries.isEmpty) {
    return null;
  }
  if (candidateLibraries.length == 1) {
    return candidateLibraries.single;
  }

  var topLevelModelElement =
      ModelElement.forElement(topLevelElement, modelElement.packageGraph);

  return _Canonicalization(topLevelModelElement)
      .canonicalLibraryCandidate(candidateLibraries);
}

/// Canonicalization support in Dartdoc.
///
/// This provides heuristic scoring to determine which library a human likely
/// considers this element to be primarily 'from', and therefore, canonical.
/// Still warn if the heuristic isn't very confident.
final class _Canonicalization {
  final ModelElement _modelElement;

  _Canonicalization(this._modelElement);

  /// Append an encoded form of the given [component] to the given [buffer].
  void _encode(StringBuffer buffer, String component) {
    var length = component.length;
    for (var i = 0; i < length; i++) {
      var currentChar = component.codeUnitAt(i);
      if (currentChar == _separatorChar) {
        buffer.writeCharCode(_separatorChar);
      }
      buffer.writeCharCode(currentChar);
    }
  }

  String _getElementLocation(Element element) {
    var components = <String>[];
    Element? ancestor = element;
    while (ancestor != null) {
      if (ancestor is LibraryElement) {
        components.insert(0, ancestor.uri.toString());
      } else {
        components.insert(0, ancestor.name!);
      }
      ancestor = ancestor.enclosingElement;
    }
    var buffer = StringBuffer();
    var length = components.length;
    for (var i = 0; i < length; i++) {
      if (i > 0) {
        buffer.writeCharCode(_separatorChar);
      }
      _encode(buffer, components[i]);
    }
    return buffer.toString();
  }

  /// Calculates a candidate for the canonical library of [_modelElement], among [libraries].
  Library canonicalLibraryCandidate(Iterable<Library> libraries) {
    var locationPieces = _getElementLocation(_modelElement.element)
        .split(_locationSplitter)
        .where((s) => s.isNotEmpty)
        .toSet();
    var elementQualifiedName = _modelElement.isFromInternalLibrary
        ? _modelElement.originalFullyQualifiedName
        : _modelElement.fullyQualifiedName;
    var scoredCandidates = libraries
        .map((library) => _scoreElementWithLibrary(
            library, elementQualifiedName, locationPieces,
            elementQualifiedNameInLibrary:
                '${library.name}.${_modelElement.qualifiedName}',
            preferredPackage: _modelElement.library?.package,
            preferredLibraryName: _modelElement.element.library?.name,
            preferredLibrary: _modelElement.element.library))
        .toList(growable: false)
      ..sort();

    final librariesByScore = scoredCandidates.map((s) => s.library).toList();
    var secondHighestScore =
        scoredCandidates[scoredCandidates.length - 2].score;
    var highestScore = scoredCandidates.last.score;
    var confidence = highestScore - secondHighestScore;
    final canonicalLibrary = librariesByScore.last;

    if (confidence <
        _modelElement.config.ambiguousReexportScorerMinConfidence) {
      var libraryNames = librariesByScore.map((l) => l.name);
      var message = '$libraryNames -> ${canonicalLibrary.name} '
          '(confidence ${confidence.toStringAsPrecision(4)})';
      _modelElement.warn(PackageWarning.ambiguousReexport,
          message: message, extendedDebug: scoredCandidates.map((s) => '$s'));
    }

    return canonicalLibrary;
  }

  // TODO(srawlins): This function is minimally tested; it's tricky to unit test
  // because it takes a lot of elements into account, like URIs, differing
  // package names, etc. Anyways, add more tests, in addition to the
  // `StringName` tests in `model_test.dart`.
  static _ScoredCandidate _scoreElementWithLibrary(Library library,
      String elementQualifiedName, Set<String> elementLocationPieces,
      {required String elementQualifiedNameInLibrary,
      Package? preferredPackage,
      String? preferredLibraryName,
      LibraryElement? preferredLibrary}) {
    var scoredCandidate = _ScoredCandidate(library);

    // Large boost for `@canonicalFor`, essentially overriding all other
    // concerns.
    if (library.canonicalFor.contains(elementQualifiedNameInLibrary) ||
        library.canonicalFor.contains(elementQualifiedName)) {
      scoredCandidate._alterScore(10.0, _Reason.canonicalFor);
    }

    if (preferredPackage != null && library.package == preferredPackage) {
      scoredCandidate._alterScore(1.0, _Reason.samePackage);
    }

    if (preferredLibrary != null && library.element == preferredLibrary) {
      scoredCandidate._alterScore(4.0, _Reason.sameLibrary);
    }

    if (preferredLibraryName != null && library.name == preferredLibraryName) {
      scoredCandidate._alterScore(0.1, _Reason.exactLibraryName);
    }

    if (library.element.firstFragment.source.uri.isScheme('dart')) {
      scoredCandidate._alterScore(0.2, _Reason.isDartScheme);
    }

    // Penalty for deprecated libraries.
    if (library.isDeprecated) {
      scoredCandidate._alterScore(-1.0, _Reason.deprecated);
    }

    var libraryNamePieces = {
      ...library.name.split('.').where((s) => s.isNotEmpty)
    };

    // Give a big boost if the library has the package name embedded in it.
    if (libraryNamePieces.contains(library.package.name)) {
      scoredCandidate._alterScore(1.0, _Reason.packageName);
    }

    // Same idea as the above, for the Dart SDK.
    if (library.name == 'dart:core') {
      scoredCandidate._alterScore(1.1, _Reason.packageName);
    }

    // Give a tiny boost for libraries with long names, assuming they're
    // more specific (and therefore more likely to be the owner of this symbol).
    scoredCandidate._alterScore(
        .01 * libraryNamePieces.length, _Reason.longName);

    // If we don't know the location of this element (which shouldn't be
    // possible), return our best guess.
    assert(elementLocationPieces.isNotEmpty);
    if (elementLocationPieces.isEmpty) return scoredCandidate;

    // The more pieces we have of the location in our library name, the more we
    // should boost our score.
    scoredCandidate._alterScore(
      libraryNamePieces.intersection(elementLocationPieces).length.toDouble() /
          elementLocationPieces.length.toDouble(),
      _Reason.sharedNamePart,
    );

    // If pieces of location at least start with elements of our library name,
    // boost the score a little bit.
    var scoreBoost = 0.0;
    for (var piece in elementLocationPieces.expand((item) => item.split('_'))) {
      for (var namePiece in libraryNamePieces) {
        if (piece.startsWith(namePiece)) {
          scoreBoost += 0.001;
        }
      }
    }
    scoredCandidate._alterScore(scoreBoost, _Reason.locationPartStart);

    return scoredCandidate;
  }
}

/// A pattern that can split [Warnable.location] strings.
final _locationSplitter = RegExp(r'(package:|[\\/;.])');

/// This class represents the score for a particular element; how likely
/// it is that this is the canonical element.
class _ScoredCandidate implements Comparable<_ScoredCandidate> {
  final List<(_Reason, double)> _reasons = [];

  final Library library;

  /// The score accumulated so far.  Higher means it is more likely that this
  /// is the intended canonical Library.
  double score = 0.0;

  _ScoredCandidate(this.library);

  void _alterScore(double scoreDelta, _Reason reason) {
    score += scoreDelta;
    if (scoreDelta != 0) {
      _reasons.add((reason, scoreDelta));
    }
  }

  @override
  int compareTo(_ScoredCandidate other) {
    var result = score.compareTo(other.score);
    if (result != 0) return result;
    return byName(library, other.library);
  }

  @override
  String toString() {
    var reasonText = _reasons.map((r) {
      var (reason, scoreDelta) = r;
      var scoreDeltaPrefix = scoreDelta >= 0 ? '+' : '';
      return '$reason ($scoreDeltaPrefix${scoreDelta.toStringAsPrecision(4)})';
    });
    return '${library.name}: ${score.toStringAsPrecision(4)} - $reasonText';
  }
}

/// A reason that a candidate's score is changed.
enum _Reason {
  canonicalFor('marked @canonicalFor'),
  samePackage('is in the same package'),
  sameLibrary('is the same library'),
  isDartScheme('uses dart: scheme'),
  exactLibraryName('library name matches defining library name'),
  deprecated('is deprecated'),
  packageName('embeds package name'),
  longName('name is long'),
  sharedNamePart('element location shares parts with name'),
  locationPartStart('element location parts start with parts of name');

  final String text;

  const _Reason(this.text);
}
