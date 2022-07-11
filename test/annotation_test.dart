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
  const libraryName = 'annotations';

  const dartCoreUrlPrefix = 'https://api.dart.dev/stable/2.16.0/dart-core';

  late PackageMetaProvider packageMetaProvider;
  late MemoryResourceProvider resourceProvider;
  late FakePackageConfigProvider packageConfigProvider;
  late String packagePath;

  setUp(() async {
    packageMetaProvider = testPackageMetaProvider;
    resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;

    packagePath = await d.createPackage(
      libraryName,
      pubspec: '''
name: annotations
version: 0.0.1
environment:
  sdk: '>=2.15.0 <3.0.0'
''',
      resourceProvider: resourceProvider,
    );

    packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, libraryName, Uri.file('$packagePath/'));
  });

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

  test('deprecated constant is linked', () async {
    var library = await bootPackageWithLibrary('''
@deprecated
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );
  });

  test('Deprecated() constructor call is linked', () async {
    var library = await bootPackageWithLibrary('''
@Deprecated('text')
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="$dartCoreUrlPrefix/Deprecated-class.html">Deprecated</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="$dartCoreUrlPrefix/Deprecated-class.html">Deprecated</a>'
      '(&#39;text&#39;)',
    );
  });

  test('locally declared constant is linked', () async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation();
}

const myAnnotation = MyAnnotation();

@myAnnotation
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/myAnnotation-constant.html">'
      'myAnnotation</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/myAnnotation-constant.html">'
      'myAnnotation</a>',
    );
  });

  test('locally declared constructor call is linked', () async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation(bool b);
}

@MyAnnotation(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/MyAnnotation-class.html">'
      'MyAnnotation</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/MyAnnotation-class.html">'
      'MyAnnotation</a>(true)',
    );
  });

  test('generic constructor call is linked', () async {
    var library = await bootPackageWithLibrary('''
class Ann<T> {
  final T f;
  const Ann(this.f);
}

@Ann(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/Ann-class.html">Ann</a>'
      '<span class="signature">&lt;<wbr><span class="type-parameter">'
      '<a href="$dartCoreUrlPrefix/bool-class.html">bool</a></span>&gt;</span>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/Ann-class.html">Ann</a>'
      '<span class="signature">&lt;<wbr><span class="type-parameter">'
      '<a href="$dartCoreUrlPrefix/bool-class.html">bool</a></span>&gt;</span>(true)',
    );
  });
}
