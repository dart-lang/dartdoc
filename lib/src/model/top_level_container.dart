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

  Iterable<ModelFunction> get functions;

  Iterable<Typedef> get typedefs;

  bool get hasPublicClasses => publicClasses.isNotEmpty;

  bool get hasPublicExtensions => publicExtensions.isNotEmpty;

  bool get hasPublicConstants => publicConstants.isNotEmpty;

  bool get hasPublicEnums => publicEnums.isNotEmpty;

  bool get hasPublicExceptions => publicExceptions.isNotEmpty;

  bool get hasPublicFunctions => publicFunctions.isNotEmpty;

  bool get hasPublicMixins => publicMixins.isNotEmpty;

  bool get hasPublicProperties => publicProperties.isNotEmpty;

  bool get hasPublicTypedefs => publicTypedefs.isNotEmpty;

  Iterable<Class> get publicClasses => model_utils.filterNonPublic(classes);

  List<Class> _publicClassesSorted;
  Iterable<Class> get publicClassesSorted =>
      _publicClassesSorted ??= publicClasses.toList()..sort(byNameStable);

  Iterable<Extension> get publicExtensions =>
      model_utils.filterNonPublic(extensions);

  List<Extension> _publicExtensionsSorted;
  Iterable<Extension> get publicExtensionsSorted =>
      _publicExtensionsSorted ??= publicExtensions.toList()..sort(byNameStable);

  Iterable<TopLevelVariable> get publicConstants =>
      model_utils.filterNonPublic(constants);

  Iterable<TopLevelVariable> get publicConstantsSorted =>
      publicConstants.toList()..sort(byNameStable);

  Iterable<Enum> get publicEnums => model_utils.filterNonPublic(enums);

  List<Enum> _publicEnumsSorted;
  Iterable<Enum> get publicEnumsSorted =>
      _publicEnumsSorted ??= publicEnums.toList()..sort(byNameStable);

  Iterable<Class> get publicExceptions =>
      model_utils.filterNonPublic(exceptions);

  List<Class> _publicExceptionsSorted;
  Iterable<Class> get publicExceptionsSorted =>
      _publicExceptionsSorted ??= publicExceptions.toList()..sort(byNameStable);

  Iterable<ModelFunctionTyped> get publicFunctions =>
      model_utils.filterNonPublic(functions);

  List<ModelFunctionTyped> _publicFunctionsSorted;
  Iterable<ModelFunctionTyped> get publicFunctionsSorted =>
      _publicFunctionsSorted ??= publicFunctions.toList()..sort(byNameStable);

  Iterable<Mixin> get publicMixins => model_utils.filterNonPublic(mixins);

  List<Mixin> _publicMixinsSorted;
  Iterable<Mixin> get publicMixinsSorted =>
      _publicMixinsSorted ??= publicMixins.toList()..sort(byNameStable);

  Iterable<TopLevelVariable> get publicProperties =>
      model_utils.filterNonPublic(properties);

  List<TopLevelVariable> _publicPropertiesSorted;
  Iterable<TopLevelVariable> get publicPropertiesSorted =>
      _publicPropertiesSorted ??= publicProperties.toList()..sort(byNameStable);

  Iterable<Typedef> get publicTypedefs => model_utils.filterNonPublic(typedefs);

  List<Typedef> _publicTypedefsSorted;
  Iterable<Typedef> get publicTypedefsSorted =>
      _publicTypedefsSorted ??= publicTypedefs.toList()..sort(byNameStable);
}
