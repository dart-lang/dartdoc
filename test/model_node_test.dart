// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model_node.dart' show SourceStringExtensions;
import 'package:test/test.dart';

void main() {
  group('model_utils stripIndentFromSource', () {
    test('no indent', () {
      expect(
        'void foo() {\n  print(1);\n}\n'.stripIndent,
        'void foo() {\n  print(1);\n}\n',
      );
    });

    test('same indent', () {
      expect(
        '  void foo() {\n    print(1);\n  }\n'.stripIndent,
        'void foo() {\n  print(1);\n}\n',
      );
    });

    test('odd indent', () {
      expect(
        '   void foo() {\n     print(1);\n   }\n'.stripIndent,
        'void foo() {\n  print(1);\n}\n',
      );
    });
  });

  group('model_utils stripDartdocCommentsFromSource', () {
    test('no comments', () {
      expect(
        'void foo() {\n  print(1);\n}\n'.stripDocComments,
        'void foo() {\n  print(1);\n}\n',
      );
    });

    test('line comments', () {
      expect(
        '/// foo comment\nvoid foo() {\n  print(1);\n}\n'.stripDocComments,
        'void foo() {\n  print(1);\n}\n',
      );
    });

    test('block comments 1', () {
      expect(
        '/** foo comment */\nvoid foo() {\n  print(1);\n}\n'.stripDocComments,
        'void foo() {\n  print(1);\n}\n',
      );
    });

    test('block comments 2', () {
      expect(
        '/**\n * foo comment\n */\nvoid foo() {\n  print(1);\n}\n'
            .stripDocComments,
        'void foo() {\n  print(1);\n}\n',
      );
    });
  });
}
