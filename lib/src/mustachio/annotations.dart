/// Specifies information for generating a Mustache renderer for a [context]
/// object, using a Mustache template at [templateUri]
class Renderer {
  /// The name of the render function to generate.
  final Symbol name;

  /// The type of the context type, specified as the [Context] type argument.
  final Context context;

  const Renderer(this.name, this.context);
}

/// A container for a type, [T], which is the type of a context object,
/// referenced in a `@Renderer` annotation.
///
/// An instance of this class holds zero information, except for [T], a type.
class Context<T> {
  const Context();
}
