// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/scope.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:meta/meta.dart';

/// A [Container] represents a Dart construct that can contain methods,
/// operators, and fields, such as [Class], [Enum], or [Extension].
///
/// Member naming in [Container] follows these general rules:
///
/// * **instance** : children of this container that can be referenced from
///   within the container without a prefix. These are usually overridden in
///   subclasses with calls to 'super'.
/// * **constant** : children declared constant.
/// * **variable** : The opposite of constant. These are available for the
///   templating system.
/// * **static** : static children of this container.
/// * **public** : Filtered versions of the above members, containing only
///   public items. These are available mostly for the templating system.
/// * **sorted** : Filtered versions of the above members as a list sorted by
///   name.  These are available for the templating system.
/// * **has** : boolean getters indicating whether the underlying collections
///   are empty.  These are available mostly for the templating system.
abstract class Container extends ModelElement
    with Categorization, TypeParameters {
  Container(super.element, super.library, super.packageGraph);

  /// Containers must have associated libraries.
  @override
  Library get library => super.library!;

  /// Containers must have associated packages.
  @override
  Package get package => super.package!;

  // TODO(jcollins-g): Implement a ContainerScope that flattens supertypes?
  @override
  Scope? get scope => null;

  @override
  bool get hasParameters => false;

  /// Whether this a class or mixin, but not an enum.
  bool get isClass =>
      element is ClassElement && !(element as ClassElement).isEnum;
  bool get isExtension => element is ExtensionElement;

  /// Whether this is a class, an enum, or an extension.
  ///
  /// For templates, classes and extensions have much in common despite
  /// differing underlying implementations in the analyzer.
  bool get isClassOrEnumOrExtension => element is ClassElement || isExtension;

  /// Whether this is an enum.
  bool get isEnum =>
      element is ClassElement && (element as ClassElement).isEnum;

  /// Whether this is a class or an enum.
  bool get isClassOrEnum => element is ClassElement;

  /// Whether this is a mixin.
  bool get isMixin =>
      element is ClassElement && (element as ClassElement).isMixin;

  Iterable<ModelElement> get allModelElements => [
        ...instanceMethods,
        ...instanceFields,
        ...instanceOperators,
        ...instanceAccessors,
        ...staticFields,
        ...staticAccessors,
        ...staticMethods,
      ];

  late final List<ModelElement> allCanonicalModelElements =
      allModelElements.where((e) => e.isCanonical).toList();

  /// All methods, including operators and statics, declared as part of this
  /// [Container].
  ///
  /// [declaredMethods] must be the union of [instanceMethods],
  /// [staticMethods], and [instanceOperators].
  Iterable<Method> get declaredMethods;

  Iterable<Method> get instanceMethods => declaredMethods
      .where((m) => !m.isStatic && !m.isOperator)
      .toList(growable: false);

  /// Whether all instance fields are inherited.
  bool get publicInheritedInstanceFields => false;

  /// Whether all instance methods are inherited.
  bool get publicInheritedInstanceMethods => false;

  /// Whether all instance operators are inherited.
  bool get publicInheritedInstanceOperators => false;

  /// Override if this is [Constructable].
  bool get hasPublicConstructors => false;

  List<Constructor> get publicConstructorsSorted => [];

  @nonVirtual
  bool get hasPublicInstanceMethods =>
      model_utils.filterNonPublic(instanceMethods).isNotEmpty;

  Iterable<Method> get publicInstanceMethods =>
      model_utils.filterNonPublic(instanceMethods);

  late final List<Method> publicInstanceMethodsSorted =
      publicInstanceMethods.toList()..sort();

  @nonVirtual
  late final Iterable<Operator> declaredOperators =
      declaredMethods.whereType<Operator>().toList(growable: false);

  @override
  ModelElement get enclosingElement;

  Iterable<Operator> get instanceOperators => declaredOperators;

  @nonVirtual
  bool get hasPublicInstanceOperators =>
      publicInstanceOperatorsSorted.isNotEmpty;

  @nonVirtual
  Iterable<Operator> get publicInstanceOperators =>
      model_utils.filterNonPublic(instanceOperators);

  late final List<Operator> publicInstanceOperatorsSorted =
      publicInstanceOperators.toList()..sort();

  /// Fields fully declared in this [Container].
  Iterable<Field> get declaredFields;

  /// All instance fields declared in this [Container].
  Iterable<Field> get instanceFields =>
      declaredFields.where((f) => !f.isStatic);

  bool get hasInstanceFields => instanceFields.isNotEmpty;

  @nonVirtual
  Iterable<Field> get publicInstanceFields =>
      model_utils.filterNonPublic(instanceFields);

  @nonVirtual
  bool get hasPublicInstanceFields => publicInstanceFields.isNotEmpty;

  late final List<Field> publicInstanceFieldsSorted =
      publicInstanceFields.toList()..sort(byName);

  Iterable<Field> get constantFields => declaredFields.where((f) => f.isConst);

  Iterable<Field> get publicConstantFields =>
      model_utils.filterNonPublic(constantFields);

  bool get hasPublicConstantFields => publicConstantFields.isNotEmpty;

  late final List<Field> publicConstantFieldsSorted =
      publicConstantFields.toList()..sort(byName);

  Iterable<Field> get publicEnumValues => [];

  bool get hasPublicEnumValues => publicEnumValues.isNotEmpty;

  Iterable<Accessor> get instanceAccessors =>
      instanceFields.expand((f) => f.allAccessors);

  Iterable<Accessor> get staticAccessors =>
      staticFields.expand((f) => f.allAccessors);

  /// This container might be canonical for elements it does not contain.
  /// See [Inheritable.canonicalEnclosingContainer].
  bool containsElement(Element? element) => allElements.contains(element);

  late final Set<Element?> allElements =
      allModelElements.map((e) => e.element).toSet();

  late final Map<String, List<ModelElement>> _membersByName = () {
    var membersByName = <String, List<ModelElement>>{};
    for (var element in allModelElements) {
      membersByName.putIfAbsent(element.name, () => []).add(element);
    }
    return membersByName;
  }();

  /// Given a ModelElement that is a member of some other class, returns
  /// the member of this class that has the same name and runtime type.
  ///
  /// This enables object substitution for canonicalization, such as Interceptor
  /// for Object.
  T memberByExample<T extends ModelElement>(T example) {
    ModelElement member;
    // [T] is insufficiently specific to disambiguate between different
    // subtypes of [Inheritable] or other mixins/implementations of
    // [ModelElement] via [Iterable.whereType].
    var possibleMembers = _membersByName[example.name]!
        .where((e) => e.runtimeType == example.runtimeType);
    if (example is Accessor) {
      possibleMembers = possibleMembers
          .where((e) => example.isGetter == (e as Accessor).isGetter);
    }
    member = possibleMembers.first;
    assert(possibleMembers.length == 1);
    return member as T;
  }

  bool get hasPublicStaticFields => publicStaticFieldsSorted.isNotEmpty;

  late final List<Field> publicStaticFieldsSorted =
      model_utils.filterNonPublic(staticFields).toList()..sort();

  Iterable<Field> get staticFields => declaredFields.where((f) => f.isStatic);

  Iterable<Field> get variableStaticFields =>
      staticFields.where((f) => !f.isConst);

  bool get hasPublicVariableStaticFields =>
      publicVariableStaticFieldsSorted.isNotEmpty;

  late final List<Field> publicVariableStaticFieldsSorted =
      model_utils.filterNonPublic(variableStaticFields).toList()..sort();

  Iterable<Method> get staticMethods =>
      declaredMethods.where((m) => m.isStatic);

  bool get hasPublicStaticMethods =>
      model_utils.filterNonPublic(publicStaticMethodsSorted).isNotEmpty;

  late final List<Method> publicStaticMethodsSorted =
      model_utils.filterNonPublic(staticMethods).toList()..sort();

  /// For subclasses to add items after the main pass but before the
  /// parameter-global.
  @visibleForOverriding
  Iterable<MapEntry<String, CommentReferable>> get extraReferenceChildren;

  @override
  @mustCallSuper
  late final Map<String, CommentReferable> referenceChildren = () {
    var referenceChildren = <String, CommentReferable>{
      for (var element in allModelElements
          .whereNotType<Accessor>()
          .whereNotType<Constructor>())
        element.referenceName: element,
    };

    referenceChildren.addEntriesIfAbsent(extraReferenceChildren);
    // Process unscoped parameters last to make sure they don't override
    // other options.
    for (var modelElement in allModelElements) {
      // Don't complain about references to parameter names, but prefer
      // referring to anything else.
      // TODO(jcollins-g): Figure out something good to do in the ecosystem
      // here to wean people off the habit of unscoped parameter references.
      if (modelElement.hasParameters) {
        referenceChildren
            .addEntriesIfAbsent(modelElement.parameters.generateEntries());
      }
    }
    referenceChildren['this'] = this;
    return referenceChildren;
  }();

  @override
  Iterable<CommentReferable> get referenceParents => [definingLibrary, library];

  /// The CSS class to use in an inheritance list.
  String get relationshipsClass;
}
