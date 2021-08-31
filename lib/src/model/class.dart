// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/inheriting_container.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:meta/meta.dart';

import 'comment_referable.dart';

/// An mixin to build an [InheritingContainer] capable of being constructed
/// with a direct call to a [Constructor] in Dart.
mixin Constructable on InheritingContainer {
  Iterable<Constructor> get constructors => element.constructors
      .map((e) => ModelElement.from(e, library, packageGraph) as Constructor);

  @override
  bool get hasPublicConstructors => publicConstructors.isNotEmpty;

  @visibleForTesting
  Iterable<Constructor> get publicConstructors =>
      model_utils.filterNonPublic(constructors);

  List<Constructor> _publicConstructorsSorted;

  @override
  Iterable<Constructor> get publicConstructorsSorted =>
      _publicConstructorsSorted ??= publicConstructors.toList()..sort(byName);

  Constructor _unnamedConstructor;
  Constructor get unnamedConstructor {
    _unnamedConstructor ??= constructors
        .firstWhere((c) => c.isUnnamedConstructor, orElse: () => null);
    return _unnamedConstructor;
  }

  Constructor _defaultConstructor;

  /// With constructor tearoffs, this is no longer equivalent to the unnamed
  /// constructor and assumptions based on that are incorrect.
  Constructor get defaultConstructor {
    _defaultConstructor ??= unnamedConstructor ??
        constructors.firstWhere((c) => c.isDefaultConstructor);
    return _defaultConstructor;
  }

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

/// A [Container] defined with a `class` declaration in Dart.
///
/// Members follow similar naming rules to [Container], with the following
/// additions:
///
/// **instance**: As with [Container], but also includes inherited children.
/// **inherited**: Filtered getters giving only inherited children.
class Class extends InheritingContainer with Constructable {
  final List<DefinedElementType> mixedInTypes;

  final List<DefinedElementType> _directInterfaces;

  Class(ClassElement element, Library library, PackageGraph packageGraph)
      : mixedInTypes = element.mixins
            .map<DefinedElementType>(
                (f) => ElementType.from(f, library, packageGraph))
            .where((mixin) => mixin != null)
            .toList(growable: false),
        _directInterfaces = element.interfaces
            .map<DefinedElementType>(
                (f) => ElementType.from(f, library, packageGraph))
            .toList(growable: false),
        super(element, library, packageGraph) {
    packageGraph.specialClasses.addSpecial(this);
  }

  List<ModelElement> _allModelElements;

  @override
  List<ModelElement> get allModelElements {
    _allModelElements ??= <ModelElement>[
      ...super.allModelElements,
      ...constructors,
    ];
    return _allModelElements;
  }

  /// Returns the library that encloses this element.
  @override
  ModelElement get enclosingElement => library;

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
  bool get hasModifiers => super.hasModifiers || hasPublicMixedInTypes;

  bool get hasPublicMixedInTypes => publicMixedInTypes.isNotEmpty;

  Iterable<DefinedElementType> get publicMixedInTypes =>
      model_utils.filterNonPublic(mixedInTypes);

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  /// Interfaces directly implemented by this class.
  List<DefinedElementType> get interfaces => _directInterfaces;

  /// The public interfaces may include substitutions for intermediate
  /// private interfaces, and so unlike other public* methods, is not
  /// a strict subset of [interfaces].
  @override
  Iterable<DefinedElementType> get publicInterfaces sync* {
    for (var i in _directInterfaces) {
      /// Do not recurse if we can find an element here.
      if (i.modelElement.canonicalModelElement != null) {
        yield i;
        continue;
      }
      // Public types used to be unconditionally exposed here.  However,
      // if the packages are [DocumentLocation.missing] we generally treat types
      // defined in them as actually defined in a documented package.
      // That translates to them being defined here, but in 'src/' or similar,
      // and so, are now always hidden.

      // This type is not backed by a canonical Class; search
      // the superchain and publicInterfaces of this interface to pretend
      // as though the hidden class didn't exist and this class was declared
      // directly referencing the canonical classes further up the chain.
      if (i.modelElement is InheritingContainer) {
        var hiddenContainer = i.modelElement as InheritingContainer;
        if (hiddenContainer.publicSuperChain.isNotEmpty) {
          yield hiddenContainer.publicSuperChain.first;
        }
        yield* hiddenContainer.publicInterfaces;
      } else {
        assert(
            false,
            'Can not handle intermediate non-public interfaces '
            'created by ModelElements that are not classes or mixins:  '
            '$fullyQualifiedName contains an interface {$i}, '
            'defined by ${i.modelElement}');
        continue;
      }
    }
  }

  bool get isAbstract => element.isAbstract;

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  bool get isErrorOrException {
    bool _doCheck(ClassElement element) {
      return (element.library.isDartCore &&
          (element.name == 'Exception' || element.name == 'Error'));
    }

    // if this class is itself Error or Exception, return true
    if (_doCheck(element)) return true;

    return element.allSupertypes.map((t) => t.element).any(_doCheck);
  }

  @override
  String get kind => 'class';

  /// Not the same as superChain as it may include mixins.
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  List<InheritingContainer> _inheritanceChain;

  @override
  List<InheritingContainer> get inheritanceChain {
    if (_inheritanceChain == null) {
      _inheritanceChain = [];
      _inheritanceChain.add(this);

      /// Caching should make this recursion a little less painful.
      for (var c in mixedInTypes.reversed
          .map((e) => (e.modelElement as InheritingContainer))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }

      for (var c
          in superChain.map((e) => (e.modelElement as InheritingContainer))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }

      /// Interfaces need to come last, because classes in the superChain might
      /// implement them even when they aren't mentioned.
      _inheritanceChain.addAll(interfaces.expand(
          (e) => (e.modelElement as InheritingContainer).inheritanceChain));
    }
    return _inheritanceChain.toList(growable: false);
  }

  Iterable<Field> _instanceFields;

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
