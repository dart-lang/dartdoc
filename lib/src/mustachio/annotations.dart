/// Specifies information for generating a Mustache renderer for a [context]
/// object, using a Mustache template at [templateUri]
class Renderer {
  /// The name of the render function to generate.
  final Symbol name;

  /// The type of the context type, specified as the [Context] type argument.
  final Context context;

  /// A set of types which are "visible" to Mustache. Mustache rendering has
  /// access to all of a type's public getters if it is visible to Mustache.
  ///
  /// Note that all subtypes and supertypes of a "visible" type are also visible
  /// to Mustache.
  final Set<Type> visibleTypes;

  const Renderer(this.name, this.context, {this.visibleTypes = const {}});
}

/// A container for a type, [T], which is the type of a context object,
/// referenced in a `@Renderer` annotation.
///
/// An instance of this class holds zero information, except for [T], a type.
class Context<T> {
  const Context();
}
