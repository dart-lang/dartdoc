// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show Member;
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/special_elements.dart';

/// Mixin for subclasses of ModelElement representing Elements that can be
/// inherited from one class to another.
///
/// We can search the inheritance chain between this instance and
/// [definingEnclosingContainer] in [Inheritable.canonicalEnclosingContainer],
/// for the canonical [Class] closest to where this member was defined.  We
/// can then know that when we find [Inheritable.element] inside that [Class]'s
/// namespace, that's the one we should treat as canonical and implementors
/// of this class can use that knowledge to determine canonicalization.
///
/// We pick the class closest to the [definingEnclosingElement] so that all
/// children of that class inheriting the same member will point to the same
/// place in the documentation, and we pick a canonical class because that's
/// the one in the public namespace that will be documented.
mixin Inheritable on ContainerMember {
  @override
  ModelElement buildCanonicalModelElement() {
    if (canonicalEnclosingContainer is Extension) {
      return this;
    }
    if (canonicalEnclosingContainer is Class) {
      return (canonicalEnclosingContainer as Class)
          ?.allCanonicalModelElements
          ?.firstWhere(
              (m) =>
                  m.name == name && m.isPropertyAccessor == isPropertyAccessor,
              orElse: () => null);
    }
    return null;
  }

  @override
  Container computeCanonicalEnclosingContainer() {
    if (isInherited) {
      Element searchElement = element;
      searchElement = searchElement is Member
          ? PackageGraph.getBasestElement(searchElement)
          : searchElement;
      // TODO(jcollins-g): generate warning if an inherited element's definition
      // is in an intermediate non-canonical class in the inheritance chain?
      Class previous;
      Class previousNonSkippable;
      Class found;
      for (Class c in inheritance.reversed) {
        // Filter out mixins.
        if (c.contains(searchElement)) {
          if ((packageGraph.inheritThrough.contains(previous) &&
                  c != definingEnclosingContainer) ||
              (packageGraph.inheritThrough.contains(c) &&
                  c == definingEnclosingContainer)) {
            return (previousNonSkippable.memberByExample(this) as Inheritable)
                .canonicalEnclosingContainer;
          }
          Class canonicalC =
              packageGraph.findCanonicalModelElementFor(c.element);
          // TODO(jcollins-g): invert this lookup so traversal is recursive
          // starting from the ModelElement.
          if (canonicalC != null) {
            assert(canonicalC.isCanonical);
            assert(canonicalC.contains(searchElement));
            found = canonicalC;
            break;
          }
        }
        previous = c;
        if (!packageGraph.inheritThrough.contains(c)) {
          previousNonSkippable = c;
        }
      }
      // This is still OK because we're never supposed to cloak public
      // classes.
      if (definingEnclosingContainer.isCanonical &&
          definingEnclosingContainer.isPublic) {
        assert(definingEnclosingContainer == found);
        return found;
      }
    }
    return super.computeCanonicalEnclosingContainer();
  }

  List<Class> get inheritance {
    List<Class> inheritance = [];
    inheritance.addAll((enclosingElement as Class).inheritanceChain);
    Class object = packageGraph.specialClasses[SpecialClass.object];
    if (!inheritance.contains(definingEnclosingContainer) &&
        definingEnclosingContainer != null) {
      assert(definingEnclosingContainer == object);
    }
    // Unless the code explicitly extends dart-core's Object, we won't get
    // an entry here.  So add it.
    if (inheritance.last != object && object != null) {
      inheritance.add(object);
    }
    assert(inheritance.where((e) => e == object).length == 1);
    return inheritance;
  }

  Inheritable get overriddenElement;

  bool _isOverride;

  @override
  bool get isOverride {
    if (_isOverride == null) {
      // The canonical version of the enclosing element -- not canonicalEnclosingElement,
      // as that is the element enclosing the canonical version of this element,
      // two different things.  Defaults to the enclosing element.
      //
      // We use canonical elements here where possible to deal with reexports
      // as seen in Flutter.
      if (enclosingElement is Extension) {
        _isOverride = false;
        return _isOverride;
      }
      Class enclosingCanonical = enclosingElement.canonicalModelElement;
      // The container in which this element was defined, canonical if available.
      Container definingCanonical =
          definingEnclosingContainer.canonicalModelElement ??
              definingEnclosingContainer;
      // The canonical version of the element we're overriding, if available.
      ModelElement overriddenCanonical =
          overriddenElement?.canonicalModelElement ?? overriddenElement;

      // We have to have an overridden element for it to be possible for this
      // element to be an override.
      _isOverride = overriddenElement != null &&
          // The defining class and the enclosing class for this element
          // must be the same (element is defined here).
          enclosingCanonical == definingCanonical &&
          // If the overridden element isn't public, we shouldn't be an
          // override in most cases.  Approximation until #1623 is fixed.
          overriddenCanonical.isPublic;
      assert(!(_isOverride && isInherited));
    }
    return _isOverride;
  }

  int _overriddenDepth;

  @override
  int get overriddenDepth {
    if (_overriddenDepth == null) {
      _overriddenDepth = 0;
      Inheritable e = this;
      while (e.overriddenElement != null) {
        _overriddenDepth += 1;
        e = e.overriddenElement;
      }
    }
    return _overriddenDepth;
  }
}
