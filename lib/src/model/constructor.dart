// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';

class Constructor extends ModelElement
    with TypeParameters
    implements EnclosedElement {
  Constructor(
      ConstructorElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  @override
  CharacterLocation get characterLocation {
    if (element.isSynthetic) {
      // Make warnings for a synthetic constructor refer to somewhere reasonable
      // since a synthetic constructor has no definition independent of the
      // parent class.
      return enclosingElement.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  // TODO(jcollins-g): Revisit this when dart-lang/sdk#31517 is implemented.
  List<TypeParameter> get typeParameters =>
      (enclosingElement as Class).typeParameters;

  @override
  ModelElement get enclosingElement =>
      ModelElement.from(_constructor.enclosingElement, library, packageGraph);

  @override
  String get filePath =>
      '${enclosingElement.library.dirName}/${enclosingElement.name}/$fileName';

  String get fullKind {
    if (isConst) return 'const $kind';
    if (isFactory) return 'factory $kind';
    return kind;
  }

  @override
  String get fullyQualifiedName {
    if (isDefaultConstructor) return super.fullyQualifiedName;
    return '${library.name}.$name';
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}$filePath';
  }

  @override
  bool get isConst => _constructor.isConst;

  bool get isDefaultConstructor => name == enclosingElement.name;

  bool get isFactory => _constructor.isFactory;

  @override
  String get kind => 'constructor';

  @override
  DefinedElementType get modelType => super.modelType;

  String _name;

  @override
  String get name {
    if (_name == null) {
      var constructorName = element.name;
      if (constructorName.isEmpty) {
        _name = enclosingElement.name;
      } else {
        _name = '${enclosingElement.name}.$constructorName';
      }
    }
    return _name;
  }

  String _nameWithGenerics;

  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      var constructorName = element.name;
      if (constructorName.isEmpty) {
        _nameWithGenerics = '${enclosingElement.name}${genericParameters}';
      } else {
        _nameWithGenerics =
            '${enclosingElement.name}${genericParameters}.$constructorName';
      }
    }
    return _nameWithGenerics;
  }

  String get shortName {
    if (name.contains('.')) {
      return name.substring(_constructor.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

  ConstructorElement get _constructor => (element as ConstructorElement);
}
