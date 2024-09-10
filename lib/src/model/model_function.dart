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
      FunctionElement super.element, super.library, super.packageGraph);

  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  FunctionElement get element => super.element as FunctionElement;

  bool get isAsynchronous => element.isAsynchronous;
}

/// A [ModelElement] for a [FunctionTypedElement] that is part of an
/// explicit typedef.
class ModelFunctionTypedef extends ModelFunctionTyped {
  ModelFunctionTypedef(super.element, super.library, super.packageGraph);

  @override
  String get name => element.enclosingElement3!.name!;
}

class ModelFunctionTyped extends ModelElement with TypeParameters {
  @override
  final FunctionTypedElement element;

  @override
  late final List<TypeParameter> typeParameters = [
    for (var p in element.typeParameters)
      getModelFor(p, library) as TypeParameter,
  ];

  ModelFunctionTyped(this.element, super.library, super.packageGraph);

  @override
  Library get enclosingElement => library;

  @override
  String get filePath => '${canonicalLibrary?.dirName}/$fileName';

  @override
  String get aboveSidebarPath => canonicalLibraryOrThrow.sidebarPath;

  @override
  String? get belowSidebarPath => null;

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    return '${package.baseHref}$filePath';
  }

  @override
  Kind get kind => Kind.function;

  // Food for mustache. TODO(jcollins-g): what about enclosing elements?
  bool get isInherited => false;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    ...parameters.explicitOnCollisionWith(this),
    ...typeParameters.explicitOnCollisionWith(this),
  };

  @override
  Iterable<CommentReferable> get referenceParents => [library];

  late final Callable modelType = getTypeFor(element.type, library) as Callable;

  // For use in templates.
  bool get isProvidedByExtension => false;

  // For use in templates.
  Extension get enclosingExtension => throw UnsupportedError(
      'Top-level variables are not provided by extensions');
}
