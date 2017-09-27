// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'model.dart';

class ElementType {
  final DartType _type;
  final ModelElement element;
  String _linkedName;

  ElementType(this._type, this.element);

  bool get isDynamic => _type.isDynamic;

  bool get isFunctionType => (_type is FunctionType);

  bool get isParameterizedType => (_type is ParameterizedType);

  bool get isParameterType => (_type is TypeParameterType);

  String get linkedName {
    if (_linkedName == null) {
      StringBuffer buf = new StringBuffer();

      if (isParameterType) {
        buf.write(name);
      } else {
        buf.write(element.linkedName);
      }

      // not TypeParameterType or Void or Union type
      if (isParameterizedType) {
        if (!typeArguments.every((t) => t.linkedName == 'dynamic') &&
            typeArguments.isNotEmpty) {
          buf.write('&lt;');
          buf.writeAll(typeArguments.map((t) => t.linkedName), ', ');
          buf.write('&gt;');
        }
        // Hide parameters if there's a an explicit typedef behind this
        // element, but if there is no typedef, be explicit.
        if (element is ModelFunctionAnonymous) {
          buf.write('(');
          buf.write(element.linkedParams());
          buf.write(')');
        }
      }
      _linkedName = buf.toString();
    }
    return _linkedName;
  }

  String get name => _type.name;

  ModelElement get returnElement {
    Element e;
    if (_type is FunctionType)
      e = _returnTypeCore.element;
    else
      e = _type.element;
    if (e == null || e.library == null) {
      return null;
    }
    Library lib = element.package.findLibraryFor(e);
    if (lib == null) {
      lib = new Library(e.library, element.package);
    }
    return (new ModelElement.from(e, lib));
  }

  List<ElementType> get typeArguments {
    var type = _type;
    if (type is FunctionType) {
      Iterable<DartType> typeArguments;
      if (type.element is FunctionTypeAliasElement &&
          type.typeFormals.isEmpty) {
        // TODO(jmesserly): simplify check above; we should have a way
        // to find instantiated typedefs without consulting the element.
        // Also, it will not work if we support typedefs declared inside classes.
        typeArguments = type.typeArguments;
      } else {
        typeArguments = type.typeFormals.map((f) => f.type);
      }
      return typeArguments.map(_getElementTypeFrom).toList();
    } else {
      return (_type as ParameterizedType)
          .typeArguments
          .map((f) => _getElementTypeFrom(f))
          .toList();
    }
  }

  ElementType get _returnType {
    var rt = _returnTypeCore;
    Library lib = element.package.findLibraryFor(rt.element);
    if (lib == null) {
      lib = new Library(rt.element.library, element.package);
    }
    return new ElementType(rt, new ModelElement.from(rt.element, lib));
  }

  DartType get _returnTypeCore => (_type as FunctionType).returnType;

  String get _returnTypeName => _returnTypeCore.name;

  String createLinkedReturnTypeName() {
    if (_returnTypeCore.element == null ||
        _returnTypeCore.element.library == null) {
      if (_returnTypeName != null) {
        if (_returnTypeName == 'dynamic' && element.isAsynchronous) {
          // TODO(keertip): for SDK docs it should be a link
          return 'Future';
        }
        return _returnTypeName;
      } else {
        return '';
      }
    } else {
      return _returnType.linkedName;
    }
  }

  @override
  String toString() => "$_type";

  ElementType _getElementTypeFrom(DartType f) {
    Library lib;
    // can happen if element is dynamic
    lib = element.package.findLibraryFor(f.element);
    if (lib == null && f.element.library != null) {
      lib = new Library(f.element.library, element.package);
    }
    return new ElementType(f, new ModelElement.from(f.element, lib));
  }
}
