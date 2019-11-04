// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A structure to keep track of extensions and their applicability efficiently.
library dartdoc.extension_tree;

import 'dart:collection';

import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/model.dart';

abstract class ExtensionNodeVisitor<R> {
  R visit(ExtensionNode e);
}

class ExtensionNode {
  /// The set of extensions that directly apply to [typeOn].
  final Set<Extension> extensions = {};

  /// The set of ExtensionNodes containing [extensions] that apply only to
  /// more specific types than [typeOn].
  final Set<ExtensionNode> children = {};

  /// The type all [extensions] are extending.
  final DartType typeOn;

  ExtensionNode(this.typeOn);

  /// A node containing a more general type than [typeOn].
  ExtensionNode parent;

  R accept<R>(ExtensionNodeVisitor v) => v.visit(this);

  @override
  int get hashCode => typeOn.hashCode;

  @override
  bool operator ==(other) => typeOn == other.typeOn;
}
