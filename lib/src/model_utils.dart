// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

final _driveLetterMatcher = RegExp(r'^\w:\\');

final Map<String, String> _fileContents = <String, String>{};

/// This will handle matching globs, including on Windows.
///
/// On windows, globs are assumed to use absolute Windows paths with drive
/// letters in combination with globs, e.g. `C:\foo\bar\*.txt`.  `fullName`
/// also is assumed to have a drive letter.
bool matchGlobs(List<String> globs, String fullName, {bool? isWindows}) {
  var windows = isWindows ?? Platform.isWindows;
  var filteredGlobs = <String>[];

  if (windows) {
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
      filteredGlobs.add(p.posix.joinAll(p.windows.split(glob)));
    }
  } else {
    filteredGlobs.addAll(globs);
  }

  return filteredGlobs.any(
      (g) => Glob(g, context: windows ? p.windows : p.posix).matches(fullName));
}

Iterable<T> filterHasCanonical<T extends ModelElement>(
    Iterable<T> maybeHasCanonicalItems) {
  return maybeHasCanonicalItems.where((me) => me.canonicalModelElement != null);
}

/// Selects [items] which are documented.
Iterable<T> filterNonDocumented<T extends Documentable>(Iterable<T> items) =>
    items.where((me) => me.isDocumented);

/// Returns an iterable containing only public elements from [privacyItems].
Iterable<T> filterNonPublic<T extends Privacy>(Iterable<T> privacyItems) {
  return privacyItems.where((me) => me.isPublic);
}

/// Finds canonical classes for all classes in the iterable, if possible.
/// If a canonical class can not be found, returns the original class.
Iterable<InheritingContainer> findCanonicalFor(
    Iterable<InheritingContainer> containers) {
  return containers.map((c) =>
      c.packageGraph.findCanonicalModelElementFor(c.element)
          as InheritingContainer? ??
      c);
}

/// Uses direct file access to get the contents of a file.  Cached.
///
/// Direct reading of source code via a [PhysicalResourceProvider] is not
/// allowed in some environments, so avoid using this.
// TODO(jcollins-g): consider deprecating this and the `--include-source`
// feature that uses it now that source code linking is possible.
// TODO(srawlins): Evaluate whether this leads to a ton of memory usage.
// An LRU of size 1 might be just fine.
String getFileContentsFor(Element e, ResourceProvider resourceProvider) {
  var location = e.source?.fullName;
  if (location != null && !_fileContents.containsKey(location)) {
    var contents = resourceProvider.getFile(location).readAsStringSync();
    _fileContents.putIfAbsent(location, () => contents);
  }
  return _fileContents[location]!;
}

bool hasPrivateName(Element e) {
  var elementName = e.name;
  if (elementName == null) return false;

  if (elementName.startsWith('_')) {
    return true;
  }
  // GenericFunctionTypeElements have the name we care about in the enclosing
  // element.
  if (e is GenericFunctionTypeElement) {
    var enclosingElementName = e.enclosingElement?.name;
    if (enclosingElementName != null && enclosingElementName.startsWith('_')) {
      return true;
    }
  }
  if (e is LibraryElement) {
    if (e.identifier.startsWith('dart:_') ||
        e.identifier.startsWith('dart:nativewrappers/') ||
        'dart:nativewrappers' == e.identifier) {
      return true;
    }
    var elementUri = e.source.uri;
    // TODO(jcollins-g): Implement real cross package detection
    if (elementUri.scheme == 'package' && elementUri.pathSegments[1] == 'src') {
      return true;
    }
  }
  return false;
}

bool hasPublicName(Element e) => !hasPrivateName(e);

/// Strip leading dartdoc comments from the given source code.
String stripDartdocCommentsFromSource(String source) {
  var remainder = source.trimLeft();
  var lineComments = remainder.startsWith(_tripleSlash) ||
      remainder.startsWith(_escapedTripleSlash);
  var blockComments = remainder.startsWith(_slashStarStar) ||
      remainder.startsWith(_escapedSlashStarStar);

  return source.split('\n').where((String line) {
    if (lineComments) {
      if (line.startsWith(_tripleSlash) ||
          line.startsWith(_escapedTripleSlash)) {
        return false;
      }
      lineComments = false;
      return true;
    } else if (blockComments) {
      if (line.contains(_starSlash) || line.contains(_escapedStarSlash)) {
        blockComments = false;
        return false;
      }
      if (line.startsWith(_slashStarStar) ||
          line.startsWith(_escapedSlashStarStar)) {
        return false;
      }
      return false;
    }

    return true;
  }).join('\n');
}

const HtmlEscape _escape = HtmlEscape();

const String _tripleSlash = '///';

final String _escapedTripleSlash = _escape.convert(_tripleSlash);

const String _slashStarStar = '/**';

final String _escapedSlashStarStar = _escape.convert(_slashStarStar);

const String _starSlash = '*/';

final String _escapedStarSlash = _escape.convert(_starSlash);

/// Strip the common indent from the given source fragment.
String stripIndentFromSource(String source) {
  var remainder = source.trimLeft();
  var indent = source.substring(0, source.length - remainder.length);
  return source.split('\n').map((line) {
    line = line.trimRight();
    return line.startsWith(indent) ? line.substring(indent.length) : line;
  }).join('\n');
}
