// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/language_feature.dart';

abstract class FeatureRenderer {
  String renderFeatureLabel(LanguageFeature feature);
}

class FeatureRendererHtml extends FeatureRenderer {
  static final FeatureRendererHtml _instance = FeatureRendererHtml._();
  factory FeatureRendererHtml() {
    return _instance;
  }

  FeatureRendererHtml._();

  @override
  String renderFeatureLabel(LanguageFeature feature) {
    var spanClasses = <String>[];
    spanClasses.add('feature');
    spanClasses
        .add('feature-${feature.name.split(' ').join('-').toLowerCase()}');

    var buf = StringBuffer();
    buf.write(
        '<span class="${spanClasses.join(' ')}" title="${feature.featureDescription}">${feature.name}</span>');
    return buf.toString();
  }
}

class FeatureRendererMd extends FeatureRenderer {
  static final FeatureRendererMd _instance = FeatureRendererMd._();
  factory FeatureRendererMd() {
    return _instance;
  }

  FeatureRendererMd._();
  @override
  String renderFeatureLabel(LanguageFeature feature) {
    return '*\<${feature.name}\>*';
  }
}
