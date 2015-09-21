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
    List<LibraryElement> libraries, LibraryElement library) {
  return libraries
      .any((lib) => lib == library || lib.exportedLibraries.contains(library));
}

/// Strip the common indent from the given source fragment.
String stripIndentFromSource(String source) {
  String remainer = source.trimLeft();
  String indent = source.substring(0, source.length - remainer.length);
  return source.split('\n').map((line) {
    line = line.trimRight();
    return line.startsWith(indent) ? line.substring(indent.length) : line;
  }).join('\n');
}

/// Strip leading dartdoc comments from the given source code.
String stripDartdocCommentsFromSource(String source) {
  String remainer = source.trimLeft();
  bool lineComments = remainer.startsWith('///');
  bool blockComments = remainer.startsWith('/**');

  return source.split('\n').where((String line) {
    if (lineComments) {
      if (line.startsWith('///')) return false;
      lineComments = false;
      return true;
    } else if (blockComments) {
      if (line.contains('*/')) {
        blockComments = false;
        return false;
      }
      if (line.startsWith('/**')) return false;
      return false;
    }

    return true;
  }).join('\n');
}
