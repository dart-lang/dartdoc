// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:unittest/unittest.dart';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/package_meta.dart';

import 'package:cli_util/cli_util.dart' as cli_util;

void main() {
  AnalyzerHelper helper = new AnalyzerHelper();
  String dirPath = p.join(Directory.current.path, 'test_package');
  Source source = helper.addSource(p.join(dirPath, 'lib/example.dart'));
  LibraryElement e = helper.resolve(source);
  Package package =
      new Package([e], new PackageMeta.fromDir(new Directory(dirPath)));
  var library = package.libraries.first;

  Directory sdkDir = cli_util.getSdkDir();

  if (sdkDir == null) {
    print("Warning: unable to locate the Dart SDK.");
    exit(1);
  }

  Package sdkAsPackage = new Package(
      getSdkLibrariesToDocument(helper.sdk, helper.context),
      new PackageMeta.fromSdk(sdkDir));

  group('Package', () {
    test('name', () {
      expect(package.name, 'test_package');
    });

    test('libraries', () {
      expect(package.libraries, hasLength(1));
    });

    test('is documented', () {
      expect(package.isDocumented(library), true);
    });

    test('description', () {
      expect(package.documentation.startsWith('# Best Package'), true);
    });

    test('sdk name', () {
      expect(sdkAsPackage.name, 'Dart API Reference');
    });

    test('sdk version', () {
      expect(sdkAsPackage.version, isNotNull);
    });

    test('sdk description', () {
      // TODO: This is null for SDK 1.10.
      if (sdkAsPackage.hasDocumentation) {
        expect(sdkAsPackage.documentation,
            startsWith('Welcome to the Dart API reference doc'));
      }
    });
  });

  group('Library', () {
    Library dartAsyncLib;

    setUp(() {
      dartAsyncLib = new Library(
          getSdkLibrariesToDocument(helper.sdk, helper.context).first,
          sdkAsPackage);

      // Make sure the first library is dart:async
      expect(dartAsyncLib.name, 'dart:async');
    });

    test('name', () {
      expect(library.name, 'ex');
    });

    test('sdk library names', () {
      expect(dartAsyncLib.name, 'dart:async');
      expect(dartAsyncLib.nameForFile, 'dart_async');
      expect(dartAsyncLib.href, 'dart_async/index.html');
    });

    test('documentation', () {
      expect(library.documentation, 'a library');
    });

    test('has properties', () {
      expect(library.hasProperties, isTrue);
    });

    test('has constants', () {
      expect(library.hasConstants, isTrue);
    });

    test('has exceptions', () {
      expect(library.hasExceptions, isTrue);
    });

    test('has enums', () {
      expect(library.hasEnums, isTrue);
    });

    test('has functions', () {
      expect(library.hasFunctions, isTrue);
    });

    test('has typedefs', () {
      expect(library.hasTypedefs, isTrue);
    });

    test('exported class', () {
      expect(library.classes.any((c) => c.name == 'Helper'), isTrue);
    });

    test('exported function', () {
      expect(library.functions.any((f) => f.name == 'helperFunction'), isFalse);
    });
  });

  group('Class', () {
    List<Class> classes;
    Class Apple, B, Cat, Dog, F;
    setUp(() {
      classes = library.classes;
      Apple = classes.firstWhere((c) => c.name == 'Apple');
      B = classes.firstWhere((c) => c.name == 'B');
      Cat = classes.firstWhere((c) => c.name == 'Cat');
      Dog = classes.firstWhere((c) => c.name == 'Dog');
      F = classes.firstWhere((c) => c.name == 'F');
    });

    test('we got the classes we expect', () {
      expect(Apple.name, equals('Apple'));
      expect(B.name, equals('B'));
      expect(Cat.name, equals('Cat'));
      expect(Dog.name, equals('Dog'));
    });

    test('correctly finds classes', () {
      expect(classes, hasLength(13));
    });

    test('docs ', () {
      expect(Apple.resolveReferences(), 'Sample class String');
    });

    test('docs refs', () {
      expect(B.resolveReferences(),
          'Extends class <a href=ex/Apple_class.html> Apple</a>');
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
      expect(Apple.constructors, hasLength(1));
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
      expect(B.inheritedMethods, hasLength(2));
      expect(B.hasInheritedMethods, isTrue);
    });

    test('inherited methods names', () {
      expect(B.inheritedMethods[0].name, 'printMsg');
      expect(B.inheritedMethods[1].name, 'isGreaterThan');
    });
  });

  group('Enum', () {
    Enum animal;

    setUp(() {
      animal = library.enums[0];
    });

    test('enum values', () {
      expect(animal.constants, hasLength(4));
      var values = animal.constants.firstWhere((f) => f.name == 'values');
      expect(values.constantValue, equals('const List&lt;Animal&gt;'));
      expect(values.documentation, startsWith('A constant List'));
    });

    test('enum single value', () {
      var dog = animal.constants.firstWhere((f) => f.name == 'DOG');
      expect(dog, isNotNull);
      expect(dog.linkedName, equals('DOG'));
    });
  });

  group('Function', () {
    ModelFunction f1;

    setUp(() {
      f1 = library.functions.single;
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
  });

  group('Method', () {
    Class classB;
    Method m, m3, m4;

    setUp(() {
      classB = library.classes.singleWhere((c) => c.name == 'B');
      m = classB.instanceMethods.first;
      m3 = library.classes
          .singleWhere((c) => c.name == 'Apple').instanceMethods.first;
      m4 = classB.instanceMethods[1];
    });

    test('overriden method', () {
      expect(m.overriddenElement.runtimeType.toString(), 'Method');
    });

    test('method documentation', () {
      expect(m.documentation, equals('this is a method'));
    });

    test('can have params', () {
      expect(m3.canHaveParameters, isTrue);
    });

    test('has parameters', () {
      expect(m3.hasParameters, isFalse);
    });

    test('return type', () {
      expect(m3.modelType.createLinkedReturnTypeName(), 'void');
    });

    test('parameter is a function', () {
      var element = m4.parameters[1].modelType.element as Typedef;
      expect(element.linkedReturnType, 'String');
    });
  });

  group('Field', () {
    var c, f1, f2, constField;

    setUp(() {
      c = library.classes.firstWhere((c) => c.name == 'Apple');
      f1 = c.staticProperties[0]; // n
      f2 = c.instanceProperties[0];
      constField = c.constants[0]; // string
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
  });

  group('Variable', () {
    TopLevelVariable v;
    TopLevelVariable v3;

    setUp(() {
      v = library.properties.firstWhere((p) => p.name == 'number');
      v3 = library.properties.firstWhere((p) => p.name == 'y');
    });

    test('found two properties', () {
      expect(library.properties, hasLength(2));
    });

    test('linked return type is a double', () {
      expect(v.linkedReturnType, 'double');
    });

    test('linked return type is dynamic', () {
      expect(v3.linkedReturnType, 'dynamic');
    });
  });

  group('Constant', () {
    TopLevelVariable greenConstant, cat, orangeConstant;

    setUp(() {
      greenConstant =
          library.constants.firstWhere((c) => c.name == 'COLOR_GREEN');
      orangeConstant =
          library.constants.firstWhere((c) => c.name == 'COLOR_ORANGE');
      cat = library.constants.firstWhere((c) => c.name == 'MY_CAT');
    });

    test('found five constants', () {
      expect(library.constants, hasLength(5));
    });

    test('COLOR_GREEN is constant', () {
      expect(greenConstant.isConst, isTrue);
    });

    test('COLOR_ORANGE has correct value', () {
      expect(orangeConstant.constantValue, "'orange'");
    });

    test('MY_CAT is linked', () {
      expect(cat.constantValue,
          'const <a href="ex/ConstantCat_class.html">ConstantCat</a>(\'tabby\')');
    });
  });

  group('Constructor', () {
    var c2;
    setUp(() {
      c2 = library.classes.firstWhere((c) => c.name == 'Apple').constructors[0];
    });

    test('has contructor', () {
      expect(c2, isNotNull);
    });
  });

  group('Type', () {
    var f =
        library.classes.firstWhere((c) => c.name == 'B').instanceProperties[0];

    test('parameterized type', () {
      expect(f.modelType.isParameterizedType, isTrue);
    });
  });

  group('Typedef', () {
    var t;

    setUp(() {
      t = library.typedefs[0];
    });

    test('docs', () {
      expect(t.documentation, null);
    });

    test('linked return type', () {
      expect(t.linkedReturnType, 'String');
    });
  });

  group('Parameter', () {
    Class c, f;
    Method isGreaterThan, asyncM, methodWithGenericParam;
    Parameter p1;

    setUp(() {
      c = library.classes.firstWhere((c) => c.name == 'Apple');
      isGreaterThan = c.instanceMethods[2]; // isGreaterThan
      asyncM = library.classes
              .firstWhere((c) => c.name == 'Dog').instanceMethods
          .firstWhere((m) => m.name == 'foo');
      p1 = isGreaterThan.parameters[1]; // {int check:5}
      f = library.classes.firstWhere((c) => c.name == 'F');
      methodWithGenericParam = f.instanceMethods[0];
    });

    test('is optional', () {
      expect(p1.isOptional, isTrue);
    });

    test('default value', () {
      expect(p1.defaultValue, '5');
    });

    test('is named', () {
      expect(p1.isOptionalNamed, isTrue);
    });

    test('linkedName', () {
      expect(p1.modelType.linkedName, 'int');
    });

    test('async return type', () {
      expect(asyncM.linkedReturnType, 'Future');
    });

    test('param with generics', () {
      var params = methodWithGenericParam.linkedParams();
      expect(params.contains('List') && params.contains('Apple'), isTrue);
    });
  });

  group('Implementors', () {
    Class apple;
    Class b;
    List<Class> implA, implC;

    setUp(() {
      apple = library.classes.firstWhere((c) => c.name == 'Apple');
      b = library.classes.firstWhere((c) => c.name == 'B');
      implA = apple.implementors;
      implC = library.classes.firstWhere((c) => c.name == 'Cat').implementors;
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
      expect(library.exceptions.map((e) => e.name),
          unorderedEquals(expectedNames));
    });
  });

  group('Annotations', () {
    Class forAnnotation, dog;
    setUp(() {
      forAnnotation =
          library.classes.firstWhere((c) => c.name == 'HasAnnotation');
      dog = library.classes.firstWhere((c) => c.name == 'Dog');
    });

    test('is not null', () => expect(forAnnotation, isNotNull));

    test('has annotations', () => expect(forAnnotation.hasAnnotations, true));

    test('has one annotation',
        () => expect(forAnnotation.annotations, hasLength(1)));

    test('has the right annotation', () {
      expect(forAnnotation.annotations.first, equals(
          '<a href="ex/ForAnnotation_class.html">ForAnnotation</a>(\'my value\')'));
    });

    test('methods has the right annotation', () {
      expect(dog.instanceMethods.first.annotations.first, equals('deprecated'));
    });
  });
}

class AnalyzerHelper {
  AnalysisContext context;
  DartSdk sdk;

  AnalyzerHelper() {
    Directory sdkDir = cli_util.getSdkDir();
    sdk = new DirectoryBasedDartSdk(new JavaFile(sdkDir.path));
    List<UriResolver> resolvers = [
      new DartUriResolver(sdk),
      new FileUriResolver()
    ];

    SourceFactory sourceFactory = new SourceFactory(resolvers);
    context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;
  }

  Source addSource(String filePath) {
    Source source = new FileBasedSource.con1(new JavaFile(filePath));
    ChangeSet changeSet = new ChangeSet();
    changeSet.addedSource(source);
    context.applyChanges(changeSet);
    return source;
  }

  LibraryElement resolve(Source librarySource) =>
      context.computeLibraryElement(librarySource);
}
