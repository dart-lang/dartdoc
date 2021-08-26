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
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../src/utils.dart' as utils;
import '../src/utils.dart';

final _testPackageGraphExperimentsMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get _testPackageGraphExperiments =>
    _testPackageGraphExperimentsMemo.runOnce(() => utils.bootBasicPackage(
        'testing/test_package_experiments',
        pubPackageMetaProvider,
        PhysicalPackageConfigProvider(),
        additionalArguments: ['--no-link-to-remote']));

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

  // We can not use ExperimentalFeature.releaseVersion or even
  // ExperimentalFeature.experimentalReleaseVersion as these are set to null
  // even when partial analyzer implementations are available, and are often
  // set too high after release.
  final _constructorTearoffsAllowed =
      VersionRange(min: Version.parse('2.15.0-0'), includeMin: true);

  // Experimental features not yet enabled by default.  Move tests out of this
  // block when the feature is enabled by default.
  group('Experiments', () {
    group('constructor-tearoffs', () {
      Library constructorTearoffs;
      Class A, B, C, D, E, F;
      Mixin M;
      Typedef At, Bt, Ct, Et, Ft, NotAClass;
      Constructor Anew, Bnew, Cnew, Dnew, Enew, Fnew;

      setUpAll(() async {
        constructorTearoffs = (await _testPackageGraphExperiments)
            .libraries
            .firstWhere((l) => l.name == 'constructor_tearoffs');
        A = constructorTearoffs.classes.firstWhere((c) => c.name == 'A');
        B = constructorTearoffs.classes.firstWhere((c) => c.name == 'B');
        C = constructorTearoffs.classes.firstWhere((c) => c.name == 'C');
        D = constructorTearoffs.classes.firstWhere((c) => c.name == 'D');
        E = constructorTearoffs.classes.firstWhere((c) => c.name == 'E');
        F = constructorTearoffs.classes.firstWhere((c) => c.name == 'F');
        M = constructorTearoffs.mixins.firstWhere((m) => m.name == 'M');
        At = constructorTearoffs.typedefs.firstWhere((t) => t.name == 'At');
        Bt = constructorTearoffs.typedefs.firstWhere((t) => t.name == 'Bt');
        Ct = constructorTearoffs.typedefs.firstWhere((t) => t.name == 'Ct');
        Et = constructorTearoffs.typedefs.firstWhere((t) => t.name == 'Et');
        Ft = constructorTearoffs.typedefs.firstWhere((t) => t.name == 'Ft');
        NotAClass = constructorTearoffs.typedefs
            .firstWhere((t) => t.name == 'NotAClass');
        Anew = A.unnamedConstructor;
        Bnew = B.unnamedConstructor;
        Cnew = C.unnamedConstructor;
        Dnew = D.unnamedConstructor;
        Enew = E.unnamedConstructor;
        Fnew = F.unnamedConstructor;
      });

      test('smoke test', () {
        expect(A, isNotNull);
        expect(B, isNotNull);
        expect(C, isNotNull);
        expect(D, isNotNull);
        expect(E, isNotNull);
        expect(F, isNotNull);
        expect(M, isNotNull);
        expect(At, isNotNull);
        expect(Bt, isNotNull);
        expect(Ct, isNotNull);
        expect(Et, isNotNull);
        expect(Ft, isNotNull);
        expect(NotAClass, isNotNull);
        expect(Anew, isNotNull);
        expect(Bnew, isNotNull);
        expect(Cnew, isNotNull);
        expect(Dnew, isNotNull);
        expect(Enew, isNotNull);
        expect(Fnew, isNotNull);
      });

      test('reference regression', () {
        expect(referenceLookup(constructorTearoffs, 'A.A'),
            equals(MatchingLinkResult(Anew)));
        expect(referenceLookup(constructorTearoffs, 'new A()'),
            equals(MatchingLinkResult(Anew)));
        expect(referenceLookup(constructorTearoffs, 'A()'),
            equals(MatchingLinkResult(Anew)));
        expect(referenceLookup(constructorTearoffs, 'B.B'),
            equals(MatchingLinkResult(Bnew)));
        expect(referenceLookup(constructorTearoffs, 'new B()'),
            equals(MatchingLinkResult(Bnew)));
        expect(referenceLookup(constructorTearoffs, 'B()'),
            equals(MatchingLinkResult(Bnew)));
        expect(referenceLookup(constructorTearoffs, 'C.C'),
            equals(MatchingLinkResult(Cnew)));
        expect(referenceLookup(constructorTearoffs, 'new C()'),
            equals(MatchingLinkResult(Cnew)));
        expect(referenceLookup(constructorTearoffs, 'C()'),
            equals(MatchingLinkResult(Cnew)));
        expect(referenceLookup(constructorTearoffs, 'D.D'),
            equals(MatchingLinkResult(Dnew)));
        expect(referenceLookup(constructorTearoffs, 'new D()'),
            equals(MatchingLinkResult(Dnew)));
        expect(referenceLookup(constructorTearoffs, 'D()'),
            equals(MatchingLinkResult(Dnew)));
        expect(referenceLookup(constructorTearoffs, 'E.E'),
            equals(MatchingLinkResult(Enew)));
        expect(referenceLookup(constructorTearoffs, 'new E()'),
            equals(MatchingLinkResult(Enew)));
        expect(referenceLookup(constructorTearoffs, 'E()'),
            equals(MatchingLinkResult(Enew)));
        expect(referenceLookup(constructorTearoffs, 'F.F'),
            equals(MatchingLinkResult(Fnew)));
        expect(referenceLookup(constructorTearoffs, 'new F()'),
            equals(MatchingLinkResult(Fnew)));
        expect(referenceLookup(constructorTearoffs, 'F()'),
            equals(MatchingLinkResult(Fnew)));
      });
    }, skip: !_constructorTearoffsAllowed.allows(utils.platformVersion));
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
