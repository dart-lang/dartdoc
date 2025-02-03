// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/scope.dart';
// ignore: implementation_imports
import 'package:analyzer/src/utilities/extensions/element.dart';
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
  Container(super.library, super.packageGraph);

  @override
  // ignore: analyzer_use_new_elements
  Element get element => element2.asElement!;

  @override
  Element2 get element2;

  // TODO(jcollins-g): Implement a ContainerScope that flattens supertypes?
  @override
  Scope? get scope => null;

  @override
  bool get hasParameters => false;

  bool get isExtension => element2 is ExtensionElement2;

  /// Whether this is an enum.
  bool get isEnum => element2 is EnumElement2;

  /// Whether this is an interface (e.g. class, enum, mixin, or extension type).
  bool get isInterface => element2 is InterfaceElement2;

  /// Whether this is a mixin.
  bool get isMixin => element2 is MixinElement2;

  /// Whether this container represents the Object class from 'dart:core'.
  bool get isDartCoreObject =>
      element2.name3 == 'Object' && element2.library2?.name3 == 'dart.core';

  /// The model elements of all of the members of this container, including
  /// declared and inherited ones.
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
      allModelElements.where((e) => e.isCanonical).toList(growable: false);

  /// All methods, including operators and statics, declared on [element].
  ///
  /// [declaredMethods] must be the union of [instanceMethods],
  /// [staticMethods], and [instanceOperators].
  Iterable<Method> get declaredMethods;

  /// The instance methods available on [element], including declared and
  /// inherited ones.
  Iterable<Method> get instanceMethods;

  /// Whether all instance fields are inherited.
  bool get publicInheritedInstanceFields => false;

  /// Whether all instance methods are inherited.
  bool get publicInheritedInstanceMethods => false;

  /// Whether all instance operators are inherited.
  bool get publicInheritedInstanceOperators => false;

  /// Override if this is [Constructable].
  bool get hasPublicConstructors => false;

  List<Constructor> get publicConstructorsSorted => const [];

  bool get hasAvailableInstanceMethods =>
      availableInstanceMethodsSorted.isNotEmpty;

  List<Method> get availableInstanceMethodsSorted;

  @nonVirtual
  late final List<Operator> declaredOperators =
      declaredMethods.whereType<Operator>().toList(growable: false);

  @override
  ModelElement get enclosingElement;

  /// The instance operators declared on [element].
  Iterable<Operator> get instanceOperators => declaredOperators;

  bool get hasAvailableInstanceOperators =>
      availableInstanceOperatorsSorted.isNotEmpty;

  List<Operator> get availableInstanceOperatorsSorted;

  /// Fields fully declared in this [Container].
  Iterable<Field> get declaredFields;

  /// All instance fields declared in this [Container].
  Iterable<Field> get instanceFields =>
      declaredFields.where((f) => !f.isStatic);

  bool get hasInstanceFields => instanceFields.isNotEmpty;

  @nonVirtual
  bool get hasAvailableInstanceFields => instanceFields.any((e) => e.isPublic);

  List<Field> get availableInstanceFieldsSorted;

  Iterable<Field> get constantFields => declaredFields.where((f) => f.isConst);

  bool get hasPublicConstantFields => constantFields.any((e) => e.isPublic);

  List<Field> get publicConstantFieldsSorted =>
      constantFields.wherePublic.toList(growable: false)..sort(byName);

  /// The total list of public enum values.
  ///
  /// This is defined on [Container] instead of just [Enum], because the
  /// `ContainerSidebar` Mustache template needs to refer to this field.
  Iterable<Field> get publicEnumValues => const [];

  /// Whether this container has any public enum values.
  ///
  /// This is defined on [Container] instead of just [Enum], because the
  /// `ContainerSidebar` Mustache template needs to refer to this field.
  bool get hasPublicEnumValues => publicEnumValues.isNotEmpty;

  /// The instance accessors declared on [element].
  Iterable<Accessor> get instanceAccessors =>
      instanceFields.expand((f) => f.allAccessors);

  /// The static accessors declared on [element].
  Iterable<Accessor> get staticAccessors =>
      staticFields.expand((f) => f.allAccessors);

  /// This container might be canonical for elements it does not contain.
  /// See [Inheritable.canonicalEnclosingContainer].
  bool containsElement(Element2? element) => _allElements.contains(element);

  late final Set<Element2> _allElements =
      allModelElements.map((e) => e.element2).toSet();

  bool get hasPublicStaticFields => staticFields.any((e) => e.isPublic);

  List<Field> get publicStaticFieldsSorted =>
      staticFields.wherePublic.toList(growable: false)..sort();

  Iterable<Field> get staticFields => declaredFields.where((f) => f.isStatic);

  Iterable<Field> get variableStaticFields =>
      staticFields.where((f) => !f.isConst);

  bool get hasPublicVariableStaticFields =>
      variableStaticFields.any((e) => e.isPublic);

  List<Field> get publicVariableStaticFieldsSorted =>
      variableStaticFields.wherePublic.toList(growable: false)..sort();

  /// The static methods declared on [element].
  Iterable<Method> get staticMethods =>
      declaredMethods.where((m) => m.isStatic);

  bool get hasPublicStaticMethods => staticMethods.any((e) => e.isPublic);

  List<Method> get publicStaticMethodsSorted =>
      staticMethods.wherePublic.toList(growable: false)..sort();

  /// For subclasses to add items after the main pass but before the
  /// parameter-global.
  @visibleForOverriding
  Map<String, CommentReferable> get extraReferenceChildren;

  @override
  @mustCallSuper
  late final Map<String, CommentReferable> referenceChildren = {
    for (var modelElement in allModelElements)
      // Don't complain about references to parameter names, but prefer
      // referring to anything else.
      // TODO(jcollins-g): Figure out something good to do in the ecosystem
      // here to wean people off the habit of unscoped parameter references.
      if (modelElement.hasParameters) ...modelElement.parameters.asMapByName,
    ...extraReferenceChildren,
    for (var element in allModelElements
        .whereNotType<Accessor>()
        .whereNotType<Constructor>())
      element.referenceName: element,
  };

  @override
  Iterable<CommentReferable> get referenceParents => [library];

  /// The full path of this element's sidebar file.
  String get sidebarPath;

  @override
  String get aboveSidebarPath => canonicalLibraryOrThrow.sidebarPath;

  @override
  String get belowSidebarPath => sidebarPath;

  /// The CSS class to use in an inheritance list.
  String get relationshipsClass;
}
