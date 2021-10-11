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
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/model/nameable.dart';
import 'package:meta/meta.dart';

class ReferenceChildrenLookup {
  final String lookup;
  final List<String> remaining;

  ReferenceChildrenLookup(this.lookup, this.remaining);

  @override
  String toString() =>
      '$lookup ($lookup${remaining.isNotEmpty ? "." + remaining.join(".") : ''})';
}

extension on Scope {
  /// Prefer the getter for a bundled lookup if both exist.
  Element? lookupPreferGetter(String id) {
    var result = lookup(id);
    return result.getter ?? result.setter;
  }
}

/// A set of utility methods for helping build
/// [CommentReferable.referenceChildren] out of collections of other
/// [CommmentReferable]s.
extension CommentReferableEntryGenerators on Iterable<CommentReferable> {
  /// Creates ordinary references except if there is a conflict with
  /// [referable], it will generate a [MapEntry] using [referable]'s
  /// [CommentReferable.referenceName] as a prefix for the conflicting item.
  Iterable<MapEntry<String, CommentReferable>> explicitOnCollisionWith(
          CommentReferable referable) =>
      map((r) {
        if (r.referenceName == referable.referenceName) {
          return MapEntry('${referable.referenceName}.${r.referenceName}', r);
        }
        return MapEntry(r.referenceName, r);
      });

  /// Just generate entries from this iterable.
  Iterable<MapEntry<String, CommentReferable>> generateEntries() =>
      map((r) => MapEntry(r.referenceName, r));

  /// Return all values not of this type.
  Iterable<CommentReferable> whereNotType<T>() sync* {
    for (var r in this) {
      if (r is! T) yield r;
    }
  }
}

/// A set of utility methods to add entries to
/// [CommentReferable.referenceChildren].
extension CommentReferableEntryBuilder on Map<String, CommentReferable> {
  /// Like [Map.putIfAbsent] except works on an iterable of entries.
  void addEntriesIfAbsent(
      Iterable<MapEntry<String, CommentReferable>> entries) {
    for (var entry in entries) {
      if (!containsKey(entry.key)) this[entry.key] = entry.value;
    }
  }
}

/// Support comment reference lookups on a Nameable object.
mixin CommentReferable implements Nameable, ModelBuilderInterface {
  /// For any [CommentReferable] where an analyzer [Scope] exists (or can
  /// be constructed), implement this.  This will take priority over
  /// lookups via [referenceChildren].  Can be cached.
  Scope? get scope => null;

  String? get href => null;

  static bool _alwaysTrue(CommentReferable? _) => true;

  /// Look up a comment reference by its component parts.  If [tryParents] is
  /// true, try looking up the same reference in any parents of [this].
  /// Will skip over results that do not pass a given [filter] and keep
  /// searching.  Will skip over entire subtrees whose parent node does
  /// not pass [allowTree].
  @nonVirtual
  CommentReferable? referenceBy(List<String> reference,
      {bool tryParents = true,
      bool Function(CommentReferable?) filter = _alwaysTrue,
      bool Function(CommentReferable?) allowTree = _alwaysTrue,
      Iterable<CommentReferable>? parentOverrides}) {
    parentOverrides ??= referenceParents;
    if (reference.isEmpty) {
      if (tryParents == false) return this;
      return null;
    }
    CommentReferable? result;

    /// Search for the reference.
    for (var referenceLookup in childLookups(reference)) {
      if (scope != null) {
        result = lookupViaScope(referenceLookup,
            filter: filter, allowTree: allowTree);
        if (result != null) break;
      }
      if (referenceChildren.containsKey(referenceLookup.lookup)) {
        result = recurseChildrenAndFilter(
            referenceLookup, referenceChildren[referenceLookup.lookup]!,
            allowTree: allowTree, filter: filter);
        if (result != null) break;
      }
    }
    // If we can't find it in children, try searching parents if allowed.
    if (result == null && tryParents) {
      for (var parent in parentOverrides) {
        result = parent.referenceBy(reference,
            tryParents: true,
            parentOverrides: referenceGrandparentOverrides,
            allowTree: allowTree,
            filter: filter);
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
  CommentReferable? lookupViaScope(ReferenceChildrenLookup referenceLookup,
      {required bool Function(CommentReferable?) allowTree,
      required bool Function(CommentReferable?) filter}) {
    var resultElement = scope!.lookupPreferGetter(referenceLookup.lookup);
    if (resultElement == null) return null;
    var result = modelBuilder.fromElement(resultElement);
    if (result is Accessor) {
      result = result.enclosingCombo;
    }
    if (result.enclosingElement is Container) {
      assert(false,
          '[Container] member detected, support not implemented for analyzer scope inside containers');
      return null;
    }
    if (!allowTree(result)) return null;
    return recurseChildrenAndFilter(referenceLookup, result,
        allowTree: allowTree, filter: filter);
  }

  /// Given a [result] found in an implementation of [lookupViaScope] or
  /// [_lookupViaReferenceChildren], recurse through children, skipping over
  /// results that do not match the filter.
  CommentReferable? recurseChildrenAndFilter(
      ReferenceChildrenLookup referenceLookup, CommentReferable result,
      {required bool Function(CommentReferable?) allowTree,
      required bool Function(CommentReferable?) filter}) {
    CommentReferable? returnValue = result;
    if (referenceLookup.remaining.isNotEmpty) {
      if (allowTree(result)) {
        returnValue = result.referenceBy(referenceLookup.remaining,
            tryParents: false, allowTree: allowTree, filter: filter);
      } else {
        returnValue = null;
      }
    } else if (!filter(result)) {
      returnValue = result.referenceBy([referenceLookup.lookup],
          tryParents: false, allowTree: allowTree, filter: filter);
    }
    if (!filter(returnValue)) {
      returnValue = null;
    }
    return returnValue;
  }

  /// A list of lookups that should be attempted on children based on
  /// [reference].  This allows us to deal with libraries that may have
  /// separators in them. [referenceBy] stops at the first one found.
  // TODO(jcollins-g): Convert to generator after dart-lang/sdk#46419
  Iterable<ReferenceChildrenLookup> childLookups(List<String> reference) {
    var retval = <ReferenceChildrenLookup>[];
    for (var index = 1; index <= reference.length; index++) {
      retval.add(ReferenceChildrenLookup(
          reference.sublist(0, index).join('.'), reference.sublist(index)));
    }
    return retval;
  }

  /// Map of [referenceName] to the elements that are a member of [this], but
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

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Element? get element;
}
