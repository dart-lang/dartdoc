// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A structure to keep track of extensions and their applicability efficiently.
library dartdoc.extension_tree;

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/special_elements.dart';

/// This class defines a node in an [Extension] tree.  An extension tree's
/// nodes are arranged given the following:
///
/// - Each node contains the set of extensions declared as being directly on
///   [extendedType].
/// - All parents, recursively, of a node contain extensions that could
///   apply to any instantiated type of [extendedType.bound].
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
    if (couldApplyTo(c.modelType)) {
      yield* extensions;
      yield* children.expand((e) => e.allCouldApplyTo(c));
    }
  }

  /// Returns the added or modified extension node.  If the extension is
  /// already in the tree, will return the node it was found in.
  ExtensionNode addExtension(Extension newExtension) {
    assert(identical(newExtension.packageGraph, packageGraph));
    ExtensionNode newNode =
        ExtensionNode(newExtension.extendedType, packageGraph, {newExtension});
    return _addExtensionNode(newNode);
  }

  ExtensionNode _addExtensionNode(ExtensionNode newNode) {
    if (newNode.extensions.first.name == 'SymDiff') {
      print('hello');
    }
    if (extendedType.name == 'String' ||
        newNode.extendedType.name == 'String') {
      print('hello');
    }
    if (newNode.extensions.first.name == '') {
      print('hmmm');
    }
    if (extendedType.instantiatedType ==
        newNode.extendedType.instantiatedType) {
      // Extended on the exact same type.  Add to this set.
      _merge(newNode);
      return this;
    }
    //assert(!newNode.couldApplyTo(extendedType));

    Set<ExtensionNode> foundApplicable = {};
    for (ExtensionNode child in children) {
      if (child.couldApplyTo(newNode.extendedType)) {
        // This child should be a child of, or the same type as the new node.
        foundApplicable.add(child);
      }
    }

    for (ExtensionNode applicable in foundApplicable) {
      applicable._detach();
      if (applicable.extendedType.instantiatedType ==
          newNode.extendedType.instantiatedType) {
        newNode._merge(applicable);
      } else {
        newNode._addChild(applicable);
      }
    }

    for (ExtensionNode child in children) {
      if (newNode.couldApplyTo(child.extendedType)) {
        return child._addExtensionNode(newNode);
      }
    }

    /*
    assert(foundApplicable.length <= 1,
        'tree structure invalid, multiple possible parents found');
    if (foundApplicable.isNotEmpty) {
      return foundApplicable.first._addExtensionNode(newNode);
    }
    // Some children of this node may need to be reparented under this
    // node.

    Set<ExtensionNode> reparentThese = {};
    for (ExtensionNode child in children) {
      if (newNode.extendedType.type == child.extendedType.type) {
        // Any reparenting should already have taken place.
        assert(reparentThese.isEmpty);
        return child._addExtensionNode(newNode);
      }
      else if (newNode.isSuperType(child.extendedType)) {
        reparentThese.add(child);
      }
    }
    for (ExtensionNode reparentMe in reparentThese) {
      if (reparentMe.extendedType.name == 'String' && newNode.extendedType.name == 'String') {
        print('wtf');
      }
      reparentMe._detach();
      newNode._addChild(reparentMe);
    }
    */
    _addChild(newNode);
    return newNode;
  }

  List<ExtensionNode> childList;

  /// Add a child, unconditionally.
  void _addChild(ExtensionNode newChild) {
    children.add(newChild);
    childList = children.toList();
    newChild.parent = this;
  }

  bool isSuperType(DefinedElementType t) => packageGraph.typeSystem
      .isSubtypeOf(t.instantiatedType, extendedType.instantiatedType);

  bool isSubtype(DefinedElementType t) => packageGraph.typeSystem
      .isSubtypeOf(extendedType.instantiatedType, t.instantiatedType);

  bool couldApplyTo(DefinedElementType t) {
    if (t.instantiatedType.element.name == 'Set' &&
        extendedType.instantiatedType.element.name == 'Set') {
      print('hello');
    }
    return t.instantiatedType == extendedType.instantiatedType ||
        isSuperType(t);
  }

  /// Remove this subtree from its parent node, unconditionally.
  void _detach() {
    parent.children.remove(this);
    parent == null;
  }

  /// Merge from [other] node into [this], unconditionally.
  void _merge(ExtensionNode other) {
    //assert(other.extendedType.type == extendedType.type);
    extensions.addAll(other.extensions);
    children.addAll(other.children);
  }

  @override
  int get hashCode => extendedType.type.hashCode;

  @override
  bool operator ==(other) => extendedType.type == other.extendedType.type;

  @override
  String toString() =>
      '{${extensions.map((e) => e.name).join(', ')}} => ${extendedType.toString()}  (${extendedType.instantiatedType.toString()})';
}
