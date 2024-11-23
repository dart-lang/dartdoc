// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc_web/highlight.dart' as highlight;
import 'package:dartdoc_web/search.dart' as search;
import 'package:dartdoc_web/sidebars.dart' as sidebars;
import 'package:dartdoc_web/theme.dart' as theme;

void main() {
  sidebars.init();
  search.init();
  highlight.init();
  theme.init();
}
