// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';

/// Canonicalization support in Dartdoc.
///
/// This provides heuristic scoring to determine which library a human likely
/// considers this element to be primarily 'from', and therefore, canonical.
/// Still warn if the heuristic isn't very confident.
final class Canonicalization {
  final ModelElement _element;

  Canonicalization(this._element);

  /// Calculates a candidate for the canonical library of [_element], among [libraries].
  Library calculateCanonicalCandidate(Iterable<Library> libraries) {
    var locationPieces = _element.element.location
        .toString()
        .split(_locationSplitter)
        .where((s) => s.isNotEmpty)
        .toSet();
    var scoredCandidates = libraries
        .map((library) => _scoreElementWithLibrary(
            library, _element.fullyQualifiedName, locationPieces))
        .toList(growable: false)
      ..sort();

    final librariesByScore = scoredCandidates.map((s) => s.library).toList();
    var secondHighestScore =
        scoredCandidates[scoredCandidates.length - 2].score;
    var highestScore = scoredCandidates.last.score;
    var confidence = highestScore - secondHighestScore;
    final canonicalLibrary = librariesByScore.last;

    if (confidence < _element.config.ambiguousReexportScorerMinConfidence) {
      var libraryNames = librariesByScore.map((l) => l.name);
      var message = '$libraryNames -> ${canonicalLibrary.name} '
          '(confidence ${confidence.toStringAsPrecision(4)})';
      _element.warn(PackageWarning.ambiguousReexport,
          message: message, extendedDebug: scoredCandidates.map((s) => '$s'));
    }

    return canonicalLibrary;
  }

  // TODO(srawlins): This function is minimally tested; it's tricky to unit test
  // because it takes a lot of elements into account, like URIs, differing
  // package names, etc. Anyways, add more tests, in addition to the
  // `StringName` tests in `model_test.dart`.
  static _ScoredCandidate _scoreElementWithLibrary(Library library,
      String elementQualifiedName, Set<String> elementLocationPieces) {
    var scoredCandidate = _ScoredCandidate(library);

    // Large boost for `@canonicalFor`, essentially overriding all other
    // concerns.
    if (library.canonicalFor.contains(elementQualifiedName)) {
      scoredCandidate._alterScore(5.0, _Reason.canonicalFor);
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
      scoredCandidate._alterScore(0.9, _Reason.packageName);
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

/// A pattern that can split [Locatable.location] strings.
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
  int compareTo(_ScoredCandidate other) => score.compareTo(other.score);

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
  deprecated('is deprecated'),
  packageName('embeds package name'),
  longName('name is long'),
  sharedNamePart('element location shares parts with name'),
  locationPartStart('element location parts start with parts of name');

  final String text;

  const _Reason(this.text);
}
