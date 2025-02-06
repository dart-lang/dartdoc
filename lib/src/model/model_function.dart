// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element2.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';

/// A [ModelElement] for a [TopLevelFunctionElement] that isn't part of a type definition.
class ModelFunction extends ModelFunctionTyped with Categorization {
  ModelFunction(
      TopLevelFunctionElement super.element2, super.library, super.packageGraph);

  bool get isStatic => element2.isStatic;

  @override
  String get name => element2.name3 ?? '';

  @override
  TopLevelFunctionElement get element2 => super.element2 as TopLevelFunctionElement;

  bool get isAsynchronous => element2.firstFragment.isAsynchronous;
}

/// A [ModelElement] for a [FunctionTypedElement2] that is part of an
/// explicit typedef.
class ModelFunctionTypedef extends ModelFunctionTyped {
  ModelFunctionTypedef(super.element2, super.library, super.packageGraph);

  @override
  String get name => element2.enclosingElement2!.name3!;
}

class ModelFunctionTyped extends ModelElement with TypeParameters {

  @override
  final FunctionTypedElement2 element2;

  @override
  late final List<TypeParameter> typeParameters = [
    for (var p in element2.typeParameters2)
      getModelFor2(p, library) as TypeParameter,
  ];

  ModelFunctionTyped(this.element2, super.library, super.packageGraph);

  @override
  Library get enclosingElement => library;

  @override
  // Prevent a collision with the library file.
  String get fileName => name == 'index' ? '$name-function.html' : '$name.html';

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

  late final Callable modelType = getTypeFor(element2.type, library) as Callable;

  // For use in templates.
  bool get isProvidedByExtension => false;

  // For use in templates.
  Extension get enclosingExtension => throw UnsupportedError(
      'Top-level variables are not provided by extensions');
}
