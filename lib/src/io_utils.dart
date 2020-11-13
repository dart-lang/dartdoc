// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a helper library to make working with io easier.
library dartdoc.io_utils;

import 'dart:convert';
import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:path/path.dart' as path;

Encoding utf8AllowMalformed = Utf8Codec(allowMalformed: true);

/// Return a resolved path including the home directory in place of tilde
/// references.
String resolveTildePath(String originalPath) {
  if (originalPath == null || !originalPath.startsWith('~/')) {
    return originalPath;
  }

  String homeDir;

  if (io.Platform.isWindows) {
    homeDir = path.absolute(io.Platform.environment['USERPROFILE']);
  } else {
    homeDir = path.absolute(io.Platform.environment['HOME']);
  }

  return path.join(homeDir, originalPath.substring(2));
}

bool isSdkLibraryDocumented(SdkLibrary library) {
  if (library is MockSdkLibrary) {
    // Not implemented in [MockSdkLibrary].
    return true;
  }
  return library.isDocumented;
}

extension ResourceProviderExtensions on ResourceProvider {
  Folder createSystemTemp(String prefix) {
    if (this is PhysicalResourceProvider) {
      return getFolder(io.Directory.systemTemp.createTempSync(prefix).path);
    } else {
      return getFolder(pathContext.join('/tmp', prefix))..create();
    }
  }

  String get resolvedExecutable {
    if (this is PhysicalResourceProvider) {
      return io.Platform.resolvedExecutable;
    } else {
      // TODO(srawlins): Return what is needed for tests.
      return null;
    }
  }

  bool isExecutable(File file) {
    if (this is PhysicalResourceProvider) {
      var mode = io.File(file.path).statSync().mode;
      return (0x1 & ((mode >> 6) | (mode >> 3) | mode)) != 0;
    } else {
      // TODO(srawlins)
      return false;
    }
  }

  bool isNotFound(File file) {
    if (this is PhysicalResourceProvider) {
      return io.File(file.path).statSync().type ==
          io.FileSystemEntityType.notFound;
    } else {
      return !file.exists;
    }
  }

  String readAsMalformedAllowedStringSync(File file) {
    if (this is PhysicalResourceProvider) {
      return io.File(file.path).readAsStringSync(encoding: utf8AllowMalformed);
    } else {
      return file.readAsStringSync();
    }
  }
}

/// Converts `.` and `:` into `-`, adding a ".html" extension.
///
/// For example:
///
/// * dart.dartdoc => dart_dartdoc.html
/// * dart:core => dart_core.html
String getFileNameFor(String name) =>
    '${name.replaceAll(_libraryNameRegExp, '-')}.html';

final _libraryNameRegExp = RegExp('[.:]');
@Deprecated('Public variable intended to be private; will be removed as early '
    'as Dartdoc 1.0.0')
RegExp get libraryNameRegexp => _libraryNameRegExp;

@Deprecated('Public variable intended to be private; will be removed as early '
    'as Dartdoc 1.0.0')
final RegExp partOfRegexp = RegExp('part of ');

@Deprecated('Public variable intended to be private; will be removed as early '
    'as Dartdoc 1.0.0')
final RegExp newLinePartOfRegexp = RegExp('\npart of ');

/// Best used with Future<void>.
class MultiFutureTracker<T> {
  /// Approximate maximum number of simultaneous active Futures.
  final int parallel;

  final Set<Future<T>> _trackedFutures = {};

  MultiFutureTracker(this.parallel);

  /// Wait until fewer or equal to this many Futures are outstanding.
  Future<void> _waitUntil(int max) async {
    while (_trackedFutures.length > max) {
      await Future.any(_trackedFutures);
    }
  }

  /// Generates a [Future] from the given closure and adds it to the queue,
  /// once the queue is sufficiently empty.  The returned future completes
  /// when the generated [Future] has been added to the queue.
  ///
  /// If the closure does not handle its own exceptions, other calls to
  /// [addFutureFromClosure] or [wait] may trigger an exception.
  Future<void> addFutureFromClosure(Future<T> Function() closure) async {
    await _waitUntil(parallel - 1);
    Future<void> future = closure();
    _trackedFutures.add(future);
    // ignore: unawaited_futures
    future.then((f) {
      _trackedFutures.remove(future);
    }, onError: (s, e) {
      _trackedFutures.remove(future);
    });
  }

  /// Wait until all futures added so far have completed.
  Future<void> wait() async => await _waitUntil(0);
}
