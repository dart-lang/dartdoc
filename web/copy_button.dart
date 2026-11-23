// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

const _svgNamespace = 'http://www.w3.org/2000/svg';

// Path data for the Material Symbols "content_copy" and "check" icons
// (Apache-2.0: https://github.com/google/material-design-icons).
const _contentCopyPath =
    'M360-240q-33 0-56.5-23.5T280-320v-480q0-33 23.5-56.5T360-880h360q33 0 56.5 23.5T800-800v480q0 33-23.5 56.5T720-240H360Zm0-80h360v-480H360v480ZM200-80q-33 0-56.5-23.5T120-160v-560h80v560h440v80H200Zm160-240v-480 480Z';
const _checkPath = 'M382-240 154-468l57-57 171 171 367-367 57 57-424 424Z';

void init() {
  final blocks = document.querySelectorAll('pre:has(> code)');
  for (var i = 0; i < blocks.length; i++) {
    final pre = blocks.item(i) as HTMLPreElement?;
    if (pre == null) continue;

    final button = document.createElement('button') as HTMLButtonElement;
    button.className = 'copy-button';

    final icon = document.createElementNS(_svgNamespace, 'svg')
      ..setAttribute('class', 'dartdoc-icon')
      ..setAttribute('viewBox', '0 -960 960 960')
      ..setAttribute('width', '1em')
      ..setAttribute('height', '1em')
      ..setAttribute('fill', 'currentColor')
      ..setAttribute('aria-hidden', 'true');
    final iconPath = document.createElementNS(_svgNamespace, 'path')
      ..setAttribute('d', _contentCopyPath);
    icon.appendChild(iconPath);
    button.appendChild(icon);

    int? timeoutId;

    button.addEventListener(
        'click',
        (Event _) {
          final codeBlock = pre.querySelector('code') as HTMLElement?;
          final text = codeBlock?.textContent ?? '';

          window.navigator.clipboard.writeText(text);

          iconPath.setAttribute('d', _checkPath);
          button.classList.add('copied');

          if (timeoutId != null) {
            window.clearTimeout(timeoutId!);
          }

          timeoutId = window.setTimeout(
              () {
                iconPath.setAttribute('d', _contentCopyPath);
                button.classList.remove('copied');
                timeoutId = null;
              }.toJS,
              2000.toJS);
        }.toJS);

    pre.insertBefore(button, pre.firstChild);
  }
}
