// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// dartdoc's dartdoc_options.yaml configuration file follows similar loading
/// semantics to that of analysis_options.yaml,
/// [documented here](https://www.dartlang.org/guides/language/analysis-options).
/// It searches parent directories until it finds an analysis_options.yaml file,
/// and uses built-in defaults if one is not found.
///
library dartdoc.dartdoc_options;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'logging.dart';

Map<String, DartdocOptions> _dartdocOptionsCache = {};

abstract class DartdocOptions {
  DartdocOptions();

  /// Path to the dartdoc options file, or '<default>' if this object is the
  /// default setting. Intended for printing only.
  String get _path;

  /// A list indicating the preferred subcategory sorting order.
  List<String> get categoryOrder;

  factory DartdocOptions.fromDir(Directory dir) {
    if (!_dartdocOptionsCache.containsKey(dir.absolute.path)) {
      _dartdocOptionsCache[dir.absolute.path] =
          new DartdocOptions._fromDir(dir);
    }
    return _dartdocOptionsCache[dir.absolute.path];
  }

  /// Search for a dartdoc_options file in this and parent directories.
  factory DartdocOptions._fromDir(Directory dir) {
    if (!dir.existsSync()) return new _DefaultDartdocOptions();

    File f;
    dir = dir.absolute;

    while (true) {
      f = new File(p.join(dir.path, 'dartdoc_options.yaml'));
      if (f.existsSync() || dir.parent.path == dir.path) break;
      dir = dir.parent.absolute;
    }

    DartdocOptions parent;
    if (dir.parent.path != dir.path) {
      parent = new DartdocOptions.fromDir(dir.parent);
    } else {
      parent = new _DefaultDartdocOptions();
    }
    if (f.existsSync()) {
      return new _FileDartdocOptions(f);
    }
    return parent;
  }
}

class _DefaultDartdocOptions extends DartdocOptions {
  _DefaultDartdocOptions() : super();

  @override
  String get _path => '<default>';

  @override
  List<String> get categoryOrder => new List.unmodifiable([]);
}

class _FileDartdocOptions extends DartdocOptions {
  File dartdocOptionsFile;
  Map _dartdocOptions;
  _FileDartdocOptions(this.dartdocOptionsFile) : super() {
    Map allDartdocOptions = loadYaml(dartdocOptionsFile.readAsStringSync());
    if (allDartdocOptions.containsKey('dartdoc')) {
      _dartdocOptions = allDartdocOptions['dartdoc'];
    } else {
      _dartdocOptions = {};
      logWarning("${_path}: must contain 'dartdoc' section");
    }
  }

  @override
  String get _path => dartdocOptionsFile.path;

  List<String> _categoryOrder;
  @override
  List<String> get categoryOrder {
    if (_categoryOrder == null) {
      _categoryOrder = [];
      if (_dartdocOptions.containsKey('categoryOrder')) {
        if (_dartdocOptions['categoryOrder'] is YamlList) {
          _categoryOrder.addAll(_dartdocOptions['categoryOrder']);
        } else {
          logWarning("${_path}: categoryOrder must be a list (ignoring)");
        }
      }
      _categoryOrder = new List.unmodifiable(_categoryOrder);
    }
    return _categoryOrder;
  }
}
