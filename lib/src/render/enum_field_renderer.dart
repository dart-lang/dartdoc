// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:dartdoc/src/model/enum.dart';

abstract class EnumFieldRenderer {
  String renderValue(EnumField field);
}

class EnumFieldRendererHtml implements EnumFieldRenderer {
  const EnumFieldRendererHtml();

  @override
  String renderValue(EnumField field) {
    if (field.name == 'values') {
      return 'const List&lt;<wbr><span class="type-parameter">${field.enclosingElement.name}</span>&gt;';
    } else {
      return 'const ${field.enclosingElement.name}(${field.index})';
    }
  }
}

class EnumFieldRendererMd implements EnumFieldRenderer {
  const EnumFieldRendererMd();

  @override
  String renderValue(EnumField field) {
    if (field.name == 'values') {
      return 'const List&lt;${field.enclosingElement.name}>';
    } else {
      return 'const ${field.enclosingElement.name}(${field.index})';
    }
  }
}
