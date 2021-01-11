// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources from the dartdoc code repository.
library dartdoc.resource_loader;

import 'dart:convert' show utf8;
import 'dart:isolate' show Isolate;
import 'package:analyzer/file_system/file_system.dart';
import 'package:meta/meta.dart';

class ResourceLoader {
  final ResourceProvider provider;

  ResourceLoader(this.provider);

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

    var uri = await resolveUri(Uri.parse(path));
    return provider.getFile(uri.toFilePath()).readAsBytesSync();
  }

  /// Helper function for resolving to a non-relative, non-package URI.
  @visibleForTesting
  Future<Uri> resolveUri(Uri uri) {
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
}
