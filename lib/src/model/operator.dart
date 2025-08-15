// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart'
    show SubstitutedExecutableElementImpl, SubstitutedElementImpl;
import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:dartdoc/src/model/model.dart';

class Operator extends Method {
  Operator(super.element, super.library, super.packageGraph);

  Operator.providedByExtension(
    super.element,
    super.enclosingContainer,
    super.library,
    super.packageGraph, {
        SubstitutedElementImpl? originalMember,
  }) : super.providedByExtension(
            originalMember: originalMember as SubstitutedExecutableElementImpl?);

  Operator.inherited(
    super.element,
    super.enclosingContainer,
    super.library,
    super.packageGraph, {
        SubstitutedElementImpl? originalMember,
  }) : super.inherited(originalMember: originalMember as SubstitutedExecutableElementImpl?);

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
