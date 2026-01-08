// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/charcode.dart' show $a, $z;
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

/// This will handle matching globs, including on Windows.
///
/// On windows, globs are assumed to use absolute Windows paths with drive
/// letters in combination with globs, e.g. `C:\foo\bar\*.txt`.  `fullName`
/// also is assumed to have a drive letter.
bool matchGlobs(List<String> globs, String fullName, {bool? isWindows}) {
  var windows = isWindows ?? Platform.isWindows;
  if (windows) {
    // Drive letter (lower-cased).
    var driveChar = _windowsDriveLetterOf(fullName);
    // TODO(jcollins-g): port this special casing to the glob package.
    if (driveChar < 0) {
      throw DartdocFailure(
          'Unable to recognize drive letter on Windows in:  $fullName');
    }
    // Remove drive letter and colon.
    fullName = fullName.substring(2);
    // Remove same drive letter and colon from globs,
    // discard any with different or no drive letter.
    var filteredGlobs = <String>[
      for (var glob in globs)
        // Starts with same drive letter.
        if (driveChar == _windowsDriveLetterOf(glob))
          // Remove leading drive letter and colon, change `\` to `/`.
          path.posix.joinAll(path.windows.split(glob.substring(2)))
    ];
    globs = filteredGlobs;
  }

  return globs.any((g) =>
      Glob(g, context: windows ? path.windows : path.posix).matches(fullName));
}

// The lower-case ASCII code of the drive letter of path, or -1 if none.
int _windowsDriveLetterOf(String path) {
  if (path.length >= 3 && path.startsWith(r':\', 1)) {
    // Drive letter, lower-cased.
    var charCode = path.codeUnitAt(0) | 0x20;
    if (charCode >= $a && charCode <= $z) return charCode;
  }
  return -1;
}

Iterable<T> filterHasCanonical<T extends ModelElement>(
    Iterable<T> maybeHasCanonicalItems) {
  return maybeHasCanonicalItems.where((me) => me.canonicalModelElement != null);
}

extension ElementExtension on Element {
  bool get hasPrivateName {
    final name = this.name;
    if (name == null) return false;
    if (name.startsWith('_')) return true;

    // GenericFunctionTypeElements have the name we care about in the enclosing
    // element.
    if (this case GenericFunctionTypeElement self) {
      final enclosingElementName = self.enclosingElement?.name;
      return enclosingElementName != null &&
          enclosingElementName.startsWith('_');
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

extension IterableOfModelElementExtension<E extends ModelElement>
    on Iterable<E> {
  Iterable<E> whereDocumentedIn(Library library) =>
      whereDocumented.where((e) => e.canonicalLibrary == library);
}
