// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/render/language_feature_renderer.dart';

const Map<String, String> _featureDescriptions = {
  'Null safety': 'Supports the null safety language feature.',
};

const Map<String, String> _featureUrls = {
  'Null safety': 'https://dart.dev/null-safety',
};

/// An abstraction for a language feature; used to render tags to notify
/// the user that the documentation should be specially interpreted.
class LanguageFeature {
  /// The description of this language feature.
  String get featureDescription => _featureDescriptions[name];

  /// A URL containing more information about this feature or `null` if there
  /// is none.
  String /*?*/ get featureUrl => _featureUrls[name];

  /// The rendered label for this language feature.
  String get featureLabel => _featureRenderer.renderLanguageFeatureLabel(this);

  /// The name of this language feature.
  final String name;

  final LanguageFeatureRenderer _featureRenderer;

  LanguageFeature(this.name, this._featureRenderer) {
    assert(_featureDescriptions.containsKey(name));
  }
}
