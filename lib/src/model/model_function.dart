// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

/// A [ModelElement] for a [FunctionElement] that isn't part of a type definition.
class ModelFunction extends ModelFunctionTyped with Categorization {
  ModelFunction(
      FunctionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name ?? '';

  @override
  FunctionElement get element => super.element;
}

/// A [ModelElement] for a [FunctionTypedElement] that is part of an
/// explicit typedef.
class ModelFunctionTypedef extends ModelFunctionTyped {
  ModelFunctionTypedef(
      FunctionTypedElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  String get name => element.enclosingElement.name;
}

class ModelFunctionTyped extends ModelElement
    with TypeParameters
    implements EnclosedElement {
  List<TypeParameter> _typeParameters;
  @override
  List<TypeParameter> get typeParameters => _typeParameters ??= <TypeParameter>[
        for (var p in element.typeParameters) modelBuilder.from(p, library),
      ];

  ModelFunctionTyped(
      FunctionTypedElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  ModelElement get enclosingElement => library;

  @override
  String get filePath => '${library.dirName}/$fileName';

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
  String get kind => 'function';

  // Food for mustache. TODO(jcollins-g): what about enclosing elements?
  bool get isInherited => false;

  Map<String, CommentReferable> _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      _referenceChildren
          .addEntriesIfAbsent(typeParameters.explicitOnCollisionWith(this));
      _referenceChildren
          .addEntriesIfAbsent(parameters.explicitOnCollisionWith(this));
    }
    return _referenceChildren;
  }

  @override
  Iterable<CommentReferable> get referenceParents => [definingLibrary];

  @override
  FunctionTypedElement get element => super.element;

  Callable _modelType;
  Callable get modelType =>
      _modelType ??= modelBuilder.typeFrom(element.type, library);
}
