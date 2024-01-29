// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'highlight.dart' as highlight;
import 'search.dart' as search;
import 'sidenav.dart' as sidenav;
import 'theme.dart' as theme;
import 'web_interop.dart';

void main() {
  initializeSidebars();
  search.init();
  sidenav.init();
  highlight.init();
  theme.init();
}

void initializeSidebars() {
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
  final sanitizer = _SidebarNodeTreeSanitizer(baseHref);

  void loadSidebar(String? sidebarPath, Element? sidebarElement) {
    if (sidebarPath == null || sidebarPath.isEmpty || sidebarElement == null) {
      return;
    }

    window.fetch('$baseHref$sidebarPath').then((response) async {
      final fetchResponse = response as FetchResponse;
      if (response.status != 200) {
        final errorAnchor = (document.createElement('a') as AnchorElement)
          ..href = 'https://dart.dev/tools/dart-doc'
          ..text = 'Failed to load sidebar. '
              'Visit dart.dev for help troubleshooting.';
        sidebarElement.append(errorAnchor);
        return;
      }

      final content = await fetchResponse.text;

      sidebarElement.setInnerHtml(content, treeSanitizer: sanitizer);
    });
  }

  final aboveSidebarPath = mainContent.getAttribute('data-above-sidebar');
  final leftSidebar = document.getElementById('dartdoc-sidebar-left-content');
  loadSidebar(aboveSidebarPath, leftSidebar);

  final belowSidebarPath = mainContent.getAttribute('data-below-sidebar');
  final rightSidebar = document.getElementById('dartdoc-sidebar-right');
  loadSidebar(belowSidebarPath, rightSidebar);
}

/// A permissive sanitizer that allows external links (e.g. to api.dart.dev) and
/// adjusts the links in a newly loaded sidebar, if "base href" is not being
/// used.
class _SidebarNodeTreeSanitizer implements NodeTreeSanitizer {
  final String baseHref;

  _SidebarNodeTreeSanitizer(this.baseHref);

  @override
  void sanitizeTree(Node node) {
    if (node is Element && node.nodeName == 'A') {
      final hrefString = node.attributes['href'];
      if (hrefString != null) {
        final href = Uri.parse(hrefString);
        if (!href.isAbsolute) {
          node.setAttribute('href', '$baseHref$hrefString');
        }
      }
    }
    node.childNodes.forEach(sanitizeTree);
  }
}
