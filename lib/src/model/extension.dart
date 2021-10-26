// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/quiver.dart' as quiver;

/// Extension methods
class Extension extends Container implements EnclosedElement {
  late final ElementType extendedType =
      modelBuilder.typeFrom(element.extendedType, library);

  Extension(
      ExtensionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  /// Detect if this extension applies to every object.
  bool get alwaysApplies =>
      extendedType.instantiatedType.isDynamic ||
      extendedType.instantiatedType.isVoid ||
      extendedType.instantiatedType.isDartCoreObject;

  bool couldApplyTo<T extends ExtensionTarget>(T c) =>
      _couldApplyTo(c.modelType as DefinedElementType);

  /// Return true if this extension could apply to [t].
  bool _couldApplyTo(DefinedElementType t) {
    if (extendedType.instantiatedType.isDynamic ||
        extendedType.instantiatedType.isVoid) {
      return true;
    }
    return t.instantiatedType == extendedType.instantiatedType ||
        (t.instantiatedType.element == extendedType.instantiatedType.element &&
            extendedType.isSubtypeOf(t)) ||
        extendedType.isBoundSupertypeTo(t);
  }

  /// Returns the library that encloses this element.
  @override
  ModelElement? get enclosingElement => library;

  @override
  String get kind => 'extension';

  List<Method>? _methods;

  @override
  List<Method>? get declaredMethods {
    _methods ??= element.methods.map((e) {
      return modelBuilder.from(e, library) as Method;
    }).toList(growable: false);
    return _methods;
  }

  @override
  ExtensionElement get element => super.element as ExtensionElement;

  @override
  String get name => element.name == null ? '' : super.name;

  List<Field>? _declaredFields;

  @override
  List<Field>? get declaredFields {
    _declaredFields ??= element.fields.map((f) {
      Accessor? getter, setter;
      if (f.getter != null) {
        getter = ContainerAccessor(f.getter, library, packageGraph);
      }
      if (f.setter != null) {
        setter = ContainerAccessor(f.setter, library, packageGraph);
      }
      return modelBuilder.fromPropertyInducingElement(f, library,
          getter: getter, setter: setter) as Field;
    }).toList(growable: false);
    return _declaredFields;
  }

  List<TypeParameter>? _typeParameters;

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    _typeParameters ??= element.typeParameters.map((f) {
      var lib = modelBuilder.fromElement(f.enclosingElement!.library!);
      return modelBuilder.from(f, lib as Library) as TypeParameter;
    }).toList();
    return _typeParameters!;
  }

  List<ModelElement>? _allModelElements;
  @override
  List<ModelElement>? get allModelElements {
    _allModelElements ??= List.from(
        quiver.concat<ModelElement>([
          super.allModelElements!,
          typeParameters,
        ]),
        growable: false);
    return _allModelElements;
  }

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
}
