// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

const _copyIconHtml = '''
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
    <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
  </svg>
''';

const _checkIconHtml = '''
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <polyline points="20 6 9 17 4 12"></polyline>
  </svg>
''';

void init() {
  var blocks = document.querySelectorAll('pre');
  for (var i = 0; i < blocks.length; i++) {
    var pre = blocks.item(i) as HTMLPreElement?;

    if (pre == null || pre.querySelector('code') == null) continue;

    var button = document.createElement('button') as HTMLButtonElement;
    button.className = 'copy-button';

    button.innerHTML = _copyIconHtml.toJS;

    int? timeoutId;

    button.addEventListener(
        'click',
        (Event _) {
          var codeBlock = pre.querySelector('code') as HTMLElement?;
          var text = codeBlock?.textContent ?? '';
          
          try {
            window.navigator.clipboard.writeText(text);
          } catch (_) {
            return;
          }

          button.innerHTML = _checkIconHtml.toJS;
          button.classList.add('copied');

          if (timeoutId != null) {
            window.clearTimeout(timeoutId!);
          }

          timeoutId = window.setTimeout(
              () {
                button.innerHTML = _copyIconHtml.toJS;
                button.classList.remove('copied');
                timeoutId = null;
              }.toJS,
              2000.toJS);
        }.toJS);

    pre.insertBefore(button, pre.firstChild);
  }
}
