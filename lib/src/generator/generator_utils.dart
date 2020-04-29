// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/categorization.dart';
import 'package:dartdoc/src/model/enclosed_element.dart';
import 'package:dartdoc/src/model/indexable.dart';

/// Convenience function to generate category JSON since different generators
/// will likely want the same content for this.
String generateCategoryJson(Iterable<Categorization> categories, bool pretty) {
  var encoder = pretty ? JsonEncoder.withIndent(' ') : JsonEncoder();
  // ignore: omit_local_variable_types
  final List<Map> indexItems = categories.map((Categorization e) {
    var data = <String, dynamic>{
      'name': e.name,
      'qualifiedName': e.fullyQualifiedName,
      'href': e.href,
      'type': e.kind,
    };

    if (e.hasCategoryNames) data['categories'] = e.categoryNames;
    if (e.hasSubCategoryNames) data['subcategories'] = e.subCategoryNames;
    if (e.hasImage) data['image'] = e.image;
    if (e.hasSamples) data['samples'] = e.samples;
    return data;
  }).toList();

  indexItems.sort((a, b) {
    var value = compareNatural(a['qualifiedName'], b['qualifiedName']);
    if (value == 0) {
      value = compareNatural(a['type'], b['type']);
    }
    return value;
  });

  return encoder.convert(indexItems);
}

/// Convenience function to generate search index JSON since different
/// generators will likely want the same content for this.
String generateSearchIndexJson(
    Iterable<Indexable> indexedElements, bool pretty) {
  var encoder = pretty ? JsonEncoder.withIndent(' ') : JsonEncoder();
  final List<Map> indexItems = indexedElements.map((Indexable e) {
    var data = <String, dynamic>{
      'name': e.name,
      'qualifiedName': e.fullyQualifiedName,
      'href': e.href,
      'type': e.kind,
      'overriddenDepth': e.overriddenDepth,
    };
    if (e is EnclosedElement) {
      var ee = e as EnclosedElement;
      data['enclosedBy'] = {
        'name': ee.enclosingElement.name,
        'type': ee.enclosingElement.kind
      };

      data['qualifiedName'] = e.fullyQualifiedName;
    }
    return data;
  }).toList();

  indexItems.sort((a, b) {
    var value = compareNatural(a['qualifiedName'], b['qualifiedName']);
    if (value == 0) {
      value = compareNatural(a['type'], b['type']);
    }
    return value;
  });

  return encoder.convert(indexItems);
}
