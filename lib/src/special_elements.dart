// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Handling for special elements within Dart.  When identified these
/// may alter the interpretation and documentation generated for other
/// [ModelElement]s.
///
/// Finding these must not depend on canonicalization.
library;

import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk;
import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/model.dart';

/// A declaration of a special [Class] and how to find it.
enum SpecialClass {
  object('Object', 'dart.core', 'dart:core'),

  pragma('pragma', 'dart.core', 'dart:core');

  /// The package name in which these special [ModelElement]s can be found.
  static const String _packageName = 'Dart';

  /// Name of the [ModelElement].
  final String _name;

  /// The library name for the [LibraryElement] in which this [ModelElement]
  /// can be found.
  final String _libraryName;

  /// The URI for the library in which this [ModelElement] is defined.
  final String _uri;

  const SpecialClass(this._name, this._libraryName, this._uri);

  /// Elements which must exist in the package graph when calling
  /// [SpecialClasses.new].
  static List<SpecialClass> get _requiredSpecialClasses =>
      [SpecialClass.object];

  /// Returns the path of the Dart Library where this [ModelElement] is
  /// declared, or `null` if its URI does not denote a library in the specified
  /// SDK.
  String? _path(DartSdk sdk) => sdk.mapDartUri(_uri)?.fullName;

  bool matchesClass(Class modelClass) {
    return modelClass.name == _name &&
        modelClass.library.element.name == _libraryName &&
        modelClass.package.name == _packageName;
  }
}

/// Given an SDK, resolve URIs for the libraries containing our special
/// classes.
Set<String> specialLibraryFiles(DartSdk sdk) =>
    SpecialClass.values.map((e) => e._path(sdk)).nonNulls.toSet();

/// Class for managing special [Class] objects inside Dartdoc.
class SpecialClasses {
  final Map<SpecialClass, Class> _specialClasses = {};

  /// Adds a class object that could be special.
  void addSpecial(Class class_) {
    var specialClass =
        SpecialClass.values.firstWhereOrNull((e) => e.matchesClass(class_));
    if (specialClass == null) return;
    assert(!_specialClasses.containsKey(specialClass) ||
        _specialClasses[specialClass] == class_);
    _specialClasses[specialClass] = class_;
  }

  /// Throw an [AssertionError] if not all required specials are found.
  void assertSpecials() {
    for (var class_ in SpecialClass._requiredSpecialClasses) {
      assert(_specialClasses.containsKey(class_));
    }
  }

  Class? operator [](SpecialClass specialClass) =>
      _specialClasses[specialClass];
}
