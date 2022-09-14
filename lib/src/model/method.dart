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
  bool _isInherited = false;
  Container? _enclosingContainer;
  @override
  List<TypeParameter> typeParameters = [];

  Method(MethodElement super.element, super.library, super.packageGraph) {
    _calcTypeParameters();
  }

  Method.inherited(MethodElement element, this._enclosingContainer,
      Library library, PackageGraph packageGraph,
      {ExecutableMember? originalMember})
      : super(element, library, packageGraph, originalMember) {
    _isInherited = true;
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
  Container get enclosingElement {
    _enclosingContainer ??=
        modelBuilder.from(element.enclosingElement3, library) as Container?;
    return _enclosingContainer!;
  }

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
    var parent = element.enclosingElement3 as InterfaceElement;
    for (var t in parent.allSupertypes) {
      Element? e = t.getMethod(element.name);
      if (e != null) {
        assert(
          e.enclosingElement3 is ClassElement,
          'Expected "${e.enclosingElement3?.name}" to be a ClassElement, but '
          'was ${e.enclosingElement3.runtimeType}',
        );
        return modelBuilder.fromElement(e) as Method?;
      }
    }
    return null;
  }

  @override
  MethodElement get element => super.element as MethodElement;

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
    if (_referenceChildren == null) {
      _referenceChildren = {};
      _referenceChildren!.addEntriesIfAbsent([
        ...typeParameters.explicitOnCollisionWith(this),
        ...allParameters.explicitOnCollisionWith(this),
        ...modelType.typeArguments.explicitOnCollisionWith(this),
        ...modelType.returnType.typeArguments.explicitOnCollisionWith(this),
      ]);
    }
    return _referenceChildren!;
  }
}
