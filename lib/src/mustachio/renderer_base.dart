// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'parser.dart';

/// The base class for a generated Mustache renderer.
abstract class RendererBase<T> {
  /// The context object which this renderer can render.
  final T context;

  /// The output buffer into which [context] is rendered, using a template.
  final buffer = StringBuffer();

  RendererBase(this.context);

  void write(String text) => buffer.write(text);

  /// Renders a block of Mustache template, the [ast], into [buffer].
  void renderBlock(List<MustachioNode> ast) {
    for (var node in ast) {
      if (node is Text) {
        write(node.content);
      } else if (node is Variable) {
        // TODO(srawlins): Implement.
      } else if (node is Section) {
        section(node);
      } else if (node is Partial) {
        partial(node);
      }
    }
  }

  void section(Section node) {
    // TODO(srawlins): Implement.
  }

  void partial(Partial node) {
    // TODO(srawlins): Implement.
  }
}

/// An individual property of objects of type [T], including functions for
/// rendering various types of Mustache nodes.
class Property<T> {
  /// Gets the value of this property on the object [context].
  final Object /*?*/ Function(T context) /*!*/ getValue;

  /// Gets the property map of the type of this property.
  final Map<String /*!*/, Property<Object> /*!*/ >
      Function() /*?*/ getProperties;

  /// Gets the bool value (true or false, never null) of this property on the
  /// object [context].
  final bool /*!*/ Function(T context) /*?*/ getBool;

  // TODO(srawlins): Add functions for rendering Iterable properties and other
  // properties.

  Property({@required this.getValue, this.getProperties, this.getBool});
}
