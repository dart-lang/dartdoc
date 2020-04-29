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

import 'dart:async' show Future;
import 'dart:convert' show utf8;

import 'package:resource/resource.dart';

/// Loads a `package:` resource as a String.
Future<String> loadAsString(String path) async {
  var bytes = await loadAsBytes(path);

  return utf8.decode(bytes);
}

/// Loads a `package:` resource as an [List<int>].
Future<List<int>> loadAsBytes(String path) async {
  if (!path.startsWith('package:')) {
    throw ArgumentError('path must begin with package:');
  }

  var uri = Uri.parse(path);
  return await ResourceLoader.defaultLoader.readAsBytes(uri);
}
