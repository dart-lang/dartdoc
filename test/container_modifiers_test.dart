// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/container_modifiers.dart';
import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/render/language_feature_renderer.dart';
import 'package:test/test.dart';

class TestChipRenderer extends LanguageFeatureRenderer {
  @override
  String renderLanguageFeatureLabel(LanguageFeature l) => l.name;
}

extension TestChipsRenderer on Iterable<LanguageFeature> {
  String asRenderedString() => map((l) => l.featureLabel).join(' ');
}

void main() {
  group('fullKind string tests', () {
    test('basic', () {
      var l = [
        ContainerModifier.base,
        ContainerModifier.interface,
        ContainerModifier.abstract
      ]..sort();
      expect(l.asLanguageFeatureSet(TestChipRenderer()).asRenderedString(),
          equals('abstract base interface'));
    });

    test('hide abstract on sealed', () {
      var l = [ContainerModifier.abstract, ContainerModifier.sealed]..sort();
      expect(l.asLanguageFeatureSet(TestChipRenderer()).asRenderedString(),
          equals('sealed'));
    });

    test('empty', () {
      var l = <ContainerModifier>[];
      expect(l.asLanguageFeatureSet(TestChipRenderer()).asRenderedString(),
          equals(''));
    });
  });
}
