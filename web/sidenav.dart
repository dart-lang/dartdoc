// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

/// Initialize the sidenav contents and event handlers.
void init() {
  _initializeContents();
  _initializeToggles();
}

void _initializeToggles() {
  final leftNavToggle = document.getElementById('sidenav-left-toggle');
  final leftDrawer = document.querySelector('.sidebar-offcanvas-left');
  final overlayElement = document.getElementById('overlay-under-drawer');

  final toggleDrawerAndOverlay = (Event _) {
    leftDrawer?.classList.toggle('active');
    overlayElement?.classList.toggle('active');
  }.toJS;

  overlayElement?.addEventListener('click', toggleDrawerAndOverlay);
  leftNavToggle?.addEventListener('click', toggleDrawerAndOverlay);
}

void _initializeContents() {
  final body = document.body;
  if (body == null) {
    return;
  }

  final dataUsingBaseHref = body.getAttribute('data-using-base-href');
  if (dataUsingBaseHref == null) {
    // This should never happen.
    return;
  }

  final String baseHref;
  if (dataUsingBaseHref != 'true') {
    final dataBaseHref = body.getAttribute('data-base-href');
    if (dataBaseHref == null) {
      return;
    }
    baseHref = dataBaseHref;
  } else {
    baseHref = '';
  }

  final mainContent = document.getElementById('dartdoc-main-content');
  if (mainContent == null) {
    return;
  }

  final aboveSidebarPath = mainContent.getAttribute('data-above-sidebar');
  final leftSidebar = document.getElementById('dartdoc-sidebar-left-content');
  _loadSidebar(baseHref, aboveSidebarPath, leftSidebar);

  final belowSidebarPath = mainContent.getAttribute('data-below-sidebar');
  final rightSidebar = document.getElementById('dartdoc-sidebar-right');
  _loadSidebar(baseHref, belowSidebarPath, rightSidebar);
}

void _loadSidebar(
  String baseHref,
  String? sidebarPath,
  Element? sidebarElement,
) {
  if (sidebarPath == null || sidebarPath.isEmpty || sidebarElement == null) {
    return;
  }

  window.fetch('$baseHref$sidebarPath'.toJS).toDart.then((fetchResponse) async {
    if (fetchResponse.status != 200) {
      final errorAnchor = (document.createElement('a') as HTMLAnchorElement)
        ..href = 'https://dart.dev/tools/dart-doc#troubleshoot'
        ..text = 'Failed to load sidebar. '
            'Visit dart.dev for help troubleshooting.';
      sidebarElement.appendChild(errorAnchor);
      return;
    }

    final responseText = (await fetchResponse.text().toDart).toDart;
    final contentTemplate = (document.createElement('template')
        as HTMLTemplateElement)
      ..innerHTML = responseText;

    // TODO(parlough): This isn't working yet.
    _updateLinks(baseHref, contentTemplate);
    sidebarElement.appendChild(contentTemplate.content.cloneNode(true));
  });
}

/// Recurses down a DOM tree to adjust the links in a newly loaded sidebar
/// if "base href" is not being used.
void _updateLinks(String baseHref, Node node) {
  if (node is Element && node.nodeName.toLowerCase() == 'a') {
    final hrefString = node.getAttribute('href');
    if (hrefString != null) {
      final href = Uri.parse(hrefString);
      if (!href.isAbsolute) {
        node.setAttribute('href', '$baseHref$hrefString');
      }
    }
  }

  final children = node.childNodes;
  for (var childIndex = 0; childIndex < children.length; childIndex += 1) {
    final child = children.item(childIndex);
    if (child != null) {
      _updateLinks(baseHref, child);
    }
  }
}
