/// {@canonicalFor reexport.somelib.SomeClass}
/// {@canonicalFor reexport.somelib.AUnicornClass}
/// {@canonicalFor something.ThatDoesntExist}
/// {@canonicalFor reexport.somelib.DocumentThisExtensionOnce}
/// {@category Unreal}
library reexport_two;

export 'src/somelib.dart';

export 'src/mixins.dart' show MixedIn, AMixin;
