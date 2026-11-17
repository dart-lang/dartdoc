// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// CSS class applied to Material Symbols Outlined ligature elements.
const String materialSymbolsClass = 'material-symbols-outlined';

/// Material Symbols Outlined ligatures rendered dynamically from `web/`.
///
/// Every ligature listed here must appear in the alphabetically sorted
/// `icon_names` query parameter in `lib/templates/_head.html`.
enum WebMaterialSymbol {
  check('check'),
  contentCopy('content_copy');

  const WebMaterialSymbol(this.ligature);

  /// The snake_case ligature string rendered inside a [materialSymbolsClass]
  /// element.
  final String ligature;
}
