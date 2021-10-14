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
      ConstructorElement element, Library? library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  CharacterLocation? get characterLocation {
    if (element!.isSynthetic) {
      // Make warnings for a synthetic constructor refer to somewhere reasonable
      // since a synthetic constructor has no definition independent of the
      // parent class.
      return enclosingElement.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  ConstructorElement? get element => super.element as ConstructorElement?;

  @override
  // TODO(jcollins-g): Revisit this when dart-lang/sdk#31517 is implemented.
  List<TypeParameter> get typeParameters =>
      (enclosingElement as Class).typeParameters;

  @override
  ModelElement get enclosingElement =>
      modelBuilder.from(element!.enclosingElement, library!);

  @override
  String get filePath =>
      '${enclosingElement.library!.dirName}/${enclosingElement.name}/$fileName';

  String get fullKind {
    if (isConst) return 'const $kind';
    if (isFactory) return 'factory $kind';
    return kind;
  }

  @override
  String get fullyQualifiedName {
    if (isUnnamedConstructor) return super.fullyQualifiedName;
    return '${library!.name}.$name';
  }

  @override
  bool get isConst => element!.isConst;

  bool get isUnnamedConstructor => name == enclosingElement.name;

  bool get isDefaultConstructor =>
      name == '${enclosingElement.name}.new' || isUnnamedConstructor;

  bool get isFactory => element!.isFactory;

  @override
  String get kind => 'constructor';

  Callable? _modelType;
  Callable get modelType =>
      (_modelType ??= modelBuilder.typeFrom(element!.type, library!) as Callable?)!;

  @override
  late final String name = () {
    // TODO(jcollins-g): After the old lookup code is retired, rationalize
    // [name] around the conventions used in referenceChildren and replace
    // code there and elsewhere with simple references to the name.
    var constructorName = element!.name;
    if (constructorName.isEmpty) {
      return enclosingElement.name;
    }
    return '${enclosingElement.name}.$constructorName';
  } ();


  @override
  late final String nameWithGenerics = () {
      var constructorName = element!.name;
      if (constructorName.isEmpty) {
        return '${enclosingElement.name}$genericParameters';
      }
        return
            '${enclosingElement.name}$genericParameters.$constructorName';
  } ();

  String? get shortName {
    if (name.contains('.')) {
      return name.substring(element!.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      _referenceChildren!.addEntries(allParameters!.map((param) {
        var paramElement = param.element;
        if (paramElement is FieldFormalParameterElement) {
          return modelBuilder.fromElement(paramElement.field!);
        }
        return param;
      }).generateEntries());
      _referenceChildren!.addEntries(typeParameters.generateEntries());
    }
    return _referenceChildren!;
  }

  @override
  String get referenceName =>
      isUnnamedConstructor ? enclosingElement.name: element!.name;
}
