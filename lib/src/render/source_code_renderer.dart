// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

/// Renderer for source code snippets extracted from source files.
abstract class SourceCodeRenderer {
  String renderSourceCode(String source);
}

class SourceCodeRendererNoop extends SourceCodeRenderer {
  @override
  String renderSourceCode(String source) => source;
}

/// [SourceCodeRenderer] that escapes characters for HTML.
class SourceCodeRendererHtml extends SourceCodeRenderer {
  @override
  String renderSourceCode(String source) {
    return (const HtmlEscape()).convert(source);
  }
}
