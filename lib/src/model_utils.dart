// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source_io.dart';

const _leftChar = '[';
const _rightChar = ']';

bool isPrivate(Element e) => e.name.startsWith('_');

bool isPublic(Element e) => !isPrivate(e);

Iterable<LibraryElement> getSdkLibrariesToDocument(
    DartSdk sdk, AnalysisContext context) sync* {
  var sdkApiLibs = sdk.sdkLibraries
      .where((SdkLibrary sdkLib) => !sdkLib.isInternal && sdkLib.isDocumented)
      .toList();
  sdkApiLibs.sort((lib1, lib2) => lib1.shortName.compareTo(lib2.shortName));

  for (var sdkLib in sdkApiLibs) {
    Source source = sdk.mapDartUri(sdkLib.shortName);
    LibraryElement library = context.computeLibraryElement(source);
    yield library;
    yield* library.exportedLibraries;
  }
}

List<InterfaceType> getAllSupertypes(ClassElement c) => c.allSupertypes;

bool isInExportedLibraries(
    List<LibraryElement> libraries, LibraryElement library) => libraries
    .any((lib) => lib == library || lib.exportedLibraries.contains(library));

String replaceAllLinks(
    String str, String findMatchingLink(String input, [bool isContructor])) {
  int lastWritten = 0;
  int index = str.indexOf(_leftChar);
  StringBuffer buf = new StringBuffer();

  while (index != -1) {
    int end = str.indexOf(_rightChar, index + 1);
    if (end != -1) {
      if (index - lastWritten > 0) {
        buf.write(str.substring(lastWritten, index));
      }
      String codeRef = str.substring(index + _leftChar.length, end);
      if (codeRef != null) {
        var link;
        // support for [new Constructor]
        var refs = codeRef.split(' ');
        if (refs.length == 2 && refs.first == 'new') {
          link = findMatchingLink(refs[1], true);
        } else {
          link = findMatchingLink(codeRef);
        }
        if (link != null) {
          buf.write('<a href="$link">$codeRef</a>');
        } else {
          buf.write(codeRef);
        }
      }
      lastWritten = end + _rightChar.length;
    } else {
      break;
    }
    index = str.indexOf(_leftChar, end + 1);
  }
  if (lastWritten < str.length) {
    buf.write(str.substring(lastWritten, str.length));
  }
  return buf.toString();
}
