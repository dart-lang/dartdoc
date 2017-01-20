// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.config;

import 'dart:io';

class Config {
  final Directory inputDir;
  final bool addCrossdart;
  final bool showWarnings;
  final String examplePathPrefix;
  final bool includeSource;
  final String sdkVersion;
  final bool autoIncludeDependencies;
  Config._(
      this.inputDir,
      this.showWarnings,
      this.addCrossdart,
      this.examplePathPrefix,
      this.includeSource,
      this.sdkVersion,
      this.autoIncludeDependencies);
}

Config _config;
Config get config => _config;

void setConfig(
    {Directory inputDir,
    bool showWarnings: false,
    String sdkVersion,
    bool addCrossdart: false,
    String examplePathPrefix,
    bool includeSource: true,
    bool autoIncludeDependencies: false}) {
  _config = new Config._(
      inputDir,
      showWarnings,
      addCrossdart,
      examplePathPrefix,
      includeSource,
      sdkVersion,
      autoIncludeDependencies);
}
