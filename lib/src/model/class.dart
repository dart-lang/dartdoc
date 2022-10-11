// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';

/// A [Container] defined with a `class` declaration in Dart.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// **instance**: As with [Container], but also includes inherited children.
/// **inherited**: Filtered getters giving only inherited children.
class Class extends InheritingContainer
    with Constructable, TypeImplementing, MixedInTypes {
  @override
  final ClassElement element;

  Class(this.element, Library library, PackageGraph packageGraph)
      : super(library, packageGraph) {
    packageGraph.specialClasses.addSpecial(this);
  }

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...constructors,
  ];

  @override
  String get fileName => '$name-class.$fileType';

  bool get isAbstract => element.isAbstract;

  bool get isErrorOrException {
    bool isError(InterfaceElement element) =>
        element.library.isDartCore &&
        (element.name == 'Exception' || element.name == 'Error');

    final element = this.element;
    if (isError(element)) return true;
    return element.allSupertypes.map((t) => t.element2).any(isError);
  }

  @override
  String get kind => 'class';

  @override
  String get fullkind {
    if (isAbstract) return 'abstract $kind';
    return super.fullkind;
  }

  @override
  late final List<InheritingContainer?> inheritanceChain = [
    this,

    // Caching should make this recursion a little less painful.
    for (var container in mixedInTypes.reversed.modelElements)
      ...container.inheritanceChain,

    for (var container in superChain.modelElements)
      ...container.inheritanceChain,

    // Interfaces need to come last, because classes in the superChain might
    // implement them even when they aren't mentioned.
    ...interfaces.expandInheritanceChain,
  ];

  @override
  String get relationshipsClass => 'clazz-relationships';
}
