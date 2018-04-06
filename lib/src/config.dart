// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.config;

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/dartdoc.dart';

import 'model.dart';

/// Class representing values possibly local to a particular [ModelElement].
class LocalConfig {
  final Map<String, Set<String>> categoryMap;
  final PackageMeta packageMeta;

  LocalConfig._(this.categoryMap, this.packageMeta);

  factory LocalConfig.fromLibrary(LibraryElement element) {
    return new LocalConfig._({}, new PackageMeta.fromElement(element));
  }
}

class DartDocConfig {
  final bool addCrossdart;
  final bool autoIncludeDependencies;
  final List<String> dropTextFrom;
  final List<String> excludeLibraries;
  final List<String> excludePackages;
  final String examplePathPrefix;
  final List<String> includeExternals;
  final List<String> includeLibraries;
  final bool includeSource;
  final Directory inputDir;
  final List<String> packageOrder;
  final double reexportMinConfidence;
  final Directory sdkDir;
  final String sdkVersion;
  final bool showWarnings;
  final bool validateLinks;
  final bool verboseWarnings;
  DartDocConfig._(
      this.addCrossdart,
      this.autoIncludeDependencies,
      this.dropTextFrom,
      this.examplePathPrefix,
      this.excludeLibraries,
      this.excludePackages,
      this.includeExternals,
      this.includeLibraries,
      this.includeSource,
      this.inputDir,
      this.packageOrder,
      this.reexportMinConfidence,
      this.sdkDir,
      this.sdkVersion,
      this.showWarnings,
      this.validateLinks,
      this.verboseWarnings,
      );

  factory DartDocConfig.fromParameters({
    bool addCrossdart: false,
    bool autoIncludeDependencies: false,
    List<String> dropTextFrom,
    String examplePathPrefix,
    List<String> excludeLibraries,
    List<String> excludePackages,
    List<String> includeExternals,
    List<String> includeLibraries,
    bool includeSource: true,
    Directory inputDir,
    List<String> packageOrder,
    double reexportMinConfidence: 0.1,
    Directory sdkDir,
    String sdkVersion,
    bool showWarnings: false,
    bool validateLinks: true,
    bool verboseWarnings: true,
  }) {
    return new DartDocConfig._(
        addCrossdart,
        autoIncludeDependencies,
        dropTextFrom ?? const <String>[],
        examplePathPrefix,
        excludeLibraries ?? const <String>[],
        excludePackages ?? const <String>[],
        includeExternals ?? const <String>[],
        includeLibraries ?? const <String>[],
        includeSource,
        inputDir,
        packageOrder ?? const <String>[],
        reexportMinConfidence,
        sdkDir ?? getSdkDir(),
        sdkVersion,
        showWarnings,
        validateLinks,
        verboseWarnings,
    );
  }

  bool isLibraryExcluded(String name) =>
      excludeLibraries.any((pattern) => name == pattern);
  bool isPackageExcluded(String name) =>
      excludePackages.any((pattern) => name == pattern);
}
