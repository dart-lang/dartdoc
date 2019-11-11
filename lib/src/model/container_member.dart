// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// A [ModelElement] that is a [Container] member.
mixin ContainerMember on ModelElement implements EnclosedElement {
  /// True if this [ContainerMember] is inherited from a different class.
  bool get isInherited;

  /// True if this [ContainerMember] is overriding a superclass.
  bool get isOverride;

  /// True if this [ContainerMember] has a parameter whose type is overridden
  /// by a subtype.
  bool get isCovariant;

  /// True if this [ContainerMember] is from an applicable [Extension].
  /// False otherwise, including if this [ContainerMember]'s [enclosingElement]
  /// is the extension it was declared in.
  // TODO(jcollins-g): This semantic is a little confusing, because a declared
  // extension member element returns false.  The rationale is an
  // extension member is not extending itself.
  // FIXME(jcollins-g): Remove concrete implementation after [Extendable] is
  // implemented.
  bool get isExtended => false;

  Container _definingEnclosingContainer;

  Container get definingEnclosingContainer {
    if (_definingEnclosingContainer == null) {
      _definingEnclosingContainer =
          ModelElement.fromElement(element.enclosingElement, packageGraph);
    }
    return _definingEnclosingContainer;
  }

  @override
  Set<String> get features {
    Set<String> _features = super.features;
    if (isOverride) _features.add('override');
    if (isInherited) _features.add('inherited');
    if (isCovariant) _features.add('covariant');
    if (isExtended) _features.add('extended');
    return _features;
  }

  bool _canonicalEnclosingContainerIsSet = false;
  Container _canonicalEnclosingContainer;

  Container get canonicalEnclosingContainer {
    if (!_canonicalEnclosingContainerIsSet) {
      _canonicalEnclosingContainer = computeCanonicalEnclosingContainer();
      _canonicalEnclosingContainerIsSet = true;
      assert(_canonicalEnclosingContainer == null ||
          _canonicalEnclosingContainer.isDocumented);
    }
    return _canonicalEnclosingContainer;
  }

  Container computeCanonicalEnclosingContainer() {
    // TODO(jcollins-g): move Extension specific code to [Extendable]
    if (enclosingElement is! Extension ||
        (enclosingElement is Extension && enclosingElement.isDocumented)) {
      return packageGraph
          .findCanonicalModelElementFor(enclosingElement.element);
    }
    return null;
  }
}
