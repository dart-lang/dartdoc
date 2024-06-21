// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

final _driveLetterMatcher = RegExp(r'^\w:\\');

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
      filteredGlobs.add(path.posix.joinAll(path.windows.split(glob)));
    }
  } else {
    filteredGlobs.addAll(globs);
  }

  return filteredGlobs.any((g) =>
      Glob(g, context: windows ? path.windows : path.posix).matches(fullName));
}

Iterable<T> filterHasCanonical<T extends ModelElement>(
    Iterable<T> maybeHasCanonicalItems) {
  return maybeHasCanonicalItems.where((me) => me.canonicalModelElement != null);
}

extension ElementExtension on Element {
  bool get hasPrivateName {
    final name = this.name;
    if (name == null) return false;

    if (name.startsWith('_')) {
      return true;
    }

    var self = this;

    // GenericFunctionTypeElements have the name we care about in the enclosing
    // element.
    if (self is GenericFunctionTypeElement) {
      var enclosingElementName = self.enclosingElement?.name;
      if (enclosingElementName != null &&
          enclosingElementName.startsWith('_')) {
        return true;
      }
    }
    if (self is LibraryElement) {
      if (self.identifier.startsWith('dart:_') ||
          self.identifier.startsWith('dart:nativewrappers/') ||
          'dart:nativewrappers' == self.identifier) {
        return true;
      }
      var elementUri = self.source.uri;
      // TODO(jcollins-g): Implement real cross package detection.
      if (elementUri.scheme == 'package' &&
          elementUri.pathSegments[1] == 'src') {
        return true;
      }
    }
    return false;
  }
}

extension IterableOfDocumentableExtension<E extends Documentable>
    on Iterable<E> {
  /// The public items which are documented.
  Iterable<E> get whereDocumented => where((e) => e.isDocumented).wherePublic;
}

extension IterableOfNameableExtension<E extends Nameable> on Iterable<E> {
  Iterable<E> get wherePublic => where((e) => e.isPublic);
}
