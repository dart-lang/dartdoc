// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/ast/utilities.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:path/path.dart' as path;
import 'package:glob/glob.dart';

final _driveLetterMatcher = RegExp(r'^\w:\\');

final Map<String, String> _fileContents = <String, String>{};

/// This will handle matching globs, including on Windows.
///
/// On windows, globs are assumed to use absolute Windows paths with drive
/// letters in combination with globs, e.g. `C:\foo\bar\*.txt`.  `fullName`
/// also is assumed to have a drive letter.
bool matchGlobs(List<String> globs, String fullName, {bool isWindows}) {
  isWindows ??= Platform.isWindows;
  var filteredGlobs = <String>[];

  if (isWindows) {
    // TODO(jcollins-g): port this special casing to the glob package.
    var fullNameDriveLetter = _driveLetterMatcher.stringMatch(fullName);
    if (fullNameDriveLetter == null) {
      throw DartdocFailure(
          'Unable to recognize drive letter on Windows in:  $fullName');
    }
    // Build a matcher from the [fullName]'s drive letter to filter the globs.
    var driveGlob = RegExp(fullNameDriveLetter.replaceFirst(r'\', r'\\'),
        caseSensitive: false);
    fullName = fullName.replaceFirst(_driveLetterMatcher, r'\');
    for (var glob in globs) {
      // Globs don't match if they aren't for the same drive.
      if (!driveGlob.hasMatch(glob)) continue;
      // `C:\` => `\` for rejoining via posix.
      glob = glob.replaceFirst(_driveLetterMatcher, r'/');
      filteredGlobs.add(path.posix.joinAll(path.windows.split(glob)));
    }
  } else {
    filteredGlobs.addAll(globs);
  }

  return filteredGlobs.any((g) =>
      Glob(g, context: isWindows ? path.windows : path.posix)
          .matches(fullName));
}

/// Returns the [AstNode] for a given [Element].
///
/// Uses a precomputed map of [element.source.fullName] to [CompilationUnit]
/// to avoid linear traversal in [ResolvedLibraryElementImpl.getElementDeclaration].
AstNode getAstNode(
    Element element, Map<String, CompilationUnit> compilationUnitMap) {
  if (element?.source?.fullName != null &&
      !element.isSynthetic &&
      element.nameOffset != -1) {
    var unit = compilationUnitMap[element.source.fullName];
    if (unit != null) {
      var locator = NodeLocator2(element.nameOffset);
      return (locator.searchWithin(unit)?.parent);
    }
  }
  return null;
}

Iterable<T> filterHasCanonical<T extends ModelElement>(
    Iterable<T> maybeHasCanonicalItems) {
  return maybeHasCanonicalItems.where((me) => me.canonicalModelElement != null);
}

/// Remove elements that aren't documented.
Iterable<T> filterNonDocumented<T extends Documentable>(
    Iterable<T> maybeDocumentedItems) {
  return maybeDocumentedItems.where((me) => me.isDocumented);
}

/// Returns an iterable containing only public elements from [privacyItems].
Iterable<T> filterNonPublic<T extends Privacy>(Iterable<T> privacyItems) {
  return privacyItems.where((me) => me.isPublic);
}

/// Finds canonical classes for all classes in the iterable, if possible.
/// If a canonical class can not be found, returns the original class.
Iterable<Class> findCanonicalFor(Iterable<Class> classes) {
  return classes.map((c) =>
      c.packageGraph.findCanonicalModelElementFor(c.element) as Class ?? c);
}

String getFileContentsFor(Element e, ResourceProvider resourceProvider) {
  var location = e.source.fullName;
  if (!_fileContents.containsKey(location)) {
    var contents = resourceProvider.getFile(location).readAsStringSync();
    _fileContents.putIfAbsent(location, () => contents);
  }
  return _fileContents[location];
}

final RegExp slashes = RegExp('[\/]');
bool hasPrivateName(Element e) {
  if (e.name == null) return false;

  if (e.name.startsWith('_')) {
    return true;
  }
  // GenericFunctionTypeElements have the name we care about in the enclosing
  // element.
  if (e is GenericFunctionTypeElement) {
    if (e.enclosingElement.name.startsWith('_')) {
      return true;
    }
  }
  if (e is LibraryElement &&
      (e.identifier.startsWith('dart:_') ||
          e.identifier.startsWith('dart:nativewrappers/') ||
          ['dart:nativewrappers'].contains(e.identifier))) {
    return true;
  }
  if (e is LibraryElement) {
    var locationParts = e.location.components[0].split(slashes);
    // TODO(jcollins-g): Implement real cross package detection
    if (locationParts.length >= 2 &&
        locationParts[0].startsWith('package:') &&
        locationParts[1] == 'src') return true;
  }
  return false;
}

bool hasPublicName(Element e) => !hasPrivateName(e);

/// Strip leading dartdoc comments from the given source code.
String stripDartdocCommentsFromSource(String source) {
  var remainer = source.trimLeft();
  var sanitizer = const HtmlEscape();
  var lineComments = remainer.startsWith('///') ||
      remainer.startsWith(sanitizer.convert('///'));
  var blockComments = remainer.startsWith('/**') ||
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
  var remainer = source.trimLeft();
  var indent = source.substring(0, source.length - remainer.length);
  return source.split('\n').map((line) {
    line = line.trimRight();
    return line.startsWith(indent) ? line.substring(indent.length) : line;
  }).join('\n');
}
