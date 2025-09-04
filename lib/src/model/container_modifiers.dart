// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Represents a single modifier applicable to containers.
class ContainerModifier implements Comparable<ContainerModifier> {
  final String name;
  final String displayName;
  final String description;
  final String? url;

  /// If this modifier is present with any of these modifiers, it should
  /// not be displayed as part of a fullKind prefix.
  final Set<ContainerModifier> hideIfPresent;

  /// The display order of this modifier.
  final int order;

  const ContainerModifier._(
    this.name, {
    required this.order,
    required this.description,
    this.url,
    String? displayName,
    Set<ContainerModifier>? hideIfPresent,
  })  : displayName = displayName ?? name,
        hideIfPresent = hideIfPresent ?? const <ContainerModifier>{};

  @override
  String toString() => displayName;

  @override
  int compareTo(ContainerModifier a) => order.compareTo(a.order);

  static const ContainerModifier sealed = ContainerModifier._('sealed',
      description:
          'The direct subtypes of this class will be checked for exhaustiveness in switches.',
      url: 'https://dart.dev/language/class-modifiers#sealed',
      order: 0);
  static const ContainerModifier abstract = ContainerModifier._('abstract',
      description: 'This type can not be directly constructed.',
      url: 'https://dart.dev/language/class-modifiers#abstract',
      order: 0,
      hideIfPresent: {sealed});
  static const ContainerModifier base = ContainerModifier._('base',
      description:
          'This class or mixin can only be extended (not implemented or mixed in).',
      url: 'https://dart.dev/language/class-modifiers#base',
      order: 1);
  static const ContainerModifier interface = ContainerModifier._('interface',
      description:
          'This class can only be implemented (not extended or mixed in).',
      url: 'https://dart.dev/language/class-modifiers#interface',
      order: 2);
  static const ContainerModifier finalModifier = ContainerModifier._('final',
      description:
          'This class can neither be extended, implemented, nor mixed in.',
      url: 'https://dart.dev/language/class-modifiers#final',
      order: 3);
  static const ContainerModifier mixin = ContainerModifier._('mixin',
      description: 'This class can be used as a class and a mixin.',
      url: 'https://dart.dev/language/mixins',
      order: 4);
}
