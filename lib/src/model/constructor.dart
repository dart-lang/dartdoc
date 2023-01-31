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
  @override
  final ConstructorElement element;

  Constructor(this.element, super.library, super.packageGraph);

  @override
  CharacterLocation? get characterLocation {
    if (element.isSynthetic) {
      // Make warnings for a synthetic constructor refer to somewhere reasonable
      // since a synthetic constructor has no definition independent of the
      // parent class.
      return enclosingElement.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  List<TypeParameter> get typeParameters =>
      (enclosingElement as Constructable).typeParameters;

  @override
  Container get enclosingElement =>
      modelBuilder.from(element.enclosingElement, library) as Container;

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
  bool get isConst => element.isConst;

  bool get isUnnamedConstructor => name == enclosingElement.name;

  bool get isDefaultConstructor =>
      isUnnamedConstructor || name == '${enclosingElement.name}.new';

  bool get isFactory => element.isFactory;

  @override
  String get kind => 'constructor';

  late final Callable modelType =
      modelBuilder.typeFrom(element.type, library) as Callable;

  @override
  late final String name = () {
    // TODO(jcollins-g): After the old lookup code is retired, rationalize
    // [name] around the conventions used in referenceChildren and replace
    // code there and elsewhere with simple references to the name.
    var constructorName = element.name;
    if (constructorName.isEmpty) {
      return enclosingElement.name;
    }
    return '${enclosingElement.name}.$constructorName';
  }();

  @override
  late final String nameWithGenerics = () {
    var constructorName = element.name;
    if (constructorName.isEmpty) {
      return '${enclosingElement.name}$genericParameters';
    }
    return '${enclosingElement.name}$genericParameters.$constructorName';
  }();

  String? get shortName {
    if (name.contains('.')) {
      return name.substring(element.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    // Find the element that [parameter] is _really_ referring to.
    Element? dereferenceParameter(ParameterElement? parameter) {
      if (parameter is FieldFormalParameterElement) {
        return parameter.field;
      } else if (parameter is SuperFormalParameterElement) {
        return dereferenceParameter(parameter.superConstructorParameter);
      } else {
        return parameter;
      }
    }

    var parameterElements = parameters.map((parameter) {
      var element = dereferenceParameter(parameter.element);
      return element == null ? parameter : modelBuilder.fromElement(element);
    });
    return {
      for (var element in parameterElements) element.referenceName: element,
      for (var tp in typeParameters) tp.referenceName: tp,
    };
  }();

  @override
  String get referenceName =>
      isUnnamedConstructor ? enclosingElement.name : element.name;
}
