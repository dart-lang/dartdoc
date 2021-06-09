// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show Member;
import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:dartdoc/src/model/model.dart';

class Operator extends Method {
  Operator(MethodElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  Operator.inherited(MethodElement element, Class enclosingClass,
      Library library, PackageGraph packageGraph, {Member originalMember})
      : super.inherited(element, enclosingClass, library, packageGraph,
            originalMember: originalMember);

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
}
