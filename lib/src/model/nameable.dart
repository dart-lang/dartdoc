// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:analyzer/dart/element/type.dart' show DartType;
import 'package:collection/collection.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/constructor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/model/prefix.dart';
import 'package:meta/meta.dart';

/// Something that has a name, and can be referenced in a doc comment.
mixin Nameable {
  String get name;

  /// A "fully" qualified name, used for things like for warnings printed in the
  /// terminal; not for display use in rendered HTML.
  ///
  /// "Fully" means the name is qualified through the library. For example, a
  /// method named 'baz' in a class named 'Bar' in a library named 'foo' has a
  /// fully qualified name of 'foo.Bar.baz'.
  ///
  /// As dartdoc can document multiple packages at once, note that such
  /// qualifying names may not be unique across all documented packages.
  String get fullyQualifiedName => name;

  /// The name to use as text in the rendered documentation.
  String get displayName => name;

  /// The name to use in breadcrumbs in the rendered documentation.
  String get breadcrumbName => name;

  /// The name that should be used in documentation to refer to this object if
  /// not the name that was actually used in the reference.
  ///
  /// This is `null` for most objects in which case the reference's original
  /// text is used, but returns the public name of a private named parameter:
  ///
  ///     class C {
  ///       /// Make with [_x].
  ///       C({this._x});
  ///     }
  ///
  /// Here, the generated doc comment will use "x" as the name for the parameter
  /// reference, not "_x".
  String? get documentedName => null;

  /// Whether this is "package-public."
  ///
  /// A "package-public" element satisfies the following requirements:
  /// * is not documented with the `@nodoc` directive,
  /// * for a library, adheres to the documentation for [Library.isPublic],
  /// * for a library member, is in a _public_ library's exported namespace, and
  ///   is not privately named, nor an unnamed extension,
  /// * for a container (class, enum, extension, extension type, mixin) member,
  ///   is in a _public_ container, and is not privately named.
  bool get isPublic => name.isNotEmpty && !name.startsWith('_');

  @override
  String toString() => name;

  PackageGraph get packageGraph;

  /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.for_], see its documentation.
  ModelElement getModelFor(
    Element element,
    Library? library, {
    Container? enclosingContainer,
  }) =>
      ModelElement.for_(
        element,
        library,
        packageGraph,
        enclosingContainer: enclosingContainer,
      );

  /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.forElement], see its
  /// documentation.
  ModelElement getModelForElement(Element element) =>
      ModelElement.forElement(element, packageGraph);

  /// Returns the [ModelElement] for [element], instantiating it if needed.
  ///
  /// A convenience method for [ModelElement.forPropertyInducingElement], see
  /// its documentation.
  // TODO(srawlins): Most callers seem to determine `getter` and `setter`
  // immediately before calling this method, and I imagine could instead just
  // call `getModelFor`.
  ModelElement getModelForPropertyInducingElement(
    PropertyInducingElement element,
    Library library, {
    required Accessor? getter,
    required Accessor? setter,
    Container? enclosingContainer,
  }) =>
      ModelElement.forPropertyInducingElement(
        element,
        library,
        packageGraph,
        getter: getter,
        setter: setter,
        enclosingContainer: enclosingContainer,
      );

  /// Returns the [ElementType] for [type], instantiating it if needed.
  ElementType getTypeFor(DartType type, Library? library) =>
      ElementType.for_(type, library, packageGraph);

  /// For any [Nameable] where an analyzer [Scope] exists (or can be
  /// constructed), implement this.  This will take priority over lookups via
  /// [referenceChildren].  Can be cached.
  @visibleForOverriding
  Scope? get scope => null;

  String? get href => null;

  /// Looks up a comment reference by its component parts.
  ///
  /// If [tryParents] is true, try looking up the same reference in any parents
  /// of `this`. Will skip over results that do not pass a given [filter] and
  /// keep searching.
  @nonVirtual
  Nameable? referenceBy(
    List<String> reference, {
    required bool Function(Nameable?) filter,
    bool tryParents = true,
    Iterable<Nameable>? parentOverrides,
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
  /// [Nameable], but you still want to have an implementation of
  /// [scope].
  Nameable? _lookupViaScope(
    _ReferenceChildrenLookup referenceLookup, {
    required bool Function(Nameable?) filter,
  }) {
    Element? resultElement;
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
    if (resultElement is PropertyAccessorElement) {
      final variable = resultElement.variable;
      if (variable.isOriginDeclaration) {
        // First, cache the synthetic variable, so that the
        // PropertyAccessorElement getter and/or setter are set (see
        // `Field.new` regarding `enclosingCombo`).
        packageGraph.getModelForElement(variable);
        // Then, use the result for the PropertyAccessorElement.
        result = packageGraph.getModelForElement(resultElement);
      } else {
        result = packageGraph.getModelForElement(variable);
      }
    } else {
      result = packageGraph.getModelForElement(resultElement);
    }
    return _recurseChildrenAndFilter(referenceLookup, result, filter: filter);
  }

  /// Given a [result] found in an implementation of [_lookupViaScope] or
  /// [_ReferenceChildrenLookup], recurse through children, skipping over
  /// results that do not match the filter.
  Nameable? _recurseChildrenAndFilter(
    _ReferenceChildrenLookup referenceLookup,
    Nameable result, {
    required bool Function(Nameable?) filter,
  }) {
    Nameable? returnValue = result;
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
  Map<String, Nameable> get referenceChildren;

  /// Iterable of immediate "parents" to try resolving component parts.
  /// [referenceBy] stops at the first parent where a part is found.
  /// Can be cached.
  // TODO(jcollins-g): Rationalize the different "enclosing" types so that
  // this doesn't duplicate `[enclosingElement]` in many cases.
  // TODO(jcollins-g): Implement comment reference resolution via categories,
  // making the iterable make sense here.
  Iterable<Nameable> get referenceParents;

  /// Replace the parents of parents.  [referenceBy] ignores whatever might
  /// otherwise be implied by the [referenceParents] of [referenceParents],
  /// replacing them with this.
  Iterable<Nameable>? get referenceGrandparentOverrides => null;

  // TODO(jcollins-g): Enforce that reference name is always the same
  // as [ModelElement.name].  Easier/possible after old lookup code is gone.
  String get referenceName => name;

  // TODO(jcollins-g): Eliminate need for this in markdown_processor.
  Library? get library => null;

  /// For testing / comparison only, get the [Nameable] from where this
  /// `ElementType` was defined.  Override where an [Element] is available.
  @internal
  Nameable get definingNameable => this;
}

/// Compares [a] with [b] by name.
int byName(Nameable a, Nameable b) {
  if (a is Library && b is Library) {
    return compareAsciiLowerCaseNatural(a.displayName, b.displayName);
  }

  if (a is Constructor && b is Constructor) {
    var aName = a.name.replaceFirst('.new', '');
    var bName = b.name.replaceFirst('.new', '');
    return compareAsciiLowerCaseNatural(aName, bName);
  }

  var stringCompare = compareAsciiLowerCaseNatural(a.name, b.name);
  if (stringCompare != 0) {
    return stringCompare;
  }

  return a.hashCode.compareTo(b.hashCode);
}

/// A set of utility methods for helping build [Nameable.referenceChildren] out
/// of collections of other [Nameable]s.
extension NameableEntryGenerators<T extends Nameable> on Iterable<T> {
  /// Creates reference entries for this Iterable.
  ///
  /// If there is a conflict with [nameable], the included [MapEntry] uses
  /// [nameable]'s [Nameable.referenceName] as a prefix.
  Map<String, T> explicitOnCollisionWith(Nameable nameable) => {
        for (var r in this)
          if (r.referenceName == nameable.referenceName)
            '${nameable.referenceName}.${r.referenceName}': r
          else
            r.referenceName: r,
      };

  /// A mapping from each [Nameable]'s name to itself.
  Map<String, T> get asMapByName => {
        for (var r in this) r.referenceName: r,
      };

  /// Returns all values not of this type.
  List<T> whereNotType<U>() => [
        for (var nameable in this)
          if (nameable is! U) nameable,
      ];
}

class _ReferenceChildrenLookup {
  final String lookup;
  final List<String> remaining;

  _ReferenceChildrenLookup(this.lookup, this.remaining);

  @override
  String toString() =>
      '$lookup ($lookup${remaining.isNotEmpty ? ".${remaining.join(".")}" : ''})';
}

extension on Scope {
  /// Prefer the getter for a bundled lookup if both exist.
  Element? lookupPreferGetter(String id) {
    var result = lookup(id);
    return result.getter ?? result.setter;
  }
}
