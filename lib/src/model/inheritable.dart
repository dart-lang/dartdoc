// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/model.dart';

/// Mixin for subclasses of [ModelElement] representing elements that can be
/// inherited from one class to another.
///
/// We can search the inheritance chain between this instance and
/// [definingEnclosingContainer] in [Inheritable.canonicalEnclosingContainer],
/// for the canonical [Class] closest to where this member was defined.  We
/// can then know that when we find [Inheritable.element] inside that [Class]'s
/// namespace, that's the one we should treat as canonical and implementors of
/// this class can use that knowledge to determine canonicalization.
///
/// We pick the class closest to the [definingEnclosingContainer] so that all
/// children of that class inheriting the same member will point to the same
/// place in the documentation, and we pick a canonical class because that's
/// the one in the public namespace that will be documented.
mixin Inheritable on ContainerMember {
  /// Whether this is inherited from a different class or mixin.
  bool get isInherited;

  /// Whether this has a parameter whose type is overridden by a subtype.
  bool get isCovariant;

  @override
  Set<Attribute> get attributes => {
        ...super.attributes,
        if (isOverride) Attribute.override_,
        if (isInherited) Attribute.inherited,
        if (isCovariant) Attribute.covariant,
      };

  @override
  Library? get canonicalLibrary =>
      canonicalEnclosingContainer?.canonicalLibrary;

  @override
  // TODO(srawlins): Do something about this overridden field. Maybe split out
  // the super implementation.
  // ignore: overridden_fields
  late final ModelElement? canonicalModelElement = canonicalEnclosingContainer
      ?.allCanonicalModelElements
      .firstWhereOrNull((m) =>
          m.name == name &&
          m is PropertyAccessorElement == this is PropertyAccessorElement);

  @override
  Container? computeCanonicalEnclosingContainer() {
    if (!isInherited || definingEnclosingContainer is Extension) {
      return super.computeCanonicalEnclosingContainer();
    }

    var searchElement = element.baseElement;
    // TODO(jcollins-g): generate warning if an inherited element's definition
    // is in an intermediate non-canonical class in the inheritance chain?
    var candidates = _enclosingSuperTypes;
    for (var i = 0; i < candidates.length; i++) {
      var container = candidates[i];
      if (container.containsElement(searchElement)) {
        var thisIsHiddenAndDefining = _isHiddenInterface(container) &&
            container == definingEnclosingContainer;

        if (thisIsHiddenAndDefining) {
          return container.supertype?.modelElement.canonicalModelElement
              as Container?;
        }
        var canonicalContainer =
            packageGraph.findCanonicalModelElementFor(container) as Container?;

        // TODO(jcollins-g): invert this lookup so traversal is recursive
        // starting from the ModelElement.
        if (canonicalContainer != null) {
          return canonicalContainer;
        }
      }
    }

    // None of the super-containers are canonical.
    return null;
  }

  /// Whether [c] is a "hidden" interface.
  ///
  /// A hidden interface should never be considered the canonical enclosing
  /// container of a container member.
  ///
  /// Add classes here if they are similar to the Dart SDK's 'Interceptor' class
  /// in that they are to be ignored even when they are the implementers of
  /// [Inheritable]s, and the class these inherit from should instead claim
  /// implementation.
  bool _isHiddenInterface(Container? c) =>
      c != null &&
      c.element.name == 'Interceptor' &&
      c.element.library?.name == '_interceptors';

  /// All of the various supertypes of [enclosingElement], in a specific order.
  ///
  /// The first types are the interfaces, supertypes, and mixed-in types of
  /// [enclosingElement]'s supertype. Next is [enclosingElement]'s supertype
  /// itself. Next are the interfaces, supertypes, and mixed-in types of each
  /// directly mixed-in type, followed by each directly mixed-in type. Next are
  /// the interfaces, supertypes, and mixed-in types of each direct interface,
  /// followed by each direct interface. Last is [enclosingElement].
  List<InheritingContainer> get _enclosingSuperTypes {
    var result = <InheritingContainer>{};
    var processed = <InheritingContainer>{};

    void addSupertype(InheritingContainer container) {
      if (processed.contains(container)) return;
      processed.add(container);
      for (var interface in container.interfaceElements) {
        addSupertype(interface);
        result.add(interface);
      }
      var supertype = container.supertype?.modelElement;
      if (supertype is InheritingContainer) {
        addSupertype(supertype);
        result.add(supertype);
      }
      if (container case Class(:var mixedInTypes) || Enum(:var mixedInTypes)) {
        for (var mixedIn in mixedInTypes.modelElements.reversed) {
          addSupertype(mixedIn);
          result.add(mixedIn);
        }
      }
      result.add(container);
    }

    var enclosingElement = this.enclosingElement as InheritingContainer;
    if (enclosingElement.supertype?.modelElement
        case InheritingContainer supertype) {
      addSupertype(supertype);
    }
    if (enclosingElement
        case Class(:var mixedInTypes) || Enum(:var mixedInTypes)) {
      for (var mixedIn in mixedInTypes.modelElements.reversed) {
        addSupertype(mixedIn);
        result.add(mixedIn);
      }
    }
    for (var interface in enclosingElement.interfaceElements) {
      addSupertype(interface);
    }
    result.add(enclosingElement);

    return result.toList();
  }

  Inheritable? get overriddenElement;

  /// Whether this [Inheritable] is overriding a member from a superclass.
  ///
  /// This is distinct from [isInherited]. An inheritable member which is an
  /// override is explicitly written in its container. An inheritable member
  /// which is implicitly included in a container is "inherited", and not an
  /// override.
  late final bool isOverride = () {
    // The canonical version of the enclosing element -- not
    // [canonicalEnclosingElement], as that is the element enclosing the
    // canonical version of this element; two different things.  Defaults to the
    // enclosing element.
    //
    // We use canonical elements here where possible to deal with reexports
    // as seen in Flutter.
    if (enclosingElement is Extension) {
      return false;
    }

    final overriddenElement = this.overriddenElement;
    if (overriddenElement == null) {
      // We have to have an overridden element for it to be possible for this
      // element to be an override.
      return false;
    }

    final enclosingCanonical =
        enclosingElement.canonicalModelElement as InheritingContainer?;
    // The container in which this element was defined, canonical if available.
    final definingCanonical =
        definingEnclosingContainer.canonicalModelElement as Container? ??
            definingEnclosingContainer;
    if (enclosingCanonical != definingCanonical) {
      // The defining class and the enclosing class for this element must be the
      // same (element is defined here).
      assert(isInherited);
      return false;
    }

    // The canonical version of the element we're overriding, if available.
    final overriddenCanonical =
        overriddenElement.canonicalModelElement ?? overriddenElement;

    // If the overridden element isn't public, we shouldn't be an override in
    // most cases.  Approximation until #1623 is fixed.
    final isOverride = overriddenCanonical.isPublic;
    assert(!isOverride || !isInherited);
    return isOverride;
  }();

  /// The depth of overrides at which this element lives.
  ///
  /// Just a count of how long the chain of this element's `overriddenElement`.
  /// For use in ranking search results.
  int get overriddenDepth {
    var depth = 0;
    var e = this;
    while (e.overriddenElement != null) {
      depth += 1;
      e = e.overriddenElement!;
    }
    return depth;
  }
}
