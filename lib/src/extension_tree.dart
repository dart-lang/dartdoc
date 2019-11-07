// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A structure to keep track of extensions and their applicability efficiently.
library dartdoc.extension_tree;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/special_elements.dart';

/// This class defines a node in an [Extension] tree.  A hybrid of a heap and
/// a type tree, an extension tree's nodes are arranged to the following
/// invariants on public methods:
///
/// - Each node contains the set of extensions declared as being directly on
///   [extendedType], or an equivalent type.
/// - All parents, recursively, of a node and the node itself contain extensions
///   that could apply to any instantiated type of [extendedType].
///
/// An extension "could apply" to a type if there exists some valid
/// instantiation of that type where the extension would be applicable if
/// made accessible in the namespace per:
/// https://github.com/dart-lang/language/blob/master/accepted/2.6/static-extension-members/feature-specification.md#implicit-extension-member-invocation
class ExtensionNode {
  /// The set of extensions that directly apply to [extendedType].
  final Set<Extension> extensions;

  /// The set of ExtensionNodes containing [extensions] that apply only to
  /// more specific types than [extendedType].
  final Set<ExtensionNode> children = {};

  /// The set of seen [ModelElement]s backing [extendedType]s in this tree.
  /// Only valid at the root.
  Set<ModelElement> _seen;

  /// The set of seen [ModelElement]s that have had empty nodes inserted in the
  /// tree if appropriate, or simply seen more than once if not.  Subset of
  /// [_seen].
  Set<ModelElement> _genericsInserted;

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

  /// Insert a node for the instantiated-to-bound type of [newExtendedType]s
  /// class if there are a lot of type-specific extensions for the same class.
  /// Makes the structure more efficient in the C++ template-emulation use case
  /// for extension methods.
  void _maybeInsertGenericNode(DefinedElementType newExtendedType) {
    if (!(_seen ??= {}).contains(newExtendedType.element)) {
      _seen.add(newExtendedType.element);
      return;
    }
    if (!(_genericsInserted ??= {}).contains(newExtendedType.element)) {
      ElementType genericType = newExtendedType.element.modelType;
      if (genericType is DefinedElementType) {
        if (genericType.typeArguments.isNotEmpty &&
            genericType.type != extendedType.type) {
          ElementType genericElementType = ElementType.from(
              genericType.instantiatedType,
              newExtendedType.element.library,
              packageGraph);
          _addExtensionNode(ExtensionNode(genericElementType, packageGraph, {}));
        }
      }
      _genericsInserted.add(newExtendedType.element);
    }
  }

  /// Returns the added or modified extension node.  If the extension is
  /// already in the tree, will return the node it was found in.
  ExtensionNode addExtension(Extension newExtension) {
    assert(identical(newExtension.packageGraph, packageGraph));
    ExtensionNode newNode =
        ExtensionNode(newExtension.extendedType, packageGraph, {newExtension});
    if (parent == null) _maybeInsertGenericNode(newExtension.extendedType);
    return _addExtensionNode(newNode);
  }

  ExtensionNode _addExtensionNode(ExtensionNode newNode) {
    if (extendedType.instantiatedType ==
        newNode.extendedType.instantiatedType) {
      // Extended on the exact same type.  Add to this set.
      _merge(newNode);
      return this;
    }

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
        if (applicable.isSubtypeOf(newNode.extendedType)) {
          newNode._addChild(applicable);
        } else if (newNode.isSubtypeOf(applicable.extendedType) ||
            newNode.isBoundSuperclassTo(applicable.extendedType)) {
          _addChild(applicable);
          return applicable._addExtensionNode(newNode);
        }
      }
    }

    for (ExtensionNode child in children) {
      if (newNode.couldApplyTo(child.extendedType)) {
        return child._addExtensionNode(newNode);
      }
    }

    _addChild(newNode);
    return newNode;
  }

  /// Add a child, unconditionally.
  void _addChild(ExtensionNode newChild) {
    children.add(newChild);
    newChild.parent = this;
  }

  /// The instantiated to bounds [extendedType] of this node is a supertype of
  /// [t].
  bool isSupertypeOf(DefinedElementType t) => packageGraph.typeSystem
      .isSubtypeOf(t.instantiatedType, extendedType.instantiatedType);

  /// The instantiated to bounds [extendedType] of this node is a subtype of
  /// [t].
  bool isSubtypeOf(DefinedElementType t) => packageGraph.typeSystem
      .isSubtypeOf(extendedType.instantiatedType, t.instantiatedType);

  /// The class from this [extendedType]:
  ///
  /// 1) is a superclass of the class associated with [t] and
  /// 2) any type parameters from [t] instantiated with that superclass type
  ///    result in a subtype of [t].
  bool isBoundSuperclassTo(DefinedElementType t) {
    InterfaceType supertype = (t.type.element is ClassElement
        ? (t.type.element as ClassElement)?.supertype
        : null);
    ClassElement superclass = supertype?.element;
    while (superclass != null) {
      if (superclass == extendedType.type.element &&
          (supertype == extendedType.instantiatedType ||
              packageGraph.typeSystem
                  .isSubtypeOf(supertype, extendedType.instantiatedType))) {
        return true;
      }
      supertype = superclass.supertype;
      superclass = supertype?.element;
    }
    return false;
  }

  /// Return true if the [extensions] in this node could apply to [t].
  /// If true, the children of this node may also apply but must be checked
  /// individually with their [couldApplyTo] methods. If false, neither this
  /// node's extensions nor its children could apply.
  bool couldApplyTo(DefinedElementType t) {
    return t.instantiatedType == extendedType.instantiatedType ||
        (t.instantiatedType.element == extendedType.instantiatedType.element &&
            isSubtypeOf(t)) ||
        isBoundSuperclassTo(t);
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
  /// Intended for debugging only.
  /// Format : {ExtensionName1, ExtensionName2, ...} => extendedType (extendedType.instantiatedType)
  String toString() =>
      '{${extensions.map((e) => e.name).join(', ')}} => ${extendedType.toString()}  (${extendedType.instantiatedType.toString()})';
}
