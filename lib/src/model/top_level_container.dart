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
mixin TopLevelContainer implements Nameable {
  Iterable<Class> get classes;

  Iterable<Extension> get extensions;

  Iterable<ExtensionType> get extensionTypes;

  Iterable<Enum> get enums;

  Iterable<Mixin> get mixins;

  Iterable<Class> get exceptions;

  Iterable<TopLevelVariable> get constants;

  Iterable<TopLevelVariable> get properties;

  Iterable<ModelFunction> get functions;

  Iterable<Typedef> get typedefs;

  bool get hasPublicClasses => classes.any((e) => e.isPublic);

  bool get hasPublicExtensions => extensions.any((e) => e.isPublic);

  bool get hasPublicExtensionTypes => extensionTypes.any((e) => e.isPublic);

  bool get hasPublicConstants => constants.any((e) => e.isPublic);

  bool get hasPublicEnums => enums.any((e) => e.isPublic);

  bool get hasPublicExceptions => exceptions.any((e) => e.isPublic);

  bool get hasPublicFunctions => functions.any((e) => e.isPublic);

  bool get hasPublicMixins => mixins.any((e) => e.isPublic);

  bool get hasPublicProperties => properties.any((e) => e.isPublic);

  bool get hasPublicTypedefs => typedefs.any((e) => e.isPublic);

  // TODO(jcollins-g):  Setting this type parameter to `Container` magically
  // fixes a number of type problems in the AOT compiler, but I am mystified as
  // to why that should be the case.
  late final List<Container> publicClassesSorted =
      classes.wherePublic.toList(growable: false)..sort();

  late final List<Extension> publicExtensionsSorted =
      extensions.wherePublic.toList(growable: false)..sort();

  late final List<ExtensionType> publicExtensionTypesSorted =
      extensionTypes.wherePublic.toList(growable: false)..sort();

  Iterable<TopLevelVariable> get publicConstantsSorted =>
      constants.wherePublic.toList(growable: false)..sort();

  late final List<Enum> publicEnumsSorted =
      enums.wherePublic.toList(growable: false)..sort();

  late final List<Class> publicExceptionsSorted =
      exceptions.wherePublic.toList(growable: false)..sort();

  late final List<ModelFunctionTyped> publicFunctionsSorted =
      functions.wherePublic.toList(growable: false)..sort();

  late final List<Mixin> publicMixinsSorted =
      mixins.wherePublic.toList(growable: false)..sort();

  late final List<TopLevelVariable> publicPropertiesSorted =
      properties.wherePublic.toList(growable: false)..sort();

  late final List<Typedef> publicTypedefsSorted =
      typedefs.wherePublic.toList(growable: false)..sort();
}
