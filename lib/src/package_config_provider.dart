// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:package_config/package_config.dart' as package_config;

/// A provider of PackageConfig-finding methods.
///
/// This provides an abstraction around package_config, which can only work
/// with the physical file system.
abstract class PackageConfigProvider {
  Future<package_config.PackageConfig> findPackageConfig(Folder dir);
}

class PhysicalPackageConfigProvider implements PackageConfigProvider {
  @override
  Future<package_config.PackageConfig> findPackageConfig(Folder dir) =>
      package_config.findPackageConfig(io.Directory(dir.path));
}

class FakePackageConfigProvider implements PackageConfigProvider {
  /// A mapping of package config search locations to configured packages.
  final _packageConfigData = <String, List<package_config.Package>>{};

  void addPackageToConfigFor(String location, String name, Uri root) {
    _packageConfigData
        .putIfAbsent(location, () => [])
        .add(package_config.Package(name, root));
  }

  @override
  Future<package_config.PackageConfig> findPackageConfig(Folder dir) async {
    assert(_packageConfigData[dir.path] != null,
        'Package config data at ${dir.path} should not be null');
    return package_config.PackageConfig(_packageConfigData[dir.path]);
  }
}
