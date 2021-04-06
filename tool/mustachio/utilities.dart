import 'package:analyzer/dart/element/element.dart';

extension ClassExtensions on ClassElement {
  /// The type parameters, if any, as a String, including bounds and the angled
  /// brackets, otherwise a blank String.
  String get typeParametersString {
    return asGenerics(typeParameters
        .map((tp) => tp.getDisplayString(withNullability: false)));
  }

  /// The type variables, if any, as a String, including the angled brackets,
  /// otherwise a blank String.
  String get typeVariablesString {
    return asGenerics(typeParameters.map((tp) => tp.name));
  }

  /// Returns the type parameters, and [extra], as they appear in a list of
  /// generics.
  String typeParametersStringWith(String extra) {
    return asGenerics([
      ...typeParameters
          .map((tp) => tp.getDisplayString(withNullability: false)),
      extra,
    ]);
  }
}

/// Returns [values] as they appear in a list of generics, with angled brackets,
/// and an empty string when [values] is empty.
String asGenerics(Iterable<String> values) =>
    values.isEmpty ? '' : '<${values.join(', ')}>';
