// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/feature.dart';
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

  @override
  Container get enclosingElement;

  late final Container definingEnclosingContainer =
      modelBuilder.fromElement(element.enclosingElement!) as Container;

  @override
  Set<Feature> get features => {
        ...super.features,
        if (isExtended) Feature.extended,
      };

  late final Container? canonicalEnclosingContainer = () {
    final canonicalEnclosingContainer = computeCanonicalEnclosingContainer();
    assert(canonicalEnclosingContainer == null ||
        canonicalEnclosingContainer.isDocumented);
    return canonicalEnclosingContainer;
  }();

  Container? computeCanonicalEnclosingContainer() {
    final enclosingElement = this.enclosingElement;
    if (enclosingElement is! Extension) {
      return packageGraph.findCanonicalModelElementFor(element.enclosingElement)
          as Container?;
    }
    // TODO(jcollins-g): move Extension specific code to [Extendable]
    if (enclosingElement.isDocumented) {
      return packageGraph.findCanonicalModelElementFor(enclosingElement.element)
          as Container?;
    }
    return null;
  }

  @override
  // TODO(jcollins-g): dart-lang/dartdoc#2693.
  Iterable<Container> get referenceParents =>
      // If you don't want the ambiguity of where your comment references are
      // resolved with respect to documentation inheritance, that has to be
      // resolved in the source by not inheriting documentation.
      [
        enclosingElement,
        (documentationFrom.first as ContainerMember).enclosingElement,
      ];

  @override
  Iterable<Library> get referenceGrandparentOverrides sync* {
    // TODO(jcollins-g): split Field documentation up between accessors
    // and resolve the pieces with different scopes.  dart-lang/dartdoc#2693.
    // Until then, just pretend we're handling this correctly.
    yield (documentationFrom.first as ModelElement).definingLibrary;
    // TODO(jcollins-g): Wean users off of depending on canonical library
    // resolution. dart-lang/dartdoc#2696
    if (canonicalLibrary != null) yield canonicalLibrary!;
  }
}
