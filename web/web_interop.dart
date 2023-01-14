import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

@JS()
@staticInterop
class FetchResponse {}

extension FetchResponseExtension on FetchResponse {
  external int get status;

  @JS('text')
  external Promise _text();
  Future<String> get text => js_util.promiseToFuture(_text());
}

@JS()
@staticInterop
class Promise {}
