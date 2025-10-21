// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:dartdoc/src/model/model.dart';

class Operator extends Method {
  Operator(super.element, super.library, super.packageGraph);

  Operator.providedByExtension(
    super.element,
    super.enclosingContainer,
    super.library,
    super.packageGraph, {
    Element? originalMember,
  }) : super.providedByExtension(
            originalElement: originalMember as ExecutableElement?);

  Operator.inherited(
    super.element,
    super.enclosingContainer,
    super.library,
    super.packageGraph, {
    Element? originalMember,
  }) : super.inherited(originalElement: originalMember as ExecutableElement?);

  @override
  String get fullyQualifiedName =>
      '${library.name}.${enclosingElement.name}.${super.name}';

  @override
  bool get isOperator => true;

  @override
  String get name {
    // TODO(jcollins-g): New lookup code will no longer require this operator
    // prefix.  Delete it and use super implementation after old lookup code
    // is removed.
    return 'operator ${super.name}';
  }

  @override
  String get fileName => 'operator_${operatorNames[referenceName]}.html';

  @override
  String get referenceName => super.name;
}
