// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;
import 'package:quiver/iterables.dart' as quiver;

// Can be either a Class or Extension, used in the package graph and template data.
// Aggregates some of the common getters.
abstract class Container extends ModelElement {
  List<Field> _constants;
  List<Operator> _operators;
  List<Method> _staticMethods;
  List<Method> _instanceMethods;
  List<Field> _staticFields;
  List<Field> _instanceFields;

  Container(Element element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  bool get isClass => element is ClassElement;

  bool get isExtension => element is ExtensionElement;

  List<Method> get methods => [];

  List<Method> get instanceMethods {
    if (_instanceMethods != null) return _instanceMethods;

    _instanceMethods = methods
        .where((m) => !m.isStatic && !m.isOperator)
        .toList(growable: false)
          ..sort(byName);
    return _instanceMethods;
  }

  bool get hasPublicMethods =>
      model_utils.filterNonPublic(instanceMethods).isNotEmpty;

  Iterable<Method> get allPublicInstanceMethods =>
      model_utils.filterNonPublic(instanceMethods);

  List<Method> get staticMethods {
    _staticMethods ??= methods.where((m) => m.isStatic).toList(growable: false)
      ..sort(byName);
    return _staticMethods;
  }

  bool get hasPublicStaticMethods =>
      model_utils.filterNonPublic(staticMethods).isNotEmpty;

  Iterable<Method> get publicStaticMethods =>
      model_utils.filterNonPublic(staticMethods);

  List<Operator> get operators {
    _operators ??= methods
        .where((m) => m.isOperator)
        .cast<Operator>()
        .toList(growable: false)
          ..sort(byName);
    return _operators;
  }

  Iterable<Operator> get allOperators => operators;

  bool get hasPublicOperators => publicOperators.isNotEmpty;

  Iterable<Operator> get allPublicOperators =>
      model_utils.filterNonPublic(allOperators);

  Iterable<Operator> get publicOperators =>
      model_utils.filterNonPublic(operators);

  List<Field> get allFields => [];

  List<Field> get staticProperties {
    _staticFields ??= allFields
        .where((f) => f.isStatic && !f.isConst)
        .toList(growable: false)
          ..sort(byName);
    return _staticFields;
  }

  Iterable<Field> get publicStaticProperties =>
      model_utils.filterNonPublic(staticProperties);

  bool get hasPublicStaticProperties => publicStaticProperties.isNotEmpty;

  List<Field> get instanceProperties {
    _instanceFields ??= allFields
        .where((f) => !f.isStatic && !f.isInherited && !f.isConst)
        .toList(growable: false)
          ..sort(byName);
    return _instanceFields;
  }

  Iterable<Field> get publicInstanceProperties =>
      model_utils.filterNonPublic(instanceProperties);

  bool get hasPublicProperties => publicInstanceProperties.isNotEmpty;

  Iterable<Field> get allInstanceFields => instanceProperties;

  Iterable<Field> get allPublicInstanceProperties =>
      model_utils.filterNonPublic(allInstanceFields);

  bool isInheritingFrom(Container other) => false;

  List<Field> get constants {
    _constants ??= allFields.where((f) => f.isConst).toList(growable: false)
      ..sort(byName);
    return _constants;
  }

  Iterable<Field> get publicConstants => model_utils.filterNonPublic(constants);

  bool get hasPublicConstants => publicConstants.isNotEmpty;

  Iterable<Accessor> get allAccessors => quiver.concat([
        allInstanceFields.expand((f) => f.allAccessors),
        constants.map((c) => c.getter)
      ]);
}
