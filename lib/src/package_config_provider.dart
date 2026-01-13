// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:package_config/package_config.dart' as package_config;
import 'package:path/path.dart' as path;

/// A provider of PackageConfig-finding methods.
///
/// This provides an abstraction around package_config, which can only work
/// with the physical file system.
abstract class PackageConfigProvider {
  package_config.PackageConfig? findPackageConfig(Folder dir);
}

class PhysicalPackageConfigProvider implements PackageConfigProvider {
  @override

  /// Discovers the package configuration for a Dart script.
  ///
  /// This is a synchronous version of
  /// [`findPackageConfig`](https://github.com/dart-lang/tools/blob/52cc9b5bb10e2293a094678815c2b4d13b1a3acf/pkgs/package_config/lib/src/discovery.dart#L34).
  ///
  /// See https://github.com/dart-lang/tools/issues/1536 for any progress on
  /// synchronous APIs in the package_config package.
  package_config.PackageConfig? findPackageConfig(Folder baseDirectory) {
    var directory = io.Directory(baseDirectory.path);
    if (!directory.isAbsolute) directory = directory.absolute;
    if (!directory.existsSync()) return null;

    do {
      var packageConfig = findPackageConfigInDirectory(directory);
      if (packageConfig != null) return packageConfig;
      // Check in parent directories.
      var parentDirectory = directory.parent;
      if (parentDirectory.path == directory.path) break;
      directory = parentDirectory;
    } while (true);
    return null;
  }

  /// Finds a `.dart_tool/package_config.json` file in [directory].
  ///
  /// This is a synchronous version of
  /// [`findPackageConfigInDirectory`](https://github.com/dart-lang/tools/blob/52cc9b5bb10e2293a094678815c2b4d13b1a3acf/pkgs/package_config/lib/src/discovery.dart#L119C24-L119C52).
  /// with `checkForPackageConfigJsonFile` inlined.
  package_config.PackageConfig? findPackageConfigInDirectory(
      io.Directory directory) {
    var packageConfigFile =
        io.File(path.join(directory.path, '.dart_tool', 'package_config.json'));
    if (!packageConfigFile.existsSync()) return null;

    var bytes = packageConfigFile.readAsBytesSync();
    var config =
        package_config.PackageConfig.parseBytes(bytes, packageConfigFile.uri);
    if (config.version < _minVersion) return null;
    return config;
  }

  /// The minimum "Package Config" version which we can parse.
  static const _minVersion = 1;
}

class FakePackageConfigProvider implements PackageConfigProvider {
  /// A mapping of package config search locations to configured packages.
  final _packageConfigData = <String, List<package_config.Package>>{};

  /// Adds the package named [name] at [root] to the package config for
  /// [location].
  void addPackageToConfigFor(String location, String name, Uri root) {
    _packageConfigData
        .putIfAbsent(location, () => [])
        .add(package_config.Package(name, root));
  }

  @override
  package_config.PackageConfig findPackageConfig(Folder dir) {
    var packageConfig = _packageConfigData[dir.path];
    assert(packageConfig != null,
        'Package config data at ${dir.path} should not be null');
    return package_config.PackageConfig(packageConfig!);
  }
}
