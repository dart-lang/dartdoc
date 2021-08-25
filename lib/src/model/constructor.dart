// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class Constructor extends ModelElement
    with TypeParameters, ContainerMember
    implements EnclosedElement {
  Constructor(
      ConstructorElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

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
  ConstructorElement get element => super.element;

  @override
  // TODO(jcollins-g): Revisit this when dart-lang/sdk#31517 is implemented.
  List<TypeParameter> get typeParameters =>
      (enclosingElement as Class).typeParameters;

  @override
  ModelElement get enclosingElement =>
      ModelElement.from(element.enclosingElement, library, packageGraph);

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
    if (isUnnamedConstructor) return super.fullyQualifiedName;
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
  bool get isConst => element.isConst;

  bool get isUnnamedConstructor =>
      name == enclosingElement.name || name == '${enclosingElement.name}.new';

  @Deprecated(
      // TODO(jcollins-g): This, in retrospect, seems like a bad idea.
      // We should disambiguate the two concepts (default and unnamed) and
      // allow both if useful.
      'Renamed to `isUnnamedConstructor`; this getter with the old name will '
      'be removed as early as Dartdoc 1.0.0')
  bool get isDefaultConstructor => isUnnamedConstructor;

  bool get isFactory => element.isFactory;

  @override
  String get kind => 'constructor';

  Callable _modelType;
  Callable get modelType =>
      _modelType ??= ElementType.from(element.type, library, packageGraph);

  String _name;

  @override
  String get name {
    if (_name == null) {
      // TODO(jcollins-g): After the old lookup code is retired, rationalize
      // [name] around the conventions used in referenceChildren and replace
      // code there and elsewhere with simple references to the name.
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
        _nameWithGenerics = '${enclosingElement.name}$genericParameters';
      } else {
        _nameWithGenerics =
            '${enclosingElement.name}$genericParameters.$constructorName';
      }
    }
    return _nameWithGenerics;
  }

  String get shortName {
    if (name.contains('.')) {
      return name.substring(element.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

  Map<String, CommentReferable> _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      _referenceChildren.addEntries(allParameters.map((param) {
        var paramElement = param.element;
        if (paramElement is FieldFormalParameterElement) {
          return ModelElement.fromElement(paramElement.field, packageGraph);
        }
        return param;
      }).generateEntries());
      _referenceChildren.addEntries(typeParameters.generateEntries());
    }
    return _referenceChildren;
  }

  @override
  String get referenceName =>
      isUnnamedConstructor ? enclosingElement.name : element.name;
}
