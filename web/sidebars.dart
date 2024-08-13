// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart';

import 'search.dart' show ElementExtension;

/// Initialize the sidebar contents and sidenav toggle handlers.
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
    assert(false, '"data-using-base-href" attribute on "body" is null.');
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
      final errorAnchor = HTMLAnchorElement()
        ..href = 'https://dart.dev/tools/dart-doc#troubleshoot'
        ..text = 'Failed to load sidebar. '
            'Visit dart.dev for help troubleshooting.';
      sidebarElement.appendChild(errorAnchor);
      return;
    }

    final responseText = (await fetchResponse.text().toDart).toDart;
    final sidebarContent = HTMLDivElement()..innerHtml = responseText;

    _updateLinks(baseHref, sidebarContent);
    sidebarElement.appendChild(sidebarContent);
  });
}

/// Recurses down a DOM tree to adjust the links in a newly loaded sidebar
/// if "base href" is not being used.
void _updateLinks(String baseHref, Node node) {
  // TODO(parlough): Once SDK constraint is >= 3.4, use isA extension.
  if (node.nodeName.toLowerCase() == 'a') {
    final element = node as HTMLAnchorElement;
    if (element.getAttribute('href') case final hrefString?) {
      final href = Uri.parse(hrefString);
      if (!href.isAbsolute) {
        element.href = '$baseHref$hrefString';
      }
    }
  }

  final children = node.childNodes;
  for (var childIndex = 0; childIndex < children.length; childIndex += 1) {
    if (children.item(childIndex) case final child?) {
      _updateLinks(baseHref, child);
    }
  }
}
