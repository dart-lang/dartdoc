// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

void init() {
  var bodyElement = document.body;

  if (bodyElement == null) {
    return;
  }

  var theme = document.getElementById('theme') as InputElement;

  theme.addEventListener('change', (event) {
    if (theme.checked == true) {
      bodyElement.setAttribute('class', 'dark-theme');
      theme.setAttribute('value', 'dark-theme');
      window.localStorage['colorTheme'] = 'true';
    } else {
      bodyElement.setAttribute('class', 'light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage['colorTheme'] = 'false';
    }
  });

  if (window.localStorage['colorTheme'] != null) {
    theme.checked = window.localStorage['colorTheme'] == 'true';
    if (theme.checked == true) {
      bodyElement.setAttribute('class', 'dark-theme');
      theme.setAttribute('value', 'dark-theme');
      window.localStorage['colorTheme'] = 'true';
    } else {
      bodyElement.setAttribute('class', 'light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage['colorTheme'] = 'false';
    }
  }
}
