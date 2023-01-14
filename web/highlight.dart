import 'package:js/js.dart';

void init() {
  highlight?.highlightAll();
}

@JS()
@staticInterop
class HighlightJs {}

extension HighlightJsExtension on HighlightJs {
  external void highlightAll();
}

@JS('hljs')
external HighlightJs? get highlight;
