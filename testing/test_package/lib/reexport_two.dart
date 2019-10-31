/// {@canonicalFor reexport.somelib.SomeClass}
/// {@canonicalFor reexport.somelib.AUnicornClass}
/// {@canonicalFor something.ThatDoesntExist}
/// {@canonicalFor reexport.somelib.DocumentThisExtensionOnce}
/// {@category Unreal}
library reexport_two;

// Intentionally create some duplicates via reexporting.
export 'src/mixins.dart' show MixedIn, AMixin;
export 'src/somelib.dart';
