// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.config;

import 'dart:io';

class Config {
  final Directory inputDir;
  final bool showWarnings;
  final bool addCrossdart;
  final String examplePathPrefix;
  final bool includeSource;
  final String sdkVersion;
  final bool autoIncludeDependencies;
  final List<String> categoryOrder;
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
      this.categoryOrder,
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
    List<String> categoryOrder,
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
      categoryOrder ?? const <String>[],
      reexportMinConfidence,
      verboseWarnings,
      dropTextFrom ?? const <String>[],
      excludePackages ?? const <String>[],
      validateLinks);
}
