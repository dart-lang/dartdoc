// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/model.dart';

final RegExp _categoryRegExp = RegExp(
    r'[ ]*{@(api|category|subCategory|image|samples) (.+?)}[ ]*\n?',
    multiLine: true);

/// Mixin implementing dartdoc categorization for ModelElements.
abstract class Categorization implements ModelElement {
  @override
  String buildDocumentationAddition(String rawDocs) =>
      _stripAndSetDartdocCategories(rawDocs);

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
        case 'api':
          categorySet.add(match[2]!.trim());
          break;
        case 'subCategory':
          subCategorySet.add(match[2]!.trim());
          break;
        case 'image':
          _image = match[2]!.trim();
          break;
        case 'samples':
          _samples = match[2]!.trim();
          break;
      }
      return '';
    });

    _categoryNames = categorySet.toList(growable: false)..sort();
    _subCategoryNames = subCategorySet.toList(growable: false)..sort();
    _image ??= '';
    _samples ??= '';
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

  @override
  bool get hasCategoryNames => categoryNames?.isNotEmpty ?? false;
  List<String>? _categoryNames;

  /// Either a set of strings containing all declared categories for this symbol,
  /// or 'null' if none were declared.
  List<String>? get categoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_categoryNames == null) documentationLocal;
    return _categoryNames;
  }

  bool get hasImage => image!.isNotEmpty;
  String? _image;

  /// Either a URI to a defined image,
  /// or 'null' if one was not declared.
  String? get image {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_image == null) documentationLocal;
    return _image;
  }

  bool get hasSamples => samples?.isNotEmpty ?? false;
  String? _samples;

  /// Either a URI to documentation with samples,
  /// or 'null' if one was not declared.
  String? get samples {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_samples == null) documentationLocal;
    return _samples;
  }

  late final Iterable<Category> categories = [
    ...?categoryNames?.map((n) => package.nameToCategory[n]).whereNotNull()
  ]..sort();

  @override
  Iterable<Category> get displayedCategories {
    if (config.showUndocumentedCategories) return categories;
    return categories.where((c) => c.isDocumented);
  }

  bool? _hasCategorization;

  /// True if categories, subcategories, a documentation icon, or samples were
  /// declared.
  late final bool hasCategorization = () {
    if (_hasCategorization == null) documentationLocal;
    return _hasCategorization ?? false;
  }();
}
