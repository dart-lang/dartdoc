// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

/// For testing sort behavior.
class TestLibraryContainer extends LibraryContainer with Nameable {
  @override
  final List<String> containerOrder;
  @override
  String enclosingName;
  @override
  final String name;

  @override
  bool get isSdk => false;
  @override
  final PackageGraph packageGraph = null;

  TestLibraryContainer(
      this.name, this.containerOrder, LibraryContainer enclosingContainer) {
    enclosingName = enclosingContainer?.name;
  }
}

class TestLibraryContainerSdk extends TestLibraryContainer {
  TestLibraryContainerSdk(String name, List<String> containerOrder,
      LibraryContainer enclosingContainer)
      : super(name, containerOrder, enclosingContainer);

  @override
  bool get isSdk => true;
}

void main() {
  var sdkDir = defaultSdkDir;

  if (sdkDir == null) {
    print('Warning: unable to locate the Dart SDK.');
    exit(1);
  }

  PackageGraph packageGraph;
  Library exLibrary;
  Library fakeLibrary;
  Library twoExportsLib;
  Library interceptorsLib;
  Library baseClassLib;
  Library dartAsync;

  setUpAll(() async {
    // Use model_special_cases_test.dart for tests that require
    // a different package graph.
    packageGraph = await utils.testPackageGraph;
    exLibrary = packageGraph.libraries.firstWhere((lib) => lib.name == 'ex');
    fakeLibrary =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'fake');
    dartAsync =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'dart:async');
    twoExportsLib =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'two_exports');
    interceptorsLib = packageGraph.libraries
        .firstWhere((lib) => lib.name == 'dart:_interceptors');
    baseClassLib =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'base_class');
  });

  group('Set Literals', () {
    Library set_literals;
    TopLevelVariable aComplexSet,
        inferredTypeSet,
        specifiedSet,
        untypedMap,
        typedSet;

    setUpAll(() async {
      set_literals = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'set_literals');
      aComplexSet =
          set_literals.constants.firstWhere((v) => v.name == 'aComplexSet');
      inferredTypeSet =
          set_literals.constants.firstWhere((v) => v.name == 'inferredTypeSet');
      specifiedSet =
          set_literals.constants.firstWhere((v) => v.name == 'specifiedSet');
      untypedMap =
          set_literals.constants.firstWhere((v) => v.name == 'untypedMap');
      typedSet = set_literals.constants.firstWhere((v) => v.name == 'typedSet');
    });

    test('Set literals test', () {
      expect(aComplexSet.modelType.name, equals('Set'));
      expect(aComplexSet.modelType.typeArguments.map((a) => a.name).toList(),
          equals(['AClassContainingLiterals']));
      expect(aComplexSet.constantValue,
          equals('const {const AClassContainingLiterals(3, 5)}'));
      expect(inferredTypeSet.modelType.name, equals('Set'));
      expect(
          inferredTypeSet.modelType.typeArguments.map((a) => a.name).toList(),
          equals(['num']));
      expect(inferredTypeSet.constantValue, equals('const {1, 2.5, 3}'));
      expect(specifiedSet.modelType.name, equals('Set'));
      expect(specifiedSet.modelType.typeArguments.map((a) => a.name).toList(),
          equals(['int']));
      expect(specifiedSet.constantValue, equals('const {}'));
      expect(untypedMap.modelType.name, equals('Map'));
      expect(untypedMap.modelType.typeArguments.map((a) => a.name).toList(),
          equals(['dynamic', 'dynamic']));
      expect(untypedMap.constantValue, equals('const {}'));
      expect(typedSet.modelType.name, equals('Set'));
      expect(typedSet.modelType.typeArguments.map((a) => a.name).toList(),
          equals(['String']));
      expect(typedSet.constantValue,
          matches(RegExp(r'const &lt;String&gt;\s?{}')));
    });
  });

  group('Tools', () {
    Class toolUser;
    Class _NonCanonicalToolUser, CanonicalToolUser, PrivateLibraryToolUser;
    Class ImplementingClassForTool, CanonicalPrivateInheritedToolUser;
    Method invokeTool;
    Method invokeToolNoInput;
    Method invokeToolMultipleSections;
    Method invokeToolNonCanonical, invokeToolNonCanonicalSubclass;
    Method invokeToolPrivateLibrary, invokeToolPrivateLibraryOriginal;
    Method invokeToolParentDoc, invokeToolParentDocOriginal;
    // ignore: omit_local_variable_types
    final RegExp packageInvocationIndexRegexp =
        RegExp(r'PACKAGE_INVOCATION_INDEX: (\d+)');

    setUpAll(() {
      _NonCanonicalToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == '_NonCanonicalToolUser');
      CanonicalToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'CanonicalToolUser');
      PrivateLibraryToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'PrivateLibraryToolUser');
      ImplementingClassForTool = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'ImplementingClassForTool');
      CanonicalPrivateInheritedToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'CanonicalPrivateInheritedToolUser');
      toolUser = exLibrary.classes.firstWhere((c) => c.name == 'ToolUser');
      invokeTool =
          toolUser.allInstanceMethods.firstWhere((m) => m.name == 'invokeTool');
      invokeToolNonCanonical = _NonCanonicalToolUser.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolNonCanonical');
      invokeToolNonCanonicalSubclass = CanonicalToolUser.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolNonCanonical');
      invokeToolNoInput = toolUser.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolNoInput');
      invokeToolMultipleSections = toolUser.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolMultipleSections');
      invokeToolPrivateLibrary = PrivateLibraryToolUser.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolPrivateLibrary');
      invokeToolPrivateLibraryOriginal =
          (invokeToolPrivateLibrary.definingEnclosingContainer as Class)
              .allInstanceMethods
              .firstWhere((m) => m.name == 'invokeToolPrivateLibrary');
      invokeToolParentDoc = CanonicalPrivateInheritedToolUser.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolParentDoc');
      invokeToolParentDocOriginal = ImplementingClassForTool.allInstanceMethods
          .firstWhere((m) => m.name == 'invokeToolParentDoc');
      packageGraph.allLocalModelElements.forEach((m) => m.documentation);
    });

    test(
        'invokes tool when inherited documentation is the only means for it to be seen',
        () {
      // Verify setup of the test is correct.
      expect(invokeToolParentDoc.isCanonical, isTrue);
      expect(invokeToolParentDoc.documentationComment, isNull);
      // Error message here might look strange due to toString() on Methods, but if this
      // fails that means we don't have the correct invokeToolParentDoc instance.
      expect(invokeToolParentDoc.documentationFrom,
          contains(invokeToolParentDocOriginal));
      // Tool should be substituted out here.
      expect(invokeToolParentDoc.documentation, isNot(contains('{@tool')));
    });

    group('does _not_ invoke a tool multiple times unnecessarily', () {
      test('non-canonical subclass case', () {
        expect(invokeToolNonCanonical.isCanonical, isFalse);
        expect(invokeToolNonCanonicalSubclass.isCanonical, isTrue);
        expect(
            packageInvocationIndexRegexp
                .firstMatch(invokeToolNonCanonical.documentation)
                .group(1),
            equals(packageInvocationIndexRegexp
                .firstMatch(invokeToolNonCanonicalSubclass.documentation)
                .group(1)));
        expect(
            invokeToolPrivateLibrary.documentation, isNot(contains('{@tool')));
        expect(
            invokeToolPrivateLibraryOriginal.documentation, contains('{@tool'));
      });

      test('Documentation borrowed from implementer case', () {
        expect(
            packageInvocationIndexRegexp
                .firstMatch(invokeToolParentDoc.documentation)
                .group(1),
            equals(packageInvocationIndexRegexp
                .firstMatch(invokeToolParentDocOriginal.documentation)
                .group(1)));
      });
    });

    test('can invoke a tool and pass args and environment', () {
      expect(invokeTool.documentation, contains('--file=<INPUT_FILE>'));
      expect(invokeTool.documentation,
          contains(RegExp(r'--source=lib[/\\]example\.dart_[0-9]+_[0-9]+, ')));
      expect(invokeTool.documentation,
          contains(RegExp(r'--package-path=<PACKAGE_PATH>, ')));
      expect(
          invokeTool.documentation, contains('--package-name=test_package, '));
      expect(invokeTool.documentation, contains('--library-name=ex, '));
      expect(invokeTool.documentation,
          contains('--element-name=ToolUser.invokeTool, '));
      expect(invokeTool.documentation,
          contains(r'''--special= |\[]!@#\"'$%^&*()_+]'''));
      expect(invokeTool.documentation, contains('INPUT: <INPUT_FILE>'));
      expect(invokeTool.documentation,
          contains(RegExp('SOURCE_COLUMN: [0-9]+, ')));
      expect(invokeTool.documentation,
          contains(RegExp(r'SOURCE_PATH: lib[/\\]example\.dart, ')));
      expect(invokeTool.documentation,
          contains(RegExp(r'PACKAGE_PATH: <PACKAGE_PATH>, ')));
      expect(
          invokeTool.documentation, contains('PACKAGE_NAME: test_package, '));
      expect(invokeTool.documentation, contains('LIBRARY_NAME: ex, '));
      expect(invokeTool.documentation,
          contains('ELEMENT_NAME: ToolUser.invokeTool, '));
      expect(invokeTool.documentation,
          contains(RegExp('INVOCATION_INDEX: [0-9]+}')));
      expect(invokeTool.documentation, contains('## `Yes it is a [Dog]!`'));
    });
    test('can invoke a tool and add a reference link', () {
      expect(invokeTool.documentation,
          contains('Yes it is a [Dog]! Is not a [ToolUser].'));
      expect(
          invokeTool.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/ToolUser-class.html">ToolUser</a>'));
      expect(
          invokeTool.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/Dog-class.html">Dog</a>'));
    });
    test(r'can invoke a tool with no $INPUT or args', () {
      expect(invokeToolNoInput.documentation, contains('Args: []'));
      expect(invokeToolNoInput.documentation,
          isNot(contains('This text should not appear in the output')));
      expect(invokeToolNoInput.documentation, isNot(contains('[Dog]')));
      expect(
          invokeToolNoInput.documentationAsHtml,
          isNot(contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/Dog-class.html">Dog</a>')));
    });
    test('can invoke a tool multiple times in one comment block', () {
      var envLine = RegExp(r'^Env: \{', multiLine: true);
      expect(
          envLine.allMatches(invokeToolMultipleSections.documentation).length,
          equals(2));
      var argLine = RegExp(r'^Args: \[', multiLine: true);
      expect(
          argLine.allMatches(invokeToolMultipleSections.documentation).length,
          equals(2));
      expect(invokeToolMultipleSections.documentation,
          contains('Invokes more than one tool in the same comment block.'));
      expect(invokeToolMultipleSections.documentation,
          contains('This text should appear in the output.'));
      expect(invokeToolMultipleSections.documentation,
          contains('## `This text should appear in the output.`'));
      expect(invokeToolMultipleSections.documentation,
          contains('This text should also appear in the output.'));
      expect(invokeToolMultipleSections.documentation,
          contains('## `This text should also appear in the output.`'));
    });
  });

  group('HTML Injection when not allowed', () {
    Class htmlInjection;
    Method injectSimpleHtml;

    setUpAll(() {
      htmlInjection =
          exLibrary.classes.firstWhere((c) => c.name == 'HtmlInjection');
      injectSimpleHtml = htmlInjection.allInstanceMethods
          .firstWhere((m) => m.name == 'injectSimpleHtml');
    });
    test("doesn't inject HTML if --inject-html option is not present", () {
      expect(
          injectSimpleHtml.documentation,
          isNot(contains(
              '\n<dartdoc-html>bad2bbdd4a5cf9efb3212afff4449904756851aa</dartdoc-html>\n')));
      expect(injectSimpleHtml.documentation, isNot(contains('<dartdoc-html>')));
      expect(injectSimpleHtml.documentationAsHtml, contains('{@inject-html}'));
    });
  });

  group('Missing and Remote', () {
    test(
        'Verify that SDK libraries are not canonical when documenting a package',
        () {
      expect(
          dartAsync.package.documentedWhere, equals(DocumentLocation.missing));
      expect(dartAsync.isCanonical, isFalse);
    });

    test('Verify that packageGraph has an SDK but will not document it locally',
        () {
      expect(packageGraph.packages.firstWhere((p) => p.isSdk).documentedWhere,
          isNot(equals(DocumentLocation.local)));
    });
  });

  group('Category', () {
    test('Verify categories for test_package', () {
      expect(packageGraph.localPackages.length, equals(1));
      expect(packageGraph.localPackages.first.hasCategories, isTrue);
      var packageCategories = packageGraph.localPackages.first.categories;
      expect(packageCategories.length, equals(6));
      expect(
          packageGraph.localPackages.first.categoriesWithPublicLibraries.length,
          equals(3));
      expect(
          packageCategories.map((c) => c.name).toList(),
          orderedEquals([
            'Superb',
            'Unreal',
            'Real Libraries',
            'Misc',
            'More Excellence',
            'NotSoExcellent'
          ]));
      expect(packageCategories.map((c) => c.libraries.length).toList(),
          orderedEquals([0, 2, 3, 1, 0, 0]));
    });

    test('Verify libraries with multiple categories show up in multiple places',
        () {
      var packageCategories = packageGraph.publicPackages.first.categories;
      var realLibraries =
          packageCategories.firstWhere((c) => c.name == 'Real Libraries');
      var misc = packageCategories.firstWhere((c) => c.name == 'Misc');
      expect(
          realLibraries.libraries.map((l) => l.name), contains('two_exports'));
      expect(misc.libraries.map((l) => l.name), contains('two_exports'));
    });

    test('Verify that libraries without categories get handled', () {
      expect(
          packageGraph
              .localPackages.first.defaultCategory.publicLibraries.length,
          // Only 5 libraries have categories, the rest belong in default.
          equals(utils.kTestPackagePublicLibraries - 5));
    });

    // TODO consider moving these to a separate suite
    test('CategoryRendererHtml renders category label', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererHtml();
      expect(
          renderer.renderCategoryLabel(category),
          '<span class="category superb cp-0 linked" title="This is part of the Superb Topic.">'
          '<a href="${HTMLBASE_PLACEHOLDER}topics/Superb-topic.html">Superb</a></span>');
    });

    test('CategoryRendererHtml renders linkedName', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererHtml();
      expect(renderer.renderLinkedName(category),
          '<a href="${HTMLBASE_PLACEHOLDER}topics/Superb-topic.html">Superb</a>');
    });

    test('CategoryRendererMd renders category label', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererMd();
      expect(renderer.renderCategoryLabel(category),
          '[Superb](${HTMLBASE_PLACEHOLDER}topics/Superb-topic.html)');
    });

    test('CategoryRendererMd renders linkedName', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererMd();
      expect(renderer.renderLinkedName(category),
          '[Superb](${HTMLBASE_PLACEHOLDER}topics/Superb-topic.html)');
    });
  });

  group('LibraryContainer', () {
    TestLibraryContainer topLevel;
    List<String> sortOrderBasic;
    List<String> containerNames;

    setUpAll(() {
      topLevel = TestLibraryContainer('topLevel', [], null);
      sortOrderBasic = ['theFirst', 'second', 'fruit'];
      containerNames = [
        'moo',
        'woot',
        'theFirst',
        'topLevel Things',
        'toplevel',
        'fruit'
      ];
    });

    test('multiple containers with specified sort order', () {
      var containers = <LibraryContainer>[];
      for (var i = 0; i < containerNames.length; i++) {
        var name = containerNames[i];
        containers.add(TestLibraryContainer(name, sortOrderBasic, topLevel));
      }
      containers.add(TestLibraryContainerSdk('SDK', sortOrderBasic, topLevel));
      containers.sort();
      expect(
          containers.map((c) => c.name),
          orderedEquals([
            'theFirst',
            'fruit',
            'toplevel',
            'SDK',
            'topLevel Things',
            'moo',
            'woot'
          ]));
    });

    test('multiple containers, no specified sort order', () {
      var containers = <LibraryContainer>[];
      for (var name in containerNames) {
        containers.add(TestLibraryContainer(name, [], topLevel));
      }
      containers.add(TestLibraryContainerSdk('SDK', [], topLevel));
      containers.sort();
      expect(
          containers.map((c) => c.name),
          orderedEquals([
            'toplevel',
            'SDK',
            'topLevel Things',
            'fruit',
            'moo',
            'theFirst',
            'woot'
          ]));
    });
  });

  group('Package', () {
    group('test package', () {
      test('name', () {
        expect(packageGraph.defaultPackage.name, 'test_package');
      });

      test('libraries', () {
        expect(packageGraph.localPublicLibraries,
            hasLength(utils.kTestPackagePublicLibraries));
        expect(interceptorsLib.isPublic, isFalse);
      });

      test('homepage', () {
        expect(packageGraph.defaultPackage.hasHomepage, true);
        expect(packageGraph.defaultPackage.homepage,
            equals('http://github.com/dart-lang'));
      });

      test('packages', () {
        expect(packageGraph.localPackages, hasLength(1));

        var package = packageGraph.localPackages.first;
        expect(package.name, 'test_package');
        expect(package.publicLibraries,
            hasLength(utils.kTestPackagePublicLibraries));
      });

      test('is documented in library', () {
        expect(exLibrary.isDocumented, isTrue);
      });

      test('has documentation', () {
        expect(packageGraph.defaultPackage.hasDocumentationFile, isTrue);
        expect(packageGraph.defaultPackage.hasDocumentation, isTrue);
      });

      test('documentation exists', () {
        expect(
            packageGraph.defaultPackage.documentation
                .startsWith('# Best Package'),
            isTrue);
      });

      test('documentation can be rendered as HTML', () {
        expect(packageGraph.defaultPackage.documentationAsHtml,
            contains('<h1 id="best-package">Best Package</h1>'));
      });

      test('has anonymous libraries', () {
        expect(
            packageGraph.libraries
                .where((lib) => lib.name == 'anonymous_library'),
            hasLength(1));
        expect(
            packageGraph.libraries
                .where((lib) => lib.name == 'another_anonymous_lib'),
            hasLength(1));
      });
    });

    group('SDK-specific cases', () {
      test('Verify pragma is hidden in docs', () {
        var HasPragma = fakeLibrary.allClasses
            .firstWhere((Class c) => c.name == 'HasPragma');
        expect(HasPragma.annotations, isEmpty);
      });
    });
  });

  group('Library', () {
    Library anonLib,
        isDeprecated,
        someLib,
        reexportOneLib,
        reexportTwoLib,
        reexportThreeLib;
    Class SomeClass,
        SomeOtherClass,
        YetAnotherClass,
        AUnicornClass,
        ADuplicateClass;

    setUpAll(() {
      anonLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'anonymous_library');

      someLib = packageGraph.allLibraries.values
          .firstWhere((lib) => lib.name == 'reexport.somelib');
      reexportOneLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_one');
      reexportTwoLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_two');
      reexportThreeLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_three');
      SomeClass = someLib.getClassByName('SomeClass');
      SomeOtherClass = someLib.getClassByName('SomeOtherClass');
      YetAnotherClass = someLib.getClassByName('YetAnotherClass');
      AUnicornClass = someLib.getClassByName('AUnicornClass');
      ADuplicateClass = reexportThreeLib.getClassByName('ADuplicateClass');

      isDeprecated = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'is_deprecated');
    });

    test('has a name', () {
      expect(exLibrary.name, 'ex');
    });

    test('has a line number and column', () {
      expect(exLibrary.characterLocation, isNotNull);
    });

    test('packageName', () {
      expect(exLibrary.packageName, 'test_package');
    });

    test('has a fully qualified name', () {
      expect(exLibrary.fullyQualifiedName, 'ex');
    });

    test('can be deprecated', () {
      expect(isDeprecated.isDeprecated, isTrue);
      expect(anonLib.isDeprecated, isFalse);
    });

    test('can be reexported even if the file suffix is not .dart', () {
      expect(fakeLibrary.allClasses.map((c) => c.name),
          contains('MyClassFromADartFile'));
    });

    test('that is deprecated has a deprecated css class in linkedName', () {
      expect(isDeprecated.linkedName, contains('class="deprecated"'));
    });

    test('has documentation', () {
      expect(exLibrary.documentation,
          'a library. testing string escaping: `var s = \'a string\'` <cool>\n');
    });

    test('has one line docs', () {
      expect(
          fakeLibrary.oneLineDoc,
          equals(
              'WOW FAKE PACKAGE IS <strong>BEST</strong> <a href="http://example.org">PACKAGE</a>'));
    });

    test('has properties', () {
      expect(exLibrary.hasPublicProperties, isTrue);
    });

    test('has constants', () {
      expect(exLibrary.hasPublicConstants, isTrue);
    });

    test('has exceptions', () {
      expect(exLibrary.hasPublicExceptions, isTrue);
    });

    test('has mixins', () {
      expect(fakeLibrary.hasPublicMixins, isTrue);
      expect(reexportTwoLib.hasPublicMixins, isTrue);
    });

    test('has enums', () {
      expect(exLibrary.hasPublicEnums, isTrue);
    });

    test('has functions', () {
      expect(exLibrary.hasPublicFunctions, isTrue);
    });

    test('has typedefs', () {
      expect(exLibrary.hasPublicTypedefs, isTrue);
    });

    test('exported class', () {
      expect(exLibrary.classes.any((c) => c.name == 'Helper'), isTrue);
    });

    test('exported function', () {
      expect(
          exLibrary.functions.any((f) => f.name == 'helperFunction'), isFalse);
    });

    test('anonymous lib', () {
      expect(anonLib.isAnonymous, isTrue);
    });

    test('with ambiguous reexport warnings', () {
      final warningMsg =
          '(reexport_one, reexport_two) -> reexport_two (confidence 0.000)';
      // Unicorn class has a warning because two @canonicalFors cancel each other out.
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              AUnicornClass, PackageWarning.ambiguousReexport, warningMsg),
          isTrue);
      // This class is ambiguous without a @canonicalFor
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              YetAnotherClass, PackageWarning.ambiguousReexport, warningMsg),
          isTrue);
      // These two classes have a @canonicalFor
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              SomeClass, PackageWarning.ambiguousReexport, warningMsg),
          isFalse);
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              SomeOtherClass, PackageWarning.ambiguousReexport, warningMsg),
          isFalse);
      // This library has a canonicalFor with no corresponding item
      expect(
          packageGraph.packageWarningCounter.hasWarning(reexportTwoLib,
              PackageWarning.ignoredCanonicalFor, 'something.ThatDoesntExist'),
          isTrue);
    });

    test('@canonicalFor directive works', () {
      expect(SomeOtherClass.canonicalLibrary, reexportOneLib);
      expect(SomeClass.canonicalLibrary, reexportTwoLib);
    });

    test('with correct show/hide behavior', () {
      expect(ADuplicateClass.definingLibrary.name, equals('shadowing_lib'));
    });
  });

  group('Macros', () {
    Class dog;
    Enum MacrosFromAccessors;
    Method withMacro, withMacro2, withPrivateMacro, withUndefinedMacro;
    EnumField macroReferencedHere;

    setUpAll(() {
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      withMacro =
          dog.allInstanceMethods.firstWhere((m) => m.name == 'withMacro');
      withMacro2 =
          dog.allInstanceMethods.firstWhere((m) => m.name == 'withMacro2');
      withPrivateMacro = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withPrivateMacro');
      withUndefinedMacro = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withUndefinedMacro');
      MacrosFromAccessors =
          fakeLibrary.enums.firstWhere((e) => e.name == 'MacrosFromAccessors');
      macroReferencedHere = MacrosFromAccessors.publicConstants
          .firstWhere((e) => e.name == 'macroReferencedHere');
    });

    test('renders a macro defined within a enum', () {
      expect(macroReferencedHere.documentationAsHtml,
          contains('This is a macro defined in an Enum accessor.'));
    });

    test("renders a macro within the same comment where it's defined", () {
      expect(withMacro.documentation,
          equals('Macro method\n\nFoo macro content\nMore docs'));
    });

    test("renders a macro in another method, not the same where it's defined",
        () {
      expect(withMacro2.documentation, equals('Foo macro content'));
    });

    test('renders a macro defined in a private symbol', () {
      expect(withPrivateMacro.documentation, contains('Private macro content'));
    });

    test('a warning is generated for unknown macros', () {
      // Retrieve documentation first to generate the warning.
      withUndefinedMacro.documentation;
      expect(
          packageGraph.packageWarningCounter.hasWarning(withUndefinedMacro,
              PackageWarning.unknownMacro, 'ThatDoesNotExist'),
          isTrue);
    });
  });

  group('YouTube', () {
    Class dog;
    Method withYouTubeWatchUrl;
    Method withYouTubeInOneLineDoc;
    Method withYouTubeInline;

    setUpAll(() {
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      withYouTubeWatchUrl = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeWatchUrl');
      withYouTubeInOneLineDoc = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeInOneLineDoc');
      withYouTubeInline = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withYouTubeInline');
    });

    test(
        'renders a YouTube video within the method documentation with correct aspect ratio',
        () {
      expect(
          withYouTubeWatchUrl.documentation,
          contains(
              '<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0?rel=0"'));
      // Video is 560x315, which means height is 56.25% of width.
      expect(
          withYouTubeWatchUrl.documentation, contains('padding-top: 56.25%;'));
    });
    test("Doesn't place YouTube video in one line doc", () {
      expect(
          withYouTubeInOneLineDoc.oneLineDoc,
          isNot(contains(
              '<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0?rel=0"')));
      expect(
          withYouTubeInOneLineDoc.documentation,
          contains(
              '<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0?rel=0"'));
    });
    test('Handles YouTube video inline properly', () {
      // Make sure it doesn't have a double-space before the continued line,
      // which would indicate to Markdown to indent the line.
      expect(withYouTubeInline.documentation, isNot(contains('  works')));
    });
  });

  group('Animation', () {
    Class dog;
    Method withAnimation;
    Method withNamedAnimation;
    Method withQuoteNamedAnimation;
    Method withDeprecatedAnimation;
    Method withAnimationInOneLineDoc;
    Method withAnimationInline;
    Method withAnimationOutOfOrder;
    Enum enumWithAnimation;
    EnumField enumValue1;
    EnumField enumValue2;

    setUpAll(() {
      enumWithAnimation =
          exLibrary.enums.firstWhere((c) => c.name == 'EnumWithAnimation');
      enumValue1 =
          enumWithAnimation.constants.firstWhere((m) => m.name == 'value1');
      enumValue2 =
          enumWithAnimation.constants.firstWhere((m) => m.name == 'value2');
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      withAnimation =
          dog.allInstanceMethods.firstWhere((m) => m.name == 'withAnimation');
      withNamedAnimation = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withNamedAnimation');
      withQuoteNamedAnimation = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withQuotedNamedAnimation');
      withDeprecatedAnimation = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withDeprecatedAnimation');
      withAnimationInOneLineDoc = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationInOneLineDoc');
      withAnimationInline = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationInline');
      withAnimationOutOfOrder = dog.allInstanceMethods
          .firstWhere((m) => m.name == 'withAnimationOutOfOrder');
    });

    test('renders an unnamed animation within the method documentation', () {
      expect(withAnimation.documentation, contains('<video id="animation_1"'));
    });
    test('renders a named animation within the method documentation', () {
      expect(withNamedAnimation.documentation,
          contains('<video id="namedAnimation"'));
    });
    test('renders a quoted, named animation within the method documentation',
        () {
      expect(withQuoteNamedAnimation.documentation,
          contains('<video id="quotedNamedAnimation"'));
      expect(withQuoteNamedAnimation.documentation,
          contains('<video id="quotedNamedAnimation2"'));
    });
    test('renders a deprecated-form animation within the method documentation',
        () {
      expect(withDeprecatedAnimation.documentation,
          contains('<video id="deprecatedAnimation"'));
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              withDeprecatedAnimation,
              PackageWarning.deprecated,
              'Deprecated form of @animation directive, '
              '"{@animation deprecatedAnimation 100 100 http://host/path/to/video.mp4}"\n'
              'Animation directives are now of the form "{@animation '
              'WIDTH HEIGHT URL [id=ID]}" (id is an optional '
              'parameter)'),
          isTrue);
    });
    test("Doesn't place animations in one line doc", () {
      expect(withAnimationInOneLineDoc.oneLineDoc, isNot(contains('<video')));
      expect(withAnimationInOneLineDoc.documentation, contains('<video'));
    });
    test('Handles animations inline properly', () {
      // Make sure it doesn't have a double-space before the continued line,
      // which would indicate to Markdown to indent the line.
      expect(withAnimationInline.documentation, isNot(contains('  works')));
    });
    test('Out of order arguments work.', () {
      expect(withAnimationOutOfOrder.documentation,
          contains('<video id="outOfOrder"'));
    });
    test('Enum field animation identifiers are unique.', () {
      expect(
          enumValue1.documentationAsHtml, contains('<video id="animation_1"'));
      expect(
          enumValue1.documentationAsHtml, contains('<video id="animation_2"'));
      expect(enumValue2.documentationAsHtml,
          isNot(contains('<video id="animation_1"')));
      expect(enumValue2.documentationAsHtml,
          isNot(contains('<video id="animation_2"')));
      expect(
          enumValue2.documentationAsHtml, contains('<video id="animation_3"'));
      expect(
          enumValue2.documentationAsHtml, contains('<video id="animation_4"'));
    });
  });

  group('MultiplyInheritedExecutableElement handling', () {
    Class BaseThingy, BaseThingy2, ImplementingThingy2;
    Method aImplementingThingyMethod;
    Field aImplementingThingyField;
    Field aImplementingThingy;
    Accessor aImplementingThingyAccessor;

    setUpAll(() {
      BaseThingy =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseThingy');
      BaseThingy2 =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseThingy2');
      ImplementingThingy2 = fakeLibrary.classes
          .firstWhere((c) => c.name == 'ImplementingThingy2');

      aImplementingThingy = ImplementingThingy2.allInstanceFields
          .firstWhere((m) => m.name == 'aImplementingThingy');
      aImplementingThingyMethod = ImplementingThingy2.allInstanceMethods
          .firstWhere((m) => m.name == 'aImplementingThingyMethod');
      aImplementingThingyField = ImplementingThingy2.allInstanceFields
          .firstWhere((m) => m.name == 'aImplementingThingyField');
      aImplementingThingyAccessor = aImplementingThingyField.getter;
    });

    test('Verify behavior of imperfect resolver', () {
      expect(aImplementingThingy.element.enclosingElement,
          equals(BaseThingy2.element));
      expect(aImplementingThingyMethod.element.enclosingElement,
          equals(BaseThingy.element));
      expect(aImplementingThingyField.element.enclosingElement,
          equals(BaseThingy.element));
      expect(aImplementingThingyAccessor.element.enclosingElement,
          equals(BaseThingy.element));
    });
  });

  group('Docs as HTML', () {
    Class Apple, B, superAwesomeClass, foo2;
    TopLevelVariable incorrectDocReferenceFromEx;
    TopLevelVariable bulletDoced;
    ModelFunction thisIsAsync;
    ModelFunction topLevelFunction;

    Class extendedClass;
    TopLevelVariable testingCodeSyntaxInOneLiners;

    Class specialList;
    Class baseForDocComments;
    Method doAwesomeStuff;
    Class subForDocComments;

    ModelFunction short;

    setUpAll(() {
      incorrectDocReferenceFromEx = exLibrary.constants
          .firstWhere((c) => c.name == 'incorrectDocReferenceFromEx');
      B = exLibrary.classes.firstWhere((c) => c.name == 'B');
      Apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      specialList =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SpecialList');
      bulletDoced =
          fakeLibrary.constants.firstWhere((c) => c.name == 'bulletDoced');
      topLevelFunction =
          fakeLibrary.functions.firstWhere((f) => f.name == 'topLevelFunction');
      thisIsAsync =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsAsync');
      testingCodeSyntaxInOneLiners = fakeLibrary.constants
          .firstWhere((c) => c.name == 'testingCodeSyntaxInOneLiners');
      superAwesomeClass = fakeLibrary.classes
          .firstWhere((cls) => cls.name == 'SuperAwesomeClass');
      foo2 = fakeLibrary.classes.firstWhere((cls) => cls.name == 'Foo2');
      assert(twoExportsLib != null);
      extendedClass = twoExportsLib.allClasses
          .firstWhere((clazz) => clazz.name == 'ExtendingClass');

      subForDocComments =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SubForDocComments');

      baseForDocComments =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseForDocComments');
      doAwesomeStuff = baseForDocComments.instanceMethods
          .firstWhere((m) => m.name == 'doAwesomeStuff');

      short = fakeLibrary.functions.firstWhere((f) => f.name == 'short');
    });

    group('markdown extensions', () {
      Class DocumentWithATable;
      String docsAsHtml;

      setUpAll(() {
        DocumentWithATable = fakeLibrary.classes
            .firstWhere((cls) => cls.name == 'DocumentWithATable');
        docsAsHtml = DocumentWithATable.documentationAsHtml;
      });

      test('Verify table appearance', () {
        expect(docsAsHtml.contains('<table><thead><tr><th>Component</th>'),
            isTrue);
      });

      test('Verify links inside of table headers', () {
        expect(
            docsAsHtml.contains(
                '<th><a href="${HTMLBASE_PLACEHOLDER}fake/Annotation-class.html">Annotation</a></th>'),
            isTrue);
      });

      test('Verify links inside of table body', () {
        expect(
            docsAsHtml.contains(
                '<tbody><tr><td><a href="${HTMLBASE_PLACEHOLDER}fake/DocumentWithATable/foo-constant.html">foo</a></td>'),
            isTrue);
      });

      test('Verify there is no emoji support', () {
        var tpvar = fakeLibrary.constants
            .firstWhere((t) => t.name == 'hasMarkdownInDoc');
        docsAsHtml = tpvar.documentationAsHtml;
        expect(docsAsHtml.contains('3ffe:2a00:100:7031::1'), isTrue);
      });
    });

    group('doc references', () {
      String docsAsHtml;

      setUpAll(() {
        docsAsHtml = doAwesomeStuff.documentationAsHtml;
      });

      test('can handle renamed imports', () {
        var aFunctionUsingRenamedLib = fakeLibrary.functions
            .firstWhere((f) => f.name == 'aFunctionUsingRenamedLib');
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to library: <a href="${HTMLBASE_PLACEHOLDER}mylibpub/mylibpub-library.html">renamedLib</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to constructor (implied): <a href="${HTMLBASE_PLACEHOLDER}mylibpub/YetAnotherHelper/YetAnotherHelper.html">new renamedLib.YetAnotherHelper()</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to constructor (implied, no new): <a href="${HTMLBASE_PLACEHOLDER}mylibpub/YetAnotherHelper/YetAnotherHelper.html">renamedLib.YetAnotherHelper()</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to class: <a href="${HTMLBASE_PLACEHOLDER}mylibpub/YetAnotherHelper-class.html">renamedLib.YetAnotherHelper</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to constructor (direct): <a href="${HTMLBASE_PLACEHOLDER}mylibpub/YetAnotherHelper/YetAnotherHelper.html">renamedLib.YetAnotherHelper.YetAnotherHelper</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to class member: <a href="${HTMLBASE_PLACEHOLDER}mylibpub/YetAnotherHelper/getMoreContents.html">renamedLib.YetAnotherHelper.getMoreContents</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to function: <a href="${HTMLBASE_PLACEHOLDER}mylibpub/helperFunction.html">renamedLib.helperFunction</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to overlapping prefix: <a href="${HTMLBASE_PLACEHOLDER}csspub/theOnlyThingInTheLibrary.html">renamedLib2.theOnlyThingInTheLibrary</a>'));
      });

      test('operator [] reference within a class works', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/BaseForDocComments/operator_get.html">operator []</a> '));
      });

      test('operator [] reference outside of a class works', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/SpecialList/operator_get.html">SpecialList.operator []</a> '));
      }, skip: 'https://github.com/dart-lang/dartdoc/issues/1285');

      test('codeifies a class from the SDK', () {
        expect(docsAsHtml, contains('<code>String</code>'));
      });

      test('codeifies a reference to its parameter', () {
        expect(docsAsHtml, contains('<code>value</code>'));
      });

      test('links to a reference to its class', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/BaseForDocComments-class.html">BaseForDocComments</a>'));
      });

      test(
          'link to a name in another library in this package, but is not imported into this library, should still be linked',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}anonymous_library/doesStuff.html">doesStuff</a>'));
      });

      test(
          'link to unresolved name in the library in this package still should be linked',
          () {
        var helperClass =
            exLibrary.classes.firstWhere((c) => c.name == 'Helper');
        expect(
            helperClass.documentationAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}ex/Apple-class.html">Apple</a>'));
        expect(
            helperClass.documentationAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}ex/B-class.html">ex.B</a>'));
      });

      test('link to override method in implementer from base class', () {
        var helperClass =
            baseClassLib.classes.firstWhere((c) => c.name == 'Constraints');
        expect(
            helperClass.documentationAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}override_class/BoxConstraints/debugAssertIsValid.html">BoxConstraints.debugAssertIsValid</a>'));
      });

      test(
          'link to a name of a class from an imported library that exports the name',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}two_exports/BaseClass-class.html">BaseClass</a>'));
      });

      test(
          'links to a reference to a top-level const with multiple underscores',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/NAME_WITH_TWO_UNDERSCORES-constant.html">NAME_WITH_TWO_UNDERSCORES</a>'));
      });

      test('links to a method in this class', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/BaseForDocComments/anotherMethod.html">anotherMethod</a>'));
      });

      test('links to a top-level function in this library', () {
        expect(
            docsAsHtml,
            contains(
                '<a class="deprecated" href="${HTMLBASE_PLACEHOLDER}fake/topLevelFunction.html">topLevelFunction</a>'));
      });

      test('links to top-level function from an imported library', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}ex/function1.html">function1</a>'));
      });

      test('links to a class from an imported lib', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}ex/Apple-class.html">Apple</a>'));
      });

      test(
          'links to a top-level const from same lib (which also has the same name as a const from an imported lib)',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/incorrectDocReference-constant.html">incorrectDocReference</a>'));
      });

      test('links to a top-level const from an imported lib', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}ex/incorrectDocReferenceFromEx-constant.html">incorrectDocReferenceFromEx</a>'));
      });

      test('links to a top-level variable with a prefix from an imported lib',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}csspub/theOnlyThingInTheLibrary.html">css.theOnlyThingInTheLibrary</a>'));
      });

      test('links to a name with a single underscore', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/NAME_SINGLEUNDERSCORE-constant.html">NAME_SINGLEUNDERSCORE</a>'));
      });

      test('correctly escapes type parameters in links', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${HTMLBASE_PLACEHOLDER}fake/ExtraSpecialList-class.html">ExtraSpecialList&lt;Object&gt;</a>'));
      });

      test('correctly escapes type parameters in broken links', () {
        expect(docsAsHtml,
            contains('<code>ThisIsNotHereNoWay&lt;MyType&gt;</code>'));
      });

      test('leaves relative href resulting in a broken link', () {
        // Dartdoc does emit a brokenLink warning for this.
        expect(docsAsHtml,
            contains('<a href="SubForDocComments/localMethod.html">link</a>'));
      });

      test('leaves relative href resulting in a working link', () {
        // Ideally doc comments should not make assumptions about Dartdoc output
        // files, but unfortunately some do...
        expect(
            docsAsHtml,
            contains(
                '<a href="../SubForDocComments/localMethod.html">link</a>'));
      });
    });

    test('multi-underscore names in brackets do not become italicized', () {
      expect(short.documentation, contains('[NAME_WITH_TWO_UNDERSCORES]'));
      expect(
          short.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/NAME_WITH_TWO_UNDERSCORES-constant.html">NAME_WITH_TWO_UNDERSCORES</a>'));
    });

    test('still has brackets inside code blocks', () {
      expect(topLevelFunction.documentationAsHtml,
          contains("['hello from dart']"));
    });

    test('class without additional docs', () {
      expect(specialList.hasExtendedDocumentation, equals(false));
    });

    test('class with additional docs', () {
      expect(Apple.hasExtendedDocumentation, equals(true));
    });

    test('oneLine doc references in inherited methods should not have brackets',
        () {
      var add =
          specialList.allInstanceMethods.firstWhere((m) => m.name == 'add');
      expect(
          add.oneLineDoc,
          equals(
              'Adds <code>value</code> to the end of this list,\nextending the length by one.'));
    });

    test(
        'full documentation references from inherited methods should not have brackets',
        () {
      var add =
          specialList.allInstanceMethods.firstWhere((m) => m.name == 'add');
      expect(
          add.documentationAsHtml,
          startsWith(
              '<p>Adds <code>value</code> to the end of this list,\nextending the length by one.'));
    });

    test('incorrect doc references are still wrapped in code blocks', () {
      expect(incorrectDocReferenceFromEx.documentationAsHtml,
          '<p>This should <code>not work</code>.</p>');
    });

    test('no references', () {
      expect(
          Apple.documentationAsHtml,
          '<p>Sample class <code>String</code></p><pre class="language-dart">  A\n'
          '   B\n'
          '</pre>');
    });

    test('single ref to class', () {
      expect(
          B.documentationAsHtml.contains(
              '<p>Extends class <a href="${HTMLBASE_PLACEHOLDER}ex/Apple-class.html">Apple</a>, use <a href="${HTMLBASE_PLACEHOLDER}ex/Apple/Apple.html">new Apple</a> or <a href="${HTMLBASE_PLACEHOLDER}ex/Apple/Apple.fromString.html">new Apple.fromString</a></p>'),
          isTrue);
    });

    test('doc ref to class in SDK does not render as link', () {
      expect(
          thisIsAsync.documentationAsHtml,
          equals(
              '<p>An async function. It should look like I return a <code>Future</code>.</p>'));
    });

    test('references are correct in exported libraries', () {
      expect(twoExportsLib, isNotNull);
      expect(extendedClass, isNotNull);
      var resolved = extendedClass.documentationAsHtml;
      expect(resolved, isNotNull);
      expect(
          resolved,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}two_exports/BaseClass-class.html">BaseClass</a>'));
      expect(
          resolved,
          contains(
              'Linking over to <a href="${HTMLBASE_PLACEHOLDER}ex/Apple-class.html">Apple</a>'));
    });

    test('references to class and constructors', () {
      var comment = B.documentationAsHtml;
      expect(
          comment,
          contains(
              'Extends class <a href="${HTMLBASE_PLACEHOLDER}ex/Apple-class.html">Apple</a>'));
      expect(
          comment,
          contains(
              'use <a href="${HTMLBASE_PLACEHOLDER}ex/Apple/Apple.html">new Apple</a>'));
      expect(
          comment,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/Apple/Apple.fromString.html">new Apple.fromString</a>'));
    });

    test('reference to class from another library', () {
      var comment = superAwesomeClass.documentationAsHtml;
      expect(
          comment,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/Apple-class.html">Apple</a>'));
    });

    test('reference to method', () {
      var comment = foo2.documentationAsHtml;
      expect(
          comment,
          equals(
              '<p>link to method from class <a href="${HTMLBASE_PLACEHOLDER}ex/Apple/m.html">Apple.m</a></p>'));
    });

    test(
        'code references to privately defined elements in public classes work properly',
        () {
      var notAMethodFromPrivateClass = fakeLibrary.allClasses
          .firstWhere((Class c) => c.name == 'ReferringClass')
          .allPublicInstanceMethods
          .firstWhere((Method m) => m.name == 'notAMethodFromPrivateClass');
      expect(
          notAMethodFromPrivateClass.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/InheritingClassOne/aMethod.html">fake.InheritingClassOne.aMethod</a>'));
      expect(
          notAMethodFromPrivateClass.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/InheritingClassTwo/aMethod.html">fake.InheritingClassTwo.aMethod</a>'));
    });

    test('legacy code blocks render correctly', () {
      expect(
          testingCodeSyntaxInOneLiners.oneLineDoc,
          equals(
              'These are code syntaxes: <code>true</code> and <code>false</code>'));
    });

    test('doc comments to parameters are marked as code', () {
      var localMethod = subForDocComments.instanceMethods
          .firstWhere((m) => m.name == 'localMethod');
      expect(localMethod.documentationAsHtml, contains('<code>foo</code>'));
      expect(localMethod.documentationAsHtml, contains('<code>bar</code>'));
    });

    test('doc comment inherited from getter', () {
      var getterWithDocs = subForDocComments.instanceProperties
          .firstWhere((m) => m.name == 'getterWithDocs');
      expect(getterWithDocs.documentationAsHtml,
          contains('Some really great topics.'));
    });

    test(
        'a property with no explicit getters and setters does not duplicate docs',
        () {
      var powers = superAwesomeClass.instanceProperties
          .firstWhere((p) => p.name == 'powers');
      Iterable<Match> matches =
          RegExp('In the super class').allMatches(powers.documentationAsHtml);
      expect(matches, hasLength(1));
    });

    test('bullet points work in top level variables', () {
      expect(
          bulletDoced.extendedDocLink,
          equals(
              ModelElementRendererHtml().renderExtendedDocLink(bulletDoced)));
      expect(bulletDoced.documentationAsHtml, contains('<li>'));
    });
  });

  group('Class edge cases', () {
    test('Factories from unrelated classes are linked correctly', () {
      var A = packageGraph.localPublicLibraries
          .firstWhere((l) => l.name == 'unrelated_factories')
          .allClasses
          .firstWhere((c) => c.name == 'A');
      var fromMap = A.constructors.firstWhere((c) => c.name == 'A.fromMap');
      expect(fromMap.documentationAsHtml,
          contains(r'unrelated_factories/AB/AB.fromMap.html">AB.fromMap</a>'));
      expect(fromMap.documentationAsHtml,
          contains(r'A/A.fromMap.html">fromMap</a>'));
      expect(fromMap.documentationAsHtml,
          contains(r'unrelated_factories/AB-class.html">AB</a>'));
      expect(fromMap.documentationAsHtml,
          contains(r'unrelated_factories/A-class.html">A</a>'));
    });

    test('Inherit from private class across private library to public library',
        () {
      var GadgetExtender = packageGraph.localPublicLibraries
          .firstWhere((l) => l.name == 'gadget_extender')
          .allClasses
          .firstWhere((c) => c.name == 'GadgetExtender');
      var gadgetGetter =
          GadgetExtender.allFields.firstWhere((f) => f.name == 'gadgetGetter');
      expect(gadgetGetter.isCanonical, isTrue);
    });

    test(
        'ExecutableElements from private classes and from public interfaces (#1561)',
        () {
      var MIEEMixinWithOverride = fakeLibrary.publicClasses
          .firstWhere((c) => c.name == 'MIEEMixinWithOverride');
      var problematicOperator = MIEEMixinWithOverride.inheritedOperators
          .firstWhere((o) => o.name == 'operator []=');
      expect(problematicOperator.element.enclosingElement.name,
          equals('_MIEEPrivateOverride'));
      expect(problematicOperator.canonicalModelElement.enclosingElement.name,
          equals('MIEEMixinWithOverride'));
    });
  });

  group('Mixin', () {
    Mixin GenericMixin;
    Class GenericClass, ModifierClass, TypeInferenceMixedIn;
    Field overrideByEverything,
        overrideByGenericMixin,
        overrideByBoth,
        overrideByModifierClass;

    setUpAll(() {
      var classes = fakeLibrary.publicClasses;
      GenericClass = classes.firstWhere((c) => c.name == 'GenericClass');
      ModifierClass = classes.firstWhere((c) => c.name == 'ModifierClass');
      GenericMixin =
          fakeLibrary.publicMixins.firstWhere((m) => m.name == 'GenericMixin');
      TypeInferenceMixedIn =
          classes.firstWhere((c) => c.name == 'TypeInferenceMixedIn');
      overrideByEverything = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'overrideByEverything');
      overrideByGenericMixin = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'overrideByGenericMixin');
      overrideByBoth = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'overrideByBoth');
      overrideByModifierClass = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'overrideByModifierClass');
    });

    test('does have a line number and column', () {
      expect(GenericMixin.characterLocation, isNotNull);
    });

    test(('Verify mixin member is available in findRefElementCache'), () {
      expect(packageGraph.findRefElementCache['GenericMixin.mixinMember'],
          isNotEmpty);
    });

    test(('Verify inheritance/mixin structure and type inference'), () {
      expect(
          TypeInferenceMixedIn.mixins
              .map<String>((DefinedElementType t) => t.element.name),
          orderedEquals(['GenericMixin']));
      expect(
          TypeInferenceMixedIn.mixins.first.typeArguments
              .map<String>((ElementType t) => t.name),
          orderedEquals(['int']));

      expect(TypeInferenceMixedIn.superChain.length, equals(2));
      final ParameterizedElementType firstType =
          TypeInferenceMixedIn.superChain.first;
      final ParameterizedElementType lastType =
          TypeInferenceMixedIn.superChain.last;
      expect(firstType.name, equals('ModifierClass'));
      expect(firstType.typeArguments.map<String>((ElementType t) => t.name),
          orderedEquals(['int']));
      expect(lastType.name, equals('GenericClass'));
      expect(lastType.typeArguments.map<String>((ElementType t) => t.name),
          orderedEquals(['int']));
    });

    test(('Verify non-overridden members have right canonical classes'), () {
      var member = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'member');
      var modifierMember = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'modifierMember');
      var mixinMember = TypeInferenceMixedIn.allInstanceFields
          .firstWhere((f) => f.name == 'mixinMember');
      expect(member.canonicalEnclosingContainer, equals(GenericClass));
      expect(modifierMember.canonicalEnclosingContainer, equals(ModifierClass));
      expect(mixinMember.canonicalEnclosingContainer, equals(GenericMixin));
    });

    test(('Verify overrides & documentation inheritance work as intended'), () {
      expect(overrideByEverything.canonicalEnclosingContainer,
          equals(TypeInferenceMixedIn));
      expect(overrideByGenericMixin.canonicalEnclosingContainer,
          equals(GenericMixin));
      expect(overrideByBoth.canonicalEnclosingContainer, equals(GenericMixin));
      expect(overrideByModifierClass.canonicalEnclosingContainer,
          equals(ModifierClass));
      expect(
          overrideByEverything.documentationFrom.first,
          equals(GenericClass.allInstanceFields
              .firstWhere((f) => f.name == 'overrideByEverything')
              .getter));
      expect(
          overrideByGenericMixin.documentationFrom.first,
          equals(GenericClass.allInstanceFields
              .firstWhere((f) => f.name == 'overrideByGenericMixin')
              .getter));
      expect(
          overrideByBoth.documentationFrom.first,
          equals(GenericClass.allInstanceFields
              .firstWhere((f) => f.name == 'overrideByBoth')
              .getter));
      expect(
          overrideByModifierClass.documentationFrom.first,
          equals(GenericClass.allInstanceFields
              .firstWhere((f) => f.name == 'overrideByModifierClass')
              .getter));
    });

    test(('Verify that documentation for mixin applications contains links'),
        () {
      expect(
          overrideByModifierClass.oneLineDoc,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByModifierClass.canonicalModelElement.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByGenericMixin.oneLineDoc,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/GenericMixin-mixin.html">GenericMixin</a>'));
      expect(
          overrideByGenericMixin.canonicalModelElement.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/GenericMixin-mixin.html">GenericMixin</a>'));
      expect(
          overrideByBoth.oneLineDoc,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByBoth.oneLineDoc,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/GenericMixin-mixin.html">GenericMixin</a>'));
      expect(
          overrideByBoth.canonicalModelElement.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByBoth.canonicalModelElement.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/GenericMixin-mixin.html">GenericMixin</a>'));
    });
  });

  group('Class', () {
    List<Class> classes;
    Class Apple, B, Cat, Cool, Dog, F, Dep, SpecialList;
    Class ExtendingClass, CatString;

    setUpAll(() {
      classes = exLibrary.publicClasses.toList();
      Apple = classes.firstWhere((c) => c.name == 'Apple');
      B = classes.firstWhere((c) => c.name == 'B');
      Cat = classes.firstWhere((c) => c.name == 'Cat');
      Dog = classes.firstWhere((c) => c.name == 'Dog');
      F = classes.firstWhere((c) => c.name == 'F');
      Dep = classes.firstWhere((c) => c.name == 'Deprecated');
      Cool = classes.firstWhere((c) => c.name == 'Cool');
      SpecialList =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SpecialList');
      ExtendingClass =
          twoExportsLib.classes.firstWhere((c) => c.name == 'ExtendingClass');
      CatString = exLibrary.classes.firstWhere((c) => c.name == 'CatString');
    });

    test('has a fully qualified name', () {
      expect(Apple.fullyQualifiedName, 'ex.Apple');
    });

    test('does have a line number and column', () {
      expect(Apple.characterLocation, isNotNull);
    });

    test('we got the classes we expect', () {
      expect(Apple.name, equals('Apple'));
      expect(B.name, equals('B'));
      expect(Cat.name, equals('Cat'));
      expect(Dog.name, equals('Dog'));
    });

    test('a class with only inherited properties has some properties', () {
      expect(CatString.hasInstanceProperties, isFalse);
      expect(CatString.instanceProperties, isEmpty);
      expect(CatString.hasPublicProperties, isTrue);
      expect(CatString.allInstanceFields, isNotEmpty);
    });

    test('has enclosing element', () {
      expect(Apple.enclosingElement.name, equals(exLibrary.name));
    });

    test('class name with generics', () {
      expect(
          F.nameWithGenerics,
          equals(
              'F&lt;<wbr><span class="type-parameter">T extends String</span>&gt;'));
    });

    test('correctly finds all the classes', () {
      expect(classes, hasLength(33));
    });

    test('abstract', () {
      expect(Cat.isAbstract, isTrue);
    });

    test('supertype', () {
      expect(B.hasPublicSuperChainReversed, isTrue);
    });

    test('mixins', () {
      expect(Apple.mixins, hasLength(0));
    });

    test('mixins private', () {
      expect(F.mixins, hasLength(1));
    });

    test('interfaces', () {
      var interfaces = Dog.interfaces;
      expect(interfaces, hasLength(2));
      expect(interfaces[0].name, 'Cat');
      expect(interfaces[1].name, 'E');
    });

    test('class title has abstract keyword', () {
      expect(Cat.fullkind, 'abstract class');
    });

    test('class title has  no abstract keyword', () {
      expect(Dog.fullkind, 'class');
    });

    test('get constructors', () {
      expect(Apple.publicConstructors, hasLength(2));
    });

    test('get static fields', () {
      expect(Apple.publicStaticProperties, hasLength(1));
    });

    test('constructors have source', () {
      var ctor = Dog.constructors.first;
      expect(ctor.sourceCode, isNotEmpty);
    });

    test('get constants', () {
      expect(Apple.publicConstants, hasLength(1));
      expect(Apple.publicConstants.first.kind, equals('constant'));
    });

    test('get instance fields', () {
      expect(Apple.publicInstanceProperties, hasLength(3));
      expect(Apple.publicInstanceProperties.first.kind, equals('property'));
    });

    test('get inherited properties, including properties of Object', () {
      expect(B.publicInheritedProperties, hasLength(4));
    });

    test('get methods', () {
      expect(Dog.publicInstanceMethods, hasLength(22));
    });

    test('get operators', () {
      expect(Dog.publicOperators, hasLength(1));
      expect(Dog.publicOperators.first.name, 'operator ==');
    });

    test('inherited methods, including from Object ', () {
      expect(B.publicInheritedMethods, hasLength(7));
      expect(B.hasPublicInheritedMethods, isTrue);
    });

    test('all instance methods', () {
      expect(B.allPublicInstanceMethods, isNotEmpty);
      expect(
          B.allPublicInstanceMethods.length,
          equals(B.publicInstanceMethods.length +
              B.publicInheritedMethods.length));
    });

    test('inherited methods exist', () {
      expect(B.inheritedMethods.firstWhere((x) => x.name == 'printMsg'),
          isNotNull);
      expect(B.inheritedMethods.firstWhere((x) => x.name == 'isGreaterThan'),
          isNotNull);
    });

    test('exported class should have hrefs from the current library', () {
      expect(
          Dep.href, equals('${HTMLBASE_PLACEHOLDER}ex/Deprecated-class.html'));
      expect(Dep.instanceMethods[0].href,
          equals('${HTMLBASE_PLACEHOLDER}ex/Deprecated/toString.html'));
      expect(Dep.instanceProperties[0].href,
          equals('${HTMLBASE_PLACEHOLDER}ex/Deprecated/expires.html'));
    });

    test('exported class should have linkedReturnType for the current library',
        () {
      var returnCool = Cool.instanceMethods
          .firstWhere((m) => m.name == 'returnCool', orElse: () => null);
      expect(returnCool, isNotNull);
      expect(
          returnCool.linkedReturnType,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/Cool-class.html">Cool</a>'));
    });

    test('F has a single instance method', () {
      expect(F.publicInstanceMethods, hasLength(1));
      expect(
          F.publicInstanceMethods.first.name, equals('methodWithGenericParam'));
    });

    test('F has many inherited methods', () {
      expect(
          F.publicInheritedMethods.map((im) => im.name),
          containsAll([
            'abstractMethod',
            'foo',
            'getAnotherClassD',
            'getClassA',
            'noSuchMethod',
            'test',
            'testGeneric',
            'testGenericMethod',
            'testMethod',
            'toString',
            'withAnimation',
            'withAnimationInline',
            'withAnimationOutOfOrder',
            'withAnimationInOneLineDoc',
            'withDeprecatedAnimation',
            'withMacro',
            'withMacro2',
            'withNamedAnimation',
            'withPrivateMacro',
            'withQuotedNamedAnimation',
            'withUndefinedMacro',
            'withYouTubeInline',
            'withYouTubeInOneLineDoc',
            'withYouTubeWatchUrl',
          ]));
    });

    test('F has zero instance properties', () {
      expect(F.publicInstanceProperties, hasLength(0));
    });

    test('F has a few inherited properties', () {
      expect(F.publicInheritedProperties, hasLength(10));
      expect(
          F.publicInheritedProperties.map((ip) => ip.name),
          containsAll([
            'aFinalField',
            'aGetterReturningRandomThings',
            'aProtectedFinalField',
            'deprecatedField',
            'deprecatedGetter',
            'deprecatedSetter',
            'hashCode',
            'isImplemented',
            'name',
            'runtimeType'
          ]));
    });

    test('SpecialList has zero instance methods', () {
      expect(SpecialList.publicInstanceMethods, hasLength(0));
    });

    test('SpecialList has many inherited methods', () {
      expect(SpecialList.publicInheritedMethods, hasLength(49));
      expect(SpecialList.publicInheritedMethods.first.name, equals('add'));
      expect(SpecialList.publicInheritedMethods.toList()[1].name,
          equals('addAll'));
    });

    test('ExtendingClass is in the right library', () {
      expect(ExtendingClass.library.name, equals('two_exports'));
    });

    // because both the sub and super classes, though from different libraries,
    // are exported out through one library
    test('ExtendingClass has a super class that is also in the same library',
        () {
      // The real implementation of BaseClass is private, but it is exported.
      expect(ExtendingClass.superChain.first.name, equals('BaseClass'));
      expect(
          ExtendingClass.superChain.first.element.isCanonical, equals(false));
      expect(ExtendingClass.superChain.first.element.isPublic, equals(false));
      // And it should still show up in the publicSuperChain, because it is
      // exported.
      expect(ExtendingClass.publicSuperChain.first.name, equals('BaseClass'));
      expect(
          ExtendingClass.publicSuperChain.first.element.canonicalLibrary.name,
          equals('two_exports'));
    });

    test(
        "ExtendingClass's super class has a library that is not in two_exports",
        () {
      expect(
          ExtendingClass.superChain.last.name, equals('WithGetterAndSetter'));
      expect(
          ExtendingClass.superChain.last.element.library.name, equals('fake'));
    });
  });

  group('Extension', () {
    Extension arm, leg, ext, fancyList, uphill;
    Extension documentOnceReexportOne, documentOnceReexportTwo;
    Library reexportOneLib, reexportTwoLib;
    Class apple,
        anotherExtended,
        baseTest,
        bigAnotherExtended,
        extensionReferencer,
        megaTron,
        superMegaTron,
        string;
    Method doSomeStuff, doStuff, s;
    List<Extension> extensions;

    setUpAll(() {
      reexportOneLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_one');
      reexportTwoLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_two');
      documentOnceReexportOne = reexportOneLib.extensions
          .firstWhere((e) => e.name == 'DocumentThisExtensionOnce');
      documentOnceReexportTwo = reexportTwoLib.extensions
          .firstWhere((e) => e.name == 'DocumentThisExtensionOnce');
      string = packageGraph.allLibraries.values
          .firstWhere((e) => e.name == 'dart:core')
          .allClasses
          .firstWhere((c) => c.name == 'String');
      apple = exLibrary.classes.firstWhere((e) => e.name == 'Apple');
      ext = exLibrary.extensions.firstWhere((e) => e.name == 'AppleExtension');
      extensionReferencer =
          exLibrary.classes.firstWhere((c) => c.name == 'ExtensionReferencer');
      fancyList = exLibrary.extensions.firstWhere((e) => e.name == 'FancyList');
      doSomeStuff = exLibrary.classes
          .firstWhere((c) => c.name == 'ExtensionUser')
          .allInstanceMethods
          .firstWhere((m) => m.name == 'doSomeStuff');
      doStuff = exLibrary.extensions
          .firstWhere((e) => e.name == 'SimpleStringExtension')
          .instanceMethods
          .firstWhere((m) => m.name == 'doStuff');
      extensions = exLibrary.publicExtensions.toList();
      baseTest = fakeLibrary.classes.firstWhere((e) => e.name == 'BaseTest');
      bigAnotherExtended =
          fakeLibrary.classes.firstWhere((e) => e.name == 'BigAnotherExtended');
      anotherExtended =
          fakeLibrary.classes.firstWhere((e) => e.name == 'AnotherExtended');
      arm = fakeLibrary.extensions.firstWhere((e) => e.name == 'Arm');
      leg = fakeLibrary.extensions.firstWhere((e) => e.name == 'Leg');
      uphill = fakeLibrary.extensions.firstWhere((e) => e.name == 'Uphill');
      megaTron = fakeLibrary.classes.firstWhere((e) => e.name == 'Megatron');
      superMegaTron =
          fakeLibrary.classes.firstWhere((e) => e.name == 'SuperMegaTron');
    });

    test('basic canonicalization for extensions', () {
      expect(documentOnceReexportOne.isCanonical, isFalse);
      expect(
          documentOnceReexportOne.href, equals(documentOnceReexportTwo.href));
      expect(documentOnceReexportTwo.isCanonical, isTrue);
    });

    test('classes know about applicableExtensions', () {
      expect(apple.potentiallyApplicableExtensions, orderedEquals([ext]));
      expect(string.potentiallyApplicableExtensions,
          isNot(contains(documentOnceReexportOne)));
      expect(string.potentiallyApplicableExtensions,
          contains(documentOnceReexportTwo));
      expect(baseTest.potentiallyApplicableExtensions, isEmpty);
      expect(anotherExtended.potentiallyApplicableExtensions,
          orderedEquals([uphill]));
      expect(bigAnotherExtended.potentiallyApplicableExtensions,
          orderedEquals([uphill]));
    });

    test('extensions on special types work', () {
      Extension extensionOnDynamic,
          extensionOnVoid,
          extensionOnNull,
          extensionOnTypeParameter;
      var object = packageGraph.specialClasses[SpecialClass.object];
      Extension getExtension(String name) =>
          fakeLibrary.extensions.firstWhere((e) => e.name == name);

      extensionOnDynamic = getExtension('ExtensionOnDynamic');
      extensionOnNull = getExtension('ExtensionOnNull');
      extensionOnVoid = getExtension('ExtensionOnVoid');
      extensionOnTypeParameter = getExtension('ExtensionOnTypeParameter');

      expect(extensionOnDynamic.couldApplyTo(object), isTrue);
      expect(extensionOnVoid.couldApplyTo(object), isTrue);
      expect(extensionOnNull.couldApplyTo(object), isFalse);
      expect(extensionOnTypeParameter.couldApplyTo(object), isTrue);

      expect(extensionOnDynamic.alwaysApplies, isTrue);
      expect(extensionOnVoid.alwaysApplies, isTrue);
      expect(extensionOnNull.alwaysApplies, isFalse);
      expect(extensionOnTypeParameter.alwaysApplies, isTrue);

      // Even though it does have extensions that could apply to it,
      // extensions that apply to [Object] should always be hidden from
      // documentation.
      expect(object.hasPotentiallyApplicableExtensions, isFalse);
    });

    test('applicableExtensions include those from implements & mixins', () {
      Extension extensionCheckLeft,
          extensionCheckRight,
          extensionCheckCenter,
          extensionCheckImplementor2,
          onNewSchool,
          onOldSchool;
      Class implementor, implementor2, school;
      Extension getExtension(String name) =>
          fakeLibrary.extensions.firstWhere((e) => e.name == name);
      Class getClass(String name) =>
          fakeLibrary.classes.firstWhere((e) => e.name == name);
      extensionCheckLeft = getExtension('ExtensionCheckLeft');
      extensionCheckRight = getExtension('ExtensionCheckRight');
      extensionCheckCenter = getExtension('ExtensionCheckCenter');
      extensionCheckImplementor2 = getExtension('ExtensionCheckImplementor2');
      onNewSchool = getExtension('OnNewSchool');
      onOldSchool = getExtension('OnOldSchool');

      implementor = getClass('Implementor');
      implementor2 = getClass('Implementor2');
      school = getClass('School');

      expect(
          implementor.potentiallyApplicableExtensions,
          orderedEquals([
            extensionCheckCenter,
            extensionCheckImplementor2,
            extensionCheckLeft,
            extensionCheckRight
          ]));
      expect(implementor2.potentiallyApplicableExtensions,
          orderedEquals([extensionCheckImplementor2, extensionCheckLeft]));
      expect(school.potentiallyApplicableExtensions,
          orderedEquals([onNewSchool, onOldSchool]));
    });

    test('type parameters and bounds work with applicableExtensions', () {
      expect(
          superMegaTron.potentiallyApplicableExtensions, orderedEquals([leg]));
      expect(
          megaTron.potentiallyApplicableExtensions, orderedEquals([arm, leg]));
    });

    // TODO(jcollins-g): implement feature and update tests
    test('documentation links do not crash in base cases', () {
      packageGraph.packageWarningCounter.hasWarning(
          doStuff,
          PackageWarning.notImplemented,
          'Comment reference resolution inside extension methods is not yet implemented');
      packageGraph.packageWarningCounter.hasWarning(
          doSomeStuff,
          PackageWarning.notImplemented,
          'Comment reference resolution inside extension methods is not yet implemented');
      expect(doStuff.documentationAsHtml, contains('<code>another</code>'));
      expect(doSomeStuff.documentationAsHtml,
          contains('<code>String.extensionNumber</code>'));
    });

    test(
        'references from outside an extension refer correctly to the extension',
        () {
      expect(extensionReferencer.documentationAsHtml,
          contains('<code>_Shhh</code>'));
      expect(
          extensionReferencer.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/FancyList.html">FancyList</a>'));
      expect(
          extensionReferencer.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/AnExtension/call.html">AnExtension.call</a>'));
      expect(
          extensionReferencer.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}reexport_two/DocumentThisExtensionOnce.html">DocumentThisExtensionOnce</a>'));
    });

    test('has a fully qualified name', () {
      expect(ext.fullyQualifiedName, 'ex.AppleExtension');
    });

    test('does have a line number and column', () {
      expect(ext.characterLocation, isNotNull);
    });

    test('has enclosing element', () {
      expect(ext.enclosingElement.name, equals(exLibrary.name));
    });

    test('member method has href', () {
      s = ext.instanceMethods.firstWhere((m) => m.name == 's');
      expect(s.href, '${HTMLBASE_PLACEHOLDER}ex/AppleExtension/s.html');
    });

    test('has extended type', () {
      expect(ext.extendedType.name, equals('Apple'));
    });

    test('extension name with generics', () {
      expect(
          fancyList.nameWithGenerics,
          equals(
              'FancyList&lt;<wbr><span class="type-parameter">Z</span>&gt;'));
    });

    test('extended type has generics', () {
      expect(fancyList.extendedType.nameWithGenerics,
          equals('List&lt;<wbr><span class="type-parameter">Z</span>&gt;'));
    });

    test('get methods', () {
      expect(fancyList.allPublicInstanceMethods, hasLength(1));
    });

    test('get operators', () {
      expect(fancyList.allPublicOperators, hasLength(1));
    });

    test('get static methods', () {
      expect(fancyList.publicStaticMethods, hasLength(1));
    });

    test('get properties', () {
      expect(fancyList.publicInstanceProperties, hasLength(1));
    });

    test('get contants', () {
      expect(fancyList.publicConstants, hasLength(0));
    });

    test('correctly finds all the extensions', () {
      expect(exLibrary.extensions, hasLength(8));
    });

    test('correctly finds all the public extensions', () {
      expect(extensions, hasLength(6));
    });
  });

  group('Enum', () {
    Enum animal;
    Method animalToString;

    setUpAll(() {
      animal = exLibrary.enums.firstWhere((e) => e.name == 'Animal');
      animalToString =
          animal.allInstanceMethods.firstWhere((m) => m.name == 'toString');

      /// Trigger code reference resolution
      animal.documentationAsHtml;
    });

    test('has a fully qualified name', () {
      expect(animal.fullyQualifiedName, 'ex.Animal');
    });

    test('toString() method location is handled specially', () {
      expect(animalToString.characterLocation, isNotNull);
      expect(animalToString.characterLocation.toString(),
          equals(animal.characterLocation.toString()));
    });

    test('has enclosing element', () {
      expect(animal.enclosingElement.name, equals(exLibrary.name));
    });

    test('has correct number of constants', () {
      expect(animal.constants, hasLength(4));
    });

    test('has a (synthetic) values constant', () {
      var valuesField = animal.constants.firstWhere((f) => f.name == 'values');
      expect(valuesField, isNotNull);
      expect(valuesField.constantValue,
          equals(EnumFieldRendererHtml().renderValue(valuesField)));
      expect(valuesField.documentation, startsWith('A constant List'));
    });

    test('has a constant that does not link anywhere', () {
      var dog = animal.constants.firstWhere((f) => f.name == 'DOG');
      expect(dog.linkedName, equals('DOG'));
      expect(dog.isConst, isTrue);
      expect(
          dog.constantValue, equals(EnumFieldRendererHtml().renderValue(dog)));
      expect(dog.extendedDocLink, equals(''));
    });

    test('constants have correct indicies', () {
      String valueByName(var name) {
        return animal.constants.firstWhere((f) => f.name == name).constantValue;
      }

      expect(valueByName('CAT'), equals('const Animal(0)'));
      expect(valueByName('DOG'), equals('const Animal(1)'));
      expect(valueByName('HORSE'), equals('const Animal(2)'));
    });

    test('has a single `index` property', () {
      expect(animal.instanceProperties, hasLength(1));
      expect(animal.instanceProperties.first, isNotNull);
      expect(animal.instanceProperties.first.name, equals('index'));
    });

    test('has a single `index` property that is not linked', () {
      expect(animal.instanceProperties.first.linkedName, equals('index'));
    });
  });

  group('Function', () {
    ModelFunction f1;
    ModelFunction genericFunction;
    ModelFunction paramOfFutureOrNull;
    ModelFunction thisIsAsync;
    ModelFunction thisIsFutureOr;
    ModelFunction thisIsFutureOrNull;
    ModelFunction thisIsFutureOrT;
    ModelFunction topLevelFunction;
    ModelFunction typeParamOfFutureOr;
    ModelFunction doAComplicatedThing;

    setUpAll(() {
      f1 = exLibrary.functions.first;
      genericFunction =
          exLibrary.functions.firstWhere((f) => f.name == 'genericFunction');
      paramOfFutureOrNull = fakeLibrary.functions
          .firstWhere((f) => f.name == 'paramOfFutureOrNull');
      thisIsAsync =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsAsync');
      thisIsFutureOr =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsFutureOr');
      thisIsFutureOrNull = fakeLibrary.functions
          .firstWhere((f) => f.name == 'thisIsFutureOrNull');
      thisIsFutureOrT =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsFutureOrT');
      topLevelFunction =
          fakeLibrary.functions.firstWhere((f) => f.name == 'topLevelFunction');
      typeParamOfFutureOr = fakeLibrary.functions
          .firstWhere((f) => f.name == 'typeParamOfFutureOr');
      doAComplicatedThing = fakeLibrary.functions
          .firstWhere((f) => f.name == 'doAComplicatedThing');
    });

    test('has a fully qualified name', () {
      expect(thisIsAsync.fullyQualifiedName, 'fake.thisIsAsync');
    });

    test('does have a line number and column', () {
      expect(thisIsAsync.characterLocation, isNotNull);
    });

    test('has enclosing element', () {
      expect(f1.enclosingElement.name, equals(exLibrary.name));
    });

    test('name is function1', () {
      expect(f1.name, 'function1');
    });

    test('local element', () {
      expect(f1.isLocalElement, true);
    });

    test('is executable', () {
      expect(f1.isExecutable, true);
    });

    test('is static', () {
      expect(f1.isStatic, true);
    });

    test('handles dynamic parameters correctly', () {
      expect(ParameterRendererHtml().renderLinkedParams(f1.parameters),
          contains('lastParam'));
    });

    test('async function', () {
      expect(thisIsAsync.isAsynchronous, isTrue);
      expect(thisIsAsync.linkedReturnType, equals('Future'));
      expect(
          thisIsAsync.documentation,
          equals(
              'An async function. It should look like I return a [Future].'));
      expect(
          thisIsAsync.documentationAsHtml,
          equals(
              '<p>An async function. It should look like I return a <code>Future</code>.</p>'));
    });

    test('function returning FutureOr', () {
      expect(thisIsFutureOr.isAsynchronous, isFalse);
      expect(thisIsFutureOr.linkedReturnType, equals('FutureOr'));
    });

    test('function returning FutureOr<Null>', () {
      expect(thisIsFutureOrNull.isAsynchronous, isFalse);
      expect(
          thisIsFutureOrNull.linkedReturnType,
          equals(
              'FutureOr<span class="signature">&lt;<wbr><span class="type-parameter">Null</span>&gt;</span>'));
    });

    test('function returning FutureOr<T>', () {
      expect(thisIsFutureOrNull.isAsynchronous, isFalse);
      expect(
          thisIsFutureOrT.linkedReturnType,
          equals(
              'FutureOr<span class="signature">&lt;<wbr><span class="type-parameter">T</span>&gt;</span>'));
    });

    test('function with a parameter having type FutureOr<Null>', () {
      expect(
          ParameterRendererHtml()
              .renderLinkedParams(paramOfFutureOrNull.parameters),
          equals(
              '<span class="parameter" id="paramOfFutureOrNull-param-future"><span class="type-annotation">FutureOr<span class="signature">&lt;<wbr><span class="type-parameter">Null</span>&gt;</span></span> <span class="parameter-name">future</span></span><wbr>'));
    });

    test('function with a bound type to FutureOr', () {
      expect(
          typeParamOfFutureOr.linkedGenericParameters,
          equals(
              '<span class="signature">&lt;<wbr><span class="type-parameter">T extends FutureOr<span class="signature">&lt;<wbr><span class="type-parameter">List</span>&gt;</span></span>&gt;</span>'));
    });

    test('docs do not lose brackets in code blocks', () {
      expect(topLevelFunction.documentation, contains("['hello from dart']"));
    });

    test('has source code', () {
      expect(topLevelFunction.sourceCode, startsWith('@deprecated'));
      expect(topLevelFunction.sourceCode, endsWith('''
String topLevelFunction(int param1, bool param2, Cool coolBeans,
    [double optionalPositional = 0.0]) {
  return null;
}'''));
    });

    test('typedef params have proper signature', () {
      var function =
          fakeLibrary.functions.firstWhere((f) => f.name == 'addCallback');
      var params =
          ParameterRendererHtml().renderLinkedParams(function.parameters);
      expect(
          params,
          '<span class="parameter" id="addCallback-param-callback">'
          '<span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}fake/VoidCallback.html">VoidCallback</a></span> '
          '<span class="parameter-name">callback</span></span><wbr>');

      function =
          fakeLibrary.functions.firstWhere((f) => f.name == 'addCallback2');
      params = ParameterRendererHtml().renderLinkedParams(function.parameters);
      expect(
          params,
          '<span class="parameter" id="addCallback2-param-callback">'
          '<span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}fake/Callback2.html">Callback2</a></span> '
          '<span class="parameter-name">callback</span></span><wbr>');
    });

    test('supports generic methods', () {
      expect(genericFunction.nameWithGenerics,
          'genericFunction&lt;<wbr><span class="type-parameter">T</span>&gt;');
    });

    test('can resolve functions as parameters', () {
      var params = ParameterRendererHtml()
          .renderLinkedParams(doAComplicatedThing.parameters);
      expect(params,
          '<span class="parameter" id="doAComplicatedThing-param-x"><span class="type-annotation">int</span> <span class="parameter-name">x</span>, </span><wbr><span class="parameter" id="doAComplicatedThing-param-doSomething">{<span class="type-annotation">void</span> <span class="parameter-name">doSomething</span>(<span class="parameter" id="param-aThingParameter"><span class="type-annotation">int</span> <span class="parameter-name">aThingParameter</span>, </span><wbr><span class="parameter" id="param-anotherThing"><span class="type-annotation">String</span> <span class="parameter-name">anotherThing</span></span><wbr>), </span><wbr><span class="parameter" id="doAComplicatedThing-param-doSomethingElse"><span class="type-annotation">void</span> <span class="parameter-name">doSomethingElse</span>(<span class="parameter" id="param-aThingParameter"><span class="type-annotation">int</span> <span class="parameter-name">aThingParameter</span>, </span><wbr><span class="parameter" id="param-somethingElse"><span class="type-annotation">double</span> <span class="parameter-name">somethingElse</span></span><wbr>)}</span><wbr>');
    });
  });

  group('Type expansion', () {
    Class TemplatedInterface, ClassWithUnusualProperties;

    setUpAll(() {
      TemplatedInterface =
          exLibrary.classes.singleWhere((c) => c.name == 'TemplatedInterface');
      ClassWithUnusualProperties = fakeLibrary.classes
          .singleWhere((c) => c.name == 'ClassWithUnusualProperties');
    });

    test('setter that takes a function is correctly displayed', () {
      var explicitSetter = ClassWithUnusualProperties.instanceProperties
          .singleWhere((f) => f.name == 'explicitSetter');
      // TODO(jcollins-g): really, these shouldn't be called "parameters" in
      // the span class.
      expect(explicitSetter.linkedReturnType,
          '<span class="parameter" id="explicitSetter=-param-f"><span class="type-annotation">dynamic</span> <span class="parameter-name">Function</span>(<span class="parameter" id="param-bar"><span class="type-annotation">int</span>, </span><wbr><span class="parameter" id="param-baz"><span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}fake/Cool-class.html">Cool</a></span>, </span><wbr><span class="parameter" id="param-macTruck"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span></span><wbr>)</span><wbr>');
    });

    test('parameterized type from field is correctly displayed', () {
      var aField = TemplatedInterface.instanceProperties
          .singleWhere((f) => f.name == 'aField');
      expect(aField.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">Stream<span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span></span>&gt;</span>');
    });

    test('parameterized type from inherited field is correctly displayed', () {
      var aInheritedField = TemplatedInterface.inheritedProperties
          .singleWhere((f) => f.name == 'aInheritedField');
      expect(aInheritedField.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from explicit getter is correctly displayed',
        () {
      Accessor aGetter = TemplatedInterface.instanceProperties
          .singleWhere((f) => f.name == 'aGetter')
          .getter;
      expect(aGetter.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">Map<span class="signature">&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">String</span>&gt;</span></span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from inherited explicit getter is correctly displayed',
        () {
      Accessor aInheritedGetter = TemplatedInterface.inheritedProperties
          .singleWhere((f) => f.name == 'aInheritedGetter')
          .getter;
      expect(aInheritedGetter.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from inherited explicit setter is correctly displayed',
        () {
      Accessor aInheritedSetter = TemplatedInterface.inheritedProperties
          .singleWhere((f) => f.name == 'aInheritedSetter')
          .setter;
      expect(aInheritedSetter.allParameters.first.modelType.linkedName,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
      // TODO(jcollins-g): really, these shouldn't be called "parameters" in
      // the span class.
      expect(aInheritedSetter.enclosingCombo.linkedReturnType,
          '<span class="parameter" id="aInheritedSetter=-param-thingToSet"><span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span></span></span><wbr>');
    });

    test(
        'parameterized type for return value from method is correctly displayed',
        () {
      var aMethodInterface = TemplatedInterface.allInstanceMethods
          .singleWhere((m) => m.name == 'aMethodInterface');
      expect(aMethodInterface.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from inherited method is correctly displayed',
        () {
      var aInheritedMethod = TemplatedInterface.allInstanceMethods
          .singleWhere((m) => m.name == 'aInheritedMethod');
      expect(aInheritedMethod.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value containing a parameterized typedef is correctly displayed',
        () {
      var aTypedefReturningMethodInterface = TemplatedInterface
          .allInstanceMethods
          .singleWhere((m) => m.name == 'aTypedefReturningMethodInterface');
      expect(aTypedefReturningMethodInterface.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">String</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value containing a parameterized typedef from inherited method is correctly displayed',
        () {
      var aInheritedTypedefReturningMethod = TemplatedInterface
          .allInstanceMethods
          .singleWhere((m) => m.name == 'aInheritedTypedefReturningMethod');
      expect(aInheritedTypedefReturningMethod.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test('parameterized types for inherited operator is correctly displayed',
        () {
      var aInheritedAdditionOperator = TemplatedInterface.inheritedOperators
          .singleWhere((m) => m.name == 'operator +');
      expect(aInheritedAdditionOperator.linkedReturnType,
          '<a href="${HTMLBASE_PLACEHOLDER}ex/ParameterizedClass-class.html">ParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
      expect(
          ParameterRendererHtml()
              .renderLinkedParams(aInheritedAdditionOperator.parameters),
          '<span class="parameter" id="+-param-other"><span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}ex/ParameterizedClass-class.html">ParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span></span> <span class="parameter-name">other</span></span><wbr>');
    });

    test('', () {});
  });

  group('Method', () {
    Class classB,
        klass,
        HasGenerics,
        Cat,
        CatString,
        TypedFunctionsWithoutTypedefs;
    Method m1, isGreaterThan, m4, m5, m6, m7, convertToMap, abstractMethod;
    Method inheritedClear, testGeneric, testGenericMethod;
    Method getAFunctionReturningVoid, getAFunctionReturningBool;

    setUpAll(() {
      klass = exLibrary.classes.singleWhere((c) => c.name == 'Klass');
      classB = exLibrary.classes.singleWhere((c) => c.name == 'B');
      HasGenerics =
          fakeLibrary.classes.singleWhere((c) => c.name == 'HasGenerics');
      CatString = exLibrary.classes.singleWhere((c) => c.name == 'CatString');
      Cat = exLibrary.classes.singleWhere((c) => c.name == 'Cat');
      inheritedClear =
          CatString.inheritedMethods.singleWhere((m) => m.name == 'clear');
      m1 = classB.instanceMethods.singleWhere((m) => m.name == 'm1');
      isGreaterThan = exLibrary.classes
          .singleWhere((c) => c.name == 'Apple')
          .instanceMethods
          .singleWhere((m) => m.name == 'isGreaterThan');
      m4 = classB.instanceMethods.singleWhere((m) => m.name == 'writeMsg');
      m5 = klass.instanceMethods.singleWhere((m) => m.name == 'another');
      m6 = klass.instanceMethods.singleWhere((m) => m.name == 'toString');
      m7 = classB.instanceMethods.singleWhere((m) => m.name == 'doNothing');
      abstractMethod =
          Cat.instanceMethods.singleWhere((m) => m.name == 'abstractMethod');
      testGeneric = exLibrary.classes
          .singleWhere((c) => c.name == 'Dog')
          .instanceMethods
          .singleWhere((m) => m.name == 'testGeneric');
      testGenericMethod = exLibrary.classes
          .singleWhere((c) => c.name == 'Dog')
          .instanceMethods
          .singleWhere((m) => m.name == 'testGenericMethod');
      convertToMap = HasGenerics.instanceMethods
          .singleWhere((m) => m.name == 'convertToMap');
      TypedFunctionsWithoutTypedefs = exLibrary.classes
          .singleWhere((c) => c.name == 'TypedFunctionsWithoutTypedefs');
      getAFunctionReturningVoid = TypedFunctionsWithoutTypedefs.instanceMethods
          .singleWhere((m) => m.name == 'getAFunctionReturningVoid');
      getAFunctionReturningBool = TypedFunctionsWithoutTypedefs.instanceMethods
          .singleWhere((m) => m.name == 'getAFunctionReturningBool');
    });

    test('does have a line number and column', () {
      expect(abstractMethod.characterLocation, isNotNull);
    });

    test('verify parameter types are correctly displayed', () {
      expect(
          getAFunctionReturningVoid.linkedReturnType,
          equals(
              'void Function<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">T1</span>, </span><wbr><span class="parameter" id="param-"><span class="type-annotation">T2</span></span><wbr>)</span>'));
    });

    test(
        'verify type parameters to anonymous functions are distinct from normal parameters and instantiated type parameters from method, displayed correctly',
        () {
      expect(
          getAFunctionReturningBool.linkedReturnType,
          equals(
              'bool Function&lt;<wbr><span class="type-parameter">T4</span>&gt;<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">String</span>, </span><wbr><span class="parameter" id="param-"><span class="type-annotation">T1</span>, </span><wbr><span class="parameter" id="param-"><span class="type-annotation">T4</span></span><wbr>)</span>'));
    });

    test('has a fully qualified name', () {
      expect(m1.fullyQualifiedName, 'ex.B.m1');
    });

    test('has abstract kind', () {
      expect(abstractMethod.fullkind, 'abstract method');
    });

    test('returns correct overriddenDepth', () {
      final bAbstractMethod = classB.allInstanceMethods
          .firstWhere((m) => m.name == 'abstractMethod');
      expect(abstractMethod.overriddenDepth, equals(0));
      expect(bAbstractMethod.overriddenDepth, equals(1));
    });

    test(
        'an inherited method has class as the enclosing class, when superclass not in package',
        () {
      expect(inheritedClear.enclosingElement.name, equals('CatString'));
    });

    test(
        'inherited method has the current library, when superclass library not in package',
        () {
      expect(inheritedClear.library.name, equals('ex'));
    });

    test(
        'an inherited method from the core SDK has a href relative to the package class',
        () {
      expect(inheritedClear.href,
          equals('${HTMLBASE_PLACEHOLDER}ex/CatString/clear.html'));
    });

    test(
        'an inherited method has linked to enclosed class name when superclass not in package',
        () {
      expect(
          inheritedClear.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/CatString/clear.html">clear</a>'));
    });

    test('has enclosing element', () {
      expect(m1.enclosingElement.name, equals(classB.name));
    });

    test('overriden method', () {
      expect(m1.overriddenElement.runtimeType.toString(), 'Method');
    });

    test('method documentation', () {
      expect(m1.documentation,
          equals('This is a method.\n\n    new Apple().m1();'));
    });

    test('can have params', () {
      expect(isGreaterThan.canHaveParameters, isTrue);
    });

    test('has parameters', () {
      expect(isGreaterThan.hasParameters, isTrue);
    });

    test('return type', () {
      expect(isGreaterThan.modelType.createLinkedReturnTypeName(), 'bool');
    });

    test('return type has Future', () {
      expect(m7.linkedReturnType, contains('Future'));
    });

    test('parameter has generics in signature', () {
      expect(testGeneric.parameters[0].modelType.linkedName,
          'Map<span class="signature">&lt;<wbr><span class="type-parameter">String</span>, <span class="type-parameter">dynamic</span>&gt;</span>');
    });

    test('parameter is a function', () {
      var functionArgParam = m4.parameters[1];
      expect(functionArgParam.modelType.createLinkedReturnTypeName(), 'String');
    });

    test('method overrides another', () {
      expect(m1.isOverride, isTrue);
      expect(m1.features, contains('override'));
    });

    test('generic method type args are rendered', () {
      expect(testGenericMethod.nameWithGenerics,
          'testGenericMethod&lt;<wbr><span class="type-parameter">T</span>&gt;');
    });

    test('doc for method with no return type', () {
      var comment = m5.documentation;
      var comment2 = m6.documentation;
      expect(comment, equals('Another method'));
      expect(comment2, equals('A shadowed method'));
    });

    test('method source code indents correctly', () {
      expect(convertToMap.sourceCode,
          'Map&lt;X, Y&gt; convertToMap() =&gt; null;');
    });
  });

  group('Operators', () {
    Class specializedDuration;
    Operator plus, equalsOverride;

    setUpAll(() {
      specializedDuration =
          exLibrary.classes.firstWhere((c) => c.name == 'SpecializedDuration');
      plus = specializedDuration.allOperators
          .firstWhere((o) => o.name == 'operator +');
      equalsOverride = exLibrary.classes
          .firstWhere((c) => c.name == 'Dog')
          .allOperators
          .firstWhere((o) => o.name == 'operator ==');
    });

    test('can be an override', () {
      expect(equalsOverride.isInherited, isFalse);
      expect(equalsOverride.isOverride, isTrue);
    });

    test('has a fully qualified name', () {
      expect(plus.fullyQualifiedName, 'ex.SpecializedDuration.+');
    });

    test('can be inherited', () {
      expect(plus.isInherited, isTrue);
      expect(plus.isOverride, isFalse);
    });

    test('if inherited, and superclass not in package', () {
      expect(plus.enclosingElement.name, equals('SpecializedDuration'));
    });

    test("if inherited, has the class's library", () {
      expect(plus.library.name, 'ex');
    });

    test('if inherited, has a href relative to enclosed class', () {
      expect(
          plus.href,
          equals(
              '${HTMLBASE_PLACEHOLDER}ex/SpecializedDuration/operator_plus.html'));
    });

    test('if inherited and superclass not in package, link to enclosed class',
        () {
      expect(
          plus.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/SpecializedDuration/operator_plus.html">operator +</a>'));
    });
  });

  group('Field', () {
    Class c, LongFirstLine, CatString, UnusualProperties;
    Field f1, f2, constField, dynamicGetter, onlySetter;
    Field lengthX;
    Field sFromApple, mFromApple, mInB, autoCompress;
    Field isEmpty;
    Field implicitGetterExplicitSetter, explicitGetterImplicitSetter;
    Field explicitGetterSetter;
    Field explicitNonDocumentedInBaseClassGetter;
    Field documentedPartialFieldInSubclassOnly;
    Field finalProperty;
    Field ExtraSpecialListLength;
    Field aProperty;
    Field covariantField, covariantSetter;

    setUpAll(() {
      c = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      f1 = c.staticProperties[0]; // n
      f2 = c.instanceProperties[0];
      constField = c.constants[0]; // string
      LongFirstLine =
          fakeLibrary.classes.firstWhere((c) => c.name == 'LongFirstLine');
      CatString = exLibrary.classes.firstWhere((c) => c.name == 'CatString');

      UnusualProperties = fakeLibrary.classes
          .firstWhere((c) => c.name == 'ClassWithUnusualProperties');
      implicitGetterExplicitSetter = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'implicitGetterExplicitSetter');
      explicitGetterImplicitSetter = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'explicitGetterImplicitSetter');
      explicitGetterSetter = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'explicitGetterSetter');
      explicitNonDocumentedInBaseClassGetter =
          UnusualProperties.allModelElements.firstWhere(
              (e) => e.name == 'explicitNonDocumentedInBaseClassGetter');
      documentedPartialFieldInSubclassOnly = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'documentedPartialFieldInSubclassOnly');
      finalProperty = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'finalProperty');

      isEmpty =
          CatString.allInstanceFields.firstWhere((p) => p.name == 'isEmpty');
      dynamicGetter = LongFirstLine.instanceProperties
          .firstWhere((p) => p.name == 'dynamicGetter');
      onlySetter = LongFirstLine.instanceProperties
          .firstWhere((p) => p.name == 'onlySetter');

      lengthX = fakeLibrary.classes
          .firstWhere((c) => c.name == 'WithGetterAndSetter')
          .allInstanceFields
          .firstWhere((c) => c.name == 'lengthX');

      var appleClass =
          exLibrary.allClasses.firstWhere((c) => c.name == 'Apple');

      sFromApple =
          appleClass.allInstanceFields.firstWhere((p) => p.name == 's');
      mFromApple =
          appleClass.allInstanceFields.singleWhere((p) => p.name == 'm');

      mInB = exLibrary.allClasses
          .firstWhere((c) => c.name == 'B')
          .allInstanceFields
          .firstWhere((p) => p.name == 'm');
      autoCompress = exLibrary.allClasses
          .firstWhere((c) => c.name == 'B')
          .allInstanceFields
          .firstWhere((p) => p.name == 'autoCompress');
      ExtraSpecialListLength = fakeLibrary.classes
          .firstWhere((c) => c.name == 'SpecialList')
          .allInstanceFields
          .firstWhere((f) => f.name == 'length');
      aProperty = fakeLibrary.classes
          .firstWhere((c) => c.name == 'AClassWithFancyProperties')
          .allInstanceFields
          .firstWhere((f) => f.name == 'aProperty');
      covariantField = fakeLibrary.classes
          .firstWhere((c) => c.name == 'CovariantMemberParams')
          .allInstanceFields
          .firstWhere((f) => f.name == 'covariantField');
      covariantSetter = fakeLibrary.classes
          .firstWhere((c) => c.name == 'CovariantMemberParams')
          .allInstanceFields
          .firstWhere((f) => f.name == 'covariantSetter');
    });

    test('Fields always have line and column information', () {
      expect(implicitGetterExplicitSetter.characterLocation, isNotNull);
      expect(explicitGetterImplicitSetter.characterLocation, isNotNull);
      expect(explicitGetterSetter.characterLocation, isNotNull);
      expect(constField.characterLocation, isNotNull);
      expect(aProperty.characterLocation, isNotNull);
    });

    test('covariant fields are recognized', () {
      expect(covariantField.isCovariant, isTrue);
      expect(covariantField.featuresAsString, contains('covariant'));
      expect(covariantSetter.isCovariant, isTrue);
      expect(covariantSetter.setter.isCovariant, isTrue);
      expect(covariantSetter.featuresAsString, contains('covariant'));
    });

    test('indentation is not lost inside indented code samples', () {
      expect(
          aProperty.documentation,
          equals(
              'This property is quite fancy, and requires sample code to understand.\n'
              '\n'
              '```dart\n'
              'AClassWithFancyProperties x = new AClassWithFancyProperties();\n'
              '\n'
              'if (x.aProperty.contains(\'Hello\')) {\n'
              '  print("I am indented!");\n'
              '  if (x.aProperty.contains(\'World\')) {\n'
              '    print ("I am indented even more!!!");\n'
              '  }\n'
              '}\n'
              '```'));
    });

    test('annotations from getters and setters are accumulated in Fields', () {
      expect(
          explicitGetterSetter.featuresAsString.contains('a Getter Annotation'),
          isTrue);
      expect(
          explicitGetterSetter.featuresAsString.contains('a Setter Annotation'),
          isTrue);
    });

    test('Docs from inherited implicit accessors are preserved', () {
      expect(
          explicitGetterImplicitSetter.setter.documentationComment, isNot(''));
    });

    test('@nodoc on simple property works', () {
      Field simpleHidden = UnusualProperties.allModelElements.firstWhere(
          (e) => e.name == 'simpleHidden' && e.isPublic,
          orElse: () => null);
      expect(simpleHidden, isNull);
    });

    test('@nodoc on explicit getters/setters hides entire field', () {
      Field explicitNodocGetterSetter = UnusualProperties.allModelElements
          .firstWhere(
              (e) => e.name == 'explicitNodocGetterSetter' && e.isPublic,
              orElse: () => null);
      expect(explicitNodocGetterSetter, isNull);
    });

    test(
        '@nodoc overridden in subclass with explicit getter over simple property works',
        () {
      expect(documentedPartialFieldInSubclassOnly.isPublic, isTrue);
      expect(documentedPartialFieldInSubclassOnly.readOnly, isTrue);
      expect(documentedPartialFieldInSubclassOnly.documentationComment,
          contains('This getter is documented'));
      expect(
          documentedPartialFieldInSubclassOnly.annotations
              .contains('inherited-setter'),
          isFalse);
    });

    test('@nodoc overridden in subclass for getter works', () {
      expect(explicitNonDocumentedInBaseClassGetter.isPublic, isTrue);
      expect(explicitNonDocumentedInBaseClassGetter.hasPublicGetter, isTrue);
      expect(explicitNonDocumentedInBaseClassGetter.documentationComment,
          contains('I should be documented'));
      expect(explicitNonDocumentedInBaseClassGetter.readOnly, isTrue);
    });

    test('inheritance of docs from SDK works for getter/setter combos', () {
      expect(
          ExtraSpecialListLength
                  .getter.documentationFrom.first.element.library.name ==
              'dart.core',
          isTrue);
      expect(ExtraSpecialListLength.oneLineDoc == '', isFalse);
    });

    test('split inheritance with explicit setter works', () {
      expect(implicitGetterExplicitSetter.getter.isInherited, isTrue);
      expect(implicitGetterExplicitSetter.setter.isInherited, isFalse);
      expect(implicitGetterExplicitSetter.isInherited, isFalse);
      expect(
          implicitGetterExplicitSetter.features.contains('inherited'), isFalse);
      expect(implicitGetterExplicitSetter.features.contains('inherited-getter'),
          isTrue);
      expect(
          implicitGetterExplicitSetter.features.contains('override'), isFalse);
      expect(implicitGetterExplicitSetter.features.contains('override-setter'),
          isTrue);
      expect(implicitGetterExplicitSetter.features.contains('read / write'),
          isTrue);
      expect(
          implicitGetterExplicitSetter.oneLineDoc,
          equals(
              'Docs for implicitGetterExplicitSetter from ImplicitProperties.'));
      expect(
          implicitGetterExplicitSetter.documentation,
          equals(
              'Docs for implicitGetterExplicitSetter from ImplicitProperties.'));
    });

    test('split inheritance with explicit getter works', () {
      expect(explicitGetterImplicitSetter.getter.isInherited, isFalse);
      expect(explicitGetterImplicitSetter.setter.isInherited, isTrue);
      expect(explicitGetterImplicitSetter.isInherited, isFalse);
      expect(
          explicitGetterImplicitSetter.features.contains('inherited'), isFalse);
      expect(explicitGetterImplicitSetter.features.contains('inherited-setter'),
          isTrue);
      expect(
          explicitGetterImplicitSetter.features.contains('override'), isFalse);
      expect(explicitGetterImplicitSetter.features.contains('override-getter'),
          isTrue);
      expect(explicitGetterImplicitSetter.features.contains('read / write'),
          isTrue);
      expect(explicitGetterImplicitSetter.oneLineDoc,
          equals('Getter doc for explicitGetterImplicitSetter'));
      // Even though we have some new setter docs, getter still takes priority.
      expect(explicitGetterImplicitSetter.documentation,
          equals('Getter doc for explicitGetterImplicitSetter'));
    });

    test('has a fully qualified name', () {
      expect(lengthX.fullyQualifiedName, 'fake.WithGetterAndSetter.lengthX');
    });

    test('has extended documentation', () {
      expect(lengthX.hasExtendedDocumentation, isTrue);
      expect(lengthX.oneLineDoc, equals('Returns a length.'));
      // TODO(jdkoren): This is left here to have at least one literal matching
      // test for extendedDocLink. Move this when extracting renderer tests.
      expect(
          lengthX.extendedDocLink,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/WithGetterAndSetter/lengthX.html">[...]</a>'));
      expect(lengthX.documentation, contains('the fourth dimension'));
      expect(lengthX.documentation, isNot(contains('[...]')));
    });

    test('has valid documentation', () {
      expect(mFromApple.hasDocumentation, isTrue);
      expect(mFromApple.documentation, 'The read-write field `m`.');
    });

    test('inherited property has a linked name to superclass in package', () {
      expect(mInB.linkedName,
          equals('<a href="${HTMLBASE_PLACEHOLDER}ex/Apple/m.html">m</a>'));
    });

    test(
        'inherited property has linked name to enclosed class, if superclass is not in package',
        () {
      expect(
          isEmpty.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/CatString/isEmpty.html">isEmpty</a>'));
    });

    test('inherited property has the enclosing class', () {
      expect(isEmpty.enclosingElement.name, equals('CatString'));
    });

    test('inherited property has the enclosing class library', () {
      expect(isEmpty.library.name, equals('ex'));
    });

    test('has enclosing element', () {
      expect(f1.enclosingElement.name, equals(c.name));
    });

    test('is not const', () {
      expect(f1.isConst, isFalse);
    });

    test('is const', () {
      expect(constField.isConst, isTrue);
    });

    test('is final only when appropriate', () {
      expect(f1.isFinal, isFalse);
      expect(finalProperty.isFinal, isTrue);
      expect(finalProperty.isLate, isFalse);
      expect(finalProperty.features, contains('final'));
      expect(finalProperty.features, isNot(contains('late')));
      expect(onlySetter.isFinal, isFalse);
      expect(onlySetter.features, isNot(contains('final')));
      expect(onlySetter.features, isNot(contains('late')));
      expect(dynamicGetter.isFinal, isFalse);
      expect(dynamicGetter.features, isNot(contains('final')));
      expect(dynamicGetter.features, isNot(contains('late')));
    });

    test('is not static', () {
      expect(f2.isStatic, isFalse);
    });

    test('getter documentation', () {
      expect(dynamicGetter.documentation,
          equals('Dynamic getter. Readable only.'));
    });

    test('setter documentation', () {
      expect(onlySetter.documentation,
          equals('Only a setter, with a single param, of type double.'));
    });

    test('Field with no explicit getter/setter has documentation', () {
      expect(autoCompress.documentation,
          contains('To enable, set `autoCompress` to `true`'));
    });

    test(
        'property with setter and getter and comments with asterixes do not show asterixes',
        () {
      expect(sFromApple.documentationAsHtml.contains('/**'), isFalse);
    });

    test('explicit getter/setter has a getter accessor', () {
      expect(lengthX.getter, isNotNull);
      expect(lengthX.getter.name, equals('lengthX'));
    });

    test('explicit getter/setter has a setter accessor', () {
      expect(lengthX.setter, isNotNull);
      expect(lengthX.setter.name, equals('lengthX='));
    });

    test('a stand-alone setter does not have a getter', () {
      expect(onlySetter.getter, isNull);
    });

    test(
        'has one inherited property for getter/setter when inherited from parameterized class',
        () {
      var withGenericSub =
          exLibrary.classes.firstWhere((c) => c.name == 'WithGenericSub');
      expect(
          withGenericSub.inheritedProperties
              .where((p) => p.name == 'prop')
              .length,
          equals(1));
    });
  });

  group('Accessor', () {
    Accessor onlyGetterGetter,
        onlyGetterSetter,
        onlySetterGetter,
        onlySetterSetter;

    Class classB;

    setUpAll(() {
      var justGetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justGetter');
      onlyGetterGetter = justGetter.getter;
      onlyGetterSetter = justGetter.setter;
      var justSetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justSetter');
      onlySetterSetter = justSetter.setter;
      onlySetterGetter = justSetter.getter;

      classB = exLibrary.classes.singleWhere((c) => c.name == 'B');
    });

    test('are available on top-level variables', () {
      expect(onlyGetterGetter.name, equals('justGetter'));
      expect(onlyGetterSetter, isNull);
      expect(onlySetterGetter, isNull);
      expect(onlySetterSetter.name, equals('justSetter='));
    });

    test('if overridden, gets documentation from superclasses', () {
      final doc = classB.allInstanceFields
          .firstWhere((p) => p.name == 's')
          .getter
          .documentation;
      expect(doc, equals('The getter for `s`'));
    });

    test(
        'has correct linked return type if the return type is a parameterized typedef',
        () {
      var apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      final fieldWithTypedef = apple.allInstanceFields
          .firstWhere((m) => m.name == 'fieldWithTypedef');
      expect(
          fieldWithTypedef.linkedReturnType,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">bool</span>&gt;</span>'));
    });
  });

  group('Top-level Variable', () {
    TopLevelVariable v;
    TopLevelVariable v3, justGetter, justSetter;
    TopLevelVariable setAndGet, mapWithDynamicKeys;
    TopLevelVariable nodocGetter, nodocSetter;
    TopLevelVariable complicatedReturn;
    TopLevelVariable meaningOfLife, importantComputations;

    setUpAll(() {
      v = exLibrary.properties.firstWhere((p) => p.name == 'number');
      v3 = exLibrary.properties.firstWhere((p) => p.name == 'y');
      meaningOfLife =
          fakeLibrary.properties.firstWhere((v) => v.name == 'meaningOfLife');
      importantComputations = fakeLibrary.properties
          .firstWhere((v) => v.name == 'importantComputations');
      complicatedReturn = fakeLibrary.properties
          .firstWhere((f) => f.name == 'complicatedReturn');
      nodocGetter = fakeLibrary.properties
          .firstWhere((p) => p.name == 'getterSetterNodocGetter');
      nodocSetter = fakeLibrary.properties
          .firstWhere((p) => p.name == 'getterSetterNodocSetter');
      justGetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justGetter');
      justSetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justSetter');
      setAndGet =
          fakeLibrary.properties.firstWhere((p) => p.name == 'setAndGet');
      mapWithDynamicKeys = fakeLibrary.properties
          .firstWhere((p) => p.name == 'mapWithDynamicKeys');
    });

    test('Verify that final and late show up (or not) appropriately', () {
      expect(meaningOfLife.isFinal, isTrue);
      expect(meaningOfLife.isLate, isFalse);
      expect(meaningOfLife.features, contains('final'));
      expect(meaningOfLife.features, isNot(contains('late')));
      expect(justGetter.isFinal, isFalse);
      expect(justGetter.features, isNot(contains('final')));
      expect(justGetter.features, isNot(contains('late')));
      expect(justSetter.isFinal, isFalse);
      expect(justSetter.features, isNot(contains('final')));
      expect(justSetter.features, isNot(contains('late')));
    });

    test(
        'Verify that a map containing anonymous functions as values works correctly',
        () {
      var typeArguments =
          (importantComputations.modelType.returnType as DefinedElementType)
              .typeArguments;
      expect(typeArguments, isNotEmpty);
      expect(
          typeArguments.last.linkedName,
          // TODO(jcollins-g): after analyzer 0.39.5 change to 'num' in first
          // group.
          matches(RegExp(
              r'(dynamic|num) Function<span class="signature">\(<span class="parameter" id="param-a"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">num</span>&gt;</span></span> <span class="parameter-name">a</span></span><wbr>\)</span>')));
      expect(
          importantComputations.linkedReturnType,
          matches(RegExp(
              r'Map<span class="signature">&lt;<wbr><span class="type-parameter">int</span>, <span class="type-parameter">(dynamic|num) Function<span class="signature">\(<span class="parameter" id="param-a"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">num</span>&gt;</span></span> <span class="parameter-name">a</span></span><wbr>\)</span></span>&gt;</span>')));
    });

    test(
        'Verify that a complex type parameter with an anonymous function works correctly',
        () {
      expect(
          complicatedReturn.linkedReturnType,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ATypeTakingClass-class.html">ATypeTakingClass</a><span class="signature">&lt;<wbr><span class="type-parameter">String Function<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">int</span></span><wbr>)</span></span>&gt;</span>'));
    });

    test('@nodoc on simple property works', () {
      var nodocSimple = fakeLibrary.publicProperties.firstWhere(
          (p) => p.name == 'simplePropertyHidden',
          orElse: () => null);
      expect(nodocSimple, isNull);
    });

    test('@nodoc on both hides both', () {
      var nodocBoth = fakeLibrary.publicProperties.firstWhere(
          (p) => p.name == 'getterSetterNodocBoth',
          orElse: () => null);
      expect(nodocBoth, isNull);
    });

    test('@nodoc on setter only works', () {
      expect(nodocSetter.isPublic, isTrue);
      expect(nodocSetter.readOnly, isTrue);
      expect(nodocSetter.documentationComment,
          equals('Getter docs should be shown.'));
    });

    test('@nodoc on getter only works', () {
      expect(nodocGetter.isPublic, isTrue);
      expect(nodocGetter.writeOnly, isTrue);
      expect(nodocGetter.documentationComment,
          equals('Setter docs should be shown.'));
    });

    test('has a fully qualified name', () {
      expect(justGetter.fullyQualifiedName, 'fake.justGetter');
    });

    test('type arguments are correct', () {
      expect(mapWithDynamicKeys.modelType.typeArguments, hasLength(2));
      expect(mapWithDynamicKeys.modelType.typeArguments.first.name,
          equals('dynamic'));
      expect(mapWithDynamicKeys.modelType.typeArguments.last.name,
          equals('String'));
    });

    test('has enclosing element', () {
      expect(v.enclosingElement.name, equals(exLibrary.name));
    });

    test('found five properties', () {
      expect(exLibrary.publicProperties, hasLength(7));
    });

    test('linked return type is a double', () {
      expect(v.linkedReturnType, 'double');
    });

    test('linked return type is dynamic', () {
      expect(v3.linkedReturnType, 'dynamic');
    });

    test('just a getter has documentation', () {
      expect(justGetter.documentation,
          equals('Just a getter. No partner setter.'));
    });

    test('just a setter has documentation', () {
      expect(justSetter.documentation,
          equals('Just a setter. No partner getter.'));
    });

    test('has a getter accessor', () {
      expect(setAndGet.getter, isNotNull);
      expect(setAndGet.getter.name, equals('setAndGet'));
    });

    test('has a setter accessor', () {
      expect(setAndGet.setter, isNotNull);
      expect(setAndGet.setter.name, equals('setAndGet='));
    });
  });

  group('Constant', () {
    TopLevelVariable greenConstant,
        cat,
        customClassPrivate,
        orangeConstant,
        prettyColorsConstant,
        deprecated;

    Field aStaticConstField, aName;

    setUpAll(() {
      greenConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'COLOR_GREEN');
      orangeConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'COLOR_ORANGE');
      prettyColorsConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'PRETTY_COLORS');
      cat = exLibrary.constants.firstWhere((c) => c.name == 'MY_CAT');
      deprecated =
          exLibrary.constants.firstWhere((c) => c.name == 'deprecated');
      var Dog = exLibrary.allClasses.firstWhere((c) => c.name == 'Dog');
      customClassPrivate = fakeLibrary.constants
          .firstWhere((c) => c.name == 'CUSTOM_CLASS_PRIVATE');
      aStaticConstField =
          Dog.constants.firstWhere((f) => f.name == 'aStaticConstField');
      aName = Dog.constants.firstWhere((f) => f.name == 'aName');
    });

    test('substrings of the constant values type are not linked (#1535)', () {
      expect(aName.constantValue,
          'const <a href="${HTMLBASE_PLACEHOLDER}ex/ExtendedShortName/ExtendedShortName.html">ExtendedShortName</a>(&quot;hello there&quot;)');
    });

    test('constant field values are escaped', () {
      expect(aStaticConstField.constantValue, '&quot;A Constant Dog&quot;');
    });

    test('privately constructed constants are unlinked', () {
      expect(customClassPrivate.constantValue, 'const _APrivateConstClass()');
    });

    test('has a fully qualified name', () {
      expect(greenConstant.fullyQualifiedName, 'ex.COLOR_GREEN');
    });

    test('has the correct kind', () {
      expect(greenConstant.kind, equals('top-level constant'));
    });

    test('has enclosing element', () {
      expect(greenConstant.enclosingElement.name, equals(exLibrary.name));
    });

    test('found all the constants', () {
      expect(exLibrary.publicConstants, hasLength(9));
    });

    test('COLOR_GREEN is constant', () {
      expect(greenConstant.isConst, isTrue);
    });

    test('COLOR_ORANGE has correct value', () {
      expect(orangeConstant.constantValue, '&#39;orange&#39;');
    });

    test('PRETTY_COLORS', () {
      expect(
          prettyColorsConstant.constantValue,
          matches(RegExp(
              r'const &lt;String&gt;\s?\[COLOR_GREEN, COLOR_ORANGE, &#39;blue&#39;\]')));
    });

    test('MY_CAT is linked', () {
      expect(cat.constantValue,
          'const <a href="${HTMLBASE_PLACEHOLDER}ex/ConstantCat/ConstantCat.html">ConstantCat</a>(&#39;tabby&#39;)');
    });

    test('exported property', () {
      expect(deprecated.library.name, equals('ex'));
    });
  });

  group('Constructor', () {
    Constructor appleDefaultConstructor, constCatConstructor;
    Constructor appleConstructorFromString;
    Constructor constructorTesterDefault, constructorTesterFromSomething;
    Constructor syntheticConstructor;
    Class apple,
        constCat,
        constructorTester,
        referToADefaultConstructor,
        withSyntheticConstructor;
    setUpAll(() {
      apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      constCat = exLibrary.classes.firstWhere((c) => c.name == 'ConstantCat');
      constructorTester =
          fakeLibrary.classes.firstWhere((c) => c.name == 'ConstructorTester');
      constCatConstructor = constCat.constructors[0];
      appleDefaultConstructor =
          apple.constructors.firstWhere((c) => c.name == 'Apple');
      appleConstructorFromString =
          apple.constructors.firstWhere((c) => c.name == 'Apple.fromString');
      constructorTesterDefault = constructorTester.constructors
          .firstWhere((c) => c.name == 'ConstructorTester');
      constructorTesterFromSomething = constructorTester.constructors
          .firstWhere((c) => c.name == 'ConstructorTester.fromSomething');
      referToADefaultConstructor = fakeLibrary.classes
          .firstWhere((c) => c.name == 'ReferToADefaultConstructor');
      withSyntheticConstructor = exLibrary.classes
          .firstWhere((c) => c.name == 'WithSyntheticConstructor');
      syntheticConstructor = withSyntheticConstructor.defaultConstructor;
    });

    test('calculates comment references to classes vs. constructors correctly',
        () {
      expect(
          referToADefaultConstructor.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ReferToADefaultConstructor-class.html">ReferToADefaultConstructor</a>'));
      expect(
          referToADefaultConstructor.documentationAsHtml,
          contains(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ReferToADefaultConstructor/ReferToADefaultConstructor.html">ReferToADefaultConstructor.ReferToADefaultConstructor</a>'));
    });

    test('displays generic parameters correctly', () {
      expect(constructorTesterDefault.nameWithGenerics,
          'ConstructorTester&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">B</span>&gt;');
      expect(constructorTesterFromSomething.nameWithGenerics,
          'ConstructorTester&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">B</span>&gt;.fromSomething');
    });

    test('has a fully qualified name', () {
      expect(
          appleConstructorFromString.fullyQualifiedName, 'ex.Apple.fromString');
    });

    test('has a line number and column', () {
      expect(appleDefaultConstructor.characterLocation, isNotNull);
      expect(syntheticConstructor.characterLocation, isNotNull);
      // The default constructor should not reference the class for location
      // because it is not synthetic.
      expect(appleDefaultConstructor.characterLocation.toString(),
          isNot(equals(apple.characterLocation.toString())));
      // A synthetic class should reference its parent.
      expect(syntheticConstructor.characterLocation.toString(),
          equals(withSyntheticConstructor.characterLocation.toString()));
    });

    test('has enclosing element', () {
      expect(appleDefaultConstructor.enclosingElement.name, equals(apple.name));
    });

    test('has constructor', () {
      expect(appleDefaultConstructor, isNotNull);
      expect(appleDefaultConstructor.name, equals('Apple'));
      expect(appleDefaultConstructor.shortName, equals('Apple'));
    });

    test('title has factory qualifier', () {
      expect(appleConstructorFromString.fullKind, 'factory constructor');
    });

    test('title has const qualifier', () {
      expect(constCatConstructor.fullKind, 'const constructor');
    });

    test('title has no qualifiers', () {
      expect(appleDefaultConstructor.fullKind, 'constructor');
    });

    test('shortName', () {
      expect(appleConstructorFromString.shortName, equals('fromString'));
    });
  });

  group('void as type', () {
    ModelFunction returningFutureVoid, aVoidParameter;
    Class ExtendsFutureVoid, ImplementsFutureVoid, ATypeTakingClassMixedIn;

    setUpAll(() {
      returningFutureVoid = fakeLibrary.functions
          .firstWhere((f) => f.name == 'returningFutureVoid');
      aVoidParameter =
          fakeLibrary.functions.firstWhere((f) => f.name == 'aVoidParameter');
      ExtendsFutureVoid =
          fakeLibrary.classes.firstWhere((f) => f.name == 'ExtendsFutureVoid');
      ImplementsFutureVoid = fakeLibrary.classes
          .firstWhere((f) => f.name == 'ImplementsFutureVoid');
      ATypeTakingClassMixedIn = fakeLibrary.classes
          .firstWhere((f) => f.name == 'ATypeTakingClassMixedIn');
    });

    test('a function returning a Future<void>', () {
      expect(
          returningFutureVoid.linkedReturnType,
          equals(
              'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });

    test('a function requiring a Future<void> parameter', () {
      expect(
          ParameterRendererHtml().renderLinkedParams(aVoidParameter.parameters,
              showMetadata: true, showNames: true),
          equals(
              '<span class="parameter" id="aVoidParameter-param-p1"><span class="type-annotation">Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span></span> <span class="parameter-name">p1</span></span><wbr>'));
    });

    test('a class that extends Future<void>', () {
      expect(
          ExtendsFutureVoid.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ExtendsFutureVoid-class.html">ExtendsFutureVoid</a>'));
      var FutureVoid = ExtendsFutureVoid.publicSuperChain
          .firstWhere((c) => c.name == 'Future');
      expect(
          FutureVoid.linkedName,
          equals(
              'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });

    test('a class that implements Future<void>', () {
      expect(
          ImplementsFutureVoid.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ImplementsFutureVoid-class.html">ImplementsFutureVoid</a>'));
      var FutureVoid = ImplementsFutureVoid.publicInterfaces
          .firstWhere((c) => c.name == 'Future');
      expect(
          FutureVoid.linkedName,
          equals(
              'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });

    test('Verify that a mixin with a void type parameter works', () {
      expect(
          ATypeTakingClassMixedIn.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ATypeTakingClassMixedIn-class.html">ATypeTakingClassMixedIn</a>'));
      var ATypeTakingClassVoid = ATypeTakingClassMixedIn.mixins
          .firstWhere((c) => c.name == 'ATypeTakingClass');
      expect(
          ATypeTakingClassVoid.linkedName,
          equals(
              '<a href="${HTMLBASE_PLACEHOLDER}fake/ATypeTakingClass-class.html">ATypeTakingClass</a><span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });
  });

  group('ModelType', () {
    Field fList;

    setUpAll(() {
      fList = exLibrary.classes
          .firstWhere((c) => c.name == 'B')
          .instanceProperties
          .singleWhere((p) => p.name == 'list');
    });

    test('parameterized type', () {
      expect(fList.modelType is ParameterizedElementType, isTrue);
    });
  });

  group('Typedef', () {
    Typedef t;
    Typedef generic;
    Typedef aComplexTypedef;
    Class TypedefUsingClass;

    setUpAll(() {
      t = exLibrary.typedefs.firstWhere((t) => t.name == 'processMessage');
      generic =
          fakeLibrary.typedefs.firstWhere((t) => t.name == 'NewGenericTypedef');

      aComplexTypedef =
          exLibrary.typedefs.firstWhere((t) => t.name == 'aComplexTypedef');
      TypedefUsingClass =
          fakeLibrary.classes.firstWhere((t) => t.name == 'TypedefUsingClass');
    });

    test(
        'Typedefs with bound type parameters indirectly referred in parameters are displayed',
        () {
      var theConstructor = TypedefUsingClass.constructors.first;
      expect(
          ParameterRendererHtml().renderLinkedParams(theConstructor.parameters),
          equals(
              '<span class="parameter" id="-param-x"><span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">double</span>&gt;</span></span> <span class="parameter-name">x</span></span><wbr>'));
    });

    test('anonymous nested functions inside typedefs are handled', () {
      expect(aComplexTypedef, isNotNull);
      expect(aComplexTypedef.linkedReturnType, startsWith('void Function'));
      expect(
          aComplexTypedef.nameWithGenerics,
          equals(
              'aComplexTypedef&lt;<wbr><span class="type-parameter">A1</span>, <span class="type-parameter">A2</span>, <span class="type-parameter">A3</span>&gt;'));
    });

    test('anonymous nested functions inside typedefs are handled correctly',
        () {
      expect(
          aComplexTypedef.linkedReturnType,
          equals(
              'void Function<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">A1</span>, </span><wbr><span class="parameter" id="param-"><span class="type-annotation">A2</span>, </span><wbr><span class="parameter" id="param-"><span class="type-annotation">A3</span></span><wbr>)</span>'));
      expect(
          aComplexTypedef.linkedParamsLines,
          equals(
              '<ol class="parameter-list"><li><span class="parameter" id="aComplexTypedef-param-"><span class="type-annotation">A3</span>, </span></li>\n'
              '<li><span class="parameter" id="aComplexTypedef-param-"><span class="type-annotation">String</span></span></li>\n'
              '</ol>'));
    });

    test('has a fully qualified name', () {
      expect(t.fullyQualifiedName, 'ex.processMessage');
      expect(generic.fullyQualifiedName, 'fake.NewGenericTypedef');
    });

    test('has enclosing element', () {
      expect(t.enclosingElement.name, equals(exLibrary.name));
      expect(generic.enclosingElement.name, equals(fakeLibrary.name));
    });

    test('docs', () {
      expect(t.documentation, equals(''));
      expect(generic.documentation,
          equals('A typedef with the new style generic function syntax.'));
    });

    test('linked return type', () {
      expect(t.linkedReturnType, equals('String'));
      expect(
          generic.linkedReturnType,
          equals(
              'List<span class="signature">&lt;<wbr><span class="type-parameter">S</span>&gt;</span>'));
    });

    test('name with generics', () {
      expect(
          t.nameWithGenerics,
          equals(
              'processMessage&lt;<wbr><span class="type-parameter">T</span>&gt;'));
      expect(
          generic.nameWithGenerics,
          equals(
              'NewGenericTypedef&lt;<wbr><span class="type-parameter">T</span>&gt;'));
    });

    // TODO(jdkoren): Not easy to call TypedefRenderer directly because Typedef
    // inspects its element member. Find a better way when we start to isolate
    // renderer tests.
    test('TypedefRendererHtml renders genericParameters', () {
      expect(TypedefRendererHtml().renderGenericParameters(t), equals(''));
      expect(TypedefRendererHtml().renderGenericParameters(generic),
          equals('&lt;<wbr><span class="type-parameter">S</span>&gt;'));
    });
  });

  group('Parameter', () {
    Class c, fClass, CovariantMemberParams;
    Method isGreaterThan,
        asyncM,
        methodWithGenericParam,
        paramFromExportLib,
        methodWithTypedefParam,
        applyCovariantParams;
    ModelFunction doAComplicatedThing;
    Parameter intNumber, intCheckOptional;

    setUpAll(() {
      c = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      CovariantMemberParams = fakeLibrary.classes
          .firstWhere((c) => c.name == 'CovariantMemberParams');
      applyCovariantParams = CovariantMemberParams.allInstanceMethods
          .firstWhere((m) => m.name == 'applyCovariantParams');
      paramFromExportLib =
          c.instanceMethods.singleWhere((m) => m.name == 'paramFromExportLib');
      isGreaterThan =
          c.instanceMethods.singleWhere((m) => m.name == 'isGreaterThan');
      asyncM = exLibrary.classes
          .firstWhere((c) => c.name == 'Dog')
          .instanceMethods
          .firstWhere((m) => m.name == 'foo');
      intNumber = isGreaterThan.parameters.first;
      intCheckOptional = isGreaterThan.parameters.last;
      fClass = exLibrary.classes.firstWhere((c) => c.name == 'F');
      methodWithGenericParam = fClass.instanceMethods
          .singleWhere((m) => m.name == 'methodWithGenericParam');
      methodWithTypedefParam = c.instanceMethods
          .singleWhere((m) => m.name == 'methodWithTypedefParam');
      doAComplicatedThing = fakeLibrary.publicFunctions
          .firstWhere((m) => m.name == 'doAComplicatedThing');
    });

    test('covariant parameters render correctly', () {
      expect(applyCovariantParams.parameters, hasLength(2));
      expect(applyCovariantParams.linkedParamsLines,
          contains('<span>covariant</span>'));
    });

    test(
        'ambiguous reference to function parameter parameters resolves to nothing',
        () {
      expect(doAComplicatedThing.documentationAsHtml,
          contains('<code>aThingParameter</code>'));
    });

    test('has parameters', () {
      expect(isGreaterThan.parameters, hasLength(2));
    });

    test('is optional', () {
      expect(intCheckOptional.isNamed, isTrue);
      expect(intCheckOptional.isRequiredNamed, isFalse);
      expect(intNumber.isNamed, isFalse);
      expect(intNumber.isRequiredPositional, isTrue);
    });

    test('default value', () {
      expect(intCheckOptional.defaultValue, '5');
    });

    test('is named', () {
      expect(intCheckOptional.isNamed, isTrue);
    });

    test('linkedName', () {
      expect(intCheckOptional.modelType.linkedName, 'int');
    });

    test('async return type', () {
      expect(asyncM.linkedReturnType, 'Future');
    });

    test('param with generics', () {
      var params = ParameterRendererHtml()
          .renderLinkedParams(methodWithGenericParam.parameters);
      expect(params.contains('List') && params.contains('Apple'), isTrue);
    });

    test('commas on same param line', () {
      var method =
          fakeLibrary.functions.firstWhere((f) => f.name == 'paintImage1');
      var params =
          ParameterRendererHtml().renderLinkedParams(method.parameters);
      expect(params, contains(', </span>'));
    });

    test('param with annotations', () {
      var method =
          fakeLibrary.functions.firstWhere((f) => f.name == 'paintImage1');
      var params =
          ParameterRendererHtml().renderLinkedParams(method.parameters);
      expect(params, contains('@required'));
    });

    test('param exported in library', () {
      var param = paramFromExportLib.parameters[0];
      expect(param.name, equals('helper'));
      expect(param.library.name, equals('ex'));
    });

    test('typedef param is linked and does not include types', () {
      var params = ParameterRendererHtml()
          .renderLinkedParams(methodWithTypedefParam.parameters);
      expect(
          params,
          equals(
              '<span class="parameter" id="methodWithTypedefParam-param-p"><span class="type-annotation"><a href="${HTMLBASE_PLACEHOLDER}ex/processMessage.html">processMessage</a></span> <span class="parameter-name">p</span></span><wbr>'));
    });
  });

  group('Implementors', () {
    Class apple;
    Class b;
    List<Class> implA, implC;

    setUpAll(() {
      apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      b = exLibrary.classes.firstWhere((c) => c.name == 'B');
      implA = apple.publicImplementors.toList();
      implC = exLibrary.classes
          .firstWhere((c) => c.name == 'Cat')
          .publicImplementors
          .toList();
    });

    test('the first class is Apple', () {
      expect(apple.name, equals('Apple'));
    });

    test('apple has some implementors', () {
      expect(apple.hasPublicImplementors, isTrue);
      expect(implA, isNotNull);
      expect(implA, hasLength(1));
      expect(implA[0].name, equals('B'));
    });

    test('Cat has implementors', () {
      expect(implC, hasLength(3));
      var implementors = <String>['B', 'Dog', 'ConstantCat'];
      expect(implementors.contains(implC[0].name), isTrue);
      expect(implementors.contains(implC[1].name), isTrue);
      expect(implementors.contains(implC[2].name), isTrue);
    });

    test('B does not have implementors', () {
      expect(b, isNotNull);
      expect(b.name, equals('B'));
      expect(b.publicImplementors, hasLength(0));
    });
  });

  group('Errors and exceptions', () {
    var expectedNames = <String>[
      'MyError',
      'MyException',
      'MyErrorImplements',
      'MyExceptionImplements'
    ];
    test('library has the exact errors/exceptions we expect', () {
      expect(exLibrary.exceptions.map((e) => e.name),
          unorderedEquals(expectedNames));
    });
  });

  group('Annotations', () {
    Class forAnnotation, dog;
    Method ctr;
    setUpAll(() {
      forAnnotation =
          exLibrary.classes.firstWhere((c) => c.name == 'HasAnnotation');
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      ctr = dog.staticMethods.firstWhere((c) => c.name == 'createDog');
    });

    test('is not null', () => expect(forAnnotation, isNotNull));

    test('has annotations', () => expect(forAnnotation.hasAnnotations, true));

    test('has one annotation',
        () => expect(forAnnotation.annotations, hasLength(1)));

    test('has the right annotation and is escaped', () {
      expect(
          forAnnotation.annotations.first,
          equals(
              '@<a href="${HTMLBASE_PLACEHOLDER}ex/ForAnnotation-class.html">ForAnnotation</a>(&#39;my value&#39;)'));
    });

    test('methods has the right annotation', () {
      var m = dog.instanceMethods.singleWhere((m) => m.name == 'getClassA');
      expect(m.hasAnnotations, isTrue);
      expect(m.annotations.first, equals('@deprecated'));
    });

    test('method annotations have the right link and are escaped', () {
      expect(
          ctr.annotations[0],
          equals(
              '@<a href="${HTMLBASE_PLACEHOLDER}ex/Deprecated-class.html">Deprecated</a>(&quot;Internal use&quot;)'));
    });
  });

  group('Sorting by name', () {
    // Order by uppercased lexical ordering for non-digits,
    // lexicographical ordering of embedded digit sequences.
    var names = [
      r'',
      r'$',
      r'0',
      r'0a',
      r'00',
      r'1',
      r'01',
      r'_',
      r'a',
      r'aaab',
      r'aab',
      r'Ab',
      r'B',
      r'bA',
      r'x0$',
      r'x1$',
      r'x01$',
      r'x001$',
      r'x10$',
      r'x010$',
      r'x100$',
    ];
    for (var i = 1; i < names.length; i++) {
      var a = StringName(names[i - 1]);
      var b = StringName(names[i]);
      test('"$a" < "$b"', () {
        expect(byName(a, a), 0);
        expect(byName(b, b), 0);
        expect(byName(a, b), -1);
        expect(byName(b, a), 1);
      });
    }
  });
}

class StringName extends Nameable {
  @override
  final String name;

  StringName(this.name);

  @override
  String toString() => name;
}
