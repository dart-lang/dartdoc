// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'package:dartdoc/src/model/model.dart';

final categoryRegexp = RegExp(
    r'[ ]*{@(api|category|subCategory|image|samples) (.+?)}[ ]*\n?',
    multiLine: true);

/// Mixin implementing dartdoc categorization for ModelElements.
abstract class Categorization implements ModelElement {
  @override
  String buildDocumentationAddition(String rawDocs) =>
      _stripAndSetDartdocCategories(rawDocs ??= '');

  /// Parse {@category ...} and related information in API comments, stripping
  /// out that information from the given comments and returning the stripped
  /// version.
  String _stripAndSetDartdocCategories(String rawDocs) {
    Set<String> _categorySet = Set();
    Set<String> _subCategorySet = Set();
    _hasCategorization = false;

    rawDocs = rawDocs.replaceAllMapped(categoryRegexp, (match) {
      _hasCategorization = true;
      switch (match[1]) {
        case 'category':
        case 'api':
          _categorySet.add(match[2].trim());
          break;
        case 'subCategory':
          _subCategorySet.add(match[2].trim());
          break;
        case 'image':
          _image = match[2].trim();
          break;
        case 'samples':
          _samples = match[2].trim();
          break;
      }
      return '';
    });

    if (_categorySet.isEmpty) {
      // All objects are in the default category if not specified.
      _categorySet.add(null);
    }
    if (_subCategorySet.isEmpty) {
      // All objects are in the default subcategory if not specified.
      _subCategorySet.add(null);
    }
    _categoryNames = _categorySet.toList()..sort();
    _subCategoryNames = _subCategorySet.toList()..sort();
    _image ??= '';
    _samples ??= '';
    return rawDocs;
  }

  bool get hasSubCategoryNames =>
      subCategoryNames.length > 1 || subCategoryNames.first != null;
  List<String> _subCategoryNames;

  /// Either a set of strings containing all declared subcategories for this symbol,
  /// or a set containing Null if none were declared.
  List<String> get subCategoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_subCategoryNames == null) documentationLocal;
    return _subCategoryNames;
  }

  @override
  bool get hasCategoryNames =>
      categoryNames.length > 1 || categoryNames.first != null;
  List<String> _categoryNames;

  /// Either a set of strings containing all declared categories for this symbol,
  /// or a set containing Null if none were declared.
  List<String> get categoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_categoryNames == null) documentationLocal;
    return _categoryNames;
  }

  bool get hasImage => image.isNotEmpty;
  String _image;

  /// Either a URI to a defined image, or the empty string if none
  /// was declared.
  String get image {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_image == null) documentationLocal;
    return _image;
  }

  bool get hasSamples => samples.isNotEmpty;
  String _samples;

  /// Either a URI to documentation with samples, or the empty string if none
  /// was declared.
  String get samples {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_samples == null) documentationLocal;
    return _samples;
  }

  bool _hasCategorization;

  Iterable<Category> _categories;

  Iterable<Category> get categories {
    if (_categories == null) {
      _categories = categoryNames
          .map((n) => package.nameToCategory[n])
          .where((c) => c != null)
          .toList()
        ..sort();
    }
    return _categories;
  }

  Iterable<Category> get displayedCategories {
    if (config.showUndocumentedCategories) return categories;
    return categories.where((c) => c.isDocumented);
  }

  /// True if categories, subcategories, a documentation icon, or samples were
  /// declared.
  bool get hasCategorization {
    if (_hasCategorization == null) documentationLocal;
    return _hasCategorization;
  }
}
