// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

final RegExp _categoryRegExp =
    RegExp(r'[ ]*{@(category|subCategory) (.+?)}[ ]*\n?', multiLine: true);

/// Mixin parsing the `@category` directive for ModelElements.
mixin Categorization on DocumentationComment {
  @override
  String buildDocumentationAddition(String docs) =>
      _stripAndSetDartdocCategories(super.buildDocumentationAddition(docs));

  /// Parse `{@category ...}` and related information in API comments, stripping
  /// out that information from the given comments and returning the stripped
  /// version.
  String _stripAndSetDartdocCategories(String rawDocs) {
    var categorySet = <String>{};
    var subCategorySet = <String>{};
    _hasCategorization = false;

    rawDocs = rawDocs.replaceAllMapped(_categoryRegExp, (match) {
      _hasCategorization = true;
      switch (match[1]) {
        case 'category':
          categorySet.add(match[2]!.trim());
        case 'subCategory':
          subCategorySet.add(match[2]!.trim());
      }
      return '';
    });

    _categoryNames = categorySet.toList(growable: false)..sort();
    _subCategoryNames = subCategorySet.toList(growable: false)..sort();
    return rawDocs;
  }

  bool get hasSubCategoryNames => subCategoryNames?.isNotEmpty ?? false;
  List<String>? _subCategoryNames;

  /// Either a set of strings containing all declared subcategories for this symbol,
  /// or 'null' if none were declared.
  List<String>? get subCategoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_subCategoryNames == null) documentationLocal;
    return _subCategoryNames;
  }

  bool get hasCategoryNames => categoryNames?.isNotEmpty ?? false;
  List<String>? _categoryNames;

  /// Either a set of strings containing all declared categories for this symbol,
  /// or 'null' if none were declared.
  List<String>? get categoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_categoryNames == null) documentationLocal;
    return _categoryNames;
  }

  @visibleForTesting
  List<Category> get categories => [
        ...?categoryNames?.map((n) => package.nameToCategory[n]).nonNulls
      ]..sort();

  Iterable<Category> get displayedCategories {
    if (config.showUndocumentedCategories) return categories;
    return categories.where((c) => c.isDocumented);
  }

  bool? _hasCategorization;

  /// True if categories, subcategories, or a documentation icon were
  /// declared.
  late final bool hasCategorization = () {
    if (_hasCategorization == null) documentationLocal;
    return _hasCategorization ?? false;
  }();
}
