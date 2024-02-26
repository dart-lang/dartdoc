// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'highlight.dart' as highlight;
import 'search.dart' as search;
import 'sidebars.dart' as sidebars;
import 'theme.dart' as theme;

void main() {
  sidebars.init();
  search.init();
  highlight.init();
  theme.init();
}
