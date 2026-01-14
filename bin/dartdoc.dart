// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
void main(List<String> arguments) {
  var config = parseOptions(pubPackageMetaProvider, arguments);
  if (config == null) {
    // Do not run dartdoc as there was either a fatal error parsing options, or
    // `--help` was passed, or `--version` was passed.
    return;
  }
  final packageBuilder = PubPackageBuilder(config, pubPackageMetaProvider);
  Dartdoc.fromContext(config, packageBuilder).executeGuarded();
}
