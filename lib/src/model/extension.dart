// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/extension_target.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:quiver/iterables.dart' as quiver;

/// Extension methods
class Extension extends Container
    with TypeParameters, Categorization
    implements EnclosedElement {
  ElementType extendedType;

  Extension(
      ExtensionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph) {
    extendedType =
        ElementType.from(_extension.extendedType, library, packageGraph);
  }

  /// Detect if this extension applies to every object.
  bool get alwaysApplies =>
      extendedType.instantiatedType.isDynamic ||
      extendedType.instantiatedType.isVoid ||
      extendedType.instantiatedType.isObject;

  bool couldApplyTo<T extends ExtensionTarget>(T c) =>
      _couldApplyTo(c.modelType);

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

  @override
  ModelElement get enclosingElement => library;

  ExtensionElement get _extension => (element as ExtensionElement);

  @override
  String get kind => 'extension';

  List<Method> _methods;

  @override
  List<Method> get methods {
    _methods ??= _extension.methods.map((e) {
      return ModelElement.from(e, library, packageGraph) as Method;
    }).toList(growable: false)
      ..sort(byName);
    return _methods;
  }

  @override
  String get name => super.name ?? '';

  List<Field> _fields;

  @override
  List<Field> get allFields {
    _fields ??= _extension.fields.map((f) {
      Accessor getter, setter;
      if (f.getter != null) {
        getter = ContainerAccessor(f.getter, library, packageGraph);
      }
      if (f.setter != null) {
        setter = ContainerAccessor(f.setter, library, packageGraph);
      }
      return ModelElement.from(f, library, packageGraph,
          getter: getter, setter: setter) as Field;
    }).toList(growable: false)
      ..sort(byName);
    return _fields;
  }

  List<TypeParameter> _typeParameters;

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    _typeParameters ??= _extension.typeParameters.map((f) {
      var lib = Library(f.enclosingElement.library, packageGraph);
      return ModelElement.from(f, lib, packageGraph) as TypeParameter;
    }).toList();
    return _typeParameters;
  }

  @override
  ParameterizedElementType get modelType => super.modelType;

  List<ModelElement> _allModelElements;

  List<ModelElement> get allModelElements {
    _allModelElements ??= List.from(
        quiver.concat([
          instanceMethods,
          allInstanceFields,
          allAccessors,
          allOperators,
          constants,
          staticMethods,
          staticProperties,
          typeParameters,
        ]),
        growable: false);
    return _allModelElements;
  }

  @override
  String get filePath => '${library.dirName}/$fileName';

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }
}
