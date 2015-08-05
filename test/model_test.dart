// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:test/test.dart';

import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/package_meta.dart';

import 'package:cli_util/cli_util.dart' as cli_util;

import 'test_utils.dart' as testUtils;

void main() {
  testUtils.init();

  final Package package = testUtils.testPackage;
  final Library exLibrary =
      package.libraries.firstWhere((lib) => lib.name == 'ex');
  final Library fakeLibrary =
      package.libraries.firstWhere((lib) => lib.name == 'fake');
  final Library twoExportsLib =
      package.libraries.firstWhere((lib) => lib.name == 'two_exports');

  Directory sdkDir = cli_util.getSdkDir();

  if (sdkDir == null) {
    print("Warning: unable to locate the Dart SDK.");
    exit(1);
  }

  Package sdkAsPackage = new Package(getSdkLibrariesToDocument(
          testUtils.sdkDir, testUtils.analyzerHelper.context),
      new PackageMeta.fromSdk(sdkDir));

  group('Package', () {
    group('test package', () {
      test('name', () {
        expect(package.name, 'test_package');
      });

      test('libraries', () {
        expect(package.libraries, hasLength(5));
      });

      test('is documented in library', () {
        expect(package.isDocumented(exLibrary.element), isTrue);
      });

      test('has documentation', () {
        expect(package.hasDocumentationFile, isTrue);
        expect(package.hasDocumentation, isTrue);
      });

      test('documentation exists', () {
        expect(package.documentation.startsWith('# Best Package'), isTrue);
      });

      test('documentation can be rendered as HTML', () {
        expect(package.documentationAsHtml, contains('<h1>Best Package</h1>'));
      });

      test('sdk name', () {
        expect(sdkAsPackage.name, equals('Dart SDK'));
      });

      test('sdk version', () {
        expect(sdkAsPackage.version, isNotNull);
      });

      test('sdk description', () {
        expect(sdkAsPackage.documentation,
            startsWith('Welcome to the Dart API reference doc'));
      });
    });

    group('test small package', () {
      test('does not have documentation', () {
        expect(testUtils.testPackageSmall.hasDocumentation, isFalse);
        expect(testUtils.testPackageSmall.hasDocumentationFile, isFalse);
        expect(testUtils.testPackageSmall.documentationFile, isNull);
        expect(testUtils.testPackageSmall.documentation, isNull);
      });
    });
  });

  group('Library', () {
    Library dartAsyncLib;

    setUp(() {
      dartAsyncLib = new Library(getSdkLibrariesToDocument(
              testUtils.sdkDir, testUtils.analyzerHelper.context).first,
          sdkAsPackage);

      // Make sure the first library is dart:async
      expect(dartAsyncLib.name, 'dart:async');
    });

    test('name', () {
      expect(exLibrary.name, 'ex');
    });

    test('sdk library names', () {
      expect(dartAsyncLib.name, 'dart:async');
      expect(dartAsyncLib.dirName, 'dart-async');
      expect(dartAsyncLib.href, 'dart-async/dart-async-library.html');
    });

    test('documentation', () {
      expect(exLibrary.documentation,
          'a library. testing string escaping: `var s = \'a string\'` <cool>');
    });

    test('has properties', () {
      expect(exLibrary.hasProperties, isTrue);
    });

    test('has constants', () {
      expect(exLibrary.hasConstants, isTrue);
    });

    test('has exceptions', () {
      expect(exLibrary.hasExceptions, isTrue);
    });

    test('has enums', () {
      expect(exLibrary.hasEnums, isTrue);
    });

    test('has functions', () {
      expect(exLibrary.hasFunctions, isTrue);
    });

    test('has typedefs', () {
      expect(exLibrary.hasTypedefs, isTrue);
    });

    test('exported class', () {
      expect(exLibrary.classes.any((c) => c.name == 'Helper'), isTrue);
    });

    test('exported function', () {
      expect(
          exLibrary.functions.any((f) => f.name == 'helperFunction'), isFalse);
    });

    test('anonymous libraries', () {
      expect(package.libraries.where((lib) => lib.name == 'anonymous_library'),
          hasLength(1));
      expect(
          package.libraries.where((lib) => lib.name == 'another_anonymous_lib'),
          hasLength(1));
    });
  });

  group('Docs as HTML', () {
    Class Apple, B, superAwesomeClass, foo2;
    TopLevelVariable incorrectReference;
    ModelFunction thisIsAsync;
    ModelFunction topLevelFunction;

    Class extendedClass;
    TopLevelVariable testingCodeSyntaxInOneLiners;

    Class specialList;
    Class baseForDocComments;
    Method doAwesomeStuff;
    Class subForDocComments;

    ModelFunction short;

    setUp(() {
      incorrectReference = exLibrary.constants
          .firstWhere((c) => c.name == 'incorrectDocReference');
      B = exLibrary.classes.firstWhere((c) => c.name == 'B');
      Apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      specialList =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SpecialList');

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

    group('doc references', () {
      String docsAsHtml;

      setUp(() {
        docsAsHtml = doAwesomeStuff.documentationAsHtml;
      });

      test('codeifies a class from the SDK', () {
        expect(docsAsHtml,
            contains('<code class="prettyprint lang-dart">String</code>'));
      });

      test('codeifies a reference to its parameter', () {
        expect(docsAsHtml,
            contains('<code class="prettyprint lang-dart">value</code>'));
      });

      test('links to a reference to its class', () {
        expect(docsAsHtml, contains(
            '<a href="fake/BaseForDocComments-class.html">BaseForDocComments</a>'));
      });

      test('links to a reference to a top-level const', () {
        expect(
            docsAsHtml, contains('<a href="">NAME_WITH_TWO_UNDERSCORES</a>'));
      });

      test('links to a method in this class', () {
        expect(docsAsHtml, contains(
            '<a href="fake/BaseForDocComments/anotherMethod.html">anotherMethod</a>'));
      });

      test('links to a top-level function in this library', () {
        expect(docsAsHtml, contains(
            '<a href="fake/topLevelFunction.html">topLevelFunction</a>'));
      });

      test('links to top-level function from an imported library', () {
        expect(
            docsAsHtml, contains('<a href="ex/function1.html">function1</a>'));
      });

      test('links to a class from an imported lib', () {
        expect(docsAsHtml, contains('<a href="ex/Apple-class.html">Apple</a>'));
      });

      test('links to a top-level const from an imported lib', () {
        expect(docsAsHtml, contains(
            '<a href="fake/incorrectDocReference.html">incorrectDocReference</a>'));
      });

      test('links to a top-level variable with a prefix from an imported lib',
          () {
        expect(docsAsHtml,
            contains('<a href="">css.theOnlyThingInTheLibrary</a>'));
      }, skip: 'Wait for https://github.com/dart-lang/dartdoc/issues/767 to be fixed');

      test('codeifies a prefixed top-level variable an imported lib', () {
        expect(docsAsHtml, contains(
            '<code class="prettyprint lang-dart">css.theOnlyThingInTheLibrary</code>'));
      });
    });

    test('multi-underscore names in brackets do not become italicized', () {
      expect(short.documentation, contains('[NAME_WITH_TWO_UNDERSCORES]'));
      expect(short.documentation, contains('[NAME_SINGLEUNDERSCORE]'));
      expect(short.documentationAsHtml, contains(
          '<a href="fake/NAME_WITH_TWO_UNDERSCORES.html">NAME_WITH_TWO_UNDERSCORES</a>'));
      expect(short.documentationAsHtml, contains(
          '<a href="fake/NAME_SINGLEUNDERSCORE.html">NAME_SINGLEUNDERSCORE</a>'));
    });

    test('still has brackets inside code blocks', () {
      expect(topLevelFunction.documentationAsHtml,
          contains("['hello from dart']"));
    });

    test('oneLine doc references in inherited methods should not have brackets',
        () {
      Method add =
          specialList.allInstanceMethods.firstWhere((m) => m.name == 'add');
      expect(add.oneLineDoc, equals(
          'Adds <code class="prettyprint lang-dart">value</code> to the end of this list,\nextending the length by one.'));
    });

    test(
        'full documentation references from inherited methods should not have brackets',
        () {
      Method add =
          specialList.allInstanceMethods.firstWhere((m) => m.name == 'add');
      expect(add.documentationAsHtml, startsWith(
          '<p>Adds <code class="prettyprint lang-dart">value</code> to the end of this list,\nextending the length by one.'));
    });

    test('incorrect doc references are still wrapped in code blocks', () {
      expect(incorrectReference.documentationAsHtml,
          '<p>This should <code class="prettyprint lang-dart">not work</code>.</p>');
    });

    test('no references', () {
      expect(Apple.documentationAsHtml,
          '<p>Sample class <code class="prettyprint lang-dart">String</code></p>');
    });

    test('single ref to class', () {
      expect(B.documentationAsHtml,
          '<p>Extends class <a href="ex/Apple-class.html">Apple</a>, use <a href="ex/Apple/Apple.html">new Apple</a> or <a href="ex/Apple/Apple.fromString.html">new Apple.fromString</a></p>');
    });

    test('doc ref to class in SDK does not render as link', () {
      expect(thisIsAsync.documentationAsHtml, equals(
          '<p>An async function. It should look like I return a <code class="prettyprint lang-dart">Future</code>.</p>'));
    });

    test('references are correct in exported libraries', () {
      expect(twoExportsLib, isNotNull);
      expect(extendedClass, isNotNull);
      String resolved = extendedClass.documentationAsHtml;
      expect(resolved, isNotNull);
      expect(resolved,
          contains('<a href="two_exports/BaseClass-class.html">BaseClass</a>'));
      expect(resolved, contains(
          'linking over to <code class="prettyprint lang-dart">Apple</code>.'));
    });

    test('references to class and constructors', () {
      String comment = B.documentationAsHtml;
      expect(comment,
          contains('Extends class <a href="ex/Apple-class.html">Apple</a>'));
      expect(
          comment, contains('use <a href="ex/Apple/Apple.html">new Apple</a>'));
      expect(comment, contains(
          '<a href="ex/Apple/Apple.fromString.html">new Apple.fromString</a>'));
    });

    test('reference to class from another library', () {
      String comment = superAwesomeClass.documentationAsHtml;
      expect(comment, contains('<a href="ex/Apple-class.html">Apple</a>'));
    });

    test('reference to method', () {
      String comment = foo2.documentationAsHtml;
      expect(comment, equals(
          '<p>link to method from class <a href="ex/Apple/m.html">Apple.m</a></p>'));
    });

    test('legacy code blocks render correctly', () {
      expect(testingCodeSyntaxInOneLiners.oneLineDoc, equals(
          'These are code syntaxes: <code class="prettyprint lang-dart">true</code> and <code class="prettyprint lang-dart">false</code>'));
    });

    test('doc comments to parameters are marked as code', () {
      Method localMethod = subForDocComments.instanceMethods
          .firstWhere((m) => m.name == 'localMethod');
      expect(localMethod.documentationAsHtml,
          contains('<code class="prettyprint lang-dart">foo</code>'));
      expect(localMethod.documentationAsHtml,
          contains('<code class="prettyprint lang-dart">bar</code>'));
    });
  });

  group('Class', () {
    List<Class> classes;
    Class Apple, B, Cat, Dog, F, DT, SpecialList;
    Class ExtendingClass;

    setUp(() {
      classes = exLibrary.classes;
      Apple = classes.firstWhere((c) => c.name == 'Apple');
      B = classes.firstWhere((c) => c.name == 'B');
      Cat = classes.firstWhere((c) => c.name == 'Cat');
      Dog = classes.firstWhere((c) => c.name == 'Dog');
      F = classes.firstWhere((c) => c.name == 'F');
      DT = classes.firstWhere((c) => c.name == 'DateTime');
      SpecialList =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SpecialList');
      ExtendingClass =
          twoExportsLib.classes.firstWhere((c) => c.name == 'ExtendingClass');
    });

    test('we got the classes we expect', () {
      expect(Apple.name, equals('Apple'));
      expect(B.name, equals('B'));
      expect(Cat.name, equals('Cat'));
      expect(Dog.name, equals('Dog'));
    });

    test('class name with generics', () {
      expect(F.nameWithGenerics, equals('F&ltT extends String&gt'));
    });

    test('correctly finds classes', () {
      expect(classes, hasLength(16));
    });

    test('abstract', () {
      expect(Cat.isAbstract, isTrue);
    });

    test('supertype', () {
      expect(B.hasSupertype, isTrue);
    });

    test('mixins', () {
      expect(Apple.mixins, hasLength(0));
    });

    test('mixins not private', () {
      expect(F.mixins, hasLength(0));
    });

    test('interfaces', () {
      var interfaces = Dog.interfaces;
      expect(interfaces, hasLength(2));
      expect(interfaces[0].name, 'Cat');
      expect(interfaces[1].name, 'E');
    });

    test('get constructors', () {
      expect(Apple.constructors, hasLength(2));
    });

    test('get static fields', () {
      expect(Apple.staticProperties, hasLength(1));
    });

    test('get constants', () {
      expect(Apple.constants, hasLength(1));
    });

    test('get instance fields', () {
      expect(Apple.instanceProperties, hasLength(2));
    });

    test('get inherited properties', () {
      expect(B.inheritedProperties, hasLength(2));
    });

    test('get methods', () {
      expect(Dog.instanceMethods, hasLength(3));
    });

    test('get operators', () {
      expect(Dog.operators, hasLength(1));
      expect(Dog.operators[0].name, 'operator ==');
    });

    test('inherited methods', () {
      expect(B.inheritedMethods, hasLength(3));
      expect(B.hasInheritedMethods, isTrue);
    });

    test('all instance methods', () {
      expect(B.allInstanceMethods, isNotEmpty);
      expect(B.allInstanceMethods.length,
          equals(B.instanceMethods.length + B.inheritedMethods.length));
    });

    test('inherited methods exist', () {
      expect(B.inheritedMethods.firstWhere((x) => x.name == 'printMsg'),
          isNotNull);
      expect(B.inheritedMethods.firstWhere((x) => x.name == 'isGreaterThan'),
          isNotNull);
    });

    test('exported class should have hrefs from the current library', () {
      expect(DT.href, equals('ex/DateTime-class.html'));
      expect(DT.instanceMethods[0].href, equals('ex/DateTime/add.html'));
      expect(DT.instanceProperties[0].href, equals('ex/DateTime/day.html'));
    });

    test('exported class should have linkedReturnType for the current library',
        () {
      Method toUTC = DT.instanceMethods.firstWhere((m) => m.name == 'toUtc',
          orElse: () => null);
      expect(toUTC, isNotNull);
      expect(toUTC.linkedReturnType,
          equals('<a href="ex/DateTime-class.html">DateTime</a>'));
    });

    test('F has a single instance method', () {
      expect(F.instanceMethods, hasLength(1));
      expect(F.instanceMethods.first.name, equals('methodWithGenericParam'));
    });

    test('F has many inherited methods', () {
      expect(F.inheritedMethods, hasLength(4));
      expect(F.inheritedMethods.map((im) => im.name),
          equals(['foo', 'getClassA', 'test', 'testMethod']));
    });

    test('F has zero instance properties', () {
      expect(F.instanceProperties, hasLength(0));
    });

    test('F has a few inherited properties', () {
      expect(F.inheritedProperties, hasLength(2));
      expect(F.inheritedProperties.map((ip) => ip.name),
          equals(['isImplemented', 'name']));
    });

    test('SpecialList has zero instance methods', () {
      expect(SpecialList.instanceMethods, hasLength(0));
    });

    test('SpecialList has many inherited methods', () {
      expect(SpecialList.inheritedMethods, hasLength(43));
      expect(SpecialList.inheritedMethods.first.name, equals('add'));
      expect(SpecialList.inheritedMethods[1].name, equals('addAll'));
    });

    test('ExtendingClass is in the right library', () {
      expect(ExtendingClass.library.name, equals('two_exports'));
    });

    // because both the sub and super classes, though from different libraries,
    // are exported out through one library
    test('ExtendingClass has a super class that is also in the same library',
        () {
      expect(ExtendingClass.supertype.name, equals('BaseClass'));
      expect(
          ExtendingClass.supertype.element.library.name, equals('two_exports'));
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

  group('Enum', () {
    Enum animal;

    setUp(() {
      animal = exLibrary.enums.firstWhere((e) => e.name == 'Animal');
    });

    test('has correct number of constants', () {
      expect(animal.constants, hasLength(4));
    });

    test("has a (synthetic) values constant", () {
      var values = animal.constants.firstWhere((f) => f.name == 'values');
      expect(values, isNotNull);
      expect(values.constantValue, equals('const List&lt;Animal&gt;'));
      expect(values.documentation, startsWith('A constant List'));
    });

    test('has a constant that does not link anywhere', () {
      var dog = animal.constants.firstWhere((f) => f.name == 'DOG');
      expect(dog.linkedName, equals('DOG'));
      expect(dog.isConst, isTrue);
      expect(dog.constantValue, equals('const Animal(2)'));
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
    ModelFunction thisIsAsync;
    ModelFunction topLevelFunction;

    setUp(() {
      f1 = exLibrary.functions.single;
      thisIsAsync =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsAsync');
      topLevelFunction =
          fakeLibrary.functions.firstWhere((f) => f.name == 'topLevelFunction');
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
      expect(f1.linkedParams(), contains('lastParam'));
    });

    test('async function', () {
      expect(thisIsAsync.isAsynchronous, isTrue);
      expect(thisIsAsync.linkedReturnType, equals('Future'));
      expect(thisIsAsync.documentation, equals(
          'An async function. It should look like I return a [Future].'));
      expect(thisIsAsync.documentationAsHtml, equals(
          '<p>An async function. It should look like I return a <code class="prettyprint lang-dart">Future</code>.</p>'));
    });

    test('docs do not lose brackets in code blocks', () {
      expect(topLevelFunction.documentation, contains("['hello from dart']"));
    });

    test('has source code', () {
      expect(topLevelFunction.sourceCode, startsWith(
          '/// Top-level function 3 params and 1 optional positional param.'));
      expect(topLevelFunction.sourceCode, endsWith('''
String topLevelFunction(int param1, bool param2, Cool coolBeans,
    [double optionalPositional = 0.0]) {
  return null;
}'''));
    });
  });

  group('Method', () {
    Class classB, klass, HasGenerics;
    Method m, isGreaterThan, m4, m5, m6, convertToMap;

    setUp(() {
      klass = exLibrary.classes.singleWhere((c) => c.name == 'Klass');
      classB = exLibrary.classes.singleWhere((c) => c.name == 'B');
      HasGenerics =
          fakeLibrary.classes.singleWhere((c) => c.name == 'HasGenerics');
      m = classB.instanceMethods.first;
      isGreaterThan = exLibrary.classes
              .singleWhere((c) => c.name == 'Apple').instanceMethods
          .singleWhere((m) => m.name == 'isGreaterThan');
      m4 = classB.instanceMethods[1];
      m5 = klass.instanceMethods.singleWhere((m) => m.name == 'another');
      m6 = klass.instanceMethods.singleWhere((m) => m.name == 'toString');
      convertToMap = HasGenerics.instanceMethods
          .singleWhere((m) => m.name == 'convertToMap');
    });

    test('overriden method', () {
      expect(m.overriddenElement.runtimeType.toString(), 'Method');
    });

    test('method documentation', () {
      expect(m.documentation, equals('this is a method'));
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

    test('parameter is a function', () {
      var element = m4.parameters[1].modelType.element as Typedef;
      expect(element.linkedReturnType, 'String');
    });

    test('doc for method with no return type', () {
      var comment = m5.documentation;
      var comment2 = m6.documentation;
      expect(comment, equals('Another method'));
      expect(comment2, equals('A shadowed method'));
    });

    test('method source code indents correctly', () {
      expect(
          convertToMap.sourceCode, startsWith('/// Converts itself to a map.'));
    });
  });

  group('Field', () {
    Class c, LongFirstLine;
    Field f1, f2, constField, dynamicGetter, onlySetter;
    Field lengthX;

    setUp(() {
      c = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      f1 = c.staticProperties[0]; // n
      f2 = c.instanceProperties[0];
      constField = c.constants[0]; // string
      LongFirstLine =
          fakeLibrary.classes.firstWhere((c) => c.name == 'LongFirstLine');
      dynamicGetter = LongFirstLine.instanceProperties
          .firstWhere((p) => p.name == 'dynamicGetter');
      onlySetter = LongFirstLine.instanceProperties
          .firstWhere((p) => p.name == 'onlySetter');

      lengthX = fakeLibrary.classes.firstWhere(
              (c) => c.name == 'WithGetterAndSetter').allInstanceProperties
          .firstWhere((c) => c.name == 'lengthX');
    });

    test('is not const', () {
      expect(f1.isConst, isFalse);
    });

    test('is const', () {
      expect(constField.isConst, isTrue);
    });

    test('is not final', () {
      expect(f1.isFinal, isFalse);
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

    test('explicit getter and setter docs are unified', () {
      expect(lengthX.documentation, contains('Sets the length.'));
      expect(lengthX.documentation, contains('Returns a length.'));
    });
  });

  group('Variable', () {
    TopLevelVariable v;
    TopLevelVariable v3, justGetter, justSetter;

    setUp(() {
      v = exLibrary.properties.firstWhere((p) => p.name == 'number');
      v3 = exLibrary.properties.firstWhere((p) => p.name == 'y');
      justGetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justGetter');
      justSetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justSetter');
    });

    test('found two properties', () {
      expect(exLibrary.properties, hasLength(2));
    });

    test('linked return type is a double', () {
      expect(v.linkedReturnType, 'double');
    });

    test('linked return type is dynamic', () {
      expect(v3.linkedReturnType, 'dynamic');
    });

    test('getter documentation', () {
      expect(justGetter.documentation,
          equals('Just a getter. No partner setter.'));
    });

    test('setter documentation', () {
      expect(justSetter.documentation,
          equals('Just a setter. No partner getter.'));
    });
  });

  group('Constant', () {
    TopLevelVariable greenConstant, cat, orangeConstant, deprecated;

    setUp(() {
      greenConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'COLOR_GREEN');
      orangeConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'COLOR_ORANGE');
      cat = exLibrary.constants.firstWhere((c) => c.name == 'MY_CAT');
      deprecated =
          exLibrary.constants.firstWhere((c) => c.name == 'deprecated');
    });

    test('found five constants', () {
      expect(exLibrary.constants, hasLength(7));
    });

    test('COLOR_GREEN is constant', () {
      expect(greenConstant.isConst, isTrue);
    });

    test('COLOR_ORANGE has correct value', () {
      expect(orangeConstant.constantValue, "'orange'");
    });

    test('MY_CAT is linked', () {
      expect(cat.constantValue,
          'const <a href="ex/ConstantCat-class.html">ConstantCat</a>(\'tabby\')');
    });

    test('exported property', () {
      expect(deprecated.library.name, equals('ex'));
    });
  });

  group('Constructor', () {
    Constructor appleDefaultConstructor;
    Constructor appleConstructorFromString;
    setUp(() {
      Class apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      appleDefaultConstructor =
          apple.constructors.firstWhere((c) => c.name == 'Apple');
      appleConstructorFromString =
          apple.constructors.firstWhere((c) => c.name == 'Apple.fromString');
    });

    test('has contructor', () {
      expect(appleDefaultConstructor, isNotNull);
      expect(appleDefaultConstructor.name, equals('Apple'));
      expect(appleDefaultConstructor.shortName, equals('Apple'));
    });

    test('shortName', () {
      expect(appleConstructorFromString.shortName, equals('fromString'));
    });
  });

  group('Type', () {
    Field fList;

    setUp(() {
      fList = exLibrary.classes
              .firstWhere((c) => c.name == 'B').instanceProperties
          .singleWhere((p) => p.name == 'list');
    });

    test('parameterized type', () {
      expect(fList.modelType.isParameterizedType, isTrue);
    });
  });

  group('Typedef', () {
    Typedef t;

    setUp(() {
      t = exLibrary.typedefs.firstWhere((t) => t.name == 'processMessage');
    });

    test('docs', () {
      expect(t.documentation, equals(''));
    });

    test('linked return type', () {
      expect(t.linkedReturnType, equals('String'));
    });
  });

  group('Parameter', () {
    Class c, fClass;
    Method isGreaterThan, asyncM, methodWithGenericParam, paramFromExportLib;
    Parameter intNumber, intCheckOptional;

    setUp(() {
      c = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      paramFromExportLib =
          c.instanceMethods.singleWhere((m) => m.name == 'paramFromExportLib');
      isGreaterThan =
          c.instanceMethods.singleWhere((m) => m.name == 'isGreaterThan');
      asyncM = exLibrary.classes
              .firstWhere((c) => c.name == 'Dog').instanceMethods
          .firstWhere((m) => m.name == 'foo');
      intNumber = isGreaterThan.parameters.first;
      intCheckOptional = isGreaterThan.parameters.last;
      fClass = exLibrary.classes.firstWhere((c) => c.name == 'F');
      methodWithGenericParam = fClass.instanceMethods
          .singleWhere((m) => m.name == 'methodWithGenericParam');
    });

    test('has parameters', () {
      expect(isGreaterThan.parameters, hasLength(2));
    });

    test('is optional', () {
      expect(intCheckOptional.isOptional, isTrue);
      expect(intNumber.isOptional, isFalse);
    });

    test('default value', () {
      expect(intCheckOptional.defaultValue, '5');
    });

    test('is named', () {
      expect(intCheckOptional.isOptionalNamed, isTrue);
    });

    test('linkedName', () {
      expect(intCheckOptional.modelType.linkedName, 'int');
    });

    test('async return type', () {
      expect(asyncM.linkedReturnType, 'Future');
    });

    test('param with generics', () {
      var params = methodWithGenericParam.linkedParams();
      expect(params.contains('List') && params.contains('Apple'), isTrue);
    });

    test('param exported in library', () {
      var param = paramFromExportLib.parameters[0];
      expect(param.name, equals('helper'));
      expect(param.library.name, equals('ex'));
    });
  });

  group('Implementors', () {
    Class apple;
    Class b;
    List<Class> implA, implC;

    setUp(() {
      apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      b = exLibrary.classes.firstWhere((c) => c.name == 'B');
      implA = apple.implementors;
      implC = exLibrary.classes.firstWhere((c) => c.name == 'Cat').implementors;
    });

    test('the first class is Apple', () {
      expect(apple.name, equals('Apple'));
    });

    test('apple has some implementors', () {
      expect(apple.hasImplementors, isTrue);
      expect(implA, isNotNull);
      expect(implA, hasLength(1));
      expect(implA[0].name, equals('B'));
    });

    test('Cat has implementors', () {
      expect(implC, hasLength(3));
      List<String> implementors = ['B', 'Dog', 'ConstantCat'];
      expect(implementors.contains(implC[0].name), isTrue);
      expect(implementors.contains(implC[1].name), isTrue);
      expect(implementors.contains(implC[2].name), isTrue);
    });

    test('B does not have implementors', () {
      expect(b, isNotNull);
      expect(b.name, equals('B'));
      expect(b.implementors, hasLength(0));
    });
  });

  group('Errors and exceptions', () {
    final List<String> expectedNames = [
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
    setUp(() {
      forAnnotation =
          exLibrary.classes.firstWhere((c) => c.name == 'HasAnnotation');
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
    });

    test('is not null', () => expect(forAnnotation, isNotNull));

    test('has annotations', () => expect(forAnnotation.hasAnnotations, true));

    test('has one annotation',
        () => expect(forAnnotation.annotations, hasLength(1)));

    test('has the right annotation', () {
      expect(forAnnotation.annotations.first, equals(
          '<a href="ex/ForAnnotation-class.html">ForAnnotation</a>(\'my value\')'));
    });

    test('methods has the right annotation', () {
      var m = dog.instanceMethods.singleWhere((m) => m.name == 'getClassA');
      expect(m.hasAnnotations, isTrue);
      expect(m.annotations.first, equals('deprecated'));
    });
  });
}
