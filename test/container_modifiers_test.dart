// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/container_modifiers.dart';
import 'package:test/test.dart';

void main() {
  group('fullKind string tests', () {
    test('basic', () {
      var l = {
        ContainerModifier.base,
        ContainerModifier.interface,
        ContainerModifier.abstract
      };
      expect(l.modifiersAsFullKindPrefix(), equals('abstract base interface'));
    });

    test('hide abstract on sealed', () {
      var l = {ContainerModifier.abstract, ContainerModifier.sealed};
      expect(l.modifiersAsFullKindPrefix(), equals('sealed'));
    });

    test('empty', () {
      var l = <ContainerModifier>{};
      expect(l.modifiersAsFullKindPrefix(), equals(''));
    });
  });
}
