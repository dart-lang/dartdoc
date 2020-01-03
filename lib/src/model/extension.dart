// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
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

  bool couldApplyTo<T extends ExtensionTarget>(T c) =>
      _couldApplyTo(c.modelType);

  /// Return true if this extension could apply to [t].
  bool _couldApplyTo(DefinedElementType t) {
    if (extendedType is UndefinedElementType) {
      assert(extendedType.type.isDynamic || extendedType.type.isVoid);
      return true;
    }
    {
      DefinedElementType extendedType = this.extendedType;
      return t.instantiatedType == extendedType.instantiatedType ||
          (t.instantiatedType.element ==
                  extendedType.instantiatedType.element &&
              extendedType.isSubtypeOf(t)) ||
          extendedType.isBoundSupertypeTo(t);
    }
  }

  @override
  ModelElement get enclosingElement => library;

  ExtensionElement get _extension => (element as ExtensionElement);

  @override
  String get kind => 'extension';

  List<Method> _methods;

  @override
  List<Method> get methods {
    if (_methods == null) {
      _methods = _extension.methods.map((e) {
        return ModelElement.from(e, library, packageGraph) as Method;
      }).toList(growable: false)
        ..sort(byName);
    }
    return _methods;
  }

  List<Field> _fields;

  @override
  List<Field> get allFields {
    if (_fields == null) {
      _fields = _extension.fields.map((f) {
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
    }
    return _fields;
  }

  List<TypeParameter> _typeParameters;

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    if (_typeParameters == null) {
      _typeParameters = _extension.typeParameters.map((f) {
        var lib = Library(f.enclosingElement.library, packageGraph);
        return ModelElement.from(f, lib, packageGraph) as TypeParameter;
      }).toList();
    }
    return _typeParameters;
  }

  @override
  ParameterizedElementType get modelType => super.modelType;

  List<ModelElement> _allModelElements;

  List<ModelElement> get allModelElements {
    if (_allModelElements == null) {
      _allModelElements = List.from(
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
    }
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
/*
/// Extension methods
class ExtensionOnUndefined extends Container
    with TypeParameters, Categorization
    implements EnclosedElement {
  UndefinedElementType extendedType;

  ExtensionOnUndefined(
      ExtensionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph) {
    extendedType =
        ElementType.from(_extension.extendedType, library, packageGraph);
  }

  /// Return true if this extension could apply to [t].
  bool _couldApplyTo(DefinedElementType t) {
    assert(extendedType.type.isDynamic || extendedType.type.isVoid);
    return true;
  }

  /// The instantiated to bounds [extendedType] of this extension is a subtype of
  /// [t].
  bool isSubtypeOf(DefinedElementType t) => throw UnimplementedError;
  bool isBoundSupertypeTo(DefinedElementType t) => throw UnimplementedError;
  bool _isBoundSupertypeTo(DartType superType, HashSet<DartType> visited) => throw UnimplementedError;



  bool couldApplyTo<T extends ExtensionTarget>(T c) =>
      _couldApplyTo(c.modelType);


  @override
  ModelElement get enclosingElement => library;

  ExtensionElement get _extension => (element as ExtensionElement);

  @override
  String get kind => 'extension';

  List<Method> _methods;

  @override
  List<Method> get methods {
    if (_methods == null) {
      _methods = _extension.methods.map((e) {
        return ModelElement.from(e, library, packageGraph) as Method;
      }).toList(growable: false)
        ..sort(byName);
    }
    return _methods;
  }

  List<Field> _fields;

  @override
  List<Field> get allFields {
    if (_fields == null) {
      _fields = _extension.fields.map((f) {
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
    }
    return _fields;
  }

  List<TypeParameter> _typeParameters;

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    if (_typeParameters == null) {
      _typeParameters = _extension.typeParameters.map((f) {
        var lib = Library(f.enclosingElement.library, packageGraph);
        return ModelElement.from(f, lib, packageGraph) as TypeParameter;
      }).toList();
    }
    return _typeParameters;
  }

  @override
  ParameterizedElementType get modelType => super.modelType;

  List<ModelElement> _allModelElements;

  List<ModelElement> get allModelElements {
    if (_allModelElements == null) {
      _allModelElements = List.from(
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
    }
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
 */
