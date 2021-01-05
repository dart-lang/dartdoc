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
    final classesText = [
      'feature',
      'feature-${feature.name.split(' ').join('-').toLowerCase()}'
    ].join(' ');

    if (feature.featureUrl != null) {
      return '<a href="${feature.featureUrl}" class="${classesText}"'
          ' title="${feature.featureDescription}">${feature.name}</a>';
    }

    return '<span class="${classesText}" '
        'title="${feature.featureDescription}">${feature.name}</span>';
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
    if (feature.featureUrl != null) {
      return '*[\<${feature.name}\>](${feature.featureUrl})*';
    }
    return '*\<${feature.name}\>*';
  }
}
