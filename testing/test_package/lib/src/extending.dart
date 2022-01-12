library two_exports.src.extending;

import 'base.dart';

int topLevelVariable = 1;

bool? someConflictingNameSymbol;

/// Extending class extends [BaseClass].
///
/// Also check out [topLevelVariable].
///
/// Linking over to [Apple] should work.
class ExtendingClass extends BaseClass {}

class ExtendingAgain extends BaseWithMembers {
  @override
  bool? anotherField;
}
