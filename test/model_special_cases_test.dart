// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This test library handles checks against the model for configurations
/// that require different PacakgeGraph configurations.  Since those
/// take a long time to initialize, isolate them here to keep model_test
/// fast.
library dartdoc.model_special_cases_test;

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  var sdkDir = defaultSdkDir;

  if (sdkDir == null) {
    print('Warning: unable to locate the Dart SDK.');
    exit(1);
  }

  // Experimental features not yet enabled by default.  Move tests out of this block
  // when the feature is enabled by default.
  group('Experiments', () {
    Library lateFinalWithoutInitializer, nnbdClassMemberDeclarations;
    Class b;
    setUpAll(() async {
      lateFinalWithoutInitializer = (await utils.testPackageGraphExperiments)
          .libraries
          .firstWhere((lib) => lib.name == 'late_final_without_initializer');
      nnbdClassMemberDeclarations = (await utils.testPackageGraphExperiments)
          .libraries
          .firstWhere((lib) => lib.name == 'nnbd_class_member_declarations');
      b = nnbdClassMemberDeclarations.allClasses
          .firstWhere((c) => c.name == 'B');
    });

    test('method parameters with required', () {
      var m1 = b.allInstanceMethods.firstWhere((m) => m.name == 'm1');
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
      var m2 = b.allInstanceMethods.firstWhere((m) => m.name == 'm2');
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
      var a = c.allFields.firstWhere((f) => f.name == 'a');
      var b = c.allFields.firstWhere((f) => f.name == 'b');
      var cField = c.allFields.firstWhere((f) => f.name == 'cField');
      var dField = c.allFields.firstWhere((f) => f.name == 'dField');

      // If nnbd isn't enabled, fields named 'late' come back from the analyzer
      // instead of setting up 'isLate'.
      expect(c.allFields.any((f) => f.name == 'late'), isFalse);

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
  }, skip: 'dart-lang/dartdoc#2148');

  group('HTML Injection when allowed', () {
    Class htmlInjection;
    Method injectSimpleHtml;
    Method injectHtmlFromTool;

    PackageGraph injectionPackageGraph;
    Library injectionExLibrary;

    setUpAll(() async {
      injectionPackageGraph = await utils.bootBasicPackage(
          'testing/test_package', ['css', 'code_in_comments', 'excluded'],
          additionalArguments: ['--inject-html']);

      injectionExLibrary =
          injectionPackageGraph.libraries.firstWhere((lib) => lib.name == 'ex');

      htmlInjection = injectionExLibrary.classes
          .firstWhere((c) => c.name == 'HtmlInjection');
      injectSimpleHtml = htmlInjection.allInstanceMethods
          .firstWhere((m) => m.name == 'injectSimpleHtml');
      injectHtmlFromTool = htmlInjection.allInstanceMethods
          .firstWhere((m) => m.name == 'injectHtmlFromTool');
      injectionPackageGraph.allLocalModelElements
          .forEach((m) => m.documentation);
    });

    test('can inject HTML', () {
      expect(
          injectSimpleHtml.documentation,
          contains(
              '\n<dartdoc-html>bad2bbdd4a5cf9efb3212afff4449904756851aa</dartdoc-html>\n'));
      expect(injectSimpleHtml.documentation,
          isNot(contains('\n{@inject-html}\n')));
      expect(injectSimpleHtml.documentation,
          isNot(contains('\n{@end-inject-html}\n')));
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
  });

  group('Missing and Remote', () {
    PackageGraph ginormousPackageGraph;

    setUpAll(() async {
      ginormousPackageGraph = await utils.testPackageGraphGinormous;
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
      ginormousPackageGraph = await utils.testPackageGraphGinormous;
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

    test('Verify that packages without categories get handled', () async {
      var packageGraphSmall = await utils.testPackageGraphSmall;
      expect(packageGraphSmall.localPackages.length, equals(1));
      expect(packageGraphSmall.localPackages.first.hasCategories, isFalse);
      var packageCategories = packageGraphSmall.localPackages.first.categories;
      expect(packageCategories.length, equals(0));
    }, timeout: Timeout.factor(2));
  });

  group('Package', () {
    PackageGraph ginormousPackageGraph, sdkAsPackageGraph;

    setUpAll(() async {
      ginormousPackageGraph = await utils.testPackageGraphGinormous;
      sdkAsPackageGraph = await utils.testPackageGraphSdk;
    });

    group('test package', () {
      test('multiple packages, sorted default', () {
        expect(ginormousPackageGraph.localPackages, hasLength(5));
        expect(ginormousPackageGraph.localPackages.first.name,
            equals('test_package'));
      });

      test('sdk name', () {
        expect(sdkAsPackageGraph.defaultPackage.name, equals('Dart'));
        expect(sdkAsPackageGraph.defaultPackage.kind, equals('SDK'));
      });

      test('sdk homepage', () {
        expect(sdkAsPackageGraph.defaultPackage.hasHomepage, isTrue);
        expect(sdkAsPackageGraph.defaultPackage.homepage,
            equals('https://github.com/dart-lang/sdk'));
      });

      test('sdk version', () {
        expect(sdkAsPackageGraph.defaultPackage.version, isNotNull);
      });

      test('sdk description', () {
        expect(sdkAsPackageGraph.defaultPackage.documentation,
            startsWith('Welcome'));
      });
    });

    group('test small package', () {
      test('does not have documentation', () async {
        var packageGraphSmall = await utils.testPackageGraphSmall;
        expect(packageGraphSmall.defaultPackage.hasDocumentation, isFalse);
        expect(packageGraphSmall.defaultPackage.hasDocumentationFile, isFalse);
        expect(packageGraphSmall.defaultPackage.documentationFile, isNull);
        expect(packageGraphSmall.defaultPackage.documentation, isNull);
      });
    });

    group('SDK-specific cases', () {
      test('Verify Interceptor is hidden from inheritance in docs', () {
        var htmlLibrary = sdkAsPackageGraph.libraries
            .singleWhere((l) => l.name == 'dart:html');
        var EventTarget =
            htmlLibrary.allClasses.singleWhere((c) => c.name == 'EventTarget');
        var hashCode = EventTarget.allPublicInstanceProperties
            .singleWhere((f) => f.name == 'hashCode');
        var objectModelElement =
            sdkAsPackageGraph.specialClasses[SpecialClass.object];
        // If this fails, EventTarget might have been changed to no longer
        // inherit from Interceptor.  If that's true, adjust test case to
        // another class that does.
        expect(
            hashCode.inheritance.any((c) => c.name == 'Interceptor'), isTrue);
        // If EventTarget really does start implementing hashCode, this will
        // fail.
        expect(hashCode.href,
            equals('${HTMLBASE_PLACEHOLDER}dart-core/Object/hashCode.html'));
        expect(
            hashCode.canonicalEnclosingContainer, equals(objectModelElement));
        expect(
            EventTarget.publicSuperChainReversed
                .any((et) => et.name == 'Interceptor'),
            isFalse);
      });

      test('Verify pragma is hidden in SDK docs', () {
        var pragmaModelElement =
            sdkAsPackageGraph.specialClasses[SpecialClass.pragma];
        expect(pragmaModelElement.name, equals('pragma'));
      });
    });
  });

  group('Library', () {
    Library dartAsyncLib;

    setUpAll(() async {
      dartAsyncLib = (await utils.testPackageGraphSdk)
          .libraries
          .firstWhere((l) => l.name == 'dart:async');
      // Make sure the first library is dart:async
      expect(dartAsyncLib.name, 'dart:async');
    });

    test('sdk library have formatted names', () {
      expect(dartAsyncLib.name, 'dart:async');
      expect(dartAsyncLib.dirName, 'dart-async');
      expect(dartAsyncLib.href,
          '${HTMLBASE_PLACEHOLDER}dart-async/dart-async-library.html');
    });
  });

  group('YouTube Errors', () {
    PackageGraph packageGraphErrors;
    Class documentationErrors;
    Method withYouTubeWrongParams;
    Method withYouTubeBadWidth;
    Method withYouTubeBadHeight;
    Method withYouTubeInvalidUrl;
    Method withYouTubeUrlWithAdditionalParameters;

    setUpAll(() async {
      packageGraphErrors = await utils.testPackageGraphErrors;
      documentationErrors = packageGraphErrors.libraries
          .firstWhere((lib) => lib.name == 'doc_errors')
          .classes
          .firstWhere((c) => c.name == 'DocumentationErrors')
            ..documentation;
      withYouTubeWrongParams = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeWrongParams')
            ..documentation;
      withYouTubeBadWidth = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeBadWidth')
            ..documentation;
      withYouTubeBadHeight = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeBadHeight')
            ..documentation;
      withYouTubeInvalidUrl = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeInvalidUrl')
            ..documentation;
      withYouTubeUrlWithAdditionalParameters = documentationErrors
          .allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeUrlWithAdditionalParameters')
            ..documentation;
    });

    test('warns on youtube video with missing parameters', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withYouTubeWrongParams,
              PackageWarning.invalidParameter,
              'Invalid @youtube directive, "{@youtube https://youtu.be/oHg5SJYRHA0}"\n'
              'YouTube directives must be of the form "{@youtube WIDTH HEIGHT URL}"'),
          isTrue);
    });
    test('warns on youtube video with non-integer width', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withYouTubeBadWidth,
              PackageWarning.invalidParameter,
              'A @youtube directive has an invalid width, "100px". The width '
              'must be a positive integer.'),
          isTrue);
    });
    test('warns on youtube video with non-integer height', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withYouTubeBadHeight,
              PackageWarning.invalidParameter,
              'A @youtube directive has an invalid height, "100px". The height '
              'must be a positive integer.'),
          isTrue);
    });
    test('warns on youtube video with invalid video URL', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withYouTubeInvalidUrl,
              PackageWarning.invalidParameter,
              'A @youtube directive has an invalid URL: '
              '"http://host/path/to/video.mp4". Supported YouTube URLs have '
              'the following format: '
              'https://www.youtube.com/watch?v=oHg5SJYRHA0.'),
          isTrue);
    });
    test('warns on youtube video with extra parameters in URL', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withYouTubeUrlWithAdditionalParameters,
              PackageWarning.invalidParameter,
              'A @youtube directive has an invalid URL: '
              '"https://www.youtube.com/watch?v=yI-8QHpGIP4&list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG&index=5". '
              'Supported YouTube URLs have the following format: '
              'https://www.youtube.com/watch?v=oHg5SJYRHA0.'),
          isTrue);
    });
  });

  group('Animation Errors', () {
    PackageGraph packageGraphErrors;
    Class documentationErrors;
    Method withInvalidNamedAnimation;
    Method withAnimationNonUnique;
    Method withAnimationNonUniqueDeprecated;
    Method withAnimationWrongParams;
    Method withAnimationBadWidth;
    Method withAnimationBadHeight;
    Method withAnimationUnknownArg;

    setUpAll(() async {
      packageGraphErrors = await utils.testPackageGraphErrors;
      documentationErrors = packageGraphErrors.libraries
          .firstWhere((lib) => lib.name == 'doc_errors')
          .classes
          .firstWhere((c) => c.name == 'DocumentationErrors')
            ..documentation;
      withInvalidNamedAnimation = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withInvalidNamedAnimation')
            ..documentation;
      withAnimationNonUnique = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationNonUnique')
            ..documentation;
      withAnimationNonUniqueDeprecated = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationNonUniqueDeprecated')
            ..documentation;
      withAnimationWrongParams = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationWrongParams')
            ..documentation;
      withAnimationBadWidth = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationBadWidth')
            ..documentation;
      withAnimationBadHeight = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationBadHeight')
            ..documentation;
      withAnimationUnknownArg = documentationErrors.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationUnknownArg')
            ..documentation;
    });

    test('warns with invalidly-named animation within the method documentation',
        () async {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withInvalidNamedAnimation,
              PackageWarning.invalidParameter,
              'An animation has an invalid identifier, "2isNot-A-ValidName". '
              'The identifier can only contain letters, numbers and '
              'underscores, and must not begin with a number.'),
          isTrue);
    });
    test('warns on a non-unique animation name within a method', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withAnimationNonUnique,
              PackageWarning.invalidParameter,
              'An animation has a non-unique identifier, "barHerderAnimation". '
              'Animation identifiers must be unique.'),
          isTrue);
    });
    test('warns on a non-unique animation name within a deprecated-form method',
        () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withAnimationNonUniqueDeprecated,
              PackageWarning.invalidParameter,
              'An animation has a non-unique identifier, "fooHerderAnimation". '
              'Animation identifiers must be unique.'),
          isTrue);
    });
    test('warns on animation with missing parameters', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withAnimationWrongParams,
              PackageWarning.invalidParameter,
              'Invalid @animation directive, "{@animation http://host/path/to/video.mp4}"\n'
              'Animation directives must be of the form "{@animation WIDTH '
              'HEIGHT URL [id=ID]}"'),
          isTrue);
    });
    test('warns on animation with non-integer width', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withAnimationBadWidth,
              PackageWarning.invalidParameter,
              'An animation has an invalid width (badWidthAnimation), "100px". '
              'The width must be an integer.'),
          isTrue);
    });
    test('warns on animation with non-integer height', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withAnimationBadHeight,
              PackageWarning.invalidParameter,
              'An animation has an invalid height (badHeightAnimation), '
              '"100px". The height must be an integer.'),
          isTrue);
    });
    test('Unknown arguments generate an error.', () {
      expect(
          packageGraphErrors.packageWarningCounter.hasWarning(
              withAnimationUnknownArg,
              PackageWarning.invalidParameter,
              'The {@animation ...} directive was called with invalid '
              'parameters. FormatException: Could not find an option named "name".'),
          isTrue);
    });
  }, timeout: Timeout.factor(2));
}
