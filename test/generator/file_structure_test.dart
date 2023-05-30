// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dartdoc_test_base.dart';
import '../src/test_descriptor_utils.dart' as d;
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

  void test_fileNamesForModelElements() async {
    var library = await bootPackageWithLibrary('''
var globalVar = 123;
const globalConst = 123;

class AClass {
  const myConst = 75;
  var myVariable = 76;

  void aMethod();

  @override
  operator+ (AClass b) => AClass();
}

mixin BMixin on AClass {}
''', libraryPreamble: '''
/// {@category MyCategory}
''', extraFiles: [
      d.file('dartdoc_options.yaml', '''
dartdoc:
  categories:
    "MyCategory":
      markdown: mycategory.md
'''),
      d.file('mycategory.md', '''
Hello there, I am an *amazing* markdown file.
'''),
    ]);
    var globalVar = library.properties.named('globalVar');
    var globalConst = library.constants.named('globalConst');
    var category =
        library.package.categories.firstWhere((c) => c.name == 'MyCategory');
    var AClass = library.classes.named('AClass');
    var BMixin = library.mixins.named('BMixin');
    var myConst = AClass.constantFields.named('myConst');
    var myVariable = AClass.instanceFields.named('myVariable');
    var aMethod = AClass.instanceMethods.named('aMethod');
    var operatorPlus = AClass.instanceOperators.named('operator +');

    expect(globalVar.fileStructure.fileName, equals('globalVar.html'));
    expect(globalConst.fileStructure.fileName,
        equals('globalConst-constant.html'));
    expect(category.fileStructure.fileName, equals('MyCategory-topic.html'));
    expect(AClass.fileStructure.fileName, equals('AClass-class.html'));
    expect(BMixin.fileStructure.fileName, equals('BMixin-mixin.html'));
    expect(myConst.fileStructure.fileName, equals('myConst-constant.html'));
    expect(myVariable.fileStructure.fileName, equals('myVariable.html'));
    expect(aMethod.fileStructure.fileName, equals('aMethod.html'));
    expect(operatorPlus.fileStructure.fileName, equals('operator_plus.html'));
  }

  void test_fileNamesForMarkdownElements() async {
    var library = await bootPackageWithLibrary('''
class AClass {
}
''', additionalArguments: ['--format=md']);
    var AClass = library.classes.named('AClass');
    // The inherited toString implementation is not canonical, so be sure
    // to get the canonical reference.
    var AClassToString =
        AClass.inheritedMethods.named('toString').canonicalModelElement!;
    expect(AClass.fileStructure.fileName, equals('AClass-class.md'));
    expect(AClassToString.fileStructure.fileName, equals('toString.html'));
  }
}
