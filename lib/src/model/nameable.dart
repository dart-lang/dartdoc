// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'locatable.dart';

/// Something that has a name.
abstract class Nameable {
  String get name;

  String get fullyQualifiedName => name;

  late final Set<String> namePieces = {
    ...name.split(locationSplitter).where((s) => s.isNotEmpty)
  };

  /// Utility getter/cache for `_MarkdownCommentReference._getResultsForClass`.
  // TODO(jcollins-g): This should really be the same as 'name', but isn't
  // because of accessors and operators.
  late final String namePart = fullyQualifiedName.split('.').last;

  @override
  String toString() => name;
}

int byName(Nameable a, Nameable b) {
  var stringCompare = compareAsciiLowerCaseNatural(a.name, b.name);
  if (stringCompare == 0) {
    return a.hashCode.compareTo(b.hashCode);
  }
  return stringCompare;
}
