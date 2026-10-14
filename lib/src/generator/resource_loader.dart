// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources from the dartdoc code repository.
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show zlib;
import 'dart:isolate' show Isolate;
import 'dart:typed_data';

import 'package:analyzer/file_system/file_system.dart';
import 'package:meta/meta.dart';

@Native<Uint8>(symbol: 'dartdoc_resources_bundle')
external int _resourcesBundle;

@Native<Uint64>(symbol: 'dartdoc_resources_bundle_len')
external int _resourcesBundleLen;

Map<String, Uint8List>? _embeddedResources;

Map<String, Uint8List> _loadEmbeddedResources() =>
    _embeddedResources ??= decodeCompressedResources(
      Native.addressOf<Uint8>(
        _resourcesBundle,
      ).asTypedList(_resourcesBundleLen),
    );

/// Decodes a zlib-compressed UTF-8 JSON map of resource filenames to
/// base64-encoded file bytes.
@visibleForTesting
Map<String, Uint8List> decodeCompressedResources(List<int> compressedBytes) {
  var decodedBytes = zlib.decode(compressedBytes);
  var map = json.decode(utf8.decode(decodedBytes)) as Map<String, dynamic>;
  return {
    for (var entry in map.entries)
      entry.key: base64.decode(entry.value as String),
  };
}

extension ResourceLoader on ResourceProvider {
  /// Loads the bytes for [resourceFileName] inside `package:dartdoc/resources`.
  ///
  /// In JIT mode (when [Isolate.resolvePackageUri] resolves package URIs),
  /// reads the file from `this` [ResourceProvider] at the resolved path.
  /// In AOT mode (when [Isolate.resolvePackageUri] returns `null`), returns the
  /// bytes from the native asset bundle compiled by `hook/build.dart`.
  Future<Uint8List> loadResourceBytes(String resourceFileName) async {
    var resolvedUri = await Isolate.resolvePackageUri(
      Uri.parse('package:dartdoc/resources'),
    );
    if (resolvedUri != null) {
      var sourcePath = pathContext.join(
        resolvedUri.toFilePath(),
        resourceFileName,
      );
      return getFile(sourcePath).readAsBytesSync();
    }
    var bytes = _loadEmbeddedResources()[resourceFileName];
    if (bytes == null) {
      throw StateError('Missing bundled resource: $resourceFileName');
    }
    return bytes;
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
