// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.config;

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as p;

import 'model.dart';

/// Class representing values possibly local to a particular [ModelElement].
class LocalConfig {
  final Map<String, Set<String>> categoryMap;
  final PackageMeta packageMeta;

  LocalConfig._(this.categoryMap, this.packageMeta);

  factory LocalConfig.fromLibrary(LibraryElement element) {
    return new LocalConfig._({}, getPackageMeta(element));
  }

  static PackageMeta getPackageMeta(LibraryElement element) {
    String sourcePath = element.source.fullName;
    File file = new File(p.canonicalize(sourcePath));
    Directory dir = file.parent;
    while (dir.parent.path != dir.path && dir.existsSync()) {
      File pubspec = new File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        return new PackageMeta.fromDir(dir);
      }
      dir = dir.parent;
    }
    return null;
  }

}

class Config {
  final Directory inputDir;
  final bool showWarnings;
  final bool addCrossdart;
  final String examplePathPrefix;
  final bool includeSource;
  final String sdkVersion;
  final bool autoIncludeDependencies;
  final List<String> packageOrder;
  final double reexportMinConfidence;
  final bool verboseWarnings;
  final List<String> dropTextFrom;
  final List<String> excludePackages;
  final bool validateLinks;
  Config._(
      this.inputDir,
      this.showWarnings,
      this.addCrossdart,
      this.examplePathPrefix,
      this.includeSource,
      this.sdkVersion,
      this.autoIncludeDependencies,
      this.packageOrder,
      this.reexportMinConfidence,
      this.verboseWarnings,
      this.dropTextFrom,
      this.excludePackages,
      this.validateLinks);
}

Config _config;
Config get config => _config;

void setConfig(
    {Directory inputDir,
    bool showWarnings: false,
    bool addCrossdart: false,
    String examplePathPrefix,
    bool includeSource: true,
    String sdkVersion,
    bool autoIncludeDependencies: false,
    List<String> packageOrder,
    double reexportMinConfidence: 0.1,
    bool verboseWarnings: true,
    List<String> dropTextFrom,
    List<String> excludePackages,
    bool validateLinks: true}) {
  _config = new Config._(
      inputDir,
      showWarnings,
      addCrossdart,
      examplePathPrefix,
      includeSource,
      sdkVersion,
      autoIncludeDependencies,
      packageOrder ?? const <String>[],
      reexportMinConfidence,
      verboseWarnings,
      dropTextFrom ?? const <String>[],
      excludePackages ?? const <String>[],
      validateLinks);
}
