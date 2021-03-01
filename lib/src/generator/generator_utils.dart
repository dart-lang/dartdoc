// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/categorization.dart';
import 'package:dartdoc/src/model/enclosed_element.dart';
import 'package:dartdoc/src/model/indexable.dart';
import 'package:dartdoc/src/model/model_element.dart';

/// Convenience function to generate category JSON since different generators
/// will likely want the same content for this.
String generateCategoryJson(Iterable<Categorization> categories, bool pretty) {
  // ignore: omit_local_variable_types
  final List<Map<String, Object>> indexItems =
      categories.map((Categorization categorization) {
    final data = <String, Object>{
      'name': categorization.name,
      'qualifiedName': categorization.fullyQualifiedName,
      'href': categorization.href,
      'type': categorization.kind,
    };

    if (categorization.hasCategoryNames) {
      data['categories'] = categorization.categoryNames;
    }
    if (categorization.hasSubCategoryNames) {
      data['subcategories'] = categorization.subCategoryNames;
    }
    if (categorization.hasImage) {
      data['image'] = categorization.image;
    }
    if (categorization.hasSamples) {
      data['samples'] = categorization.samples;
    }
    return data;
  }).sorted(_sortElementRepresentations);

  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();

  return encoder.convert(indexItems);
}

/// Convenience function to generate search index JSON since different
/// generators will likely want the same content for this.
String generateSearchIndexJson(
    Iterable<Indexable> indexedElements, bool pretty) {
  final indexItems = indexedElements.map((Indexable indexable) {
    final data = <String, Object>{
      'name': indexable.name,
      'qualifiedName': indexable.fullyQualifiedName,
      'href': indexable.href,
      'type': indexable.kind,
      'overriddenDepth': indexable.overriddenDepth,
    };
    if (indexable is ModelElement) {
      data['packageName'] = indexable.package.name;
    }
    if (indexable is EnclosedElement) {
      final ee = indexable as EnclosedElement;
      data['enclosedBy'] = {
        'name': ee.enclosingElement.name,
        'type': ee.enclosingElement.kind
      };

      data['qualifiedName'] = indexable.fullyQualifiedName;
    }
    return data;
  }).sorted(_sortElementRepresentations);

  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();

  return encoder.convert(indexItems);
}

int _sortElementRepresentations(Map<String, Object> a, Map<String, Object> b) {
  final value = compareNatural(a['qualifiedName'], b['qualifiedName']);
  if (value == 0) {
    return compareNatural(a['type'], b['type']);
  }
  return value;
}
