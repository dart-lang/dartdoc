// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library model_utils;

import 'package:analyzer/src/generated/constant.dart';
import 'package:analyzer/src/generated/element.dart';

Object getConstantValue(PropertyInducingElement element) {
  if (element is ConstFieldElementImpl) {
    ConstFieldElementImpl e = element;
    return _valueFor(e.evaluationResult);
  } else if (element is ConstTopLevelVariableElementImpl) {
    ConstTopLevelVariableElementImpl e = element;
    return _valueFor(e.evaluationResult);
  } else {
    return null;
  }
}

Object _valueFor(EvaluationResultImpl result) {
  if (result is ValidResult) {
    return result.value;
  } else {
    return null;
  }
}

int elementCompare(Element a, Element b) => a.name.compareTo(b.name);

bool isPrivate(Element e) => e.name.startsWith('_');

List<InterfaceType> getAllSupertypes(ClassElement c) {
  InterfaceType t = c.type;
  return c.allSupertypes;

  // TODO:

  //return _getAllSupertypes(t, []);
}
