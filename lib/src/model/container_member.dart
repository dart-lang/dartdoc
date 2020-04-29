// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// A [ModelElement] that is a [Container] member.
mixin ContainerMember on ModelElement implements EnclosedElement {
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
    _definingEnclosingContainer ??=
        ModelElement.fromElement(element.enclosingElement, packageGraph);
    return _definingEnclosingContainer;
  }

  @override
  Set<String> get features {
    var _features = super.features;
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
    if (enclosingElement is Extension && enclosingElement.isDocumented) {
      return packageGraph
          .findCanonicalModelElementFor(enclosingElement.element);
    }
    if (enclosingElement is! Extension) {
      return packageGraph
          .findCanonicalModelElementFor(element.enclosingElement);
    }
    return null;
  }
}
