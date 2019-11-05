// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A structure to keep track of extensions and their applicability efficiently.
library dartdoc.extension_tree;

import 'dart:collection';

import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/special_elements.dart';

/// This class defines a node in an [Extension] tree.  An extension tree's
/// nodes are arranged given the following:
///
/// - Each node contains the set of extensions declared as being directly on
///   [extendedType].
/// - All parents, recursively, of a node contain extensions that could
///   apply to any instantiated-to-upper-bounds type of [extendedType.element].
///
/// A tree of ExtensionNodes will have a root node associated with the [Object]
/// type and more specific types will be further down the tree.
class ExtensionNode {
  /// The set of extensions that directly apply to [extendedType].
  final Set<Extension> extensions;

  /// The set of ExtensionNodes containing [extensions] that apply only to
  /// more specific types than [extendedType].
  final Set<ExtensionNode> children = {};

  /// The type all [extensions] are extending.
  final DefinedElementType extendedType;

  /// The [PackageGraph] associated with the tree; must be the same for all
  /// nodes.
  final PackageGraph packageGraph;

  ExtensionNode(this.extendedType, this.packageGraph, this.extensions);

  /// Creates an initially empty root node for [Object].
  factory ExtensionNode.fromRoot(PackageGraph packageGraph) => ExtensionNode(
      packageGraph.specialClasses[SpecialClass.object].modelType,
      packageGraph, {});

  /// A node containing a more general type than [extendedType].
  ExtensionNode parent;

  /// Do not call addExtension while iterating over the return value to
  /// this function.
  Iterable<Extension> allCouldApplyTo(Class c) sync* {
    if (couldApplyTo(c)) {
      yield* extensions;
      yield* children.expand((e) => e.allCouldApplyTo(c));
    }
  }

  /// Returns the added or modified extension node.  If the extension is
  /// already in the tree, will return the node it was found in.
  ExtensionNode addExtension(Extension newExtension) {
    assert(identical(newExtension.packageGraph, packageGraph));
    if (extendedType.element is! Class) {
      throw UnimplementedError(
          'Extension tree does not yet know about extensions not on classes');
    }
    assert(extendedType.element is Class);
    assert(extendedType.element is Documentable);
    ExtensionNode newNode =
        ExtensionNode(newExtension.extendedType, packageGraph, {newExtension});
    return _addExtensionNode(newNode);
  }

  ExtensionNode _addExtensionNode(ExtensionNode newNode) {
    if (extendedType.type == newNode.extendedType.type) {
      // Extended on the exact same type.  Add to this set.
      _merge(newNode);
      return this;
    }
    assert(!newNode.couldApplyTo(extendedType.element));

    Set<ExtensionNode> foundApplicable = {};
    for (ExtensionNode child in children) {
      if (child.couldApplyTo(extendedType.element)) {
        // This child should be a parent of, or the same type as the new node.
        foundApplicable.add(child);
      }
    }

    assert(foundApplicable.length <= 1,
        'tree structure invalid, multiple possible parents found');
    if (foundApplicable.isNotEmpty) {
      return foundApplicable.first._addExtensionNode(newNode);
    }
    // Some children of this node may need to be reparented under this
    // node.
    Set<ExtensionNode> reparentThese = {};
    for (ExtensionNode child in children) {
      if (newNode.couldApplyTo(child.extendedType.element)) {
        reparentThese.add(child);
      }
    }
    for (ExtensionNode reparentMe in reparentThese) {
      reparentMe._detach();
      newNode._addChild(reparentMe);
    }
    _addChild(newNode);
    return newNode;
  }

  /// Add a child, unconditionally.
  void _addChild(ExtensionNode newChild) {
    children.add(newChild);
    newChild.parent = this;
  }

  bool couldApplyTo(Class c) =>
      (c.element == extendedType.element.element) ||
      packageGraph.typeSystem
          .isSubtypeOf(c.modelType.instantiatedType, extendedType.type);

  /// Remove this subtree from its parent node, unconditionally.
  void _detach() {
    parent.children.remove(this);
    parent == null;
  }

  /// Merge this node into [other], unconditionally.
  void _merge(ExtensionNode other) {
    assert(other.extendedType.type == extendedType.type);
    other.extensions.addAll(extensions);
    other.children.addAll(children);
  }

  @override
  int get hashCode => extendedType.type.hashCode;

  @override
  bool operator ==(other) => extendedType.type == other.extendedType.type;
}
