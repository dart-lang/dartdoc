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

  var themeButton =
      document.getElementById('theme-button') as HTMLButtonElement;

  void switchThemes(bool toDarkMode) {
    if (toDarkMode) {
      bodyElement.classList.remove('light-theme');
      bodyElement.classList.add('dark-theme');

      window.localStorage.setItem('colorTheme', 'true');
    } else {
      bodyElement.classList.remove('dark-theme');
      bodyElement.classList.add('light-theme');

      window.localStorage.setItem('colorTheme', 'false');
    }
  }

  themeButton.addEventListener(
    'click',
    (Event _) {
      final currentlyDarkMode = bodyElement.classList.contains('dark-theme');
      switchThemes(!currentlyDarkMode);
    }.toJS,
  );

  if (window.localStorage.getItem('colorTheme') case var colorTheme?) {
    switchThemes(colorTheme == 'true');
  }
}
