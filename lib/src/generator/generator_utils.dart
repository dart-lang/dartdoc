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

/// Generates the text of the search index file (`index.json`) containing
/// [indexedItems] and [packageOrder].
///
/// Passing `pretty: true` will use a [JsonEncoder] with a single-space indent.
String generateSearchIndexJson(Iterable<Indexable> indexedElements,
    {required List<String> packageOrder, required bool pretty}) {
  final indexItems = [
    for (final indexable
        in indexedElements.sorted(_compareElementRepresentations))
      {
        'name': indexable.name,
        'qualifiedName': indexable.fullyQualifiedName,
        'href': indexable.href,
        'kind': indexable.kind.index,
        // TODO(srawlins): Only include this for [Inheritable] items.
        'overriddenDepth': indexable.overriddenDepth,
        if (indexable is ModelElement)
          'packageRank': _packageRank(packageOrder, indexable),
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

/// The "package rank" of [element], given a [packageOrder].
///
/// Briefly, this is 10 times the element's package's position in the
/// [packageOrder], or 10 times the length of [packageOrder] if the element's
/// package is not listed in [packageOrder].
int _packageRank(List<String> packageOrder, ModelElement element) {
  if (packageOrder.isEmpty) return 0;
  var packageName = element.package.name;
  var index = packageOrder.indexOf(packageName);
  if (index == -1) return packageOrder.length * 10;
  if (packageName == 'Dart' &&
      !_dartCoreLibraries.contains(element.library.name)) {
    // Non-"core" Dart SDK libraries should be ranked slightly lower than "core"
    // Dart SDK libraries. The "core" Dart SDK libraries are the ones labeled as
    // such at <https://api.dart.dev>, which can be used in both VM and Web
    // environments.
    // Note we choose integers throughout this function (as opposed to adding
    // 0.5 here) in order to facilitate a proper [Comparable] comparison.
    return index * 10 + 5;
  }
  return index * 10;
}

/// The set of "core" Dart libraries, used to rank contained items above items
/// declared elsewhere in the Dart SDK.
const _dartCoreLibraries = {
  'dart:async',
  'dart:collection',
  'dart:convert',
  'dart:core',
  'dart:developer',
  'dart:math',
  'dart:typed_data',

  // Plus the two core Flutter engine libraries.
  'dart:ui',
  'dart:web_ui',
};

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
