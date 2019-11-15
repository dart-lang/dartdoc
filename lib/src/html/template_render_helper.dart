// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

abstract class TemplateRenderHelper {
  String composeLayoutTitle(String name, String kind, bool isDeprecated);
}

class HtmlRenderHelper implements TemplateRenderHelper {
  @override
  String composeLayoutTitle(String name, String kind, bool isDeprecated) {
    if (isDeprecated) {
      return '<span class="deprecated">${name}</span> ${kind}';
    } else {
      return '${name} ${kind}';
    }
  }
}
