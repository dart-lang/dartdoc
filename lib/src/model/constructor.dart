// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';

class Constructor extends ModelElement with ContainerMember, TypeParameters {
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
    final lineInfo = unitElement.lineInfo;
    var offset = element.firstFragment.nameOffset ??
        element.firstFragment.typeNameOffset;
    if (offset != null && offset >= 0) {
      return lineInfo.getLocation(offset);
    }
    return null;
  }

  @override
  bool get isPublic {
    if (!super.isPublic) return false;
    if (element.hasPrivateName) return false;
    var class_ = element.enclosingElement;
    // Enums cannot be explicitly constructed or extended.
    if (class_ is EnumElement) return false;
    if (class_ is ClassElement) {
      if (element.isFactory) return true;
      if (class_.isSealed ||
          (class_.isAbstract && class_.isFinal) ||
          (class_.isAbstract && class_.isInterface)) {
        /// Sealed classes, abstract final classes, and abstract interface
        /// classes, cannot be instantiated nor extended, from outside the
        /// declaring library. Avoid documenting them.
        return false;
      }
    }
    return true;
  }

  @override
  List<TypeParameter> get typeParameters =>
      (enclosingElement as Constructable).typeParameters;

  @override
  Container get enclosingElement =>
      getModelFor(element.enclosingElement, library) as Container;

  @override
  String get fileName =>
      // TODO(srawlins): It would be great to use `new.html` as the file name.
      isUnnamedConstructor ? '${enclosingElement.name}.html' : '$name.html';

  @override
  String get aboveSidebarPath => enclosingElement.sidebarPath;

  @override
  String? get belowSidebarPath => null;

  String get fullKind {
    if (isConst) return 'const $kind';
    if (isFactory) return 'factory $kind';
    return kind.toString();
  }

  @override
  String get fullyQualifiedName => '${library.name}.$name';

  @override
  bool get isConst => element.isConst;

  bool get isUnnamedConstructor => element.name == 'new';

  bool get isFactory => element.isFactory;

  @override
  Kind get kind => Kind.constructor;

  late final Callable modelType = getTypeFor(element.type, library) as Callable;

  @override
  String get name =>
      // TODO(jcollins-g): After the old lookup code is retired, rationalize
      // [name] around the conventions used in referenceChildren and replace
      // code there and elsewhere with simple references to the name.
      '${enclosingElement.name}.${element.name}';

  @override
  String get displayName => isUnnamedConstructor
      ? enclosingElement.name
      : '${enclosingElement.name}.${element.name}';

  @override
  String get nameWithGenerics {
    var constructorName = element.name!;
    if (constructorName == 'new') {
      return '${enclosingElement.name}$genericParameters';
    }
    return '${enclosingElement.name}$genericParameters.$constructorName';
  }

  String? get shortName {
    if (name.contains('.')) {
      return name.substring(element.enclosingElement.name!.length + 1);
    } else {
      return name;
    }
  }

  @override
  late final Map<String, CommentReferable> referenceChildren = () {
    // Find the element that [parameter] is _really_ referring to.
    Element? dereferenceParameter(FormalParameterElement? parameter) =>
        switch (parameter) {
          FieldFormalParameterElement() => parameter.field,
          SuperFormalParameterElement() =>
            dereferenceParameter(parameter.superConstructorParameter),
          _ => parameter
        };

    var parameterElements = parameters.map((parameter) {
      var e = dereferenceParameter(parameter.element);
      return e == null ? parameter : getModelForElement(e);
    });
    return {
      for (var e in parameterElements) e.referenceName: e,
      for (var tp in typeParameters) tp.referenceName: tp,
    };
  }();

  @override
  String get referenceName =>
      isUnnamedConstructor ? enclosingElement.name : element.name!;
}
