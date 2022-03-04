// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';

import 'comment_referable.dart';

/// A [Container] defined with a `class` declaration in Dart.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// **instance**: As with [Container], but also includes inherited children.
/// **inherited**: Filtered getters giving only inherited children.
class Class extends InheritingContainer
    with Constructable, TypeImplementing, MixedInTypes {
  Class(ClassElement element, Library? library, PackageGraph packageGraph)
      : super(element, library, packageGraph) {
    packageGraph.specialClasses.addSpecial(this);
  }

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...constructors,
  ];

  /// Returns the library that encloses this element.
  @override
  ModelElement? get enclosingElement => library;

  @override
  String get fileName => '$name-class.$fileType';

  @override
  String get filePath => '${library.dirName}/$fileName';

  @override
  String get fullkind {
    if (isAbstract) return 'abstract $kind';
    return super.fullkind;
  }

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    var packageBaseHref = package.baseHref;
    if (packageBaseHref != null) {
      return '$packageBaseHref$filePath';
    }
    return null;
  }

  bool get isAbstract => element!.isAbstract;

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  bool get isErrorOrException {
    bool isError(ClassElement element) => (element.library.isDartCore &&
        (element.name == 'Exception' || element.name == 'Error'));

    final element = this.element;
    if (element == null) return false;
    if (isError(element)) return true;
    return element.allSupertypes.map((t) => t.element).any(isError);
  }

  @override
  String get kind => 'class';

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
  late final Iterable<Field> instanceFields =
      allFields.where((f) => !f.isStatic);

  @override
  bool get publicInheritedInstanceFields =>
      publicInstanceFields.every((f) => f.isInherited);

  @override
  Iterable<Field> get constantFields => allFields.where((f) => f.isConst);

  static Iterable<MapEntry<String, CommentReferable>> _constructorGenerator(
      Iterable<Constructor> source) sync* {
    for (var constructor in source) {
      yield MapEntry(constructor.referenceName, constructor);
      yield MapEntry(
          '${constructor.enclosingElement.referenceName}.${constructor.referenceName}',
          constructor);
      if (constructor.isDefaultConstructor) {
        yield MapEntry('new', constructor);
      }
    }
  }

  @override
  Iterable<MapEntry<String, CommentReferable>>
      get extraReferenceChildren sync* {
    yield* _constructorGenerator(constructors);
    // TODO(jcollins-g): wean important users off of relying on static method
    // inheritance (dart-lang/dartdoc#2698)
    for (var container
        in publicSuperChain.map((t) => t.modelElement).whereType<Container>()) {
      for (var modelElement in [
        ...container.staticFields,
        ...container.staticMethods,
      ]) {
        yield MapEntry(modelElement.referenceName, modelElement);
      }
      if (container is Class) {
        yield* _constructorGenerator(container.constructors);
      }
    }
  }

  @override
  String get relationshipsClass => 'clazz-relationships';
}
