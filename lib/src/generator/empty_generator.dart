// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';

/// A generator that does not generate files, but does traverse the
/// [PackageGraph] and access [ModelElement.documentationAsHtml] for every
/// element as though it were.
class EmptyGenerator implements Generator {
  @override
  Future<void> generate(PackageGraph packageGraph) {
    logProgress(packageGraph.defaultPackage.documentationAsHtml);
    for (var package in {
      packageGraph.defaultPackage,
      ...packageGraph.localPackages
    }) {
      for (var category in filterNonDocumented(package.categories)) {
        logProgress(category.documentationAsHtml);
      }

      for (var lib in filterNonDocumented(package.libraries)) {
        filterNonDocumented(lib.allModelElements)
            .forEach((m) => logProgress(m.documentationAsHtml));
      }
    }
    return Future.value();
  }

  @override
  Set<String> get writtenFiles => const {};
}

Generator initEmptyGenerator() {
  return EmptyGenerator();
}
