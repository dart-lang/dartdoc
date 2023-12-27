// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utilities copied out of `package:grinder/grinder_files.dart`.
library;

import 'dart:io';

final String _sep = Platform.pathSeparator;

/// Copy the given entity to the destination directory.
///
/// Note that the [context] parameter is deprecated.
void copy(FileSystemEntity entity, Directory destDir) {
  print('copying ${entity.path} to ${destDir.path}');
  return _copyImpl(entity, destDir);
}

void _copyImpl(FileSystemEntity? entity, Directory destDir) {
  if (entity is Directory) {
    for (final entity in entity.listSync()) {
      final name = fileName(entity);

      if (entity is File) {
        _copyImpl(entity, destDir);
      } else {
        _copyImpl(entity, joinDir(destDir, [name]));
      }
    }
  } else if (entity is File) {
    final destFile = joinFile(destDir, [fileName(entity)]);

    if (!destFile.existsSync() ||
        entity.lastModifiedSync() != destFile.lastModifiedSync()) {
      destDir.createSync(recursive: true);
      entity.copySync(destFile.path);
    }
  } else {
    throw StateError('unexpected type: ${entity.runtimeType}');
  }
}

/// Return the last segment of the file path.
String fileName(FileSystemEntity entity) {
  final name = entity.path;
  final index = name.lastIndexOf(_sep);
  return (index != -1 ? name.substring(index + 1) : name);
}

File joinFile(Directory dir, List<String> files) {
  final pathFragment = files.join(_sep);
  return File('${dir.path}$_sep$pathFragment');
}

Directory joinDir(Directory dir, List<String> files) {
  final pathFragment = files.join(_sep);
  return Directory('${dir.path}$_sep$pathFragment');
}
