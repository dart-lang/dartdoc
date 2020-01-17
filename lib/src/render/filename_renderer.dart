// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

abstract class FileNameRenderer {
  String renderFileName(String name);
}

class HtmlFileNameRenderer extends FileNameRenderer {
  @override
  String renderFileName(String name) => '$name.html';
}
