// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:test/test.dart';

void main() {
  void expectParseEquivalent(String codeRef, List<String> parts,
      {bool constructorHint = false}) {
    var result = CommentReferenceParser(codeRef).parse();
    var hasHint = result.isNotEmpty &&
        (result.first is ConstructorHintStartNode ||
            result.last is ConstructorHintEndNode);
    var stringParts = result.whereType<IdentifierNode>().map((i) => i.text);
    expect(stringParts, equals(parts));
    expect(hasHint, equals(constructorHint));
  }

  void expectParseError(String codeRef) {
    expect(CommentReferenceParser(codeRef).parse(), isEmpty);
  }

  group('Basic comment reference parsing', () {
    test('Check that basic references parse', () {
      expectParseEquivalent('this.is.valid', ['this', 'is', 'valid']);
      expectParseEquivalent('this.is.valid()', ['this', 'is', 'valid'],
          constructorHint: true);
      expectParseEquivalent('new this.is.valid', ['this', 'is', 'valid'],
          constructorHint: true);
      expectParseEquivalent('const this.is.valid', ['this', 'is', 'valid']);
      expectParseEquivalent('final this.is.valid', ['this', 'is', 'valid']);
      expectParseEquivalent('var this.is.valid', ['this', 'is', 'valid']);
      expectParseEquivalent('this.is.valid?', ['this', 'is', 'valid']);
      expectParseEquivalent('this.is.valid!', ['this', 'is', 'valid']);
      expectParseEquivalent('this.is.valid<>', ['this', 'is', 'valid']);
      expectParseEquivalent('this.is.valid<stuff>', ['this', 'is', 'valid']);
      expectParseEquivalent('this.is.valid(things)', ['this', 'is', 'valid']);
    });

    test('Basic negative tests', () {
      expectParseError(r'.');
      expectParseError(r'');
      expectParseError('foo(wefoi');
      expectParseError('<MoofMilker>');
    });
  });
}
