// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/render/language_feature_renderer.dart';

const Map<String, String> _featureDescriptions = {
  'sealed': 'All direct subtypes must be defined in the same library.',
  'abstract': 'This type can not be directly constructed.',
  'base': 'This type can only be extended (not implemented or mixed in).',
  'interface': 'This type can only be implemented (not extended or mixed in).',
  'final': 'This type can neither be extended, implemented, nor mixed in.',
  'mixin': 'This type can be used as a class and a mixin.',
};

const Map<String, String> _featureUrls = {
  // TODO(jcollins-g): link to dart.dev for all links once documentation is
  // available.
  'sealed':
      'https://github.com/dart-lang/language/blob/main/accepted/future-releases/sealed-types/feature-specification.md#sealed-types',
  'abstract': 'https://dart.dev/language/classes#abstract-classes',
  'base':
      'https://github.com/dart-lang/language/blob/main/accepted/future-releases/class-modifiers/feature-specification.md#class-modifiers',
  'interface':
      'https://github.com/dart-lang/language/blob/main/accepted/future-releases/class-modifiers/feature-specification.md#class-modifiers',
  'final':
      'https://github.com/dart-lang/language/blob/main/accepted/future-releases/class-modifiers/feature-specification.md#class-modifiers',
  'mixin':
      'https://github.com/dart-lang/language/blob/main/accepted/future-releases/class-modifiers/feature-specification.md#class-modifiers',
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
