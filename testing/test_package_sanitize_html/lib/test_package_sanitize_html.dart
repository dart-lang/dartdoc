/// My library
///
/// See [heading](#heading-with-id).
///
/// <h1 id="my-id">headline with custom id</h1>
///
/// <h1 id="MY-ID">headline with disallowed id</h1>
///
/// # Heading with id
///  * what a topic
library ex;

abstract class SanitizableHtml {
  /// Has both good and bad block HTML
  ///
  /// <h1>A fine headline</h1>
  ///
  /// <script>
  /// alert('bad-idea');
  /// </script>
  void blockHtml();

  /// Has both good and bad inline HTML
  ///
  /// Writing <small>little text</small> is fine.
  ///
  /// Having links is okay <a href="https://example.com">link</a>, but they
  /// should have ugc.
  ///
  /// This is a <a href="javascript:alert('bad-idea');">bad</a> link.
  void inlineHtml();
}
