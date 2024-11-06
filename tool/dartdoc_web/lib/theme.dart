// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

void init() {
  var bodyElement = document.body;

  if (bodyElement == null) {
    return;
  }

  var theme = document.getElementById('theme') as HTMLInputElement;

  void switchThemes() {
    if (theme.checked) {
      bodyElement.setAttribute('class', 'dark-theme');
      theme.setAttribute('value', 'dark-theme');
      window.localStorage.setItem('colorTheme', 'true');
    } else {
      bodyElement.setAttribute('class', 'light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage.setItem('colorTheme', 'false');
    }
  }

  theme.addEventListener(
    'change',
    (Event _) {
      switchThemes();
    }.toJS,
  );

  if (window.localStorage.getItem('colorTheme') case var colorTheme?) {
    theme.checked = colorTheme == 'true';
    switchThemes();
  }
}
