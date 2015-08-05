// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources, independent of how the Dart app is run.
///
///     Future<String> getTemplateFile(String templatePath) {
///       return loadAsString('package:dartdoc/templates/$templatePath');
///     }
///
library dartdoc.resource_loader;

import 'dart:async';

/// Loads a `package:` resource as a String.
Future<String> loadAsString(String path) {
  if (!path.startsWith('package:')) {
    throw new ArgumentError('path must begin with package:');
  }
  return new Resource(path).readAsString();
}

/// Loads a `package:` resource as a [List<int>].
Future<List<int>> loadAsBytes(String path) {
  if (!path.startsWith('package:')) {
    throw new ArgumentError('path must begin with package:');
  }
  return new Resource(path).readAsBytes();
}
