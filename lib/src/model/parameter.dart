// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show Member;
import 'package:dartdoc/src/model/model.dart';

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(
      ParameterElement element, Library library, PackageGraph packageGraph,
      {Member originalMember})
      : super(element, library, packageGraph, originalMember);

  String get defaultValue {
    if (!hasDefaultValue) return null;
    return _parameter.defaultValueCode;
  }

  @override
  ModelElement get enclosingElement => (_parameter.enclosingElement != null)
      ? ModelElement.from(_parameter.enclosingElement, library, packageGraph)
      : null;

  bool get hasDefaultValue {
    return _parameter.defaultValueCode != null &&
        _parameter.defaultValueCode.isNotEmpty;
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
    if (_parameter.enclosingElement != null) {
      var enclosingName = _parameter.enclosingElement.name;
      if (_parameter.enclosingElement is GenericFunctionTypeElement) {
        // TODO(jcollins-g): Drop when GenericFunctionTypeElement populates name.
        // Also, allowing null here is allowed as a workaround for
        // dart-lang/sdk#32005.
        for (var e = _parameter.enclosingElement;
            e.enclosingElement != null;
            e = e.enclosingElement) {
          enclosingName = e.name;
          if (enclosingName != null && enclosingName.isNotEmpty) break;
        }
      }
      return '${enclosingName}-param-${name}';
    } else {
      return 'param-${name}';
    }
  }

  @override
  int get hashCode => element == null ? 0 : element.hashCode;

  @override
  bool operator ==(Object object) =>
      object is Parameter && (_parameter.type == object._parameter.type);

  bool get isCovariant => _parameter.isCovariant;

  bool get isRequiredPositional => _parameter.isRequiredPositional;

  bool get isNamed => _parameter.isNamed;

  bool get isOptionalPositional => _parameter.isOptionalPositional;

  /// Only true if this is a required named parameter.
  bool get isRequiredNamed => _parameter.isRequiredNamed;

  @override
  String get kind => 'parameter';

  ParameterElement get _parameter => element as ParameterElement;
}
