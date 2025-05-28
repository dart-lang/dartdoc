// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources from the dartdoc code repository.
library;

import 'dart:isolate' show Isolate;

import 'package:analyzer/file_system/file_system.dart';
import 'package:meta/meta.dart';

extension ResourceLoader on ResourceProvider {
  Future<Folder> getResourceFolder(String path) async {
    var uri = await resolveResourceUri(Uri.parse(path));
    return getFolder(uri.toFilePath());
  }

  /// Resolves a non-relative, non-package URI.
  @visibleForTesting
  Future<Uri> resolveResourceUri(Uri uri) async {
    if (uri.scheme == 'package') {
      var resolvedUri = await Isolate.resolvePackageUri(uri);
      if (resolvedUri == null) {
        throw ArgumentError.value(uri, 'uri', 'Unknown package');
      }
      return resolvedUri;
    } else {
      return Uri.base.resolveUri(uri);
    }
  }
}
