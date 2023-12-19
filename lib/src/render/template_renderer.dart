// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

abstract class LayoutRenderer {
  String composeLayoutTitle(String name, String? kind, bool isDeprecated);
}

class HtmlLayoutRenderer implements LayoutRenderer {
  const HtmlLayoutRenderer();

  @override
  String composeLayoutTitle(String name, String? kind, bool isDeprecated) {
    var kindText = kind == null ? '' : ' $kind';
    if (isDeprecated) {
      return '<span class="deprecated">$name</span>$kindText';
    } else {
      return '$name$kindText';
    }
  }
}
