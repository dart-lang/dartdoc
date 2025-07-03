// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:meta/meta.dart';

class Mixin extends InheritingContainer {
  @override
  final MixinElement2 element;

  late final List<ParameterizedElementType> superclassConstraints = [
    ...element.superclassConstraints.where((e) => !e.isDartCoreObject).map(
        (InterfaceType i) => getTypeFor(i, library) as ParameterizedElementType)
  ];

  @override
  String get fileName => '$name-mixin.html';

  @override
  String get sidebarPath =>
      '${canonicalLibraryOrThrow.dirName}/$name-mixin-sidebar.html';

  @override
  late final List<InheritingContainer> inheritanceChain = [
    this,
    ...superclassConstraints.modelElements.expandInheritanceChain,

    for (var container in superChain.modelElements)
      ...container.inheritanceChain,

    // Interfaces need to come last, because classes in the `superChain` might
    // implement them even when they aren't mentioned.
    ...interfaceElements.expandInheritanceChain,
  ];

  Mixin(this.element, super.library, super.packageGraph);

  @override
  @visibleForOverriding
  Map<String, CommentReferable> get extraReferenceChildren => const {};

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicSuperclassConstraints;

  bool get hasPublicSuperclassConstraints =>
      publicSuperclassConstraints.isNotEmpty;

  @override
  bool get isAbstract => false;

  @override
  bool get isBase => element.isBase;

  @override
  bool get isFinal => false;

  @override
  bool get isImplementableInterface => false;

  @override

  /// Mixins are not mixin classes by definition.
  bool get isMixinClass => false;

  @override
  bool get isSealed => false;

  @override
  Kind get kind => Kind.mixin;

  Iterable<ParameterizedElementType> get publicSuperclassConstraints =>
      superclassConstraints.wherePublic;

  @override
  String get relationshipsClass => 'mixin-relationships';
}
