// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:meta/meta.dart';

/// Static extension on a given type, containing methods (including getters,
/// setters, operators).
class Extension extends Container {
  @override
  final ExtensionElement element;

  late final ElementType extendedType =
      getTypeFor(element.extendedType, library);

  Extension(this.element, super.library, super.packageGraph);

  /// Detect if this extension applies to every object.
  bool get alwaysApplies =>
      extendedType.instantiatedType is DynamicType ||
      extendedType.instantiatedType is VoidType ||
      extendedType.instantiatedType.isDartCoreObject;

  bool couldApplyTo<T extends InheritingContainer>(T c) =>
      _couldApplyTo(c.modelType);

  /// Whether this extension could apply to [type].
  bool _couldApplyTo(DefinedElementType type) {
    if (extendedType.instantiatedType is DynamicType ||
        extendedType.instantiatedType is VoidType) {
      return true;
    }
    var typeInstantiated = type.instantiatedType;
    var extendedInstantiated = extendedType.instantiatedType;
    if (typeInstantiated == extendedInstantiated) {
      return true;
    }
    if (typeInstantiated.documentableElement ==
            extendedInstantiated.documentableElement &&
        extendedType.isSubtypeOf(type)) {
      return true;
    }
    return extendedType.isBoundSupertypeTo(type);
  }

  @override
  Library get enclosingElement => library;

  @override
  Kind get kind => Kind.extension;

  @override
  late final List<Method> declaredMethods = element.methods
      .map((e) => getModelFor(e, library) as Method)
      .toList(growable: false);

  @override
  String get name => element.name == null ? '' : super.name;

  @override
  late final List<Field> declaredFields = element.fields.map((field) {
    ContainerAccessor? getter, setter;
    final fieldGetter = field.getter;
    if (fieldGetter != null) {
      getter = ContainerAccessor(fieldGetter, library, packageGraph);
    }
    final fieldSetter = field.setter;
    if (fieldSetter != null) {
      setter = ContainerAccessor(fieldSetter, library, packageGraph);
    }
    return getModelForPropertyInducingElement(field, library,
        getter: getter, setter: setter, enclosingContainer: this) as Field;
  }).toList(growable: false);

  @override
  late final List<TypeParameter> typeParameters = element.typeParameters
      .map((typeParameter) => getModelFor(
          typeParameter,
          getModelForElement(typeParameter.enclosingElement!.library!)
              as Library) as TypeParameter)
      .toList(growable: false);

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...typeParameters,
  ];

  @override
  String get sidebarPath => '${library.dirName}/$name-extension-sidebar.html';

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
  Iterable<MapEntry<String, CommentReferable>> get extraReferenceChildren =>
      const [];

  @override
  String get relationshipsClass => 'clazz-relationships';
}
