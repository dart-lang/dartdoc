// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:path/path.dart' as path;

import '../dartdoc_test_base.dart';
import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

abstract class TemplateTestBase extends DartdocTestBase {
  String get packageName;

  /// Creates a package on disk with the given singular library [content], and
  /// generates the docs.
  Future<void> createPackageWithLibrary(String content) async {
    packagePath = await d.createPackage(
      packageName,
      pubspec: '''
name: $packageName
version: 0.0.1
environment:
  sdk: '>=3.3.0-0 <4.0.0'
''',
      libFiles: [
        d.file('lib.dart', content),
      ],
      resourceProvider: resourceProvider,
    );
    await writeDartdocResources(resourceProvider);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));

    await (await buildDartdoc()).generateDocs();
  }

  List<String> readLines(List<String> filePath) =>
      resourceProvider.readLines([packagePath, 'doc', ...filePath]);
}

extension on MemoryResourceProvider {
  List<String> readLines(List<String> pathParts) =>
      getFile(path.joinAll(pathParts)).readAsStringSync().split('\n');
}
