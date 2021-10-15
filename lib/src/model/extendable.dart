// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// Mixin for subclasses of [ModelElement] representing Elements that can be
/// extension methods.
mixin Extendable on ContainerMember {
  /// Returns this Extendable from the [Extension] in which it was declared.
  Extendable get definingExtension => throw UnimplementedError;

  @override
  Container get canonicalEnclosingContainer => throw UnimplementedError;
}
