// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// Classes extending this class have canonicalization support in Dartdoc.
abstract mixin class Canonicalization implements Locatable, Documentable {
  bool get isCanonical;

  /// Pieces of the location, split to remove 'package:' and slashes.
  Set<String> get locationPieces;

  List<ScoredCandidate> scoreCanonicalCandidates(Iterable<Library> libraries) {
    return libraries.map(_scoreElementWithLibrary).toList(growable: false)
      ..sort();
  }

  ScoredCandidate _scoreElementWithLibrary(Library library) {
    var scoredCandidate = ScoredCandidate(library);

    // Large boost for `@canonicalFor`, essentially overriding all other
    // concerns.
    if (library.canonicalFor.contains(fullyQualifiedName)) {
      scoredCandidate._alterScore(5.0, _Reason.canonicalFor);
    }
    // Penalty for deprecated libraries.
    if (library.isDeprecated) {
      scoredCandidate._alterScore(-1.0, _Reason.deprecated);
    }
    // Give a big boost if the library has the package name embedded in it.
    if (library.package.namePieces.intersection(library.namePieces).isEmpty) {
      scoredCandidate._alterScore(1.0, _Reason.packageName);
    }
    // Give a tiny boost for libraries with long names, assuming they're
    // more specific (and therefore more likely to be the owner of this symbol).
    scoredCandidate._alterScore(
        .01 * library.namePieces.length, _Reason.longName);
    // If we don't know the location of this element (which shouldn't be
    // possible), return our best guess.
    assert(locationPieces.isNotEmpty);
    if (locationPieces.isEmpty) return scoredCandidate;
    // The more pieces we have of the location in our library name, the more we
    // should boost our score.
    scoredCandidate._alterScore(
      library.namePieces.intersection(locationPieces).length.toDouble() /
          locationPieces.length.toDouble(),
      _Reason.sharedNamePart,
    );
    // If pieces of location at least start with elements of our library name,
    // boost the score a little bit.
    var scoreBoost = 0.0;
    for (var piece in locationPieces.expand((item) => item.split('_'))) {
      for (var namePiece in library.namePieces) {
        if (piece.startsWith(namePiece)) {
          scoreBoost += 0.001;
        }
      }
    }
    scoredCandidate._alterScore(scoreBoost, _Reason.locationPartStart);
    return scoredCandidate;
  }
}

/// This class represents the score for a particular element; how likely
/// it is that this is the canonical element.
class ScoredCandidate implements Comparable<ScoredCandidate> {
  final List<(_Reason, double)> _reasons = [];

  final Library library;

  /// The score accumulated so far.  Higher means it is more likely that this
  /// is the intended canonical Library.
  double score = 0.0;

  ScoredCandidate(this.library);

  void _alterScore(double scoreDelta, _Reason reason) {
    score += scoreDelta;
    if (scoreDelta != 0) {
      _reasons.add((reason, scoreDelta));
    }
  }

  @override
  int compareTo(ScoredCandidate other) => score.compareTo(other.score);

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
