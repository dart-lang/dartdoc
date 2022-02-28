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
  const libraryName = 'constant_values';

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

  group('constructor-tearoffs', () {
    const libraryName = 'constructor_tearoffs';

    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(
        libraryName,
        pubspec: '''
name: constructor_tearoffs
version: 0.0.1
environment:
  sdk: '>=2.15.0-0 <3.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - constructor-tearoffs
''',
      );
    });

    test('non-generic function reference', () async {
      var library = await bootPackageWithLibrary('''
void func() {}
const aFunc = func;
''');
      var aFuncConstant = library.constants.named('aFunc');
      expect(aFuncConstant.constantValue, equals('func'));
    });

    test('generic function reference', () async {
      var library = await bootPackageWithLibrary('''
void funcTypeParams<T extends String, U extends num>(
    T something, U different) {}
const aFuncParams = funcTypeParams;
''');
      var aFuncParamsConstant = library.constants.named('aFuncParams');
      expect(aFuncParamsConstant.constantValue, equals('funcTypeParams'));
    });

    test('generic function reference w/ type args', () async {
      var library = await bootPackageWithLibrary('''
void funcTypeParams<T extends String, U extends num>(
    T something, U different) {}
const aFuncWithArgs = funcTypeParams<String, int>;
''');
      var aFuncWithArgs = library.constants.named('aFuncWithArgs');
      expect(aFuncWithArgs.constantValue,
          equals('funcTypeParams&lt;String, int&gt;'));
    });

    test('named constructor reference', () async {
      var library = await bootPackageWithLibrary('''
class F<T> {
  F.alternative();
}
const aTearOffNamedConstructor = F.alternative;
''');
      var aTearOffNamedConstructor =
          library.constants.named('aTearOffNamedConstructor');
      expect(aTearOffNamedConstructor.constantValue, equals('F.alternative'));
    });

    test('named constructor reference w/ type args', () async {
      var library = await bootPackageWithLibrary('''
class F<T> {
  F.alternative();
}
const aTearOffNamedConstructorArgs = F<int>.alternative;
''');
      var aTearOffNamedConstructorArgs =
          library.constants.named('aTearOffNamedConstructorArgs');
      expect(aTearOffNamedConstructorArgs.constantValue,
          equals('F&lt;int&gt;.alternative'));
    });

    test('unnamed constructor reference', () async {
      var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructor = F.new;
''');
      var aTearOffUnnamedConstructor =
          library.constants.named('aTearOffUnnamedConstructor');
      expect(aTearOffUnnamedConstructor.constantValue, equals('F.new'));
    });

    test('unnamed constructor reference w/ type args', () async {
      var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructorArgs = F<String>.new;
''');
      var aTearOffUnnamedConstructorArgs =
          library.constants.named('aTearOffUnnamedConstructorArgs');
      expect(aTearOffUnnamedConstructorArgs.constantValue,
          equals('F&lt;String&gt;.new'));
    });

    test('unnamed typedef constructor reference', () async {
      var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructorTypedef = Fstring.new;
''');
      var aTearOffUnnamedConstructorTypedef =
          library.constants.named('aTearOffUnnamedConstructorTypedef');
      expect(aTearOffUnnamedConstructorTypedef.constantValue,
          equals('Fstring.new'));
    });

    test('unnamed typedef constructor reference w/ type args', () async {
      var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructorArgsTypedef = Ft<String>.new;
''');
      var aTearOffUnnamedConstructorArgsTypedef =
          library.constants.named('aTearOffUnnamedConstructorArgsTypedef');
      expect(aTearOffUnnamedConstructorArgsTypedef.constantValue,
          equals('Ft&lt;String&gt;.new'));
    });
  }, skip: !constructorTearoffsAllowed);

  group('named-arguments-anywhere', () {
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
    const libraryName = 'constant_values';
    const linkPrefix = '$placeholder$libraryName';

    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(
        libraryName,
        pubspec: '''
name: named_arguments_anywhere
version: 0.0.1
environment:
  sdk: '>=2.17.0-0 <3.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - named-arguments-anywhere
''',
      );
    });

    test('named parameters in a const invocation value can be specified last',
        () async {
      var library = await bootPackageWithLibrary('''
class C {
  const C(int a, int b, {required int c, required int d});
}
const p = C(1, 2, c: 3, d: 4);
''');
      var pConst = library.constants.named('p');

      expect(pConst.constantValue,
          equals('<a href="$linkPrefix/C/C.html">C</a>(1, 2, c: 3, d: 4)'));
    });

    test(
        'named parameters in a const invocation value can be specified anywhere',
        () async {
      var library = await bootPackageWithLibrary('''
class C {
  const C(int a, int b, {required int c, required int d});
}
const q = C(1, c: 2, 3, d: 4);
''');
      var qConst = library.constants.named('q');

      expect(qConst.constantValue,
          equals('<a href="$linkPrefix/C/C.html">C</a>(1, c: 2, 3, d: 4)'));
    });

    test('named parameters in a const invocation value can be specified first',
        () async {
      var library = await bootPackageWithLibrary('''
class C {
  const C(int a, int b, {required int c, required int d});
}
const r = C(c: 1, d: 2, 3, 4);
''');
      var rConst = library.constants.named('r');

      expect(rConst.constantValue,
          equals('<a href="$linkPrefix/C/C.html">C</a>(c: 1, d: 2, 3, 4)'));
    });
  }, skip: !namedArgumentsAnywhereAllowed);
}
