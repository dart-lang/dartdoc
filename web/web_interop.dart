// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_util' as js_util;

import 'package:js/js.dart';

@JS('Response')
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
