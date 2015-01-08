// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:dartdoc/src/model.dart';
import 'package:grinder/grinder.dart' as grinder;
import 'package:unittest/unittest.dart';

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/java_engine_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';

const SOURCE1 = r'''
class A {
  const int n = 5;
  static  String s = 'hello';
  String s2;

  A(this.m);

  get m => 0;
}
''';

main() {
  tests();
}

tests() {

  AnalyzerHelper helper = new AnalyzerHelper();

  Source source = helper.addSource(SOURCE1);
  LibraryElement e = helper.resolve(source);
  var l = new Library(e);
  var classes = l.getTypes();
  Class c = classes[0];

  group('Class', () {

    test('no of classes', () {
      expect(classes.length, 1);
    });

    test('name', () {
      expect(c.name, 'A');
    });

    test('abstract', () {
      expect(c.isAbstract, false);
    });

    test('get ctors', () {
      expect(c.getCtors().length, 1);
    });

    test('get static fields', () {
      expect(c.getStaticFields().length, 1);
    });

    test('get instance fields', () {
      expect(c.getInstanceFields().length, 3);
    });

    test('get accessors', () {
      expect(c.getAccessors().length, 1);
    });

    test('get methods', () {
      expect(c.getMethods().length, 0);
    });

    test('has correct type name', () {
      expect(c.typeName, equals('Classes'));
    });
  });


  group('TypeParameter', () {

      test('has correct type name', () {
        var t = new TypeParameter(null, null);
        expect(t.typeName, equals('Type Parameters'));
      });
    });

}

class AnalyzerHelper {
  AnalysisContext context;

  AnalyzerHelper() {
    _initAnalyzer();
  }

  void _initAnalyzer() {
    Directory sdkDir = grinder.getSdkDir(['']);
    DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(sdkDir.path));
    List<UriResolver> resolvers = [new DartUriResolver(sdk), new FileUriResolver()];

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
    Source source = new FileBasedSource.con1(FileUtilities2.createFile(filePath));
    context.setContents(source, contents);
    return source;
  }

  LibraryElement resolve(Source librarySource) => context.computeLibraryElement(librarySource);
}
