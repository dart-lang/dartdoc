// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS('Response')
@staticInterop
final class FetchResponse {}

extension FetchResponseExtension on FetchResponse {
  external int get status;

  @JS('text')
  external JSPromise _text();
  Future<String> get text async =>
      ((await _text().toDart) as JSString).toString();
}
