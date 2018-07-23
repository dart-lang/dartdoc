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
import 'package:dartdoc/src/model.dart';

/// Which of the [SpecialClasses] to get.
enum SpecialClass {
  /// From dart:core, Object
  object,
  /// From dart:_interceptors, Interceptor
  interceptor,
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
  _SpecialClassDefinition(this.specialClass, this.name, this.libraryName, this.specialFileUri, {this.required = true, this.packageName = 'Dart'}) {
    assert(packageName == 'Dart', 'Packages other than SDK not yet supported in special element detection');
  }

  /// Get the filename for the Dart Library where this [specialClass] is
  /// declared.
  String getSpecialFilename(DartSdk sdk) => sdk.mapDartUri(specialFileUri).fullName;

  bool matchesClass(Class modelClass) {
    return modelClass.name == name &&
           modelClass.library.element.name == libraryName &&
           modelClass.package.name == packageName;
  }
}

/// List all special classes we need to find here.
final List<_SpecialClassDefinition> _specialClassDefinitions = [
  new _SpecialClassDefinition(SpecialClass.object, 'Object', 'dart.core', 'dart:core'),
  new _SpecialClassDefinition(SpecialClass.interceptor, 'Interceptor', '_interceptors', 'dart:_interceptors'),
];

/// Given a SDK, resolve URIs for the libraries containing our special
/// clases.
Set<String> specialLibraryFiles(DartSdk sdk) => _specialClassDefinitions.map((_SpecialClassDefinition d) => d.getSpecialFilename(sdk)).toSet();

Set<String> __specialLibraryNames;
/// These library names can be checked against the [LibraryElement] names
/// to avoid traversing libraries we don't need to.
Set<String> get _specialLibraryNames {
  if (__specialLibraryNames == null) {
    __specialLibraryNames = _specialClassDefinitions.map((_SpecialClassDefinition d) => d.libraryName).toSet();
  }
  return __specialLibraryNames;
}

/// Class for managing special [Class] objects inside Dartdoc.
class SpecialClasses {
  final PackageGraph packageGraph;
  final Map<SpecialClass, Class> _specialClass = {};

  SpecialClasses(this.packageGraph) {
    Set<LibraryElement> doneKeys = new Set();
    Set<LibraryElement> keysToDo = new Set.from(packageGraph.allLibraries.keys);
    // Loops because traversing the libraries can instantiate additional
    // libraries, and does so in this manner to avoid running into iterable
    // modification exceptions.
    while (keysToDo.isNotEmpty) {
      keysToDo.forEach((LibraryElement e) {
        if (_specialLibraryNames.contains(e.name)) {
          packageGraph.allLibraries[e].allClasses.forEach((Class aClass) {
            _specialClassDefinitions.forEach((_SpecialClassDefinition d) {
              if (d.matchesClass(aClass)) {
                assert (!_specialClass.containsKey(d.specialClass) || _specialClass[d.specialClass] == aClass);
                _specialClass[d.specialClass] = aClass;
              }
            });
          });
        }
        doneKeys.add(e);
      });
      keysToDo = new Set.from(packageGraph.allLibraries.keys.where((LibraryElement e) => !doneKeys.contains(e)));
    }
    _specialClassDefinitions.forEach((_SpecialClassDefinition d) {
      if (d.required) assert(_specialClass.containsKey(d.specialClass));
    });
  }

  Class operator[](SpecialClass specialClass) => _specialClass[specialClass];
}