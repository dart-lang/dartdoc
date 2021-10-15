// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart' show ParameterMember;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(
      ParameterElement element, Library? library, PackageGraph packageGraph,
      {ParameterMember? originalMember})
      : super(element, library, packageGraph, originalMember);
  String? get defaultValue {
    if (!hasDefaultValue) return null;
    return element!.defaultValueCode;
  }

  @override
  ModelElement get enclosingElement =>
      modelBuilder.from(element!.enclosingElement!, library!);

  bool get hasDefaultValue {
    return element!.defaultValueCode != null &&
        element!.defaultValueCode!.isNotEmpty;
  }

  @override
  String get filePath {
    throw UnimplementedError('Parameters have no generated files in dartdoc');
  }

  @override
  String? get href => null;

  @override
  String get htmlId {
    if (element!.enclosingElement != null) {
      var enclosingName = element!.enclosingElement!.name;
      if (element!.enclosingElement is GenericFunctionTypeElement) {
        // TODO(jcollins-g): Drop when GenericFunctionTypeElement populates name.
        // Also, allowing null here is allowed as a workaround for
        // dart-lang/sdk#32005.
        for (var e = element!.enclosingElement!;
            e.enclosingElement != null;
            e = e.enclosingElement!) {
          enclosingName = e.name;
          if (enclosingName != null && enclosingName.isNotEmpty) break;
        }
      }
      return '$enclosingName-param-$name';
    } else {
      return 'param-$name';
    }
  }

  @override
  int get hashCode => element == null ? 0 : element.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Parameter && (element!.type == other.element!.type);

  bool get isCovariant => element!.isCovariant;

  bool get isRequiredPositional => element!.isRequiredPositional;

  bool get isNamed => element!.isNamed;

  bool get isOptionalPositional => element!.isOptionalPositional;

  /// Only true if this is a required named parameter.
  bool get isRequiredNamed => element!.isRequiredNamed;

  @override
  String get kind => 'parameter';

  Map<String, CommentReferable>? _referenceChildren;

  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      var _modelType = modelType;
      if (_modelType is Callable) {
        _referenceChildren!.addEntriesIfAbsent(
            _modelType.parameters.explicitOnCollisionWith(this));
      }
      _referenceChildren!.addEntriesIfAbsent(
          modelType.typeArguments.explicitOnCollisionWith(this));
      if (_modelType is Callable) {
        _referenceChildren!.addEntriesIfAbsent(
            _modelType.returnType.typeArguments.explicitOnCollisionWith(this));
      }
    }
    return _referenceChildren!;
  }

  @override
  Iterable<CommentReferable> get referenceParents => [enclosingElement];
  @override
  ParameterElement? get element => super.element as ParameterElement?;

  @override
  ParameterMember? get originalMember =>
      super.originalMember as ParameterMember?;

  ElementType? _modelType;
  ElementType get modelType => _modelType ??=
      modelBuilder.typeFrom((originalMember ?? element)!.type, library!);
}
