// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/attribute.dart';

const _htmlEscape = HtmlEscape();

/// A renderer for subclasses of [Attribute].
///
/// (The base class does not require separate rendering, represented by
/// pre-defined constant strings.)
abstract class AttributeRenderer {
  const AttributeRenderer();

  /// Render this [Annotation].
  String renderAnnotation(Annotation attribute);
}

/// A HTML renderer for an [Attribute].
class AttributeRendererHtml extends AttributeRenderer {
  const AttributeRendererHtml();

  @override
  String renderAnnotation(Annotation attribute) =>
      '@${attribute.linkedName}${_htmlEscape.convert(attribute.parameterText)}';
}
