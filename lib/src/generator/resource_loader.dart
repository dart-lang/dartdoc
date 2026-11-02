// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources from the dartdoc code repository.
library;

import 'dart:convert';
import 'dart:isolate' show Isolate;
import 'dart:typed_data';

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart' as resources;
import 'package:meta/meta.dart';

Future<Uri?>? _resourcesPackageUriFuture;

final Map<String, Uint8List> _decodedBundledResources = {};

/// Decodes the bundled resource bytes for [resourceFileName] from
/// [resources.bundledResourcesBase64].
@visibleForTesting
Uint8List loadBundledResourceBytes(String resourceFileName) {
  return _decodedBundledResources.putIfAbsent(resourceFileName, () {
    var encoded = resources.bundledResourcesBase64[resourceFileName];
    if (encoded == null) {
      throw StateError('Missing bundled resource: $resourceFileName');
    }
    return base64.decode(encoded.replaceAll('\n', ''));
  });
}

extension ResourceLoader on ResourceProvider {
  /// Loads the bytes for [resourceFileName] inside `package:dartdoc/resources`.
  ///
  /// In JIT mode (when [Isolate.resolvePackageUri] resolves package URIs),
  /// reads the file from `this` [ResourceProvider] at the resolved path.
  /// In AOT mode (when [Isolate.resolvePackageUri] returns `null`), returns the
  /// bytes from [resources.bundledResourcesBase64].
  Future<Uint8List> loadResourceBytes(String resourceFileName) async {
    var resolvedUri = await (_resourcesPackageUriFuture ??=
        Isolate.resolvePackageUri(Uri.parse('package:dartdoc/resources')));
    if (resolvedUri != null) {
      var sourcePath = pathContext.join(
        resolvedUri.toFilePath(),
        resourceFileName,
      );
      return getFile(sourcePath).readAsBytesSync();
    }
    return loadBundledResourceBytes(resourceFileName);
  }

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
