// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:async';

import    'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/options.dart';

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
Future<void> main(List<String> arguments) async {
  var config = parseOptions(pubPackageMetaProvider, arguments);
  if (config == null) {
    // Do not run dartdoc as there was either a fatal error parsing options, or
    // `--help` was passed, or `--version` was passed.
    return;
  }
  final packageConfigProvider = PhysicalPackageConfigProvider();
  final packageBuilder =
      PubPackageBuilder(config, pubPackageMetaProvider, packageConfigProvider);
  final dartdoc = config.generateDocs
      ? await Dartdoc.fromContext(config, packageBuilder)
      : Dartdoc.withEmptyGenerator(config, packageBuilder);
  dartdoc.executeGuarded();
}
