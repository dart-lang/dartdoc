// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart'
    show ExecutableMember, Member;
import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:dartdoc/src/model/model.dart';

class Operator extends Method {
  Operator(super.element, super.library, super.packageGraph);

  Operator.inherited(super.element, Container super.enclosingContainer,
      super.library, super.packageGraph,
      {Member? originalMember})
      : super.inherited(originalMember: originalMember as ExecutableMember?);

  @override
  String get fileName {
    var actualName = super.name;
    if (operatorNames.containsKey(actualName)) {
      actualName = 'operator_${operatorNames[actualName]}';
    }
    return '$actualName.$fileType';
  }

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
  String get referenceName => super.name;
}
