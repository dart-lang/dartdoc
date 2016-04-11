/// This library is excluded from the documentation
/// even though it is located in the lib folder by
/// using the <nodoc> tag
library excluded;

export 'example.dart' show Apple;

const EXCLUDE = 'exclude';

class Excluded {
  void excludedMethod(String s) {}
}
