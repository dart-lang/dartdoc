library reexport_three;

// Test show/hide handling.
export 'src/shadowing_lib.dart' show ADuplicateClass;
// ignore: directives_ordering
export 'src/shadow_lib.dart' hide ADuplicateClass;
