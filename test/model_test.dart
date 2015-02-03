// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:grinder/grinder.dart' as grinder;
import 'package:unittest/unittest.dart';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/java_engine_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';

const SOURCE1 = r'''
library ex;

static int function1(String s, bool b) => 5;

static int number;
get y => 2;

/// Sample class
class A {
  const int n = 5;
  static  String s = 'hello';
  String s2;
  
  ///Constructor
  A(this.m);

  void m1(){};

  get m => 0;
}
class B extends A {
  @override 
  void m1() { var a = 6; var b = a * 9;};
}
abstract class C {}
''';

void main() {
  AnalyzerHelper helper = new AnalyzerHelper();
  Source source = helper.addSource(SOURCE1);
  LibraryElement e = helper.resolve(source);
  Package package = new Package([], null);
  var l = new Library(e, package);
  var lib2 = new Library(e, package, SOURCE1);

  group('Package', () {
    var p = new Package([e], Directory.current.path);

    test('name', () {
      expect(p.name, 'dartdoc');
    });

    test('libraries', () {
      expect(p.libraries.length, 1);
    });

    test('is documented', () {
      expect(p.isDocumented(l), true);
    });

    var p2 = new Package([e], Directory.current.path, '1.9.0-dev.3.0', true);

    test('sdk name', () {
      expect(p2.name, 'Dart API Reference');
    });

    test('sdk version', () {
      expect(p2.version, '1.9.0-dev.3.0');
    });

    test('sdk description', () {
      expect(p2.description, 'Dart API Libraries');
    });
  });

  group('Library', () {
    test('name', () {
      expect(l.name, 'ex');
    });

    Package package = new Package([], null);
    Library sdkLib =
        new Library(getSdkLibrariesToDocument(helper.sdk, helper.context)[0],
        package);

    test('sdk library name', () {
      expect(sdkLib.name, 'dart:async');
    });
  });

  group('Class', () {
    var classes = l.getTypes();
    Class A = classes[0];
    var B = classes[1];
    var C = classes[2];

    test('no of classes', () {
      expect(classes.length, 3);
    });

    test('name', () {
      expect(A.name, 'A');
    });

    test('docs', () {
      expect(A.documentation, '/// Sample class');
    });

    test('abstract', () {
      expect(C.isAbstract, true);
    });

    test('supertype', () {
      expect(B.hasSupertype, true);
    });

    test('interfaces', () {
      expect(A.interfaces.length, 0);
    });

    test('mixins', () {
      expect(A.mixins.length, 0);
    });

    test('get ctors', () {
      expect(A.getCtors().length, 1);
    });

    test('get static fields', () {
      expect(A.getStaticFields().length, 1);
    });

    test('get instance fields', () {
      expect(A.getInstanceFields().length, 3);
    });

    test('get accessors', () {
      expect(A.getAccessors().length, 1);
    });

    test('get methods', () {
      expect(B.getMethods().length, 1);
    });

    test('has correct type name', () {
      expect(A.typeName, equals('Classes'));
    });
  });

  group('Function', () {
    ModelFunction f1 = l.getFunctions()[0];
    var f2 = lib2.getFunctions()[0];

    test('local element', () {
      expect(f1.isLocalElement, true);
    });

    test('is executable', () {
      expect(f1.isExecutable, true);
    });

    test('is static', () {
      expect(f1.isStatic, true);
    });

    test('has correct type name', () {
      expect(f1.typeName, equals('Functions'));
    });

    test('has correct source code', () {
      expect(f2.source, equals('int function1(String s, bool b) => 5;'));
    });
  });

  group('Method', () {
    var c = l.getTypes()[1];
    var m = c.getMethods()[0];
    var m2 = lib2.getTypes()[1].getMethods()[0];

    test('overriden method', () {
      expect(m.getOverriddenElement().runtimeType.toString(), 'Method');
    });

    test('method source', () {
      expect(m2.source, '@override \n  void m1() { var a = 6; var b = a * 9;}');
    });

    test('has correct type name', () {
      expect(m.typeName, equals('Methods'));
    });
  });

  group('Accessor', () {
    var c = l.getTypes()[0];
    var a = c.getAccessors()[0];

    test('is getter', () {
      expect(a.isGetter, true);
    });

    test('has correct type name', () {
      expect(a.typeName, equals('Getters and Setters'));
    });
  });

  group('Field', () {
    var c = l.getTypes()[0];
    var f1 = c.getStaticFields()[0];
    var f2 = c.getInstanceFields()[1];

    test('is const', () {
      expect(f2.isConst, true);
    });

    test('is final', () {
      expect(f2.isFinal, false);
    });

    test('is static', () {
      expect(f1.isStatic, true);
    });

    test('has correct type name', () {
      expect(f1.typeName, equals('Fields'));
    });
  });

  group('Variable', () {
    var v = l.getVariables()[0];

    test('is final', () {
      expect(v.isFinal, false);
    });

    test('is const', () {
      expect(v.isConst, false);
    });

    test('is static', () {
      expect(v.isStatic, true);
    });

    test('has correct type name', () {
      expect(v.typeName, equals('Top-Level Variables'));
    });
  });

  group('Parameter', () {
    test('has correct type name', () {
      var t = new Parameter(null, null, null);
      expect(t.typeName, equals('Parameters'));
    });
  });

  group('TypeParameter', () {
    test('has correct type name', () {
      var t = new TypeParameter(null, null, null);
      expect(t.typeName, equals('Type Parameters'));
    });
  });

  group('Constructor', () {
    var c = l.getTypes()[0].getCtors()[0];
    var c2 = lib2.getTypes()[0].getCtors()[0];

    test('has correct type name', () {
      expect(c.typeName, equals('Constructors'));
    });

    test('has source', () {
      expect(c2.source, equals('///Constructor\n  A(this.m);'));
    });
  });

  group('Typedef', () {
    test('has correct type name', () {
      Typedef t = new Typedef(null, null, null);
      expect(t.typeName, equals('Typedefs'));
    });

    test('docs', () {
      Typedef t = new Typedef(null, null, null);
      expect(t.documentation, null);
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

  Source addSource(String contents) {
    Source source = _cacheSource("/test.dart", contents);
    ChangeSet changeSet = new ChangeSet();
    changeSet.addedSource(source);
    context.applyChanges(changeSet);
    return source;
  }

  Source _cacheSource(String filePath, String contents) {
    Source source =
        new FileBasedSource.con1(FileUtilities2.createFile(filePath));
    context.setContents(source, contents);
    return source;
  }

  LibraryElement resolve(Source librarySource) =>
      context.computeLibraryElement(librarySource);
}
