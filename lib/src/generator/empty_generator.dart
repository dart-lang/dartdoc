library dartdoc.empty_generator;

import 'dart:async';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';

/// A generator that does not generate files, but does traverse the [PackageGraph]
/// and access [ModelElement.documentationAsHtml] for every element as though
/// it were.
class EmptyGenerator extends Generator {
  @override
  Future generate(PackageGraph _packageGraph, FileWriter writer) {
    logProgress(_packageGraph.defaultPackage.documentationAsHtml);
    for (var package in {_packageGraph.defaultPackage}
      ..addAll(_packageGraph.localPackages)) {
      for (var category in filterNonDocumented(package.categories)) {
        logProgress(category.documentationAsHtml);
      }

      for (var lib in filterNonDocumented(package.libraries)) {
        filterNonDocumented(lib.allModelElements)
            .forEach((m) => logProgress(m.documentationAsHtml));
      }
    }
    return null;
  }
}

Future<Generator> initEmptyGenerator(DartdocOptionContext config) async {
  return EmptyGenerator();
}
