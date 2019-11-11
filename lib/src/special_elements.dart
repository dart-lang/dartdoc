// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Handling for special elements within Dart.  When identified these
/// may alter the interpretation and documentation generated for other
/// [ModelElement]s.
///
/// Finding these must not depend on canonicalization.
library dartdoc.special_elements;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:dartdoc/src/model/model.dart';

/// Which of the [SpecialClasses] to get.
enum SpecialClass {
  /// From dart:core, Object
  object,

  /// From dart:_interceptors, Interceptor
  interceptor,

  /// From dart:core, pragma
  pragma,
}

/// A declaration of a special [Class] and how to find it.
class _SpecialClassDefinition {
  /// Which specialElement this is.
  final SpecialClass specialClass;

  /// Name of the ModelElement.
  final String name;

  /// The library name for the [LibraryElement] in which this [ModelElement]
  /// can be found.
  final String libraryName;

  /// The package name in which this [ModelElement] can be found.
  final String packageName;

  /// The URI for the library in which this [ModelElement] is defined.
  final String specialFileUri;

  /// If true, require this element to exist in the packageGraph when
  /// calling the [SpecialClasses] constructor.
  final bool required;
  _SpecialClassDefinition(
      this.specialClass, this.name, this.libraryName, this.specialFileUri,
      {this.required = true, this.packageName = 'Dart'});

  /// Get the filename for the Dart Library where this [specialClass] is
  /// declared.
  String getSpecialFilename(DartSdk sdk) =>
      sdk.mapDartUri(specialFileUri)?.fullName;

  bool matchesClass(Class modelClass) {
    return modelClass.name == name &&
        modelClass.library.element.name == libraryName &&
        modelClass.package.name == packageName;
  }
}

/// All special classes we need to find here, indexed by class name.
/// The index is a shortcut to reduce processing time for determining if
/// a class might be "special".
final Map<String, _SpecialClassDefinition> _specialClassDefinitions = {
  'Object': _SpecialClassDefinition(
      SpecialClass.object, 'Object', 'dart.core', 'dart:core'),
  'Interceptor': _SpecialClassDefinition(SpecialClass.interceptor,
      'Interceptor', '_interceptors', 'dart:_interceptors',
      required: false),
  'pragma': _SpecialClassDefinition(
      SpecialClass.pragma, 'pragma', 'dart.core', 'dart:core',
      required: false),
};

/// Given a SDK, resolve URIs for the libraries containing our special
/// classes.
Set<String> specialLibraryFiles(DartSdk sdk) => _specialClassDefinitions.values
    .map((_SpecialClassDefinition d) => d.getSpecialFilename(sdk))
    .where((String s) => s != null)
    .toSet();

/// Class for managing special [Class] objects inside Dartdoc.
class SpecialClasses {
  final Map<SpecialClass, Class> _specialClass = {};

  SpecialClasses();

  /// Add a class object that could be special.
  void addSpecial(Class aClass) {
    if (_specialClassDefinitions.containsKey(aClass.name)) {
      var d = _specialClassDefinitions[aClass.name];
      if (d.matchesClass(aClass)) {
        assert(!_specialClass.containsKey(d.specialClass) ||
            _specialClass[d.specialClass] == aClass);
        _specialClass[d.specialClass] = aClass;
      }
    }
  }

  /// Throw an [AssertionError] if not all required specials are found.
  void assertSpecials() {
    _specialClassDefinitions.values.forEach((_SpecialClassDefinition d) {
      if (d.required) assert(_specialClass.containsKey(d.specialClass));
    });
  }

  Class operator [](SpecialClass specialClass) => _specialClass[specialClass];
}
