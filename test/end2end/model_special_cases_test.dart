// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This test library handles checks against the model for configurations
/// that require different PackageGraph configurations.  Since those
/// take a long time to initialize, isolate them here to keep model_test
/// fast.
library dartdoc.model_special_cases_test;

import 'dart:io';

import 'package:async/async.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../src/utils.dart' as utils;

final String _platformVersionString = Platform.version.split(' ').first;
final Version _platformVersion = Version.parse(_platformVersionString);

final _testPackageGraphExperimentsMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get _testPackageGraphExperiments =>
    _testPackageGraphExperimentsMemo.runOnce(() => utils.bootBasicPackage(
            'testing/test_package_experiments',
            pubPackageMetaProvider,
            PhysicalPackageConfigProvider(),
            additionalArguments: [
              '--enable-experiment',
              'non-nullable,nonfunction-type-aliases',
              '--no-link-to-remote'
            ]));

final _testPackageGraphGinormousMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get _testPackageGraphGinormous =>
    _testPackageGraphGinormousMemo.runOnce(() => utils.bootBasicPackage(
            'testing/test_package',
            pubPackageMetaProvider,
            PhysicalPackageConfigProvider(),
            excludeLibraries: [
              'css',
              'code_in_commnets',
              'excluded'
            ],
            additionalArguments: [
              '--auto-include-dependencies',
              '--no-link-to-remote'
            ]));

final _testPackageGraphSdkMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get _testPackageGraphSdk =>
    _testPackageGraphSdkMemo.runOnce(_bootSdkPackage);

Future<PackageGraph> _bootSdkPackage() async {
  return PubPackageBuilder(
          await utils.contextFromArgv(
              ['--input', pubPackageMetaProvider.defaultSdkDir.path],
              pubPackageMetaProvider),
          pubPackageMetaProvider,
          PhysicalPackageConfigProvider())
      .buildPackageGraph();
}

void main() {
  var sdkDir = pubPackageMetaProvider.defaultSdkDir;

  if (sdkDir == null) {
    print('Warning: unable to locate the Dart SDK.');
    exit(1);
  }

  final _generalizedTypedefsAllowed =
      VersionRange(min: Version.parse('2.13.0-0'), includeMin: true);
  final _genericMetadataAllowed =
      VersionRange(min: Version.parse('2.13.0-0'), includeMin: true);
  final _tripleShiftAllowed =
      VersionRange(min: Version.parse('2.13.0-0'), includeMin: true);

  // Experimental features not yet enabled by default.  Move tests out of this
  // block when the feature is enabled by default.
  group('Experiments', () {
    group('triple-shift', () {
      Library tripleShift;
      Class C, E, F;
      Extension ShiftIt;
      Operator classShift, extensionShift;
      Field constantTripleShifted;

      setUpAll(() async {
        tripleShift = (await _testPackageGraphExperiments)
            .libraries
            .firstWhere((l) => l.name == 'triple_shift');
        C = tripleShift.classes.firstWhere((c) => c.name == 'C');
        E = tripleShift.classes.firstWhere((c) => c.name == 'E');
        F = tripleShift.classes.firstWhere((c) => c.name == 'F');
        ShiftIt = tripleShift.extensions.firstWhere((e) => e.name == 'ShiftIt');
        classShift =
            C.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
        extensionShift =
            ShiftIt.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
        constantTripleShifted = C.constantFields
            .firstWhere((f) => f.name == 'constantTripleShifted');
      });

      test('constants with triple shift render correctly', () {
        expect(constantTripleShifted.constantValue, equals('3 &gt;&gt;&gt; 5'));
      });

      test('operators exist and are named correctly', () {
        expect(classShift.name, equals('operator >>>'));
        expect(extensionShift.name, equals('operator >>>'));
      });

      test(
          'inheritance and overriding of triple shift operators works correctly',
          () {
        var tripleShiftE =
            E.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
        var tripleShiftF =
            F.instanceOperators.firstWhere((o) => o.name.contains('>>>'));

        expect(tripleShiftE.isInherited, isTrue);
        expect(tripleShiftE.canonicalModelElement, equals(classShift));
        expect(tripleShiftE.modelType.returnType.name, equals('C'));
        expect(tripleShiftF.isInherited, isFalse);
        expect(tripleShiftF.modelType.returnType.name, equals('F'));
      });
    }, skip: !_tripleShiftAllowed.allows(_platformVersion));

    group('generic metadata', () {
      Library genericMetadata;
      TopLevelVariable f;
      Class C;
      Method mp, mn;

      setUpAll(() async {
        genericMetadata = (await _testPackageGraphExperiments)
            .libraries
            .firstWhere((l) => l.name == 'generic_metadata');
        f = genericMetadata.properties.firstWhere((p) => p.name == 'f');
        C = genericMetadata.classes.firstWhere((c) => c.name == 'C');
        mp = C.instanceMethods.firstWhere((m) => m.name == 'mp');
        mn = C.instanceMethods.firstWhere((m) => m.name == 'mn');
      });

      test('Verify type arguments on annotations renders, including parameters',
          () {
        var ab0 =
            '@<a href="%%__HTMLBASE_dartdoc_internal__%%generic_metadata/A-class.html">A</a><span class="signature">&lt;<wbr><span class="type-parameter"><a href="%%__HTMLBASE_dartdoc_internal__%%generic_metadata/B.html">B</a></span>&gt;</span>(0)';

        expect(genericMetadata.annotations.first.linkedNameWithParameters,
            equals(ab0));
        expect(f.annotations.first.linkedNameWithParameters, equals(ab0));
        expect(C.annotations.first.linkedNameWithParameters, equals(ab0));
        expect(
            C.typeParameters.first.annotations.first.linkedNameWithParameters,
            equals(ab0));
        expect(
            mp.parameters
                .map((p) => p.annotations.first.linkedNameWithParameters),
            everyElement(equals(ab0)));
        expect(
            mn.parameters
                .map((p) => p.annotations.first.linkedNameWithParameters),
            everyElement(equals(ab0)));

        expect(genericMetadata.features.map((f) => f.linkedNameWithParameters),
            contains(ab0));
        expect(
            f.features.map((f) => f.linkedNameWithParameters), contains(ab0));
        expect(
            C.features.map((f) => f.linkedNameWithParameters), contains(ab0));
        expect(
            C.typeParameters.first.features
                .map((f) => f.linkedNameWithParameters),
            contains(ab0));
        expect(
            mp.parameters
                .map((p) => p.features.map((f) => f.linkedNameWithParameters)),
            everyElement(contains(ab0)));
        expect(
            mn.parameters
                .map((p) => p.features.map((f) => f.linkedNameWithParameters)),
            everyElement(contains(ab0)));
      });
    }, skip: !_genericMetadataAllowed.allows(_platformVersion));

    group('generalized typedefs', () {
      Library generalizedTypedefs;
      Typedef T0, T1, T2, T3, T4, T5, T6, T7;
      Class C, C2;

      setUpAll(() async {
        generalizedTypedefs = (await _testPackageGraphExperiments)
            .libraries
            .firstWhere((l) => l.name == 'generalized_typedefs');
        T0 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T0');
        T1 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T1');
        T2 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T2');
        T3 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T3');
        T4 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T4');
        T5 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T5');
        T6 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T6');
        T7 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T7');
        C = generalizedTypedefs.classes.firstWhere((c) => c.name == 'C');
        C2 = generalizedTypedefs.classes.firstWhere((c) => c.name == 'C2');
      });

      void expectTypedefs(Typedef t, String modelTypeToString,
          Iterable<String> genericParameters) {
        expect(t.modelType.toString(), equals(modelTypeToString));
        expect(t.genericTypeParameters.map((p) => p.toString()),
            orderedEquals(genericParameters));
      }

      void expectAliasedTypeName(AliasedElementType n, expected) {
        expect(n.aliasElement.name, expected);
      }

      test('typedef references display aliases', () {
        var g = C.instanceMethods.firstWhere((m) => m.name == 'g');

        var c = C2.allFields.firstWhere((f) => f.name == 'c');
        var d = C2.instanceMethods.firstWhere((f) => f.name == 'd');

        expectAliasedTypeName(c.modelType, equals('T1'));
        expectAliasedTypeName(d.modelType.returnType, equals('T2'));
        expectAliasedTypeName(d.parameters.first.modelType, equals('T3'));
        expectAliasedTypeName(d.parameters.last.modelType, equals('T4'));

        expectAliasedTypeName(g.modelType.returnType, equals('T1'));
        expectAliasedTypeName(
            g.modelType.parameters.first.modelType, equals('T2'));
        expectAliasedTypeName(
            g.modelType.parameters.last.modelType, equals('T3'));
      });

      test('typedef references to special types work', () {
        var a = generalizedTypedefs.properties.firstWhere((p) => p.name == 'a');
        var b = C2.allFields.firstWhere((f) => f.name == 'b');
        var f = C.allFields.firstWhere((f) => f.name == 'f');
        expectAliasedTypeName(a.modelType, equals('T0'));
        expectAliasedTypeName(b.modelType, equals('T0'));
        expectAliasedTypeName(f.modelType, equals('T0'));
      }, skip: 'dart-lang/sdk#45291');

      test('basic non-function typedefs work', () {
        expectTypedefs(T0, 'void', []);
        expectTypedefs(T1, 'Function', []);
        expectTypedefs(T2, 'List<X>', ['out X']);
        expectTypedefs(T3, 'Map<X, Y>', ['out X', 'out Y']);
        expectTypedefs(T4, 'void Function()', []);
        expectTypedefs(T5, 'X Function(X, {X name})', ['inout X']);
        expectTypedefs(T6, 'X Function(Y, [Map<Y, Y>])', ['out X', 'in Y']);
        expectTypedefs(T7, 'X Function(Y, [Map<Y, Y>])',
            ['out X extends String', 'in Y extends List<X>']);
      });
    }, skip: (!_generalizedTypedefsAllowed.allows(_platformVersion)));
  });

  group('HTML Injection when allowed', () {
    Class htmlInjection;
    Method injectSimpleHtml;
    Method injectHtmlFromTool;

    PackageGraph injectionPackageGraph;
    Library injectionExLibrary;

    setUpAll(() async {
      injectionPackageGraph = await utils.bootBasicPackage(
          'testing/test_package',
          pubPackageMetaProvider,
          PhysicalPackageConfigProvider(),
          excludeLibraries: ['css', 'code_in_comments', 'excluded'],
          additionalArguments: ['--inject-html']);

      injectionExLibrary =
          injectionPackageGraph.libraries.firstWhere((lib) => lib.name == 'ex');

      htmlInjection = injectionExLibrary.classes
          .firstWhere((c) => c.name == 'HtmlInjection');
      injectSimpleHtml = htmlInjection.instanceMethods
          .firstWhere((m) => m.name == 'injectSimpleHtml');
      injectHtmlFromTool = htmlInjection.instanceMethods
          .firstWhere((m) => m.name == 'injectHtmlFromTool');
      injectionPackageGraph.allLocalModelElements
          .forEach((m) => m.documentation);
    });

    test('can inject HTML', () {
      expect(injectSimpleHtml.documentationAsHtml,
          contains('   <div style="opacity: 0.5;">[HtmlInjection]</div>'));
    });
    test('can inject HTML from tool', () {
      var envLine = RegExp(r'^Env: \{', multiLine: true);
      expect(envLine.allMatches(injectHtmlFromTool.documentation).length,
          equals(2));
      var argLine = RegExp(r'^Args: \[', multiLine: true);
      expect(argLine.allMatches(injectHtmlFromTool.documentation).length,
          equals(2));
      expect(
          injectHtmlFromTool.documentation,
          contains(
              'Invokes more than one tool in the same comment block, and injects HTML.'));
      expect(injectHtmlFromTool.documentationAsHtml,
          contains('<div class="title">Title</div>'));
      expect(injectHtmlFromTool.documentationAsHtml,
          isNot(contains('{@inject-html}')));
      expect(injectHtmlFromTool.documentationAsHtml,
          isNot(contains('{@end-inject-html}')));
    });
    test('tool outputs a macro which outputs injected HTML', () {
      var ToolPrintingMacroWhichInjectsHtml = injectionExLibrary.allClasses
          .firstWhere((c) => c.name == 'ToolPrintingMacroWhichInjectsHtml');
      var a = ToolPrintingMacroWhichInjectsHtml.instanceFields
          .firstWhere((m) => m.name == 'a');
      expect(a.documentationAsHtml,
          contains('<p>Text.</p>\n<p><div class="title">Title</div></p>'));
      var b = ToolPrintingMacroWhichInjectsHtml.instanceFields
          .firstWhere((m) => m.name == 'b');
      expect(b.documentationAsHtml,
          contains('<p>Text.</p>\n<p><div class="title">Title</div></p>'));
    });
  });

  group('Missing and Remote', () {
    PackageGraph ginormousPackageGraph;

    setUpAll(() async {
      ginormousPackageGraph = await _testPackageGraphGinormous;
    });

    test('Verify that SDK libraries are not canonical when missing', () {
      expect(ginormousPackageGraph.publicPackages, isNotEmpty);
    });

    test(
        'Verify that autoIncludeDependencies makes everything document locally',
        () {
      expect(ginormousPackageGraph.packages.map((p) => p.documentedWhere),
          everyElement((x) => x == DocumentLocation.local));
    });

    test('Verify that ginormousPackageGraph takes in the SDK', () {
      expect(
          ginormousPackageGraph.packages
              .firstWhere((p) => p.isSdk)
              .libraries
              .length,
          greaterThan(1));
      expect(
          ginormousPackageGraph.packages
              .firstWhere((p) => p.isSdk)
              .documentedWhere,
          equals(DocumentLocation.local));
    });
  });

  group('Category', () {
    PackageGraph ginormousPackageGraph;

    setUpAll(() async {
      ginormousPackageGraph = await _testPackageGraphGinormous;
    });

    test(
        'Verify auto-included dependencies do not use default package category definitions',
        () {
      var IAmAClassWithCategories = ginormousPackageGraph.localPackages
          .firstWhere((Package p) => p.name == 'test_package_imported')
          .publicLibraries
          .firstWhere((Library l) => l.name == 'categoriesExported')
          .publicClasses
          .firstWhere((Class c) => c.name == 'IAmAClassWithCategories');
      expect(IAmAClassWithCategories.hasCategoryNames, isTrue);
      expect(IAmAClassWithCategories.categories.length, equals(1));
      expect(
          IAmAClassWithCategories.categories.first.name, equals('Excellent'));
      expect(IAmAClassWithCategories.displayedCategories, isEmpty);
    });

    // For flutter, we allow reexports to pick up categories from the package
    // they are exposed in.
    test('Verify that reexported classes pick up categories', () {
      var IAmAClassWithCategoriesReexport = ginormousPackageGraph.localPackages
          .firstWhere((Package p) => p.name == 'test_package')
          .publicLibraries
          .firstWhere((Library l) => l.name == 'fake')
          .publicClasses
          .firstWhere((Class c) => c.name == 'IAmAClassWithCategories');
      expect(IAmAClassWithCategoriesReexport.hasCategoryNames, isTrue);
      expect(IAmAClassWithCategoriesReexport.categories.length, equals(1));
      expect(IAmAClassWithCategoriesReexport.categories.first.name,
          equals('Superb'));
      expect(IAmAClassWithCategoriesReexport.displayedCategories, isNotEmpty);
      var category = IAmAClassWithCategoriesReexport.displayedCategories.first;
      expect(category.categoryIndex, equals(0));
      expect(category.isDocumented, isTrue);
    });

    test('Verify that multiple categories work correctly', () {
      var fakeLibrary = ginormousPackageGraph.localPackages
          .firstWhere((Package p) => p.name == 'test_package')
          .publicLibraries
          .firstWhere((Library l) => l.name == 'fake');
      var BaseForDocComments = fakeLibrary.publicClasses
          .firstWhere((Class c) => c.name == 'BaseForDocComments');
      var SubForDocComments = fakeLibrary.publicClasses
          .firstWhere((Class c) => c.name == 'SubForDocComments');
      expect(BaseForDocComments.hasCategoryNames, isTrue);
      // Display both, with the correct order and display name.
      expect(BaseForDocComments.displayedCategories.length, equals(2));
      expect(
          BaseForDocComments.displayedCategories.first.name, equals('Superb'));
      expect(
          BaseForDocComments.displayedCategories.last.name, equals('Unreal'));
      // Subclasses do not inherit category information.
      expect(SubForDocComments.hasCategoryNames, isTrue);
      expect(SubForDocComments.categories, hasLength(1));
      expect(SubForDocComments.categories.first.isDocumented, isFalse);
      expect(SubForDocComments.displayedCategories, isEmpty);
    });
  });

  group('Package', () {
    PackageGraph sdkAsPackageGraph;

    setUpAll(() async {
      sdkAsPackageGraph = await _testPackageGraphSdk;
    });

    // Analyzer's MockSdk's html library doesn't conform to the expectations
    // of this test.
    test('Verify Interceptor is hidden from inheritance in docs', () {
      var htmlLibrary =
          sdkAsPackageGraph.libraries.singleWhere((l) => l.name == 'dart:html');
      var eventTarget =
          htmlLibrary.allClasses.singleWhere((c) => c.name == 'EventTarget');
      var hashCode = eventTarget.publicInstanceFields
          .singleWhere((f) => f.name == 'hashCode');
      var objectModelElement =
          sdkAsPackageGraph.specialClasses[SpecialClass.object];
      // If this fails, EventTarget might have been changed to no longer
      // inherit from Interceptor.  If that's true, adjust test case to
      // another class that does.
      expect(hashCode.inheritance.any((c) => c.name == 'Interceptor'), isTrue);
      // If EventTarget really does start implementing hashCode, this will
      // fail.
      expect(hashCode.href,
          equals('${htmlBasePlaceholder}dart-core/Object/hashCode.html'));
      expect(hashCode.canonicalEnclosingContainer, equals(objectModelElement));
      expect(
          eventTarget.publicSuperChainReversed
              .any((et) => et.name == 'Interceptor'),
          isFalse);
    });
  });
}
