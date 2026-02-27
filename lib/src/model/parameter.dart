// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

class Parameter extends ModelElement with HasNoPage {
  @override
  final FormalParameterElement element;

  Parameter(this.element, super.library, super.packageGraph,
      {FormalParameterElement? super.originalElement});

  String? get defaultValue => hasDefaultValue ? element.defaultValueCode : null;

  @override
  ModelElement? get enclosingElement {
    final enclosingElement = element.enclosingElement;
    return enclosingElement == null
        ? null
        : getModelFor(enclosingElement, library);
  }

  bool get hasDefaultValue {
    return element.defaultValueCode != null &&
        element.defaultValueCode!.isNotEmpty;
  }

  @override
  String? get href => null;

  @override
  String? get documentedName {
    // TODO(rnystrom): Allow private named declaring parameters in primary
    // constructors here too.
    if (element case FieldFormalParameterElement(privateName: _?)) {
      return element.name;
    }

    return null;
  }

  @override
  String get htmlId {
    final enclosingElement = element.enclosingElement;
    if (enclosingElement == null) {
      return 'param-$name';
    }
    var enclosingName = enclosingElement.lookupName;
    if (enclosingName == 'new') {
      enclosingName = '';
    }
    if (enclosingElement is GenericFunctionTypeElement) {
      return 'param-$name';
    }
    if (enclosingName == null || enclosingName.isEmpty) {
      return 'param-$name';
    }
    return '$enclosingName-param-$name';
  }

  @override
  int get hashCode => element.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Parameter && (element.type == other.element.type);

  bool get isCovariant => element.isCovariant;

  bool get isRequiredPositional => element.isRequiredPositional;

  bool get isNamed => element.isNamed;

  bool get isOptionalPositional => element.isOptionalPositional;

  /// Only true if this is a required named parameter.
  bool get isRequiredNamed => element.isRequiredNamed;

  @override
  Kind get kind => Kind.parameter;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    if (modelType is Callable)
      ...(modelType as Callable)
          .returnType
          .typeArguments
          .explicitOnCollisionWith(this),
    ...modelType.typeArguments.explicitOnCollisionWith(this),
    if (modelType is Callable)
      ...(modelType as Callable).parameters.explicitOnCollisionWith(this),
  };

  @override
  Iterable<CommentReferable> get referenceParents {
    final enclosingElement = this.enclosingElement;
    return [if (enclosingElement != null) enclosingElement];
  }

  @override
  FormalParameterElement? get originalMember =>
      super.originalMember as FormalParameterElement?;

  late final ElementType modelType =
      getTypeFor((originalMember ?? element).type, library);
}
