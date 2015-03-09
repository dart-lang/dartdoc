// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source_io.dart';

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
}

String replaceAllLinks(String str, {var findMatchingLink}) {
  var matchChars = ['[', ']'];
  int lastWritten = 0;
  int index = str.indexOf(matchChars[0]);
  StringBuffer buf = new StringBuffer();

  while (index != -1) {
    int end = str.indexOf(matchChars[1], index + 1);
    if (end != -1) {
      if (index - lastWritten > 0) {
        buf.write(str.substring(lastWritten, index));
      }
      String codeRef = str.substring(index + matchChars[0].length, end);
      if (codeRef != null) {
        var link = findMatchingLink(codeRef);
        if (link != null) {
          buf.write('<a href=$link> $codeRef</a>');
        } else {
          buf.write(codeRef);
        }
      }
      lastWritten = end + matchChars[1].length;
    } else {
      break;
    }
    index = str.indexOf(matchChars[0], end + 1);
  }
  if (lastWritten < str.length) {
    buf.write(str.substring(lastWritten, str.length));
  }
  return buf.toString();
}
