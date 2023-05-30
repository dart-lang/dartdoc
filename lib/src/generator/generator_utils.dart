// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/directives/categorization.dart';
import 'package:dartdoc/src/model/enclosed_element.dart';
import 'package:dartdoc/src/model/indexable.dart';
import 'package:dartdoc/src/model/model_element.dart';

String generateCategoryJson(Iterable<Categorization> categories, bool pretty) {
  final indexItems = [
    for (final categorization
        in categories.sorted(_compareElementRepresentations))
      <String, Object?>{
        'name': categorization.name,
        'qualifiedName': categorization.fullyQualifiedName,
        'href': categorization.href,
        // TODO(srawlins): Rename to 'kind'.
        'type': categorization.kind.toString(),
        if (categorization.hasCategoryNames)
          'categories': categorization.categoryNames,
        if (categorization.hasSubCategoryNames)
          'subcategories': categorization.subCategoryNames,
        if (categorization.hasImage) 'image': categorization.image,
        if (categorization.hasSamples) 'samples': categorization.samples,
      }
  ];

  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();

  return encoder.convert(indexItems.toList(growable: false));
}

String generateSearchIndexJson(Iterable<Indexable> indexedElements, bool pretty,
    List<String> packageOrder) {
  final indexItems = [
    {packageOrderKey: packageOrder},
    for (final indexable
        in indexedElements.sorted(_compareElementRepresentations))
      {
        'name': indexable.name,
        'qualifiedName': indexable.fullyQualifiedName,
        'href': indexable.href,
        'kind': indexable.kind.index,
        'overriddenDepth': indexable.overriddenDepth,
        if (indexable is ModelElement) 'packageName': indexable.package.name,
        if (indexable is ModelElement)
          'desc': _removeHtmlTags(indexable.oneLineDoc),
        if (indexable is EnclosedElement)
          'enclosedBy': {
            'name': indexable.enclosingElement.name,
            'kind': indexable.enclosingElement.kind.index,
            'href': indexable.enclosingElement.href,
          },
      }
  ];

  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();

  return encoder.convert(indexItems);
}

/// The key used in the `index.json` file used to specify the package order.
const packageOrderKey = '__PACKAGE_ORDER__';

String _removeHtmlTags(String? input) =>
    input?.replaceAll(_htmlTagPattern, '') ?? '';

final _htmlTagPattern =
    RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

// Compares two elements, first by fully qualified name, then by kind.
int _compareElementRepresentations<T extends Indexable>(T a, T b) {
  final value = compareNatural(a.fullyQualifiedName, b.fullyQualifiedName);
  if (value == 0) {
    return compareNatural(a.kind.toString(), b.kind.toString());
  }
  return value;
}
