// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'foo.aot_renderers_for_html.dart';
import 'foo.dart';

void main() {
  test('Renderer renders a non-bool variable node', () async {
    var foo = Foo()
      ..s1 = 'hello'
      ..b1 = false
      ..l1 = [1, 2, 3];
    var rendered = renderFoo(foo);
    expect(rendered, equals('''
<div>

    <div class="partial">
    l1: [1, 2, 3]</div>
    s1: hello    b1: false</div>'''));
  });

  // TODO(srawlins): Add waaay more end-to-end render tests. These are
  // non-trivial to write though, so that the input Markdown template and
  // expected output are visually near each other in the test cases...
}
