// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  const libraryName = 'records';

  late PackageMetaProvider packageMetaProvider;
  late MemoryResourceProvider resourceProvider;
  late FakePackageConfigProvider packageConfigProvider;
  late String packagePath;

  Future<void> setUpPackage(
    String name, {
    String? pubspec,
    String? analysisOptions,
  }) async {
    packagePath = await d.createPackage(
      name,
      pubspec: pubspec,
      analysisOptions: analysisOptions,
      resourceProvider: resourceProvider,
    );

    packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, name, Uri.file('$packagePath/'));
  }

  Future<Library> bootPackageWithLibrary(String libraryContent) async {
    await d.dir('lib', [
      d.file('lib.dart', '''
library $libraryName;

$libraryContent
'''),
    ]).createInMemory(resourceProvider, packagePath);

    var packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    return packageGraph.libraries.named(libraryName);
  }

  group('records', skip: !recordsAllowed, () {
    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(
        libraryName,
        pubspec: '''
name: records
version: 0.0.1
environment:
  sdk: '>=2.19.0-0 <3.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - records
''',
      );
    });

    test('with no fields is presented with display names', () async {
      var library = await bootPackageWithLibrary('''
void f(() record) {}
''');
      var fFunction = library.functions.named('f');
      var recordType = fFunction.modelType.parameters.first.modelType;
      expect(recordType.linkedName, equals('Record()'));
      expect(recordType.nameWithGenerics, equals('Record'));
    });

    test('with one positional field is presented with a linked name', () async {
      var library = await bootPackageWithLibrary('''
void f((int) record) {}
''');
      var fFunction = library.functions.named('f');
      var recordType = fFunction.modelType.parameters.first.modelType;
      expect(recordType.linkedName, matchesCompressed(r'''
        Record\(
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">\$0</span>
          </span>
        \)
      '''));
      expect(recordType.nameWithGenerics, equals('Record'));
    });

    test('with positional fields is presented with a linked name', () async {
      var library = await bootPackageWithLibrary('''
void f((int, String) record) {}
''');
      var fFunction = library.functions.named('f');
      var recordType = fFunction.modelType.parameters.first.modelType;
      expect(recordType.linkedName, matchesCompressed(r'''
        Record\(
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">\$0</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
            <span class="field-name">\$1</span>
          </span>
        \)
      '''));
      expect(recordType.nameWithGenerics, equals('Record'));
    });

    test('with named fields is presented with a linked name', () async {
      var library = await bootPackageWithLibrary('''
void f(({int bbb, String aaa}) record) {}
''');
      var fFunction = library.functions.named('f');
      var recordType = fFunction.modelType.parameters.first.modelType;
      expect(recordType.linkedName, matchesCompressed(r'''
        Record\(
          <span class="field">
            \{
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
            <span class="field-name">aaa</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">bbb</span>
            \}
          </span>
        \)
      '''));
      expect(recordType.nameWithGenerics, equals('Record'));
    });

    test('with positional and named fields is presented with a linked name',
        () async {
      var library = await bootPackageWithLibrary('''
void f((int one, String two, {int ccc, String aaa, int bbb}) record) {}
''');
      var fFunction = library.functions.named('f');
      var recordType = fFunction.modelType.parameters.first.modelType;
      expect(recordType.linkedName, matchesCompressed(r'''
        Record\(
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">\$0</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
            <span class="field-name">\$1</span>,
          </span>
          <span class="field">
            \{
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
            <span class="field-name">aaa</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">bbb</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">ccc</span>
            \}
          </span>
        \)
      '''));
      expect(recordType.nameWithGenerics, equals('Record'));
    });
  });
}
