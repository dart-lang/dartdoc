// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart' show ExecutableMember;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

class Method extends ModelElement
    with ContainerMember, Inheritable, TypeParameters {
  @override
  final MethodElement2 element;

  Container? _enclosingContainer;

  final bool _isInherited;

  @override
  late final List<TypeParameter> typeParameters;

  Method(this.element, super.library, super.packageGraph)
      : _isInherited = false {
    _calcTypeParameters();
  }

  Method.inherited(
      this.element, this._enclosingContainer, super.library, super.packageGraph,
      {ExecutableMember? super.originalMember})
      : _isInherited = true {
    _calcTypeParameters();
  }

  Method.providedByExtension(
    this.element,
    this._enclosingContainer,
    super.library,
    super.packageGraph, {
    ExecutableMember? super.originalMember,
  }) : _isInherited = false {
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = element.typeParameters2.map((f) {
      return getModelFor(f, library) as TypeParameter;
    }).toList(growable: false);
  }

  @override
  CharacterLocation? get characterLocation {
    if (enclosingElement is Enum && name == 'toString') {
      // The toString() method on Enums is special, treated as not having
      // a definition location by the analyzer yet not being inherited, either.
      // Just directly override our location with the Enum definition --
      // this is OK because Enums can not inherit from each other nor
      // have their definitions split between files.
      return enclosingElement.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  Container get enclosingElement => _enclosingContainer ??=
      getModelFor(element.enclosingElement2!, library) as Container;

  @override
  String get aboveSidebarPath => enclosingElement.sidebarPath;

  @override
  String? get belowSidebarPath => null;

  String get fullkind {
    // A method cannot be abstract and static at the same time.
    if (element.isAbstract) return 'abstract $kind';
    if (element.isStatic) return 'static $kind';
    return kind.toString();
  }

  @override
  String? get href {
    assert(!identical(canonicalModelElement, this) ||
        canonicalEnclosingContainer == enclosingElement);
    return super.href;
  }

  @override
  bool get isInherited => _isInherited;

  bool get isOperator => false;

  bool get isProvidedByExtension =>
      element.enclosingElement2 is ExtensionElement2;

  /// The [enclosingElement], which is expected to be an [Extension].
  Extension get enclosingExtension => enclosingElement as Extension;

  @override
  Set<Attribute> get attributes => {
        ...super.attributes,
        if (isInherited) Attribute.inherited,
      };

  bool get isStatic => element.isStatic;

  @override
  Kind get kind => Kind.method;

  @override
  ExecutableMember? get originalMember =>
      super.originalMember as ExecutableMember?;

  late final Callable modelType =
      getTypeFor((originalMember ?? element).type, library) as Callable;

  @override
  Method? get overriddenElement {
    if (_enclosingContainer is Extension ||
        element.enclosingElement2 is ExtensionElement2) {
      return null;
    }
    var parent = element.enclosingElement2 as InterfaceElement2;
    for (var t in parent.allSupertypes) {
      Element2? e = t.getMethod2(element.name3 ?? '');
      if (e != null) {
        assert(
          e.enclosingElement2 is InterfaceElement2,
          'Expected "${e.enclosingElement2?.name3}" to be a InterfaceElement, '
          'but was ${e.enclosingElement2.runtimeType}',
        );
        return getModelForElement(e) as Method?;
      }
    }
    return null;
  }

  /// Methods can not be covariant; always returns false.
  @override
  bool get isCovariant => false;

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    var from = documentationFrom.first as Method;
    if (!identical(this, from)) {
      return from.referenceChildren;
    }
    return _referenceChildren ??= <String, CommentReferable>{
      // If we want to include all types referred to in the signature of this
      // method, this is woefully incomplete. Notice we don't currently include
      // the element of the returned type itself, nor nested type arguments,
      // nor other nested types e.g. in the case of function types or record
      // types. But this is all being replaced with analyzer's resolution soon.
      ...modelType.returnType.typeArguments.modelElements
          .explicitOnCollisionWith(this),
      ...parameters.explicitOnCollisionWith(this),
      ...typeParameters.explicitOnCollisionWith(this),
    };
  }
}

extension on Iterable<ElementType> {
  /// The [ModelElement] associated with each type, for each type that is a
  /// [DefinedElementType].
  List<ModelElement> get modelElements => [
        for (var type in this)
          if (type is DefinedElementType) type.modelElement,
      ];
}
