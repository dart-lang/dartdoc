// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/directives/categorization.dart';
import 'package:dartdoc/src/model/documentable.dart';
import 'package:dartdoc/src/model/inheritable.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/nameable.dart';

String generateCategoryJson(Iterable<Categorization> categories, bool pretty) {
  final indexItems = [
    for (final categorization
        in categories.sorted(_compareElementRepresentations))
      <String, Object?>{
        'name': categorization.name,
        'qualifiedName': categorization.canonicalQualifiedName,
        'href': categorization.href,
        // TODO(srawlins): Rename to 'kind'.
        'type': categorization.kind.toString(),
        if (categorization.hasCategoryNames)
          'categories': categorization.categoryNames,
        if (categorization.hasSubCategoryNames)
          'subcategories': categorization.subCategoryNames,
      }
  ];

  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();

  return encoder.convert(indexItems.toList(growable: false));
}

/// Generates the text of the search index file (`index.json`) containing
/// [indexedElements] and [packageOrder].
///
/// Passing `pretty: true` will use a [JsonEncoder] with a single-space indent.
String generateSearchIndexJson(Iterable<Documentable> indexedElements,
    {required List<String> packageOrder, required bool pretty}) {
  var indexItems = <Map<String, Object?>>[];

  for (var element in indexedElements.sorted(_compareElementRepresentations)) {
    assert(
      element.href != null,
      "element expected to have a non-null 'href', but was null: "
      "'$element'",
    );
    var item = {
      'name': element.name,
      'qualifiedName': element.canonicalQualifiedName,
      'href': element.href,
      'kind': element.kind.index,
      if (element is Inheritable) 'overriddenDepth': element.overriddenDepth,
    };

    if (element is ModelElement) {
      item['packageRank'] = _packageRank(packageOrder, element);
      item['desc'] = _removeHtmlTags(element.oneLineDoc);
      var enclosingElement = element.enclosingElement is Library
          ? element.canonicalLibrary
          : element.enclosingElement;
      if (enclosingElement != null) {
        assert(
          enclosingElement.href != null,
          "'enclosedBy' element expected to have a non-null 'href', "
          "but was null: '$element', enclosed by the "
          "${enclosingElement.runtimeType} '$enclosingElement'",
        );
        item['enclosedBy'] = {
          'name': enclosingElement.name,
          'kind': enclosingElement.kind.index,
          'href': enclosingElement.href,
        };
      }
    }
    indexItems.add(item);
  }

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
      !_dartCoreLibraries.contains(element.library!.name)) {
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
int _compareElementRepresentations(Documentable a, Documentable b) {
  final value =
      compareNatural(a.canonicalQualifiedName, b.canonicalQualifiedName);
  if (value == 0) {
    return compareNatural(a.kind.toString(), b.kind.toString());
  }
  return value;
}

extension on Nameable {
  /// The fully qualified name of this element, but using the canonical library,
  /// if it has one.
  String get canonicalQualifiedName {
    var self = this;
    if (self is Library) return name;
    if (self is ModelElement) {
      var library = self.canonicalLibrary ?? self.library;
      if (library != null) {
        return '${library.name}.${self.qualifiedName}';
      }
    }
    return name;
  }
}
