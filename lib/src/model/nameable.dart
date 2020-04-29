// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'locatable.dart';

/// Something that has a name.
abstract class Nameable {
  String get name;

  String get fullyQualifiedName => name;

  Set<String> _namePieces;

  Set<String> get namePieces {
    _namePieces ??= {
      ...name.split(locationSplitter).where((s) => s.isNotEmpty)
    };
    return _namePieces;
  }

  String _namePart;

  /// Utility getter/cache for `_MarkdownCommentReference._getResultsForClass`.
  String get namePart {
    // TODO(jcollins-g): This should really be the same as 'name', but isn't
    // because of accessors and operators.
    _namePart ??= fullyQualifiedName.split('.').last;
    return _namePart;
  }

  @override
  String toString() => name;
}

int byName(Nameable a, Nameable b) =>
    compareAsciiLowerCaseNatural(a.name, b.name);
