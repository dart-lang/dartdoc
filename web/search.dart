// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:js_util' as js_util;

void init() {
  // todo:

  // Dartdoc stores the htmlBase in 'body[data-base-href]'.
  var baseElement = window.document.querySelector('body')!;
  var htmlBase = baseElement.attributes['data-base-href'];

  window.fetch('${htmlBase}index.json').then((response) async {
    // todo: check the response code
    // ignore: unused_local_variable
    int code = js_util.getProperty(response, 'status');
    var textPromise = js_util.callMethod<Object>(response, 'text', []);
    var json = await promiseToFuture<String>(textPromise);

    // todo: decode JSON
    print('json response=${json.length} bytes');
  });
}
