// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/enum.dart';

abstract class EnumFieldRenderer {
  String renderValue(EnumField field);
}

class EnumFieldRendererHtml extends EnumFieldRenderer {
  @override
  String renderValue(EnumField field) {
    if (field.name == 'values') {
      return 'const List&lt;<wbr><span class="type-parameter">${field.enclosingElement.name}</span>&gt;';
    } else {
      return 'const ${field.enclosingElement.name}(${field.index})';
    }
  }
}

class EnumFieldRendererMd extends EnumFieldRenderer {
  @override
  String renderValue(EnumField field) {
    if (field.name == 'values') {
      return 'const List<${field.enclosingElement.name}>';
    } else {
      return 'const ${field.enclosingElement.name}(${field.index})';
    }
  }
}
