// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:package_config/package_config.dart' as package_config;

abstract class PackageConfigProvider {
  Future<package_config.PackageConfig> findPackageConfigUri(Uri location);
}

class PhysicalPackageConfigProvider implements PackageConfigProvider {
  @override
  Future<package_config.PackageConfig> findPackageConfigUri(Uri location) =>
      package_config.findPackageConfigUri(location);
}

class FakePackageConfigProvider implements PackageConfigProvider {
  /// A mapping of package config search locations to configured packages.
  final _packageConfigData = <Uri, List<package_config.Package>>{};

  void addPackageToConfigFor(Uri location, String name, Uri root) {
    _packageConfigData.putIfAbsent(location, () => []);
    _packageConfigData[location].add(package_config.Package(name, root));
  }

  @override
  Future<package_config.PackageConfig> findPackageConfigUri(
      Uri location) async {
    return package_config.PackageConfig(_packageConfigData[location]);
  }
}
