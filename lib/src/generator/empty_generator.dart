library dartdoc.empty_generator;

import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';

/// A generator that does not generate files, but does traverse the
/// [PackageGraph] and access [ModelElement.documentationAsHtml] for every
/// element as though it were.
class EmptyGenerator extends Generator {
  @override
  Future<void> generate(PackageGraph packageGraph, FileWriter writer) {
    logProgress(packageGraph.defaultPackage.documentationAsHtml);
    for (var package in {packageGraph.defaultPackage}
      ..addAll(packageGraph.localPackages)) {
      for (var category in filterNonDocumented(package.categories)) {
        logProgress(category.documentationAsHtml);
      }

      for (var lib in filterNonDocumented(package.libraries)) {
        filterNonDocumented(lib.allModelElements)
            .forEach((m) => logProgress(m.documentationAsHtml));
      }
    }
    return Future.value(null);
  }
}

Generator initEmptyGenerator() {
  return EmptyGenerator();
}
