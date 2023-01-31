// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart' show ParameterMember;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class Parameter extends ModelElement with HasNoPage {
  @override
  final ParameterElement element;

  Parameter(this.element, Library library, PackageGraph packageGraph,
      {ParameterMember? originalMember})
      : super(library, packageGraph, originalMember);

  String? get defaultValue => hasDefaultValue ? element.defaultValueCode : null;

  @override
  ModelElement? get enclosingElement {
    final enclosingElement = element.enclosingElement;
    return enclosingElement == null
        ? null
        : modelBuilder.from(enclosingElement, library);
  }

  bool get hasDefaultValue {
    return element.defaultValueCode != null &&
        element.defaultValueCode!.isNotEmpty;
  }

  @override
  String? get href => null;

  @override
  String get htmlId {
    final enclosingElement = element.enclosingElement;
    if (enclosingElement != null) {
      var enclosingName = enclosingElement.name;
      if (enclosingElement is GenericFunctionTypeElement) {
        // TODO(jcollins-g): Drop when GenericFunctionTypeElement populates
        // name. Also, allowing null here is allowed as a workaround for
        // dart-lang/sdk#32005.
        for (Element e = enclosingElement;
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
  String get kind => 'parameter';

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
  ParameterMember? get originalMember =>
      super.originalMember as ParameterMember?;

  late final ElementType modelType =
      modelBuilder.typeFrom((originalMember ?? element).type, library);
}
