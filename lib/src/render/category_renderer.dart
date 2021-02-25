// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/category.dart';

/// A renderer for a [Category].
abstract class CategoryRenderer {
  const CategoryRenderer();

  /// Render the label of this [category].
  String renderCategoryLabel(Category category);

  /// Render the name of this [category] with a link to its specified
  /// [Category.href] if it is documented.
  String renderLinkedName(Category category);
}

/// A HTML renderer for a [Category].
class CategoryRendererHtml extends CategoryRenderer {
  const CategoryRendererHtml();

  @override
  String renderCategoryLabel(Category category) {
    final buffer = StringBuffer('<span class="category ');
    final name = category.name;
    buffer.writeAll(name.toLowerCase().split(' '), '-');
    buffer.write(' cp-');
    buffer.write(category.categoryIndex);

    if (category.isDocumented) {
      buffer.write(' linked');
    }

    buffer.write('"'); // Wrap up the class list and begin title
    buffer.write(' title="This is part of the ');
    buffer.write(name);
    buffer.write(' ');
    buffer.write(category.kind);
    buffer.write('.">'); // Wrap up the title

    buffer.write(renderLinkedName(category));
    buffer.write('</span>');

    return buffer.toString();
  }

  @override
  String renderLinkedName(Category category) {
    final unbrokenName = category.name.replaceAll(' ', '&nbsp;');
    if (category.isDocumented) {
      return '<a href="${category.href}">$unbrokenName</a>';
    } else {
      return unbrokenName;
    }
  }
}

/// A markdown renderer for a [Category].
class CategoryRendererMd extends CategoryRenderer {
  const CategoryRendererMd();

  @override
  String renderCategoryLabel(Category category) => renderLinkedName(category);

  @override
  String renderLinkedName(Category category) {
    final name = category.name;
    if (category.isDocumented) {
      return '[$name](${category.href})';
    }
    return name;
  }
}
