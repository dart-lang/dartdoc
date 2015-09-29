library dartdoc.config;

class Config {
  final bool addCrossdart;
  Config(this.addCrossdart);
}

Config _config;
Config get config => _config;

void initializeConfig({bool addCrossdart: false}) {
  _config = new Config(addCrossdart);
}
