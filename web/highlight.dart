// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

void init() {
  highlight?.highlightAll();
}

@JS()
@staticInterop
final class HighlightJs {}

extension HighlightJsExtension on HighlightJs {
  external void highlightAll();
}

@JS('hljs')
external HighlightJs? get highlight;
