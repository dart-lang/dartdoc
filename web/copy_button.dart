// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

void init() {
  final blocks = document.querySelectorAll('pre:has(> code)');
  for (var i = 0; i < blocks.length; i++) {
    final pre = blocks.item(i) as HTMLPreElement?;
    if (pre == null) continue;

    final button = document.createElement('button') as HTMLButtonElement;
    button.className = 'copy-button';

    final iconSpan = document.createElement('span') as HTMLSpanElement;
    iconSpan.className = 'material-symbols-outlined';
    iconSpan.textContent = 'content_copy';
    button.appendChild(iconSpan);

    int? timeoutId;

    button.addEventListener(
        'click',
        (Event _) {
          final codeBlock = pre.querySelector('code') as HTMLElement?;
          final text = codeBlock?.textContent ?? '';

          window.navigator.clipboard.writeText(text);

          iconSpan.textContent = 'check';
          button.classList.add('copied');

          if (timeoutId != null) {
            window.clearTimeout(timeoutId!);
          }

          timeoutId = window.setTimeout(
              () {
                iconSpan.textContent = 'content_copy';
                button.classList.remove('copied');
                timeoutId = null;
              }.toJS,
              2000.toJS);
        }.toJS);

    pre.insertBefore(button, pre.firstChild);
  }
}
