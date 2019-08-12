library dartdoc.empty_generator;

import 'dart:async';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';

/// A generator that does not generate files, but does traverse the [PackageGraph]
/// and access [ModelElement.documetationAsHtml] for every element as though
/// it were.
class EmptyGenerator extends Generator {
  @override
  Future generate(PackageGraph _packageGraph, String outputDirectoryPath) {
    _onFileCreated.add(_packageGraph.defaultPackage.documentationAsHtml);
    for (var package in Set.from([_packageGraph.defaultPackage])
      ..addAll(_packageGraph.localPackages)) {
      for (var category in filterNonDocumented(package.categories)) {
        _onFileCreated.add(category.documentationAsHtml);
      }

      for (Library lib in filterNonDocumented(package.libraries)) {
        filterNonDocumented(lib.allModelElements)
            .forEach((m) => _onFileCreated.add(m.documentationAsHtml));
      }
    }
    return null;
  }

  final StreamController<void> _onFileCreated =
      new StreamController(sync: true);

  @override

  /// Implementation fires on each model element processed rather than
  /// file creation.
  Stream<void> get onFileCreated => _onFileCreated.stream;

  @override
  Set<String> get writtenFiles => new Set();
}

Future<Generator> createEmptyGenerator(DartdocOptionContext config) async {
  return EmptyGenerator();
}
