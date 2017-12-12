// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils_test;

import 'package:dartdoc/src/model_utils.dart';
import 'package:test/test.dart';

class MemoizerUser extends MethodMemoizer {
  int foo = 0;
  // These are actually not things you would ordinarily memoize, because
  // they change.  But they are useful for testing.
  int _toMemoize() { return foo++; }
  int get toMemoize => memoized(_toMemoize);

  String _memoizedParameter1(String param) => "${foo++} ${param}";
  String memoizedParameter1(String param) => memoized1(_memoizedParameter1, param);

  String _memoizedParameter2(String param, String param2) => "${foo++} ${param} ${param2}";
  String memoizedParameter2(String param, String param2) => memoized2(_memoizedParameter2, param, param2);

  String _memoizedParameter3(String param, String param2, String param3) => "${foo++} ${param} ${param2} ${param3}";
  String memoizedParameter3(String param, String param2, String param3) => memoized3(_memoizedParameter3, param, param2, param3);

  String _memoizedParameter4(String param, String param2, String param3, String param4) => "${foo++} ${param} ${param2} ${param3} ${param4}";
  String memoizedParameter4(String param, String param2, String param3, String param4) => memoized4(_memoizedParameter4, param, param2, param3, param4);

  String _memoizedParameter5(String param, String param2, String param3, String param4, String param5) => "${foo++} ${param} ${param2} ${param3} ${param4} ${param5}";
  String memoizedParameter5(String param, String param2, String param3, String param4, String param5) => memoized5(_memoizedParameter5, param, param2, param3, param4, param5);

  String _memoizedParameter6(String param, String param2, String param3, String param4, String param5, String param6) => "${foo++} ${param} ${param2} ${param3} ${param4} ${param5} ${param6}";
  String memoizedParameter6(String param, String param2, String param3, String param4, String param5, String param6) => memoized6(_memoizedParameter6, param, param2, param3, param4, param5, param6);

  String _memoizedParameter7(String param, String param2, String param3, String param4, String param5, String param6, String param7) => "${foo++} ${param} ${param2} ${param3} ${param4} ${param5} ${param6} ${param7}";
  String memoizedParameter7(String param, String param2, String param3, String param4, String param5, String param6, String param7) => memoized7(_memoizedParameter7, param, param2, param3, param4, param5, param6, param7);

  String _memoizedParameter8(String param, String param2, String param3, String param4, String param5, String param6, String param7, String param8) => "${foo++} ${param} ${param2} ${param3} ${param4} ${param5} ${param6} ${param7} ${param8}";
  String memoizedParameter8(String param, String param2, String param3, String param4, String param5, String param6, String param7, String param8) => memoized8(_memoizedParameter8, param, param2, param3, param4, param5, param6, param7, param8);
}

void main() {
  group('model_utils stripIndentFromSource', () {
    test('no indent', () {
      expect(stripIndentFromSource('void foo() {\n  print(1);\n}\n'),
          'void foo() {\n  print(1);\n}\n');
    });

    test('same indent', () {
      expect(stripIndentFromSource('  void foo() {\n    print(1);\n  }\n'),
          'void foo() {\n  print(1);\n}\n');
    });

    test('odd indent', () {
      expect(stripIndentFromSource('   void foo() {\n     print(1);\n   }\n'),
          'void foo() {\n  print(1);\n}\n');
    });
  });

  group('model_utils stripDartdocCommentsFromSource', () {
    test('no comments', () {
      expect(stripDartdocCommentsFromSource('void foo() {\n  print(1);\n}\n'),
          'void foo() {\n  print(1);\n}\n');
    });

    test('line comments', () {
      expect(
          stripDartdocCommentsFromSource(
              '/// foo comment\nvoid foo() {\n  print(1);\n}\n'),
          'void foo() {\n  print(1);\n}\n');
    });

    test('block comments 1', () {
      expect(
          stripDartdocCommentsFromSource(
              '/** foo comment */\nvoid foo() {\n  print(1);\n}\n'),
          'void foo() {\n  print(1);\n}\n');
    });

    test('block comments 2', () {
      expect(
          stripDartdocCommentsFromSource(
              '/**\n * foo comment\n */\nvoid foo() {\n  print(1);\n}\n'),
          'void foo() {\n  print(1);\n}\n');
    });
  });

  group('model_utils MethodMemoizer', () {
    test('basic memoization and invalidation', () {
      var m = new MemoizerUser();
      expect(m.toMemoize, equals(0), reason: "initialization problem");
      expect(m.toMemoize, equals(0), reason: "failed to memoize");
      m.invalidateMemos();
      expect(m.toMemoize, equals(1), reason: "failed to invalidate");
    });

    test('memoization of a method with parameter', () {
      var m = new MemoizerUser();
      expect(m.memoizedParameter1("hello"), equals("0 hello"), reason: "initialization problem");
      expect(m.memoizedParameter1("hello"), equals("0 hello"), reason: "failed to memoize");
      expect(m.memoizedParameter1("goodbye"), equals("1 goodbye"));
      expect(m.memoizedParameter1("something"), equals("2 something"));
      m.invalidateMemos();
      expect(m.memoizedParameter1("hello"), equals("3 hello"), reason: "failed to invalidate");
    });

    test('memoization of many parameters', () {
      var m = new MemoizerUser();
      expect(m.memoizedParameter1("hello"), equals("0 hello"));
      expect(m.memoizedParameter2("hello", "obi"), equals("1 hello obi"));
      expect(m.memoizedParameter3("hello", "obi", "wan"), equals("2 hello obi wan"));
      expect(m.memoizedParameter4("hello", "obi", "wan", "how"), equals("3 hello obi wan how"));
      expect(m.memoizedParameter5("hello", "obi", "wan", "how", "are"), equals("4 hello obi wan how are"));
      expect(m.memoizedParameter6("hello", "obi", "wan", "how", "are", "you"), equals("5 hello obi wan how are you"));
      expect(m.memoizedParameter7("hello", "obi", "wan", "how", "are", "you", "doing"), equals("6 hello obi wan how are you doing"));
      expect(m.memoizedParameter8("hello", "obi", "wan", "how", "are", "you", "doing", "today"), equals("7 hello obi wan how are you doing today"));
      expect(m.memoizedParameter1("hello"), equals("0 hello"));
      expect(m.memoizedParameter2("hello", "obi"), equals("1 hello obi"));
      expect(m.memoizedParameter3("hello", "obi", "wan"), equals("2 hello obi wan"));
      expect(m.memoizedParameter4("hello", "obi", "wan", "how"), equals("3 hello obi wan how"));
      expect(m.memoizedParameter5("hello", "obi", "wan", "how", "are"), equals("4 hello obi wan how are"));
      expect(m.memoizedParameter6("hello", "obi", "wan", "how", "are", "you"), equals("5 hello obi wan how are you"));
      expect(m.memoizedParameter7("hello", "obi", "wan", "how", "are", "you", "doing"), equals("6 hello obi wan how are you doing"));
      expect(m.memoizedParameter8("hello", "obi", "wan", "how", "are", "you", "doing", "today"), equals("7 hello obi wan how are you doing today"));
    });
  });
}
