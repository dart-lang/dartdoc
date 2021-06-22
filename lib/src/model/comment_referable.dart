// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// Code for managing comment reference lookups in dartdoc.
///
library dartdoc.src.model.comment_reference;

import 'dart:core';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:meta/meta.dart';

class ReferenceChildrenLookup {
  final String lookup;
  final List<String> remaining;

  ReferenceChildrenLookup(this.lookup, this.remaining);

  @override
  String toString() => '$lookup.${remaining.join(".")}';
}

extension on Scope {
  /// Prefer the getter for a bundled lookup if both exist.
  Element lookupPreferGetter(String id) {
    var result = lookup(id);
    return result.getter ?? result.setter;
  }
}


/// Support comment reference lookups on a Nameable object.
mixin CommentReferable implements Nameable {
  PackageGraph packageGraph;

  /// For any [CommentReferable] where an analyzer [Scope] exists (or can
  /// be constructed), implement this.  This will take priority over
  /// lookups via [referenceChildren].  Can be cached.
  Scope get scope => null;

  /// Look up a comment reference by its component parts.  If [tryParents] is
  /// true, try looking up the same reference in any parents of [this].
  /// Will skip over results that do not pass a given [filter] and keep
  /// searching.
  @nonVirtual
  CommentReferable referenceBy(List<String> reference,
      {bool tryParents = true, bool Function(CommentReferable) filter,
       Iterable<CommentReferable> parentOverrides}) {
    filter ??= (r) => true;
    parentOverrides ??= referenceParents;
    if (reference.isEmpty) {
      if (tryParents == false) return this;
      return null;
    }
    CommentReferable result;

    /// Search for the reference.
    for (var referenceLookup in childLookups(reference)) {
      if (scope != null) {
        result = lookupViaScope(referenceLookup, filter);
        if (result != null) break;
      }
      if (referenceChildren.containsKey(referenceLookup.lookup)) {
        result = _lookupViaReferenceChildren(referenceLookup, filter);
        if (result != null) break;
      }
    }
    // If we can't find it in children, try searching parents if allowed.
    if (result == null && tryParents) {
      for (var parent in parentOverrides) {
        result = parent.referenceBy(reference, tryParents: true, parentOverrides: referenceGrandparentOverrides, filter: filter);
        if (result != null) break;
      }
    }
    return result;
  }


  /// Looks up references by [scope], skipping over results that do not match
  /// the given filter.
  ///
  /// Override if [Scope.lookup] may return elements not corresponding to a
  /// [CommentReferable], but you still want to have an implementation of
  /// [scope].
  CommentReferable lookupViaScope(ReferenceChildrenLookup referenceLookup,
      bool Function(CommentReferable) filter) {
    var resultElement = scope.lookupPreferGetter(referenceLookup.lookup);
    if (resultElement == null) return null;
    var result = ModelElement.fromElement(resultElement, packageGraph);
    if (result is Accessor) {
      result = (result as Accessor).enclosingCombo;
    }
    if (result?.enclosingElement is Container) {
      assert(false,
          '[Container] member detected, support not implemented for analyzer scope inside containers');
      return null;
    }
    return recurseChildrenAndFilter(referenceLookup, result, filter);
  }

  CommentReferable _lookupViaReferenceChildren(
          ReferenceChildrenLookup referenceLookup,
          bool Function(CommentReferable) filter) =>
      recurseChildrenAndFilter(
          referenceLookup, referenceChildren[referenceLookup.lookup], filter);

  /// Given a [result] found in an implementation of [lookupViaScope] or
  /// [_lookupViaReferenceChildren], recurse through children, skipping over
  /// results that do not match the filter.
  CommentReferable recurseChildrenAndFilter(
      ReferenceChildrenLookup referenceLookup,
      CommentReferable result,
      bool Function(CommentReferable) filter) {
    assert(result != null);
    if (referenceLookup.remaining.isNotEmpty) {
      result = result.referenceBy(referenceLookup.remaining,
          tryParents: false, filter: filter);
    } else if (!filter(result)) {
      result = result.referenceBy([referenceLookup.lookup],
          tryParents: false, filter: filter);
    }
    if (!filter(result)) {
      result = null;
    }
    return result;
  }

  /// A list of lookups that should be attempted on children based on
  /// [reference].  This allows us to deal with libraries that may have
  /// separators in them. [referenceBy] stops at the first one found.
  Iterable<ReferenceChildrenLookup> childLookups(List<String> reference) sync* {
    for (var index = 1; index <= reference.length; index++) {
      yield ReferenceChildrenLookup(reference.sublist(0, index).join('.'), reference.sublist(index));
    }
  }

  /// Map of name to the elements that are a member of [this], but
  /// not this model element itself.  Can be cached.
  ///
  /// There is no need to duplicate references here that can be found via
  /// [scope].
  Map<String, CommentReferable> get referenceChildren;

  /// Iterable of immediate "parents" to try resolving component parts.
  /// [referenceBy] stops at the first parent where a part is found.
  /// Can be cached.
  // TODO(jcollins-g): Rationalize the different "enclosing" types so that
  // this doesn't duplicate `[enclosingElement]` in many cases.
  // TODO(jcollins-g): Implement comment reference resolution via categories,
  // making the iterable make sense here.
  Iterable<CommentReferable> get referenceParents;

  /// Replace the parents of parents.  [referenceBy] ignores whatever might
  /// otherwise be implied by the [referenceParents] of [referenceParents],
  /// replacing them with this.
  Iterable<CommentReferable> get referenceGrandparentOverrides => null;

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Library get library => null;

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Element get element;
}
