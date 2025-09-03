// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

const Map<String, String> classModifierDescriptions = {
  'sealed':
      'The direct subtypes of this class will be checked for exhaustiveness in switches.',
  'abstract': 'This type can not be directly constructed.',
  'base':
      'This class or mixin can only be extended (not implemented or mixed in).',
  'interface': 'This class can only be implemented (not extended or mixed in).',
  'final': 'This class can neither be extended, implemented, nor mixed in.',
  'mixin': 'This class can be used as a class and a mixin.',
};

const Map<String, String> classModifierUrls = {
  'sealed': 'https://dart.dev/language/class-modifiers#sealed',
  'abstract': 'https://dart.dev/language/class-modifiers#abstract',
  'base': 'https://dart.dev/language/class-modifiers#base',
  'interface': 'https://dart.dev/language/class-modifiers#interface',
  'final': 'https://dart.dev/language/class-modifiers#final',
  'mixin': 'https://dart.dev/language/mixins#class-mixin-or-mixin-class',
};
