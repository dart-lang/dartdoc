library test_package.tool;

abstract class PrivateLibraryToolUser {
  /// Invokes a tool from a private library.
  ///
  /// {@tool drill}
  /// Some text in the drill.
  /// {@end-tool}
  void invokeToolPrivateLibrary();
}
