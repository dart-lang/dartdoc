// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:async/async.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart' as utils;

void main() {
  // We can not use ExperimentalFeature.releaseVersion or even
  // ExperimentalFeature.experimentalReleaseVersion as these are set to null
  // even when partial analyzer implementations are available, and are often
  // set too high after release.
  final constructorTearoffsAllowed =
      VersionRange(min: Version.parse('2.15.0-0'), includeMin: true);

  // We can not use ExperimentalFeature.releaseVersion or even
  // ExperimentalFeature.experimentalReleaseVersion as these are set to null
  // even when partial analyzer implementations are available.
  final namedArgumentsAnywhereAllowed =
      VersionRange(min: Version.parse('2.17.0-0'), includeMin: true);

  group('constructor-tearoffs', () {
    late Library library;
    const libraryName = 'constructor_tearoffs';

    final packageGraphMemo = AsyncMemoizer<PackageGraph>();
    Future<PackageGraph> bootstrapPackageGraph() =>
        packageGraphMemo.runOnce(() => utils.bootBasicPackage(
            d.dir(libraryName).io.path,
            pubPackageMetaProvider,
            PhysicalPackageConfigProvider(),
            additionalArguments: ['--no-link-to-remote']));

    setUp(() async {
      await d.createPackage(
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
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

class F<T> {
  F();

  F.alternative();
}

typedef Ft<T> = F<T>;

void func() {}
void funcTypeParams<T extends String, U extends num>(
    T something, U different) {}

const aFunc = func;
const aFuncParams = funcTypeParams;
const aFuncWithArgs = funcTypeParams<String, int>;
const aTearOffUnnamedConstructor = F.new;
const aTearOffUnnamedConstructorArgs = F<String>.new;
const aTearOffUnnamedConstructorTypedef = Fstring.new;
const aTearOffUnnamedConstructorArgsTypedef = Ft<String>.new;
const aTearOffNamedConstructor = F.alternative;
const aTearOffNamedConstructorArgs = F<int>.alternative;
'''),
        ],
      );

      library = (await bootstrapPackageGraph())
          .libraries
          .firstWhere((l) => l.name == libraryName);
    });

    test('non-generic function reference', () {
      var aFuncConstant =
          library.constants.firstWhere((c) => c.name == 'aFunc');
      expect(aFuncConstant.constantValue, equals('func'));
    });

    test('generic function reference', () {
      var aFuncParamsConstant =
          library.constants.firstWhere((c) => c.name == 'aFuncParams');
      expect(aFuncParamsConstant.constantValue, equals('funcTypeParams'));
    });

    test('generic function reference w/ type args', () {
      var aFuncWithArgs =
          library.constants.firstWhere((c) => c.name == 'aFuncWithArgs');
      expect(aFuncWithArgs.constantValue,
          equals('funcTypeParams&lt;String, int&gt;'));
    });

    test('named constructor reference', () {
      var aTearOffNamedConstructor = library.constants
          .firstWhere((c) => c.name == 'aTearOffNamedConstructor');
      expect(aTearOffNamedConstructor.constantValue, equals('F.alternative'));
    });

    test('named constructor reference w/ type args', () {
      var aTearOffNamedConstructorArgs = library.constants
          .firstWhere((c) => c.name == 'aTearOffNamedConstructorArgs');
      expect(aTearOffNamedConstructorArgs.constantValue,
          equals('F&lt;int&gt;.alternative'));
    });

    test('unnamed constructor reference', () {
      var aTearOffUnnamedConstructor = library.constants
          .firstWhere((c) => c.name == 'aTearOffUnnamedConstructor');
      expect(aTearOffUnnamedConstructor.constantValue, equals('F.new'));
    });

    test('unnamed constructor reference w/ type args', () {
      var aTearOffUnnamedConstructorArgs = library.constants
          .firstWhere((c) => c.name == 'aTearOffUnnamedConstructorArgs');
      expect(aTearOffUnnamedConstructorArgs.constantValue,
          equals('F&lt;String&gt;.new'));
    });

    test('unnamed typedef constructor reference', () {
      var aTearOffUnnamedConstructorTypedef = library.constants
          .firstWhere((c) => c.name == 'aTearOffUnnamedConstructorTypedef');
      expect(aTearOffUnnamedConstructorTypedef.constantValue,
          equals('Fstring.new'));
    });

    test('unnamed typedef constructor reference w/ type args', () {
      var aTearOffUnnamedConstructorArgsTypedef = library.constants
          .firstWhere((c) => c.name == 'aTearOffUnnamedConstructorArgsTypedef');
      expect(aTearOffUnnamedConstructorArgsTypedef.constantValue,
          equals('Ft&lt;String&gt;.new'));
    });

    test('constant rendering', () {}, skip: true);
  }, skip: !constructorTearoffsAllowed.allows(utils.platformVersion));

  group('named-arguments-anywhere', () {
    late Library library;
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
    const libraryName = 'named_arguments_anywhere';
    const linkPrefix = '$placeholder$libraryName';

    final _testPackageGraphExperimentsMemo = AsyncMemoizer<PackageGraph>();
    Future<PackageGraph> bootstrapPackageGraph() =>
        _testPackageGraphExperimentsMemo.runOnce(() => utils.bootBasicPackage(
            d.dir(libraryName).io.path,
            pubPackageMetaProvider,
            PhysicalPackageConfigProvider(),
            additionalArguments: ['--no-link-to-remote']));

    setUp(() async {
      await d.createPackage(
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
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

class C {
  const C(int a, int b, {required int c, required int d});
}

const p = C(1, 2, c: 3, d: 4);

const q = C(1, c: 2, 3, d: 4);

const r = C(c: 1, d: 2, 3, 4);
'''),
        ],
      );

      library = (await bootstrapPackageGraph())
          .libraries
          .firstWhere((l) => l.name == libraryName);
    });

    test('named parameters in a const invocation value can be specified last',
        () async {
      var pConst = library.constants.firstWhere((c) => c.name == 'p');

      expect(pConst.constantValue,
          equals('<a href="$linkPrefix/C/C.html">C</a>(1, 2, c: 3, d: 4)'));
    });

    test(
        'named parameters in a const invocation value can be specified anywhere',
        () async {
      var qConst = library.constants.firstWhere((c) => c.name == 'q');

      expect(qConst.constantValue,
          equals('<a href="$linkPrefix/C/C.html">C</a>(1, c: 2, 3, d: 4)'));
    });

    test('named parameters in a const invocation value can be specified first',
        () async {
      var rConst = library.constants.firstWhere((c) => c.name == 'r');

      expect(rConst.constantValue,
          equals('<a href="$linkPrefix/C/C.html">C</a>(c: 1, d: 2, 3, 4)'));
    });
  }, skip: !namedArgumentsAnywhereAllowed.allows(utils.platformVersion));
}
