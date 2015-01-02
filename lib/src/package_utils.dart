// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

String getPackageName(String directoryName)  =>
    _getPubspec(directoryName)['name'];

Map _getPubspec(String directoryName) {
  var pubspecName = path.join(directoryName, 'pubspec.yaml');
  File pubspec = new File(pubspecName);
  if (!pubspec.existsSync()) return {'name': ''};
  var contents = pubspec.readAsStringSync();
  return loadYaml(contents);
}

String getPackageDescription(String directoryName) =>
  _getPubspec(directoryName)['description'];

String getPackageVersion(String directoryName) =>
  _getPubspec(directoryName)['version'];
