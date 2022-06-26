// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/categorization.dart';
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
        'type': categorization.kind,
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

  return encoder.convert(indexItems.toList());
}

String generateSearchIndexJson(
    Iterable<Indexable> indexedElements, bool pretty) {
  final indexItems = [
    for (final indexable
        in indexedElements.sorted(_compareElementRepresentations))
      <String, Object?>{
        'name': indexable.name,
        'qualifiedName': indexable.fullyQualifiedName,
        'href': indexable.href,
        'type': indexable.kind,
        'overriddenDepth': indexable.overriddenDepth,
        if (indexable is ModelElement) 'packageName': indexable.package?.name,
        if (indexable is EnclosedElement)
          'enclosedBy': {
            'name': indexable.enclosingElement!.name,
            'type': indexable.enclosingElement!.kind
          },
      }
  ];

  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();

  return encoder.convert(indexItems.toList());
}

// Compares two elements, first by fully qualified name, then by kind.
int _compareElementRepresentations(Indexable a, Indexable b) {
  final value = compareNatural(a.fullyQualifiedName, b.fullyQualifiedName);
  if (value == 0) {
    return compareNatural(a.kind, b.kind);
  }
  return value;
}
