// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:package_config/package_config.dart' as package_config;

/// Discovers the package configuration for a Dart script.
///
/// This is a synchronous version of
/// [`findPackageConfig`](https://github.com/dart-lang/tools/blob/52cc9b5bb10e2293a094678815c2b4d13b1a3acf/pkgs/package_config/lib/src/discovery.dart#L34).
///
/// See https://github.com/dart-lang/tools/issues/1536 for any progress on
/// synchronous APIs in the package_config package.
package_config.PackageConfig? findPackageConfig(Folder folder) {
  if (!folder.exists) return null;

  do {
    var packageConfig = findPackageConfigInDirectory(folder);
    if (packageConfig != null) return packageConfig;
    // Check in parent folders.
    var parentFolder = folder.parent;
    if (parentFolder.path == folder.path) break;
    folder = parentFolder;
  } while (true);
  return null;
}

/// Finds a `.dart_tool/package_config.json` file in [folder].
///
/// This is a synchronous version of
/// [`findPackageConfigInDirectory`](https://github.com/dart-lang/tools/blob/52cc9b5bb10e2293a094678815c2b4d13b1a3acf/pkgs/package_config/lib/src/discovery.dart#L119C24-L119C52).
/// with `checkForPackageConfigJsonFile` inlined.
package_config.PackageConfig? findPackageConfigInDirectory(Folder folder) {
  var packageConfigFile = folder
      .getChildAssumingFolder('.dart_tool')
      .getChildAssumingFile('package_config.json');

  if (!packageConfigFile.exists) return null;

  var bytes = packageConfigFile.readAsBytesSync();
  var config =
      package_config.PackageConfig.parseBytes(bytes, packageConfigFile.toUri());
  if (config.version < _minVersion) return null;
  return config;
}

const _minVersion = 1;
