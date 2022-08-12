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

  bool get hasDocumentedClasses => documentedClasses.isNotEmpty;

  bool get hasDocumentedExtensions => documentedExtensions.isNotEmpty;

  bool get hasDocumentedConstants => documentedConstants.isNotEmpty;

  bool get hasDocumentedEnums => documentedEnums.isNotEmpty;

  bool get hasDocumentedExceptions => _documentedExceptions.isNotEmpty;

  bool get hasDocumentedFunctions => documentedFunctions.isNotEmpty;

  bool get hasDocumentedMixins => documentedMixins.isNotEmpty;

  bool get hasDocumentedProperties => documentedProperties.isNotEmpty;

  bool get hasDocumentedTypedefs => documentedTypedefs.isNotEmpty;

  Iterable<Class> get documentedClasses =>
      model_utils.filterNonDocumented(classes);

  // TODO(jcollins-g):  Setting this type parameter to `Container` magically
  // fixes a number of type problems in the AOT compiler, but I am mystified as
  // to why that should be the case.
  late final Iterable<Container> documentedClassesSorted =
      documentedClasses.toList()..sort();

  Iterable<Extension> get documentedExtensions =>
      model_utils.filterNonDocumented(extensions);

  late final Iterable<Extension> documentedExtensionsSorted =
      documentedExtensions.toList()..sort();

  Iterable<TopLevelVariable> get documentedConstants =>
      model_utils.filterNonDocumented(constants);

  Iterable<TopLevelVariable> get documentedConstantsSorted =>
      documentedConstants.toList()..sort();

  Iterable<Enum> get documentedEnums => model_utils.filterNonDocumented(enums);

  late final Iterable<Enum> documentedEnumsSorted = documentedEnums.toList()
    ..sort();

  Iterable<Class> get _documentedExceptions =>
      model_utils.filterNonDocumented(exceptions);

  late final Iterable<Class> documentedExceptionsSorted =
      _documentedExceptions.toList()..sort();

  Iterable<ModelFunctionTyped> get documentedFunctions =>
      model_utils.filterNonDocumented(functions!);

  late final Iterable<ModelFunctionTyped> documentedFunctionsSorted =
      documentedFunctions.toList()..sort();

  Iterable<Mixin> get documentedMixins =>
      model_utils.filterNonDocumented(mixins);

  late final Iterable<Mixin> documentedMixinsSorted = documentedMixins.toList()
    ..sort();

  Iterable<TopLevelVariable> get documentedProperties =>
      model_utils.filterNonDocumented(properties);

  late final Iterable<TopLevelVariable> documentedPropertiesSorted =
      documentedProperties.toList()..sort();

  Iterable<Typedef> get documentedTypedefs =>
      model_utils.filterNonDocumented(typedefs);

  late final Iterable<Typedef> documentedTypedefsSorted =
      documentedTypedefs.toList()..sort();
}
