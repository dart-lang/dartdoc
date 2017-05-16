// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.config;

import 'dart:collection' show UnmodifiableListView;
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
  Config._(
      this.inputDir,
      this.showWarnings,
      this.addCrossdart,
      this.examplePathPrefix,
      this.includeSource,
      this.sdkVersion,
      this.autoIncludeDependencies,
      this.categoryOrder);
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
    List<String> categoryOrder}) {
  if (categoryOrder == null) {
    categoryOrder = new UnmodifiableListView<String>([]);
  }
  _config = new Config._(
      inputDir,
      showWarnings,
      addCrossdart,
      examplePathPrefix,
      includeSource,
      sdkVersion,
      autoIncludeDependencies,
      categoryOrder);
}
