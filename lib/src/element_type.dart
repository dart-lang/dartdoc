// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.element_type;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'model.dart';

abstract class ElementType extends Privacy {
  final DartType _type;
  final PackageGraph packageGraph;
  final DefinedElementType returnedFrom;

  ElementType(this._type, this.packageGraph, this.returnedFrom);

  factory ElementType.from(DartType f, PackageGraph packageGraph, [ElementType returnedFrom]) {
    if (f.element == null || f.element.kind == ElementKind.DYNAMIC) {
      return new UndefinedElementType(f, packageGraph, returnedFrom);
    } else {
      bool isGenericTypeAlias = f.element.enclosingElement is GenericTypeAliasElement;
      // can happen if element is dynamic
      assert(f.element.library != null);
      if (f is FunctionType) {
        if (isGenericTypeAlias) {
          return new CallableGenericTypeAliasElementType(f, packageGraph, new ModelElement.fromElement(f.element, packageGraph), returnedFrom);
        } else {
          if ((f.name ?? f.element.name) == '') {
            return new CallableAnonymousElementType(f, packageGraph, new ModelElement.fromElement(f.element, packageGraph), returnedFrom);
          } else {
            return new CallableElementType(f, packageGraph, new ModelElement.fromElement(f.element, packageGraph), returnedFrom);
          }
        }
      } else if (isGenericTypeAlias) {
        return new GenericTypeAliasElementType(f, packageGraph, new ModelElement.fromElement(f.element, packageGraph), returnedFrom);
      }
      return new DefinedElementType(f, packageGraph, new ModelElement.fromElement(f.element, packageGraph), returnedFrom);
    }
  }

  bool get canHaveParameters => false;

  String createLinkedReturnTypeName() => linkedName;

  bool get isTypedef => false;

  String get linkedName;

  String get name => _type.name ?? _type.element.name;

  String get nameWithGenerics;

  List<Parameter> get parameters => [];

  List<ElementType> get typeArguments {
    return (_type as ParameterizedType)
        .typeArguments
        .map((f) => new ElementType.from(f, packageGraph))
        .toList();
  }
}

/// An [ElementType] that isn't pinned to an Element (or one that is, but whose
/// element is irrelevant).
class UndefinedElementType extends ElementType {
  UndefinedElementType(DartType f, PackageGraph packageGraph, ElementType returnedFrom) : super(f, packageGraph, returnedFrom);

  @override
  bool get isPublic => true;

  @override
  /// dynamic and void are not allowed to have parameterized types.
  String get linkedName {
    if (_type.isDynamic && returnedFrom != null && returnedFrom.element.isAsynchronous)
      return 'Future';
    return name;
  }

  @override
  String get nameWithGenerics => name;
}

/// An [ElementType] associated with an [Element].
/// TODO(jcollins-g): split this out into subclasses where appropriate.
class DefinedElementType extends ElementType {
  @visibleForTesting
  final ModelElement _element;
  String _linkedName;

  DefinedElementType(DartType type, PackageGraph packageGraph, this._element, ElementType returnedFrom) : super(type, packageGraph, returnedFrom) {}

  ModelElement get element {
    assert(_element != null);
    return _element;
  }

  bool get isParameterizedType => (_type is ParameterizedType);

  bool get isParameterType => (_type is TypeParameterType);

  /// This type is a public type if the underlying, canonical element is public.
  /// This avoids discarding the resolved type information as canonicalization
  /// would ordinarily do.
  @override
  bool get isPublic {
    Class canonicalClass =
        _element.packageGraph.findCanonicalModelElementFor(_element.element) ??
            _element;
    return canonicalClass?.isPublic;
  }

  @override
  bool get isTypedef => element is Typedef || element is ModelFunctionTypedef;

  @override
  String get linkedName {
    if (_linkedName == null) {
      StringBuffer buf = new StringBuffer();

      if (isParameterType || _element == null) {
        buf.write(name);
      } else {
        buf.write(_element.linkedName);
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
        if (_element is ModelFunctionAnonymous) {
          buf.write('<span class="signature">');
          buf.write('(');
          buf.write(_element.linkedParams());
          buf.write(')');
          buf.write('</span>');
        }
      }
      _linkedName = buf.toString();
    }
    return _linkedName;
  }

  String _nameWithGenerics;
  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      StringBuffer buf = new StringBuffer();

      if (isParameterType) {
        buf.write(name);
      } else {
        buf.write(_element.name);
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

  @override
  List<Parameter> get parameters => element.canHaveParameters ? element.parameters : [];

  @override
  String toString() => "$_type";

  DartType get type => _type;



  ModelElement get returnElement => element;
  ElementType get returnType => new ElementType.from(_type, packageGraph, this);

  @override
  String createLinkedReturnTypeName()  {
    return returnType.linkedName;
  }
}

abstract class CallableElementTypeMixin implements DefinedElementType {
  @override
  ModelElement get returnElement => returnType is DefinedElementType ? (returnType as DefinedElementType).element : null;
  @override
  ElementType get returnType => new ElementType.from((_type as FunctionType).returnType, packageGraph, this);

  @override
  FunctionType get type => _type;

  @override
  // TODO(jcollins-g): Rewrite this so it doesn't require type checking everywhere.
  List<DefinedElementType> get typeArguments {
    Iterable<DartType> typeArguments;
    if (type.typeFormals.isEmpty && element is! ModelFunctionAnonymous && returnedFrom?.element is! ModelFunctionAnonymous) {
      typeArguments = type.typeArguments;
    } else if (returnedFrom != null && returnedFrom.type.element is GenericFunctionTypeElement) {
      typeArguments = type.typeArguments;
    } else {
      typeArguments = type.typeFormals.map((f) => f.type);
    }

    return typeArguments.map((f) => new ElementType.from(f, packageGraph)).toList();
  }

}

class CallableElementType extends DefinedElementType with CallableElementTypeMixin {
  CallableElementType(FunctionType t, PackageGraph graph, ModelElement element, ElementType returnedFrom) : super(t, graph, element, returnedFrom);

  @override
  String createLinkedReturnTypeName() => returnType.linkedName;
}

class CallableAnonymousElementType extends CallableElementType {
  CallableAnonymousElementType(FunctionType t, PackageGraph graph, ModelElement element, ElementType returnedFrom) : super(t, graph, element, returnedFrom);
  @override
  String get name => 'Function';
}

class GenericTypeAliasElementType extends DefinedElementType {
  GenericTypeAliasElementType(DartType t, PackageGraph graph, ModelElement element, ElementType returnedFrom) : super(t, graph, element, returnedFrom) {
    assert(t.element.enclosingElement is TypeDefiningElement);
  }

  ElementType get declaredType => new ElementType.from((_type.element.enclosingElement as TypeDefiningElement).type, packageGraph);
}

class CallableGenericTypeAliasElementType extends GenericTypeAliasElementType with CallableElementTypeMixin {
  CallableGenericTypeAliasElementType(FunctionType t, PackageGraph graph, ModelElement element, ElementType returnedFrom) : super(t, graph, element, returnedFrom);

  @override
  ModelElement get returnElement => new ModelElement.fromElement(type.element.enclosingElement, packageGraph);

  @override
  ElementType get returnType => new ElementType.from(returnElement.modelType._type, packageGraph, this);
}