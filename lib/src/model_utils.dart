// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'package:analyzer/src/generated/constant.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source_io.dart';

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

bool isPublic(Element e) => !isPrivate(e);

List<LibraryElement> getSdkLibrariesToDocument(
    DartSdk sdk, AnalysisContext context) {
  List<LibraryElement> libraries = [];
  var sdkApiLibs = sdk.sdkLibraries
      .where((SdkLibrary sdkLib) => !sdkLib.isInternal && sdkLib.isDocumented)
      .toList();
  sdkApiLibs.sort((lib1, lib2) => lib1.shortName.compareTo(lib2.shortName));
  sdkApiLibs.forEach((SdkLibrary sdkLib) {
    Source source = sdk.mapDartUri(sdkLib.shortName);
    LibraryElement library = context.computeLibraryElement(source);
    libraries.add(library);
    libraries.addAll(library.exportedLibraries);
  });
  return libraries;
}

List<InterfaceType> getAllSupertypes(ClassElement c) {
  return c.allSupertypes;

  // TODO:

  //return _getAllSupertypes(t, []);
}
