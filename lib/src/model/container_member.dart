// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

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
  Set<Feature> get features => {
        ...super.features,
        if (isExtended) Feature.extended,
      };

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

  @override
  @nonVirtual
  Iterable<Container> get referenceParents sync* {
    yield enclosingElement;
    if (enclosingElement != definingEnclosingContainer) yield definingEnclosingContainer;
  }


  @override
  Iterable<Iterable<Library>> get referenceGrandparentOverrides {
    // TODO(jcollins-g): split Field documentation up between accessors
    // and resolve the pieces with different scopes.
    //assert(documentationFrom.length == 1);
    // Until then, just pretend we're handling this correctly.
    return [[documentationFrom.first.definingLibrary]];
  }
}
