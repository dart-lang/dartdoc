library dartdoc.config;

import 'dart:io';

class Config {
  final Directory inputDir;
  final bool addCrossdart;
  final bool includeSource;
  final String sdkVersion;
  Config._(
      this.inputDir, this.addCrossdart, this.includeSource, this.sdkVersion);
}

Config _config;
Config get config => _config;

void initializeConfig(
    {Directory inputDir,
    String sdkVersion,
    bool addCrossdart: false,
    bool includeSource: true}) {
  _config = new Config._(inputDir, addCrossdart, includeSource, sdkVersion);
}
