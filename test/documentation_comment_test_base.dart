// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart' as utils;

@reflectiveTest
class DocumentationCommentTestBase extends DartdocTestBase {
  @override
  String get libraryName => 'my_library';

  String get packageName => 'my_package';

  late Folder projectRoot;
  late PackageGraph packageGraph;
  late ModelElement libraryModel;

  void expectNoWarnings() {
    expect(packageGraph.packageWarningCounter.countedWarnings, isEmpty);
    expect(packageGraph.packageWarningCounter.hasWarnings, isFalse);
  }

  Future<void> writePackageWithCommentedLibraries(
    List<(String, String)> filesAndComments, {
    List<String> additionalArguments = const [],
  }) async {
    projectRoot = utils.writePackage(packageName, resourceProvider);
    projectRoot
        .getChildAssumingFile('dartdoc_options.yaml')
        .writeAsStringSync('''
      dartdoc:
        warnings:
          - missing-code-block-language
      ''');

    for (var (fileName, comment) in filesAndComments) {
      projectRoot
          .getChildAssumingFolder('lib')
          .getChildAssumingFile(fileName)
          .writeAsStringSync('$comment\n'
              'library;');
    }

    var optionSet = DartdocOptionRoot.fromOptionGenerators(
        'dartdoc', [createDartdocOptions], packageMetaProvider);
    optionSet.parseArguments([]);
    packageGraph = await utils.bootBasicPackage(
        projectRoot.path, packageMetaProvider,
        additionalArguments: additionalArguments);
    libraryModel = packageGraph.defaultPackage.libraries.first;
  }

  Future<void> writePackageWithCommentedLibrary(
    String comment, {
    List<String> additionalArguments = const [],
  }) =>
      writePackageWithCommentedLibraries([('a.dart', comment)],
          additionalArguments: additionalArguments);
}
