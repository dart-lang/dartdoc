// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/render/language_feature_renderer.dart';

/// Represents a single modifier applicable to containers.
class ContainerModifier implements Comparable<ContainerModifier> {
  final String name;
  final String displayName;

  /// If this modifier is present with any of these modifiers, it should
  /// not be displayed as part of a fullKind prefix.
  final Set<ContainerModifier> hideIfPresent;

  /// The display order of this modifier.
  final int order;

  const ContainerModifier._(
    this.name, {
    required this.order,
    String? displayName,
    Set<ContainerModifier>? hideIfPresent,
  })  : displayName = displayName ?? name,
        hideIfPresent = hideIfPresent ?? const <ContainerModifier>{};

  @override
  String toString() => displayName;

  @override
  int compareTo(ContainerModifier a) => order.compareTo(a.order);

  static const ContainerModifier sealed =
      ContainerModifier._('sealed', order: 0);
  static const ContainerModifier abstract =
      ContainerModifier._('abstract', order: 0, hideIfPresent: {sealed});
  static const ContainerModifier base = ContainerModifier._('base', order: 1);
  static const ContainerModifier interface =
      ContainerModifier._('interface', order: 2);
  static const ContainerModifier finalModifier =
      ContainerModifier._('final', order: 3);
  static const ContainerModifier mixin = ContainerModifier._('mixin', order: 4);
}

extension BuildLanguageFeatureSet on Iterable<ContainerModifier> {
  /// Transforms [ContainerModifiers] into a series of [LanguageFeature] objects
  /// suitable for rendering as chips.   Assumes iterable is sorted.
  Iterable<LanguageFeature> asLanguageFeatureSet(
          LanguageFeatureRenderer languageFeatureRenderer) =>
      where((m) => !m.hideIfPresent.any(contains))
          .map((m) => LanguageFeature(m.name, languageFeatureRenderer));
}
