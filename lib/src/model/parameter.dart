// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show ParameterMember;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(
      ParameterElement element, Library library, PackageGraph packageGraph,
      {ParameterMember originalMember})
      : super(element, library, packageGraph, originalMember);

  String get defaultValue {
    if (!hasDefaultValue) return null;
    return element.defaultValueCode;
  }

  @override
  ModelElement get enclosingElement => (element.enclosingElement != null)
      ? ModelElement.from(element.enclosingElement, library, packageGraph)
      : null;

  bool get hasDefaultValue {
    return element.defaultValueCode != null &&
        element.defaultValueCode.isNotEmpty;
  }

  @override
  String get filePath {
    throw StateError('filePath not implemented for parameters');
  }

  @override
  String get href {
    throw StateError('href not implemented for parameters');
  }

  @override
  String get htmlId {
    if (element.enclosingElement != null) {
      var enclosingName = element.enclosingElement.name;
      if (element.enclosingElement is GenericFunctionTypeElement) {
        // TODO(jcollins-g): Drop when GenericFunctionTypeElement populates name.
        // Also, allowing null here is allowed as a workaround for
        // dart-lang/sdk#32005.
        for (var e = element.enclosingElement;
            e.enclosingElement != null;
            e = e.enclosingElement) {
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
  bool operator ==(Object object) =>
      object is Parameter && (element.type == object.element.type);

  bool get isCovariant => element.isCovariant;

  bool get isRequiredPositional => element.isRequiredPositional;

  bool get isNamed => element.isNamed;

  bool get isOptionalPositional => element.isOptionalPositional;

  /// Only true if this is a required named parameter.
  bool get isRequiredNamed => element.isRequiredNamed;

  @override
  String get kind => 'parameter';

  @override
  ParameterElement get element => super.element;

  @override
  ParameterMember get originalMember => super.originalMember;

  ElementType _modelType;
  ElementType get modelType => _modelType ??=
      ElementType.from((originalMember ?? element).type, library, packageGraph);
}
