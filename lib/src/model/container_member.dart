// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

/// A [ModelElement] that is a [Container] member.
mixin ContainerMember on ModelElement {
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

  @override
  String get filePath =>
      '${canonicalLibraryOrThrow.dirName}/${enclosingElement.name}/$fileName';

  /// The container that contains this member.
  @protected
  @visibleForTesting
  late final Container definingEnclosingContainer =
      getModelForElement(element.enclosingElement!) as Container;

  @override
  Set<Attribute> get attributes => {
        ...super.attributes,
        if (isExtended) Attribute.extended,
      };

  late final Container? canonicalEnclosingContainer = () {
    final canonicalEnclosingContainer = computeCanonicalEnclosingContainer();
    assert(canonicalEnclosingContainer == null ||
        canonicalEnclosingContainer.isDocumented);
    return canonicalEnclosingContainer;
  }();

  Container? computeCanonicalEnclosingContainer() =>
      packageGraph.findCanonicalModelElementFor(enclosingElement) as Container?;

  /// The model element to link to for a reference to this member, where
  /// [container] is the class the reference names, as `C` in `[C.m]`, or the
  /// class whose documentation contains an unqualified reference.
  ///
  /// Usually this is the member itself. A member whose declaring class has no
  /// page, as for a private class, is documented on the public classes that
  /// inherit it. For such a member the result is the model element on
  /// [container], or on the nearest superclass of [container] that documents
  /// the member. If there is none, as when [container] overrides the member,
  /// this member is returned and still has no page.
  ContainerMember documentedOn(InheritingContainer? container) {
    if (canonicalModelElement != null) return this;
    // Inheritance happens among classes, mixins, enums and extension types,
    // the [InheritingContainer]s. An extension member is never inherited, so
    // it has no copy elsewhere, and for one without a page
    // `findCanonicalModelElementFor` would construct a model on [container]
    // rather than find one.
    if (definingEnclosingContainer is! InheritingContainer) return this;
    var documented = packageGraph.findCanonicalModelElementFor(this,
        preferredClass: container);
    return documented is ContainerMember ? documented : this;
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
  List<Library> get referenceGrandparentOverrides =>
      // TODO(jcollins-g): split Field documentation up between accessors
      // and resolve the pieces with different scopes.  dart-lang/dartdoc#2693.
      // Until then, just pretend we're handling this correctly.
      [
        documentationFrom.first.library,
        if (this case Field(:var getter, :var setter))
          packageGraph.findCanonicalModelElementFor(getter ?? setter)?.library
        else
          (packageGraph.findCanonicalModelElementFor(this) ?? this).library,
      ].nonNulls.toList();
}
