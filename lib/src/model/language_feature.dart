// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/render/language_feature_renderer.dart';

const Map<String, String> _featureDescriptions = {
  'sealed':
      'The direct subtypes of this class will be checked for exhaustiveness in switches.',
  'abstract': 'This type can not be directly constructed.',
  'base':
      'This class or mixin can only be extended (not implemented or mixed in).',
  'interface': 'This class can only be implemented (not extended or mixed in).',
  'final': 'This class can neither be extended, implemented, nor mixed in.',
  'mixin': 'This class can be used as a class and a mixin.',
};

const Map<String, String> _featureUrls = {
  'sealed': 'https://dart.dev/language/class-modifiers#sealed',
  'abstract': 'https://dart.dev/language/class-modifiers#abstract',
  'base': 'https://dart.dev/language/class-modifiers#base',
  'interface': 'https://dart.dev/language/class-modifiers#interface',
  'final': 'https://dart.dev/language/class-modifiers#final',
  'mixin': 'https://dart.dev/language/mixins',
};

/// An abstraction for a language feature; used to render tags ('chips') to
/// notify the user that the documentation should be specially interpreted.
class LanguageFeature {
  /// The description of this language feature.
  String? get featureDescription => _featureDescriptions[name];

  /// A URL containing more information about this feature or `null` if there
  /// is none.
  String? get featureUrl => _featureUrls[name];

  /// The rendered label for this language feature.
  String get featureLabel => _featureRenderer.renderLanguageFeatureLabel(this);

  /// The name of this language feature.
  final String name;

  final LanguageFeatureRenderer _featureRenderer;

  LanguageFeature(this.name, this._featureRenderer)
      : assert(_featureDescriptions.containsKey(name));
}
