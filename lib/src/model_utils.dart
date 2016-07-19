// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source_io.dart';

import 'config.dart';

final Map<String, String> _fileContents = <String, String>{};

List<InterfaceType> getAllSupertypes(ClassElement c) => c.allSupertypes;

String getFileContentsFor(Element e) {
  var location = e.source.fullName;
  if (!_fileContents.containsKey(location)) {
    var contents = new File(location).readAsStringSync();
    _fileContents.putIfAbsent(location, () => contents);
  }
  return _fileContents[location];
}

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

bool isInExportedLibraries(
    List<LibraryElement> libraries, LibraryElement library) {
  return libraries
      .any((lib) => lib == library || lib.exportedLibraries.contains(library));
}

bool isPrivate(Element e) =>
    e.name.startsWith('_') ||
    (e is LibraryElement &&
        (e.identifier == 'dart:_internal' ||
            e.identifier == 'dart:nativewrappers'));

bool isPublic(Element e) {
  if (isPrivate(e)) return false;
  // check to see if element is part of the public api, that is it does not
  // have a '<nodoc>' or '@nodoc' in the documentation comment
  if (e is PropertyAccessorElement && e.isSynthetic) {
    var accessor = (e as PropertyAccessorElement);
    if (accessor.correspondingSetter != null &&
        !accessor.correspondingSetter.isSynthetic) {
      e = accessor.correspondingSetter;
    } else if (accessor.correspondingGetter != null &&
        !accessor.correspondingGetter.isSynthetic) {
      e = accessor.correspondingGetter;
    } else if (accessor.variable != null) {
      e = accessor.variable;
    }
  }

  var docComment = e.documentationComment;
  if (docComment != null &&
      (docComment.contains('<nodoc>') || docComment.contains('@nodoc')))
    return false;
  return true;
}

/// Strip leading dartdoc comments from the given source code.
String stripDartdocCommentsFromSource(String source) {
  String remainer = source.trimLeft();
  HtmlEscape sanitizer = const HtmlEscape();
  bool lineComments = remainer.startsWith('///') ||
      remainer.startsWith(sanitizer.convert('///'));
  bool blockComments = remainer.startsWith('/**') ||
      remainer.startsWith(sanitizer.convert('/**'));

  return source.split('\n').where((String line) {
    if (lineComments) {
      if (line.startsWith('///') || line.startsWith(sanitizer.convert('///'))) {
        return false;
      }
      lineComments = false;
      return true;
    } else if (blockComments) {
      if (line.contains('*/') || line.contains(sanitizer.convert('*/'))) {
        blockComments = false;
        return false;
      }
      if (line.startsWith('/**') || line.startsWith(sanitizer.convert('/**'))) {
        return false;
      }
      return false;
    }

    return true;
  }).join('\n');
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

/// Add links to crossdart.info to the given source fragment
String crossdartifySource(
    Map<String, Map<String, List<Map<String, dynamic>>>> json,
    String source,
    Element element,
    int start) {
  var sanitizer = const HtmlEscape();
  String newSource;
  if (json.isNotEmpty) {
    var node = element.computeNode();
    var file = element.source.fullName
        .replaceAll("${config.inputDir.path}${Platform.pathSeparator}", "");
    var filesData = json[file];
    if (filesData != null) {
      var data = filesData["references"]
          .where((r) => r["offset"] >= start && r["end"] <= node.end);
      if (data.isNotEmpty) {
        var previousStop = 0;
        var stringBuffer = new StringBuffer();
        for (var item in data) {
          stringBuffer.write(sanitizer
              .convert(source.substring(previousStop, item["offset"] - start)));
          stringBuffer
              .write("<a class='crossdart-link' href='${item["remotePath"]}'>");
          stringBuffer.write(sanitizer.convert(
              source.substring(item["offset"] - start, item["end"] - start)));
          stringBuffer.write("</a>");
          previousStop = item["end"] - start;
        }
        stringBuffer.write(
            sanitizer.convert(source.substring(previousStop, source.length)));

        newSource = stringBuffer.toString();
      }
    }
  }
  if (newSource == null) {
    newSource = sanitizer.convert(source);
  }
  return newSource;
}
