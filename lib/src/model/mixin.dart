// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:dartdoc/src/special_elements.dart';
import 'package:meta/meta.dart';

/// Implements the Dart 2.1 "mixin" style of mixin declarations.
class Mixin extends InheritingContainer with TypeImplementing {
  Mixin(ClassElement element, Library? library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  List<ParameterizedElementType>? _superclassConstraints;

  /// Returns a list of superclass constraints for this mixin.
  Iterable<ParameterizedElementType>? get superclassConstraints {
    _superclassConstraints ??= [
      ...element!.superclassConstraints
          .map<ParameterizedElementType>((InterfaceType i) =>
              modelBuilder.typeFrom(i, library) as ParameterizedElementType)
          .where((t) =>
              t.modelElement !=
              packageGraph.specialClasses[SpecialClass.object])
    ];
    return _superclassConstraints;
  }

  bool get hasPublicSuperclassConstraints =>
      publicSuperclassConstraints.isNotEmpty;

  Iterable<ParameterizedElementType> get publicSuperclassConstraints =>
      model_utils.filterNonPublic(superclassConstraints!);

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicSuperclassConstraints;

  @override
  String get fileName => '$name-mixin.$fileType';

  @override
  String get kind => 'mixin';

  @override
  late final List<InheritingContainer?> inheritanceChain = [
    this,

    // Mix-in interfaces come before other interfaces.
    ...superclassConstraints!.expandInheritanceChain,

    for (var container in superChain.modelElements)
      ...container.inheritanceChain,

    // Interfaces need to come last, because classes in the superChain might
    // implement them even when they aren't mentioned.
    ...interfaces.expandInheritanceChain,
  ];

  @override
  @visibleForOverriding
  Iterable<MapEntry<String, CommentReferable>> get extraReferenceChildren => [];

  @override
  String get relationshipsClass => 'mixin-relationships';
}
