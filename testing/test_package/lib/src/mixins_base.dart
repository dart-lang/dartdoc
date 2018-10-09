library mixins_base;

mixin AMixin {}

class ThisClass {
  String property;
}

/// A class that extends another class with a new-style mixin, then is
/// reexported a couple of times similar to how Flutter does things.
class MixedIn extends ThisClass with AMixin {}
