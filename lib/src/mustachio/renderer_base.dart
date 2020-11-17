// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
