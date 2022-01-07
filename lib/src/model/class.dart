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
  // TODO(srawlins): Figure out what we elsewhere in dartdoc.
  // ignore: overridden_fields
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
    bool _doCheck(ClassElement element) {
      return (element.library.isDartCore &&
          (element.name == 'Exception' || element.name == 'Error'));
    }

    // if this class is itself Error or Exception, return true
    if (_doCheck(element!)) return true;

    return element!.allSupertypes.map((t) => t.element).any(_doCheck);
  }

  @override
  String get kind => 'class';

  List<InheritingContainer?>? _inheritanceChain;

  /// Not the same as superChain as it may include mixins.
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  @override
  List<InheritingContainer?> get inheritanceChain {
    if (_inheritanceChain == null) {
      _inheritanceChain = [];
      _inheritanceChain!.add(this);

      /// Caching should make this recursion a little less painful.
      for (var c in mixedInTypes.reversed
          .map((e) => (e.modelElement as InheritingContainer))) {
        _inheritanceChain!.addAll(c.inheritanceChain);
      }

      for (var c
          in superChain.map((e) => (e.modelElement as InheritingContainer))) {
        _inheritanceChain!.addAll(c.inheritanceChain);
      }

      /// Interfaces need to come last, because classes in the superChain might
      /// implement them even when they aren't mentioned.
      _inheritanceChain!.addAll(interfaces.expand(
          (e) => (e.modelElement as InheritingContainer).inheritanceChain));
    }
    return _inheritanceChain!.toList(growable: false);
  }

  Iterable<Field>? _instanceFields;

  @override
  Iterable<Field> get instanceFields =>
      _instanceFields ??= allFields.where((f) => !f.isStatic);

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
}
