// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// Classes extending this class have canonicalization support in Dartdoc.
abstract mixin class Canonicalization implements Locatable, Documentable {
  bool get isCanonical;

  Library? get canonicalLibrary;

  /// Pieces of the location, split to remove 'package:' and slashes.
  Set<String> get locationPieces;

  List<ScoredCandidate> scoreCanonicalCandidates(Iterable<Library> libraries) {
    return libraries.map(_scoreElementWithLibrary).toList(growable: false)
      ..sort();
  }

  ScoredCandidate _scoreElementWithLibrary(Library lib) {
    var scoredCandidate = ScoredCandidate(lib);
    Iterable<String> resplit(Set<String> items) sync* {
      for (var item in items) {
        for (var subItem in item.split('_')) {
          yield subItem;
        }
      }
    }

    // Large boost for @canonicalFor, essentially overriding all other concerns.
    if (lib.canonicalFor.contains(fullyQualifiedName)) {
      scoredCandidate._alterScore(5.0, 'marked @canonicalFor');
    }
    // Penalty for deprecated libraries.
    if (lib.isDeprecated) scoredCandidate._alterScore(-1.0, 'is deprecated');
    // Give a big boost if the library has the package name embedded in it.
    if (lib.package.namePieces.intersection(lib.namePieces).isEmpty) {
      scoredCandidate._alterScore(1.0, 'embeds package name');
    }
    // Give a tiny boost for libraries with long names, assuming they're
    // more specific (and therefore more likely to be the owner of this symbol).
    scoredCandidate._alterScore(.01 * lib.namePieces.length, 'name is long');
    // If we don't know the location of this element, return our best guess.
    // TODO(jcollins-g): is that even possible?
    assert(locationPieces.isNotEmpty);
    if (locationPieces.isEmpty) return scoredCandidate;
    // The more pieces we have of the location in our library name, the more we should boost our score.
    scoredCandidate._alterScore(
        lib.namePieces.intersection(locationPieces).length.toDouble() /
            locationPieces.length.toDouble(),
        'element location shares parts with name');
    // If pieces of location at least start with elements of our library name, boost the score a little bit.
    var scoreBoost = 0.0;
    for (var piece in resplit(locationPieces)) {
      for (var namePiece in lib.namePieces) {
        if (piece.startsWith(namePiece)) {
          scoreBoost += 0.001;
        }
      }
    }
    scoredCandidate._alterScore(
        scoreBoost, 'element location parts start with parts of name');
    return scoredCandidate;
  }
}

/// This class represents the score for a particular element; how likely
/// it is that this is the canonical element.
class ScoredCandidate implements Comparable<ScoredCandidate> {
  final List<String> _reasons = [];

  final Library library;

  /// The score accumulated so far.  Higher means it is more likely that this
  /// is the intended canonical Library.
  double score = 0.0;

  ScoredCandidate(this.library);

  void _alterScore(double scoreDelta, String reason) {
    score += scoreDelta;
    if (scoreDelta != 0) {
      _reasons.add(
          "$reason (${scoreDelta >= 0 ? '+' : ''}${scoreDelta.toStringAsPrecision(4)})");
    }
  }

  @override
  int compareTo(ScoredCandidate other) {
    //assert(element == other.element);
    return score.compareTo(other.score);
  }

  @override
  String toString() =>
      "${library.name}: ${score.toStringAsPrecision(4)} - ${_reasons.join(', ')}";
}
