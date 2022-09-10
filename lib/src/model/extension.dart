// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:meta/meta.dart';

/// Extension methods
class Extension extends Container implements EnclosedElement {
  late final ElementType extendedType =
      modelBuilder.typeFrom(element.extendedType, library);

  Extension(ExtensionElement super.element, super.library, super.packageGraph);

  /// Detect if this extension applies to every object.
  bool get alwaysApplies =>
      extendedType.instantiatedType.isDynamic ||
      extendedType.instantiatedType.isVoid ||
      extendedType.instantiatedType.isDartCoreObject;

  bool couldApplyTo<T extends ExtensionTarget>(T c) =>
      _couldApplyTo(c.modelType as DefinedElementType);

  /// Return true if this extension could apply to [t].
  bool _couldApplyTo(DefinedElementType type) {
    if (extendedType.instantiatedType.isDynamic ||
        extendedType.instantiatedType.isVoid) {
      return true;
    }
    var typeInstantiated = type.instantiatedType;
    var extendedInstantiated = extendedType.instantiatedType;
    if (typeInstantiated == extendedInstantiated) {
      return true;
    }
    if (DartTypeExtension(typeInstantiated).element ==
            DartTypeExtension(extendedInstantiated).element &&
        extendedType.isSubtypeOf(type)) {
      return true;
    }
    return extendedType.isBoundSupertypeTo(type);
  }

  /// Returns the library that encloses this element.
  @override
  ModelElement get enclosingElement => library;

  @override
  String get kind => 'extension';

  @override
  late List<Method> declaredMethods = element.methods.map((e) {
    return modelBuilder.from(e, library) as Method;
  }).toList(growable: false);

  @override
  ExtensionElement get element => super.element as ExtensionElement;

  @override
  String get name => element.name == null ? '' : super.name;

  @override
  late final List<Field> declaredFields = element.fields.map((field) {
    Accessor? getter, setter;
    final fGetter = field.getter;
    if (fGetter != null) {
      getter = ContainerAccessor(fGetter, library, packageGraph);
    }
    final fSetter = field.setter;
    if (fSetter != null) {
      setter = ContainerAccessor(fSetter, library, packageGraph);
    }
    return modelBuilder.fromPropertyInducingElement(field, library,
        getter: getter, setter: setter) as Field;
  }).toList(growable: false);

  // a stronger hash?
  @override
  late final List<TypeParameter> typeParameters = element.typeParameters
      .map((typeParameter) => modelBuilder.from(
          typeParameter,
          modelBuilder.fromElement(typeParameter.enclosingElement3!.library!)
              as Library) as TypeParameter)
      .toList(growable: false);

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...typeParameters,
  ];

  @override
  String get filePath => '${library.dirName}/$fileName';

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    return _referenceChildren ??= {
      ...extendedType.referenceChildren,
      // Override extendedType entries with local items.
      ...super.referenceChildren,
    };
  }

  @override
  @visibleForOverriding
  Iterable<MapEntry<String, CommentReferable>> get extraReferenceChildren => [];

  @override
  String get relationshipsClass => 'clazz-relationships';
}
