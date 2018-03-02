// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'model.dart';

class ElementType extends Privacy {
  final DartType _type;
  final ModelElement element;
  String _linkedName;

  ElementType(this._type, this.element) {
    assert(element != null);
  }

  DartType get type => _type;

  Library get library => element.library;

  bool get isDynamic => _type.isDynamic;

  bool get isFunctionType => (_type is FunctionType);

  bool get isParameterizedType => (_type is ParameterizedType);

  bool get isParameterType => (_type is TypeParameterType);

  /// This type is a public type if the underlying, canonical element is public.
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    Class canonicalClass =
        element.packageGraph.findCanonicalModelElementFor(element.element) ??
            element;
    return canonicalClass.isPublic;
  }

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
          buf.write('<span class="signature">');
          buf.write('&lt;');
          buf.writeAll(typeArguments.map((t) => t.linkedName), ', ');
          buf.write('&gt;');
          buf.write('</span>');
        }
        // Hide parameters if there's a an explicit typedef behind this
        // element, but if there is no typedef, be explicit.
        if (element is ModelFunctionAnonymous) {
          buf.write('<span class="signature">');
          buf.write('(');
          buf.write(element.linkedParams());
          buf.write(')');
          buf.write('</span>');
        }
      }
      _linkedName = buf.toString();
    }
    return _linkedName;
  }

  String _nameWithGenerics;
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      StringBuffer buf = new StringBuffer();

      if (isParameterType) {
        buf.write(name);
      } else {
        buf.write(element.name);
      }

      // not TypeParameterType or Void or Union type
      if (isParameterizedType) {
        if (!typeArguments.every((t) => t.linkedName == 'dynamic') &&
            typeArguments.isNotEmpty) {
          buf.write('&lt;');
          buf.writeAll(typeArguments.map((t) => t.nameWithGenerics), ', ');
          buf.write('&gt;');
        }
      }
      _nameWithGenerics = buf.toString();
    }
    return _nameWithGenerics;
  }

  String get name => _type.name ?? _type.element.name;

  ModelElement get returnElement {
    Element e;
    if (_type is FunctionType)
      e = _returnTypeCore.element;
    else
      e = _type.element;
    if (e == null || e.library == null) {
      return null;
    }
    Library lib = new ModelElement.from(e.library, element.library);
    return (new ModelElement.from(e, lib));
  }

  List<ElementType> get typeArguments {
    var type = _type;
    if (type is FunctionType) {
      Iterable<DartType> typeArguments;
      if (element is! ModelFunctionAnonymous && type.typeFormals.isEmpty) {
        // TODO(jcollins-g): replace with if (FunctionType.isInstantiated) once
        // that's reliable and revealed through the interface.
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
    Library lib = element.packageGraph.findLibraryFor(rt.element);
    if (lib == null) {
      lib = new ModelElement.from(rt.element.library, element.library);
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
    if (f.element.library != null) {
      lib = new ModelElement.from(f.element.library, element.library);
    } else {
      // TODO(jcollins-g): Assigning libraries to dynamics doesn't make sense,
      // really, but is needed for .package.
      assert(f.element.kind == ElementKind.DYNAMIC);
      lib = element.library;
    }
    return new ElementType(f, new ModelElement.from(f.element, lib));
  }
}
