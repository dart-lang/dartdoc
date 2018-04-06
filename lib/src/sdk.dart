// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Use config.sdkDir instead outside of initialization.
// TODO(jcollins-g): Avoid this function in PackageMeta, too.
Directory getSdkDir() {
  File vmExecutable = new File(Platform.resolvedExecutable);
  return vmExecutable.parent.parent;
}
