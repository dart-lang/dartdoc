// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as model_utils;

/// A set of libraries, initialized after construction by accessing [libraries].
/// Do not cache return values of any methods or members excepting [libraries]
/// and [name] before finishing initialization of a [LibraryContainer].
abstract class LibraryContainer
    implements Nameable, Comparable<LibraryContainer> {
  final List<Library> libraries = [];

  PackageGraph get packageGraph;

  Iterable<Library> get publicLibraries =>
      model_utils.filterNonPublic(libraries);

  bool get hasPublicLibraries => publicLibraries.isNotEmpty;

  /// The name of the container or object that this LibraryContainer is a part
  /// of.  Used for sorting in [containerOrder].
  String get enclosingName;

  /// Order by which this container should be sorted.
  List<String> get containerOrder;

  /// Sorting key.  [containerOrder] should contain these.
  String get sortKey => name;

  /// Does this container represent the SDK?  This can be false for containers
  /// that only represent a part of the SDK.
  bool get isSdk => false;

  /// Returns:
  /// -1 if this container is listed in [containerOrder].
  /// 0 if this container is named the same as the [enclosingName].
  /// 1 if this container represents the SDK.
  /// 2 if this group has a name that contains the name [enclosingName].
  /// 3 otherwise.
  int get _group {
    if (containerOrder.contains(sortKey)) return -1;
    if (equalsIgnoreAsciiCase(sortKey, enclosingName)) return 0;
    if (isSdk) return 1;
    if (sortKey.toLowerCase().contains(enclosingName.toLowerCase())) return 2;
    return 3;
  }

  @override
  int compareTo(LibraryContainer other) {
    if (_group == other._group) {
      if (_group == -1) {
        return Comparable.compare(containerOrder.indexOf(sortKey),
            containerOrder.indexOf(other.sortKey));
      } else {
        return sortKey.toLowerCase().compareTo(other.sortKey.toLowerCase());
      }
    }
    return Comparable.compare(_group, other._group);
  }
}
