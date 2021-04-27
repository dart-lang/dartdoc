// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// Code for managing comment reference lookups in dartdoc.
///
library dartdoc.src.model.comment_reference;

import 'dart:core';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:meta/meta.dart';

class ReferenceChildrenLookup {
  final String lookup;
  final List<String> remaining;
  ReferenceChildrenLookup(this.lookup, this.remaining);
}

/// Support comment reference lookups on a Nameable object.
mixin CommentReferable implements Nameable {
  /// Look up a comment reference by its component parts.  If [tryParents] is
  /// true, try looking up the same reference in any parents of [this].
  @nonVirtual
  CommentReferable referenceBy(List<String> reference,
      {bool tryParents = true}) {
    if (reference.isEmpty) {
      if (tryParents == false) return this;
      return null;
    }
    CommentReferable result;

    /// Search for the reference
    for (var referenceLookup in childLookups(reference)) {
      if (referenceChildren.containsKey(referenceLookup.lookup)) {
        result = referenceChildren[referenceLookup.lookup];
        if (referenceLookup.remaining.isNotEmpty) {
          result =
              result?.referenceBy(referenceLookup.remaining, tryParents: false);
        }
      }
      if (result != null) break;
    }
    // If we can't find it in children, try searching parents if allowed.
    if (result == null && tryParents) {
      for (var parent in referenceParents) {
        result = parent.referenceBy(reference);
        if (result != null) break;
      }
    }
    return result;
  }

  /// A list of lookups that should be attempted on children based on
  /// [reference].  This allows us to deal with libraries that may have
  /// separators in them. [referenceBy] stops at the first one found.
  List<ReferenceChildrenLookup> childLookups(List<String> reference) => [
        ReferenceChildrenLookup(
            reference.first, reference.length > 1 ? reference.sublist(1) : [])
      ];

  /// Map of name to the elements that are a member of [this], but
  /// not this model element itself.
  /// Can be cached.
  Map<String, CommentReferable> get referenceChildren;

  /// Iterable of immediate "parents" to try resolving component parts.
  /// [referenceBy] stops at the first parent where a part is found.
  /// Can be cached.
  // TODO(jcollins-g): Rationalize the different "enclosing" types so that
  // this doesn't duplicate `[enclosingElement]` in many cases.
  // TODO(jcollins-g): Implement comment reference resolution via categories,
  // making the iterable make sense here.
  Iterable<CommentReferable> get referenceParents;

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Library get library => null;

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Element get element;
}
