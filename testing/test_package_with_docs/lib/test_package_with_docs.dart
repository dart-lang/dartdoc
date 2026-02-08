/// A library with documentation guides.
library;

/// A well-documented class for testing.
class Greeter {
  /// The greeting template.
  final String template;

  /// Creates a new [Greeter] with the given [template].
  Greeter(this.template);

  /// Returns a greeting for the given [name].
  String greet(String name) => template.replaceAll('{name}', name);
}
