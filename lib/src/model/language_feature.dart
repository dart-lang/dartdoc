// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/render/feature_renderer.dart';

const Map<String, String> _featureDescriptions = {
  'Null safety': 'Supports the null safety language feature.',
};

/// An abstraction for a language feature; used to render tags to notify
/// the user that the documentation should be specially interpreted.
class LanguageFeature {
  String get featureDescription => _featureDescriptions[name];
  String get featureLabel => _featureRenderer.renderFeatureLabel(this);

  final String name;

  final FeatureRenderer _featureRenderer;

  LanguageFeature(this.name, this._featureRenderer) {
    assert(_featureDescriptions.containsKey(name));
  }
}
