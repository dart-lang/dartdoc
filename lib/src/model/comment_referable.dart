// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Code for managing comment reference lookups in dartdoc.
library;

import 'dart:core';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/nameable.dart';
import 'package:dartdoc/src/model/prefix.dart';
import 'package:meta/meta.dart';

class _ReferenceChildrenLookup {
  final String lookup;
  final List<String> remaining;

  _ReferenceChildrenLookup(this.lookup, this.remaining);

  @override
  String toString() =>
      '$lookup ($lookup${remaining.isNotEmpty ? ".${remaining.join(".")}" : ''})';
}

/// Support comment reference lookups on a Nameable object.
mixin CommentReferable implements Nameable {
  /// For any [CommentReferable] where an analyzer [Scope] exists (or can
  /// be constructed), implement this.  This will take priority over
  /// lookups via [referenceChildren].  Can be cached.
  Scope? get scope => null;

  String? get href => null;

  /// Looks up a comment reference by its component parts.
  ///
  /// If [tryParents] is true, try looking up the same reference in any parents
  /// of `this`. Will skip over results that do not pass a given [filter] and
  /// keep searching.
  @nonVirtual
  CommentReferable? referenceBy(
    List<String> reference, {
    required bool Function(CommentReferable?) filter,
    bool tryParents = true,
    Iterable<CommentReferable>? parentOverrides,
  }) {
    parentOverrides ??= referenceParents;
    if (reference.isEmpty) {
      return tryParents ? null : this;
    }
    for (var referenceLookup in _childLookups(reference)) {
      // First attempt: Ask analyzer's `Scope.lookup` API.
      var result = _lookupViaScope(referenceLookup, filter: filter);
      if (result != null) {
        if (result is Prefix &&
            result.name == '_' &&
            library!.element.featureSet.isEnabled(Feature.wildcard_variables)) {
          // A wildcard import prefix is non-binding.
          continue;
        }
        return result;
      }

      // Second attempt: Look through `referenceChildren`.
      final referenceChildren = this.referenceChildren;
      final childrenResult = referenceChildren[referenceLookup.lookup];
      if (childrenResult != null) {
        var result = _recurseChildrenAndFilter(
          referenceLookup,
          childrenResult,
          filter: filter,
        );
        if (result != null) {
          return result;
        }
      }
    }
    // If we can't find it in children, try searching parents if allowed.
    if (tryParents) {
      for (var parent in parentOverrides) {
        var result = parent.referenceBy(
          reference,
          tryParents: true,
          parentOverrides: referenceGrandparentOverrides,
          filter: filter,
        );
        if (result != null) return result;
      }
    }
    return null;
  }

  /// Looks up references by [scope], skipping over results that do not match
  /// [filter].
  ///
  /// Override if [Scope.lookup] may return elements not corresponding to a
  /// [CommentReferable], but you still want to have an implementation of
  /// [scope].
  CommentReferable? _lookupViaScope(
    _ReferenceChildrenLookup referenceLookup, {
    required bool Function(CommentReferable?) filter,
  }) {
    Element2? resultElement;
    final scope = this.scope;
    if (scope != null) {
      resultElement = scope.lookupPreferGetter(referenceLookup.lookup);
      if (resultElement == null) return null;
    }

    if (resultElement == null) {
      if (this case ModelElement(:var modelNode?)) {
        var references = modelNode.commentData?.references;
        if (references != null) {
          resultElement = references[referenceLookup.lookup]?.element;
        }
      }
    }

    if (resultElement == null) {
      return null;
    }

    ModelElement result;
    if (resultElement is PropertyAccessorElement2) {
      final variable = resultElement.variable3!;
      if (variable.isSynthetic) {
        // First, cache the synthetic variable, so that the
        // PropertyAccessorElement getter and/or setter are set (see
        // `Field.new` regarding `enclosingCombo`).
        packageGraph.getModelForElement(variable);
        // Then, use the result for the PropertyAccessorElement.
        result = packageGraph.getModelForElement(resultElement);
      } else {
        // print('propertyaccessor variable $variable');
        result = packageGraph.getModelForElement(variable);
      }
    } else {
      // print('resultElement  $resultElement');
      result = packageGraph.getModelForElement(resultElement);
    }
    return _recurseChildrenAndFilter(referenceLookup, result, filter: filter);
  }

  /// Given a [result] found in an implementation of [_lookupViaScope] or
  /// [_ReferenceChildrenLookup], recurse through children, skipping over
  /// results that do not match the filter.
  CommentReferable? _recurseChildrenAndFilter(
    _ReferenceChildrenLookup referenceLookup,
    CommentReferable result, {
    required bool Function(CommentReferable?) filter,
  }) {
    CommentReferable? returnValue = result;
    if (referenceLookup.remaining.isNotEmpty) {
      returnValue = result.referenceBy(referenceLookup.remaining,
          tryParents: false, filter: filter);
    } else if (!filter(result)) {
      returnValue = result.referenceBy([referenceLookup.lookup],
          tryParents: false, filter: filter);
    }
    if (!filter(returnValue)) {
      returnValue = null;
    }
    return returnValue;
  }

  /// A list of lookups that should be attempted on children based on
  /// [reference].
  ///
  /// This allows us to deal with libraries that may have separators in them.
  /// [referenceBy] stops at the first one found.
  Iterable<_ReferenceChildrenLookup> _childLookups(List<String> reference) =>
      reference
          .mapIndexed((index, _) => _ReferenceChildrenLookup(
              reference.sublist(0, index + 1).join('.'),
              reference.sublist(index + 1)))
          .toList(growable: false);

  /// Map of [referenceName] to the elements that are a member of `this`, but
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
  Iterable<CommentReferable>? get referenceGrandparentOverrides => null;

  // TODO(jcollins-g): Enforce that reference name is always the same
  // as [ModelElement.name].  Easier/possible after old lookup code is gone.
  String get referenceName => name;

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Library? get library => null;

  /// For testing / comparison only, get the comment referable from where this
  /// `ElementType` was defined.  Override where an [Element2] is available.
  @internal
  CommentReferable get definingCommentReferable => this;
}

extension on Scope {
  /// Prefer the getter for a bundled lookup if both exist.
  Element2? lookupPreferGetter(String id) {
    var result = lookup(id);
    return result.getter2 ?? result.setter2;
  }
}

/// A set of utility methods for helping build
/// [CommentReferable.referenceChildren] out of collections of other
/// [CommentReferable]s.
extension CommentReferableEntryGenerators<T extends CommentReferable>
    on Iterable<T> {
  /// Creates reference entries for this Iterable.
  ///
  /// If there is a conflict with [referable], the included [MapEntry] uses
  /// [referable]'s [CommentReferable.referenceName] as a prefix.
  Map<String, T> explicitOnCollisionWith(CommentReferable referable) => {
        for (var r in this)
          if (r.referenceName == referable.referenceName)
            '${referable.referenceName}.${r.referenceName}': r
          else
            r.referenceName: r,
      };

  /// A mapping from each [CommentReferable]'s name to itself.
  Map<String, T> get asMapByName => {
        for (var r in this) r.referenceName: r,
      };

  /// Returns all values not of this type.
  List<T> whereNotType<U>() => [
        for (var referable in this)
          if (referable is! U) referable,
      ];
}
