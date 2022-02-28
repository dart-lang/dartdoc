// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  const libraryName = 'enums';

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

  group('an enum', () {
    const libraryName = 'enums';
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
    const linkPrefix = '$placeholder$libraryName';

    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(libraryName);
    });

    test('is found on the enclosing library', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      expect(library.publicEnums, isNotEmpty);
    });

    test('has a fully qualified names', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var eEnum = library.enums.named('E');

      expect(eEnum.fullyQualifiedName, equals('enums.E'));
    });

    test('is presented with a linked name', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var eEnum = library.enums.named('E');

      expect(eEnum.linkedName, equals('<a href="$linkPrefix/E.html">E</a>'));
    });

    test('has a library as its enclosing element', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var eEnum = library.enums.named('E');

      expect(eEnum.enclosingElement!.name, 'enums');
    });

    test('has the correct number of constants', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var eEnum = library.enums.named('E');

      // Three enum values, plus the `values` constant field.
      expect(eEnum.constantFields, hasLength(4));
    });

    test("has a (synthetic) 'values' constant", () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var valuesField =
          library.enums.named('E').constantFields.named('values') as EnumField;
      expect(valuesField.constantValue,
          equals(EnumFieldRendererHtml().renderValue(valuesField)));
      expect(valuesField.documentation, startsWith('A constant List'));
    });

    test("has an 'index' getter, which is linked", () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var eEnum = library.enums.named('E');

      expect(eEnum.instanceFields.map((f) => f.name), contains('index'));
      expect(
        eEnum.instanceFields.named('index').linkedName,
        '<a href="https://api.dart.dev/stable/2.9.0/dart-core/Enum/index.html">index</a>',
      );
    });

    test("'toString' is treated specialty", () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var eEnum = library.enums.named('E');
      var toStringMethod = eEnum.instanceMethods.named('toString');
      expect(toStringMethod.characterLocation, isNotNull);
      expect(toStringMethod.characterLocation.toString(),
          equals(eEnum.characterLocation.toString()));
    });

    test('value does not link anywhere', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var oneValue =
          library.enums.named('E').constantFields.named('one') as EnumField;
      expect(oneValue.linkedName, 'one');
      expect(oneValue.constantValue,
          equals(EnumFieldRendererHtml().renderValue(oneValue)));
    });

    test('values have correct indices', () async {
      var library = await bootPackageWithLibrary('enum E { one, two, three }');
      var oneValue =
          library.enums.named('E').constantFields.named('one') as EnumField;
      var twoValue =
          library.enums.named('E').constantFields.named('two') as EnumField;
      var threeValue =
          library.enums.named('E').constantFields.named('three') as EnumField;

      expect(oneValue.constantValue, equals('const E(0)'));
      expect(twoValue.constantValue, equals('const E(1)'));
      expect(threeValue.constantValue, equals('const E(2)'));
    });

    test('has annotations', () async {
      var library = await bootPackageWithLibrary('''
class C {
  const C();
}

@C()
enum E { one, two, three }
''');
      var eEnum = library.enums.named('E');

      expect(eEnum.hasAnnotations, true);
      expect(eEnum.annotations, hasLength(1));
      expect(eEnum.annotations.single.linkedName,
          '<a href="$linkPrefix/C-class.html">C</a>');
    });

    test('has a doc comment', () async {
      var library = await bootPackageWithLibrary('''
/// Doc comment for [E].
enum E { one, two, three }
''');
      var eEnum = library.enums.named('E');

      expect(eEnum.hasDocumentationComment, true);
      expect(eEnum.documentationComment, '/// Doc comment for [E].');
    });

    test('value has a doc comment', () async {
      var library = await bootPackageWithLibrary('''
enum E {
  /// Doc comment for [E.one].
  one,
  two,
  three
}
''');
      var one = library.enums.named('E').constantFields.named('one');

      expect(one.hasDocumentationComment, true);
      expect(one.documentationComment, '/// Doc comment for [E.one].');
    });
  });

  group('enhanced enums', () {
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
    const linkPrefix = '$placeholder$libraryName';

    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(
        libraryName,
        pubspec: '''
name: enhanced_enums
version: 0.0.1
environment:
  sdk: '>=2.17.0-0 <3.0.0'
''',
        analysisOptions: '''
analyzer:
  enable-experiment:
    - enhanced-enums
''',
      );
    });

    test('an enum is presented with a linked name', () async {
      var library = await bootPackageWithLibrary('''
class C<T> {}

enum E<T> implements C<T> { one, two, three; }
''');
      var eEnum = library.enums.named('E');

      expect(eEnum.linkedName, '<a href="$linkPrefix/E.html">E</a>');
    });

    test('a generic enum is presented with linked type parameters', () async {
      var library = await bootPackageWithLibrary('''
class C<T> {}

enum E<T> implements C<T> { one, two, three; }
''');
      var eEnum = library.enums.named('E');

      expect(
        eEnum.linkedGenericParameters,
        '<span class="signature">&lt;<wbr><span class="type-parameter">T</span>&gt;</span>',
      );
    });

    test("an enhanced enum's methods are documented", () async {
      var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Doc comment.
  int method1(String p) => 7;
}
''');
      var method1 = library.enums.named('E').instanceMethods.named('method1');

      expect(method1.isInherited, false);
      expect(method1.isOperator, false);
      expect(method1.isStatic, false);
      expect(method1.isCallable, true);
      expect(method1.isDocumented, true);
      expect(
        method1.linkedName,
        '<a href="$linkPrefix/E/method1.html">method1</a>',
      );
      expect(method1.documentationComment, '/// Doc comment.');
    });

    test("an enhanced enum's operators are documented", () async {
      var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Greater than.
  bool operator >(E other) => index > other.index;

  /// Less than.
  bool operator <(E other) => index < other.index;
}
''');
      var greaterThan =
          library.enums.named('E').instanceOperators.named('operator >');

      expect(greaterThan.isInherited, false);
      expect(greaterThan.isOperator, true);
      expect(greaterThan.isStatic, false);
      expect(greaterThan.isCallable, true);
      expect(greaterThan.isDocumented, true);
      expect(
        greaterThan.linkedName,
        '<a href="$linkPrefix/E/operator_greater.html">operator ></a>',
      );
      expect(greaterThan.documentationComment, '/// Greater than.');

      var lessThan =
          library.enums.named('E').instanceOperators.named('operator <');

      expect(lessThan.isInherited, false);
      expect(lessThan.isOperator, true);
      expect(lessThan.isStatic, false);
      expect(lessThan.isCallable, true);
      expect(lessThan.isDocumented, true);
      expect(
        lessThan.linkedName,
        // TODO(srawlins): I think this smells... escape HTML.
        '<a href="$linkPrefix/E/operator_less.html">operator <</a>',
      );
      expect(lessThan.documentationComment, '/// Less than.');
    });

    test('an enum is presented with linked interfaces', () async {
      var library = await bootPackageWithLibrary('''
class C<T> {}
class D {}

enum E<T> implements C<T>, D { one, two, three; }
''');
      var eEnum = library.enums.named('E');

      expect(eEnum.interfaces, hasLength(2));
      expect(eEnum.interfaces.map((i) => i.name), equals(['C', 'D']));
    });

    // TODO(srawlins): Add rendering tests.
    // * Fix interfaces test.
    // * Add tests for rendered supertypes HTML.
    // * Add tests for rendered interfaces HTML.
    // * Add tests for rendered mixins HTML.
    // * Add tests for rendered static members.
    // * Add tests for rendered fields.
    // * Add tests for rendered getters, setters, operators.
    // * Add tests for rendered field pages.
    // * Add tests for rendered generic enum values.
    // * Add tests for rendered constructors.

    // TODO(srawlins): Add referencing tests (`/// [Enum.method]` etc.)
    // * Add tests for referencing enum static members.
    // * Add tests for referencing enum getters, setters, operators, methods.
    // * Add tests for referencing constructors.
  }, skip: !enhancedEnumsAllowed);
}
