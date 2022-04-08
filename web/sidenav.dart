// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

/// Initialize the sidenav event handlers.
void init() {
  final document = window.document;

  var leftNavToggle = document.getElementById('sidenav-left-toggle');
  var leftDrawer = document.querySelector('.sidebar-offcanvas-left');
  var overlayElement = document.getElementById('overlay-under-drawer');

  void toggleDrawerAndOverlay(Event event) {
    leftDrawer?.classes.toggle('active');
    overlayElement?.classes.toggle('active');
  }

  overlayElement?.addEventListener('click', toggleDrawerAndOverlay);
  leftNavToggle?.addEventListener('click', toggleDrawerAndOverlay);
}
