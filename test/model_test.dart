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

void main() {
  AnalyzerHelper helper = new AnalyzerHelper();
  String dirPath = path.join(Directory.current.path, 'test/fake_package');
  Source source = helper.addSource(path.join(dirPath, 'lib/example.dart'));
  LibraryElement e = helper.resolve(source);
  Package package = new Package([e], dirPath);
  var l = new Library(e, package);
  var file = new File(path.join(dirPath, 'lib/example.dart'));
  var lib2 = new Library(e, package, file.readAsStringSync());

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

    Library sdkLib = new Library(
        getSdkLibrariesToDocument(helper.sdk, helper.context)[0], package);

    test('sdk library name', () {
      expect(sdkLib.name, 'dart:async');
    });

    test('documentation', () {
      expect(l.documentation, 'a library');
    });
  });

  group('Class', () {
    var classes = l.getTypes();
    Class A = classes[0];
    var B = classes[1];
    var C = classes[2];
    var D = classes[3];

    test('no of classes', () {
      expect(classes.length, 5);
    });

    test('name', () {
      expect(A.name, 'A');
    });

    test('docs ', () {
      expect(A.resolveReferences(A.documentation), 'Sample class [String]');
    });

    test('docs refs', () {
      expect(
          B.resolveReferences(B.documentation), 'Extends class [A](ex/A.html)');
    });

    test('abstract', () {
      expect(C.isAbstract, true);
    });

    test('supertype', () {
      expect(B.hasSupertype, true);
    });

    test('mixins', () {
      expect(A.mixins.length, 0);
    });

    test('interfaces', () {
      var interfaces = D.interfaces;
      expect(interfaces.length, 2);
      expect(interfaces[0].name, 'C');
      expect(interfaces[1].name, 'E');
    });

    test('get constructors', () {
      expect(A.constructors.length, 1);
    });

    test('get static fields', () {
      expect(A.getStaticFields().length, 2);
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

    test('has correct source code', () {
      expect(f2.source, equals('int function1(String s, bool b) => 5;'));
    });
  });

  group('Method', () {
    var c = l.getTypes()[1];
    var m = c.getMethods()[0];
    var m2 = lib2.getTypes()[1].getMethods()[0];
    var m3 = l.getTypes()[0].getMethods()[0];

    test('overriden method', () {
      expect(m.getOverriddenElement().runtimeType.toString(), 'Method');
    });

    test('method source', () {
      expect(m2.source,
          '@override\n  void m1() {\n    var a = 6;\n    var b = a * 9;\n  }');
    });

    test('has params', () {
      expect(m3.hasParameters, true);
    });

    test('return type', () {
      expect(m3.type.createLinkedReturnTypeName(), 'bool');
    });
  });

  group('Accessor', () {
    var c = l.getTypes()[0];
    var a = c.getAccessors()[0];

    test('is getter', () {
      expect(a.isGetter, true);
    });
  });

  group('Field', () {
    var c = l.getTypes()[0];
    var f1 = c.getStaticFields()[0];
    var f2 = c.getInstanceFields()[0];

    test('is const', () {
      expect(f1.isConst, true);
    });

    test('is final', () {
      expect(f1.isFinal, false);
    });

    test('is static', () {
      expect(f2.isStatic, false);
    });
  });

  group('Variable', () {

    Variable v;
    Variable v3;

    setUp(() {
      v = l.getProperties()[0];
      v3 = l.getProperties()[1];
    });

    test('found two properties', () {
      expect(l.getProperties().length, 2);
    });

    test('linked return type is a double', () {
      expect(v.linkedReturnType, 'double');
    });

    test('linked return type is dynamic', () {
      expect(v3.linkedReturnType, 'dynamic');
    });
  });

  group('Constant', () {
    Variable constant;

    setUp(() {
      constant = l.getConstants()[0];
    });

    test('found one constant', () {
      expect(l.getConstants().length, 1);
    });

    test('is constant', () {
      expect(constant.isConst, isTrue);
    });
  });

  group('Constructor', () {
    var c2 = lib2.getTypes()[0].constructors[0];

    test('has source', () {
      expect(c2.source, equals('///Constructor\n  A();'));
    });
  });

  group('Type', () {
    var f = l.getTypes()[1].getInstanceFields()[0];

    test('parameterized type', () {
      expect(f.type.isParameterizedType, true);
    });
  });

  group('Typedef', () {
    var t = l.getTypedefs()[0];

    test('docs', () {
      expect(t.documentation, null);
    });

    test('linked return type', () {
      expect(t.linkedReturnType, 'String');
    });
  });

  group('Parameter', () {
    var c = l.getTypes()[0];
    var m1 = c.getMethods()[2]; // printMsg
    var m2 = c.getMethods()[0]; // isGreaterThan

    var p1 = m1.parameters[1]; // [bool linebreak]
    var p2 = m2.parameters[1]; // {int check:5}

    test('is optional', () {
      expect(p1.isOptional, true);
    });

    test('default value', () {
      expect(p2.defaultValue, '5');
    });

    test('is named', () {
      expect(p2.isOptionalNamed, true);
    });

    test('linkedName', () {
      expect(p2.type.linkedName, 'int');
    });
  });

  group('Implementors', () {
    var c = l.getTypes()[0];
    var impls = getAllImplementorsFor(c);

    test('getAllImplementors', () {
      expect(impls != null, true);
    });

    test('implementors href', () {
      expect(impls[0].href != null, true);
    });

    test('implementors linked name', () {
      expect(impls[0].linkedName != null, true);
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
