abstract class ToolUser {
  /// Invokes a tool that fails.
  ///
  /// {@tool drill}
  /// Doesn't matter what's here: it's gonna fail.
  /// {@end-tool}
  void invokeFailingTool();
}
