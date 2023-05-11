// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/generator/file_structure.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dartdoc_test_base.dart';
import '../src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FileStructureTest);
  });
}

@reflectiveTest
class FileStructureTest extends DartdocTestBase {
  @override
  String get libraryName => 'file_structure_test';

  void test_createFileStructureForVariable() async {
    var library = await bootPackageWithLibrary('''
var globalVar = 123;
''');
    var globalVar = library.properties.named('globalVar');
    var htmlStructure =
        FileStructure(FileStructureMode.htmlOriginal, globalVar);
    var mdStructure = FileStructure(FileStructureMode.mdOriginal, globalVar);
    expect(htmlStructure.fileType, equals('html'));
    expect(mdStructure.fileType, equals('md'));
  }
}
