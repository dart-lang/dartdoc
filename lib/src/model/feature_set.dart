// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/language_feature.dart';
import 'package:dartdoc/src/model/model.dart';

/// [ModelElement]s can have different language features that can alter
/// the user interpretation of the interface.
mixin FeatureSet {
  PackageGraph get packageGraph;
  Library get library;

  /// A list of language features that both apply to this [ModelElement] and
  /// make sense to display in context.
  Iterable<LanguageFeature> get displayedLanguageFeatures => const [];

  bool get hasFeatureSet => displayedLanguageFeatures.isNotEmpty;
}
