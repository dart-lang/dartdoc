library base_class;

/// Abstract class Constraints
/// * The [debugAssertIsValid] method, which should assert if there's anything
///   wrong with the constraints object. (We use this approach rather than
///   asserting in constructors so that our constructors can be `const` and so
///   that it is possible to create invalid constraints temporarily while
///   building valid ones.) See the implementation of
///   [BoxConstraints.debugAssertIsValid] for an example of the detailed checks
///   that can be made.
abstract class Constraints {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const Constraints();

  /// Method is overriden in implementations.
  bool debugAssertIsValid() {
    return true;
  }
}
