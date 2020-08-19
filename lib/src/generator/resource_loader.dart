// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources from the dartdoc code repository.
library dartdoc.resource_loader;

import 'dart:convert' show utf8;
import 'dart:io' show File;
import 'dart:isolate' show Isolate;

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

  var uri = await _resolveUri(Uri.parse(path));
  return File.fromUri(uri).readAsBytes();
}

/// Helper function for resolving to a non-relative, non-package URI.
Future<Uri> _resolveUri(Uri uri) {
  if (uri.scheme == 'package') {
    return Isolate.resolvePackageUri(uri).then((resolvedUri) {
      if (resolvedUri == null) {
        throw ArgumentError.value(uri, 'uri', 'Unknown package');
      }
      return resolvedUri;
    });
  }
  return Future<Uri>.value(Uri.base.resolveUri(uri));
}
