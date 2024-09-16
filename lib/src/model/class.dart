// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

/// A [Container] defined with a `class` declaration.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// **instance**: As with [Container], but also includes inherited children.
/// **inherited**: Filtered getters giving only inherited children.
class Class extends InheritingContainer with Constructable, MixedInTypes {
  @override
  final ClassElement element;

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...constructors,
  ];

  @override
  String get sidebarPath =>
      '${canonicalLibraryOrThrow.dirName}/$name-class-sidebar.html';

  @override
  late final List<InheritingContainer> inheritanceChain = [
    this,

    // Caching should make this recursion a little less painful.
    for (var container in mixedInTypes.modelElements.reversed)
      ...container.inheritanceChain,

    for (var container in superChain.modelElements)
      ...container.inheritanceChain,

    // Interfaces need to come last, because classes in the superChain might
    // implement them even when they aren't mentioned.
    ...interfaceElements.expandInheritanceChain,
  ];

  Class(this.element, Library library, PackageGraph packageGraph)
      : super(library, packageGraph) {
    packageGraph.specialClasses.addSpecial(this);
  }

  @override
  String get fileName => '$name-class.html';

  @override
  bool get isAbstract => element.isAbstract;

  @override
  bool get isBase => element.isBase && !element.isSealed;

  bool get isErrorOrException {
    bool isError(InterfaceElement element) =>
        element.library.isDartCore &&
        (element.name == 'Exception' || element.name == 'Error');

    final element = this.element;
    if (isError(element)) return true;
    return element.allSupertypes.map((t) => t.element).any(isError);
  }

  @override
  bool get isFinal => element.isFinal && !element.isSealed;

  @override
  bool get isImplementableInterface => element.isInterface && !element.isSealed;

  @override
  bool get isMixinClass => element.isMixinClass;

  @override
  bool get isSealed => element.isSealed;

  @override
  Kind get kind => Kind.class_;

  @override
  String get relationshipsClass => 'clazz-relationships';
}
