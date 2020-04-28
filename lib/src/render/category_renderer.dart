// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/category.dart';

abstract class CategoryRenderer {
  String renderCategoryLabel(Category category);
  String renderLinkedName(Category category);
}

class CategoryRendererHtml extends CategoryRenderer {
  static final CategoryRendererHtml _instance = CategoryRendererHtml._();

  factory CategoryRendererHtml() {
    return _instance;
  }

  CategoryRendererHtml._();

  @override
  String renderCategoryLabel(Category category) {
    var spanClasses = <String>[];
    spanClasses.add('category');
    spanClasses.add(category.name.split(' ').join('-').toLowerCase());
    spanClasses.add('cp-${category.categoryIndex}');
    if (category.isDocumented) {
      spanClasses.add('linked');
    }
    var spanTitle = 'This is part of the ${category.name} ${category.kind}.';

    var buf = StringBuffer();
    buf.write('<span class="${spanClasses.join(' ')}" title="$spanTitle">');
    buf.write(renderLinkedName(category));
    buf.write('</span>');
    return buf.toString();
  }

  @override
  String renderLinkedName(Category category) {
    var unbrokenName = category.name.replaceAll(' ', '&nbsp;');
    if (category.isDocumented) {
      return '<a href="${category.href}">$unbrokenName</a>';
    } else {
      return unbrokenName;
    }
  }
}

class CategoryRendererMd extends CategoryRenderer {
  @override
  String renderCategoryLabel(Category category) => renderLinkedName(category);

  @override
  String renderLinkedName(Category category) {
    var name = category.name;
    if (category.isDocumented) {
      return '[$name](${category.href})';
    }
    return name;
  }
}
