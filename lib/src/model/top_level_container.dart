// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;

/// A set of [Class]es, [Extension]s, [Enum]s, [Mixin]s, [TopLevelVariable]s,
/// [ModelFunction]s, and [Typedef]s, possibly initialized after construction by
/// accessing private member variables.
///
/// Do not call any methods or members excepting [name] and the private Lists
/// below before finishing initialization of a [TopLevelContainer].
abstract class TopLevelContainer implements Nameable {
  Iterable<Class> get classes;

  Iterable<Extension> get extensions;

  Iterable<Enum> get enums;

  Iterable<Mixin> get mixins;

  Iterable<Class> get exceptions;

  Iterable<TopLevelVariable> get constants;

  Iterable<TopLevelVariable> get properties;

  Iterable<ModelFunction>? get functions;

  Iterable<Typedef> get typedefs;

  bool get hasPublicClasses => publicClasses.isNotEmpty;

  bool get hasPublicExtensions => publicExtensions.isNotEmpty;

  bool get hasPublicConstants => publicConstants.isNotEmpty;

  bool get hasPublicEnums => publicEnums.isNotEmpty;

  bool get hasPublicExceptions => _publicExceptions.isNotEmpty;

  bool get hasPublicFunctions => publicFunctions.isNotEmpty;

  bool get hasPublicMixins => publicMixins.isNotEmpty;

  bool get hasPublicProperties => publicProperties.isNotEmpty;

  bool get hasPublicTypedefs => publicTypedefs.isNotEmpty;

  Iterable<Class> get publicClasses => model_utils.filterNonPublic(classes);

  // TODO(jcollins-g):  Setting this type parameter to `Container` magically
  // fixes a number of type problems in the AOT compiler, but I am mystified as
  // to why that should be the case.
  late final Iterable<Container> publicClassesSorted =
      publicClasses.toList(growable: false)..sort();

  Iterable<Extension> get publicExtensions =>
      model_utils.filterNonPublic(extensions);

  late final Iterable<Extension> publicExtensionsSorted =
      publicExtensions.toList(growable: false)..sort();

  Iterable<TopLevelVariable> get publicConstants =>
      model_utils.filterNonPublic(constants);

  Iterable<TopLevelVariable> get publicConstantsSorted =>
      publicConstants.toList(growable: false)..sort();

  Iterable<Enum> get publicEnums => model_utils.filterNonPublic(enums);

  late final Iterable<Enum> publicEnumsSorted =
      publicEnums.toList(growable: false)..sort();

  Iterable<Class> get _publicExceptions =>
      model_utils.filterNonPublic(exceptions);

  late final Iterable<Class> publicExceptionsSorted =
      _publicExceptions.toList(growable: false)..sort();

  Iterable<ModelFunctionTyped> get publicFunctions =>
      model_utils.filterNonPublic(functions!);

  late final Iterable<ModelFunctionTyped> publicFunctionsSorted =
      publicFunctions.toList(growable: false)..sort();

  Iterable<Mixin> get publicMixins => model_utils.filterNonPublic(mixins);

  late final Iterable<Mixin> publicMixinsSorted =
      publicMixins.toList(growable: false)..sort();

  Iterable<TopLevelVariable> get publicProperties =>
      model_utils.filterNonPublic(properties);

  late final Iterable<TopLevelVariable> publicPropertiesSorted =
      publicProperties.toList(growable: false)..sort();

  Iterable<Typedef> get publicTypedefs => model_utils.filterNonPublic(typedefs);

  late final Iterable<Typedef> publicTypedefsSorted =
      publicTypedefs.toList(growable: false)..sort();
}
