// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/language_feature.dart';

/// A renderer for a [LanguageFeature].
abstract class LanguageFeatureRenderer {
  const LanguageFeatureRenderer();

  /// Render the label of this [feature].
  String renderLanguageFeatureLabel(LanguageFeature feature);
}

/// A HTML renderer for a [LanguageFeature].
class LanguageFeatureRendererHtml extends LanguageFeatureRenderer {
  const LanguageFeatureRendererHtml();

  @override
  String renderLanguageFeatureLabel(LanguageFeature feature) {
    final buffer = StringBuffer();
    final url = feature.featureUrl;

    if (url != null) {
      buffer.write('<a href="');
      buffer.write(url);
      buffer.write('"');
    } else {
      buffer.write('<span');
    }

    final name = feature.name;

    buffer.write(' class="feature feature-');
    buffer.writeAll(name.toLowerCase().split(' '), '-');
    buffer.write('" title="');
    buffer.write(feature.featureDescription);
    buffer.write('">');
    buffer.write(name);

    if (url != null) {
      buffer.write('</a>');
    } else {
      buffer.write('</span>');
    }

    return buffer.toString();
  }
}

/// A markdown renderer for a [LanguageFeature].
class LanguageFeatureRendererMd extends LanguageFeatureRenderer {
  const LanguageFeatureRendererMd();

  @override
  String renderLanguageFeatureLabel(LanguageFeature feature) {
    final featureUrl = feature.featureUrl;
    if (featureUrl != null) {
      return '*[<${feature.name}>]($featureUrl)*';
    }
    return '*<${feature.name}>*';
  }
}
