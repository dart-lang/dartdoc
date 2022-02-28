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
  group('parameters', () {
    late Library library;

    // It is expensive (~10s) to compute a package graph, even skipping
    // unreachable Dart SDK libraries, so we set up this package once.
    setUpAll(() async {
      const libraryName = 'super_parameters';
      var packageMetaProvider = testPackageMetaProvider;

      var packagePath = await d.createPackage(
        libraryName,
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

class C {
  int? f;

  C.requiredPositional(this.f);
  C.optionalPositional([this.f]);
  C.defaultValue([this.f = 0]);
  C.requiredNamed({required this.f});
  C.named({this.f});
  C.namedWithDefault({this.f = 0});
}
'''),
        ],
        resourceProvider:
            packageMetaProvider.resourceProvider as MemoryResourceProvider,
      );
      var packageConfigProvider =
          getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
      packageConfigProvider.addPackageToConfigFor(
          packagePath, libraryName, Uri.file('$packagePath/'));

      var packageGraph = await bootBasicPackage(
        packagePath,
        packageMetaProvider,
        packageConfigProvider,
      );
      library = packageGraph.libraries.named(libraryName);
    });

    test(
        'required positional field formal parameters are presented with a '
        'linked type', () async {
      var requiredPositional = library.constructor('C.requiredPositional');

      expect(requiredPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredPositional-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
        </span>
      '''));
    });

    test(
        'optional positional field formal parameters are presented with a '
        'linked type', () async {
      var optionalPositional = library.constructor('C.optionalPositional');

      expect(optionalPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="optionalPositional-param-f">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          \]
        </span>
      '''));
    });

    test(
        'optional positional field formal parameters, with a default value, '
        'are presented with a linked type', () async {
      var defaultValue = library.constructor('C.defaultValue');

      expect(defaultValue.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="defaultValue-param-f">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          =
          <span class="default-value">0</span>
          \]
        </span>
      '''));
    });

    test(
        'required named field formal parameters are presented with a '
        'linked type', () async {
      var requiredNamed = library.constructor('C.requiredNamed');

      expect(requiredNamed.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredNamed-param-f">
          \{
          <span>required</span>
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          \}
        </span>
      '''));
    });

    test('named field formal parameters are presented with a linked type',
        () async {
      var named = library.constructor('C.named');

      expect(named.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="named-param-f">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          \}
        </span>
      '''));
    });

    test(
        'named field formal parameters, with a default value, are presented '
        'with a linked type', () async {
      var namedWithDefault = library.constructor('C.namedWithDefault');

      expect(namedWithDefault.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="namedWithDefault-param-f">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          =
          <span class="default-value">0</span>
          \}
        </span>
      '''));
    });
  });

  group('super-parameters', () {
    late Library library;

    // It is expensive (~10s) to compute a package graph, even skipping
    // unreachable Dart SDK libraries, so we set up this package once.
    setUpAll(() async {
      const libraryName = 'super_parameters';

      await d.createPackage(
        libraryName,
        pubspec: '''
name: super_parameters
version: 0.0.1
environment:
  sdk: '>=2.17.0-0 <3.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - super-parameters
''',
        libFiles: [
          d.file('lib.dart', '''
library $libraryName;

class C {
  C.requiredPositional(int a);
  C.optionalPositional([int? a]);
  C.defaultValue([int a = 0]);
  C.requiredNamed({required int a});
  C.named({int? a});
  C.namedWithDefault({int a = 0});

  int f;
  C.fieldFormal(this.f);

  C.positionalNum(num g);
}

class D extends C {
  D.requiredPositional(super.a) : super.requiredPositional();
  D.optionalPositional([super.a]) : super.optionalPositional();
  D.defaultValue([super.a = 0]) : super.defaultValue();
  D.requiredNamed({required super.a}) : super.requiredNamed();
  D.named({super.a}) : super.named();
  D.namedWithDefault({int a = 0}) : super.namedWithDefault();

  D.fieldFormal(super.f) : super.fieldFormal();
  D.positionalNum(int super.g) : super.positionalNum();
}

class E extends D {
  E.superIsSuper(super.a) : super.requiredPositional();
}
'''),
        ],
      );

      var packageGraph = await bootBasicPackage(
        d.dir(libraryName).io.path,
        pubPackageMetaProvider,
        PhysicalPackageConfigProvider(),
      );
      library = packageGraph.libraries.named(libraryName);
    });

    test(
        'required positional super-parameters are presented with a linked type',
        () async {
      var requiredPositional = library.constructor('D.requiredPositional');

      expect(requiredPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredPositional-param-a">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
        </span>
      '''));
    });

    test(
        'optional positional super-parameters are presented with a linked type',
        () async {
      var optionalPositional = library.constructor('D.optionalPositional');

      expect(optionalPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="optionalPositional-param-a">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">a</span>
          \]
        </span>
      '''));
    });

    test(
        'optional positional super-parameters, with a default, are presented '
        'with a linked type', () async {
      var defaultValue = library.constructor('D.defaultValue');

      expect(defaultValue.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="defaultValue-param-a">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          =
          <span class="default-value">0</span>
          \]
        </span>
      '''));
    });

    test('required named super-parameters are presented with a linked type',
        () async {
      var requiredNamed = library.constructor('D.requiredNamed');

      expect(requiredNamed.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredNamed-param-a">
          \{
          <span>required</span>
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          \}
        </span>
      '''));
    });

    test('named super-parameters are presented with a linked type', () async {
      var named = library.constructor('D.named');

      expect(named.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="named-param-a">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">a</span>
          \}
        </span>
      '''));
    });

    test(
        'named super-parameters, with a default, are presented with a linked '
        'type', () async {
      var namedWithDefault = library.constructor('D.namedWithDefault');

      expect(namedWithDefault.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="namedWithDefault-param-a">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          =
          <span class="default-value">0</span>
          \}
        </span>
      '''));
    });

    test('super-constructor parameter is field formal', () async {
      var fieldFormal = library.constructor('D.fieldFormal');

      expect(fieldFormal.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="fieldFormal-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">f</span>
        </span>
      '''));
    });

    test('super-constructor parameter is super-parameter', () async {
      var superIsSuper = library.constructor('E.superIsSuper');

      expect(superIsSuper.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="superIsSuper-param-a">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
        </span>
      '''));
    });

    test('parameter is subtype of super-constructor parameter', () async {
      var positionalNum = library.constructor('D.positionalNum');

      expect(positionalNum.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="positionalNum-param-g">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">g</span>
        </span>
      '''));
    });
  }, skip: !superParametersAllowed);
}

extension on Library {
  Constructor constructor(String name) {
    var className = name.split('.').first;
    return classes
        .firstWhere((c) => c.name == className)
        .constructors
        .firstWhere((c) => c.name == name);
  }
}
