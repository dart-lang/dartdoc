/// {@category Real Libraries}
/// {@category Misc}

// @dart=2.9

library two_exports;

export 'src/base.dart';
export 'src/extending.dart' hide someConflictingNameSymbol;

int aSymbolOnlyAvailableInExportContext;

bool someConflictingNameSymbol;
