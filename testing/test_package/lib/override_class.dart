import 'base_class.dart';

class BoxConstraints extends Constraints {
  /// Creates box constraints with the given constraints.
  const BoxConstraints();

  /// Overrides the method in the superclass.
  @override
  bool debugAssertIsValid() {
    return false;
  }
}
