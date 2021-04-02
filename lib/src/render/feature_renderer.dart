// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/feature.dart';

const _htmlEscape = HtmlEscape();

/// A renderer for subclasses of [Feature]. (The base class does not require
/// separate rendering, represented by pre-defined constant strings.)
abstract class FeatureRenderer {
  const FeatureRenderer();

  /// Render this [Annotation].
  String renderAnnotation(Annotation feature);
}

/// A HTML renderer for a [Feature].
class FeatureRendererHtml extends FeatureRenderer {
  const FeatureRendererHtml();

  @override
  String renderAnnotation(Annotation feature) =>
      '@' + feature.linkedName + _htmlEscape.convert(feature.parameterText);
}

/// A markdown renderer for a [Feature].
class FeatureRendererMd extends FeatureRenderer {
  const FeatureRendererMd();

  @override
  String renderAnnotation(Annotation feature) =>
      '@' + feature.linkedName + _htmlEscape.convert(feature.parameterText);
}
