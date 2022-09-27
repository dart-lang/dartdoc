// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'highlight.dart' as highlight;
import 'search.dart' as search;
import 'sidenav.dart' as sidenav;
import 'theme.dart' as theme;

void main() {
  highlight.init();
  initializeSidebars();
  sidenav.init();
  search.init();
  theme.init();
}

void initializeSidebars() {
  final body = document.querySelector('body');
  if (body == null) {
    return;
  }
  final baseHref = body.dataset['base-href'];
  if (baseHref == null) {
    return;
  }
  final mainContent = document.querySelector('#dartdoc-main-content');
  if (mainContent == null) {
    return;
  }
  final aboveSidebarPath = mainContent.dataset['above-sidebar'];
  final leftSidebar = document.querySelector('#dartdoc-sidebar-left-content');
  if (aboveSidebarPath != null &&
      aboveSidebarPath.isNotEmpty &&
      leftSidebar != null) {
    HttpRequest.getString('$baseHref$aboveSidebarPath').then((content) {
      leftSidebar.innerHtml = content;
    });
  }
  final belowSidebarPath = mainContent.dataset['below-sidebar'];
  final rightSidebar = document.querySelector('#dartdoc-sidebar-right');
  if (belowSidebarPath != null &&
      belowSidebarPath.isNotEmpty &&
      rightSidebar != null) {
    HttpRequest.getString('$baseHref$belowSidebarPath').then((content) {
      rightSidebar.innerHtml = content;
    });
  }
}
