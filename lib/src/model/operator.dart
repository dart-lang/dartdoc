// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show Member;
import 'package:dartdoc/src/model/model.dart';

class Operator extends Method {
  static const Map<String, String> friendlyNames = {
    '[]': 'get',
    '[]=': 'put',
    '~': 'bitwise_negate',
    '==': 'equals',
    '-': 'minus',
    '+': 'plus',
    '*': 'multiply',
    '/': 'divide',
    '<': 'less',
    '>': 'greater',
    '>=': 'greater_equal',
    '<=': 'less_equal',
    '<<': 'shift_left',
    '>>': 'shift_right',
    '^': 'bitwise_exclusive_or',
    'unary-': 'unary_minus',
    '|': 'bitwise_or',
    '&': 'bitwise_and',
    '~/': 'truncate_divide',
    '%': 'modulo'
  };

  Operator(MethodElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  Operator.inherited(MethodElement element, Class enclosingClass,
      Library library, PackageGraph packageGraph, {Member originalMember})
      : super.inherited(element, enclosingClass, library, packageGraph,
            originalMember: originalMember);

  @override
  String get fileName {
    var actualName = super.name;
    if (friendlyNames.containsKey(actualName)) {
      actualName = 'operator_${friendlyNames[actualName]}';
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
    return 'operator ${super.name}';
  }
}
