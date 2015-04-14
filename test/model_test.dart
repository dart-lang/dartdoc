// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:grinder/grinder.dart' as grinder;
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';

import 'package:cli_util/cli_util.dart' as cli_util;

void main() {
  AnalyzerHelper helper = new AnalyzerHelper();
  String dirPath = path.join(Directory.current.path, 'test/fake_package');
  Source source = helper.addSource(path.join(dirPath, 'lib/example.dart'));
  LibraryElement e = helper.resolve(source);
  Package package = new Package([e], dirPath);
  Package sdkAsPackage;
  var library = package.libraries[0];
  var file = new File(path.join(dirPath, 'lib/example.dart'));
  var lib2 = new Library(e, package, file.readAsStringSync());

  group('Package', () {
    var p, p2;

    setUp(() {
      p = new Package([e], Directory.current.path);
      var readmeLoc =
          '${Directory.current.path}/test/fake_package/test_readme.md';
      p2 = new Package([e], Directory.current.path,
          sdkVersion: '1.9.0-dev.3.0', isSdk: true, readmeLoc: readmeLoc);
    });

    test('name', () {
      expect(p.name, 'dartdoc');
    });

    test('libraries', () {
      expect(p.libraries, hasLength(1));
    });

    test('is documented', () {
      expect(p.isDocumented(library), true);
    });

    test('description', () {
      expect(p.description.startsWith('# dartdoc'), true);
    });

    test('sdk name', () {
      expect(p2.name, 'Dart API Reference');
    });

    test('sdk version', () {
      expect(p2.version, '1.9.0-dev.3.0');
    });

    test('sdk description', () {
      expect(true, p2.description
          .startsWith('Welcome to the Dart API reference documentation.'));
    });
  });

  group('Library', () {
    Library dartAsyncLib;

    setUp(() {
      Directory sdkDir = cli_util.getSdkDir();
      if (sdkDir == null) {
        print("Warning: unable to locate the Dart SDK.");
        exit(1);
      }
      sdkAsPackage = new Package(
          getSdkLibrariesToDocument(helper.sdk, helper.context), sdkDir.path,
          sdkVersion: '0.0.0', isSdk: true);
      dartAsyncLib = new Library(
          getSdkLibrariesToDocument(helper.sdk, helper.context)[0],
          sdkAsPackage);
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
      expect(library.hasEnums, isFalse);
    });

    test('has functions', () {
      expect(library.hasFunctions, isTrue);
    });

    test('has typedefs', () {
      expect(library.hasTypedefs, isTrue);
    });

    test('exported class', () {
      expect(library.getClasses().any((c) => c.name == 'Helper'), isTrue);
    });

    test('exported function', () {
      expect(library.getFunctions().any((f) => f.name == 'helperFunction'),
          isFalse);
    });
  });

  group('Class', () {
    List<Class> classes;
    Class Apple, B, Cat, Dog, F;
    setUp(() {
      classes = library.getClasses();
      Apple = classes[0];
      B = classes[1];
      Cat = classes[2];
      Dog = classes[3];
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
      expect(
          Apple.resolveReferences(Apple.documentation), 'Sample class String');
    });

    test('docs refs', () {
      expect(B.resolveReferences(B.documentation),
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
      expect(Dog.instanceMethods, hasLength(2));
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

  group('Function', () {
    ModelFunction f1, f2;

    setUp(() {
      f1 = library.getFunctions()[0];
      f2 = lib2.getFunctions()[0];
    });

    test('name is function1', () {
      expect(f1.name, 'function1');
      expect(f2.name, 'function1');
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
      expect(f2.linkedParams(), contains('lastParam'));
    });

    test('has correct source code', () {
      expect(f2.source,
          equals('int function1(String s, bool b, lastParam) => 5;'));
    });
  });

  group('Method', () {
    var c, m, m2, m3, m4;

    setUp(() {
      c = library.getClasses()[1];
      m = c.instanceMethods[0];
      m2 = lib2.getClasses()[1].instanceMethods[0];
      m3 = library.getClasses()[0].instanceMethods[0];
      m4 = library.getClasses()[1].instanceMethods[1];
    });

    test('overriden method', () {
      expect(m.getOverriddenElement().runtimeType.toString(), 'Method');
    });

    test('method source', () {
      expect(m2.source,
          '@override\n  void m1() {\n    var a = 6;\n    var b = a * 9;\n    b * 2;\n  }');
    });

    test('method documentation', () {
      expect(m2.documentation, equals('this is a method'));
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
      expect(m4.parameters[1].modelType.element.linkedReturnType, 'String');
    });
  });

  group('Field', () {
    var c, f1, f2, constField;

    setUp(() {
      c = library.getClasses()[0];
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
      v = library.getProperties()[0];
      v3 = library.getProperties()[1];
    });

    test('found two properties', () {
      expect(library.getProperties(), hasLength(2));
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
          library.getConstants().firstWhere((c) => c.name == 'COLOR_GREEN');
      orangeConstant =
          library.getConstants().firstWhere((c) => c.name == 'COLOR_ORANGE');
      cat = library.getConstants().firstWhere((c) => c.name == 'MY_CAT');
    });

    test('found five constants', () {
      expect(library.getConstants(), hasLength(5));
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
      c2 = lib2.getClasses()[0].constructors[0];
    });

    test('has source', () {
      expect(c2.source, equals('///Constructor\n  Apple();'));
    });
  });

  group('Type', () {
    var f = library.getClasses()[1].instanceProperties[0];

    test('parameterized type', () {
      expect(f.modelType.isParameterizedType, isTrue);
    });
  });

  group('Typedef', () {
    var t;

    setUp(() {
      t = library.getTypedefs()[0];
    });

    test('docs', () {
      expect(t.documentation, null);
    });

    test('linked return type', () {
      expect(t.linkedReturnType, 'String');
    });
  });

  group('Parameter', () {
    Class c;
    Method isGreaterThan, asyncM;
    Parameter p1;

    setUp(() {
      c = library.getClasses()[0]; // A

      isGreaterThan = c.instanceMethods[2]; // isGreaterThan
      asyncM = library.getClasses()[3].instanceMethods
          .firstWhere((m) => m.name == 'foo');
      p1 = isGreaterThan.parameters[1]; // {int check:5}
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
  });

  group('Implementors', () {
    Class apple;
    Class b;
    List<Class> implA, implC;

    setUp(() {
      apple = library.getClasses()[0];
      b = library.getClasses()[1];
      implA = apple.implementors;
      implC = library.getClasses()[2].implementors;
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

    test('C has implementors', () {
      expect(implC, hasLength(3));
      expect(implC[0].name, equals('B'));
      expect(implC[1].name, equals('Dog'));
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
      expect(library.getExceptions().map((e) => e.name),
          unorderedEquals(expectedNames));
    });
  });

  group('Annotations', () {
    Class forAnnotation, dog;
    setUp(() {
      forAnnotation =
          library.getClasses().firstWhere((c) => c.name == 'HasAnnotation');
      dog = library.getClasses().firstWhere((c) => c.name == 'Dog');
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
    _initAnalyzer();
  }

  void _initAnalyzer() {
    Directory sdkDir = grinder.getSdkDir(['']);
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
