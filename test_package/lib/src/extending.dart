library two_exports.src.extending;

import 'base.dart';

int topLevelVariable = 1;

/// Extending class extends [BaseClass].
///
/// Also check out [topLevelVariable].
///
/// This should not work: linking over to [Apple].
class ExtendingClass extends BaseClass {}
