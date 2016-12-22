// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.config;

import 'dart:io';

class Config {
  final Directory inputDir;
  final bool addCrossdart;
  final String examplePathPrefix;
  final bool includeSource;
  final String sdkVersion;
  Config._(
      this.inputDir, this.addCrossdart, this.examplePathPrefix, this.includeSource, this.sdkVersion);
}

Config _config;
Config get config => _config;

void setConfig(
    {Directory inputDir,
    String sdkVersion,
    bool addCrossdart: false,
    String examplePathPrefix,
    bool includeSource: true}) {
  _config = new Config._(inputDir, addCrossdart, examplePathPrefix, includeSource, sdkVersion);
}
