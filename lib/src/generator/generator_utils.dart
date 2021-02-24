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
  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();
  // ignore: omit_local_variable_types
  final List<Map<String, Object>> indexItems = categories
      .map((Categorization cat) {
        final data = <String, Object>{
          'name': cat.name,
          'qualifiedName': cat.fullyQualifiedName,
          'href': cat.href,
          'type': cat.kind,
        };

        if (cat.hasCategoryNames) {
          data['categories'] = cat.categoryNames;
        }
        if (cat.hasSubCategoryNames) {
          data['subcategories'] = cat.subCategoryNames;
        }
        if (cat.hasImage) {
          data['image'] = cat.image;
        }
        if (cat.hasSamples) {
          data['samples'] = cat.samples;
        }
        return data;
      })
      .sorted(_sortElements)
      .toList(growable: false);

  return encoder.convert(indexItems);
}

/// Convenience function to generate search index JSON since different
/// generators will likely want the same content for this.
String generateSearchIndexJson(
    Iterable<Indexable> indexedElements, bool pretty) {
  final encoder =
      pretty ? const JsonEncoder.withIndent(' ') : const JsonEncoder();
  final indexItems = indexedElements
      .map((Indexable ind) {
        final data = <String, Object>{
          'name': ind.name,
          'qualifiedName': ind.fullyQualifiedName,
          'href': ind.href,
          'type': ind.kind,
          'overriddenDepth': ind.overriddenDepth,
        };
        if (ind is ModelElement) {
          data['packageName'] = ind.package.name;
        }
        if (ind is EnclosedElement) {
          final ee = ind as EnclosedElement;
          data['enclosedBy'] = {
            'name': ee.enclosingElement.name,
            'type': ee.enclosingElement.kind
          };

          data['qualifiedName'] = ind.fullyQualifiedName;
        }
        return data;
      })
      .sorted(_sortElements)
      .toList(growable: false);

  return encoder.convert(indexItems);
}

int _sortElements(Map<String, Object> a, Map<String, Object> b) {
  final value = compareNatural(a['qualifiedName'], b['qualifiedName']);
  if (value == 0) {
    return compareNatural(a['type'], b['type']);
  }
  return value;
}
