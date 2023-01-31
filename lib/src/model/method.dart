// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart' show ExecutableMember;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/model.dart';

class Method extends ModelElement
    with ContainerMember, Inheritable, TypeParameters
    implements EnclosedElement {
  @override
  final MethodElement element;

  Container? _enclosingContainer;

  final bool _isInherited;

  @override
  late final List<TypeParameter> typeParameters;

  Method(this.element, super.library, super.packageGraph)
      : _isInherited = false {
    _calcTypeParameters();
  }

  Method.inherited(this.element, this._enclosingContainer, Library library,
      PackageGraph packageGraph,
      {ExecutableMember? originalMember})
      : _isInherited = true,
        super(library, packageGraph, originalMember) {
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = element.typeParameters.map((f) {
      return modelBuilder.from(f, library) as TypeParameter;
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
      modelBuilder.from(element.enclosingElement, library) as Container;

  @override
  String get filePath =>
      '${enclosingElement.library.dirName}/${enclosingElement.name}/$fileName';

  String get fullkind {
    // A method cannot be abstract and static at the same time.
    if (element.isAbstract) return 'abstract $kind';
    if (element.isStatic) return 'static $kind';
    return kind;
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

  @override
  Set<Feature> get features => {
        ...super.features,
        if (isInherited) Feature.inherited,
      };

  @override
  bool get isStatic => element.isStatic;

  @override
  String get kind => 'method';

  @override
  ExecutableMember? get originalMember =>
      super.originalMember as ExecutableMember?;

  late final Callable modelType = modelBuilder.typeFrom(
      (originalMember ?? element).type, library) as Callable;

  @override
  Method? get overriddenElement {
    if (_enclosingContainer is Extension) {
      return null;
    }
    var parent = element.enclosingElement as InterfaceElement;
    for (var t in parent.allSupertypes) {
      Element? e = t.getMethod(element.name);
      if (e != null) {
        assert(
          e.enclosingElement is InterfaceElement,
          'Expected "${e.enclosingElement?.name}" to be a InterfaceElement, '
          'but was ${e.enclosingElement.runtimeType}',
        );
        return modelBuilder.fromElement(e) as Method?;
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
      ...modelType.returnType.typeArguments.explicitOnCollisionWith(this),
      ...modelType.typeArguments.explicitOnCollisionWith(this),
      ...parameters.explicitOnCollisionWith(this),
      ...typeParameters.explicitOnCollisionWith(this),
    };
  }
}
