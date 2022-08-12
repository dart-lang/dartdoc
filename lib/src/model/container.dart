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
/// * **documented**: Filtered versions of the above members, containing only
///   documented items. These are available mostly for the templating system.
/// * **sorted** : Filtered versions of the above members as a list sorted by
///   name.  These are available for the templating system.
/// * **has** : boolean getters indicating whether the underlying collections
///   are empty.  These are available mostly for the templating system.
abstract class Container extends ModelElement
    with Categorization, TypeParameters {
  Container(super.element, super.library, super.packageGraph);

  /// Containers must have associated packages.
  @override
  Package get package => super.package;

  // TODO(jcollins-g): Implement a ContainerScope that flattens supertypes?
  @override
  Scope? get scope => null;

  @override
  bool get hasParameters => false;

  /// Whether this a class or mixin, but not an enum.
  bool get isClass => element is ClassElement;
  bool get isExtension => element is ExtensionElement;

  /// Whether this is a class, an enum, or an extension.
  ///
  /// For templates, classes and extensions have much in common despite
  /// differing underlying implementations in the analyzer.
  bool get isClassOrEnumOrExtension => element is ClassElement || isExtension;

  /// Whether this is an enum.
  bool get isEnum => element is EnumElement;

  /// Whether this is a class or an enum.
  bool get isClassOrEnum => element is ClassElement;

  /// Whether this is a mixin.
  bool get isMixin => element is MixinElement;

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
  bool get documentedInheritedInstanceFields => false;

  /// Whether all instance methods are inherited.
  bool get documentedInheritedInstanceMethods => false;

  /// Whether all instance operators are inherited.
  bool get documentedInheritedInstanceOperators => false;

  /// Override if this is [Constructable].
  bool get hasDocumentedConstructors => false;

  List<Constructor> get documentedConstructorsSorted => [];

  @nonVirtual
  bool get hasDocumentedInstanceMethods =>
      model_utils.filterNonDocumented(instanceMethods).isNotEmpty;

  Iterable<Method> get documentedInstanceMethods =>
      model_utils.filterNonDocumented(instanceMethods);

  late final List<Method> documentedInstanceMethodsSorted =
      documentedInstanceMethods.toList()..sort();

  @nonVirtual
  late final Iterable<Operator> declaredOperators =
      declaredMethods.whereType<Operator>().toList(growable: false);

  @override
  ModelElement get enclosingElement;

  Iterable<Operator> get instanceOperators => declaredOperators;

  @nonVirtual
  bool get hasDocumentedInstanceOperators =>
      documentedInstanceOperatorsSorted.isNotEmpty;

  @nonVirtual
  Iterable<Operator> get documentedInstanceOperators =>
      model_utils.filterNonDocumented(instanceOperators);

  late final List<Operator> documentedInstanceOperatorsSorted =
      documentedInstanceOperators.toList()..sort();

  /// Fields fully declared in this [Container].
  Iterable<Field> get declaredFields;

  /// All instance fields declared in this [Container].
  Iterable<Field> get instanceFields =>
      declaredFields.where((f) => !f.isStatic);

  bool get hasInstanceFields => instanceFields.isNotEmpty;

  @nonVirtual
  Iterable<Field> get documentedInstanceFields =>
      model_utils.filterNonDocumented(instanceFields);

  @nonVirtual
  bool get hasDocumentedInstanceFields => documentedInstanceFields.isNotEmpty;

  late final List<Field> documentedInstanceFieldsSorted =
      documentedInstanceFields.toList()..sort(byName);

  Iterable<Field> get constantFields => declaredFields.where((f) => f.isConst);

  Iterable<Field> get documentedConstantFields =>
      model_utils.filterNonDocumented(constantFields);

  bool get hasDocumentedConstantFields => documentedConstantFields.isNotEmpty;

  late final List<Field> documentedConstantFieldsSorted =
      documentedConstantFields.toList()..sort(byName);

  Iterable<Field> get documentedEnumValues => [];

  bool get hasDocumentedEnumValues => documentedEnumValues.isNotEmpty;

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

  bool get hasDocumentedStaticFields => documentedStaticFieldsSorted.isNotEmpty;

  late final List<Field> documentedStaticFieldsSorted =
      model_utils.filterNonDocumented(staticFields).toList()..sort();

  Iterable<Field> get staticFields => declaredFields.where((f) => f.isStatic);

  Iterable<Field> get variableStaticFields =>
      staticFields.where((f) => !f.isConst);

  bool get hasDocumentedVariableStaticFields =>
      documentedVariableStaticFieldsSorted.isNotEmpty;

  late final List<Field> documentedVariableStaticFieldsSorted =
      model_utils.filterNonDocumented(variableStaticFields).toList()..sort();

  Iterable<Method> get staticMethods =>
      declaredMethods.where((m) => m.isStatic);

  bool get hasDocumentedStaticMethods =>
      model_utils.filterNonDocumented(documentedStaticMethodsSorted).isNotEmpty;

  late final List<Method> documentedStaticMethodsSorted =
      model_utils.filterNonDocumented(staticMethods).toList()..sort();

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

  @override
  String get filePath => '${library.dirName}/$fileName';

  /// The CSS class to use in an inheritance list.
  String get relationshipsClass;
}
