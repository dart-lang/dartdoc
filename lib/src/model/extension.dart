// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

/// Static extension on a given type, containing methods (including getters,
/// setters, operators).
class Extension extends Container {
  @override
  final ExtensionElement element;

  late final ElementType extendedElement =
      getTypeFor(element.extendedType, library);

  Extension(this.element, super.library, super.packageGraph);

  /// Whether this extension applies to every static type.
  bool get alwaysApplies {
    var extendedType = extendedElement.type;
    if (extendedType is TypeParameterType) extendedType = extendedType.bound;
    return extendedType is DynamicType ||
        extendedType is VoidType ||
        extendedType.isDartCoreObject;
  }

  /// Whether this extension could apply to [container].
  ///
  /// This makes some assumptions in its calculations. For example, all
  /// [InheritingContainer]s represent [InterfaceElement]s, so no care is taken
  /// to consider function types or record types.
  bool couldApplyTo(InheritingContainer container) {
    var extendedType = extendedElement.type;
    if (extendedType is TypeParameterType) {
      extendedType = extendedType.bound;
    }
    if (extendedType is DynamicType || extendedType is VoidType) {
      return true;
    }
    var otherType = container.modelType.type;
    if (otherType is InterfaceType) {
      otherType = library.element.typeSystem.instantiateInterfaceToBounds(
        element: otherType.element,
        nullabilitySuffix: NullabilitySuffix.none,
      );

      for (var superType in [otherType, ...otherType.allSupertypes]) {
        var isSameBaseType = superType.element == extendedType.element;
        if (isSameBaseType &&
            library.element.typeSystem.isSubtypeOf(extendedType, superType)) {
          return true;
        }
      }
    }

    return false;
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
  String get sidebarPath =>
      '${canonicalLibraryOrThrow.dirName}/$name-extension-sidebar.html';

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    return _referenceChildren ??= {
      ...extendedElement.referenceChildren,
      // Override extendedType entries with local items.
      ...super.referenceChildren,
    };
  }

  @override
  @visibleForOverriding
  Map<String, CommentReferable> get extraReferenceChildren => const {};

  @override
  String get relationshipsClass => 'clazz-relationships';
}
