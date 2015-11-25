library dartdoc.config;

class Config {
  final bool addCrossdart;
  final bool includeSource;
  Config._(this.addCrossdart, this.includeSource);
}

Config _config;
Config get config => _config;

void initializeConfig({bool addCrossdart: false, bool includeSource: true}) {
  _config = new Config._(addCrossdart, includeSource);
}
