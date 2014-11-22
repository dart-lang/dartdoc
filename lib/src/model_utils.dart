// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library model_utils;

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/constant.dart';

String getDocumentationFor(Element e) {
  if (e == null) {
    return null;
  }

  String comments = e.computeDocumentationComment();

  if (comments != null) {
    return comments;
  }

  if (canOverride(e)) {
    return getDocumentationFor(getOverriddenElement(e));
  } else {
    return null;
  }
}

String getFileNameFor(LibraryElement library) {
  return '${library.name}.html';
}

Element getOverriddenElement(Element element) {
  if (element is MethodElement) {
    return getOverriddenElementMethod(element);
  } else {
    // TODO: ctors, fields, accessors -

    return null;
  }
}

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

MethodElement getOverriddenElementMethod(MethodElement element) {
  ClassElement parent = element.enclosingElement;
  for (InterfaceType t in getAllSupertypes(parent)) {
    if (t.getMethod(element.name) != null) {
      return t.getMethod(element.name);
    }
  }
  return null;
}

bool canOverride(Element e) => e is ClassMemberElement;

ClassElement getEnclosingElement(Element e) {
  if (e is ClassMemberElement) {
    return e.enclosingElement;
  } else {
    return null;
  }
}

List<InterfaceType> getAllSupertypes(ClassElement c) {
  InterfaceType t = c.type;
  return c.allSupertypes;

  // TODO:

  //return _getAllSupertypes(t, []);
}

