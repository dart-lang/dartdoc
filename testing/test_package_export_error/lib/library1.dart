library library1;

/// An invalid reexport - a non-existent library3.dart from 'not_referenced_in_pubspec'
/// package.
export 'package:not_referenced_in_pubspec/library3.dart' show Lib3Class;
