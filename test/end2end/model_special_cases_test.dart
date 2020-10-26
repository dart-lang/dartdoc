// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This test library handles checks against the model for configurations
/// that require different PacakgeGraph configurations.  Since those
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
              'non-nullable',
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

  // This doesn't have the `max` because Null safety is supposed to work after
  // this version, and if the `max` is placed here we'll silently pass 2.10
  // stable if we haven't figured out how to switch on Null safety outside of
  // dev builds as specified in #2148.
  final _nullSafetyExperimentAllowed =
      VersionRange(min: Version.parse('2.9.0-9.0.dev'), includeMin: true);

  // Experimental features not yet enabled by default.  Move tests out of this
  // block when the feature is enabled by default.
  group('Experiments', () {
    Library lateFinalWithoutInitializer,
        nullSafetyClassMemberDeclarations,
        optOutOfNullSafety,
        nullableElements;
    Class b;

    setUpAll(() async {
      lateFinalWithoutInitializer = (await _testPackageGraphExperiments)
          .libraries
          .firstWhere((lib) => lib.name == 'late_final_without_initializer');
      nullSafetyClassMemberDeclarations = (await _testPackageGraphExperiments)
          .libraries
          .firstWhere((lib) => lib.name == 'nnbd_class_member_declarations');
      optOutOfNullSafety = (await _testPackageGraphExperiments)
          .libraries
          .firstWhere((lib) => lib.name == 'opt_out_of_nnbd');
      nullableElements = (await _testPackageGraphExperiments)
          .libraries
          .firstWhere((lib) => lib.name == 'nullable_elements');
      b = nullSafetyClassMemberDeclarations.allClasses
          .firstWhere((c) => c.name == 'B');
    });

    test('isNullSafety is set correctly for libraries', () {
      expect(lateFinalWithoutInitializer.isNullSafety, isTrue);
      expect(optOutOfNullSafety.isNullSafety, isFalse);
    });

    test('method parameters with required', () {
      var m1 = b.instanceMethods.firstWhere((m) => m.name == 'm1');
      var p1 = m1.allParameters.firstWhere((p) => p.name == 'p1');
      var p2 = m1.allParameters.firstWhere((p) => p.name == 'p2');
      expect(p1.isRequiredNamed, isTrue);
      expect(p2.isRequiredNamed, isFalse);
      expect(p2.isNamed, isTrue);

      expect(
          m1.linkedParamsLines,
          equals(
              '<ol class="parameter-list"><li><span class="parameter" id="m1-param-some"><span class="type-annotation">int</span> <span class="parameter-name">some</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-regular"><span class="type-annotation">dynamic</span> <span class="parameter-name">regular</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-parameters"><span>covariant</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">parameters</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p1">{<span>required</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">p1</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p2"><span class="type-annotation">int</span> <span class="parameter-name">p2</span>: <span class="default-value">3</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p3"><span>required</span> <span>covariant</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">p3</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p4"><span>required</span> <span>covariant</span> <span class="type-annotation">int</span> <span class="parameter-name">p4</span>}</span></li>\n'
              '</ol>'));
    });

    test('verify no regression on ordinary optionals', () {
      var m2 = b.instanceMethods.firstWhere((m) => m.name == 'm2');
      var sometimes = m2.allParameters.firstWhere((p) => p.name == 'sometimes');
      var optionals = m2.allParameters.firstWhere((p) => p.name == 'optionals');
      expect(sometimes.isRequiredNamed, isFalse);
      expect(sometimes.isRequiredPositional, isTrue);
      expect(sometimes.isOptionalPositional, isFalse);
      expect(optionals.isRequiredNamed, isFalse);
      expect(optionals.isRequiredPositional, isFalse);
      expect(optionals.isOptionalPositional, isTrue);

      expect(
          m2.linkedParamsLines,
          equals(
              '<ol class="parameter-list"><li><span class="parameter" id="m2-param-sometimes"><span class="type-annotation">int</span> <span class="parameter-name">sometimes</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-we"><span class="type-annotation">dynamic</span> <span class="parameter-name">we</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-have">[<span class="type-annotation">String</span> <span class="parameter-name">have</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-optionals"><span class="type-annotation">double</span> <span class="parameter-name">optionals</span>]</span></li>\n'
              '</ol>'));
    });

    test('Late final class member test', () {
      var c = lateFinalWithoutInitializer.allClasses
          .firstWhere((c) => c.name == 'C');
      var a = c.instanceFields.firstWhere((f) => f.name == 'a');
      var b = c.instanceFields.firstWhere((f) => f.name == 'b');
      var cField = c.instanceFields.firstWhere((f) => f.name == 'cField');
      var dField = c.instanceFields.firstWhere((f) => f.name == 'dField');

      // If Null safety isn't enabled, fields named 'late' come back from the
      // analyzer instead of setting up 'isLate'.
      expect(c.instanceFields.any((f) => f.name == 'late'), isFalse);

      expect(a.modelType.returnType.name, equals('dynamic'));
      expect(a.isLate, isTrue);
      expect(a.features, contains('late'));

      expect(b.modelType.returnType.name, equals('int'));
      expect(b.isLate, isTrue);
      expect(b.features, contains('late'));

      expect(cField.modelType.returnType.name, equals('dynamic'));
      expect(cField.isLate, isTrue);
      expect(cField.features, contains('late'));

      expect(dField.modelType.returnType.name, equals('double'));
      expect(dField.isLate, isTrue);
      expect(dField.features, contains('late'));
    });

    test('Late final top level variables', () {
      var initializeMe = lateFinalWithoutInitializer.publicProperties
          .firstWhere((v) => v.name == 'initializeMe');
      expect(initializeMe.modelType.returnType.name, equals('String'));
      expect(initializeMe.isLate, isTrue);
      expect(initializeMe.features, contains('late'));
    });

    test('Opt out of Null safety', () {
      var notOptedIn = optOutOfNullSafety.publicProperties
          .firstWhere((v) => v.name == 'notOptedIn');
      expect(notOptedIn.isNullSafety, isFalse);
      expect(notOptedIn.modelType.nullabilitySuffix, isEmpty);
    });

    test('complex nullable elements are detected and rendered correctly', () {
      var complexNullableMembers = nullableElements.allClasses
          .firstWhere((c) => c.name == 'ComplexNullableMembers');
      var aComplexType = complexNullableMembers.allFields
          .firstWhere((f) => f.name == 'aComplexType');
      var aComplexSetterOnlyType = complexNullableMembers.allFields
          .firstWhere((f) => f.name == 'aComplexSetterOnlyType');
      expect(complexNullableMembers.isNullSafety, isTrue);
      expect(
          complexNullableMembers.nameWithGenerics,
          equals(
              'ComplexNullableMembers&lt;<wbr><span class=\"type-parameter\">T extends String?</span>&gt;'));
      expect(
          aComplexType.linkedReturnType,
          equals(
              'Map<span class="signature">&lt;<wbr><span class="type-parameter">T?</span>, <span class="type-parameter">String?</span>&gt;</span>'));
      expect(aComplexSetterOnlyType.linkedReturnType, equals(
          // TODO(jcollins-g): fix wrong span class for setter-only return type (#2226)
          '<span class="parameter" id="aComplexSetterOnlyType=-param-value"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">Map<span class="signature">&lt;<wbr><span class="type-parameter">T?</span>, <span class="type-parameter">String?</span>&gt;</span>?</span>&gt;</span></span></span>'));
    });

    test('simple nullable elements are detected and rendered correctly', () {
      var nullableMembers = nullableElements.allClasses
          .firstWhere((c) => c.name == 'NullableMembers');
      var initialized =
          nullableMembers.allFields.firstWhere((f) => f.name == 'initialized');
      var nullableField = nullableMembers.allFields
          .firstWhere((f) => f.name == 'nullableField');
      var methodWithNullables = nullableMembers.publicInstanceMethods
          .firstWhere((f) => f.name == 'methodWithNullables');
      var operatorStar = nullableMembers.publicInstanceOperators
          .firstWhere((f) => f.name == 'operator *');
      expect(nullableMembers.isNullSafety, isTrue);
      expect(
          nullableField.linkedReturnType,
          equals(
              'Iterable<span class=\"signature\">&lt;<wbr><span class=\"type-parameter\">BigInt</span>&gt;</span>?'));
      expect(
          methodWithNullables.linkedParams,
          equals(
              '<span class="parameter" id="methodWithNullables-param-foo"><span class="type-annotation">String?</span> <span class="parameter-name">foo</span></span>'));
      expect(methodWithNullables.linkedReturnType, equals('int?'));
      expect(
          initialized.linkedReturnType,
          equals(
              'Map<span class="signature">&lt;<wbr><span class="type-parameter">String</span>, <span class="type-parameter">Map</span>&gt;</span>?'));
      expect(
          operatorStar.linkedParams,
          equals(
              '<span class="parameter" id="*-param-nullableOther"><span class="type-annotation"><a href="%%__HTMLBASE_dartdoc_internal__%%nullable_elements/NullableMembers-class.html">NullableMembers</a>?</span> <span class="parameter-name">nullableOther</span></span>'));
    });
  },
      skip: (!_nullSafetyExperimentAllowed.allows(_platformVersion) &&
          !_platformVersionString.contains('edge')));

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
      var EventTarget =
          htmlLibrary.allClasses.singleWhere((c) => c.name == 'EventTarget');
      var hashCode = EventTarget.publicInstanceFields
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
          equals('${HTMLBASE_PLACEHOLDER}dart-core/Object/hashCode.html'));
      expect(hashCode.canonicalEnclosingContainer, equals(objectModelElement));
      expect(
          EventTarget.publicSuperChainReversed
              .any((et) => et.name == 'Interceptor'),
          isFalse);
    });
  });
}
