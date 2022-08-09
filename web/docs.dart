// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js' as js;

import 'search.dart' as search;
import 'sidenav.dart' as sidenav;
import 'theme.dart' as theme;

void main() {
  inithighlightJS();
  sidenav.init();
  search.init();
  theme.init();
}

void inithighlightJS() {
  js.JsObject hljs = js.context['hljs'];
  hljs.callMethod('highlightAll');
}