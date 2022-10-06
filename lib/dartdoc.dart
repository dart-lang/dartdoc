// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
library dartdoc;

export 'package:dartdoc/src/dartdoc.dart';
export 'package:dartdoc/src/dartdoc_options.dart';
@Deprecated(
    'Elements which are only exposed via this export will no longer be part of '
    'the public API starting in dartdoc 7.0.0')
export 'package:dartdoc/src/element_type.dart';
export 'package:dartdoc/src/generator/generator.dart';
@Deprecated(
    'Elements which are only exposed via this export will no longer be part of '
    'the public API starting in dartdoc 7.0.0')
export 'package:dartdoc/src/model/model.dart';
export 'package:dartdoc/src/model/package_builder.dart';
export 'package:dartdoc/src/model/package_graph.dart';
export 'package:dartdoc/src/package_config_provider.dart';
export 'package:dartdoc/src/package_meta.dart';
