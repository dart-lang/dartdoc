library test_package.tool;

abstract class PrivateLibraryToolUser {
  /// Invokes a tool from a private library.
  ///
  /// {@tool drill}
  /// Some text in the drill.
  /// {@end-tool}
  void invokeToolPrivateLibrary();
}

abstract class GenericSuperProperty<T> {}

abstract class GenericSuperValue<T> extends GenericSuperProperty<T> {}

class _GenericSuper<T> extends GenericSuperValue<T> {}

class GenericSuperNum<T extends num> extends _GenericSuper<T> {}

class GenericSuperInt extends GenericSuperNum<int> {}
